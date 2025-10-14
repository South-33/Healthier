import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String role; // 'user' | 'assistant'
  final String content;
  final DateTime createdAt;
  final String status; // 'streaming' | 'final' | 'error'

  Message({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
    required this.status,
  });

  factory Message.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Message(
      id: doc.id,
      role: (data['role'] as String?) ?? 'assistant',
      content: (data['content'] as String?) ?? '',
      createdAt: ((data['createdAt'] as Timestamp?) ?? Timestamp.now()).toDate(),
      status: (data['status'] as String?) ?? 'final',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'role': role,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status,
    };
  }
}
