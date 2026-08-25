import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:planpal/application/notifiers/workspace_notifier.dart';
import 'package:planpal/infrastructure/repositories/auth_repository.dart';
import 'package:planpal/infrastructure/repositories/conversation_repository.dart';
import 'package:planpal/infrastructure/repositories/preferences_repository.dart';
import 'package:planpal/infrastructure/repositories/supabase_auth_repository.dart';
import 'package:planpal/infrastructure/repositories/supabase_conversation_repository.dart';
import 'package:planpal/infrastructure/repositories/supabase_preferences_repository.dart';
import 'package:planpal/infrastructure/repositories/supabase_profile_repository.dart';
import 'package:planpal/infrastructure/repositories/supabase_task_repository.dart';
import 'package:planpal/infrastructure/repositories/task_repository.dart';
import 'package:planpal/infrastructure/repositories/user_repository.dart';

/// The global Supabase client — initialised in main.dart.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// ── Auth ──────────────────────────────────────────────────────────────────────

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseAuthRepository(client);
});

// ── Profile ───────────────────────────────────────────────────────────────────

final profileRepositoryProvider = Provider<SupabaseProfileRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseProfileRepository(client);
});

/// Satisfies the UserRepository abstract type used by UserNotifier.
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return ref.watch(profileRepositoryProvider);
});

// ── Tasks ─────────────────────────────────────────────────────────────────────

/// Task repository scoped to the active workspace.
/// Re-creates itself when the active workspace changes.
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final workspaceId = ref.watch(activeWorkspaceIdProvider) ?? '';
  return SupabaseTaskRepository(client, workspaceId);
});

// ── Conversations ─────────────────────────────────────────────────────────────

/// Conversation repository scoped to the active workspace.
final conversationRepositoryProvider = Provider<ConversationRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final workspaceId = ref.watch(activeWorkspaceIdProvider) ?? '';
  return SupabaseConversationRepository(client, workspaceId);
});

// ── Preferences ───────────────────────────────────────────────────────────────

final preferencesRepositoryProvider = Provider<PreferencesRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabasePreferencesRepository(client);
});
