import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';

abstract class AuthRepository {
  Stream<String?> get authStateChanges;
  String? get currentUserId;
  Future<Either<Failure, String>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<Either<Failure, String>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
  });
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, void>> sendPasswordResetEmail({required String email});
  Future<Either<Failure, void>> deleteAccount();
  Future<bool> isUsernameAvailable(String username);
  Future<List<String>> getUsernameSuggestions(String username);
}
