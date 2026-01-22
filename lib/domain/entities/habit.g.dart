// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HabitImpl _$$HabitImplFromJson(Map<String, dynamic> json) => _$HabitImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
      frequency:
          HabitFrequency.fromJson(json['frequency'] as Map<String, dynamic>),
      isPrivateHabit: json['isPrivateHabit'] as bool? ?? false,
      reminderTime: json['reminderTime'] as String?,
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
      startDate: DateTime.parse(json['startDate'] as String),
    );

Map<String, dynamic> _$$HabitImplToJson(_$HabitImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'title': instance.title,
      'icon': instance.icon,
      'color': instance.color,
      'frequency': instance.frequency,
      'isPrivateHabit': instance.isPrivateHabit,
      'reminderTime': instance.reminderTime,
      'currentStreak': instance.currentStreak,
      'longestStreak': instance.longestStreak,
      'startDate': instance.startDate.toIso8601String(),
    };

_$HabitFrequencyImpl _$$HabitFrequencyImplFromJson(Map<String, dynamic> json) =>
    _$HabitFrequencyImpl(
      daysOfWeek: (json['daysOfWeek'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$$HabitFrequencyImplToJson(
        _$HabitFrequencyImpl instance) =>
    <String, dynamic>{
      'daysOfWeek': instance.daysOfWeek,
    };
