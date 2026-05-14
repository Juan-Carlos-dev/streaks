import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../domain/repositories/post_repository.dart';
import '../../data/repositories/post_repository_impl.dart';
import '../../domain/entities/post.dart';
import 'habit_providers.dart' as import_habit_providers;
import 'user_providers.dart' as import_user_providers;

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

// List of UIDs the current user is following
final followingUidsProvider = StreamProvider<List<String>>((ref) {
  final currentUid = ref.watch(import_user_providers.currentUserProvider).value?.uid;
  if (currentUid == null) return Stream.value([]);
  return FirebaseFirestore.instance
      .collection('users')
      .doc(currentUid)
      .collection('following')
      .snapshots()
      .map((snap) => snap.docs.map((d) => d.id).toList());
});

// Posts only from followed users
final followingFeedProvider = StreamProvider<List<Post>>((ref) {
  final followedUids = ref.watch(followingUidsProvider).value;
  if (followedUids == null || followedUids.isEmpty) return Stream.value([]);

  final allPostsStream = ref.watch(postRepositoryProvider).getFeedPosts();
  return allPostsStream.map((posts) => posts.where((p) => followedUids.contains(p.userId)).toList());
});

// Suggested users (any user except self, not already followed)
final suggestedUsersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final currentUid = ref.watch(import_user_providers.currentUserProvider).value?.uid;
  final followedUids = ref.watch(followingUidsProvider).value ?? [];
  if (currentUid == null) return [];

  final snap = await FirebaseFirestore.instance.collection('users').limit(20).get();
  return snap.docs
      .where((d) => d.id != currentUid && !followedUids.contains(d.id))
      .map((d) => {'uid': d.id, ...d.data()})
      .toList();
});

final groupsFeedProvider = FutureProvider.family<List<Post>, String?>((ref, selectedGroup) async {
  final allPosts = await ref.watch(feedStreamProvider.future);
  
  final currentUserAsync = ref.watch(import_user_providers.currentUserProvider);
  final currentUser = currentUserAsync.value;
  if (currentUser == null) return [];
  
  final myHabitTitles = currentUser.followedGroups.map((g) => g.trim().toLowerCase()).toSet();
  if (myHabitTitles.isEmpty) return [];

  final filterTitle = selectedGroup?.trim().toLowerCase();

  List<Post> filtered = [];
  for (final post in allPosts) {
    try {
      final habitDoc = await FirebaseFirestore.instance.collection('habits').doc(post.habitId).get();
      if (habitDoc.exists) {
        final title = (habitDoc.data()?['title'] as String?)?.trim().toLowerCase() ?? '';
        if (filterTitle != null) {
          if (title == filterTitle) {
            filtered.add(post);
          }
        } else {
          if (myHabitTitles.contains(title)) {
            filtered.add(post);
          }
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
