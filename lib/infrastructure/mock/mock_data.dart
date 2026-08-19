import 'package:flutter/material.dart';
import 'package:planpal/domain/enums/activity_type.dart';
import 'package:planpal/domain/enums/task_priority.dart';
import 'package:planpal/domain/enums/task_status.dart';
import 'package:planpal/domain/models/activity_item.dart';
import 'package:planpal/domain/models/conversation.dart';
import 'package:planpal/domain/models/message.dart';
import 'package:planpal/domain/models/task.dart';
import 'package:planpal/domain/models/user.dart';

/// Hardcoded seed data for Phase 1.
/// All IDs are fixed strings so they are stable across hot-restarts.
abstract final class MockData {
  // ── User IDs ──────────────────────────────────────────────────────────────
  static const String currentUserId = 'user-001';
  static const String userId2 = 'user-002';
  static const String userId3 = 'user-003';

  // ── Users ─────────────────────────────────────────────────────────────────

  static final List<User> users = [
    const User(
      id: currentUserId,
      firstName: 'Alex',
      lastName: 'Morgan',
      role: 'Product Manager',
      email: 'alex.morgan@planpal.app',
      phone: '+1 555 000 1234',
    ),
    const User(
      id: userId2,
      firstName: 'Jamie',
      lastName: 'Chen',
      role: 'UI Designer',
      email: 'jamie.chen@planpal.app',
    ),
    const User(
      id: userId3,
      firstName: 'Sam',
      lastName: 'Rivera',
      role: 'Backend Engineer',
      email: 'sam.rivera@planpal.app',
      phone: '+1 555 000 5678',
    ),
  ];

  // ── Tasks ─────────────────────────────────────────────────────────────────

  static final DateTime _now = DateTime.now();

  /// Helper: a date N days from today at midnight.
  static DateTime _daysFromNow(int days) => DateTime(
        _now.year,
        _now.month,
        _now.day + days,
      );

