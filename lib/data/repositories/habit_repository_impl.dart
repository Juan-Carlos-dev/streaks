import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/habit.dart';
import '../../domain/repositories/habit_repository.dart';

class HabitRepositoryImpl implements HabitRepository {
  final FirebaseFirestore _firestore;

  HabitRepositoryImpl(this._firestore);

  @override
  Stream<List<Habit>> getHabitsByUserId(String userId) {
    return _firestore
        .collection('habits')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Habit.fromFirestore(doc)).toList();
    });
  }

  @override
  Stream<Habit?> getHabitStream(String habitId) {
    return _firestore
        .collection('habits')
        .doc(habitId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return Habit.fromFirestore(snapshot);
      }
      return null;
    });
  }

  @override
  Future<Either<Failure, void>> createHabit(Habit habit) async {
    try {
      await _firestore
          .collection('habits')
          .doc(habit.id)
          .set(habit.toFirestore());
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure('Error al crear el hábito'));
    }
  }

  @override
  Future<Either<Failure, void>> updateHabit(Habit habit) async {
    try {
      await _firestore
          .collection('habits')
          .doc(habit.id)
          .update(habit.toFirestore());
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure('Error al actualizar el hábito'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteHabit(String habitId) async {
    try {
      await _firestore.collection('habits').doc(habitId).delete();
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure('Error al eliminar el hábito'));
    }
  }

  @override
  Future<Either<Failure, void>> completeHabit(String habitId) async {
    try {
      await _firestore.collection('habits').doc(habitId).update({
        'currentStreak': FieldValue.increment(1),
      });
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure('Error al completar el hábito'));
    }
  }

  @override
  Future<Either<Failure, void>> toggleHabitCompletion(String habitId, DateTime date) async {
    try {
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      final habitRef = _firestore.collection('habits').doc(habitId);
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(habitRef);
        if (!snapshot.exists) return;
        
        final data = snapshot.data()!;
        final completedDates = Map<String, dynamic>.from(data['completedDates'] ?? {});
        
        if (completedDates.containsKey(dateKey)) {
          completedDates.remove(dateKey);
          transaction.update(habitRef, {
            'completedDates': completedDates,
            'currentStreak': FieldValue.increment(-1),
          });
        } else {
          completedDates[dateKey] = DateTime.now().toIso8601String();
          transaction.update(habitRef, {
            'completedDates': completedDates,
            'currentStreak': FieldValue.increment(1),
          });
        }
      });
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure('Error al actualizar el hábito'));
    }
  }
}
