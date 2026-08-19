import 'package:planpal/domain/models/user.dart';

/// Abstract contract for user persistence.
abstract class UserRepository {
  /// Returns the current (logged-in) user.
  /// In Phase 1 this is always the first seeded user.
  Future<User?> getCurrentUser();

  /// Returns all users (current user + mock contacts).
  Future<List<User>> getAll();

  /// Returns a single user by [id], or `null` if not found.
  Future<User?> getById(String id);

  /// Persists an updated user record.
  Future<void> save(User user);

  /// Emits the current user whenever it changes.
  Stream<User?> watchCurrentUser();
}
