import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/habit_repository.dart';
import '../../data/repositories/habit_repository_impl.dart';
import '../../domain/entities/habit.dart';
import 'auth_providers.dart';
import 'user_providers.dart';
import '../../core/utils/widget_utils.dart';


/// Calculates the real global daily streak from the habits list.
///
/// Rules:
/// - Iterate backwards from today (or yesterday if today isn't fully done yet).
/// - For each day, collect all habits whose [HabitFrequency.daysOfWeek] includes
///   that weekday (Dart: 1=Mon … 7=Sun).
/// - If NO habits are scheduled for that day → skip it (doesn't break the streak).
/// - If some habits are scheduled → ALL must have a completedDates entry for
///   that day, otherwise the streak is broken.
/// - The streak counter only increments on days where habits were scheduled
///   AND all were completed.
final globalStreakProvider = Provider<int>((ref) {
  final habitsAsync = ref.watch(habitListProvider);
  return habitsAsync.when(
    data: (habits) => _computeGlobalStreak(habits),
    loading: () => 0,
    error: (_, __) => 0,
  );
});

int _computeGlobalStreak(List<Habit> habits) {
  if (habits.isEmpty) return 0;

  final now = DateTime.now();
  // Normalise today to midnight
  DateTime cursor = DateTime(now.year, now.month, now.day);

  // Helper: format a date as 'yyyy-MM-dd'
  String fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  int streak = 0;

  // We look back up to 365 days to avoid an infinite loop
  for (int i = 0; i < 365; i++) {
    final dateKey = fmt(cursor);
    final weekday = cursor.weekday; // 1=Mon … 7=Sun

    // Habits scheduled for this weekday
    final scheduled = habits
        .where((h) => h.frequency.daysOfWeek.contains(weekday))
        .toList();

    if (scheduled.isEmpty) {
      // No habits today → skip, does NOT break streak
      cursor = cursor.subtract(const Duration(days: 1));
      continue;
    }

    // Check if ALL scheduled habits were completed this day
    final allDone = scheduled.every((h) => h.completedDates.containsKey(dateKey));

    if (allDone) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    } else {
      // Today might still be in progress — only break if it's a past day
      // OR if it's today but nothing is done at all yet
      if (i == 0) {
        // It's today: don't count today, but don't break either — start
        // checking yesterday
        cursor = cursor.subtract(const Duration(days: 1));
        continue;
      }
      break; // Past day not completed → streak ends
    }
  }

  return streak;
}

final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  return HabitRepositoryImpl(FirebaseFirestore.instance);
});

final habitListProvider = StreamProvider<List<Habit>>((ref) {
  final uid = ref.watch(authStateProvider).value;
  if (uid == null) return Stream.value([]);
  final repository = ref.watch(habitRepositoryProvider);
  return repository.getHabitsByUserId(uid);
});

final habitByIdProvider = StreamProvider.family<Habit?, String>((ref, habitId) {
  return ref.watch(habitRepositoryProvider).getHabitStream(habitId);
});

final habitControllerProvider =
    StateNotifierProvider<HabitController, AsyncValue<void>>((ref) {
  return HabitController(ref.watch(habitRepositoryProvider));
});

class HabitController extends StateNotifier<AsyncValue<void>> {
  final HabitRepository _repository;

  HabitController(this._repository) : super(const AsyncData(null));

  Future<void> createHabit(Habit habit) async {
    state = const AsyncLoading();
    final result = await _repository.createHabit(habit);
    state = result.fold(
      (failure) => AsyncError(failure.message, StackTrace.current),
      (_) => const AsyncData(null),
    );
  }

  Future<void> updateHabit(Habit habit) async {
    state = const AsyncLoading();
    final result = await _repository.updateHabit(habit);
    state = result.fold(
      (failure) => AsyncError(failure.message, StackTrace.current),
      (_) => const AsyncData(null),
    );
  }

  Future<void> deleteHabit(String habitId) async {
    state = const AsyncLoading();
    final result = await _repository.deleteHabit(habitId);
    state = result.fold(
      (failure) => AsyncError(failure.message, StackTrace.current),
      (_) => const AsyncData(null),
    );
  }

  Future<void> completeHabit(String habitId) async {
    state = const AsyncLoading();
    final result = await _repository.completeHabit(habitId);
    state = result.fold(
      (failure) => AsyncError(failure.message, StackTrace.current),
      (_) => const AsyncData(null),
    );
  }

