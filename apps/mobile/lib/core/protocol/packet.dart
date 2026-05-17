import 'dart:typed_data';

enum PacketKind {
  data(1),
  ack(2),
  nack(3),
  heartbeat(4),
  routeAdvert(5),
  emergency(6),
  diagnostics(7),
  pairing(8);

  const PacketKind(this.wireValue);
  final int wireValue;

  static PacketKind fromWire(int value) {
    return PacketKind.values.firstWhere(
      (kind) => kind.wireValue == value,
      orElse: () => PacketKind.data,
    );
  }
}

enum PacketPriority {
  background(0),
  normal(1),
  high(2),
  emergency(3);

  const PacketPriority(this.wireValue);
  final int wireValue;

  static PacketPriority fromWire(int value) {
    return PacketPriority.values.firstWhere(
      (priority) => priority.wireValue == value,
      orElse: () => PacketPriority.normal,
    );
  }
}

class PacketFlags {
  const PacketFlags({
    this.requiresAck = true,
    this.isEncrypted = true,
    this.isFragmented = false,
    this.isBroadcast = false,
  });

  final bool requiresAck;
  final bool isEncrypted;
  final bool isFragmented;
  final bool isBroadcast;

  int toWire() {
    var value = 0;
    if (requiresAck) value |= 1 << 0;
    if (isEncrypted) value |= 1 << 1;
    if (isFragmented) value |= 1 << 2;
    if (isBroadcast) value |= 1 << 3;
    return value;
  }

  static PacketFlags fromWire(int value) {
    return PacketFlags(
      requiresAck: value & (1 << 0) != 0,
      isEncrypted: value & (1 << 1) != 0,
      isFragmented: value & (1 << 2) != 0,
      isBroadcast: value & (1 << 3) != 0,
    );
  }
}

class PacketHeader {
  const PacketHeader({
    required this.kind,
    required this.flags,
    required this.priority,
    required this.source,
    required this.destination,
    required this.sequence,
    required this.createdAtMillis,
    this.previousHop = '',
    this.nextHop = '',
    this.ttl = 12,
    this.hopCount = 0,
    this.fragmentIndex = 0,
    this.fragmentCount = 1,
  });

  final PacketKind kind;
  final PacketFlags flags;
  final PacketPriority priority;
  final String source;
  final String destination;
  final String previousHop;
  final String nextHop;
  final int sequence;
  final int createdAtMillis;
  final int ttl;
  final int hopCount;
  final int fragmentIndex;
  final int fragmentCount;

  bool get isExpired => ttl <= 0;
  bool get isFragment => fragmentCount > 1 || flags.isFragmented;
  String get dedupeKey => '$source:$sequence:$fragmentIndex';

  PacketHeader forwardedThrough(String nodeId, String next) {
    return PacketHeader(
      kind: kind,
      flags: flags,
      priority: priority,
      source: source,
      destination: destination,
      previousHop: nodeId,
      nextHop: next,
      sequence: sequence,
      createdAtMillis: createdAtMillis,
      ttl: ttl - 1,
      hopCount: hopCount + 1,
      fragmentIndex: fragmentIndex,
      fragmentCount: fragmentCount,
    );
  }
}

class MeshPacket {
  const MeshPacket({required this.header, required this.payload, this.crc = 0});

  final PacketHeader header;
  final Uint8List payload;
  final int crc;

  String get dedupeKey => header.dedupeKey;

  MeshPacket withCrc(int value) =>
      MeshPacket(header: header, payload: payload, crc: value);

  MeshPacket forwardedThrough(String nodeId, String nextHop) {
    return MeshPacket(
      header: header.forwardedThrough(nodeId, nextHop),
      payload: payload,
      crc: 0,
    );
  }
}

class PacketRejectedException implements Exception {
  PacketRejectedException(this.message);
  final String message;

  @override
  String toString() => 'PacketRejectedException: $message';
}
