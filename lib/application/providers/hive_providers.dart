import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planpal/infrastructure/hive_init.dart';
import 'package:planpal/infrastructure/repositories/hive_conversation_repository.dart';
import 'package:planpal/infrastructure/repositories/hive_preferences_repository.dart';
import 'package:planpal/infrastructure/repositories/hive_task_repository.dart';
import 'package:planpal/infrastructure/repositories/hive_user_repository.dart';
import 'package:planpal/infrastructure/repositories/task_repository.dart';
import 'package:planpal/infrastructure/repositories/user_repository.dart';
import 'package:planpal/infrastructure/repositories/conversation_repository.dart';
import 'package:planpal/infrastructure/repositories/preferences_repository.dart';

/// Holds the [HiveInitResult] after the splash screen completes init.
/// Other providers read from this to access repositories.
final hiveInitResultProvider =
    StateProvider<HiveInitResult?>((ref) => null);

/// Provides the [TaskRepository] implementation.
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final result = ref.watch(hiveInitResultProvider);
  if (result == null) throw StateError('Hive not yet initialised');
  return result.taskRepository;
});

/// Provides the [UserRepository] implementation.
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final result = ref.watch(hiveInitResultProvider);
  if (result == null) throw StateError('Hive not yet initialised');
  return result.userRepository;
});

/// Provides the [ConversationRepository] implementation.
final conversationRepositoryProvider =
    Provider<ConversationRepository>((ref) {
  final result = ref.watch(hiveInitResultProvider);
  if (result == null) throw StateError('Hive not yet initialised');
  return result.conversationRepository;
});

/// Provides the [PreferencesRepository] implementation.
final preferencesRepositoryProvider =
    Provider<PreferencesRepository>((ref) {
  final result = ref.watch(hiveInitResultProvider);
  if (result == null) throw StateError('Hive not yet initialised');
  return result.preferencesRepository;
});

// ── Typed repository convenience accessors ────────────────────────────────

/// Direct access to the [HiveTaskRepository] (needed for seeding checks).
final hiveTaskRepositoryProvider =
    Provider<HiveTaskRepository>((ref) {
  final result = ref.watch(hiveInitResultProvider);
  if (result == null) throw StateError('Hive not yet initialised');
  return result.taskRepository;
});

/// Direct access to the [HiveUserRepository].
final hiveUserRepositoryProvider =
    Provider<HiveUserRepository>((ref) {
  final result = ref.watch(hiveInitResultProvider);
  if (result == null) throw StateError('Hive not yet initialised');
  return result.userRepository;
});

/// Direct access to the [HiveConversationRepository].
final hiveConversationRepositoryProvider =
    Provider<HiveConversationRepository>((ref) {
  final result = ref.watch(hiveInitResultProvider);
  if (result == null) throw StateError('Hive not yet initialised');
  return result.conversationRepository;
});

/// Direct access to the [HivePreferencesRepository].
final hivePreferencesRepositoryProvider =
    Provider<HivePreferencesRepository>((ref) {
  final result = ref.watch(hiveInitResultProvider);
  if (result == null) throw StateError('Hive not yet initialised');
  return result.preferencesRepository;
});
