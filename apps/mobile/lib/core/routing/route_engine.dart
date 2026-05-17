import 'dart:math';

import 'mesh_node.dart';
import 'route.dart';

class RouteEngine {
  RouteEngine({
    this.routeTtl = const Duration(minutes: 4),
    this.linkTtl = const Duration(minutes: 8),
  });

  final Duration routeTtl;
  final Duration linkTtl;
  final Map<String, MeshNode> _nodes = {};
  final Map<String, Map<String, MeshLink>> _links = {};
  final Map<String, MeshRoute> _routeCache = {};

  List<MeshNode> get nodes => _nodes.values.toList()
    ..sort((a, b) => b.linkQuality.compareTo(a.linkQuality));

  List<MeshLink> get links => [
        for (final edges in _links.values) ...edges.values,
      ];

  void upsertNode(MeshNode node) {
    _nodes[node.id] = node;
    _routeCache.clear();
  }

  void heartbeat({
    required String nodeId,
    required String callsign,
    required DateTime now,
    required int rssi,
    required double snr,
    required double battery,
    Set<NodeRole> roles = const {NodeRole.relay},
    String firmwareVersion = 'unknown',
  }) {
    upsertNode(
      MeshNode(
        id: nodeId,
        callsign: callsign,
        lastSeen: now,
        roles: roles,
        rssi: rssi,
        snr: snr,
        batteryPercent: battery,
        firmwareVersion: firmwareVersion,
      ),
    );
  }

  void observeLink(MeshLink link) {
    _links.putIfAbsent(link.from, () => {})[link.to] = link;
    _links.putIfAbsent(link.to, () => {})[link.from] = MeshLink(
      from: link.to,
      to: link.from,
      rssi: link.rssi,
      snr: link.snr,
      latencyMs: link.latencyMs,
      packetLoss: link.packetLoss,
      updatedAt: link.updatedAt,
    );
    _routeCache.clear();
  }

  MeshRoute route({
    required String source,
    required String destination,
    required DateTime now,
  }) {
    _sweep(now);
    final cacheKey = '$source->$destination';
    final cached = _routeCache[cacheKey];
    if (cached != null && now.difference(cached.computedAt) <= routeTtl) {
      return cached;
    }

    final route = _dijkstra(source, destination, now);
    _routeCache[cacheKey] = route;
    return route;
  }

  String? selectNextHop({
    required String source,
    required String destination,
    required DateTime now,
  }) {
    return route(source: source, destination: destination, now: now).nextHop;
  }

  List<MeshNode> rankedRelays(String source, DateTime now) {
    _sweep(now);
    final neighbors =
        _links[source]?.values ?? const Iterable<MeshLink>.empty();
    final relayIds = neighbors.map((link) => link.to).toSet();
    final relays = _nodes.values
        .where(
          (node) =>
              relayIds.contains(node.id) &&
              node.canRelay &&
              now.difference(node.lastSeen) <= linkTtl,
        )
        .toList();
    relays.sort(
      (a, b) => _relayScore(source, b).compareTo(_relayScore(source, a)),
    );
    return relays;
  }

  double _relayScore(String source, MeshNode node) {
    final link = _links[source]?[node.id];
    final linkScore = link == null ? 0.0 : 1 / link.cost;
    final freshness =
        1 / max(1, DateTime.now().difference(node.lastSeen).inSeconds);
    return node.linkQuality * 0.65 + linkScore * 0.30 + freshness * 0.05;
  }

  MeshRoute _dijkstra(String source, String destination, DateTime now) {
    if (!_nodes.containsKey(source) && !_links.containsKey(source)) {
      return MeshRoute(
        destination: destination,
        hops: const [],
        cost: double.infinity,
        computedAt: now,
      );
    }

    final distances = <String, double>{source: 0};
    final previous = <String, String>{};
    final visited = <String>{};
    final queue = PriorityQueue<_RouteCandidate>();
    queue.add(_RouteCandidate(source, 0));

    while (queue.isNotEmpty) {
      final current = queue.removeFirst();
      if (!visited.add(current.nodeId)) continue;
      if (current.nodeId == destination) break;

      final edges =
          _links[current.nodeId]?.values ?? const Iterable<MeshLink>.empty();
      for (final edge in edges) {
        if (edge.isExpired(now, linkTtl)) continue;
        final node = _nodes[edge.to];
        if (node != null &&
            (!node.online || now.difference(node.lastSeen) > linkTtl)) {
          continue;
        }
        final candidateDistance = current.cost + edge.cost;
        if (candidateDistance < (distances[edge.to] ?? double.infinity)) {
          distances[edge.to] = candidateDistance;
          previous[edge.to] = current.nodeId;
          queue.add(_RouteCandidate(edge.to, candidateDistance));
        }
      }
    }

    if (!distances.containsKey(destination)) {
      return MeshRoute(
        destination: destination,
        hops: const [],
        cost: double.infinity,
        computedAt: now,
      );
    }

    final hops = <String>[destination];
    var cursor = destination;
    while (previous.containsKey(cursor)) {
      cursor = previous[cursor]!;
      hops.insert(0, cursor);
    }
    return MeshRoute(
      destination: destination,
      hops: hops,
      cost: distances[destination]!,
      computedAt: now,
    );
  }

  void _sweep(DateTime now) {
    for (final entry in _links.entries) {
      entry.value.removeWhere((_, link) => link.isExpired(now, linkTtl));
    }
    _links.removeWhere((_, edges) => edges.isEmpty);
    _routeCache.removeWhere(
      (_, route) => now.difference(route.computedAt) > routeTtl,
    );
  }
}

class _RouteCandidate implements Comparable<_RouteCandidate> {
  const _RouteCandidate(this.nodeId, this.cost);

  final String nodeId;
  final double cost;

  @override
  int compareTo(_RouteCandidate other) => cost.compareTo(other.cost);
}

class PriorityQueue<E extends Comparable<E>> {
  final List<E> _items = [];

  bool get isNotEmpty => _items.isNotEmpty;

  void add(E item) {
    _items.add(item);
    _items.sort();
  }

  E removeFirst() => _items.removeAt(0);
}
