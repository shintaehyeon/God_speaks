import 'package:cloud_firestore/cloud_firestore.dart';

class SermonSummary {
  final String id;
  final String title;
  final String date;
  final String category;
  final List<String> bulletPoints;
  final String keyScripture;
  final String takeaway;
  final String audioUrl;
  final DateTime timestamp;

  SermonSummary({
    required this.id,
    required this.title,
    required this.date,
    required this.category,
    required this.bulletPoints,
    required this.keyScripture,
    required this.takeaway,
    required this.audioUrl,
    required this.timestamp,
  });

  factory SermonSummary.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return SermonSummary(
      id: doc.id,
      title: data['title'] ?? '',
      date: data['date'] ?? '',
      category: data['category'] ?? '',
      bulletPoints: List<String>.from(data['bulletPoints'] ?? []),
      keyScripture: data['keyScripture'] ?? '',
      takeaway: data['takeaway'] ?? '',
      audioUrl: data['audioUrl'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'date': date,
      'category': category,
      'bulletPoints': bulletPoints,
      'keyScripture': keyScripture,
      'takeaway': takeaway,
      'audioUrl': audioUrl,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
