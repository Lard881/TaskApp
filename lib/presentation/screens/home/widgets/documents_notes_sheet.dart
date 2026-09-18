import 'dart:convert';

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:planpal/application/notifiers/workspace_notifier.dart';
import 'package:planpal/core/constants/app_colors.dart';
import 'package:planpal/core/constants/app_sizes.dart';
import 'package:planpal/presentation/widgets/app_snackbar.dart';
import 'package:planpal/presentation/widgets/skeleton_loader.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DocumentsNotesSheet extends ConsumerStatefulWidget {
  const DocumentsNotesSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const DocumentsNotesSheet(),
    );
  }

  @override
  ConsumerState<DocumentsNotesSheet> createState() =>
      _DocumentsNotesSheetState();
}

class _DocumentsNotesSheetState extends ConsumerState<DocumentsNotesSheet> {
  static const _uuid = Uuid();
  List<_DocItem> _docs = [];
  bool _isLoading = true;
  String? _loadedWorkspaceId;

  @override
  void initState() {
    super.initState();
    _loadDocs();
  }

  String _getStorageKey(String workspaceId) {
    return 'planpal_docs_${workspaceId.trim().isEmpty ? "default" : workspaceId.trim()}';
  }

  Future<void> _loadDocs() async {
    final activeWs = ref.read(activeWorkspaceProvider);
    final wsId = activeWs?.id ?? '';
    _loadedWorkspaceId = wsId;

    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getStorageKey(wsId);
      final raw = prefs.getString(key);

      if (raw != null && raw.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
        if (mounted) {
          setState(() {
            _docs = decoded
                .map((e) => _DocItem.fromJson(e as Map<String, dynamic>))
                .toList();
            _isLoading = false;
          });
          return;
        }
      }
    } catch (e) {
      debugPrint('[DocumentsNotesSheet] Error loading documents: $e');
    }

