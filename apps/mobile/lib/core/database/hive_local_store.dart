import 'package:hive_flutter/hive_flutter.dart';

import '../routing/mesh_node.dart';
import 'local_store.dart';
import 'models.dart';

class HiveLocalStore implements LocalStore {
  static const _conversations = 'conversations';
  static const _messages = 'messages';
  static const _nodes = 'nodes';
  static const _diagnostics = 'diagnostics';

  late Box _conversationBox;
  late Box _messageBox;
  late Box _nodeBox;
  late Box _diagnosticBox;

  @override
  Future<void> open() async {
    await Hive.initFlutter();
    _conversationBox = await Hive.openBox(_conversations);
    _messageBox = await Hive.openBox(_messages);
    _nodeBox = await Hive.openBox(_nodes);
    _diagnosticBox = await Hive.openBox(_diagnostics);
  }

  @override
  Future<void> close() async {
    await Hive.close();
  }

  @override
  Future<void> saveConversation(Conversation conversation) async {
    await _conversationBox.put(conversation.id, conversation.toJson());
  }

  @override
  Future<List<Conversation>> conversations() async {
    final items = _conversationBox.values
        .map(
          (item) =>
              Conversation.fromJson(Map<dynamic, dynamic>.from(item as Map)),
        )
        .toList();
    items.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return items;
  }

  @override
  Future<void> saveMessage(StoredMessage message) async {
    await _messageBox.put(message.id, message.toJson());
  }

  @override
  Future<List<StoredMessage>> messagesForConversation(
    String conversationId,
  ) async {
    final items = _messageBox.values
        .map(
          (item) =>
              StoredMessage.fromJson(Map<dynamic, dynamic>.from(item as Map)),
        )
        .where((message) => message.conversationId == conversationId)
        .toList();
    items.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return items;
  }

  @override
  Future<List<StoredMessage>> queuedMessages() async {
    return _messageBox.values
        .map(
          (item) =>
              StoredMessage.fromJson(Map<dynamic, dynamic>.from(item as Map)),
        )
        .where((message) => message.state == MessageState.queued)
        .toList();
  }

  @override
  Future<void> updateMessageState(String id, MessageState state) async {
    final raw = _messageBox.get(id);
    if (raw == null) return;
    final message = StoredMessage.fromJson(
      Map<dynamic, dynamic>.from(raw as Map),
    );
    await saveMessage(message.copyWith(state: state));
  }

  @override
  Future<void> saveNode(MeshNode node) async {
    await _nodeBox.put(node.id, node.toJson());
  }

  @override
  Future<List<MeshNode>> nodes() async {
    return _nodeBox.values
        .map(
          (item) => MeshNode.fromJson(Map<dynamic, dynamic>.from(item as Map)),
        )
        .toList();
  }

  @override
  Future<void> saveDiagnostic(DiagnosticSample sample) async {
    await _diagnosticBox.put(sample.id, sample.toJson());
  }

  @override
  Future<List<DiagnosticSample>> diagnosticsForNode(
    String nodeId, {
    int limit = 120,
  }) async {
    final items = _diagnosticBox.values
        .map(
          (item) => DiagnosticSample.fromJson(
            Map<dynamic, dynamic>.from(item as Map),
          ),
        )
        .where((sample) => sample.nodeId == nodeId)
        .toList();
    items.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    return items.take(limit).toList();
  }
}
