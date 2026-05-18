import '../entities/message.dart';

abstract class MessageRepository {
  Stream<List<Conversation>> getConversations(String uid);
  Stream<List<Message>> getMessages(String conversationId);
  Future<void> sendMessage({
    required String conversationId,
    required Message message,
  });
  Future<void> markAsRead(String conversationId, String currentUid);
}
