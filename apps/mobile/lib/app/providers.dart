import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../core/database/hive_local_store.dart';
import '../core/database/local_store.dart';
import '../core/database/models.dart';
import '../core/network/mesh_transport.dart';
import '../core/network/offline_sync_service.dart';
import '../core/network/simulated_mesh_transport.dart';
import '../core/routing/mesh_node.dart';
import '../core/routing/route.dart';
import '../core/routing/route_engine.dart';
import '../core/telemetry/diagnostics_service.dart';

const localNodeId = 'mw-field-ops';
const localCallsign = 'FIELD-OPS';

final themeModeProvider = StateProvider<ThemeMode>((_) => ThemeMode.dark);

final localStoreProvider = Provider<LocalStore>((ref) {
  return HiveLocalStore();
});

final routeEngineProvider = Provider<RouteEngine>((ref) {
  return RouteEngine();
});

final transportProvider = Provider<MeshTransport>((ref) {
  final transport = SimulatedMeshTransport();
  ref.onDispose(transport.disconnect);
  return transport;
});

final syncServiceProvider = Provider<OfflineSyncService>((ref) {
  return OfflineSyncService(
    store: ref.watch(localStoreProvider),
    transport: ref.watch(transportProvider),
  );
});

final meshRuntimeProvider =
    StateNotifierProvider<MeshRuntimeController, MeshRuntimeState>((ref) {
  return MeshRuntimeController(
    store: ref.watch(localStoreProvider),
    routes: ref.watch(routeEngineProvider),
    transport: ref.watch(transportProvider),
  );
});

final chatControllerProvider = StateNotifierProvider.family<ChatController,
    AsyncValue<List<StoredMessage>>, String>((ref, id) {
  return ChatController(
    conversationId: id,
    store: ref.watch(localStoreProvider),
    sync: ref.watch(syncServiceProvider),
  );
});

final conversationsProvider = FutureProvider<List<Conversation>>((ref) async {
  return ref.watch(localStoreProvider).conversations();
});

class MeshRuntimeState {
  const MeshRuntimeState({
    required this.nodes,
    required this.transportState,
    required this.linkQuality,
    required this.rssi,
    required this.snr,
    required this.battery,
    required this.queueDepth,
    required this.lastUpdated,
  });

  factory MeshRuntimeState.initial() => MeshRuntimeState(
        nodes: const [],
        transportState: TransportState.disconnected,
        linkQuality: 0,
        rssi: -120,
        snr: 0,
        battery: 0,
        queueDepth: 0,
        lastUpdated: DateTime.now(),
      );

  final List<MeshNode> nodes;
  final TransportState transportState;
  final double linkQuality;
  final int rssi;
  final double snr;
  final double battery;
  final int queueDepth;
  final DateTime lastUpdated;