    if (mounted) {
      setState(() {
        _docs = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _saveDocs() async {
    final activeWs = ref.read(activeWorkspaceProvider);
    final wsId = activeWs?.id ?? _loadedWorkspaceId ?? '';
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getStorageKey(wsId);
      final encoded = jsonEncode(_docs.map((d) => d.toJson()).toList());
      await prefs.setString(key, encoded);
    } catch (e) {
      debugPrint('[DocumentsNotesSheet] Error saving documents: $e');
    }
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Guidelines':
        return const Color(0xFF6366F1);
      case 'Project':
        return const Color(0xFF8B5CF6);
      case 'Meeting':
        return const Color(0xFF14B8A6);
      case 'Documentation':
        return const Color(0xFF3B82F6);
      case 'Specs':
        return const Color(0xFFEC4899);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  void _openDocumentDialog({_DocItem? existingDoc, int? index}) {
    final isEditing = existingDoc != null;
    final titleCtrl = TextEditingController(text: existingDoc?.title ?? '');
    final contentCtrl = TextEditingController(text: existingDoc?.content ?? '');
    String category = existingDoc?.category ?? 'Notes';

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          isEditing ? 'Edit Document' : 'Add Document / Note',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Title *',
                  hintText: 'e.g. Design Specs, Onboarding Guide',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: [
                  'Notes',
                  'Project',
                  'Meeting',
                  'Guidelines',
                  'Documentation',
                  'Specs',
                ]
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) category = val;
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentCtrl,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  hintText: 'Write notes or document details...',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final trimmedTitle = titleCtrl.text.trim();
              if (trimmedTitle.isEmpty) return;

              final nowFormatted =
                  DateFormat('MMM d, yyyy • h:mm a').format(DateTime.now());

              if (isEditing && index != null) {
                setState(() {
                  _docs[index] = _DocItem(
                    id: existingDoc.id,
                    title: trimmedTitle,
                    category: category,
                    content: contentCtrl.text.trim(),
                    updatedAt: nowFormatted,
                    colorValue: _categoryColor(category).toARGB32(),
                  );
                });
              } else {
                setState(() {
                  _docs.insert(
                    0,
                    _DocItem(
                      id: _uuid.v4(),
                      title: trimmedTitle,
                      category: category,
                      content: contentCtrl.text.trim(),
                      updatedAt: nowFormatted,
                      colorValue: _categoryColor(category).toARGB32(),
                    ),
                  );
                });
              }

              await _saveDocs();
              if (ctx.mounted) {
                Navigator.pop(ctx);
              }
              if (mounted) {
                AppSnackbar.show(
                  context,
                  isEditing ? 'Document updated' : 'Document created',
                );
              }
            },
            child: Text(isEditing ? 'Save Changes' : 'Create'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(int index) {
    final doc = _docs[index];
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Document?'),
        content: Text('Are you sure you want to delete "${doc.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              setState(() {
                _docs.removeAt(index);
              });
              await _saveDocs();
              if (ctx.mounted) {
                Navigator.pop(ctx);
              }
              if (mounted) {
                AppSnackbar.show(context, 'Document deleted');
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final activeWs = ref.watch(activeWorkspaceProvider);

    // If workspace changed while sheet is open, reload
    if (activeWs != null && activeWs.id != _loadedWorkspaceId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _loadDocs();
      });
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusL),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          BootstrapIcons.folder2_open,
                          color: Color(0xFF8B5CF6),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Workspace Documents',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                            if (activeWs != null)
                              Text(
                                '${activeWs.emoji} ${activeWs.name}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.darkOnSurfaceMuted
                                      : Colors.grey.shade600,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => _openDocumentDialog(),
                  icon: const Icon(BootstrapIcons.plus, size: 16),
                  label: const Text('New'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    minimumSize: Size.zero,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Body
          Expanded(
            child: _isLoading
                ? const SkeletonDocList(count: 4)
                : _docs.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  BootstrapIcons.journal_text,
                                  size: 32,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No Documents Yet',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: isDark
                                      ? AppColors.darkOnSurface
                                      : AppColors.lightOnSurface,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Create guidelines, specifications, or meeting notes for this workspace. All entries are saved here.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isDark
                                      ? AppColors.darkOnSurfaceMuted
                                      : Colors.grey.shade500,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 18),
                              FilledButton.icon(
                                onPressed: () => _openDocumentDialog(),
                                icon: const Icon(BootstrapIcons.plus_circle,
                                    size: 16),
                                label: const Text('Create First Document'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _docs.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final doc = _docs[index];
                          final docColor = doc.color;

                          return Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusM),
                              side: BorderSide(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.black.withValues(alpha: 0.06),
                              ),
                            ),
                            child: ExpansionTile(
                              shape: const Border(),
                              leading: Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: docColor.withValues(alpha: 0.12),
                                  borderRadius:
                                      BorderRadius.circular(AppSizes.radiusM),
                                ),
                                child: Icon(
                                  BootstrapIcons.file_text,
                                  color: docColor,
                                  size: 18,
                                ),
                              ),
                              title: Text(
                                doc.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Text(
                                '${doc.category} • ${doc.updatedAt}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 0, 16, 12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? AppColors.darkBackground
                                              : const Color(0xFFF9FAFB),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          doc.content.isEmpty
                                              ? '(No content entered)'
                                              : doc.content,
                                          style: TextStyle(
                                            fontSize: 13,
                                            height: 1.4,
                                            fontStyle: doc.content.isEmpty
                                                ? FontStyle.italic
                                                : FontStyle.normal,
                                            color: isDark
                                                ? AppColors.darkOnSurface
                                                : AppColors.lightOnSurface,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          if (doc.content.isNotEmpty) ...[
                                            TextButton.icon(
                                              onPressed: () {
                                                Clipboard.setData(
                                                  ClipboardData(
                                                      text: doc.content),
                                                );
                                                AppSnackbar.show(context,
                                                    'Copied to clipboard');
                                              },
                                              icon: const Icon(
                                                  BootstrapIcons.copy,
                                                  size: 14),
                                              label: const Text('Copy'),
                                            ),
                                            const SizedBox(width: 4),
                                          ],
                                          TextButton.icon(
                                            onPressed: () =>
                                                _openDocumentDialog(
                                              existingDoc: doc,
                                              index: index,
                                            ),
                                            icon: const Icon(
                                                BootstrapIcons.pencil,
                                                size: 14),
                                            label: const Text('Edit'),
                                          ),
                                          const SizedBox(width: 4),
                                          TextButton.icon(
                                            onPressed: () =>
                                                _confirmDelete(index),
                                            icon: const Icon(
                                              BootstrapIcons.trash,
                                              size: 14,
                                              color: AppColors.error,
                                            ),
                                            label: const Text(
                                              'Delete',
                                              style: TextStyle(
                                                  color: AppColors.error),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _DocItem {
  _DocItem({
    required this.id,
    required this.title,
    required this.category,
    required this.content,
    required this.updatedAt,
    required this.colorValue,
  });

  final String id;
  final String title;
  final String category;
  final String content;
  final String updatedAt;
  final int colorValue;

  Color get color => Color(colorValue);

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'content': content,
        'updatedAt': updatedAt,
        'colorValue': colorValue,
      };

  factory _DocItem.fromJson(Map<String, dynamic> json) => _DocItem(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        category: json['category'] as String? ?? 'Notes',
        content: json['content'] as String? ?? '',
        updatedAt: json['updatedAt'] as String? ?? '',
        colorValue: json['colorValue'] as int? ?? 0xFF6366F1,
      );
}
