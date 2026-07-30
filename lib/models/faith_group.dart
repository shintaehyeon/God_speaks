import 'package:cloud_firestore/cloud_firestore.dart';

class FaithGroup {
  final String id;
  final String name;
  final String ownerId;
  final String inviteCode;
  final List<String> memberIds;
  final DateTime createdAt;

  const FaithGroup({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.inviteCode,
    required this.memberIds,
    required this.createdAt,
  });

  factory FaithGroup.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FaithGroup(
      id: doc.id,
      name: data['name'] ?? '',
      ownerId: data['ownerId'] ?? '',
      inviteCode: data['inviteCode'] ?? '',
      memberIds: List<String>.from(data['memberIds'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  String get inviteToken => '$id-$inviteCode';
}

class GroupMember {
  final String id;
  final String userId;
  final String displayName;
  final String currentBook;
  final int currentChapter;
  final double progressPercent;
  final String role;
  final DateTime updatedAt;

  const GroupMember({
    required this.id,
    required this.userId,
    required this.displayName,
    required this.currentBook,
    required this.currentChapter,
    required this.progressPercent,
    required this.role,
    required this.updatedAt,
  });

  factory GroupMember.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final rawProgress = data['progressPercent'];
    return GroupMember(
      id: doc.id,
      userId: data['userId'] ?? '',
      displayName: data['displayName'] ?? '성도',
      currentBook: data['currentBook'] ?? '마태복음',
      currentChapter: data['currentChapter'] ?? 1,
      progressPercent: rawProgress is int
          ? rawProgress.toDouble()
          : (rawProgress ?? 0.03).toDouble(),
      role: data['role'] ?? 'member',
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  String get statusLabel => '$currentBook $currentChapter장 항해 중';
}

class QtPost {
  final String id;
  final String authorId;
  final String authorName;
  final String verseRef;
  final String content;
  final DateTime createdAt;

  const QtPost({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.verseRef,
    required this.content,
    required this.createdAt,
  });

  factory QtPost.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QtPost(
      id: doc.id,
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '성도',
      verseRef: data['verseRef'] ?? '',
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
