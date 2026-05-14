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
  final Map<String, DateTime> completedDates;

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
    this.completedDates = const {},
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
          : const HabitFrequency(daysOfWeek: [1, 2, 3, 4, 5, 6, 7]),
      isPrivateHabit: data['isPrivateHabit'] ?? false,
      currentStreak: data['currentStreak'] ?? 0,
      longestStreak: data['longestStreak'] ?? 0,
      reminderTime: data['reminderTime'],
      startDate: data['startDate'] != null
          ? DateTime.parse(data['startDate'])
          : DateTime.now(),
      completedDates: data['completedDates'] != null
          ? Map<String, dynamic>.from(data['completedDates'] as Map).map(
              (key, value) => MapEntry(key, DateTime.parse(value.toString())))
          : {},
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
      'completedDates': completedDates.map((k, v) => MapEntry(k, v.toIso8601String())),
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
    Map<String, DateTime>? completedDates,
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
      completedDates: completedDates ?? this.completedDates,
    );
  }

  int get calculatedStreak {
    if (completedDates.isEmpty) return 0;
    
    int streak = 0;
    DateTime date = DateTime.now();
    date = DateTime(date.year, date.month, date.day);
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    
    while (date.isAfter(start) || date.isAtSameMomentAs(start)) {
      if (frequency.daysOfWeek.contains(date.weekday)) {
        final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        final isCompleted = completedDates.containsKey(dateKey);
        
        if (isCompleted) {
          streak++;
        } else {
          final now = DateTime.now();
          final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
          if (!isToday) {
            break;
          }
        }
      }
      date = date.subtract(const Duration(days: 1));
    }
    return streak;
  }
}

class HabitFrequency {
  final List<int> daysOfWeek;

  const HabitFrequency({required this.daysOfWeek});

  factory HabitFrequency.fromMap(Map<String, dynamic> map) {
    final list = map['daysOfWeek'] as List<dynamic>?;
    return HabitFrequency(
      daysOfWeek: list != null ? list.map((e) => (e as num).toInt()).toList() : [1, 2, 3, 4, 5, 6, 7],
    );
  }

  Map<String, dynamic> toMap() {
    return {'daysOfWeek': daysOfWeek};
  }
}
