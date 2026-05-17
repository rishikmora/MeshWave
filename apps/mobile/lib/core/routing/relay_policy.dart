import '../protocol/packet.dart';
import 'mesh_node.dart';
import 'route_engine.dart';

class RelayDecision {
  const RelayDecision.forward(this.nextHop) : dropReason = null;
  const RelayDecision.drop(this.dropReason) : nextHop = null;

  final String? nextHop;
  final String? dropReason;
  bool get shouldForward => nextHop != null;
}

class RelayPolicy {
  const RelayPolicy({
    this.emergencyTtlFloor = 4,
    this.minimumBatteryForRelay = 0.12,
  });

  final int emergencyTtlFloor;
  final double minimumBatteryForRelay;

  RelayDecision decide({
    required MeshPacket packet,
    required String localNodeId,
    required MeshNode localNode,
    required RouteEngine routes,
    required DateTime now,
  }) {
    if (packet.header.destination == localNodeId) {
      return const RelayDecision.drop('packet reached destination');
    }
    if (packet.header.isExpired) {
      return const RelayDecision.drop('ttl exhausted');
    }
    if (localNode.batteryPercent < minimumBatteryForRelay &&
        packet.header.priority != PacketPriority.emergency) {
      return const RelayDecision.drop('battery reserve protected');
    }

    final ttl = packet.header.priority == PacketPriority.emergency
        ? packet.header.ttl.clamp(emergencyTtlFloor, 32)
        : packet.header.ttl;
    if (ttl <= 0) {
      return const RelayDecision.drop('ttl exhausted');
    }

    final nextHop = routes.selectNextHop(
      source: localNodeId,
      destination: packet.header.destination,
      now: now,
    );
    if (nextHop == null) {
      final relay = routes.rankedRelays(localNodeId, now).firstOrNull;
      if (relay == null) {
        return const RelayDecision.drop('no known relay');
      }
      return RelayDecision.forward(relay.id);
    }
    return RelayDecision.forward(nextHop);
  }
}

extension _FirstOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
