import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:planpal/core/constants/app_colors.dart';
import 'package:planpal/core/constants/app_sizes.dart';
import 'package:planpal/core/formatters/datetime_formatter.dart';
import 'package:planpal/domain/models/message.dart';
import 'package:planpal/domain/models/user.dart';
import 'package:planpal/presentation/widgets/avatar_widget.dart';
import 'package:url_launcher/url_launcher.dart';

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

  Future<void> _openMedia(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildMediaContent(BuildContext context) {
    switch (message.type) {
      case MessageType.image:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.mediaUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
                child: GestureDetector(
                  onTap: () => _openMedia(message.mediaUrl!),
                  child: Image.network(
                    message.mediaUrl!,
                    width: 200,
                    height: 150,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 200,
                      height: 150,
                      color: Colors.grey[300],
                      child: const Icon(BootstrapIcons.image, size: 48),
                    ),
                  ),
                ),
              ),
            if (message.text.isNotEmpty) ...[
              const SizedBox(height: AppSizes.spaceXS),
              Text(
                message.text,
                style: TextStyle(
                  color: isOwn ? Colors.white : Theme.of(context).colorScheme.onSurface,
                  fontSize: AppSizes.fontBody,
                ),
              ),
            ],
          ],
        );

      case MessageType.document:
      case MessageType.file:
        return GestureDetector(
          onTap: message.mediaUrl != null ? () => _openMedia(message.mediaUrl!) : null,
          child: Container(
            padding: const EdgeInsets.all(AppSizes.spaceS),
            decoration: BoxDecoration(
              color: isOwn 
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  message.type == MessageType.document
                      ? BootstrapIcons.file_earmark_text
                      : BootstrapIcons.paperclip,
                  color: isOwn ? Colors.white : AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: AppSizes.spaceS),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.mediaName ?? 'File',
                        style: TextStyle(
                          color: isOwn ? Colors.white : Theme.of(context).colorScheme.onSurface,
                          fontSize: AppSizes.fontBody,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (message.text.isNotEmpty)
                        Text(
                          message.text,
                          style: TextStyle(
                            color: isOwn 
                                ? Colors.white.withValues(alpha: 0.8)
                                : Colors.grey[600],
                            fontSize: AppSizes.fontSmall,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );

      default:
        return Text(
          message.text,
          style: TextStyle(
            color: isOwn ? Colors.white : Theme.of(context).colorScheme.onSurface,
            fontSize: AppSizes.fontBody,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isOwn
        ? AppColors.primary
        : Theme.of(context).colorScheme.surface;
    final textColor = isOwn
        ? Colors.white
        : Theme.of(context).colorScheme.onSurface;
    final timeColor = isOwn
        ? Colors.white.withValues(alpha: 0.7)
        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5);

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
                      style: const TextStyle(
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
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildMediaContent(context),
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
