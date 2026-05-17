import 'dart:async';
import 'dart:math';

import '../protocol/packet.dart';
import 'mesh_transport.dart';

class SimulatedMeshTransport implements MeshTransport {
  SimulatedMeshTransport({Random? random}) : _random = random ?? Random(42);

  final Random _random;
  final _state = StreamController<TransportState>.broadcast();
  final _packets = StreamController<MeshPacket>.broadcast();
  final _diagnostics = StreamController<TransportDiagnostics>.broadcast();
  Timer? _timer;

  @override
  Stream<TransportState> get state => _state.stream;

  @override
  Stream<MeshPacket> get packets => _packets.stream;

  @override
  Stream<TransportDiagnostics> get diagnostics => _diagnostics.stream;

  @override
  Future<void> scan() async {
    _state.add(TransportState.scanning);
    await Future<void>.delayed(const Duration(milliseconds: 450));
    _state.add(TransportState.disconnected);
  }

  @override
  Future<void> connect(String deviceId) async {
    _state.add(TransportState.connecting);
    await Future<void>.delayed(const Duration(milliseconds: 650));
    _state.add(TransportState.connected);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      _diagnostics.add(
        TransportDiagnostics(
          state: TransportState.connected,
          rssi: -92 + _random.nextInt(22),
          snr: -4 + _random.nextDouble() * 12,
          batteryPercent: 0.56 + _random.nextDouble() * 0.35,
          queueDepth: _random.nextInt(7),
          lastSeen: DateTime.now(),
          firmwareVersion: 'mw-fw-0.1.0',
        ),
      );
    });
  }

  @override
  Future<void> disconnect() async {
    _timer?.cancel();
    _state.add(TransportState.disconnected);
  }

  @override
  Future<void> send(MeshPacket packet) async {
    await Future<void>.delayed(
      Duration(milliseconds: 80 + _random.nextInt(200)),
    );
    if (packet.header.flags.requiresAck) {
      _packets.add(
        MeshPacket(
          header: PacketHeader(
            kind: PacketKind.ack,
            flags: const PacketFlags(requiresAck: false, isEncrypted: false),
            priority: packet.header.priority,
            source: packet.header.destination,
            destination: packet.header.source,
            sequence: packet.header.sequence,
            createdAtMillis: DateTime.now().millisecondsSinceEpoch,
            ttl: 4,
          ),
          payload: packet.payload,
        ),
      );
    }
  }
}
