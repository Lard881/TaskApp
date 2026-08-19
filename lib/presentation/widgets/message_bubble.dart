import 'package:flutter/material.dart';
import 'package:planpal/core/constants/app_colors.dart';
import 'package:planpal/core/constants/app_sizes.dart';
import 'package:planpal/core/formatters/datetime_formatter.dart';
import 'package:planpal/domain/models/message.dart';
import 'package:planpal/domain/models/user.dart';
import 'package:planpal/presentation/widgets/avatar_widget.dart';

/// A single chat message bubble, aligned left (others) or right (own).
class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isOwn,
    this.sender,
    this.showSenderName = false,
  });

  final Message message;
  final bool isOwn;
  final User? sender;

  /// Show sender name — only in group chats (Req 14.4).
  final bool showSenderName;

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isOwn
        ? AppColors.primary
        : Theme.of(context).colorScheme.surface;
    final textColor = isOwn
        ? Colors.white
        : Theme.of(context).colorScheme.onSurface;
    final timeColor = isOwn
        ? Colors.white.withOpacity(0.7)
        : Theme.of(context).colorScheme.onSurface.withOpacity(0.5);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spaceM,
        vertical: AppSizes.spaceXS,
      ),
      child: Row(
        mainAxisAlignment:
            isOwn ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isOwn && sender != null) ...[
            AvatarWidget(
              initials: sender!.initials,
              imagePath: sender!.avatarPath,
              diameter: 28,
            ),
            const SizedBox(width: AppSizes.spaceS),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isOwn
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (showSenderName && !isOwn && sender != null)
                  Padding(
                    padding:
                        const EdgeInsets.only(bottom: AppSizes.spaceXS),
                    child: Text(
                      sender!.fullName,
                      style: TextStyle(
                        fontSize: AppSizes.fontSmall,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.spaceM,
                    vertical: AppSizes.spaceS,
                  ),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(AppSizes.radiusM),
                      topRight: const Radius.circular(AppSizes.radiusM),
                      bottomLeft: Radius.circular(
                          isOwn ? AppSizes.radiusM : AppSizes.spaceXS),
                      bottomRight: Radius.circular(
                          isOwn ? AppSizes.spaceXS : AppSizes.radiusM),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        message.text,
                        style: TextStyle(
                          color: textColor,
                          fontSize: AppSizes.fontBody,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateTimeFormatter.formatMessageTimestamp(
                            message.sentAt),
                        style: TextStyle(
                          color: timeColor,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
