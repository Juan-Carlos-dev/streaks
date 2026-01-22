import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user.dart' as domain;

// Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(FirebaseAuth.instance);
});

// Auth State Stream
final authStateProvider = StreamProvider<domain.User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges;
});

final userByIdProvider =
    FutureProvider.family<domain.User, String>((ref, userId) async {
  final repository = ref.watch(authRepositoryProvider);
  final result = await repository.getUserById(userId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (user) => user,
  );
});

// Login Controller
final loginControllerProvider =
    StateNotifierProvider.autoDispose<LoginController, AsyncValue<void>>((ref) {
  return LoginController(ref.watch(authRepositoryProvider));
});

class LoginController extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _authRepository;

  LoginController(this._authRepository) : super(const AsyncData(null));

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    final result = await _authRepository.signInWithEmailAndPassword(
        email: email, password: password);

    result.fold(
      (failure) => state = AsyncError(failure.message, StackTrace.current),
      (user) => state = const AsyncData(null),
    );
  }
}

// Register Controller
final registerControllerProvider =
    StateNotifierProvider.autoDispose<RegisterController, AsyncValue<void>>(
        (ref) {
  return RegisterController(ref.watch(authRepositoryProvider));
});

class RegisterController extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _authRepository;

  RegisterController(this._authRepository) : super(const AsyncData(null));

  Future<void> signUp(String email, String password) async {
    state = const AsyncLoading();
    final result = await _authRepository.signUpWithEmailAndPassword(
      email: email,
      password: password,
    );

    result.fold(
      (failure) => state = AsyncError(failure.message, StackTrace.current),
      (user) => state = const AsyncData(null),
    );
  }
}
