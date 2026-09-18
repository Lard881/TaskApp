import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planpal/application/notifiers/workspace_notifier.dart';
import 'package:planpal/infrastructure/repositories/api_auth_repository.dart';
import 'package:planpal/infrastructure/repositories/api_conversation_repository.dart';
import 'package:planpal/infrastructure/repositories/api_preferences_repository.dart';
import 'package:planpal/infrastructure/repositories/api_profile_repository.dart';
import 'package:planpal/infrastructure/repositories/api_task_repository.dart';
import 'package:planpal/infrastructure/repositories/auth_repository.dart';
import 'package:planpal/infrastructure/repositories/conversation_repository.dart';
import 'package:planpal/infrastructure/repositories/preferences_repository.dart';
import 'package:planpal/infrastructure/repositories/task_repository.dart';
import 'package:planpal/infrastructure/repositories/user_repository.dart';

// ── Auth ──────────────────────────────────────────────────────────────────────

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return ApiAuthRepository(ref);
});

// ── Profile ───────────────────────────────────────────────────────────────────

final profileRepositoryProvider = Provider<ApiProfileRepository>((ref) {
  return ApiProfileRepository();
});

/// Satisfies the UserRepository abstract type used by UserNotifier.
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return ref.watch(profileRepositoryProvider);
});

// ── Tasks ─────────────────────────────────────────────────────────────────────

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final workspaceId = ref.watch(activeWorkspaceIdProvider) ?? '';
  return ApiTaskRepository(workspaceId: workspaceId);
});

// ── Conversations ─────────────────────────────────────────────────────────────

final conversationRepositoryProvider = Provider<ConversationRepository>((ref) {
  final workspaceId = ref.watch(activeWorkspaceIdProvider) ?? '';
  return ApiConversationRepository(workspaceId: workspaceId);
});

// ── Preferences ───────────────────────────────────────────────────────────────

final preferencesRepositoryProvider = Provider<PreferencesRepository>((ref) {
  return ApiPreferencesRepository();
});
