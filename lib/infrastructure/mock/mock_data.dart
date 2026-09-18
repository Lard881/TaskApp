import 'package:planpal/domain/models/activity_item.dart';
import 'package:planpal/domain/models/conversation.dart';
import 'package:planpal/domain/models/message.dart';
import 'package:planpal/domain/models/task.dart';
import 'package:planpal/domain/models/user.dart';

/// Clean container — all mock data has been removed.
abstract final class MockData {
  static const String currentUserId = '';
  static const String userId2 = '';
  static const String userId3 = '';

  static final List<User> users = const [];
  static final List<Task> tasks = const [];
  static final List<Conversation> conversations = const [];
  static final List<Message> messages = const [];
  static final List<ActivityItem> activityItems = const [];
}
