import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/social.dart';
import '../providers/social_provider.dart';
import '../theme/theme.dart';
import '../widgets/common/app_top_bar.dart';
import '../widgets/common/async_state_view.dart';
import '../widgets/common/snap_avatar.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<SocialProvider>().loadNotifications();
    });
  }

  IconData _iconFor(NotificationKind kind) {
    switch (kind) {
      case NotificationKind.message:
        return Icons.chat_bubble_outline_rounded;
      case NotificationKind.friendRequest:
      case NotificationKind.friendAccepted:
        return Icons.person_add_alt_1_rounded;
      case NotificationKind.story:
        return Icons.auto_stories_rounded;
      case NotificationKind.reel:
        return Icons.play_circle_outline_rounded;
      case NotificationKind.comment:
        return Icons.mode_comment_outlined;
      case NotificationKind.like:
        return Icons.favorite_border_rounded;
      case NotificationKind.mention:
        return Icons.alternate_email_rounded;
      case NotificationKind.creator:
        return Icons.workspace_premium_outlined;
      case NotificationKind.system:
        return Icons.info_outline_rounded;
    }
  }

  void _open(AppNotification notification) {
    switch (notification.kind) {
      case NotificationKind.message:
        if (notification.targetId != null) {
          context.push('/chat/${notification.targetId}');
        }
        break;
      case NotificationKind.friendRequest:
      case NotificationKind.friendAccepted:
        context.push('/friends');
        break;
      default:
        if (notification.actor != null) {
          context.push('/user/${notification.actor!.id}');
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;
    final provider = context.watch<SocialProvider>();

    return Scaffold(
      body: Column(
        children: [
          AppTopBar(
            showBack: true,
            title: 'Notifications',
            actions: [
              TextButton(
                onPressed: () async {
                  final error = await provider.markNotificationsRead();
                  if (!context.mounted || error == null) return;
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(error)));
                },
                child: const Text('Mark read'),
              ),
            ],
          ),
          Expanded(
            child: AsyncStateView<List<AppNotification>>(
              state: provider.notifications,
              emptyIcon: Icons.notifications_none_rounded,
              emptyTitle: 'You are all caught up',
              onRetry: provider.loadNotifications,
              builder: (notifications) => ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return ListTile(
                    leading: notification.actor != null
                        ? SnapAvatar(
                            imageUrl: notification.actor!.avatarUrl,
                            renderUrl: notification.actor!.avatarRenderUrl,
                            fallbackText: notification.actor!.displayName,
                            size: AppTheme.avatarSm,
                          )
                        : Icon(_iconFor(notification.kind)),
                    title: Text(
                      notification.title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: notification.isRead
                            ? FontWeight.w400
                            : FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      notification.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: appColors.subtleText),
                    ),
                    onTap: () => _open(notification),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
