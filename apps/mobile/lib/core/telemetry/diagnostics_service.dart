import '../database/local_store.dart';
import '../database/models.dart';
import '../network/mesh_transport.dart';
import '../routing/mesh_node.dart';
import '../routing/route_engine.dart';

class DiagnosticsService {
  DiagnosticsService({
    required this.store,
    required this.routes,
    required this.localNodeId,
  });

  final LocalStore store;
  final RouteEngine routes;
  final String localNodeId;

  Future<void> ingest(String nodeId, TransportDiagnostics diagnostics) async {
    final sample = DiagnosticSample(
      id: '$nodeId-${diagnostics.lastSeen.microsecondsSinceEpoch}',
      nodeId: nodeId,
      recordedAt: diagnostics.lastSeen,
      rssi: diagnostics.rssi,
      snr: diagnostics.snr,
      batteryPercent: diagnostics.batteryPercent,
      queueDepth: diagnostics.queueDepth,
      deliveryRatio:
          diagnostics.state == TransportState.connected ? 0.96 : 0.42,
    );
    await store.saveDiagnostic(sample);
    final node = MeshNode(
      id: nodeId,
      callsign: nodeId,
      lastSeen: diagnostics.lastSeen,
      roles: const {NodeRole.relay, NodeRole.gateway},
      rssi: diagnostics.rssi,
      snr: diagnostics.snr,
      batteryPercent: diagnostics.batteryPercent,
      firmwareVersion: diagnostics.firmwareVersion,
    );
    routes.upsertNode(node);
    await store.saveNode(node);
  }
}
