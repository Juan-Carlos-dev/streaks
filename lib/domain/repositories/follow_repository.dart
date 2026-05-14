import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';

abstract class FollowRepository {
  Future<bool> isFollowing(String currentUid, String targetUid);
  Future<Either<Failure, void>> follow(String currentUid, String targetUid);
  Future<Either<Failure, void>> unfollow(String currentUid, String targetUid);
}