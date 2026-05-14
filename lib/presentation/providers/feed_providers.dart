import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../domain/repositories/post_repository.dart';
import '../../data/repositories/post_repository_impl.dart';
import '../../domain/entities/post.dart';
import 'habit_providers.dart' as import_habit_providers;

final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepositoryImpl(
    FirebaseFirestore.instance,
    FirebaseStorage.instanceFor(bucket: 'streaks-cc514.firebasestorage.app'),
  );
});

final feedStreamProvider = StreamProvider<List<Post>>((ref) {
  final repository = ref.watch(postRepositoryProvider);
  return repository.getFeedPosts();
});

final groupsFeedProvider = FutureProvider<List<Post>>((ref) async {
  final allPosts = await ref.watch(feedStreamProvider.future);
  // Get user's habits
  final myHabitsAsync = ref.watch(import_habit_providers.habitListProvider);
  if (myHabitsAsync.value == null) return [];
  
  final myHabitTitles = myHabitsAsync.value!.map((h) => h.title.trim().toLowerCase()).toSet();
  if (myHabitTitles.isEmpty) return [];

  List<Post> filtered = [];
  for (final post in allPosts) {
    try {
      final habitDoc = await FirebaseFirestore.instance.collection('habits').doc(post.habitId).get();
      if (habitDoc.exists) {
        final title = (habitDoc.data()?['title'] as String?)?.trim().toLowerCase() ?? '';
        if (myHabitTitles.contains(title)) {
          filtered.add(post);
        }
      }
    } catch (_) {}
  }
  return filtered;
});

final userPostsProvider =
    StreamProvider.family<List<Post>, String>((ref, userId) {
  final repository = ref.watch(postRepositoryProvider);
  return repository.getUserPosts(userId);
});

final createPostControllerProvider =
    StateNotifierProvider<CreatePostController, AsyncValue<void>>((ref) {
  return CreatePostController(ref.watch(postRepositoryProvider));
});

class CreatePostController extends StateNotifier<AsyncValue<void>> {
  final PostRepository _repository;

  CreatePostController(this._repository) : super(const AsyncData(null));

  Future<void> createPost({
    required Post post,
    required File imageFile,
  }) async {
    state = const AsyncLoading();
    final result =
        await _repository.createPost(post: post, imageFile: imageFile);
    state = result.fold(
      (failure) => AsyncError(failure.message, StackTrace.current),
      (_) => const AsyncData(null),
    );
  }
}

final likePostControllerProvider = Provider((ref) {
  return LikePostController(ref.watch(postRepositoryProvider));
});

class LikePostController {
  final PostRepository _repository;
  LikePostController(this._repository);

  Future<void> likePost(String postId, String userId) async {
    await _repository.likePost(postId, userId);
  }
}
