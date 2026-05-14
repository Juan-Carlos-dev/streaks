import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/post.dart';
import '../../domain/entities/habit.dart';
import '../providers/feed_providers.dart';
import '../providers/auth_providers.dart';
import '../providers/habit_providers.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _captionController = TextEditingController();
  File? _imageFile;
  final _picker = ImagePicker();
  Habit? _selectedHabit;
  bool _isLoading = false;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  void _submit() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una imagen')),
      );
      return;
    }
    if (_selectedHabit == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un hábito')),
      );
      return;
    }

    final uid = ref.read(authStateProvider).value;
    if (uid == null) return;

    final newPost = Post(
      id: const Uuid().v4(),
      userId: uid,
      habitId: _selectedHabit!.id,
      imageUrl: '',
      caption: _captionController.text.trim(),
      likesCount: 0,
      habitStreakSnapshot: _selectedHabit!.calculatedStreak,
      timestamp: DateTime.now(),
    );

    setState(() => _isLoading = true);
    try {
      await ref.read(createPostControllerProvider.notifier).createPost(
            post: newPost,
            imageFile: _imageFile!,
          );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final habitsAsync = ref.watch(habitListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nueva publicación'),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 220,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  image: _imageFile != null
                      ? DecorationImage(
                          image: FileImage(_imageFile!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _imageFile == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo,
                              size: 48, color: Colors.grey[600]),
                          const SizedBox(height: 8),
                          const Text('Toca para añadir foto',
                              style:
                                  TextStyle(color: AppColors.textSecondary)),
                        ],
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 24),
            const Text('Hábito asociado',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            habitsAsync.when(
              data: (habits) {
                final today = DateTime.now();
                final dateKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
                
                final completedHabits = habits.where((h) => h.completedDates.containsKey(dateKey)).toList();

                if (completedHabits.isEmpty) {
                  return const Text('No tienes hábitos completados hoy para compartir',
                      style: TextStyle(color: AppColors.textHint));
                }
                
                // Validar que el hábito seleccionado sigue existiendo en la lista filtrada
                if (_selectedHabit != null && !completedHabits.any((h) => h.id == _selectedHabit!.id)) {
                  _selectedHabit = null;
                }

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<Habit>(
                      value: _selectedHabit,
                      isExpanded: true,
                      dropdownColor: AppColors.surface,
                      hint: const Text('Selecciona un hábito completado hoy',
                          style: TextStyle(color: AppColors.textHint)),
                      items: completedHabits.map((h) {
                        return DropdownMenuItem(
                          value: h,
                          child: Text(h.title,
                              style: const TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _selectedHabit = v),
                    ),
                  ),
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _captionController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Escribe una descripción...',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Compartir'),
            ),
          ],
        ),
      ),
    );
  }
}
