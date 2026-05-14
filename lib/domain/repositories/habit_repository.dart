import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/habit.dart';

abstract class HabitRepository {
  Stream<List<Habit>> getHabitsByUserId(String userId);
  Stream<Habit?> getHabitStream(String habitId);
  Future<Either<Failure, void>> createHabit(Habit habit);
  Future<Either<Failure, void>> updateHabit(Habit habit);
  Future<Either<Failure, void>> deleteHabit(String habitId);
  Future<Either<Failure, void>> completeHabit(String habitId);
  Future<Either<Failure, void>> toggleHabitCompletion(String habitId, DateTime date);
}
