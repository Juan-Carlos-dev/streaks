import 'package:freezed_annotation/freezed_annotation.dart';

part 'habit_log.freezed.dart';
part 'habit_log.g.dart';

@freezed
class HabitLog with _$HabitLog {
  const factory HabitLog({
    required String id,
    required String habitId,
    required String userId,
    required DateTime date,
    required int minutesSpent,
    @Default(false) bool hasPhoto,
  }) = _HabitLog;

  factory HabitLog.fromJson(Map<String, dynamic> json) => _$HabitLogFromJson(json);
}
