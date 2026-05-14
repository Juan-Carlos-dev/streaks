import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/repositories/follow_repository_impl.dart';
import '../../domain/repositories/follow_repository.dart';
import 'auth_providers.dart';

final followRepositoryProvider = Provider<FollowRepository>((ref) {
  return FollowRepositoryImpl(FirebaseFirestore.instance);
});

final isFollowingProvider = StreamProvider.family<bool, String>((ref, targetUid) {
  final currentUid = ref.watch(authStateProvider).value;
  if (currentUid == null) return Stream.value(false);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(currentUid)
      .collection('following')
      .doc(targetUid)
      .snapshots()
      .map((doc) => doc.exists);
});

final followControllerProvider =
    StateNotifierProvider.family<FollowController, AsyncValue<void>, String>(
        (ref, targetUid) {
  return FollowController(ref, targetUid);
});

final followersCountProvider = StreamProvider.family<int, String>((ref, uid) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((doc) {
        if (!doc.exists) return 0;
        final data = doc.data()!;
        final stats = data['stats'];
        if (stats == null) return 0;
        if (stats is Map) return (stats['followersCount'] ?? 0) as int;
        return 0;
      });
});

final followingCountProvider = StreamProvider.family<int, String>((ref, uid) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((doc) {
        if (!doc.exists) return 0;
        final data = doc.data()!;
        final stats = data['stats'];
        if (stats == null) return 0;
        if (stats is Map) return (stats['followingCount'] ?? 0) as int;
        return 0;
      });
});

class FollowController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  final String _targetUid;

  FollowController(this._ref, this._targetUid) : super(const AsyncData(null));

  Future<void> toggle() async {
    final currentUid = _ref.read(authStateProvider).value;
    if (currentUid == null) return;

    state = const AsyncLoading();
    final repo = _ref.read(followRepositoryProvider);
    final isFollowing = await repo.isFollowing(currentUid, _targetUid);

    final result = isFollowing
        ? await repo.unfollow(currentUid, _targetUid)
        : await repo.follow(currentUid, _targetUid);

    state = result.fold(
      (failure) => AsyncError(failure.message, StackTrace.current),
      (_) => const AsyncData(null),
    );
  }
}