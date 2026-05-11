import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../../data/repositories/user_repository_impl.dart';
import 'auth_providers.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(FirebaseFirestore.instance);
});

final currentUserProvider = StreamProvider<User?>((ref) {
  final authUid = ref.watch(authStateProvider).value;
  if (authUid == null) return Stream.value(null);
  return ref.watch(userRepositoryProvider).getUserStream(authUid);
});

final userByIdProvider =
    StreamProvider.family<User?, String>((ref, userId) {
  return ref.watch(userRepositoryProvider).getUserStream(userId);
});
