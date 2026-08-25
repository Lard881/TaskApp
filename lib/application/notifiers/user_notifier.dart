import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planpal/application/providers/supabase_providers.dart';
import 'package:planpal/domain/models/user.dart';
import 'package:planpal/infrastructure/repositories/supabase_profile_repository.dart';
import 'package:planpal/infrastructure/repositories/user_repository.dart';

/// Manages the current user's profile state.
/// Backed by [SupabaseProfileRepository].
class UserNotifier extends AsyncNotifier<User?> {
  late final UserRepository _repo;

  @override
  Future<User?> build() async {
    _repo = ref.watch(userRepositoryProvider);

    // Live updates via Supabase Realtime
    _repo.watchCurrentUser().listen((user) {
      if (state is! AsyncLoading) state = AsyncData(user);
    });

    return _repo.getCurrentUser();
  }

  /// Persists updated profile fields.
  Future<void> updateProfile(User updated) async {
    await _repo.save(updated);
    state = AsyncData(updated);
  }

  /// Uploads a new avatar image to Supabase Storage and updates the profile.
  Future<void> updateAvatar(String filePath) async {
    final current = state.valueOrNull;
    if (current == null) return;

    if (_repo is SupabaseProfileRepository) {
      try {
        final url = await (_repo as SupabaseProfileRepository)
            .uploadAvatar(File(filePath));
        state = AsyncData(current.copyWith(avatarPath: url));
      } catch (_) {
        // Fallback to local path if upload fails
        state = AsyncData(current.copyWith(avatarPath: filePath));
      }
    } else {
      await _repo.save(current.copyWith(avatarPath: filePath));
      state = AsyncData(current.copyWith(avatarPath: filePath));
    }
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final currentUserProvider =
    AsyncNotifierProvider<UserNotifier, User?>(UserNotifier.new);

/// All users — for assignee pickers and contact search.
final allUsersProvider = FutureProvider<List<User>>((ref) async {
  final repo = ref.watch(userRepositoryProvider);
  return repo.getAll();
});

/// Single user by id — resolves assignee avatars in task rows.
final userByIdProvider =
    FutureProvider.family<User?, String>((ref, id) async {
  final repo = ref.watch(userRepositoryProvider);
  return repo.getById(id);
});
