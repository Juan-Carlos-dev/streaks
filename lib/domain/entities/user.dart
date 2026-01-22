import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String uid,
    required String email,
    required String username,
    String? photoUrl,
    @Default(false) bool isPrivateProfile,
    @Default(UserStats(totalMinutes: 0, currentGlobalStreak: 0)) UserStats stats,
    @Default({}) Map<String, dynamic> widgetConfig,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

@freezed
class UserStats with _$UserStats {
  const factory UserStats({
    required int totalMinutes,
    required int currentGlobalStreak,
  }) = _UserStats;

  factory UserStats.fromJson(Map<String, dynamic> json) => _$UserStatsFromJson(json);
}
