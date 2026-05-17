class ReplayGuard {
  ReplayGuard({this.windowSize = 512});

  final int windowSize;
  final Map<String, int> _highestSequenceByPeer = {};
  final Map<String, Set<int>> _recentByPeer = {};

  bool accept(String peerId, int sequence) {
    final highest = _highestSequenceByPeer[peerId] ?? -1;
    final recent = _recentByPeer.putIfAbsent(peerId, () => <int>{});
    if (recent.contains(sequence)) {
      return false;
    }
    if (highest - sequence > windowSize) {
      return false;
    }
    recent.add(sequence);
    if (sequence > highest) {
      _highestSequenceByPeer[peerId] = sequence;
    }
    if (recent.length > windowSize) {
      final ordered = recent.toList()..sort();
      recent
        ..clear()
        ..addAll(ordered.skip(ordered.length - windowSize));
    }
    return true;
  }
}
