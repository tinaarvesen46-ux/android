import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/theme.dart';
import '../providers/app_provider.dart';
import '../api/services/settings_service.dart';
import 'account_settings_screen.dart';
import 'password_settings_screen.dart';
import 'notifications_settings_screen.dart';
import 'appearance_settings_screen.dart';
import 'blocked_users_screen.dart';
import 'reports_screen.dart';
import 'privacy_settings_screen.dart';
import 'security_screen.dart';
import 'help_support_screen.dart';
import 'about_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwiftSnapTheme.backgroundDark,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildHeader(context),
            _buildSnapchatPlusCard(),
            _buildShortcutsSection(context),
            _buildPublicProfileSection(),
            _buildAppPrivacySection(context),
            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: SwiftSnapTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: SwiftSnapTheme.textPrimary,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 16),
            const Text(
              'Settings',
              style: TextStyle(
                color: SwiftSnapTheme.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _showSearchDialog(context);
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: SwiftSnapTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: const Icon(
                  Icons.search_rounded,
                  color: SwiftSnapTheme.textPrimary,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSnapchatPlusCard() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                SwiftSnapTheme.primaryPurple.withOpacity(0.3),
                SwiftSnapTheme.primaryPink.withOpacity(0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      SwiftSnapTheme.primaryPurple,
                      SwiftSnapTheme.primaryPink,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.star_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Join SwiftSnap+ for \$3.99',
                      style: TextStyle(
                        color: SwiftSnapTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Exclusive features and benefits including custom emojis and more',
                      style: TextStyle(
                        color: SwiftSnapTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: SwiftSnapTheme.textSecondary,
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0),
    );
  }

  Widget _buildShortcutsSection(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'Shortcuts',
                style: TextStyle(
                  color: SwiftSnapTheme.textSecondary.withOpacity(0.7),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: SwiftSnapTheme.surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  _buildSettingsTile(
                    context,
                    icon: Icons.person_rounded,
                    title: 'My Account',
                    onTap: () => _navigate(context, const AccountSettingsScreen()),
                  ),
                  _buildDivider(),
                  _buildSettingsTile(
                    context,
                    icon: Icons.lock_rounded,
                    title: 'Password',
                    onTap: () => _navigate(context, const PasswordSettingsScreen()),
                  ),
                  _buildDivider(),
                  _buildSettingsTile(
                    context,
                    icon: Icons.notifications_rounded,
                    title: 'Notifications',
                    onTap: () => _navigate(context, const NotificationsSettingsScreen()),
                  ),
                  _buildDivider(),
                  _buildSettingsTile(
                    context,
                    icon: Icons.palette_rounded,
                    title: 'App Appearance',
                    onTap: () => _navigate(context, const AppearanceSettingsScreen()),
                  ),
                  _buildDivider(),
                  _buildSettingsTile(
                    context,
                    icon: Icons.block_rounded,
                    title: 'Blocked Users',
                    onTap: () => _navigate(context, const BlockedUsersScreen()),
                  ),
                  _buildDivider(),
                  _buildSettingsTile(
                    context,
                    icon: Icons.flag_rounded,
                    title: 'My Reports',
                    subtitle: 'See what you\'ve reported and by who',
                    onTap: () => _navigate(context, const ReportsScreen()),
                  ),
                  _buildDivider(),
                  _buildSettingsTile(
                    context,
                    icon: Icons.delete_rounded,
                    title: 'Delete Account',
                    titleColor: Colors.red,
                    onTap: () => _showDeleteAccountDialog(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms, delay: 100.ms).slideY(begin: 0.2, end: 0),
    );
  }

  Widget _buildPublicProfileSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'Public Profile Settings',
                style: TextStyle(
                  color: SwiftSnapTheme.textSecondary.withOpacity(0.7),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: SwiftSnapTheme.surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Consumer<AppProvider>(
                builder: (context, provider, _) {
                  final user = provider.currentUser;
                  return Column(
                    children: [
                      _buildProfileTile(
                        context,
                        name: user?.displayName ?? '',
                        username: user != null ? '@${user.username}' : '',
                        avatarUrl: user?.avatarUrl ?? '',
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms, delay: 200.ms).slideY(begin: 0.2, end: 0),
    );
  }

  Widget _buildAppPrivacySection(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'App & Privacy',
                style: TextStyle(
                  color: SwiftSnapTheme.textSecondary.withOpacity(0.7),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: SwiftSnapTheme.surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  _buildSettingsTile(
                    context,
                    icon: Icons.privacy_tip_rounded,
                    title: 'Privacy Control',
                    onTap: () => _navigate(context, const PrivacySettingsScreen()),
                  ),
                  _buildDivider(),
                  _buildSettingsTile(
                    context,
                    icon: Icons.security_rounded,
                    title: 'Security',
                    onTap: () => _navigate(context, const SecurityScreen()),
                  ),
                  _buildDivider(),
                  _buildSettingsTile(
                    context,
                    icon: Icons.help_rounded,
                    title: 'Help & Support',
                    onTap: () => _navigate(context, const HelpSupportScreen()),
                  ),
                  _buildDivider(),
                  _buildSettingsTile(
                    context,
                    icon: Icons.info_rounded,
                    title: 'About',
                    onTap: () => _navigate(context, const AboutScreen()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms, delay: 300.ms).slideY(begin: 0.2, end: 0),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        color: Colors.transparent,
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: SwiftSnapTheme.backgroundDark.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: titleColor ?? SwiftSnapTheme.textPrimary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: titleColor ?? SwiftSnapTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: SwiftSnapTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: SwiftSnapTheme.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTile(
    BuildContext context, {
    required String name,
    required String username,
    required String avatarUrl,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _navigate(context, const AccountSettingsScreen());
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.transparent,
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: avatarUrl.isNotEmpty
                  ? NetworkImage(avatarUrl)
                  : null,
              backgroundColor: SwiftSnapTheme.primaryPurple,
              child: avatarUrl.isEmpty
                  ? Text(
                      name[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: SwiftSnapTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    username,
                    style: TextStyle(
                      color: SwiftSnapTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Text(
              'Settings',
              style: TextStyle(
                color: SwiftSnapTheme.primaryPink,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              color: SwiftSnapTheme.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 64),
      child: Divider(
        height: 1,
        thickness: 1,
        color: Colors.white.withOpacity(0.05),
      ),
    );
  }

  void _navigate(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final passwordController = TextEditingController();
    final settingsService = SettingsService();
    bool deleting = false;
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          backgroundColor: SwiftSnapTheme.surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Delete Account?',
            style: TextStyle(
              color: SwiftSnapTheme.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'This action cannot be undone. Confirm with your password to permanently delete your account.',
                style: TextStyle(color: SwiftSnapTheme.textSecondary),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                style: const TextStyle(color: SwiftSnapTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: const TextStyle(color: SwiftSnapTheme.textSecondary),
                  filled: true,
                  fillColor: SwiftSnapTheme.backgroundDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: deleting ? null : () => Navigator.pop(dialogContext),
              child: const Text('Cancel', style: TextStyle(color: SwiftSnapTheme.textPrimary)),
            ),
            TextButton(
              onPressed: deleting
                  ? null
                  : () async {
                      if (passwordController.text.isEmpty) return;
                      setDialogState(() => deleting = true);
                      final res = await settingsService.deleteAccount(
                        password: passwordController.text,
                      );
                      if (!dialogContext.mounted) return;
                      if (res.isSuccess) {
                        Navigator.pop(dialogContext);
                        context.read<AppProvider>().logout();
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      } else {
                        setDialogState(() => deleting = false);
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          SnackBar(content: Text(res.errorMessage)),
                        );
                      }
                    },
              child: deleting
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red))
                  : const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: SwiftSnapTheme.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                style: const TextStyle(color: SwiftSnapTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search settings...',
                  hintStyle: TextStyle(color: SwiftSnapTheme.textSecondary),
                  prefixIcon: const Icon(Icons.search, color: SwiftSnapTheme.textSecondary),
                  filled: true,
                  fillColor: SwiftSnapTheme.backgroundDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildSearchResult('Notifications', Icons.notifications_rounded, context),
              _buildSearchResult('Privacy Control', Icons.privacy_tip_rounded, context),
              _buildSearchResult('Security', Icons.security_rounded, context),
              _buildSearchResult('Blocked Users', Icons.block_rounded, context),
              _buildSearchResult('App Appearance', Icons.palette_rounded, context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResult(String title, IconData icon, BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: SwiftSnapTheme.primaryPurple),
      title: Text(
        title,
        style: const TextStyle(
          color: SwiftSnapTheme.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        // Navigate to the respective screen
      },
    );
  }
}
