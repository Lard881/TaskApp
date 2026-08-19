import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planpal/application/notifiers/task_notifier.dart';
import 'package:planpal/application/notifiers/user_notifier.dart';
import 'package:planpal/core/constants/app_sizes.dart';
import 'package:planpal/core/constants/app_strings.dart';
import 'package:planpal/core/validators/task_validator.dart';
import 'package:planpal/domain/enums/task_priority.dart';
import 'package:planpal/domain/models/task.dart';
import 'package:planpal/presentation/widgets/app_snackbar.dart';

class EditTaskSheet extends ConsumerStatefulWidget {
  const EditTaskSheet({super.key, required this.task});
  final Task task;

  @override
  ConsumerState<EditTaskSheet> createState() => _EditTaskSheetState();
}

class _EditTaskSheetState extends ConsumerState<EditTaskSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late DateTime? _dueDate;
  late TimeOfDay? _dueTime;
  late TaskPriority? _priority;
  late String? _assigneeId;

  Map<String, String> _errors = {};

  @override
  void initState() {
    super.initState();
    // Pre-populate from existing task (Req 10.1)
    _nameController = TextEditingController(text: widget.task.name);
    _descController =
        TextEditingController(text: widget.task.description ?? '');
    _dueDate = widget.task.dueDate;
    _dueTime = widget.task.dueTime;
    _priority = widget.task.priority;
    _assigneeId = widget.task.assigneeId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _dueTime = picked);
  }

  Future<void> _save() async {
    final errors = TaskValidator.validateAll(
      name: _nameController.text,
      dueDate: _dueDate,
      dueTime: _dueTime,
      priority: _priority,
    );
    setState(() => _errors = errors);
    if (errors.isNotEmpty) return;

    final updated = widget.task.copyWith(
      name: _nameController.text.trim(),
      dueDate: _dueDate,
      dueTime: _dueTime,
      priority: _priority,
      assigneeId: _assigneeId,
      description: _descController.text.trim().isEmpty
          ? null
          : _descController.text.trim(),
      clearDescription: _descController.text.trim().isEmpty,
      updatedAt: DateTime.now(),
    );

    await ref.read(tasksProvider.notifier).updateTask(updated);
    if (mounted) {
      Navigator.of(context).pop();
      AppSnackbar.show(context, AppStrings.taskUpdated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(allUsersProvider);
    final users = usersAsync.valueOrNull ?? [];
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(AppSizes.spaceM, AppSizes.spaceM,
          AppSizes.spaceM, bottom + AppSizes.spaceM),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSizes.spaceM),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text('Edit Task',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSizes.spaceM),

            // Task name
            TextFormField(
              controller: _nameController,
              maxLength: 100,
              decoration: InputDecoration(
                labelText: AppStrings.taskNameLabel,
                errorText: _errors['name'],
                counterText: '${_nameController.text.length}/100',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSizes.spaceM),

            // Due date + time
            Row(
              children: [
                Expanded(
                  child: _FieldTile(
                    label: AppStrings.dueDateLabel,
                    value: _dueDate != null
                        ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
                        : 'Select',
                    icon: Icons.calendar_today_outlined,
                    error: _errors['dueDate'],
                    onTap: _pickDate,
                  ),
                ),
                const SizedBox(width: AppSizes.spaceS),
                Expanded(
                  child: _FieldTile(
                    label: AppStrings.dueTimeLabel,
                    value: _dueTime != null
                        ? _dueTime!.format(context)
                        : 'Select',
                    icon: Icons.access_time_rounded,
                    error: _errors['dueTime'],
                    onTap: _pickTime,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spaceM),

            // Priority
            DropdownButtonFormField<TaskPriority>(
              value: _priority,
              decoration: InputDecoration(
                labelText: AppStrings.priorityLabel,
                errorText: _errors['priority'],
              ),
              items: TaskPriority.values
                  .map((p) => DropdownMenuItem(
                        value: p,
                        child: Text(p.label),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _priority = v),
            ),
            const SizedBox(height: AppSizes.spaceM),

            // Assignee
            DropdownButtonFormField<String>(
              value: _assigneeId,
              decoration: const InputDecoration(
                  labelText: AppStrings.assigneeLabel),
              items: [
                const DropdownMenuItem(
                    value: null, child: Text('None')),
                ...users.map((u) => DropdownMenuItem(
                      value: u.id,
                      child: Text(u.fullName),
                    )),
              ],
              onChanged: (v) => setState(() => _assigneeId = v),
            ),
            const SizedBox(height: AppSizes.spaceM),

            // Description
            TextFormField(
              controller: _descController,
              maxLength: 500,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: AppStrings.descriptionLabel,
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: AppSizes.spaceM),

            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(AppStrings.cancel),
                  ),
                ),
                const SizedBox(width: AppSizes.spaceS),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _save,
                    child: const Text(AppStrings.saveChanges),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldTile extends StatelessWidget {
  const _FieldTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
    this.error,
  });
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusM),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          errorText: error,
          prefixIcon: Icon(icon, size: AppSizes.iconSizeM),
        ),
        child: Text(value,
            style: const TextStyle(fontSize: AppSizes.fontBody)),
      ),
    );
  }
}
