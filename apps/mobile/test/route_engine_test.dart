import 'package:meshwave/core/routing/mesh_node.dart';
import 'package:meshwave/core/routing/route.dart';
import 'package:meshwave/core/routing/route_engine.dart';
import 'package:test/test.dart';

void main() {
  test('route engine selects the lowest cost multi-hop path', () {
    final now = DateTime.utc(2026, 1, 1);
    final routes = RouteEngine();
    for (final id in ['a', 'b', 'c', 'd']) {
      routes.upsertNode(
        MeshNode(id: id, callsign: id.toUpperCase(), lastSeen: now),
      );
    }
    routes.observeLink(
      MeshLink(
        from: 'a',
        to: 'b',
        rssi: -70,
        snr: 8,
        latencyMs: 200,
        packetLoss: 0.01,
        updatedAt: now,
      ),
    );
    routes.observeLink(
      MeshLink(
        from: 'b',
        to: 'd',
        rssi: -76,
        snr: 6,
        latencyMs: 300,
        packetLoss: 0.02,
        updatedAt: now,
      ),
    );
    routes.observeLink(
      MeshLink(
        from: 'a',
        to: 'c',
        rssi: -105,
        snr: -3,
        latencyMs: 1500,
        packetLoss: 0.2,
        updatedAt: now,
      ),
    );
    routes.observeLink(
      MeshLink(
        from: 'c',
        to: 'd',
        rssi: -106,
        snr: -4,
        latencyMs: 1600,
        packetLoss: 0.2,
        updatedAt: now,
      ),
    );

    final route = routes.route(source: 'a', destination: 'd', now: now);

    expect(route.hops, ['a', 'b', 'd']);
    expect(route.nextHop, 'b');
  });
}
