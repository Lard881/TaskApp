import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:planpal/domain/models/user.dart' as app;
import 'package:planpal/infrastructure/repositories/user_repository.dart';

/// Supabase-backed implementation of [UserRepository].
///
/// Maps between the app's [User] model and the `profiles` table.
class SupabaseProfileRepository implements UserRepository {
  SupabaseProfileRepository(this._client);

  final SupabaseClient _client;

  String get _uid => _client.auth.currentUser!.id;

  // ── Helpers ───────────────────────────────────────────────────────────────

  app.User _fromRow(Map<String, dynamic> row) => app.User(
        id: row['id'] as String,
        firstName: row['first_name'] as String? ?? '',
        lastName: row['last_name'] as String? ?? '',
        email: row['email'] as String? ?? '',
        role: row['role'] as String?,
        phone: row['phone'] as String?,
        avatarPath: row['avatar_url'] as String?,
      );

  Map<String, dynamic> _toRow(app.User user) => {
        'first_name': user.firstName,
        'last_name': user.lastName,
        'email': user.email,
        'role': user.role,
        'phone': user.phone,
        // avatar_url handled separately via storage
      };

  // ── Read ──────────────────────────────────────────────────────────────────

  @override
  Future<app.User?> getCurrentUser() async {
    final row = await _client
        .from('profiles')
        .select()
        .eq('id', _uid)
        .maybeSingle();
    if (row == null) return null;
    return _fromRow(row as Map<String, dynamic>);
  }

  @override
  Future<List<app.User>> getAll() async {
    final rows = await _client.from('profiles').select();
    return (rows as List)
        .map((r) => _fromRow(r as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<app.User?> getById(String id) async {
    final row = await _client
        .from('profiles')
        .select()
        .eq('id', id)
        .maybeSingle();
    if (row == null) return null;
    return _fromRow(row as Map<String, dynamic>);
  }

  // ── Write ─────────────────────────────────────────────────────────────────

  @override
  Future<void> save(app.User user) async {
    await _client
        .from('profiles')
        .update(_toRow(user))
        .eq('id', user.id);
  }

  /// Uploads [imageFile] to Supabase Storage and updates avatar_url.
  Future<String> uploadAvatar(File imageFile) async {
    final ext = imageFile.path.split('.').last;
    final path = 'avatars/$_uid.$ext';

    await _client.storage.from('avatars').upload(
          path,
          imageFile,
          fileOptions: const FileOptions(upsert: true),
        );

    final url = _client.storage.from('avatars').getPublicUrl(path);

    await _client
        .from('profiles')
        .update({'avatar_url': url})
        .eq('id', _uid);

    return url;
  }

  // ── Stream ────────────────────────────────────────────────────────────────

  @override
  Stream<app.User?> watchCurrentUser() {
    final controller = StreamController<app.User?>.broadcast();

    Future<void> emit() async {
      if (!controller.isClosed) controller.add(await getCurrentUser());
    }

    emit();

    final channel = _client
        .channel('profile_$_uid')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'profiles',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: _uid,
          ),
          callback: (_) => emit(),
        )
        .subscribe();

    controller.onCancel = () {
      _client.removeChannel(channel);
      controller.close();
    };

    return controller.stream;
  }
}
