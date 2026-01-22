// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PostImpl _$$PostImplFromJson(Map<String, dynamic> json) => _$PostImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      habitId: json['habitId'] as String,
      imageUrl: json['imageUrl'] as String,
      caption: json['caption'] as String,
      likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
      habitStreakSnapshot: (json['habitStreakSnapshot'] as num).toInt(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$$PostImplToJson(_$PostImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'habitId': instance.habitId,
      'imageUrl': instance.imageUrl,
      'caption': instance.caption,
      'likesCount': instance.likesCount,
      'habitStreakSnapshot': instance.habitStreakSnapshot,
      'timestamp': instance.timestamp.toIso8601String(),
    };
