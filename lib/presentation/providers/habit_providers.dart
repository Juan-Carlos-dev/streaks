import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/habit_repository.dart';
import '../../data/repositories/habit_repository_impl.dart';
import '../../domain/entities/habit.dart';
import 'auth_providers.dart';

final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  return HabitRepositoryImpl(FirebaseFirestore.instance);
});

final habitListProvider = StreamProvider<List<Habit>>((ref) {
  final uid = ref.watch(authStateProvider).value;
  if (uid == null) return Stream.value([]);
  final repository = ref.watch(habitRepositoryProvider);
  return repository.getHabitsByUserId(uid);
});

final habitControllerProvider =
    StateNotifierProvider<HabitController, AsyncValue<void>>((ref) {
  return HabitController(ref.watch(habitRepositoryProvider));
});

class HabitController extends StateNotifier<AsyncValue<void>> {
  final HabitRepository _repository;

  HabitController(this._repository) : super(const AsyncData(null));

  Future<void> createHabit(Habit habit) async {
    state = const AsyncLoading();
    final result = await _repository.createHabit(habit);
    state = result.fold(
      (failure) => AsyncError(failure.message, StackTrace.current),
      (_) => const AsyncData(null),
    );
  }

  Future<void> updateHabit(Habit habit) async {
    state = const AsyncLoading();
    final result = await _repository.updateHabit(habit);
    state = result.fold(
      (failure) => AsyncError(failure.message, StackTrace.current),
      (_) => const AsyncData(null),
    );
  }

  Future<void> deleteHabit(String habitId) async {
    state = const AsyncLoading();
    final result = await _repository.deleteHabit(habitId);
    state = result.fold(
      (failure) => AsyncError(failure.message, StackTrace.current),
      (_) => const AsyncData(null),
    );
  }

  Future<void> completeHabit(String habitId) async {
    state = const AsyncLoading();
    final result = await _repository.completeHabit(habitId);
    state = result.fold(
      (failure) => AsyncError(failure.message, StackTrace.current),
      (_) => const AsyncData(null),
    );
  }
}
