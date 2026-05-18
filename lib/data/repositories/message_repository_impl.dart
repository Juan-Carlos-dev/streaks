import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/message_repository.dart';

class MessageRepositoryImpl implements MessageRepository {
  final FirebaseFirestore _firestore;

  MessageRepositoryImpl(this._firestore);

  @override
  Stream<List<Conversation>> getConversations(String uid) {
    return _firestore
        .collection('conversations')
        .where('participants', arrayContains: uid)
        //.orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => Conversation.fromFirestore(doc, uid))
            .toList());
  }

@override
Stream<List<Message>> getMessages(String conversationId) {
  return _firestore
      .collection('conversations')
      .doc(conversationId)
      .collection('messages')
      .orderBy('timestamp', descending: false)
      .snapshots()
      .handleError((e) {
        // Si la conversación no existe aún, devolver lista vacía
        return [];
      })
      .map((snap) => snap.docs
          .map((doc) => Message.fromFirestore(doc))
          .toList());
}

  @override
  Future<void> sendMessage({
    required String conversationId,
    required Message message,
  }) async {
    final batch = _firestore.batch();

    // Add message to subcollection
    final msgRef = _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc();

    batch.set(msgRef, message.toFirestore());

    // Update conversation metadata
    final convRef = _firestore.collection('conversations').doc(conversationId);
    batch.set(convRef, {
      'participants': [message.senderId, message.receiverId],
      'lastMessage': message.text,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'unreadCount_${message.receiverId}': FieldValue.increment(1),
    }, SetOptions(merge: true));

    await batch.commit();
  }

  @override
  Future<void> markAsRead(String conversationId, String currentUid) async {
    await _firestore.collection('conversations').doc(conversationId).set(
      {'unreadCount_$currentUid': 0},
      SetOptions(merge: true),
    );
  }
}
