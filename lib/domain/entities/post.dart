import 'package:freezed_annotation/freezed_annotation.dart';

part 'post.freezed.dart';
part 'post.g.dart';

@freezed
class Post with _$Post {
  const factory Post({
    required String id,
    required String userId,
    required String habitId,
    required String imageUrl,
    required String caption,
    @Default(0) int likesCount,
    required int habitStreakSnapshot,
    required DateTime timestamp,
  }) = _Post;

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
}
