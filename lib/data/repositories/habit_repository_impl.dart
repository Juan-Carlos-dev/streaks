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
      return snapshot.docs.map((doc) {
        return Habit.fromJson(doc.data());
      }).toList();
    });
  }

  @override
  Future<Either<Failure, void>> createHabit(Habit habit) async {
    try {
      print('Creating habit: ${habit.id}, userId: ${habit.userId}');
      final json = _convertHabitToJson(habit);
      await _firestore.collection('habits').doc(habit.id).set(json);
      print('Habit created successfully');
      return const Right(null);
    } catch (e) {
      print('Error creating habit: $e');
      return Left(ServerFailure('Failed to create habit: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateHabit(Habit habit) async {
    try {
      final json = _convertHabitToJson(habit);
      await _firestore.collection('habits').doc(habit.id).update(json);
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure('Failed to update habit'));
    }
  }

  Map<String, dynamic> _convertHabitToJson(Habit habit) {
    final json = habit.toJson();
    // Manually convert nested HabitFrequency if it wasn't converted automatically
    if (json['frequency'] is HabitFrequency) {
      json['frequency'] = (json['frequency'] as HabitFrequency).toJson();
    }
    return json;
  }

  @override
  Future<Either<Failure, void>> deleteHabit(String habitId) async {
    try {
      await _firestore.collection('habits').doc(habitId).delete();
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure('Failed to delete habit'));
    }
  }

  @override
  Future<Either<Failure, Habit>> getHabitById(String habitId) async {
    try {
      final doc = await _firestore.collection('habits').doc(habitId).get();
      if (doc.exists) {
        return Right(Habit.fromJson(doc.data()!));
      } else {
        return const Left(ServerFailure('Habit not found'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
