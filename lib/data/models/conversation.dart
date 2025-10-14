import 'package:cloud_firestore/cloud_firestore.dart';

class Conversation {
  final String id;
  final String title;
  final String model;
  final String systemPrompt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Conversation({
    required this.id,
    required this.title,
    required this.model,
    required this.systemPrompt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Conversation.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Conversation(
      id: doc.id,
      title: (data['title'] as String?) ?? 'New chat',
      model: (data['model'] as String?) ?? 'gemini-2.5-flash',
      systemPrompt: (data['systemPrompt'] as String?) ?? '',
      createdAt: (data['createdAt'] is Timestamp)
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: (data['updatedAt'] is Timestamp)
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }
}
