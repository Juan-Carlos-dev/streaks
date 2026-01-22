import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/habit.dart';
import '../providers/auth_providers.dart';
import '../providers/habit_providers.dart';

class AddHabitModal extends ConsumerStatefulWidget {
  const AddHabitModal({super.key});

  @override
  ConsumerState<AddHabitModal> createState() => _AddHabitModalState();
}

class _AddHabitModalState extends ConsumerState<AddHabitModal> {
  final _titleController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _selectedColor = '#007BFF'; // Default to Neon Blue

  final List<String> _colors = [
    '#007BFF', // Blue
    '#FF3B30', // Red
    '#34C759', // Green
    '#FF9500', // Orange
    '#AF52DE', // Purple
    '#FF2D55', // Pink
  ];
  List<int> _selectedDays = [1, 2, 3, 4, 5, 6, 7]; // 1 = Monday, 7 = Sunday

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _toggleDay(int day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        if (_selectedDays.length > 1) {
          _selectedDays.remove(day);
        }
      } else {
        _selectedDays.add(day);
        _selectedDays.sort();
      }
    });
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDays.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one day')),
        );
        return;
      }

      final user = ref.read(authStateProvider).value;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in')),
        );
        return;
      }

      print('User: $user');
      print('User UID: ${user.uid}');

      final newHabit = Habit(
        id: const Uuid().v4(),
        userId: user.uid,
        title: _titleController.text.trim(),
        icon: 'fitness_center',
        color: _selectedColor,
        frequency: HabitFrequency(daysOfWeek: List.from(_selectedDays)),
        isPrivateHabit: false,
        startDate: DateTime.now(),
      );

      ref.read(habitControllerProvider.notifier).createHabit(newHabit);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(habitControllerProvider, (previous, next) {
      next.when(
        data: (_) {
          if (previous is AsyncLoading) {
            Navigator.of(context).pop();
          }
        },
        error: (error, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error creating habit: $error')),
          );
        },
        loading: () {
          // Could show a loading indicator on the button
        },
      );
    });

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'New Habit',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Habit Title',
                hintText: 'e.g., Morning Run',
              ),
              autofocus: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Color',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              children: _colors.map((color) {
                final isSelected = _selectedColor == color;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(int.parse(color.replaceAll('#', '0xFF'))),
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text(
              'Frequency',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                final day = index + 1;
                final isSelected = _selectedDays.contains(day);
                final dayName = ['M', 'T', 'W', 'T', 'F', 'S', 'S'][index];

                return GestureDetector(
                  onTap: () => _toggleDay(day),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.grey,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      dayName,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),
            Consumer(
              builder: (context, ref, child) {
                final habitState = ref.watch(habitControllerProvider);
                return ElevatedButton(
                  onPressed: habitState.isLoading ? null : _submit,
                  child: habitState.isLoading
                      ? const Text('Creating...')
                      : const Text('Create Habit'),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
