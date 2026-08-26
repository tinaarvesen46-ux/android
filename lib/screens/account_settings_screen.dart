import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/theme.dart';
import '../providers/app_provider.dart';
import 'edit_field_screen.dart';
import 'subscription_plans_screen.dart';
import 'notifications_settings_screen.dart';
import 'bitmoji_screen.dart';
import 'manage_extensions_screen.dart';
import 'my_selfie_screen.dart';
import 'two_factor_auth_screen.dart';
import 'memories_screen.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwiftSnapTheme.backgroundDark,
      body: SafeArea(
        child: Consumer<AppProvider>(
          builder: (context, provider, _) {
            final user = provider.currentUser;
            if (user == null) return const SizedBox();
            
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildHeader(context),
                _buildAccountSection(context, user),
                const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
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
              'My Account',
              style: TextStyle(
                color: SwiftSnapTheme.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context, dynamic user) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          decoration: BoxDecoration(
            color: SwiftSnapTheme.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              _buildAccountTile(
                context,
                title: 'Name',
                value: user.displayName,
                onTap: () => _navigateToEdit(
                  context,
                  'Name',
                  user.displayName,
                  (value) => user.copyWith(displayName: value),
                ),
              ),
              _buildDivider(),
              _buildAccountTile(
                context,
                title: 'Username',
                value: user.username,
                onTap: () => _navigateToEdit(
                  context,
                  'Username',
                  user.username,
                  (value) => user.copyWith(username: value),
                ),
              ),
              _buildDivider(),
              _buildAccountTile(
                context,
                title: 'Birthday',
                value: user.birthday ?? 'Not set',
                onTap: () => _showBirthdayPicker(context),
              ),
              _buildDivider(),
              _buildAccountTile(
                context,
                title: 'Mobile Number',
                value: user.phone ?? 'Not set',
                onTap: () => _navigateToEdit(
                  context,
                  'Mobile Number',
                  user.phone ?? '',
                  (value) => user,
                ),
              ),
              _buildDivider(),
              _buildAccountTile(
                context,
                title: 'Email',
                value: user.email ?? 'email@example.com',
                onTap: () => _navigateToEdit(
                  context,
                  'Email',
                  user.email ?? 'email@example.com',
                  (value) => user.copyWith(email: value),
                ),
              ),
              _buildDivider(),
              _buildAccountTile(
                context,
                title: 'SwiftSnap+',
                value: 'NEW',
                valueColor: SwiftSnapTheme.primaryPink,
                showBadge: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SubscriptionPlansScreen()),
                ),
              ),
              _buildDivider(),
              _buildAccountTile(
                context,
                title: 'Bitmoji',
                value: 'Not linked',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BitmojiScreen()),
                ),
              ),
              _buildDivider(),
              _buildAccountTile(
                context,
                title: 'Manage Extensions',
                value: '',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ManageExtensionsScreen()),
                ),
              ),
              _buildDivider(),
              _buildAccountTile(
                context,
                title: 'My Selfie',
                value: '',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MySelfieScreen()),
                ),
              ),
              _buildDivider(),
              _buildAccountTile(
                context,
                title: 'Password',
                value: '••••••••',
                onTap: () => _navigateToEdit(
                  context,
                  'Password',
                  '••••••••',
                  (value) => user,
                  isPassword: true,
                ),
              ),
              _buildDivider(),
              _buildAccountTile(
                context,
                title: 'Two-Factor Authentication',
                value: '',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TwoFactorAuthScreen()),
                ),
              ),
              _buildDivider(),
              _buildAccountTile(
                context,
                title: 'Notifications',
                value: '',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationsSettingsScreen()),
                ),
              ),
              _buildDivider(),
              _buildAccountTile(
                context,
                title: 'Memories',
                value: '',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MemoriesScreen()),
                ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0),
    );
  }

  Widget _buildAccountTile(
    BuildContext context, {
    required String title,
    required String value,
    Color? valueColor,
    bool showBadge = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        color: Colors.transparent,
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: SwiftSnapTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (value.isNotEmpty) ...[
              if (showBadge)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        SwiftSnapTheme.primaryPurple,
                        SwiftSnapTheme.primaryPink,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              else
                Text(
                  value,
                  style: TextStyle(
                    color: valueColor ?? SwiftSnapTheme.textSecondary,
                    fontSize: 15,
                  ),
                ),
              const SizedBox(width: 8),
            ],
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

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Divider(
        height: 1,
        thickness: 1,
        color: Colors.white.withOpacity(0.05),
      ),
    );
  }

  void _navigateToEdit(
    BuildContext context,
    String fieldName,
    String currentValue,
    Function(String) onSave, {
    bool isPassword = false,
  }) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => EditFieldScreen(
          fieldName: fieldName,
          currentValue: currentValue,
          onSave: onSave,
          isPassword: isPassword,
        ),
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

  void _showBirthdayPicker(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: DateTime(1995, 1, 15),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: SwiftSnapTheme.primaryPurple,
              onPrimary: Colors.white,
              surface: SwiftSnapTheme.surfaceColor,
              onSurface: SwiftSnapTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
  }
}
