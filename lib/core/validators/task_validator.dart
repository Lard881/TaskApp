import 'package:flutter/material.dart';
import 'package:planpal/core/constants/app_strings.dart';
import 'package:planpal/domain/enums/task_priority.dart';

/// Validation functions for the Add/Edit Task form fields.
/// Each function returns an error string or `null` when valid.
abstract final class TaskValidator {
  /// Validates the task name field.
  /// - Error if null, empty, or exceeds 100 characters.
  static String? validateName(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return AppStrings.taskNameRequired;
    if (trimmed.length > 100) return AppStrings.taskNameTooLong;
    return null;
  }

  /// Validates the due date field.
  /// - Error if null (date is required).
  static String? validateDueDate(DateTime? value) {
    if (value == null) return AppStrings.dueDateRequired;
    return null;
  }

  /// Validates the due time field.
  /// - Error if null (time is required).
  static String? validateDueTime(TimeOfDay? value) {
    if (value == null) return AppStrings.dueTimeRequired;
    return null;
  }

  /// Validates the priority dropdown.
  /// - Error if null (priority is required).
  static String? validatePriority(TaskPriority? value) {
    if (value == null) return AppStrings.priorityRequired;
    return null;
  }

  /// Validates all required task form fields at once.
  /// Returns a map of field name → error message for any failing fields.
  /// An empty map means all fields are valid.
  static Map<String, String> validateAll({
    required String? name,
    required DateTime? dueDate,
    required TimeOfDay? dueTime,
    required TaskPriority? priority,
  }) {
    final errors = <String, String>{};
    final nameError = validateName(name);
    final dueDateError = validateDueDate(dueDate);
    final dueTimeError = validateDueTime(dueTime);
    final priorityError = validatePriority(priority);

    if (nameError != null) errors['name'] = nameError;
    if (dueDateError != null) errors['dueDate'] = dueDateError;
    if (dueTimeError != null) errors['dueTime'] = dueTimeError;
    if (priorityError != null) errors['priority'] = priorityError;

    return errors;
  }
}