  Future<void> toggleHabitCompletion(String habitId, DateTime date) async {
    state = const AsyncLoading();
    final result = await _repository.toggleHabitCompletion(habitId, date);
    state = result.fold(
      (failure) => AsyncError(failure.message, StackTrace.current),
      (_) => const AsyncData(null),
    );
  }
}

class StreakRecord {
  final String id;
  final DateTime startDate;
  final DateTime endDate;
  final int days;
  final int completedTasks;
  final int followersGained;
  final int minutesSpent;

  StreakRecord({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.days,
    required this.completedTasks,
    required this.followersGained,
    required this.minutesSpent,
  });
}

final followerDatesProvider = StreamProvider<List<DateTime>>((ref) {
  final uid = ref.watch(authStateProvider).value;
  if (uid == null) return Stream.value([]);
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('followers')
      .snapshots()
      .map((snapshot) {
        final dates = <DateTime>[];
        for (final doc in snapshot.docs) {
          final data = doc.data();
          final ts = data['createdAt'];
          if (ts is Timestamp) {
            dates.add(ts.toDate());
          }
        }
        return dates;
      });
});

class ActiveStreakStats {
  final int days;
  final int completedTasks;
  final int followersGained;
  final int minutesSpent;

  const ActiveStreakStats({
    required this.days,
    required this.completedTasks,
    required this.followersGained,
    required this.minutesSpent,
  });
}

final activeStreakStatsProvider = Provider<ActiveStreakStats>((ref) {
  final streak = ref.watch(globalStreakProvider);
  final habits = ref.watch(habitListProvider).value ?? [];
  final followerDates = ref.watch(followerDatesProvider).value ?? [];
  final user = ref.watch(currentUserProvider).value;
  
  final rawMinutes = user?.widgetConfig['minutesLog'];
  final minutesLog = rawMinutes is Map
      ? Map<String, int>.from(rawMinutes.map((k, v) => MapEntry(k.toString(), (v as num).toInt())))
      : <String, int>{};

  if (streak == 0) {
    return const ActiveStreakStats(
      days: 0,
      completedTasks: 0,
      followersGained: 0,
      minutesSpent: 0,
    );
  }

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  String fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  final List<DateTime> activeDates = [];
  DateTime cursor = today;
  int count = 0;
  for (int i = 0; i < 365; i++) {
    final dateKey = fmt(cursor);
    final weekday = cursor.weekday;
    final scheduled = habits.where((h) => h.frequency.daysOfWeek.contains(weekday)).toList();
    if (scheduled.isEmpty) {
      cursor = cursor.subtract(const Duration(days: 1));
      continue;
    }
    final allDone = scheduled.every((h) => h.completedDates.containsKey(dateKey));
    if (allDone) {
      activeDates.add(cursor);
      count++;
      cursor = cursor.subtract(const Duration(days: 1));
      if (count >= streak) break;
    } else {
      if (i == 0) {
        cursor = cursor.subtract(const Duration(days: 1));
        continue;
      }
      break;
    }
  }

  // Sum completed tasks
  int tasks = 0;
  for (final h in habits) {
    for (final d in activeDates) {
      if (h.completedDates.containsKey(fmt(d))) {
        tasks++;
      }
    }
  }

  // Sum followers gained during active dates
  int followers = 0;
  if (activeDates.isNotEmpty) {
    activeDates.sort();
    final start = DateTime(activeDates.first.year, activeDates.first.month, activeDates.first.day);
    final end = DateTime(activeDates.last.year, activeDates.last.month, activeDates.last.day).add(const Duration(days: 1));
    followers = followerDates.where((fd) => fd.isAfter(start) && fd.isBefore(end)).length;
  }

  // Sum minutes spent during active dates
  int minutes = 0;
  for (final d in activeDates) {
    minutes += minutesLog[fmt(d)] ?? 0;
  }

  return ActiveStreakStats(
    days: streak,
    completedTasks: tasks,
    followersGained: followers,
    minutesSpent: minutes,
  );
});

