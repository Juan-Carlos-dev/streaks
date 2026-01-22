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
        .limit(50) // Limit to recent 50 posts for now
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Post.fromJson(doc.data());
      }).toList();
    });
  }

  @override
  Future<Either<Failure, void>> createPost({
    required Post post,
    required File imageFile,
  }) async {
    try {
      // 1. Upload Image to Storage
      print('Starting image upload for post ${post.id}...');
      print('Using Storage Bucket: ${_storage.app.options.storageBucket}');
      final String imagePath = 'posts/${post.userId}/${const Uuid().v4()}.jpg';
      final ref = _storage.ref().child(imagePath);

      final metadata = SettableMetadata(contentType: 'image/jpeg');
      await ref.putFile(imageFile, metadata);
      print('Image uploaded. Getting download URL...');

      final String downloadUrl = await ref.getDownloadURL();
      print('Download URL retrieved: $downloadUrl');

      // 2. Update Post with Image URL
      final newPost = post.copyWith(imageUrl: downloadUrl);

      // 3. Save Post to Firestore
      await _firestore
          .collection('posts')
          .doc(newPost.id)
          .set(newPost.toJson());

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
