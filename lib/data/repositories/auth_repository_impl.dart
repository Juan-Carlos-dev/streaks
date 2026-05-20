import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRepositoryImpl(this._firebaseAuth, this._firestore);

  @override
  String? get currentUserId => _firebaseAuth.currentUser?.uid;

  @override
  Stream<String?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((user) => user?.uid);
  }

  @override
  Future<Either<Failure, String>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user == null) {
        return const Left(AuthFailure('Usuario no encontrado'));
      }
      return Right(credential.user!.uid);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapAuthError(e.code)));
    } catch (e) {
      return const Left(ServerFailure('Error inesperado'));
    }
  }

  @override
  Future<Either<Failure, String>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        return const Left(AuthFailure('Error al crear la cuenta'));
      }

      final newUser = User(
        uid: firebaseUser.uid,
        email: email,
        username: username,
        bio: '',
        photoUrl: '',
        isPrivateProfile: false,
        profileGradientIndex: 0,
        stats: const UserStats(),
        widgetConfig: {},
      );

      await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .set(newUser.toFirestore());

      return Right(firebaseUser.uid);
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('---------- ERROR FIREBASE AUTH ----------');
      print('Código: ${e.code}');
      print('Mensaje: ${e.message}');
      print('-----------------------------------------');
      return Left(AuthFailure(_mapAuthError(e.code)));
    } catch (e) {
      print('---------- ERROR INESPERADO ----------');
      print(e.toString());
      print('--------------------------------------');
      return const Left(ServerFailure('Error inesperado'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _firebaseAuth.signOut();
      return const Right(null);
    } catch (e) {
      return const Left(AuthFailure('Error al cerrar sesión'));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return const Right(null);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapAuthError(e.code)));
    } catch (e) {
      return const Left(ServerFailure('Error inesperado'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return const Left(AuthFailure('No hay ningún usuario autenticado'));
      }
      final uid = user.uid;

      // 1. Delete habits belonging to the user
      final habitsSnapshot = await _firestore
          .collection('habits')
          .where('userId', isEqualTo: uid)
          .get();
      if (habitsSnapshot.docs.isNotEmpty) {
        final habitBatch = _firestore.batch();
        for (final doc in habitsSnapshot.docs) {
          habitBatch.delete(doc.reference);
        }
        await habitBatch.commit();
      }

      // 2. Delete posts belonging to the user
      final postsSnapshot = await _firestore
          .collection('posts')
          .where('userId', isEqualTo: uid)
          .get();
      if (postsSnapshot.docs.isNotEmpty) {
        final postBatch = _firestore.batch();
        for (final doc in postsSnapshot.docs) {
          postBatch.delete(doc.reference);
        }
        await postBatch.commit();
      }

      // 3. Delete user's following subcollection documents
      final followingSnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('following')
          .get();
      if (followingSnapshot.docs.isNotEmpty) {
        final followingBatch = _firestore.batch();
        for (final doc in followingSnapshot.docs) {
          followingBatch.delete(doc.reference);
        }
        await followingBatch.commit();
      }

      // 4. Delete user's followers subcollection documents
      final followersSnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('followers')
          .get();
      if (followersSnapshot.docs.isNotEmpty) {
        final followersBatch = _firestore.batch();
        for (final doc in followersSnapshot.docs) {
          followersBatch.delete(doc.reference);
        }
        await followersBatch.commit();
      }

      // 5. Delete user document from Firestore
      await _firestore.collection('users').doc(uid).delete();

      // 6. Delete Auth user
      await user.delete();

      return const Right(null);
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        return const Left(AuthFailure(
            'Por seguridad, debes cerrar sesión e iniciar sesión de nuevo antes de eliminar tu cuenta.'));
      }
      return Left(AuthFailure(e.message ?? 'Error al eliminar la cuenta'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No existe una cuenta con este correo';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con este correo';
      case 'weak-password':
        return 'La contraseña es demasiado débil';
      case 'invalid-email':
        return 'El correo electrónico no es válido';
      default:
        return 'Error de autenticación';
    }
  }
}
