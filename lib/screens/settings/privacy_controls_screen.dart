import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/account.dart';
import '../../providers/account_provider.dart';
import '../../theme/theme.dart';
import '../../widgets/common/app_top_bar.dart';
import '../../widgets/common/async_state_view.dart';
import '../../widgets/common/settings_rows.dart';

/// Real, server-enforced privacy controls (Laravel `UserSettings`). Every
/// toggle here calls `PUT /users/me/settings` and the change takes effect
/// on the next request from any client — not just this device.
class PrivacyControlsScreen extends StatefulWidget {
  const PrivacyControlsScreen({super.key});

  @override
  State<PrivacyControlsScreen> createState() => _PrivacyControlsScreenState();
}

class _PrivacyControlsScreenState extends State<PrivacyControlsScreen> {
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AccountProvider>().loadPrivacySettings();
    });
  }

  Future<void> _patch(Map<String, dynamic> patch) async {
    final error = await context.read<AccountProvider>().updatePrivacySettings(patch);
    if (mounted) setState(() => _error = error);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AccountProvider>();
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;

    return Scaffold(
      body: Column(
        children: [
          const AppTopBar(showBack: true, title: 'Privacy controls'),
          if (_error != null)
            InlineErrorBar(message: _error!, onRetry: null),
          Expanded(
            child: AsyncStateView<PrivacySettings>(
              state: provider.privacy,
              onRetry: provider.loadPrivacySettings,
              builder: (settings) => ListView(
                children: [
                  const SettingsGroupLabel(label: 'Who can reach you'),
                  SettingsNavigationRow(
                    title: 'Contact me',
                    value: _label(settings.allowMessagesFrom),
                    onTap: () => _showPicker(
                      context,
                      title: 'Who can message you',
                      current: settings.allowMessagesFrom,
                      options: const ['everyone', 'friends', 'nobody'],
                      onSelected: (v) => _patch({'allow_messages_from': v}),
                    ),
                  ),
                  SettingsNavigationRow(
                    title: 'Friend requests',
                    value: _label(settings.allowFriendRequestsFrom),
                    onTap: () => _showPicker(
                      context,
                      title: 'Who can send you friend requests',
                      current: settings.allowFriendRequestsFrom,
                      options: const ['everyone', 'friends_of_friends', 'nobody'],
                      onSelected: (v) => _patch({'allow_friend_requests_from': v}),
                    ),
                  ),
                  SettingsNavigationRow(
                    title: 'View my story',
                    value: _label(settings.storyVisibility),
                    onTap: () => _showPicker(
                      context,
                      title: 'Who can view your story',
                      current: settings.storyVisibility,
                      options: const ['everyone', 'friends', 'custom'],
                      onSelected: (v) => _patch({'story_visibility': v}),
                    ),
                  ),
                  SettingsNavigationRow(
                    title: 'Blocked accounts',
                    onTap: () => context.push('/settings-blocked'),
                  ),
                  const SettingsGroupLabel(label: 'Language'),
                  SettingsNavigationRow(
                    title: 'App language',
                    value: _languageLabel(settings.language),
                    onTap: () => _showPicker(
                      context,
                      title: 'App language',
                      current: settings.language,
                      options: const ['en', 'es', 'fr', 'de', 'pt', 'hi', 'ja'],
                      onSelected: (v) => _patch({'language': v}),
                      labelFor: _languageLabel,
                    ),
                  ),
                  const SettingsGroupLabel(label: 'Activity'),
                  SettingsToggleRow(
                    title: 'Activity indicator',
                    subtitle: 'Let friends see when you\'re online',
                    value: settings.showOnlineStatus,
                    onChanged: (v) => _patch({'show_online_status': v}),
                  ),
                  SettingsToggleRow(
                    title: 'Read receipts',
                    subtitle: 'Show when you\'ve seen a message',
                    value: settings.showReadReceipts,
                    onChanged: (v) => _patch({'show_read_receipts': v}),
                  ),
                  SettingsToggleRow(
                    title: 'Typing indicator',
                    value: settings.showTypingIndicator,
                    onChanged: (v) => _patch({'show_typing_indicator': v}),
                  ),
                  const SettingsGroupLabel(label: 'Security alerts'),
                  SettingsToggleRow(
                    title: 'New login alerts',
                    subtitle: 'Email me when a new device signs in',
                    value: settings.loginAlerts,
                    onChanged: (v) => _patch({'login_alerts': v}),
                  ),
                  SettingsToggleRow(
                    title: 'Screenshot alerts',
                    subtitle: 'Notify friends if you screenshot a chat',
                    value: settings.screenshotAlerts,
                    onChanged: (v) => _patch({'screenshot_alerts': v}),
                  ),
                  const SettingsGroupLabel(label: 'My data'),
                  SettingsToggleRow(
                    title: 'Personalisation',
                    subtitle: 'Use your activity to rank Discover for you',
                    value: settings.dataSharingPersonalization,
                    onChanged: (v) => _patch({'data_sharing_personalization': v}),
                  ),
                  SettingsToggleRow(
                    title: 'Usage analytics',
                    subtitle: 'Help improve SwiftSnap with anonymous usage data',
                    value: settings.dataSharingAnalytics,
                    onChanged: (v) => _patch({'data_sharing_analytics': v}),
                  ),
                  SettingsNavigationRow(
                    title: 'My Data',
                    subtitle: 'Download a copy of your account data',
                    onTap: () => context.push('/settings-my-data'),
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

  String _label(String v) => v
      .split('_')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');

  static const Map<String, String> _languageNames = {
    'en': 'English',
    'es': 'Español',
    'fr': 'Français',
    'de': 'Deutsch',
    'pt': 'Português',
    'hi': 'हिन्दी',
    'ja': '日本語',
  };

  String _languageLabel(String code) => _languageNames[code] ?? code;

  void _showPicker(
    BuildContext context, {
    required String title,
    required String current,
    required List<String> options,
    required Future<void> Function(String) onSelected,
    String Function(String)? labelFor,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              child: Text(title, style: Theme.of(context).textTheme.titleMedium),
            ),
            ...options.map((o) => RadioListTile<String>(
                  value: o,
                  groupValue: current,
                  title: Text(labelFor != null ? labelFor(o) : _label(o)),
                  onChanged: (v) {
                    Navigator.of(sheetContext).pop();
                    if (v != null) onSelected(v);
                  },
                )),
            const SizedBox(height: AppTheme.spacingMd),
          ],
        ),
      ),
    );
  }
}
