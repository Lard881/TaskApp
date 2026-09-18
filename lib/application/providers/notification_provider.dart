import 'package:planpal/domain/models/app_preferences.dart';
import 'package:planpal/domain/models/task.dart';
import 'package:planpal/infrastructure/services/notification_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Extension to schedule task reminders
extension TaskNotifications on NotificationService {
  Future<void> scheduleTaskReminder(Task task, AppPreferences prefs) async {
    // Check if task reminders are enabled in preferences
    if (!prefs.notifyTaskReminders) {
      return; // Notifications disabled
    }

    if (task.dueDate == null) return;

    final dueDateTime = DateTime(
      task.dueDate!.year,
      task.dueDate!.month,
      task.dueDate!.day,
      task.dueTime?.hour ?? 9,
      task.dueTime?.minute ?? 0,
    );

    // Schedule 1 hour before due time
    final reminderTime = dueDateTime.subtract(const Duration(hours: 1));

    // Only schedule if reminder time is in the future
    if (reminderTime.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: task.id.hashCode,
        title: 'Task Reminder: ${task.name}',
        body: 'Due in 1 hour',
        scheduledDate: reminderTime,
        payload: 'task:${task.id}',
      );
    }

    // Schedule at due time if due date alerts enabled
    if (prefs.notifyDueDateAlerts && dueDateTime.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: task.id.hashCode + 1,
        title: 'Task Due: ${task.name}',
        body: task.description ?? 'This task is due now',
        scheduledDate: dueDateTime,
        payload: 'task:${task.id}',
      );
    }
  }

  Future<void> cancelTaskReminder(Task task) async {
    await cancelNotification(task.id.hashCode);
    await cancelNotification(task.id.hashCode + 1);
  }

  Future<void> notifyTaskCompleted(Task task, AppPreferences prefs) async {
    // Check if task reminders are enabled
    if (!prefs.notifyTaskReminders) {
      return; // Notifications disabled
    }

    await showInstantNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      title: '✓ Task Completed',
      body: task.name,
      payload: 'task:${task.id}',
    );
  }

  Future<void> notifyChatMessage({
    required String senderName,
    required String message,
    required String conversationId,
    required AppPreferences prefs,
  }) async {
    // Check if chat notifications are enabled
    if (!prefs.notifyChatMessages) {
      return; // Notifications disabled
    }

    await showInstantNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      title: senderName,
      body: message,
      payload: 'chat:$conversationId',
    );
  }
}
