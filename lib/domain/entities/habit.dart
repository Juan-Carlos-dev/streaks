import 'package:freezed_annotation/freezed_annotation.dart';

part 'habit.freezed.dart';
part 'habit.g.dart';

@freezed
class Habit with _$Habit {
  @JsonSerializable(explicitToJson: true)
  const factory Habit({
    required String id,
    required String userId,
    required String title,
    required String icon,
    required String color,
    required HabitFrequency frequency,
    @Default(false) bool isPrivateHabit,
    String? reminderTime,
    @Default(0) int currentStreak,
    @Default(0) int longestStreak,
    required DateTime startDate,
  }) = _Habit;

  factory Habit.fromJson(Map<String, dynamic> json) => _$HabitFromJson(json);
}

@freezed
class HabitFrequency with _$HabitFrequency {
  const factory HabitFrequency({
    required List<int> daysOfWeek,
  }) = _HabitFrequency;

  factory HabitFrequency.fromJson(Map<String, dynamic> json) => _$HabitFrequencyFromJson(json);
}
