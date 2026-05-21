import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    FirebaseAuth.instance,
    FirebaseFirestore.instance,
  );
});

final authStateProvider = StreamProvider<String?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges;
});

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
      email: email,
      password: password,
    );
    result.fold(
      (failure) => state = AsyncError(failure.message, StackTrace.current),
      (_) => state = const AsyncData(null),
    );
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    state = const AsyncLoading();
    final result = await _authRepository.sendPasswordResetEmail(email: email);
    return result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncData(null);
        return true;
      },
    );
  }
}

final registerControllerProvider =
    StateNotifierProvider.autoDispose<RegisterController, AsyncValue<void>>(
        (ref) {
  return RegisterController(ref.watch(authRepositoryProvider));
});

class RegisterController extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _authRepository;

  RegisterController(this._authRepository) : super(const AsyncData(null));

  Future<void> signUp(String email, String password, String username) async {
    state = const AsyncLoading();
    final result = await _authRepository.signUpWithEmailAndPassword(
      email: email,
      password: password,
      username: username,
    );
    result.fold(
      (failure) => state = AsyncError(failure.message, StackTrace.current),
      (_) => state = const AsyncData(null),
    );
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  late final dynamic _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class UsernameCheckState {
  final String username;
  final bool isLoading;
  final bool? isAvailable;
  final List<String> suggestions;

  const UsernameCheckState({
    this.username = '',
    this.isLoading = false,
    this.isAvailable,
    this.suggestions = const [],
  });

  UsernameCheckState copyWith({
    String? username,
    bool? isLoading,
    bool? isAvailable,
    bool clearAvailability = false,
    List<String>? suggestions,
  }) {
    return UsernameCheckState(
      username: username ?? this.username,
      isLoading: isLoading ?? this.isLoading,
      isAvailable: clearAvailability ? null : (isAvailable ?? this.isAvailable),
      suggestions: suggestions ?? this.suggestions,
    );
  }

  UsernameCheckState.initial()
      : username = '',
        isLoading = false,
        isAvailable = null,
        suggestions = const [];
}

class UsernameCheckNotifier extends StateNotifier<UsernameCheckState> {
  final AuthRepository _authRepository;
  Timer? _debounceTimer;

  UsernameCheckNotifier(this._authRepository) : super(UsernameCheckState.initial());

  void checkUsername(String username) {
    _debounceTimer?.cancel();
    final clean = username.trim();
    if (clean.length < 3) {
      state = UsernameCheckState.initial().copyWith(username: clean);
      return;
    }

    if (clean == state.username && state.isAvailable == true && !state.isLoading) {
      return;
    }

    state = state.copyWith(
      username: clean,
      isLoading: true,
      clearAvailability: true,
      suggestions: const [],
    );

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      final available = await _authRepository.isUsernameAvailable(clean);
      List<String> suggestions = const [];
      if (!available) {
        suggestions = await _authRepository.getUsernameSuggestions(clean);
      }

      if (state.username == clean) {
        state = state.copyWith(
          isLoading: false,
          isAvailable: available,
          suggestions: suggestions,
        );
      }
    });
  }

  void selectSuggestion(String suggestion) {
    _debounceTimer?.cancel();
    state = UsernameCheckState(
      username: suggestion,
      isLoading: false,
      isAvailable: true,
      suggestions: const [],
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

final usernameCheckProvider =
    StateNotifierProvider.autoDispose<UsernameCheckNotifier, UsernameCheckState>((ref) {
  return UsernameCheckNotifier(ref.watch(authRepositoryProvider));
});
