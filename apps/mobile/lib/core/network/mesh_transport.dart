import 'dart:async';
import 'dart:typed_data';

import '../protocol/packet.dart';

enum TransportState { disconnected, scanning, connecting, connected, degraded }

class TransportDiagnostics {
  const TransportDiagnostics({
    required this.state,
    required this.rssi,
    required this.snr,
    required this.batteryPercent,
    required this.queueDepth,
    required this.lastSeen,
    this.firmwareVersion = 'unknown',
  });

  final TransportState state;
  final int rssi;
  final double snr;
  final double batteryPercent;
  final int queueDepth;
  final DateTime lastSeen;
  final String firmwareVersion;
}

abstract class MeshTransport {
  Stream<TransportState> get state;
  Stream<MeshPacket> get packets;
  Stream<TransportDiagnostics> get diagnostics;

  Future<void> scan();
  Future<void> connect(String deviceId);
  Future<void> disconnect();
  Future<void> send(MeshPacket packet);
}

class BridgeFrame {
  const BridgeFrame({required this.channel, required this.payload});

  final int channel;
  final Uint8List payload;

  Uint8List encode() {
    final length = payload.length;
    return Uint8List.fromList([
      0x4d,
      0x42,
      channel,
      (length >> 8) & 0xff,
      length & 0xff,
      ...payload,
    ]);
  }

  static BridgeFrame decode(Uint8List bytes) {
    if (bytes.length < 5 || bytes[0] != 0x4d || bytes[1] != 0x42) {
      throw FormatException('invalid bridge frame');
    }
    final length = (bytes[3] << 8) | bytes[4];
    if (length != bytes.length - 5) {
      throw FormatException('bridge frame length mismatch');
    }
    return BridgeFrame(
      channel: bytes[2],
      payload: Uint8List.sublistView(bytes, 5),
    );
  }
}
