import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/theme.dart';
import '../../widgets/common/app_top_bar.dart';
import '../../widgets/common/settings_rows.dart';
import 'settings_catalog.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will need to sign in again to use SwiftSnap.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await context.read<AuthProvider>().logout();
    if (context.mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const AppTopBar(showBack: true, title: 'Settings'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: AppTheme.spacingHuge),
              children: [
                const SettingsGroupLabel(label: 'Account'),
                SettingsNavigationRow(
                  icon: Icons.lock_reset_rounded,
                  title: 'Password',
                  onTap: () => context.push('/settings-password'),
                ),
                SettingsNavigationRow(
                  icon: Icons.shield_outlined,
                  title: 'Two-factor authentication',
                  onTap: () => context.push('/settings-2fa'),
                ),
                SettingsNavigationRow(
                  icon: Icons.phone_iphone_rounded,
                  title: 'Mobile number',
                  onTap: () => context.push('/settings-phone'),
                ),
                SettingsNavigationRow(
                  icon: Icons.devices_other_rounded,
                  title: 'Sessions',
                  onTap: () => context.push('/settings-sessions'),
                ),
                SettingsNavigationRow(
                  icon: Icons.verified_user_outlined,
                  title: 'Account status',
                  onTap: () => context.push('/settings-account-status'),
                ),
                SettingsNavigationRow(
                  icon: Icons.flag_outlined,
                  title: 'My Reports',
                  onTap: () => context.push('/settings-my-reports'),
                ),
                const SettingsGroupLabel(label: 'Privacy'),
                SettingsNavigationRow(
                  icon: Icons.lock_outline_rounded,
                  title: 'Privacy controls',
                  onTap: () => context.push('/settings-privacy'),
                ),
                SettingsNavigationRow(
                  icon: Icons.block_rounded,
                  title: 'Blocked accounts',
                  onTap: () => context.push('/settings-blocked'),
                ),
                const SettingsGroupLabel(label: 'Notifications'),
                SettingsNavigationRow(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notification preferences',
                  onTap: () => context.push('/settings-notifications'),
                ),
                const SettingsGroupLabel(label: 'Your data'),
                SettingsNavigationRow(
                  icon: Icons.download_outlined,
                  title: 'My Data',
                  onTap: () => context.push('/settings-my-data'),
                ),
                const SettingsGroupLabel(label: 'Preferences'),
                ...SettingsCatalog.sections.map(
                  (section) => SettingsNavigationRow(
                    icon: section.icon,
                    title: section.title,
                    onTap: () => context.push('/settings/${section.id}'),
                  ),
                ),
                const SettingsGroupLabel(label: 'Safety'),
                SettingsNavigationRow(
                  icon: Icons.verified_user_outlined,
                  title: 'App permissions',
                  onTap: () => context.push('/settings-permissions'),
                ),
                const SettingsGroupLabel(label: 'About'),
                SettingsNavigationRow(
                  icon: Icons.info_outline_rounded,
                  title: 'About SwiftSnap',
                  onTap: () => context.push('/settings-about'),
                ),
                const SettingsGroupLabel(label: 'Danger zone'),
                SettingsActionRow(
                  title: 'Delete account',
                  destructive: true,
                  onTap: () => context.push('/settings-delete-account'),
                ),
                SettingsActionRow(
                  title: 'Log out',
                  destructive: true,
                  onTap: () => _logout(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