  static final List<Task> tasks = [
    // Due today — high priority
    Task(
      id: 'task-001',
      name: 'Review design mockups for the onboarding flow',
      dueDate: _daysFromNow(0),
      dueTime: const TimeOfDay(hour: 10, minute: 0),
      priority: TaskPriority.high,
      status: TaskStatus.inProgress,
      assigneeId: currentUserId,
      description:
          'Go through the Figma file shared by Jamie and leave comments on the prototype.',
      createdAt: _daysFromNow(-3),
      updatedAt: _daysFromNow(-1),
    ),
    // Due today — medium priority
    Task(
      id: 'task-002',
      name: 'Write release notes for v1.2.0',
      dueDate: _daysFromNow(0),
      dueTime: const TimeOfDay(hour: 14, minute: 30),
      priority: TaskPriority.medium,
      status: TaskStatus.todo,
      assigneeId: currentUserId,
      createdAt: _daysFromNow(-2),
      updatedAt: _daysFromNow(-2),
    ),
    // Due today — low priority (no time)
    Task(
      id: 'task-003',
      name: 'Update project README with new setup instructions',
      dueDate: _daysFromNow(0),
      priority: TaskPriority.low,
      status: TaskStatus.todo,
      assigneeId: userId2,
      createdAt: _daysFromNow(-1),
      updatedAt: _daysFromNow(-1),
    ),
    // Upcoming — tomorrow
    Task(
      id: 'task-004',
      name: 'Conduct weekly team standup and take notes',
      dueDate: _daysFromNow(1),
      dueTime: const TimeOfDay(hour: 9, minute: 0),
      priority: TaskPriority.medium,
      status: TaskStatus.todo,
      assigneeId: currentUserId,
      createdAt: _daysFromNow(-5),
      updatedAt: _daysFromNow(-5),
    ),
    // Upcoming — 3 days from now
    Task(
      id: 'task-005',
      name: 'Prepare Q3 product roadmap presentation',
      dueDate: _daysFromNow(3),
      dueTime: const TimeOfDay(hour: 15, minute: 0),
      priority: TaskPriority.high,
      status: TaskStatus.inProgress,
      assigneeId: currentUserId,
      description:
          'Include milestones, resource allocation, and key risks for the exec review.',
      createdAt: _daysFromNow(-7),
      updatedAt: _daysFromNow(-2),
    ),
    // Upcoming — 5 days from now
    Task(
      id: 'task-006',
      name: 'Integrate push notification service',
      dueDate: _daysFromNow(5),
      priority: TaskPriority.high,
      status: TaskStatus.todo,
      assigneeId: userId3,
      description: 'Use FCM for Android and APNs for iOS.',
      createdAt: _daysFromNow(-4),
      updatedAt: _daysFromNow(-4),
    ),
    // Upcoming — 7 days
    Task(
      id: 'task-007',
      name: 'Run accessibility audit on all five screens',
      dueDate: _daysFromNow(7),
      priority: TaskPriority.medium,
      status: TaskStatus.todo,
      assigneeId: userId2,
      createdAt: _daysFromNow(-2),
      updatedAt: _daysFromNow(-2),
    ),
    // Completed
    Task(
      id: 'task-008',
      name: 'Set up CI/CD pipeline with GitHub Actions',
      dueDate: _daysFromNow(-5),
      dueTime: const TimeOfDay(hour: 17, minute: 0),
      priority: TaskPriority.high,
      status: TaskStatus.completed,
      assigneeId: userId3,
      createdAt: _daysFromNow(-14),
      updatedAt: _daysFromNow(-5),
    ),
    // Completed
    Task(
      id: 'task-009',
      name: 'Finalise color palette and typography scale',
      dueDate: _daysFromNow(-8),
      priority: TaskPriority.medium,
      status: TaskStatus.completed,
      assigneeId: userId2,
      createdAt: _daysFromNow(-20),
      updatedAt: _daysFromNow(-8),
    ),
    // Overdue — not completed
    Task(
      id: 'task-010',
      name: 'Fix login screen keyboard overlap on small devices',
      dueDate: _daysFromNow(-2),
      dueTime: const TimeOfDay(hour: 12, minute: 0),
      priority: TaskPriority.high,
      status: TaskStatus.inProgress,
      assigneeId: currentUserId,
      description:
          'The keyboard covers the submit button on devices below 5-inch screen.',
      createdAt: _daysFromNow(-10),
      updatedAt: _daysFromNow(-3),
    ),
    // Overdue — low priority
    Task(
      id: 'task-011',
      name: 'Archive old sprint boards in project management tool',
      dueDate: _daysFromNow(-4),
      priority: TaskPriority.low,
      status: TaskStatus.todo,
      assigneeId: currentUserId,
      createdAt: _daysFromNow(-12),
      updatedAt: _daysFromNow(-12),
    ),
    // No due date
    Task(
      id: 'task-012',
      name: 'Research competitor apps for benchmark analysis',
      priority: TaskPriority.low,
      status: TaskStatus.todo,
      assigneeId: currentUserId,
      description: 'Focus on Notion, Todoist, and Linear.',
      createdAt: _daysFromNow(-6),
      updatedAt: _daysFromNow(-6),
    ),
  ];

  // ── Conversations ─────────────────────────────────────────────────────────

  static final List<Conversation> conversations = [
    Conversation(
      id: 'conv-001',
      name: 'Jamie Chen',
      participantIds: [currentUserId, userId2],
      lastMessagePreview: 'I\'ll send the updated Figma link shortly.',
      lastMessageAt: _daysFromNow(0).subtract(const Duration(hours: 1)),
      unreadCount: 2,
      isGroup: false,
    ),
    Conversation(
      id: 'conv-002',
      name: 'Sam Rivera',
      participantIds: [currentUserId, userId3],
      lastMessagePreview: 'The API endpoints are ready for testing.',
      lastMessageAt: _daysFromNow(-1),
      unreadCount: 0,
      isGroup: false,
    ),
    Conversation(
      id: 'conv-003',
      name: 'PlanPal Dev Team',
      participantIds: [currentUserId, userId2, userId3],
      lastMessagePreview: 'Sprint review is moved to Friday at 3 PM.',
      lastMessageAt: _daysFromNow(-2),
      unreadCount: 5,
      isGroup: true,
    ),
    Conversation(
      id: 'conv-004',
      name: 'Design Reviews',
      participantIds: [currentUserId, userId2],
      lastMessagePreview: 'Looks great! Approved.',
      lastMessageAt: _daysFromNow(-10),
      unreadCount: 0,
      isGroup: true,
    ),
  ];

