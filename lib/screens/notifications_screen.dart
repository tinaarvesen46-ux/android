import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/theme.dart';
import '../providers/app_provider.dart';
import '../models/friend_request_model.dart';

/// Real notifications list — consumes AppProvider.notifications (loaded from
/// Laravel `notifications`) + surfaces pending friend requests with real
/// Accept/Decline actions.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwiftSnapTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: SwiftSnapTheme.surfaceColor,
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
        actions: [
          Consumer<AppProvider>(
            builder: (context, p, _) => p.unreadNotificationCount > 0
                ? TextButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      p.markAllNotificationsRead();
                    },
                    child: const Text('Mark all read',
                        style: TextStyle(color: SwiftSnapTheme.primaryPurple)),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          final items = provider.notifications;
          final requests = provider.friendRequests;
          if (provider.isLoadingData && items.isEmpty && requests.isEmpty) {
            return const Center(
                child: CircularProgressIndicator(color: SwiftSnapTheme.primaryPurple));
          }
          if (items.isEmpty && requests.isEmpty) {
            return const Center(
              child: Text('No notifications yet',
                  style: TextStyle(color: SwiftSnapTheme.textSecondary)),
            );
          }
          return RefreshIndicator(
            onRefresh: () => provider.loadInitialData(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (requests.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8, left: 2),
                    child: Text('Friend Requests',
                        style: TextStyle(
                            color: SwiftSnapTheme.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w700)),
                  ),
                  ...requests.map((r) => _FriendRequestTile(request: r)),
                  if (items.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8, left: 2),
                      child: Text('Activity',
                          style: TextStyle(
                              color: SwiftSnapTheme.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ],
                for (final n in items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _notificationTile(context, provider, n),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _notificationTile(BuildContext context, AppProvider provider, Map<String, dynamic> n) {
    final unread = n['is_read'] != true && n['read_at'] == null;
    return GestureDetector(
      onTap: () {
        if (unread) provider.markNotificationRead('${n['id']}');
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: unread
              ? SwiftSnapTheme.primaryPurple.withOpacity(0.10)
              : SwiftSnapTheme.surfaceColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: unread
                ? SwiftSnapTheme.primaryPurple.withOpacity(0.3)
                : Colors.white.withOpacity(0.08),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(top: 4, right: 12),
              decoration: BoxDecoration(
                color: unread ? SwiftSnapTheme.primaryPurple : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${n['title'] ?? n['type'] ?? 'Notification'}',
                    style: TextStyle(
                      color: SwiftSnapTheme.textPrimary,
                      fontWeight: unread ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  if (n['body'] != null) ...[
                    const SizedBox(height: 2),
                    Text('${n['body']}',
                        style: const TextStyle(
                            color: SwiftSnapTheme.textSecondary, fontSize: 13)),
                  ],
                  if (n['sent_at'] != null || n['created_at'] != null) ...[
                    const SizedBox(height: 4),
                    Text('${n['sent_at'] ?? n['created_at']}',
                        style: const TextStyle(
                            color: SwiftSnapTheme.textMuted, fontSize: 11)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Inline friend-request card with real Accept / Decline that persist through
/// Laravel and refresh the friends list.
class _FriendRequestTile extends StatefulWidget {
  final FriendRequestModel request;
  const _FriendRequestTile({required this.request});
  @override
  State<_FriendRequestTile> createState() => _FriendRequestTileState();
}

class _FriendRequestTileState extends State<_FriendRequestTile> {
  bool _busy = false;

  Future<void> _act(bool accept) async {
    if (_busy) return;
    setState(() => _busy = true);
    HapticFeedback.lightImpact();
    final p = context.read<AppProvider>();
    final err = accept
        ? await p.acceptFriendRequest(widget.request.id)
        : await p.declineFriendRequest(widget.request.id);
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(err ??
          (accept
              ? 'You are now friends with @${widget.request.sender.username}'
              : 'Request from @${widget.request.sender.username} declined')),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.request.sender;
    final avatar = s.avatarUrl;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SwiftSnapTheme.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SwiftSnapTheme.primaryPurple.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: SwiftSnapTheme.primaryPurple.withOpacity(0.2),
            backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
            child: avatar.isEmpty
                ? Text(s.username.isNotEmpty ? s.username[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.displayName.isNotEmpty ? s.displayName : '@${s.username}',
                    style: const TextStyle(
                        color: SwiftSnapTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
                const Text('wants to be friends',
                    style: TextStyle(color: SwiftSnapTheme.textMuted, fontSize: 12)),
              ],
            ),
          ),
          if (_busy)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: SizedBox(
                  width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else ...[
            GestureDetector(
              key: const Key('decline-friend-request-btn'),
              onTap: () => _act(false),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded, color: SwiftSnapTheme.textSecondary, size: 20),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              key: const Key('accept-friend-request-btn'),
              onTap: () => _act(true),
              child: Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  gradient: SwiftSnapTheme.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 20),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
