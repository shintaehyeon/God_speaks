import 'package:cloud_firestore/cloud_firestore.dart';

class SavedItem {
  final String id;
  final String type; // 'verse' or 'quote'
  final String serviceType; // 'SUNDAY SERVICE', 'MIDWEEK SERVICE' etc.
  final String date;
  final String
  title; // 'VERSE OF THE DAY: John 3:16' or 'Key Sermon Quote' etc.
  final String content;
  final String authorOrVersion; // Bible version or speaker name
  final DateTime timestamp;

  SavedItem({
    required this.id,
    required this.type,
    required this.serviceType,
    required this.date,
    required this.title,
    required this.content,
    required this.authorOrVersion,
    required this.timestamp,
  });

  factory SavedItem.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return SavedItem(
      id: doc.id,
      type: data['type'] ?? 'verse',
      serviceType: data['serviceType'] ?? '',
      date: data['date'] ?? '',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      authorOrVersion: data['authorOrVersion'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type,
      'serviceType': serviceType,
      'date': date,
      'title': title,
      'content': content,
      'authorOrVersion': authorOrVersion,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
