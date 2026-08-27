import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/theme.dart';
import '../models/chat_model.dart';

class ChatTile extends StatelessWidget {
  final ChatModel chat;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  
  const ChatTile({
    super.key,
    required this.chat,
    required this.onTap,
    required this.onLongPress,
  });
  
  @override
  Widget build(BuildContext context) {
    final hasUnread = chat.unreadCount > 0;
    
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: hasUnread
              ? SwiftSnapTheme.primaryPurple.withOpacity(0.08)
              : SwiftSnapTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasUnread
                ? SwiftSnapTheme.primaryPurple.withOpacity(0.2)
                : Colors.white.withOpacity(0.06),
          ),
        ),
        child: Row(
          children: [
            _buildAvatar(),
            const SizedBox(width: 12),
            Expanded(child: _buildContent()),
            _buildTrailing(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAvatar() {
    return Stack(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: chat.participant.isOnline
                ? SwiftSnapTheme.primaryGradient
                : null,
            border: !chat.participant.isOnline
                ? Border.all(
                    color: Colors.white.withOpacity(0.15),
                    width: 2,
                  )
                : null,
          ),
          padding: const EdgeInsets.all(2),
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl: chat.participant.avatarUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: SwiftSnapTheme.backgroundCard,
              ),
              errorWidget: (context, url, error) => Container(
                color: SwiftSnapTheme.backgroundCard,
                child: const Icon(
                  Icons.person_rounded,
                  color: SwiftSnapTheme.textMuted,
                ),
              ),
            ),
          ),
        ),
        if (chat.participant.isOnline)
          Positioned(
            right: 2,
            bottom: 2,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: SwiftSnapTheme.online,
                shape: BoxShape.circle,
                border: Border.all(
                  color: SwiftSnapTheme.surfaceColor,
                  width: 2,
                ),
              ),
            ),
          ),
        if (chat.isPinned)
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                gradient: SwiftSnapTheme.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.push_pin_rounded,
                color: Colors.white,
                size: 10,
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildContent() {
    final hasUnread = chat.unreadCount > 0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                chat.title,
                style: TextStyle(
                  color: SwiftSnapTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (!chat.isGroup && chat.participant.isVerified) ...[
              const SizedBox(width: 4),
              const Icon(
                Icons.verified_rounded,
                color: SwiftSnapTheme.primaryPurple,
                size: 16,
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            if (chat.lastMessage.senderId == 'user_001') ...[
              Icon(
                _getMessageStatusIcon(),
                size: 14,
                color: chat.lastMessage.isRead
                    ? SwiftSnapTheme.primaryPurple
                    : SwiftSnapTheme.textMuted,
              ),
              const SizedBox(width: 4),
            ],
            Expanded(
              child: Text(
                chat.lastMessage.content,
                style: TextStyle(
                  color: hasUnread
                      ? SwiftSnapTheme.textPrimary
                      : SwiftSnapTheme.textMuted,
                  fontSize: 14,
                  fontWeight: hasUnread ? FontWeight.w500 : FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildTrailing() {
    final hasUnread = chat.unreadCount > 0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          chat.lastMessage.timeFormatted,
          style: TextStyle(
            color: hasUnread
                ? SwiftSnapTheme.primaryPurple
                : SwiftSnapTheme.textMuted,
            fontSize: 12,
            fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        const SizedBox(height: 6),
        if (hasUnread)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              gradient: SwiftSnapTheme.primaryGradient,
              borderRadius: BorderRadius.circular(10),
              boxShadow: SwiftSnapTheme.glowShadow(
                SwiftSnapTheme.primaryPurple,
                intensity: 0.3,
              ),
            ),
            child: Text(
              chat.unreadCount > 99 ? '99+' : chat.unreadCount.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          )
        else if (chat.isMuted)
          const Icon(
            Icons.notifications_off_outlined,
            size: 16,
            color: SwiftSnapTheme.textMuted,
          )
        else
          const SizedBox(height: 20),
      ],
    );
  }
  
  IconData _getMessageStatusIcon() {
    switch (chat.lastMessage.status) {
      case MessageStatus.sending:
        return Icons.schedule_rounded;
      case MessageStatus.sent:
        return Icons.done_rounded;
      case MessageStatus.delivered:
        return Icons.done_all_rounded;
      case MessageStatus.read:
        return Icons.done_all_rounded;
      case MessageStatus.failed:
        return Icons.error_outline_rounded;
    }
  }
}
