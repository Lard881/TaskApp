import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planpal/application/providers/hive_providers.dart';
import 'package:planpal/domain/models/user.dart';
import 'package:planpal/infrastructure/repositories/user_repository.dart';

/// Manages the current user's profile state.
class UserNotifier extends AsyncNotifier<User?> {
  late final UserRepository _repo;

  @override
  Future<User?> build() async {
    _repo = ref.watch(userRepositoryProvider);

    // Keep in sync with Hive stream
    _repo.watchCurrentUser().listen((user) {
      if (state is! AsyncLoading) {
        state = AsyncData(user);
      }
    });

    return _repo.getCurrentUser();
  }

  /// Persists updated profile fields for the current user.
  Future<void> updateProfile(User updated) async {
    await _repo.save(updated);
  }

  /// Updates only the avatar path for the current user.
  Future<void> updateAvatar(String path) async {
    final current = state.valueOrNull;
    if (current == null) return;
    await _repo.save(current.copyWith(avatarPath: path));
  }
}

/// The current user provider.
final currentUserProvider =
    AsyncNotifierProvider<UserNotifier, User?>(UserNotifier.new);

/// All users (current + contacts) — used for assignee pickers, etc.
final allUsersProvider = FutureProvider<List<User>>((ref) async {
  final repo = ref.watch(userRepositoryProvider);
  return repo.getAll();
});

/// Looks up a single user by id — used by task list items to resolve assignees.
final userByIdProvider =
    FutureProvider.family<User?, String>((ref, id) async {
  final repo = ref.watch(userRepositoryProvider);
  return repo.getById(id);
});
