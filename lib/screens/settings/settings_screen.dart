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
  final TextEditingController _search = TextEditingController();
  bool _nudgeDismissed = true;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      if (mounted) {
        setState(() => _nudgeDismissed = prefs.getBool(_dismiss2faNudgeKey) ?? false);
      }
    });
    _search.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
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
        content: const Text('You can save this account for one-tap access next time.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(dialogContext).pop('logout'), child: const Text('Log out')),
          TextButton(onPressed: () => Navigator.of(dialogContext).pop('remember'), child: const Text('Save & log out')),
        ],
      ),
    );
    if (choice == null || !context.mounted) return;
    await context.read<AuthProvider>().logout(remember: choice == 'remember');
    if (context.mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final query = _search.text.trim().toLowerCase();
    final entries = SettingsCatalog.directory.where((entry) {
      return query.isEmpty || entry.title.toLowerCase().contains(query) || entry.subtitle.toLowerCase().contains(query);
    }).toList();
    final showNudge = !(auth.currentUser?.twoFactorEnabled ?? false) && !_nudgeDismissed;

    return Scaffold(
      body: Column(
        children: [
          const AppTopBar(showBack: true, title: 'Settings'),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppTheme.spacingLg, AppTheme.spacingSm, AppTheme.spacingLg, AppTheme.spacingXs),
            child: TextField(
              controller: _search,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search settings',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: query.isEmpty ? null : IconButton(icon: const Icon(Icons.clear_rounded), onPressed: _search.clear),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: AppTheme.spacingHuge),
              children: [
                if (showNudge && query.isEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(AppTheme.spacingLg, AppTheme.spacingMd, AppTheme.spacingLg, 0),
                    child: Material(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        onTap: () => context.push('/settings-2fa'),
                        child: Padding(
                          padding: const EdgeInsets.all(AppTheme.spacingMd),
                          child: Row(children: [
                            const Icon(Icons.shield_outlined),
                            const SizedBox(width: AppTheme.spacingMd),
                            const Expanded(child: Text('Turn on two-factor authentication to keep your account safer.')),
                            IconButton(tooltip: 'Dismiss', icon: const Icon(Icons.close_rounded), onPressed: _dismissNudge),
                          ]),
                        ),
                      ),
                    ),
                  ),
                if (query.isEmpty) ...[
                  const SettingsGroupLabel(label: 'Account'),
                  SettingsNavigationRow(
                    icon: Icons.person_outline_rounded,
                    title: auth.currentUser?.displayName ?? 'Account',
                    subtitle: auth.currentUser == null ? null : '@${auth.currentUser!.username}',
                    onTap: () => context.push('/settings/account'),
                  ),
                ],
                SettingsGroupLabel(label: query.isEmpty ? 'All settings' : 'Search results'),
                if (entries.isEmpty)
                  const Padding(padding: EdgeInsets.all(AppTheme.spacingXl), child: Text('No settings match your search.'))
                else
                  ...entries.map((entry) => SettingsNavigationRow(
                        icon: entry.icon,
                        title: entry.title,
                        subtitle: entry.subtitle,
                        onTap: () => context.push(entry.route),
                      )),
                if (query.isEmpty) ...[
                  const SettingsGroupLabel(label: 'Safety & account actions'),
                  SettingsNavigationRow(icon: Icons.devices_other_rounded, title: 'Sessions', onTap: () => context.push('/settings-sessions')),
                  SettingsNavigationRow(icon: Icons.verified_user_outlined, title: 'Account status', onTap: () => context.push('/settings-account-status')),
                  SettingsNavigationRow(icon: Icons.download_outlined, title: 'My Data', onTap: () => context.push('/settings-my-data')),
                  SettingsNavigationRow(icon: Icons.block_rounded, title: 'Blocked accounts', onTap: () => context.push('/settings-blocked')),
                  SettingsNavigationRow(icon: Icons.admin_panel_settings_outlined, title: 'App permissions', onTap: () => context.push('/settings-permissions')),
                  SettingsNavigationRow(icon: Icons.flag_outlined, title: 'My Reports', onTap: () => context.push('/settings-my-reports')),
                  SettingsNavigationRow(icon: Icons.info_outline_rounded, title: 'About SwiftSnap', onTap: () => context.push('/settings-about')),
                  SettingsNavigationRow(icon: Icons.delete_outline_rounded, title: 'Delete account', destructive: true, onTap: () => context.push('/settings-delete-account')),
                  SettingsActionRow(title: 'Log out', destructive: true, onTap: () => _logout(context)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
