import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final int price;
  final String description;
  final String imageUrl;
  final String creatorUid;
  final Timestamp creationTime;
  final Timestamp updateTime;
  final int likes;
  final List<String> likedBy;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.creatorUid,
    required this.creationTime,
    required this.updateTime,
    this.likes = 0,
    this.likedBy = const [],
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      price: data['price'] ?? 0,
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      creatorUid: data['creatorUid'] ?? '',
      creationTime: data['creationTime'] ?? Timestamp.now(),
      updateTime: data['updateTime'] ?? Timestamp.now(),
      likes: data['likes'] ?? 0,
      likedBy: List<String>.from(data['likedBy'] ?? []),
    );
  }
}
