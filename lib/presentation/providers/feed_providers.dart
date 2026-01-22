import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../domain/repositories/post_repository.dart';
import '../../data/repositories/post_repository_impl.dart';
import '../../domain/entities/post.dart';

final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepositoryImpl(
    FirebaseFirestore.instance,
    FirebaseStorage.instance,
  );
});

final feedStreamProvider = StreamProvider<List<Post>>((ref) {
  final repository = ref.watch(postRepositoryProvider);
  return repository.getFeedPosts();
});

final createPostControllerProvider = StateNotifierProvider<CreatePostController, AsyncValue<void>>((ref) {
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
    final result = await _repository.createPost(post: post, imageFile: imageFile);
    state = result.fold(
      (failure) => AsyncError(failure.message, StackTrace.current),
      (_) => const AsyncData(null),
    );
  }
}
