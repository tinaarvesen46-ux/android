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
                  icon: Icons.block_rounded,
                  title: 'Blocked accounts',
                  onTap: () => context.push('/settings-blocked'),
                ),
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
                const SettingsGroupLabel(label: 'Account'),
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