  MeshRuntimeState copyWith({
    List<MeshNode>? nodes,
    TransportState? transportState,
    double? linkQuality,
    int? rssi,
    double? snr,
    double? battery,
    int? queueDepth,
    DateTime? lastUpdated,
  }) {
    return MeshRuntimeState(
      nodes: nodes ?? this.nodes,
      transportState: transportState ?? this.transportState,
      linkQuality: linkQuality ?? this.linkQuality,
      rssi: rssi ?? this.rssi,
      snr: snr ?? this.snr,
      battery: battery ?? this.battery,
      queueDepth: queueDepth ?? this.queueDepth,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class MeshRuntimeController extends StateNotifier<MeshRuntimeState> {
  MeshRuntimeController({
    required LocalStore store,
    required RouteEngine routes,
    required MeshTransport transport,
  })  : _store = store,
        _routes = routes,
        _transport = transport,
        _diagnostics = DiagnosticsService(
          store: store,
          routes: routes,
          localNodeId: localNodeId,
        ),
        super(MeshRuntimeState.initial()) {
    _boot();
  }

  final LocalStore _store;
  final RouteEngine _routes;
  final MeshTransport _transport;
  final DiagnosticsService _diagnostics;
  final _subscriptions = <StreamSubscription<dynamic>>[];

  Future<void> _boot() async {
    await seedFieldTopology(_store, _routes);
    state = state.copyWith(
      nodes: _routes.nodes,
      linkQuality: _averageQuality(_routes.nodes),
    );
    _subscriptions.add(
      _transport.state.listen((transportState) {
        state = state.copyWith(transportState: transportState);
      }),
    );
    _subscriptions.add(
      _transport.diagnostics.listen((sample) async {
        await _diagnostics.ingest('relay-alpha', sample);
        state = state.copyWith(
          nodes: _routes.nodes,
          linkQuality: _averageQuality(_routes.nodes),
          rssi: sample.rssi,
          snr: sample.snr,
          battery: sample.batteryPercent,
          queueDepth: sample.queueDepth,
          lastUpdated: sample.lastSeen,
        );
      }),
    );
    await _transport.connect('MeshWave Field Relay');
  }

  Future<void> rescan() => _transport.scan();

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }
}

class ChatController extends StateNotifier<AsyncValue<List<StoredMessage>>> {
  ChatController({
    required this.conversationId,
    required LocalStore store,
    required OfflineSyncService sync,
  })  : _store = store,
        _sync = sync,
        super(const AsyncValue.loading()) {
    refresh();
  }

  final String conversationId;
  final LocalStore _store;
  final OfflineSyncService _sync;
  final _uuid = const Uuid();

  Future<void> refresh() async {
    state = AsyncValue.data(
      await _store.messagesForConversation(conversationId),
    );
  }

  Future<void> send(String body, {bool emergency = false}) async {
    final message = StoredMessage(
      id: _uuid.v4(),
      conversationId: conversationId,
      senderId: localNodeId,
      recipientId: conversationId == 'emergency' ? 'broadcast' : 'relay-alpha',
      body: body,
      createdAt: DateTime.now().toUtc(),
      state: MessageState.queued,
      priority: emergency ? 'emergency' : 'normal',
      sequence: DateTime.now().millisecondsSinceEpoch & 0xffffffff,
    );
    await _sync.enqueueText(
      message: message,
      localNodeId: localNodeId,
      destinationNodeId: message.recipientId,
    );
    await refresh();
  }
}

Future<void> seedFieldTopology(LocalStore store, RouteEngine routes) async {
  final now = DateTime.now().toUtc();
  final nodes = [
    MeshNode(
      id: localNodeId,
      callsign: localCallsign,
      lastSeen: now,
      roles: const {NodeRole.phone, NodeRole.gateway},
      rssi: -64,
      snr: 9.2,
      batteryPercent: 0.91,
      firmwareVersion: 'mobile',
    ),
    MeshNode(
      id: 'relay-alpha',
      callsign: 'ALPHA',
      lastSeen: now.subtract(const Duration(seconds: 14)),
      roles: const {NodeRole.relay, NodeRole.gateway},
      rssi: -78,
      snr: 6.5,
      batteryPercent: 0.78,
      firmwareVersion: 'mw-fw-0.1.0',
    ),
    MeshNode(
      id: 'ridge-link',
      callsign: 'RIDGE',
      lastSeen: now.subtract(const Duration(seconds: 28)),
      roles: const {NodeRole.relay},
      rssi: -91,
      snr: 2.9,
      batteryPercent: 0.63,
      firmwareVersion: 'mw-fw-0.1.0',
    ),
    MeshNode(
      id: 'sos-beacon-7',
      callsign: 'SOS-7',
      lastSeen: now.subtract(const Duration(minutes: 2)),
      roles: const {NodeRole.emergency, NodeRole.relay},
      rssi: -102,
      snr: -1.2,
      batteryPercent: 0.44,
      firmwareVersion: 'mw-fw-0.1.0',
    ),
  ];
  for (final node in nodes) {
    routes.upsertNode(node);
    await store.saveNode(node);
  }
  routes
    ..observeLink(
      MeshLink(
        from: localNodeId,
        to: 'relay-alpha',
        rssi: -78,
        snr: 6.5,
        latencyMs: 420,
        packetLoss: 0.03,
        updatedAt: now,
      ),
    )
    ..observeLink(
      MeshLink(
        from: 'relay-alpha',
        to: 'ridge-link',
        rssi: -88,
        snr: 4.1,
        latencyMs: 880,
        packetLoss: 0.07,
        updatedAt: now,
      ),
    )
    ..observeLink(
      MeshLink(
        from: 'ridge-link',
        to: 'sos-beacon-7',
        rssi: -101,
        snr: -0.8,
        latencyMs: 1320,
        packetLoss: 0.11,
        updatedAt: now,
      ),
    );

  final existing = await store.conversations();
  if (existing.isNotEmpty) return;
  await store.saveConversation(
    Conversation(
      id: 'field-ops',
      title: 'Field Operations',
      participantIds: const [localNodeId, 'relay-alpha', 'ridge-link'],
      updatedAt: now,
    ),
  );
  await store.saveConversation(
    Conversation(
      id: 'emergency',
      title: 'Emergency Broadcast',
      participantIds: const [localNodeId, 'broadcast'],
      updatedAt: now,
      isEmergency: true,
    ),
  );
  await store.saveMessage(
    StoredMessage(
      id: 'seed-1',
      conversationId: 'field-ops',
      senderId: 'relay-alpha',
      recipientId: localNodeId,
      body: 'Relay ALPHA online. Route through RIDGE is stable.',
      createdAt: now.subtract(const Duration(minutes: 4)),
      state: MessageState.delivered,
      sequence: 1001,
      hopCount: 1,
    ),
  );
}

double _averageQuality(List<MeshNode> nodes) {
  if (nodes.isEmpty) return 0;
  return nodes.map((node) => node.linkQuality).reduce((a, b) => a + b) /
      nodes.length;
}
