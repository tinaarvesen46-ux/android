import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/account.dart';
import '../../providers/account_provider.dart';
import '../../theme/theme.dart';
import '../../widgets/common/app_top_bar.dart';
import '../../widgets/common/async_state_view.dart';
import '../../widgets/common/settings_rows.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AccountProvider>().loadNotificationSettings();
    });
  }

  void _patch(Map<String, dynamic> patch) {
    context.read<AccountProvider>().updateNotificationSettings(patch);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AccountProvider>();

    return Scaffold(
      body: Column(
        children: [
          const AppTopBar(showBack: true, title: 'Notifications'),
          Expanded(
            child: AsyncStateView<NotificationSettings>(
              state: provider.notificationSettings,
              onRetry: provider.loadNotificationSettings,
              builder: (s) => ListView(
                children: [
                  const SettingsGroupLabel(label: 'Delivery'),
                  SettingsToggleRow(
                    title: 'Push notifications',
                    value: s.pushEnabled,
                    onChanged: (v) => _patch({'push_enabled': v}),
                  ),
                  SettingsToggleRow(
                    title: 'Email notifications',
                    value: s.emailEnabled,
                    onChanged: (v) => _patch({'email_enabled': v}),
                  ),
                  SettingsToggleRow(
                    title: 'SMS notifications',
                    value: s.smsEnabled,
                    onChanged: (v) => _patch({'sms_enabled': v}),
                  ),
                  const SettingsGroupLabel(label: 'Activity'),
                  SettingsToggleRow(
                    title: 'Messages',
                    value: s.newMessage,
                    onChanged: (v) => _patch({'new_message': v}),
                  ),
                  SettingsToggleRow(
                    title: 'Friend requests',
                    value: s.friendRequest,
                    onChanged: (v) => _patch({'friend_request': v}),
                  ),
                  SettingsToggleRow(
                    title: 'Friend accepted',
                    value: s.friendAccepted,
                    onChanged: (v) => _patch({'friend_accepted': v}),
                  ),
                  SettingsToggleRow(
                    title: 'Story views',
                    value: s.storyView,
                    onChanged: (v) => _patch({'story_view': v}),
                  ),
                  SettingsToggleRow(
                    title: 'Story reactions',
                    value: s.storyReaction,
                    onChanged: (v) => _patch({'story_reaction': v}),
                  ),
                  SettingsToggleRow(
                    title: 'Streak reminders',
                    value: s.streakReminder,
                    onChanged: (v) => _patch({'streak_reminder': v}),
                  ),
                  SettingsToggleRow(
                    title: 'Streak achievements',
                    value: s.streakAchievement,
                    onChanged: (v) => _patch({'streak_achievement': v}),
                  ),
                  SettingsToggleRow(
                    title: 'Mentions',
                    value: s.mention,
                    onChanged: (v) => _patch({'mention': v}),
                  ),
                  SettingsToggleRow(
                    title: 'Group invites',
                    value: s.groupInvite,
                    onChanged: (v) => _patch({'group_invite': v}),
                  ),
                  const SettingsGroupLabel(label: 'Other'),
                  SettingsToggleRow(
                    title: 'Security alerts',
                    subtitle: 'Recommended — new sign-ins and account changes',
                    value: s.securityAlerts,
                    onChanged: (v) => _patch({'security_alerts': v}),
                  ),
                  SettingsToggleRow(
                    title: 'News and offers',
                    value: s.marketingEmails,
                    onChanged: (v) => _patch({'marketing_emails': v}),
                  ),
                  const SizedBox(height: AppTheme.spacingXl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
