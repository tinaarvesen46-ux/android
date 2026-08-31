import 'package:flutter/material.dart';

import '../../models/chat.dart';
import '../../theme/theme.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMine;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMine,
  });

  String get _preview {
    switch (message.type) {
      case MessageType.photo:
        return 'Photo';
      case MessageType.video:
        return 'Video';
      case MessageType.voice:
        return 'Voice message';
      case MessageType.snap:
        return 'Snap';
      case MessageType.text:
        return message.content;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;
    final isMedia = message.type != MessageType.text;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingXs),
      child: Row(
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingMd,
                vertical: AppTheme.spacingSm,
              ),
              decoration: BoxDecoration(
                color: isMine
                    ? appColors.chatBubbleSelf
                    : appColors.chatBubbleOther,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isMedia) ...[
                        Icon(
                          Icons.perm_media_rounded,
                          size: AppTheme.iconSm,
                          color: appColors.onMedia,
                        ),
                        const SizedBox(width: AppTheme.spacingSm),
                      ],
                      Flexible(
                        child: Text(
                          _preview,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: appColors.onMedia),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingXxs),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.timestamp),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: appColors.onMedia
                              .withValues(alpha: AppTheme.opacityHint),
                        ),
                      ),
                      if (isMine) ...[
                        const SizedBox(width: AppTheme.spacingXxs),
                        Icon(
                          message.isRead ? Icons.done_all_rounded : Icons.done_rounded,
                          size: 14,
                          color: message.isRead
                              ? theme.colorScheme.primary
                              : appColors.onMedia.withValues(alpha: AppTheme.opacityHint),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
