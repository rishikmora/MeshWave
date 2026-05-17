import '../routing/mesh_node.dart';
import 'models.dart';

abstract class LocalStore {
  Future<void> open();
  Future<void> close();

  Future<void> saveConversation(Conversation conversation);
  Future<List<Conversation>> conversations();

  Future<void> saveMessage(StoredMessage message);
  Future<List<StoredMessage>> messagesForConversation(String conversationId);
  Future<List<StoredMessage>> queuedMessages();
  Future<void> updateMessageState(String id, MessageState state);

  Future<void> saveNode(MeshNode node);
  Future<List<MeshNode>> nodes();

  Future<void> saveDiagnostic(DiagnosticSample sample);
  Future<List<DiagnosticSample>> diagnosticsForNode(
    String nodeId, {
    int limit = 120,
  });
}
