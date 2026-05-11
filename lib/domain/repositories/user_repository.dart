import '../entities/user.dart';

abstract class UserRepository {
  Stream<User?> getUserStream(String uid);
  Future<User?> getUserById(String uid);
  Future<void> createUser(User user);
  Future<void> updateUser(User user);
  Future<User?> getUserByUsername(String username);
}
