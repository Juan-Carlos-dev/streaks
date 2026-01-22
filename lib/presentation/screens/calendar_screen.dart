import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/habit_providers.dart';
import '../widgets/add_habit_modal.dart';
import '../../domain/entities/habit.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  void _showAddHabitModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const AddHabitModal(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitListAsync = ref.watch(habitListProvider);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildCalendarHeader(),
                Expanded(
                  child: habitListAsync.when(
                    data: (habits) {
                      if (habits.isEmpty) {
                        return Center(
                          child: Text(
                            'No habits yet.\nAdd one to get started!',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        );
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.only(top: 20, left: 16, right: 16, bottom: 100),
                        itemCount: habits.length + 1, // +1 for header
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Bienvenido,',
                                    style: GoogleFonts.outfit(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'Juan Carlos', // TODO: Get from auth provider
                                    style: GoogleFonts.outfit(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          final habit = habits[index - 1];
                          return GestureDetector(
                            onLongPress: () => _showDeleteConfirmation(context, ref, habit),
                            child: _HabitTaskCard(habit: habit),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Center(child: Text('Error: $error')),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton(
                  onPressed: () => _showAddHabitModal(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0099FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    'Añadir habito',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, Habit habit) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar tarea'),
        content: Text('¿Estás seguro de que quieres eliminar "${habit.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              ref.read(habitControllerProvider.notifier).deleteHabit(habit.id);
              Navigator.of(ctx).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      color: Colors.black, // Or transparent
      child: Column(
        children: [
          Text(
            'DICIEMBRE',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildDayBubble('MAR', '9', false),
                const SizedBox(width: 12),
                _buildDayBubble('MIE', '10', true),
                const SizedBox(width: 12),
                _buildDayBubble('JUE', '11', true), // Design shows multiple selected? Or just blue ones.
                const SizedBox(width: 12),
                _buildDayBubble('VIE', '12', true),
                const SizedBox(width: 12),
                _buildDayBubble('SAB', '13', true),
                 const SizedBox(width: 12),
                _buildDayBubble('DOM', '14', true),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 2,
            width: 50,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildDayBubble(String dayName, String dayNum, bool isSelected) {
    return Container(
      width: 56,
      height: 80, // Portrait bubble
      decoration: BoxDecoration(
        gradient: isSelected
            ? const LinearGradient(
                colors: [Color(0xFF0099FF), Color(0xFF00C6FF)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              )
            : null,
        color: isSelected ? null : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: isSelected ? null : Border.all(color: Colors.transparent),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            dayName,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : const Color(0xFF0099FF),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Text(
              dayNum,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0099FF),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HabitTaskCard extends StatelessWidget {
  final Habit habit;

  const _HabitTaskCard({required this.habit});

  @override
  Widget build(BuildContext context) {
    Color habitColor;
    try {
      habitColor = Color(int.parse(habit.color.replaceAll('#', '0xFF')));
    } catch (e) {
      habitColor = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: habitColor,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.title,
                  style: GoogleFonts.outfit(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Ultima vez: Ayer a las 18:00', // Placeholder
                  style: GoogleFonts.outfit(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF0099FF),
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }
}
