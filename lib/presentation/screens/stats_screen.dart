import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/habit.dart';
import '../providers/user_providers.dart';
import '../providers/habit_providers.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  void _showStreakHistory(BuildContext context, WidgetRef ref) {
    final pastStreaks = ref.read(pastStreaksProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onVerticalDragUpdate: (details) {
                  if (details.primaryDelta! > 7) {
                    Navigator.pop(context);
                  }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Historial de rachas',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tus logros de rachas anteriores completadas',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (pastStreaks.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text(
                      'No tienes rachas anteriores registradas aún.',
                      style: TextStyle(color: Colors.white38, fontSize: 14),
                    ),
                  ),
                )
              else
                Flexible(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.6,
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: pastStreaks.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final record = pastStreaks[index];
                        final startStr = '${record.startDate.day}/${record.startDate.month}/${record.startDate.year}';
                        final endStr = '${record.endDate.day}/${record.endDate.month}/${record.endDate.year}';

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF262626),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.local_fire_department, color: Colors.orange, size: 20),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Racha de ${record.days} ${record.days == 1 ? 'día' : 'días'}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '$startStr - $endStr',
                                    style: const TextStyle(
                                      color: Colors.white38,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _HistoryStatItem(
                                    label: 'Tareas',
                                    value: '${record.completedTasks}',
                                    icon: Icons.check_circle_outline,
                                  ),
                                  _HistoryStatItem(
                                    label: 'Seguidores',
                                    value: '${record.followersGained}',
                                    icon: Icons.people_outline,
                                  ),
                                  _HistoryStatItem(
                                    label: 'Minutos',
                                    value: '${record.minutesSpent}m',
                                    icon: Icons.timer_outlined,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final habitsAsync = ref.watch(habitListProvider);
    final streak = ref.watch(globalStreakProvider);
    final activeStats = ref.watch(activeStreakStatsProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top Action Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.history, color: Colors.white70, size: 28),
                      onPressed: () => _showStreakHistory(context, ref),
                    ),
                    const SizedBox.shrink(),
                  ],
                ),
              ),

              // ── Streak hero ──────────────────────────────────────────────
              userAsync.when(
                data: (user) {
                  final name = user?.username ?? '';
                  return habitsAsync.when(
                    data: (habits) =>
                        _StreakHero(streak: streak, username: name, habits: habits),
                    loading: () => _StreakHero(streak: streak, username: name, habits: const []),
                    error: (_, __) =>
                        _StreakHero(streak: streak, username: name, habits: const []),
                  );
                },
                loading: () => const SizedBox(
                  height: 120,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 28),

              // ── Cards Container ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Stats card — streak from activeStats Provider
                    _StatsCard(
                      streak: activeStats.days,
                      tasks: activeStats.completedTasks,
                      followers: activeStats.followersGained,
                      minutes: activeStats.minutesSpent,
                      habits: habitsAsync.asData?.value ?? [],
                    ),

                    const SizedBox(height: 16),

                    // Heatmap card — real data from habits
                    habitsAsync.when(
                      data: (habits) => _HeatmapCard(habits: habits),
                      loading: () => const _HeatmapCard(habits: []),
                      error: (_, __) => const _HeatmapCard(habits: []),
                    ),

                    const SizedBox(height: 16),

                    // Habits card
                    habitsAsync.when(
                      data: (habits) => _HabitsCard(habits: habits),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),

                    // Padding for the floating bottom navigation bar
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Streak Hero ─────────────────────────────────────────────────────────────

class _StreakHero extends StatelessWidget {
  final int streak;
  final String username;
  final List<Habit> habits;

  const _StreakHero({
    required this.streak,
    required this.username,
    required this.habits,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Big streak number
        Text(
          '$streak',
          style: const TextStyle(
            fontSize: 110,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Tu racha diaria',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '¡Vas por buen camino, ${username.isNotEmpty ? username : 'campeón'}!',
          style: const TextStyle(
            fontSize: 13,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 20),
        // Day circles row
        _DayCirclesRow(streak: streak),
      ],
    );
  }
}

// ── Day Circles Row ──────────────────────────────────────────────────────────

class _DayCirclesRow extends StatelessWidget {
  final int streak;

  const _DayCirclesRow({required this.streak});

  @override
  Widget build(BuildContext context) {
    final List<Widget> circles = [];

    if (streak == 0) {
      // If no streak, show 7 upcoming numbered circles starting from 1
      for (int i = 1; i <= 7; i++) {
        circles.add(_DayCircle(
          completed: false,
          label: '$i',
        ));
      }
    } else {
      // If streak >= 1, show exactly 1 green check circle on the far left
      circles.add(const _DayCircle(completed: true, label: ''));

      // Followed by 6 upcoming numbered circles starting from streak + 1
      for (int i = 1; i <= 6; i++) {
        circles.add(_DayCircle(
          completed: false,
          label: '${streak + i}',
        ));
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: circles,
    );
  }
}


class _DayCircle extends ConsumerWidget {
  final bool completed;
  final String label;
  final bool invisible;

  const _DayCircle({
    required this.completed,
    required this.label,
    this.invisible = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(gradientControllerProvider);

    if (invisible) {
      return const SizedBox(width: 52, height: 44);
    }

    return Container(
      width: 44,
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        gradient: completed ? AppColors.blueGradient : null,
        color: completed ? null : const Color(0xFFE8E8E8),
        shape: BoxShape.circle,
      ),
      child: completed
          ? const Icon(Icons.check, color: Colors.white, size: 22)
          : Center(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
    );
  }
}

// ── Stats Card ───────────────────────────────────────────────────────────────

class _StatsCard extends ConsumerWidget {
  final int streak;
  final int tasks;
  final int followers;
  final int minutes;
  final List<Habit> habits;

  const _StatsCard({
    required this.streak,
    required this.tasks,
    required this.followers,
    required this.minutes,
    required this.habits,
  });

  void _showBreakdown(BuildContext context, WidgetRef ref) {
    final gradient = AppColors.blueGradient;
    final followerDates = ref.read(followerDatesProvider).value ?? [];
    final user = ref.read(currentUserProvider).value;
    final rawMinutes = user?.widgetConfig['minutesLog'];
    final minutesLog = rawMinutes is Map
        ? Map<String, int>.from(rawMinutes.map((k, v) => MapEntry(k.toString(), (v as num).toInt())))
        : <String, int>{};

    // Compute per-habit stats
    final now = DateTime.now();
    final thisMonth = habits.map((h) {
      final count = h.completedDates.keys.where((k) {
        try {
          final d = DateTime.parse(k);
          return d.year == now.year && d.month == now.month;
        } catch (_) {
          return false;
        }
      }).length;
      return (habit: h, monthCount: count);
    }).toList();

    // Compute Star Habit (highest completions this month)
    Habit? starHabit;
    int maxCompletions = -1;
    for (final h in habits) {
      final countThisMonth = h.completedDates.keys.where((k) {
        try {
          final d = DateTime.parse(k);
          return d.year == now.year && d.month == now.month;
        } catch (_) {
          return false;
        }
      }).length;
      if (countThisMonth > maxCompletions) {
        maxCompletions = countThisMonth;
        starHabit = h;
      }
    }

    // Compute Most Productive Day of the Week
    final weekdayCounts = <int, int>{};
    for (final h in habits) {
      for (final k in h.completedDates.keys) {
        try {
          final d = DateTime.parse(k);
          if (d.year == now.year && d.month == now.month) {
            weekdayCounts[d.weekday] = (weekdayCounts[d.weekday] ?? 0) + 1;
          }
        } catch (_) {}
      }
    }
    int bestDayNum = 1;
    int maxDayCount = -1;
    weekdayCounts.forEach((day, c) {
      if (c > maxDayCount) {
        maxDayCount = c;
        bestDayNum = day;
      }
    });
    final dayNames = {
      1: 'Lunes',
      2: 'Martes',
      3: 'Miércoles',
      4: 'Jueves',
      5: 'Viernes',
      6: 'Sábado',
      7: 'Domingo',
    };
    final bestDayStr = maxDayCount > 0 ? dayNames[bestDayNum]! : 'Sin datos';

    // Compute Consistency Monthly Rate
    int scheduledSessions = 0;
    int completedSessions = 0;
    final today = DateTime.now();
    final firstDayOfMonth = DateTime(today.year, today.month, 1);

    for (final h in habits) {
      for (final k in h.completedDates.keys) {
        try {
          final d = DateTime.parse(k);
          if (d.year == today.year && d.month == today.month) {
            completedSessions++;
          }
        } catch (_) {}
      }

      DateTime temp = firstDayOfMonth;
      while (temp.isBefore(today) || (temp.year == today.year && temp.month == today.month && temp.day == today.day)) {
        if (h.frequency.daysOfWeek.contains(temp.weekday)) {
          scheduledSessions++;
        }
        temp = temp.add(const Duration(days: 1));
      }
    }

    final consistencyRate = scheduledSessions > 0
        ? (completedSessions / scheduledSessions * 100).clamp(0, 100).round()
        : 0;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onVerticalDragUpdate: (details) {
                    if (details.primaryDelta! > 7) {
                      Navigator.pop(context);
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Desglose de estadísticas',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Summary row
                Row(
                  children: [
                    _BreakdownTile(
                      label: 'Racha actual',
                      value: '$streak días',
                      icon: Icons.local_fire_department,
                      gradient: gradient,
                    ),
                    const SizedBox(width: 12),
                    _BreakdownTile(
                      label: 'Publicaciones',
                      value: '$tasks',
                      icon: Icons.article_outlined,
                      gradient: gradient,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _BreakdownTile(
                      label: 'Seguidores',
                      value: '$followers',
                      icon: Icons.people_outline,
                      gradient: gradient,
                    ),
                    const SizedBox(width: 12),
                    _BreakdownTile(
                      label: 'Minutos totales',
                      value: '$minutes min',
                      icon: Icons.timer_outlined,
                      gradient: gradient,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Interactive Trends Chart
                _InteractiveStatsChart(
                  habits: habits,
                  followerDates: followerDates,
                  minutesLog: minutesLog,
                ),

                const SizedBox(height: 24),
                const Text(
                  'Insights Inteligentes',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    _InsightTile(
                      title: 'Consistencia',
                      subtitle: '$consistencyRate%',
                      icon: Icons.track_changes,
                      color: Colors.tealAccent,
                    ),
                    const SizedBox(width: 10),
                    _InsightTile(
                      title: 'Hábito Estrella',
                      subtitle: starHabit != null && maxCompletions > 0 ? starHabit.title : '¡Comienza hoy!',
                      icon: Icons.star_border,
                      color: Colors.amberAccent,
                    ),
                    const SizedBox(width: 10),
                    _InsightTile(
                      title: 'Día Activo',
                      subtitle: bestDayStr,
                      icon: Icons.flash_on_outlined,
                      color: Colors.orangeAccent,
                    ),
                  ],
                ),

                if (habits.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Este mes por hábito',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...thisMonth.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.habit.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Text(
                            '${item.monthCount} días',
                            style: TextStyle(
                              color: gradient.colors.last,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(gradientControllerProvider);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tus estadísticas',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _StatColumn(label: 'Días', value: '$streak'),
              _StatColumn(label: 'Tareas', value: '$tasks'),
              _StatColumn(label: 'Seguidores', value: '$followers'),
              _StatColumn(label: 'Minutos', value: '$minutes'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppColors.blueGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: ElevatedButton.icon(
                onPressed: () => _showBreakdown(context, ref),
                icon:
                    const Icon(Icons.auto_awesome, size: 16, color: Colors.white),
                label: const Text(
                  'Ver un desglose',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BreakdownTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final LinearGradient gradient;

  const _BreakdownTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShaderMask(
              shaderCallback: (bounds) =>
                  gradient.createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  const _StatColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Heatmap Card ─────────────────────────────────────────────────────────────

class _HeatmapCard extends ConsumerWidget {
  final List<Habit> habits;

  const _HeatmapCard({required this.habits});

  /// Builds a map of 'yyyy-MM-dd' → completion level (0–3) for the current month.
  Map<String, int> _buildHeatmapData() {
    final now = DateTime.now();
    final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);

    // Count how many habits were completed each day this month
    final Map<String, int> counts = {};
    for (final habit in habits) {
      for (final key in habit.completedDates.keys) {
        try {
          final d = DateTime.parse(key);
          if (d.year == now.year && d.month == now.month) {
            final normalized =
                '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
            counts[normalized] = (counts[normalized] ?? 0) + 1;
          }
        } catch (_) {}
      }
    }

    // Normalise to 0–3 levels
    final total = habits.length;
    final Map<String, int> levels = {};
    for (int day = 1; day <= daysInMonth; day++) {
      final key =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
      final count = counts[key] ?? 0;
      if (count == 0) {
        levels[key] = 0;
      } else if (total == 0) {
        levels[key] = 1;
      } else {
        final ratio = count / total;
        if (ratio <= 0.33) {
          levels[key] = 1;
        } else if (ratio <= 0.66) {
          levels[key] = 2;
        } else {
          levels[key] = 3;
        }
      }
    }
    return levels;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(gradientControllerProvider);

    final now = DateTime.now();
    final monthName = _monthName(now.month);
    final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
    // Weekday of the 1st (1=Mon … 7=Sun in Dart), convert to 0-based Sunday-first
    final firstWeekday = DateTime(now.year, now.month, 1).weekday % 7;

    final heatmapData = _buildHeatmapData();
    final color1 = AppColors.blueGradient.colors.first;
    final color2 = AppColors.blueGradient.colors.last;

    // Total cells = leading empty + days
    final totalCells = firstWeekday + daysInMonth;
    // Round up to full weeks
    final rows = (totalCells / 7).ceil();
    final gridCells = rows * 7;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month label at top
          Text(
            monthName,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 12),
          // Day-of-week headers
          Row(
            children: const ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb']
                .map(
                  (d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.black38,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          // Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
            ),
            itemCount: gridCells,
            itemBuilder: (context, index) {
              final dayNumber = index - firstWeekday + 1;
              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const SizedBox();
              }
              final key =
                  '${now.year}-${now.month.toString().padLeft(2, '0')}-${dayNumber.toString().padLeft(2, '0')}';
              final level = heatmapData[key] ?? 0;
              final isFuture = dayNumber > now.day;
              final isToday = dayNumber == now.day;

              Color cellColor;
              if (isFuture) {
                cellColor = const Color(0xFFF0F0F0);
              } else if (level == 0) {
                cellColor = const Color(0xFFE0E0E0);
              } else {
                cellColor = Color.lerp(color1, color2, level / 3.0)!;
              }

              return Container(
                decoration: BoxDecoration(
                  color: cellColor,
                  borderRadius: BorderRadius.circular(6),
                  border: isToday
                      ? Border.all(color: Colors.black45, width: 1.5)
                      : null,
                ),
                child: Center(
                  child: Text(
                    '$dayNumber',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight:
                          isToday ? FontWeight.bold : FontWeight.normal,
                      color: level > 0 && !isFuture
                          ? Colors.white.withOpacity(0.9)
                          : Colors.black38,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text('Menos',
                  style: TextStyle(fontSize: 10, color: Colors.black38)),
              const SizedBox(width: 4),
              for (int i = 0; i <= 3; i++)
                Container(
                  width: 14,
                  height: 14,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: i == 0
                        ? const Color(0xFFE0E0E0)
                        : Color.lerp(color1, color2, i / 3.0)!,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              const SizedBox(width: 4),
              const Text('Más',
                  style: TextStyle(fontSize: 10, color: Colors.black38)),
            ],
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      '',
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return months[month];
  }
}

// ── Habits Card ──────────────────────────────────────────────────────────────

class _HabitsCard extends StatelessWidget {
  final List<Habit> habits;
  const _HabitsCard({required this.habits});

  @override
  Widget build(BuildContext context) {
    if (habits.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tus hábitos',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 16),
          ...habits.map((habit) => _HabitBar(habit: habit)),
        ],
      ),
    );
  }
}

class _HabitBar extends StatelessWidget {
  final Habit habit;
  const _HabitBar({required this.habit});

  @override
  Widget build(BuildContext context) {
    // Use calculatedStreak vs longestStreak; fall back gracefully
    final current = habit.calculatedStreak > 0
        ? habit.calculatedStreak
        : habit.currentStreak;
    final longest = habit.longestStreak > 0 ? habit.longestStreak : 1;
    final progress = (current / longest).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  habit.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              Text(
                '$current / $longest días',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black45,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 14,
              child: Stack(
                children: [
                  // Track
                  Container(
                    width: double.infinity,
                    color: const Color(0xFFE0E0E0),
                  ),
                  // Fill with gradient
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.blueGradient,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryStatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _HistoryStatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white54),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _InteractiveStatsChart extends StatefulWidget {
  final List<Habit> habits;
  final List<DateTime> followerDates;
  final Map<String, int> minutesLog;

  const _InteractiveStatsChart({
    required this.habits,
    required this.followerDates,
    required this.minutesLog,
  });

  @override
  State<_InteractiveStatsChart> createState() => _InteractiveStatsChartState();
}

class _InteractiveStatsChartState extends State<_InteractiveStatsChart> {
  int _selectedTab = 0; // 0 = Tareas, 1 = Seguidores, 2 = Minutos

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final List<double> values = [];
    final List<String> labels = [];

    // Generate last 14 days data
    for (int i = 13; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final dateKey = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
      
      // Format short label (e.g. "18")
      labels.add('${day.day}');

      if (_selectedTab == 0) {
        // Tareas
        int count = 0;
        for (final h in widget.habits) {
          if (h.completedDates.containsKey(dateKey)) {
            count++;
          }
        }
        values.add(count.toDouble());
      } else if (_selectedTab == 1) {
        // Seguidores
        final count = widget.followerDates.where((fd) {
          return fd.year == day.year && fd.month == day.month && fd.day == day.day;
        }).length;
        values.add(count.toDouble());
      } else {
        // Minutos
        values.add((widget.minutesLog[dateKey] ?? 0).toDouble());
      }
    }

    // Build spots
    final List<FlSpot> spots = [];
    for (int i = 0; i < values.length; i++) {
      spots.add(FlSpot(i.toDouble(), values[i]));
    }

    // Find max Y to set bounds nicely
    double maxY = values.fold(0.0, (prev, element) => element > prev ? element : prev);
    if (maxY < 4) maxY = 4; // safe minimum height

    final gradient = AppColors.blueGradient;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tab selector
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tendencia (últimos 14 días)',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Row(
              children: [
                _TabButton(
                  label: 'Tareas',
                  isSelected: _selectedTab == 0,
                  onTap: () => setState(() => _selectedTab = 0),
                ),
                const SizedBox(width: 6),
                _TabButton(
                  label: 'Segs',
                  isSelected: _selectedTab == 1,
                  onTap: () => setState(() => _selectedTab = 1),
                ),
                const SizedBox(width: 6),
                _TabButton(
                  label: 'Mins',
                  isSelected: _selectedTab == 2,
                  onTap: () => setState(() => _selectedTab = 2),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        
        // Chart area
        SizedBox(
          height: 160,
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: maxY,
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 22,
                    interval: 3, // Show label every 3 days to avoid crowding
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx >= 0 && idx < labels.length) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 4,
                          child: Text(
                            labels[idx],
                            style: const TextStyle(
                              color: Colors.white30,
                              fontSize: 9,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 26,
                    interval: (maxY / 4).clamp(1.0, 100.0),
                    getTitlesWidget: (value, meta) {
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        space: 4,
                        child: Text(
                          '${value.toInt()}',
                          style: const TextStyle(
                            color: Colors.white30,
                            fontSize: 9,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  preventCurveOverShooting: true,
                  gradient: gradient,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        gradient.colors.first.withOpacity(0.2),
                        gradient.colors.last.withOpacity(0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF262626) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.white24 : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white54,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _InsightTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _InsightTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF262626),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
