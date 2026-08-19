import 'package:flutter/material.dart';
import 'package:planpal/core/constants/app_colors.dart';
import 'package:planpal/core/constants/app_sizes.dart';
import 'package:planpal/core/formatters/datetime_formatter.dart';
import 'package:planpal/domain/models/conversation.dart';
import 'package:planpal/presentation/widgets/avatar_widget.dart';

/// A single row in the Chat screen conversation list.
class ConversationItem extends StatelessWidget {
  const ConversationItem({
    super.key,
    required this.conversation,
    required this.onTap,
  });

  final Conversation conversation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final unread = conversation.unreadCount;
    final badgeLabel = unread > 99 ? '99+' : '$unread';

    return Semantics(
      label: 'Conversation with ${conversation.name}',
      button: true,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spaceM,
          vertical: AppSizes.spaceXS,
        ),
        leading: AvatarWidget(
          initials: conversation.name.isNotEmpty
              ? conversation.name[0].toUpperCase()
              : '?',
          diameter: AppSizes.avatarMedium,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                conversation.name,
                style: TextStyle(
                  fontWeight: unread > 0
                      ? FontWeight.w700
                      : FontWeight.w500,
                  fontSize: AppSizes.fontBody,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppSizes.spaceS),
            Text(
              DateTimeFormatter.formatConversationTimestamp(
                  conversation.lastMessageAt),
              style: TextStyle(
                fontSize: AppSizes.fontSmall,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.5),
              ),
            ),
          ],
        ),
        subtitle: Row(
          children: [
            Expanded(
              child: Text(
                conversation.lastMessagePreview,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: AppSizes.fontSmall,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.55),
                  fontWeight: unread > 0
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ),
            if (unread > 0) ...[
              const SizedBox(width: AppSizes.spaceS),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius:
                      BorderRadius.circular(AppSizes.radiusFull),
                ),
                child: Text(
                  badgeLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
