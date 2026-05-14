import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';

class PostRepositoryImpl implements PostRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  PostRepositoryImpl(this._firestore, this._storage);

  @override
  Stream<List<Post>> getFeedPosts() {
    return _firestore
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList();
    });
  }

  @override
  Stream<List<Post>> getUserPosts(String userId) {
    return _firestore
        .collection('posts')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final posts = snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList();
      posts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return posts;
    });
  }

  @override
  Future<Either<Failure, void>> createPost({
    required Post post,
    required File imageFile,
  }) async {
    try {
      final String imagePath =
          'posts/${post.userId}/${const Uuid().v4()}.jpg';
      final ref = _storage.ref().child(imagePath);
      await ref.putFile(imageFile);
      final String downloadUrl = await ref.getDownloadURL();

      final newPost = post.copyWith(imageUrl: downloadUrl);
      await _firestore
          .collection('posts')
          .doc(newPost.id)
          .set(newPost.toFirestore());

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> likePost(String postId, String userId) async {
    try {
      final postRef = _firestore.collection('posts').doc(postId);
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(postRef);
        if (!snapshot.exists) return;
        
        final likedBy = List<String>.from(snapshot.data()?['likedBy'] ?? []);
        if (likedBy.contains(userId)) {
          transaction.update(postRef, {
            'likedBy': FieldValue.arrayRemove([userId]),
            'likesCount': FieldValue.increment(-1),
          });
        } else {
          transaction.update(postRef, {
            'likedBy': FieldValue.arrayUnion([userId]),
            'likesCount': FieldValue.increment(1),
          });
        }
      });
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure('Error al dar like'));
    }
  }
}
