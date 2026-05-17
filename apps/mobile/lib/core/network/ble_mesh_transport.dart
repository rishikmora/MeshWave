import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../protocol/packet.dart';
import '../protocol/packet_codec.dart';
import 'mesh_transport.dart';

class BleMeshTransport implements MeshTransport {
  BleMeshTransport({
    required this.serviceUuid,
    required this.txCharacteristicUuid,
    required this.rxCharacteristicUuid,
    PacketCodec? codec,
  }) : _codec = codec ?? const PacketCodec();

  final Guid serviceUuid;
  final Guid txCharacteristicUuid;
  final Guid rxCharacteristicUuid;
  final PacketCodec _codec;
  final _state = StreamController<TransportState>.broadcast();
  final _packets = StreamController<MeshPacket>.broadcast();
  final _diagnostics = StreamController<TransportDiagnostics>.broadcast();

  BluetoothDevice? _device;
  BluetoothCharacteristic? _tx;
  BluetoothCharacteristic? _rx;
  StreamSubscription<List<int>>? _rxSubscription;

  @override
  Stream<TransportState> get state => _state.stream;

  @override
  Stream<MeshPacket> get packets => _packets.stream;

  @override
  Stream<TransportDiagnostics> get diagnostics => _diagnostics.stream;

  @override
  Future<void> scan() async {
    _state.add(TransportState.scanning);
    await FlutterBluePlus.startScan(
      withServices: [serviceUuid],
      timeout: const Duration(seconds: 8),
    );
    _state.add(TransportState.disconnected);
  }

  @override
  Future<void> connect(String deviceId) async {
    _state.add(TransportState.connecting);
    final results = FlutterBluePlus.scanResults;
    final subscription = results.listen((items) async {
      for (final result in items) {
        if (result.device.remoteId.str == deviceId ||
            result.advertisementData.advName == deviceId) {
          await FlutterBluePlus.stopScan();
          await _connectDevice(result.device);
          return;
        }
      }
    });
    await FlutterBluePlus.startScan(
      withServices: [serviceUuid],
      timeout: const Duration(seconds: 8),
    );
    await subscription.cancel();
  }

  Future<void> _connectDevice(BluetoothDevice device) async {
    _device = device;
    await device.connect(timeout: const Duration(seconds: 12));
    final services = await device.discoverServices();
    for (final service in services.where((item) => item.uuid == serviceUuid)) {
      for (final characteristic in service.characteristics) {
        if (characteristic.uuid == txCharacteristicUuid) {
          _tx = characteristic;
        } else if (characteristic.uuid == rxCharacteristicUuid) {
          _rx = characteristic;
        }
      }
    }
    if (_tx == null || _rx == null) {
      throw StateError('MeshWave BLE bridge characteristics not found');
    }
    await _rx!.setNotifyValue(true);
    _rxSubscription = _rx!.lastValueStream.listen(_onFrame);
    _state.add(TransportState.connected);
  }

  void _onFrame(List<int> data) {
    if (data.isEmpty) return;
    final frame = BridgeFrame.decode(Uint8List.fromList(data));
    if (frame.channel == 1) {
      _packets.add(_codec.decode(frame.payload));
    } else if (frame.channel == 2 && frame.payload.length >= 8) {
      _diagnostics.add(
        TransportDiagnostics(
          state: TransportState.connected,
          rssi: frame.payload[0].toSigned(8),
          snr: frame.payload[1].toSigned(8).toDouble(),
          batteryPercent: frame.payload[2] / 100,
          queueDepth: frame.payload[3],
          lastSeen: DateTime.now(),
          firmwareVersion: 'esp32',
        ),
      );
    }
  }

  @override
  Future<void> disconnect() async {
    await _rxSubscription?.cancel();
    await _device?.disconnect();
    _device = null;
    _tx = null;
    _rx = null;
    _state.add(TransportState.disconnected);
  }

  @override
  Future<void> send(MeshPacket packet) async {
    final tx = _tx;
    if (tx == null) {
      throw StateError('BLE bridge is not connected');
    }
    final bytes = BridgeFrame(
      channel: 1,
      payload: _codec.encode(packet),
    ).encode();
    const mtuSafeChunk = 180;
    for (var offset = 0; offset < bytes.length; offset += mtuSafeChunk) {
      final end = (offset + mtuSafeChunk).clamp(0, bytes.length);
      await tx.write(bytes.sublist(offset, end), withoutResponse: false);
    }
  }
}
