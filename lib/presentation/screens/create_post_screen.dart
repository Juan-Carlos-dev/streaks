import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../providers/feed_providers.dart';
import '../providers/auth_providers.dart';
import '../providers/habit_providers.dart';
import '../../domain/entities/post.dart';
import '../../domain/entities/habit.dart';

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
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _submit() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image')),
      );
      return;
    }
    if (_selectedHabit == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a habit')),
      );
      return;
    }

    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    final newPost = Post(
      id: const Uuid().v4(),
      userId: user.uid,
      habitId: _selectedHabit!.id,
      imageUrl: '', // Will be filled by repository
      caption: _captionController.text.trim(),
      likesCount: 0,
      habitStreakSnapshot: _selectedHabit!.currentStreak,
      timestamp: DateTime.now(),
    );

    setState(() => _isLoading = true);
    
    try {
      await ref.read(createPostControllerProvider.notifier).createPost(
        post: newPost,
        imageFile: _imageFile!,
      );
      if (mounted) context.pop();
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
      appBar: AppBar(title: const Text('New Post')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                  image: _imageFile != null
                      ? DecorationImage(
                          image: FileImage(_imageFile!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _imageFile == null
                    ? const Icon(Icons.add_a_photo, size: 50, color: Colors.grey)
                    : null,
              ),
            ),
            const SizedBox(height: 24),
            Text('Select Habit', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            habitsAsync.when(
              data: (habits) {
                if (habits.isEmpty) return const Text('No habits found');
                return DropdownButtonFormField<Habit>(
                  initialValue: _selectedHabit,
                  items: habits.map((habit) {
                    return DropdownMenuItem(
                      value: habit,
                      child: Text(habit.title),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedHabit = value),
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  hint: const Text('Choose a habit'),
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Error loading habits: $e'),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _captionController,
              decoration: const InputDecoration(
                labelText: 'Caption',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Share'),
            ),
          ],
        ),
      ),
    );
  }
}
