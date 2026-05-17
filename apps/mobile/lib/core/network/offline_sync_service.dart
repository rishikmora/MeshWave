import 'dart:async';

import '../database/local_store.dart';
import '../database/models.dart';
import '../protocol/ack_tracker.dart';
import '../protocol/packet.dart';
import '../protocol/packet_codec.dart';
import '../protocol/payload_optimizer.dart';
import 'mesh_transport.dart';

class OfflineSyncService {
  OfflineSyncService({
    required this.store,
    required this.transport,
    PacketCodec? codec,
    PayloadOptimizer? optimizer,
    AckTracker? ackTracker,
  })  : codec = codec ?? const PacketCodec(),
        optimizer = optimizer ?? PayloadOptimizer(),
        ackTracker = ackTracker ?? AckTracker();

  final LocalStore store;
  final MeshTransport transport;
  final PacketCodec codec;
  final PayloadOptimizer optimizer;
  final AckTracker ackTracker;
  Timer? _retryTimer;

  void start() {
    _retryTimer?.cancel();
    _retryTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => flushQueued(),
    );
  }

  Future<void> stop() async {
    _retryTimer?.cancel();
  }

  Future<void> enqueueText({
    required StoredMessage message,
    required String localNodeId,
    required String destinationNodeId,
  }) async {
    await store.saveMessage(message);
    await flushQueued(
      localNodeId: localNodeId,
      destinationNodeId: destinationNodeId,
    );
  }

  Future<void> flushQueued({
    String localNodeId = 'local',
    String destinationNodeId = 'broadcast',
  }) async {
    final queued = await store.queuedMessages();
    for (final message in queued) {
      final payload = optimizer.compressText(message.body);
      final packet = MeshPacket(
        header: PacketHeader(
          kind: message.priority == 'emergency'
              ? PacketKind.emergency
              : PacketKind.data,
          flags: PacketFlags(isBroadcast: destinationNodeId == 'broadcast'),
          priority: message.priority == 'emergency'
              ? PacketPriority.emergency
              : PacketPriority.normal,
          source: localNodeId,
          destination: destinationNodeId,
          sequence: message.sequence,
          createdAtMillis: message.createdAt.millisecondsSinceEpoch,
          ttl: message.priority == 'emergency' ? 24 : 12,
        ),
        payload: payload,
      );
      await transport.send(packet);
      ackTracker.track(packet, DateTime.now());
      await store.updateMessageState(message.id, MessageState.sent);
    }
  }
}
