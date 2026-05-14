import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String userId;
  final String habitId;
  final String imageUrl;
  final String caption;
  final int likesCount;
  final List<String> likedBy;
  final int habitStreakSnapshot;
  final DateTime timestamp;

  const Post({
    required this.id,
    required this.userId,
    required this.habitId,
    required this.imageUrl,
    required this.caption,
    this.likesCount = 0,
    this.likedBy = const [],
    this.habitStreakSnapshot = 0,
    required this.timestamp,
  });

  factory Post.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Post(
      id: data['id'] ?? doc.id,
      userId: data['userId'] ?? '',
      habitId: data['habitId'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      caption: data['caption'] ?? '',
      likesCount: data['likesCount'] ?? 0,
      likedBy: List<String>.from(data['likedBy'] ?? []),
      habitStreakSnapshot: data['habitStreakSnapshot'] ?? 0,
      timestamp: data['timestamp'] != null
          ? DateTime.parse(data['timestamp'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'habitId': habitId,
      'imageUrl': imageUrl,
      'caption': caption,
      'likesCount': likesCount,
      'likedBy': likedBy,
      'habitStreakSnapshot': habitStreakSnapshot,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  Post copyWith({
    String? id,
    String? userId,
    String? habitId,
    String? imageUrl,
    String? caption,
    int? likesCount,
    List<String>? likedBy,
    int? habitStreakSnapshot,
    DateTime? timestamp,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      habitId: habitId ?? this.habitId,
      imageUrl: imageUrl ?? this.imageUrl,
      caption: caption ?? this.caption,
      likesCount: likesCount ?? this.likesCount,
      likedBy: likedBy ?? this.likedBy,
      habitStreakSnapshot: habitStreakSnapshot ?? this.habitStreakSnapshot,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
