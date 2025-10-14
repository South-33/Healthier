import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:healthier/data/models/message.dart' as model;
import 'package:healthier/data/models/conversation.dart' as convo;

class ConversationRepository {
  ConversationRepository({FirebaseFirestore? db, FirebaseAuth? auth})
      : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('No authenticated user');
    }
    return user.uid;
  }

  Future<String> createConversation({
    String? title,
    required String model,
    required String systemPrompt,
  }) async {
    final convRef = _db
        .collection('users')
        .doc(_uid)
        .collection('conversations')
        .doc();

    await convRef.set({
      'title': title ?? 'New chat',
      'model': model,
      'systemPrompt': systemPrompt,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return convRef.id;
  }

  Stream<List<model.Message>> watchMessages(String conversationId) {
    final query = _db
        .collection('users')
        .doc(_uid)
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('createdAt');

    return query.snapshots().map((snap) =>
        snap.docs.map((d) => model.Message.fromDoc(d)).toList());
  }

  Future<String> addUserMessage(String conversationId, String text) async {
    final msgRef = _db
        .collection('users')
        .doc(_uid)
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc();

    await msgRef.set({
      'role': 'user',
      'content': text,
      'status': 'final',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _touchConversation(conversationId);
    return msgRef.id;
  }

  Future<String> addAssistantPlaceholder(String conversationId) async {
    final msgRef = _db
        .collection('users')
        .doc(_uid)
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc();

    await msgRef.set({
      'role': 'assistant',
      'content': '',
      'status': 'streaming',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _touchConversation(conversationId);
    return msgRef.id;
  }

  Future<void> updateAssistantMessage(
    String conversationId,
    String messageId,
    String text, {
    bool isFinal = false,
  }) async {
    final msgRef = _db
        .collection('users')
        .doc(_uid)
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc(messageId);

    await msgRef.update({
      'content': text,
      if (isFinal) 'status': 'final',
    });

    await _touchConversation(conversationId);
  }

  Future<void> _touchConversation(String conversationId) async {
    final convRef = _db
        .collection('users')
        .doc(_uid)
        .collection('conversations')
        .doc(conversationId);
    await convRef.set({
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<List<convo.Conversation>> watchConversations() {
    final query = _db
        .collection('users')
        .doc(_uid)
        .collection('conversations')
        .orderBy('updatedAt', descending: true);
    return query.snapshots().map(
        (snap) => snap.docs.map((d) => convo.Conversation.fromDoc(d)).toList());
  }

  Future<convo.Conversation?> getConversation(String conversationId) async {
    final doc = await _db
        .collection('users')
        .doc(_uid)
        .collection('conversations')
        .doc(conversationId)
        .get();
    if (!doc.exists) return null;
    return convo.Conversation.fromDoc(doc);
  }

  Stream<convo.Conversation?> watchConversation(String conversationId) {
    final docRef = _db
        .collection('users')
        .doc(_uid)
        .collection('conversations')
        .doc(conversationId);
    return docRef.snapshots().map((d) => d.exists ? convo.Conversation.fromDoc(d) : null);
  }

  Future<void> renameConversation(String conversationId, String title) async {
    final convRef = _db
        .collection('users')
        .doc(_uid)
        .collection('conversations')
        .doc(conversationId);
    await convRef.set({
      'title': title,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> deleteConversation(String conversationId) async {
    final convRef = _db
        .collection('users')
        .doc(_uid)
        .collection('conversations')
        .doc(conversationId);
    // Delete messages in batches
    const int pageSize = 200;
    while (true) {
      final snap = await convRef
          .collection('messages')
          .orderBy('createdAt')
          .limit(pageSize)
          .get();
      if (snap.docs.isEmpty) break;
      final batch = _db.batch();
      for (final d in snap.docs) {
        batch.delete(d.reference);
      }
      await batch.commit();
      if (snap.docs.length < pageSize) break;
    }
    await convRef.delete();
  }

  Future<List<model.Message>> fetchRecentMessages(String conversationId, {int limit = 6}) async {
    final qSnap = await _db
        .collection('users')
        .doc(_uid)
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    final list = qSnap.docs.map((d) => model.Message.fromDoc(d)).toList();
    return list.reversed.toList();
  }

  Future<List<model.Message>> fetchAllMessages(String conversationId) async {
    final collection = _db
        .collection('users')
        .doc(_uid)
        .collection('conversations')
        .doc(conversationId)
        .collection('messages');

    const pageSize = 200;
    List<model.Message> all = [];
    QueryDocumentSnapshot<Map<String, dynamic>>? last;
    while (true) {
      Query<Map<String, dynamic>> query = collection.orderBy('createdAt').limit(pageSize);
      if (last != null) {
        query = query.startAfterDocument(last);
      }
      final snap = await query.get();
      if (snap.docs.isEmpty) break;
      all.addAll(snap.docs.map(model.Message.fromDoc));
      last = snap.docs.last;
      if (snap.docs.length < pageSize) break;
    }
    return all;
  }
}
