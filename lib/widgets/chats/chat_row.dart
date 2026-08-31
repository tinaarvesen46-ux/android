import 'package:flutter/material.dart';
import '../../models/chat.dart';
import '../../theme/theme.dart';
import '../common/snap_avatar.dart';
import '../common/role_badge.dart';

class ChatRow extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const ChatRow({
    super.key,
    required this.conversation,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;
    final hasUnread = conversation.unreadCount > 0;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: AppTheme.chatRowHeight,
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingLg,
          vertical: AppTheme.spacingSm,
        ),
        child: Row(
          children: [
            SnapAvatar(
              imageUrl: conversation.participant.avatarUrl,
              fallbackText: conversation.participant.displayName,
              size: AppTheme.avatarMd,
              showOnlineIndicator: true,
              isOnline: conversation.participant.isOnline,
            ),
            const SizedBox(width: AppTheme.spacingMd),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                conversation.isGroup
                                    ? (conversation.groupName ??
                                        conversation.participant.displayName)
                                    : conversation.participant.displayName,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: hasUnread
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (!conversation.isGroup)
                              RoleBadge(
                                role: conversation.participant.role,
                                roleLabel: conversation.participant.roleLabel,
                              ),
                          ],
                        ),
                      ),
                      if (conversation.lastMessage != null)
                        Text(
                          _formatTime(conversation.lastMessage!.timestamp),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: hasUnread
                                ? appColors.storyRing
                                : appColors.subtleText,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingXxs),
                  Row(
                    children: [
                      if (conversation.isTyping)
                        Expanded(
                          child: Text(
                            'Typing...',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: appColors.storyRing,
                            ),
                            maxLines: 1,
                          ),
                        )
                      else
                        Expanded(
                          child: Text(
                            _lastMessagePreview(conversation.lastMessage),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: hasUnread
                                  ? theme.colorScheme.onSurface
                                  : appColors.subtleText,
                              fontWeight: hasUnread
                                  ? FontWeight.w500
                                  : FontWeight.w400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      if (hasUnread)
                        Container(
                          margin:
                              const EdgeInsets.only(left: AppTheme.spacingSm),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingSm,
                            vertical: AppTheme.spacingXxs,
                          ),
                          decoration: BoxDecoration(
                            color: appColors.storyRing,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusFull),
                          ),
                          child: Text(
                            conversation.unreadCount > 99
                                ? '99+'
                                : '${conversation.unreadCount}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.surface,
                              fontWeight: FontWeight.w700,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      if (conversation.isMuted)
                        Padding(
                          padding:
                              const EdgeInsets.only(left: AppTheme.spacingSm),
                          child: Icon(
                            Icons.notifications_off_rounded,
                            size: AppTheme.iconSm - 4,
                            color: appColors.subtleText,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _lastMessagePreview(ChatMessage? msg) {
    if (msg == null) return 'Tap to start chatting';
    switch (msg.type) {
      case MessageType.photo:
        return '📸 Photo';
      case MessageType.video:
        return '🎥 Video';
      case MessageType.voice:
        return '🎤 Voice message';
      case MessageType.snap:
        return '👻 Snap';
      case MessageType.text:
        return msg.content;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return 'Now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${time.month}/${time.day}';
  }
}
