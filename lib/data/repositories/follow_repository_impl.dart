import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/repositories/follow_repository.dart';

class FollowRepositoryImpl implements FollowRepository {
  final FirebaseFirestore _firestore;
  FollowRepositoryImpl(this._firestore);

  @override
  Future<bool> isFollowing(String currentUid, String targetUid) async {
    final doc = await _firestore
        .collection('users')
        .doc(currentUid)
        .collection('following')
        .doc(targetUid)
        .get();
    return doc.exists;
  }

  @override
  Future<Either<Failure, void>> follow(String currentUid, String targetUid) async {
    try {
      final batch = _firestore.batch();

      batch.set(
        _firestore.collection('users').doc(currentUid).collection('following').doc(targetUid),
        {'uid': targetUid, 'createdAt': FieldValue.serverTimestamp()},
      );

      batch.set(
        _firestore.collection('users').doc(targetUid).collection('followers').doc(currentUid),
        {'uid': currentUid, 'createdAt': FieldValue.serverTimestamp()},
      );

      batch.set(
        _firestore.collection('users').doc(currentUid),
        {'stats': {'followingCount': FieldValue.increment(1)}},
        SetOptions(merge: true),
      );

      batch.set(
        _firestore.collection('users').doc(targetUid),
        {'stats': {'followersCount': FieldValue.increment(1)}},
        SetOptions(merge: true),
      );

      await batch.commit();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> unfollow(String currentUid, String targetUid) async {
    try {
      final batch = _firestore.batch();

      batch.delete(
        _firestore.collection('users').doc(currentUid).collection('following').doc(targetUid),
      );

      batch.delete(
        _firestore.collection('users').doc(targetUid).collection('followers').doc(currentUid),
      );

      batch.set(
        _firestore.collection('users').doc(currentUid),
        {'stats': {'followingCount': FieldValue.increment(-1)}},
        SetOptions(merge: true),
      );

      batch.set(
        _firestore.collection('users').doc(targetUid),
        {'stats': {'followersCount': FieldValue.increment(-1)}},
        SetOptions(merge: true),
      );

      await batch.commit();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}