import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planpal/application/notifiers/task_notifier.dart';
import 'package:planpal/application/notifiers/workspace_notifier.dart';
import 'package:planpal/core/constants/app_sizes.dart';
import 'package:planpal/core/constants/app_strings.dart';
import 'package:planpal/core/validators/task_validator.dart';
import 'package:planpal/domain/enums/task_priority.dart';
import 'package:planpal/domain/enums/task_status.dart';
import 'package:planpal/domain/models/task.dart';
import 'package:planpal/domain/models/workspace.dart';
import 'package:planpal/presentation/widgets/app_snackbar.dart';
import 'package:uuid/uuid.dart';

class AddWorkspaceTaskSheet extends ConsumerStatefulWidget {
  const AddWorkspaceTaskSheet({super.key, this.preselectedWorkspaceId});
  
  /// If provided, workspace dropdown will default to this workspace
  final String? preselectedWorkspaceId;

  @override
  ConsumerState<AddWorkspaceTaskSheet> createState() => _AddWorkspaceTaskSheetState();
}

class _AddWorkspaceTaskSheetState extends ConsumerState<AddWorkspaceTaskSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  TaskPriority? _priority;
  String? _workspaceId;
  String? _assigneeId;

  Map<String, String> _errors = {};
  List<WorkspaceMember> _workspaceMembers = [];

  @override
  void initState() {
    super.initState();
    // Pre-select workspace if provided
    _workspaceId = widget.preselectedWorkspaceId;
    
    // Load members for preselected workspace
    if (_workspaceId != null) {
      _loadWorkspaceMembers(_workspaceId!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _loadWorkspaceMembers(String workspaceId) async {
    final repo = ref.read(workspaceRepositoryProvider);
    final members = await repo.getMembers(workspaceId);
    setState(() => _workspaceMembers = members);
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
    
    // Add workspace validation
    if (_workspaceId == null || _workspaceId!.isEmpty) {
      errors['workspace'] = 'Please select a workspace';
    }
    
    setState(() => _errors = errors);
    if (errors.isNotEmpty) return;

    // Set the active workspace before saving
    ref.read(activeWorkspaceIdProvider.notifier).state = _workspaceId;

    // Workspace task: requires workspace to be set via activeWorkspaceIdProvider
    final task = Task(
      id: const Uuid().v4(),
      name: _nameController.text.trim(),
      dueDate: _dueDate,
      dueTime: _dueTime,
      priority: _priority!,
      status: TaskStatus.todo,
      assigneeId: _assigneeId,
      description: _descController.text.trim().isEmpty
          ? null
          : _descController.text.trim(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await ref.read(tasksProvider.notifier).addTask(task);
    if (context.mounted) {
      Navigator.of(context).pop();
      AppSnackbar.show(context, 'Workspace task added');
    }
  }

  @override
  Widget build(BuildContext context) {
    final workspacesAsync = ref.watch(workspacesProvider);
    final workspaces = workspacesAsync.valueOrNull ?? [];
    
    // Show ALL workspaces (including personal) for workspace tasks
    final availableWorkspaces = workspaces;
    
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
          AppSizes.spaceM, AppSizes.spaceM, AppSizes.spaceM, bottom + AppSizes.spaceM),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: AppSizes.spaceM),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  const Icon(BootstrapIcons.people_fill, size: 20),
                  const SizedBox(width: 8),
                  Text('New Workspace Task', 
                    style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Assign to workspace members',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: AppSizes.spaceM),

              // Workspace selection
              DropdownButtonFormField<String>(
                value: _workspaceId,
                decoration: InputDecoration(
                  labelText: 'Workspace *',
                  errorText: _errors['workspace'],
                  prefixIcon: const Icon(BootstrapIcons.briefcase, size: AppSizes.iconSizeM),
                ),
                items: availableWorkspaces.map((w) => DropdownMenuItem(
                  value: w.id,
                  child: Row(
                    children: [
                      Text(w.emoji, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text(w.name),
                    ],
                  ),
                )).toList(),
                onChanged: (v) {
                  setState(() {
                    _workspaceId = v;
                    _assigneeId = null; // Reset assignee when workspace changes
                    _workspaceMembers = [];
                  });
                  if (v != null) {
                    _loadWorkspaceMembers(v);
                  }
                },
              ),
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

              // Due date + time row
              Row(
                children: [
                  Expanded(
                    child: _FieldTile(
                      label: AppStrings.dueDateLabel,
                      value: _dueDate != null
                          ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
                          : 'Select',
                      icon: BootstrapIcons.calendar3,
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
                      icon: BootstrapIcons.clock,
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

              // Assignee (only shows members of selected workspace)
              DropdownButtonFormField<String>(
                value: _assigneeId,
                decoration: InputDecoration(
                  labelText: AppStrings.assigneeLabel,
                  prefixIcon: const Icon(BootstrapIcons.person, size: AppSizes.iconSizeM),
                  enabled: _workspaceId != null,
                ),
                items: [
                  const DropdownMenuItem(
                      value: null,
                      child: Text('None')),
                  ..._workspaceMembers.map((m) => DropdownMenuItem(
                        value: m.userId,
                        child: Text(m.profile?.fullName ?? m.userId),
                      )),
                ],
                onChanged: _workspaceId != null 
                  ? (v) => setState(() => _assigneeId = v)
                  : null,
              ),
              if (_workspaceId == null)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 12),
                  child: Text(
                    'Select a workspace first to assign members',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
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

              // Buttons
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
                      child: const Text(AppStrings.saveTask),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Small helper tile for date/time fields
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
