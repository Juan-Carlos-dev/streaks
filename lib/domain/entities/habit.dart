import 'package:cloud_firestore/cloud_firestore.dart';

class Habit {
  final String id;
  final String userId;
  final String title;
  final String icon;
  final String color;
  final HabitFrequency frequency;
  final bool isPrivateHabit;
  final int currentStreak;
  final int longestStreak;
  final String? reminderTime;
  final DateTime startDate;

  const Habit({
    required this.id,
    required this.userId,
    required this.title,
    required this.icon,
    required this.color,
    required this.frequency,
    this.isPrivateHabit = false,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.reminderTime,
    required this.startDate,
  });

  factory Habit.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Habit(
      id: data['id'] ?? doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      icon: data['icon'] ?? 'fitness_center',
      color: data['color'] ?? '#007BFF',
      frequency: data['frequency'] != null
          ? HabitFrequency.fromMap(Map<String, dynamic>.from(data['frequency']))
          : const HabitFrequency(daysOfWeek: []),
      isPrivateHabit: data['isPrivateHabit'] ?? false,
      currentStreak: data['currentStreak'] ?? 0,
      longestStreak: data['longestStreak'] ?? 0,
      reminderTime: data['reminderTime'],
      startDate: data['startDate'] != null
          ? DateTime.parse(data['startDate'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'icon': icon,
      'color': color,
      'frequency': frequency.toMap(),
      'isPrivateHabit': isPrivateHabit,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'reminderTime': reminderTime,
      'startDate': startDate.toIso8601String(),
    };
  }

  Habit copyWith({
    String? id,
    String? userId,
    String? title,
    String? icon,
    String? color,
    HabitFrequency? frequency,
    bool? isPrivateHabit,
    int? currentStreak,
    int? longestStreak,
    String? reminderTime,
    DateTime? startDate,
  }) {
    return Habit(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      frequency: frequency ?? this.frequency,
      isPrivateHabit: isPrivateHabit ?? this.isPrivateHabit,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      reminderTime: reminderTime ?? this.reminderTime,
      startDate: startDate ?? this.startDate,
    );
  }
}

class HabitFrequency {
  final List<int> daysOfWeek;

  const HabitFrequency({required this.daysOfWeek});

  factory HabitFrequency.fromMap(Map<String, dynamic> map) {
    return HabitFrequency(
      daysOfWeek: List<int>.from(map['daysOfWeek'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {'daysOfWeek': daysOfWeek};
  }
}
