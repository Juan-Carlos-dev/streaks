import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
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

final gradientControllerProvider = Provider<List<String>>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.when(
    data: (user) {
      if (user != null && user.customGradient.length == 2) {
        AppColors.blueGradient = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(int.parse(user.customGradient[0].replaceAll('#', '0xFF'))),
            Color(int.parse(user.customGradient[1].replaceAll('#', '0xFF'))),
          ],
        );
        return user.customGradient;
      } else {
        AppColors.blueGradient = const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF3D8EF0), Color(0xFF64B5F6)],
        );
        return [];
      }
    },
    loading: () => [],
    error: (_, __) => [],
  );
});
