import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/chat.dart';

/// Firestore-backed 1:1 chat between buyers and agents.
///   chats/{chatId}                       → Chat.toMap()
///   chats/{chatId}/messages/{messageId}  → ChatMessage.toMap()
class ChatRepository {
  ChatRepository([FirebaseFirestore? db])
      : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _chats =>
      _db.collection('chats');

  /// Live list of a user's chats, most recent first.
  Stream<List<Chat>> watchChats(String uid) {
    return _chats
        .where('participants', arrayContains: uid)
        .snapshots()
        .map((snap) {
      final list = snap.docs.map((d) => Chat.fromMap(d.data())).toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return list;
    });
  }

  Stream<List<ChatMessage>> watchMessages(String chatId) {
    return _chats
        .doc(chatId)
        .collection('messages')
        .snapshots()
        .map((snap) {
      final list = snap.docs.map((d) => ChatMessage.fromMap(d.data())).toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return list;
    });
  }

  Future<Chat> getOrCreate(Chat chat) async {
    final ref = _chats.doc(chat.id);
    try {
      final doc = await ref.get();
      if (doc.exists) return Chat.fromMap(doc.data()!);
    } catch (_) {
      // Reading a not-yet-existent chat can be denied by rules; fall through
      // and create it.
    }
    await ref.set(chat.toMap());
    return chat;
  }

  Future<void> sendMessage(String chatId, ChatMessage message) async {
    final chatRef = _chats.doc(chatId);
    await chatRef.collection('messages').doc(message.id).set(message.toMap());
    await chatRef.update({
      'lastMessage': message.text,
      'lastSenderId': message.senderId,
      'updatedAt': message.createdAt.toIso8601String(),
    });
  }
}
