class MeshLink {
  const MeshLink({
    required this.from,
    required this.to,
    required this.rssi,
    required this.snr,
    required this.latencyMs,
    required this.packetLoss,
    required this.updatedAt,
  });

  final String from;
  final String to;
  final int rssi;
  final double snr;
  final int latencyMs;
  final double packetLoss;
  final DateTime updatedAt;

  double get cost {
    final signalPenalty = ((-rssi - 40) / 90).clamp(0.0, 1.0);
    final snrPenalty = (1 - ((snr + 20) / 35).clamp(0.0, 1.0));
    final latencyPenalty = (latencyMs / 5000).clamp(0.0, 1.0);
    final lossPenalty = packetLoss.clamp(0.0, 1.0);
    return 1 +
        signalPenalty * 4 +
        snrPenalty * 2 +
        latencyPenalty * 2 +
        lossPenalty * 6;
  }

  bool isExpired(DateTime now, Duration ttl) => now.difference(updatedAt) > ttl;
}

class MeshRoute {
  const MeshRoute({
    required this.destination,
    required this.hops,
    required this.cost,
    required this.computedAt,
  });

  final String destination;
  final List<String> hops;
  final double cost;
  final DateTime computedAt;

  String? get nextHop => hops.length > 1 ? hops[1] : null;
  int get hopCount => hops.length <= 1 ? 0 : hops.length - 1;
  bool get isReachable => hops.isNotEmpty;
}
