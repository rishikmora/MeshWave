class PacketDedupeCache {
  PacketDedupeCache({
    this.maxEntries = 4096,
    this.ttl = const Duration(minutes: 15),
  });

  final int maxEntries;
  final Duration ttl;
  final Map<String, DateTime> _seen = {};

  bool accept(String key, DateTime now) {
    sweep(now);
    if (_seen.containsKey(key)) {
      return false;
    }
    _seen[key] = now;
    if (_seen.length > maxEntries) {
      final ordered = _seen.entries.toList()
        ..sort((a, b) => a.value.compareTo(b.value));
      for (final entry in ordered.take(_seen.length - maxEntries)) {
        _seen.remove(entry.key);
      }
    }
    return true;
  }

  void sweep(DateTime now) {
    _seen.removeWhere((_, timestamp) => now.difference(timestamp) > ttl);
  }
}
