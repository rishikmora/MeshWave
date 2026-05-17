import 'packet.dart';

class PendingTransmission {
  PendingTransmission({
    required this.packet,
    required this.firstSentAt,
    required this.nextRetryAt,
    this.attempts = 0,
  });

  final MeshPacket packet;
  final DateTime firstSentAt;
  DateTime nextRetryAt;
  int attempts;
}

class AckTracker {
  AckTracker({
    this.baseRetry = const Duration(seconds: 2),
    this.maxAttempts = 5,
  });

  final Duration baseRetry;
  final int maxAttempts;
  final Map<String, PendingTransmission> _pending = {};

  Iterable<PendingTransmission> get pending => _pending.values;

  void track(MeshPacket packet, DateTime now) {
    if (!packet.header.flags.requiresAck) return;
    _pending[packet.header.dedupeKey] = PendingTransmission(
      packet: packet,
      firstSentAt: now,
      nextRetryAt: now.add(baseRetry),
    );
  }

  void ack(String source, int sequence, {int fragmentIndex = 0}) {
    _pending.remove('$source:$sequence:$fragmentIndex');
  }

  List<MeshPacket> dueForRetry(DateTime now) {
    final retries = <MeshPacket>[];
    final expired = <String>[];
    for (final entry in _pending.entries) {
      final pending = entry.value;
      if (now.isBefore(pending.nextRetryAt)) continue;
      if (pending.attempts >= maxAttempts) {
        expired.add(entry.key);
        continue;
      }
      pending.attempts += 1;
      final backoff = baseRetry * (1 << pending.attempts).clamp(1, 16);
      pending.nextRetryAt = now.add(backoff);
      retries.add(pending.packet);
    }
    for (final key in expired) {
      _pending.remove(key);
    }
    return retries;
  }
}
