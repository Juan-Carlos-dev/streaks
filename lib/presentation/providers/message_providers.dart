import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/message_repository.dart';
import '../../data/repositories/message_repository_impl.dart';
import 'auth_providers.dart';

final messageRepositoryProvider = Provider<MessageRepository>((ref) {
  return MessageRepositoryImpl(FirebaseFirestore.instance);
});

final conversationsProvider = StreamProvider<List<Conversation>>((ref) {
  final uid = ref.watch(authStateProvider).value;
  if (uid == null) return Stream.value([]);
  return ref.watch(messageRepositoryProvider).getConversations(uid);
});

// Total unread messages count (for badge)
final totalUnreadProvider = Provider<int>((ref) {
  return ref.watch(conversationsProvider).when(
    data: (convs) => convs.fold(0, (sum, c) => sum + c.unreadCount),
    loading: () => 0,
    error: (_, __) => 0,
  );
});

final messagesProvider =
    StreamProvider.family<List<Message>, String>((ref, convId) {
  final uid = ref.watch(authStateProvider).value;
  if (uid == null) return Stream.value([]);
  return ref.watch(messageRepositoryProvider).getMessages(convId);
});

final sendMessageProvider = Provider((ref) {
  return (String convId, String text, String receiverId) async {
    final uid = ref.read(authStateProvider).value;
    if (uid == null || text.trim().isEmpty) return;

    final message = Message(
      id: const Uuid().v4(),
      senderId: uid,
      receiverId: receiverId,
      text: text.trim(),
      timestamp: DateTime.now(),
    );

    await ref
        .read(messageRepositoryProvider)
        .sendMessage(conversationId: convId, message: message);
  };
});

final markAsReadProvider = Provider((ref) {
  return (String convId) async {
    final uid = ref.read(authStateProvider).value;
    if (uid == null) return;
    await ref.read(messageRepositoryProvider).markAsRead(convId, uid);
  };
});
