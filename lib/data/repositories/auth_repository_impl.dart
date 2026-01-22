import 'package:dartz/dartz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final firebase_auth.FirebaseAuth _firebaseAuth;

  AuthRepositoryImpl(this._firebaseAuth);

  @override
  Stream<User?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;

      try {
        final docRef = FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid);
        final doc = await docRef.get();

        if (doc.exists) {
          return User.fromJson(doc.data()!);
        }

        // Heal: Create missing doc
        final user = User(
          uid: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          username: firebaseUser.displayName ??
              firebaseUser.email?.split('@').first ??
              'User',
          photoUrl: firebaseUser.photoURL,
        );
        final userJson = user.toJson();
        userJson['stats'] = user.stats.toJson();
        await docRef.set(userJson);
        return user;
      } catch (e) {
        // Fallback or specific error handling (e.g., offline)
        print('Error in authStateChanges: $e');
        return User(
          uid: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          username: firebaseUser.displayName ?? 'User',
        );
      }
    });
  }

  @override
  Future<Either<Failure, User>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        return const Left(AuthFailure('User not found'));
      }

      // Check if user exists in Firestore, if not create it (healing for old users)
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      User user;
      if (userDoc.exists) {
        user = User.fromJson(userDoc.data()!);
      } else {
        // Create missing doc
        user = User(
          uid: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          username: email.split('@').first,
          photoUrl: '',
        );
        final userJson = user.toJson();
        userJson['stats'] = user.stats.toJson();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(userJson);
      }

      return Right(user);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(AuthFailure(e.message ?? 'Authentication failed'));
    } catch (e) {
      return const Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, User>> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        return const Left(AuthFailure('User creation failed'));
      }

      final user = User(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        username: email.split('@').first, // Use email part as initial username
        photoUrl: '',
        isPrivateProfile: false,
      );

      // Save user to Firestore
      final userJson = user.toJson();
      userJson['stats'] = user.stats.toJson();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(userJson);

      return Right(user);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(AuthFailure(e.message ?? 'Registration failed'));
    } catch (e) {
      return const Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _firebaseAuth.signOut();
      return const Right(null);
    } catch (e) {
      return const Left(AuthFailure('Failed to logout'));
    }
  }

  @override
  Future<Either<Failure, User>> getUserById(String userId) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('users').doc(userId);
      final doc = await docRef.get();

      if (doc.exists) {
        var user = User.fromJson(doc.data()!);

        // Auto-fix: If username is empty for current user, try to fix it
        final currentUser = _firebaseAuth.currentUser;
        if (currentUser != null &&
            user.uid == currentUser.uid &&
            user.username.isEmpty) {
          final newName = currentUser.email?.split('@').first ?? 'User';
          if (newName.isNotEmpty) {
            user = user.copyWith(username: newName);
            final userJson = user.toJson();
            userJson['stats'] = user.stats.toJson();
            await docRef.set(userJson, SetOptions(merge: true));
          }
        }
        return Right(user);
      } else {
        // Document missing.
        // Check if it's the current user (lazy healing)
        final currentUser = _firebaseAuth.currentUser;
        if (currentUser != null && currentUser.uid == userId) {
          final newUser = User(
            uid: currentUser.uid,
            email: currentUser.email ?? '',
            username: currentUser.displayName ??
                currentUser.email?.split('@').first ??
                'User',
            photoUrl: currentUser.photoURL,
          );
          final userJson = newUser.toJson();
          userJson['stats'] = newUser.stats.toJson();
          await docRef.set(userJson);
          return Right(newUser);
        }

        // For other users, return a meaningful placeholder instead of error
        // This handles "ghost" posts from deleted/old users
        return Right(User(
          uid: userId,
          email: '',
          username: 'Unknown User',
          photoUrl: null,
          isPrivateProfile: true,
        ));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
