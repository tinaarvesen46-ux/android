import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/auth_provider.dart';
import '../../theme/theme.dart';
import '../../widgets/common/app_top_bar.dart';
import '../../widgets/common/settings_rows.dart';
import 'settings_catalog.dart';

const _dismiss2faNudgeKey = 'dismissed_2fa_nudge';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _nudgeDismissed = true;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      if (mounted) {
        setState(
          () => _nudgeDismissed = prefs.getBool(_dismiss2faNudgeKey) ?? false,
        );
      }
    });
  }

  Future<void> _dismissNudge() async {
    setState(() => _nudgeDismissed = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dismiss2faNudgeKey, true);
  }

  Future<void> _logout(BuildContext context) async {
    final choice = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text(
          'You can save this account so it appears on the sign-in screen for one-tap access next time.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(null),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop('logout'),
            child: const Text('Log out'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop('remember'),
            child: const Text('Save & log out'),
          ),
        ],
      ),
    );
    if (choice == null || !context.mounted) return;
    await context.read<AuthProvider>().logout(remember: choice == 'remember');
    if (context.mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final twoFactorOn =
        context.watch<AuthProvider>().currentUser?.twoFactorEnabled ?? false;
    final showNudge = !twoFactorOn && !_nudgeDismissed;

    return Scaffold(
      body: Column(
        children: [
          const AppTopBar(showBack: true, title: 'Settings'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: AppTheme.spacingHuge),
              children: [
                if (showNudge)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppTheme.spacingLg,
                      AppTheme.spacingMd,
                      AppTheme.spacingLg,
                      0,
                    ),
                    child: Material(
                      key: const Key('two-factor-nudge-banner'),
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        onTap: () => context.push('/settings-2fa'),
                        child: Padding(
                          padding: const EdgeInsets.all(AppTheme.spacingMd),
                          child: Row(
                            children: [
                              const Icon(Icons.shield_outlined),
                              const SizedBox(width: AppTheme.spacingMd),
                              const Expanded(
                                child: Text(
                                  'Turn on two-factor authentication to keep your account safer.',
                                ),
                              ),
                              IconButton(
                                key: const Key('two-factor-nudge-dismiss'),
                                icon: const Icon(Icons.close_rounded,
                                    size: AppTheme.iconSm),
                                onPressed: _dismissNudge,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
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
