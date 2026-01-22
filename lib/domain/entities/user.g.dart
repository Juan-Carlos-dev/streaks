// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
      uid: json['uid'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      photoUrl: json['photoUrl'] as String?,
      isPrivateProfile: json['isPrivateProfile'] as bool? ?? false,
      stats: json['stats'] == null
          ? const UserStats(totalMinutes: 0, currentGlobalStreak: 0)
          : UserStats.fromJson(json['stats'] as Map<String, dynamic>),
      widgetConfig: json['widgetConfig'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'email': instance.email,
      'username': instance.username,
      'photoUrl': instance.photoUrl,
      'isPrivateProfile': instance.isPrivateProfile,
      'stats': instance.stats,
      'widgetConfig': instance.widgetConfig,
    };

_$UserStatsImpl _$$UserStatsImplFromJson(Map<String, dynamic> json) =>
    _$UserStatsImpl(
      totalMinutes: (json['totalMinutes'] as num).toInt(),
      currentGlobalStreak: (json['currentGlobalStreak'] as num).toInt(),
    );

Map<String, dynamic> _$$UserStatsImplToJson(_$UserStatsImpl instance) =>
    <String, dynamic>{
      'totalMinutes': instance.totalMinutes,
      'currentGlobalStreak': instance.currentGlobalStreak,
    };
