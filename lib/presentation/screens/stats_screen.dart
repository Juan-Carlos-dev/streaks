import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/habit.dart';
import '../providers/user_providers.dart';
import '../providers/habit_providers.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final habitsAsync = ref.watch(habitListProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const SizedBox(height: 24),

                      // ── Streak hero ──────────────────────────────────────────────
                      userAsync.when(
                        data: (user) {
                          final streak = user?.stats.currentGlobalStreak ?? 0;
                          final name = user?.username ?? '';
                          return _StreakHero(streak: streak, username: name);
                        },
                        loading: () => const SizedBox(
                          height: 120,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (_, __) => const SizedBox.shrink(),
                      ),

                      const SizedBox(height: 28),

                      // ── Cards Container ──────────────────────────────────────────
                      Expanded(
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFFF5F5F5), // Light grey background
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                          child: Column(
                            children: [
                              // Stats card
                              userAsync.when(
                                data: (user) {
                                  final stats = user?.stats;
                                  return _StatsCard(
                                    streak: stats?.currentGlobalStreak ?? 0,
                                    tasks: stats?.postsCount ?? 0,
                                    followers: 112,
                                    minutes: stats?.totalMinutes ?? 0,
                                  );
                                },
                                loading: () => const SizedBox.shrink(),
                                error: (_, __) => const SizedBox.shrink(),
                              ),

                              const SizedBox(height: 16),

                              // Heatmap card
                              const _HeatmapCard(),

                              const SizedBox(height: 16),

                              // Habits card
                              habitsAsync.when(
                                data: (habits) => _HabitsCard(habits: habits),
                                loading: () => const SizedBox.shrink(),
                                error: (_, __) => const SizedBox.shrink(),
                              ),

                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Streak Hero ─────────────────────────────────────────────────────────────

class _StreakHero extends StatelessWidget {
  final int streak;
  final String username;

  const _StreakHero({required this.streak, required this.username});

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
    // Show last 4 completed days (check marks) + next 3 upcoming (numbered)
    const completedCount = 4;
    const upcomingCount = 3;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Completed days — blue circle with check
        for (int i = 0; i < completedCount; i++)
          const _DayCircle(
            completed: true,
            label: '',
          ),
        // Upcoming days — grey circle with next streak number
        for (int i = 1; i <= upcomingCount; i++)
          _DayCircle(
            completed: false,
            label: '${streak + i}',
          ),
      ],
    );
  }
}

class _DayCircle extends ConsumerWidget {
  final bool completed;
  final String label;
  const _DayCircle({required this.completed, required this.label});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(gradientControllerProvider);
    
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

class _StatsCard extends StatelessWidget {
  final int streak;
  final int tasks;
  final int followers;
  final int minutes;

  const _StatsCard({
    required this.streak,
    required this.tasks,
    required this.followers,
    required this.minutes,
  });

  @override
  Widget build(BuildContext context) {
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
          Align(
            alignment: Alignment.centerRight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppColors.blueGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.auto_awesome, size: 16, color: Colors.white),
                label: const Text(
                  'Ver un desglose',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                ),
              ),
            ),
          ),
        ],
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
  const _HeatmapCard();

  // Simulated heatmap: 4 rows × 8 columns = 32 cells (last partial row)
  static const List<int> _pattern = [
    3, 3, 2, 2, 3, 2, 3, 3,
    3, 3, 3, 2, 3, 1, 3, 2,
    2, 3, 3, 3, 2, 2, 3, 1,
    3, 3, 3, 2, 0, 0, 0, 0,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(gradientControllerProvider);
    
    final now = DateTime.now();
    final monthName = _monthName(now.month);

    final color1 = AppColors.blueGradient.colors.first;
    final color2 = AppColors.blueGradient.colors.last;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
            ),
            itemCount: _pattern.length,
            itemBuilder: (context, index) {
              final level = _pattern[index];
              final color = level == 0
                  ? Colors.transparent
                  : Color.lerp(color1, color2, level / 3.0)!;
              return Container(
                decoration: BoxDecoration(
                  color: level == 0 ? Colors.transparent : color,
                  borderRadius: BorderRadius.circular(8),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          Text(
            monthName,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
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
            'Tus habitos',
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
    final progress = habit.longestStreak > 0
        ? (habit.currentStreak / habit.longestStreak).clamp(0.0, 1.0)
        : (habit.currentStreak > 0 ? 1.0 : 0.3);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            habit.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
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
