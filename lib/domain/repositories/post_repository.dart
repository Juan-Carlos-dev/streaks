import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/post.dart';

abstract class PostRepository {
  Stream<List<Post>> getFeedPosts();
  Stream<List<Post>> getUserPosts(String userId);
  Future<Either<Failure, void>> createPost({
    required Post post,
    required File imageFile,
  });
  Future<Either<Failure, void>> likePost(String postId, String userId);
}
