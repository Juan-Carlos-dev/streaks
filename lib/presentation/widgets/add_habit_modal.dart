import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/habit.dart';
import '../providers/auth_providers.dart';
import '../providers/habit_providers.dart';
import '../providers/user_providers.dart';
import '../../core/utils/widget_utils.dart';

class AddHabitModal extends ConsumerStatefulWidget {
  const AddHabitModal({super.key});

  @override
  ConsumerState<AddHabitModal> createState() => _AddHabitModalState();
}

class _AddHabitModalState extends ConsumerState<AddHabitModal> {
  final _titleController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _selectedColor = '#0052FF';
  String _selectedIcon = 'fitness_center';
  final List<int> _selectedDays = [1, 2, 3, 4, 5, 6, 7];

  final List<String> _colors = AppColors.habitColors;

  final List<Map<String, dynamic>> _icons = [
    {'name': 'fitness_center', 'icon': Icons.fitness_center},
    {'name': 'book', 'icon': Icons.book},
    {'name': 'self_improvement', 'icon': Icons.self_improvement},
    {'name': 'edit_note', 'icon': Icons.edit_note},
    {'name': 'local_florist', 'icon': Icons.local_florist},
    {'name': 'directions_run', 'icon': Icons.directions_run},
    {'name': 'water_drop', 'icon': Icons.water_drop},
    {'name': 'bedtime', 'icon': Icons.bedtime},
    {'name': 'music_note', 'icon': Icons.music_note},
    {'name': 'code', 'icon': Icons.code},
    {'name': 'restaurant', 'icon': Icons.restaurant},
    {'name': 'brush', 'icon': Icons.brush},
    {'name': 'pets', 'icon': Icons.pets},
    {'name': 'shopping_cart', 'icon': Icons.shopping_cart},
    {'name': 'attach_money', 'icon': Icons.attach_money},
    {'name': 'school', 'icon': Icons.school},
    {'name': 'sports_basketball', 'icon': Icons.sports_basketball},
    {'name': 'favorite', 'icon': Icons.favorite},
    {'name': 'coffee', 'icon': Icons.coffee},
    {'name': 'flight', 'icon': Icons.flight},
    {'name': 'smartphone', 'icon': Icons.smartphone},
    {'name': 'cleaning_services', 'icon': Icons.cleaning_services},
    {'name': 'timer', 'icon': Icons.timer},
    {'name': 'local_bar', 'icon': Icons.local_bar},
    {'name': 'lightbulb', 'icon': Icons.lightbulb},
    {'name': 'sports_esports', 'icon': Icons.sports_esports},
    {'name': 'home', 'icon': Icons.home},
    {'name': 'translate', 'icon': Icons.translate},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _toggleDay(int day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        _selectedDays.remove(day);
      } else {
        _selectedDays.add(day);
      }
    });
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final uid = ref.read(authStateProvider).value;
      if (uid == null) return;

      final newHabit = Habit(
        id: const Uuid().v4(),
        userId: uid,
        title: _titleController.text.trim(),
        icon: _selectedIcon,
        color: _selectedColor,
        frequency: HabitFrequency(daysOfWeek: List<int>.from(_selectedDays)),
        isPrivateHabit: false,
        startDate: DateTime.now(),
      );

      ref.read(habitControllerProvider.notifier).createHabit(newHabit).then((_) async {
        // Sync with native home screen widget
        final user = ref.read(currentUserProvider).value;
        final habitsList = ref.read(habitListProvider).value;
        final globalStreak = ref.read(globalStreakProvider);
        if (user != null && habitsList != null) {
          await WidgetUtils.updateNativeWidget(
            user: user,
            habits: habitsList,
            globalStreak: globalStreak,
          );
        }

        if (mounted) Navigator.of(context).pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Nuevo hábito',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Nombre del hábito',
                ),
                autofocus: true,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Introduce un nombre' : null,
              ),
              const SizedBox(height: 20),

              // Icon selector
              const Text('Icono',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 8),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _icons.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final item = _icons[index];
                    final isSelected = _selectedIcon == item['name'];
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIcon = item['name']),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: isSelected ? AppColors.blueGradient : null,
                          color: isSelected ? null : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          item['icon'] as IconData,
                          color: isSelected ? Colors.white : Colors.grey,
                          size: 20,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Color selector
              const Text('Color',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 8),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _colors.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final color = _colors[index];
                    final isSelected = _selectedColor == color;
                    final c = AppColors.habitColorFromHex(color);
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = color),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 3.5)
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Day selector
              const Text('Días de la semana',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _dayChip('L', 1),
                  _dayChip('M', 2),
                  _dayChip('X', 3),
                  _dayChip('J', 4),
                  _dayChip('V', 5),
                  _dayChip('S', 6),
                  _dayChip('D', 7),
                ],
              ),

              const SizedBox(height: 28),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppColors.blueGradient,
                  borderRadius: const BorderRadius.all(Radius.circular(14)),
                ),
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    elevation: 0,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Crear hábito'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dayChip(String label, int day) {
    final isSelected = _selectedDays.contains(day);
    return GestureDetector(
      onTap: () => _toggleDay(day),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.blueGradient : null,
          color: isSelected ? null : AppColors.surfaceLight,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
