import 'package:hive_flutter/hive_flutter.dart';
import 'package:planpal/domain/models/activity_item.dart';
import 'package:planpal/domain/models/app_preferences.dart';
import 'package:planpal/domain/models/conversation.dart';
import 'package:planpal/domain/models/message.dart';
import 'package:planpal/domain/models/task.dart';
import 'package:planpal/domain/models/user.dart';
import 'package:planpal/infrastructure/repositories/hive_conversation_repository.dart';
import 'package:planpal/infrastructure/repositories/hive_preferences_repository.dart';
import 'package:planpal/infrastructure/repositories/hive_task_repository.dart';
import 'package:planpal/infrastructure/repositories/hive_user_repository.dart';

/// Result of a successful Hive initialisation.
/// Holds all open boxes and pre-built repository instances.
class HiveInitResult {
  const HiveInitResult({
    required this.taskRepository,
    required this.userRepository,
    required this.conversationRepository,
    required this.preferencesRepository,
  });

  final HiveTaskRepository taskRepository;
  final HiveUserRepository userRepository;
  final HiveConversationRepository conversationRepository;
  final HivePreferencesRepository preferencesRepository;
}

/// Opens all Hive boxes, registers all [TypeAdapter]s, seeds empty boxes,
/// and returns a [HiveInitResult] with ready-to-use repository instances.
///
/// Called once during the splash screen sequence.
Future<HiveInitResult> initHive() async {
  await Hive.initFlutter();

  // Register adapters (typeId must match the adapter class)
  if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(TaskAdapter());
  if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(UserAdapter());
  if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(ConversationAdapter());
  if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(MessageAdapter());
  if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(ActivityItemAdapter());
  if (!Hive.isAdapterRegistered(5)) Hive.registerAdapter(AppPreferencesAdapter());

  // Open all boxes
  final taskBox = await Hive.openBox<Task>('tasks');
  final userBox = await Hive.openBox<User>('users');
  final convBox = await Hive.openBox<Conversation>('conversations');
  final msgBox = await Hive.openBox<Message>('messages');
  final activityBox = await Hive.openBox<ActivityItem>('activity');
  final prefsBox = await Hive.openBox<AppPreferences>('preferences');

  // Build repositories
  final taskRepo = HiveTaskRepository(taskBox);
  final userRepo = HiveUserRepository(userBox);
  final convRepo = HiveConversationRepository(
    conversationBox: convBox,
    messageBox: msgBox,
    activityBox: activityBox,
  );
  final prefsRepo = HivePreferencesRepository(prefsBox);

  // Seed empty boxes with mock data
  await taskRepo.seedIfEmpty();
  await userRepo.seedIfEmpty();
  await convRepo.seedIfEmpty();
  await prefsRepo.seedIfEmpty();

  return HiveInitResult(
    taskRepository: taskRepo,
    userRepository: userRepo,
    conversationRepository: convRepo,
    preferencesRepository: prefsRepo,
  );
}