final pastStreaksProvider = Provider<List<StreakRecord>>((ref) {
  final streak = ref.watch(globalStreakProvider);
  final habits = ref.watch(habitListProvider).value ?? [];
  final followerDates = ref.watch(followerDatesProvider).value ?? [];
  final user = ref.watch(currentUserProvider).value;
  
  final rawMinutes = user?.widgetConfig['minutesLog'];
  final minutesLog = rawMinutes is Map
      ? Map<String, int>.from(rawMinutes.map((k, v) => MapEntry(k.toString(), (v as num).toInt())))
      : <String, int>{};

  if (habits.isEmpty) return [];

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  
  String fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // 1. Identify active streak dates to avoid overlap
  final List<DateTime> activeDates = [];
  if (streak > 0) {
    DateTime cursor = today;
    int count = 0;
    for (int i = 0; i < 365; i++) {
      final dateKey = fmt(cursor);
      final weekday = cursor.weekday;
      final scheduled = habits.where((h) => h.frequency.daysOfWeek.contains(weekday)).toList();
      if (scheduled.isEmpty) {
        cursor = cursor.subtract(const Duration(days: 1));
        continue;
      }
      final allDone = scheduled.every((h) => h.completedDates.containsKey(dateKey));
      if (allDone) {
        activeDates.add(cursor);
        count++;
        cursor = cursor.subtract(const Duration(days: 1));
        if (count >= streak) break;
      } else {
        if (i == 0) {
          cursor = cursor.subtract(const Duration(days: 1));
          continue;
        }
        break;
      }
    }
  }
  activeDates.sort();

  final limitDate = activeDates.isNotEmpty ? activeDates.first : today;

  // Find oldest date
  DateTime? oldestDate;
  for (final h in habits) {
    for (final dateKey in h.completedDates.keys) {
      try {
        final d = DateTime.parse(dateKey);
        if (oldestDate == null || d.isBefore(oldestDate)) {
          oldestDate = d;
        }
      } catch (_) {}
    }
  }

  final List<StreakRecord> history = [];

  if (oldestDate != null) {
    DateTime cursor = oldestDate;
    List<DateTime> currentStreakDays = [];

    while (cursor.isBefore(limitDate)) {
      final dateKey = fmt(cursor);
      final weekday = cursor.weekday;
      final scheduled = habits.where((h) => h.frequency.daysOfWeek.contains(weekday)).toList();

      if (scheduled.isEmpty) {
        cursor = cursor.add(const Duration(days: 1));
        continue;
      }

      final allDone = scheduled.every((h) => h.completedDates.containsKey(dateKey));
      if (allDone) {
        currentStreakDays.add(cursor);
      } else {
        if (currentStreakDays.isNotEmpty) {
          history.add(_buildRecord(
            days: currentStreakDays,
            habits: habits,
            followerDates: followerDates,
            minutesLog: minutesLog,
          ));
          currentStreakDays = [];
        }
      }
      cursor = cursor.add(const Duration(days: 1));
    }

    if (currentStreakDays.isNotEmpty) {
      history.add(_buildRecord(
        days: currentStreakDays,
        habits: habits,
        followerDates: followerDates,
        minutesLog: minutesLog,
      ));
    }
  }

  return history.reversed.toList();
});

StreakRecord _buildRecord({
  required List<DateTime> days,
  required List<Habit> habits,
  required List<DateTime> followerDates,
  required Map<String, int> minutesLog,
}) {
  days.sort();
  final start = days.first;
  final end = days.last;
  final startFmt = DateTime(start.year, start.month, start.day);
  final endFmt = DateTime(end.year, end.month, end.day).add(const Duration(days: 1));

  String fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  int tasks = 0;
  for (final h in habits) {
    for (final d in days) {
      if (h.completedDates.containsKey(fmt(d))) {
        tasks++;
      }
    }
  }

  int followers = followerDates.where((fd) => fd.isAfter(startFmt) && fd.isBefore(endFmt)).length;

  int minutes = 0;
  for (final d in days) {
    minutes += minutesLog[fmt(d)] ?? 0;
  }

  return StreakRecord(
    id: fmt(start),
    startDate: start,
    endDate: end,
    days: days.length,
    completedTasks: tasks,
    followersGained: followers,
    minutesSpent: minutes,
  );
}

final nativeWidgetSyncProvider = Provider.autoDispose<void>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  final habitsAsync = ref.watch(habitListProvider);
  final streak = ref.watch(globalStreakProvider);

  userAsync.whenData((user) {
    habitsAsync.whenData((habits) {
      if (user != null) {
        WidgetUtils.updateNativeWidget(
          user: user,
          habits: habits,
          globalStreak: streak,
        );
      }
    });
  });
});