  // ── Messages ──────────────────────────────────────────────────────────────

  static final List<Message> messages = [
    // conv-001 messages
    Message(
      id: 'msg-001',
      conversationId: 'conv-001',
      senderId: currentUserId,
      text: 'Hey Jamie, did you finish the mockups for the dashboard?',
      sentAt: _daysFromNow(0).subtract(const Duration(hours: 3)),
      isRead: true,
    ),
    Message(
      id: 'msg-002',
      conversationId: 'conv-001',
      senderId: userId2,
      text: 'Almost done! Just polishing the dark mode version.',
      sentAt: _daysFromNow(0).subtract(const Duration(hours: 2)),
      isRead: true,
    ),
    Message(
      id: 'msg-003',
      conversationId: 'conv-001',
      senderId: userId2,
      text: "I'll send the updated Figma link shortly.",
      sentAt: _daysFromNow(0).subtract(const Duration(hours: 1)),
      isRead: false,
    ),
    // conv-002 messages
    Message(
      id: 'msg-004',
      conversationId: 'conv-002',
      senderId: userId3,
      text: 'The API endpoints are ready for testing.',
      sentAt: _daysFromNow(-1),
      isRead: true,
    ),
    Message(
      id: 'msg-005',
      conversationId: 'conv-002',
      senderId: currentUserId,
      text: 'Awesome, I will start integration today.',
      sentAt: _daysFromNow(-1).add(const Duration(hours: 1)),
      isRead: true,
    ),
    // conv-003 messages
    Message(
      id: 'msg-006',
      conversationId: 'conv-003',
      senderId: userId3,
      text: 'Build is green on all platforms 🎉',
      sentAt: _daysFromNow(-2).subtract(const Duration(hours: 5)),
      isRead: true,
    ),
    Message(
      id: 'msg-007',
      conversationId: 'conv-003',
      senderId: userId2,
      text: 'Sprint review is moved to Friday at 3 PM.',
      sentAt: _daysFromNow(-2),
      isRead: false,
    ),
    // conv-004 messages
    Message(
      id: 'msg-008',
      conversationId: 'conv-004',
      senderId: currentUserId,
      text: 'Here are the updated screens for your review.',
      sentAt: _daysFromNow(-10).subtract(const Duration(hours: 2)),
      isRead: true,
    ),
    Message(
      id: 'msg-009',
      conversationId: 'conv-004',
      senderId: userId2,
      text: 'Looks great! Approved.',
      sentAt: _daysFromNow(-10),
      isRead: true,
    ),
  ];

  // ── Activity items ────────────────────────────────────────────────────────

  static final List<ActivityItem> activityItems = [
    ActivityItem(
      id: 'act-001',
      type: ActivityType.completed,
      taskId: 'task-008',
      taskName: 'Set up CI/CD pipeline with GitHub Actions',
      timestamp: _daysFromNow(-5),
    ),
    ActivityItem(
      id: 'act-002',
      type: ActivityType.created,
      taskId: 'task-012',
      taskName: 'Research competitor apps for benchmark analysis',
      timestamp: _daysFromNow(-6),
    ),
    ActivityItem(
      id: 'act-003',
      type: ActivityType.updated,
      taskId: 'task-005',
      taskName: 'Prepare Q3 product roadmap presentation',
      timestamp: _daysFromNow(-2),
    ),
    ActivityItem(
      id: 'act-004',
      type: ActivityType.completed,
      taskId: 'task-009',
      taskName: 'Finalise color palette and typography scale',
      timestamp: _daysFromNow(-8),
    ),
    ActivityItem(
      id: 'act-005',
      type: ActivityType.created,
      taskId: 'task-001',
      taskName: 'Review design mockups for the onboarding flow',
      timestamp: _daysFromNow(-3),
    ),
  ];
}
