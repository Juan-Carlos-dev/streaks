// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HabitLogImpl _$$HabitLogImplFromJson(Map<String, dynamic> json) =>
    _$HabitLogImpl(
      id: json['id'] as String,
      habitId: json['habitId'] as String,
      userId: json['userId'] as String,
      date: DateTime.parse(json['date'] as String),
      minutesSpent: (json['minutesSpent'] as num).toInt(),
      hasPhoto: json['hasPhoto'] as bool? ?? false,
    );

Map<String, dynamic> _$$HabitLogImplToJson(_$HabitLogImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'habitId': instance.habitId,
      'userId': instance.userId,
      'date': instance.date.toIso8601String(),
      'minutesSpent': instance.minutesSpent,
      'hasPhoto': instance.hasPhoto,
    };
