import 'dart:typed_data';

import 'packet.dart';
import 'packet_codec.dart';

class PacketFragmenter {
  const PacketFragmenter({this.maxPayloadBytes = PacketCodec.maxPayloadBytes});

  final int maxPayloadBytes;

  List<MeshPacket> fragment({
    required PacketHeader baseHeader,
    required Uint8List payload,
  }) {
    if (payload.length <= maxPayloadBytes) {
      return [MeshPacket(header: baseHeader, payload: payload)];
    }

    final count = (payload.length / maxPayloadBytes).ceil();
    return List.generate(count, (index) {
      final start = index * maxPayloadBytes;
      final end = (start + maxPayloadBytes).clamp(0, payload.length);
      return MeshPacket(
        header: PacketHeader(
          kind: baseHeader.kind,
          flags: PacketFlags(
            requiresAck: baseHeader.flags.requiresAck,
            isEncrypted: baseHeader.flags.isEncrypted,
            isFragmented: true,
            isBroadcast: baseHeader.flags.isBroadcast,
          ),
          priority: baseHeader.priority,
          source: baseHeader.source,
          destination: baseHeader.destination,
          previousHop: baseHeader.previousHop,
          nextHop: baseHeader.nextHop,
          sequence: baseHeader.sequence,
          createdAtMillis: baseHeader.createdAtMillis,
          ttl: baseHeader.ttl,
          hopCount: baseHeader.hopCount,
          fragmentIndex: index,
          fragmentCount: count,
        ),
        payload: Uint8List.sublistView(payload, start, end),
      );
    });
  }
}

class FragmentReassembler {
  final Map<String, _FragmentBucket> _buckets = {};

  Uint8List? add(MeshPacket packet) {
    if (!packet.header.isFragment) {
      return packet.payload;
    }

    final key =
        '${packet.header.source}:${packet.header.destination}:${packet.header.sequence}';
    final bucket = _buckets.putIfAbsent(
      key,
      () => _FragmentBucket(packet.header.fragmentCount),
    );
    bucket.add(packet.header.fragmentIndex, packet.payload);
    if (!bucket.isComplete) {
      return null;
    }
    _buckets.remove(key);
    return bucket.assemble();
  }

  void sweep(Duration maxAge, DateTime now) {
    _buckets.removeWhere(
      (_, bucket) => now.difference(bucket.createdAt) > maxAge,
    );
  }
}

class _FragmentBucket {
  _FragmentBucket(this.expectedCount);

  final int expectedCount;
  final DateTime createdAt = DateTime.now();
  final Map<int, Uint8List> parts = {};

  bool get isComplete => parts.length == expectedCount;

  void add(int index, Uint8List payload) {
    if (index < 0 || index >= expectedCount) return;
    parts[index] = Uint8List.fromList(payload);
  }

  Uint8List assemble() {
    final ordered = List.generate(expectedCount, (index) => parts[index]!);
    final length = ordered.fold<int>(0, (total, part) => total + part.length);
    final output = Uint8List(length);
    var offset = 0;
    for (final part in ordered) {
      output.setRange(offset, offset + part.length, part);
      offset += part.length;
    }
    return output;
  }
}
