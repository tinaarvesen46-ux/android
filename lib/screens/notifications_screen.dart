import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/theme.dart';
import '../providers/app_provider.dart';

/// Real notifications list — consumes AppProvider.notifications (loaded from
/// Laravel `notifications`) with mark-read / mark-all-read.
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
          if (provider.isLoadingData && items.isEmpty) {
            return const Center(
                child: CircularProgressIndicator(color: SwiftSnapTheme.primaryPurple));
          }
          if (items.isEmpty) {
            return const Center(
              child: Text('No notifications yet',
                  style: TextStyle(color: SwiftSnapTheme.textSecondary)),
            );
          }
          return RefreshIndicator(
            onRefresh: () => provider.loadInitialData(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final n = items[i];
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
              },
            ),
          );
        },
      ),
    );
  }
}
