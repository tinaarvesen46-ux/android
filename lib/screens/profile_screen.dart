import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/theme.dart';
import '../providers/app_provider.dart';
import '../models/user_model.dart';
import '../widgets/staff_badge.dart';
import 'edit_profile_screen.dart';
import 'friends_screen.dart';
import 'settings_screen.dart';
import 'language_settings_screen.dart';
import 'download_data_screen.dart';
import 'blocked_users_screen.dart';
import 'help_support_screen.dart';
import 'privacy_policy_screen.dart';
import 'achievements_screen.dart';
import 'avatar_studio_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwiftSnapTheme.backgroundDark,
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          final user = provider.currentUser;
          if (user == null) return const SizedBox();
          
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildHeader(user),
              _buildProfileCard(user),
              _buildStatsCard(user, provider),
              _buildSettingsSection(),
              _buildPrivacySection(),
              _buildAccountSection(),
              const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildHeader(dynamic user) {
    return SliverToBoxAdapter(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  SwiftSnapTheme.primaryPurple.withOpacity(0.6),
                  SwiftSnapTheme.primaryPink.withOpacity(0.4),
                  SwiftSnapTheme.backgroundDark,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Row(
                  children: [
                    _buildHeaderButton(Icons.share_rounded),
                    const SizedBox(width: 8),
                    _buildHeaderButton(Icons.settings_rounded),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHeaderButton(IconData icon) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (icon == Icons.settings_rounded) {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const SettingsScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
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
        } else if (icon == Icons.share_rounded) {
          Share.share(
            'Check out my SwiftSnap profile!',
            subject: 'My SwiftSnap Profile',
          );
        }
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: icon == Icons.settings_rounded 
              ? SwiftSnapTheme.primaryPurple.withOpacity(0.25)
              : Colors.white.withOpacity(0.15),
          shape: BoxShape.circle,
          border: Border.all(
            color: icon == Icons.settings_rounded
                ? SwiftSnapTheme.primaryPurple.withOpacity(0.4)
                : Colors.white.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: icon == Icons.settings_rounded ? [
            BoxShadow(
              color: SwiftSnapTheme.primaryPurple.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ] : null,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }
  
  Widget _buildProfileCard(dynamic user) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: SwiftSnapTheme.surfaceColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SwiftSnapTheme.primaryGradient,
                    boxShadow: SwiftSnapTheme.glowShadow(
                      SwiftSnapTheme.primaryPurple,
                      intensity: 0.3,
                    ),
                  ),
                  padding: const EdgeInsets.all(3),
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: user.avatarUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              user.displayName,
                              style: const TextStyle(
                                color: SwiftSnapTheme.textPrimary,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          if (user.accountStatus == AccountStatus.creator)
                            Container(
                              width: 22,
                              height: 22,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFFFD700),
                                    Color(0xFFFFA500),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFFFFD700),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.star_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                            )
                          else if (user.isVerified || user.accountStatus == AccountStatus.verified)
                            const Icon(
                              Icons.verified_rounded,
                              color: SwiftSnapTheme.primaryPurple,
                              size: 20,
                            ),
                          if (user.staffRole != StaffRole.none) ...[
                            const SizedBox(width: 6),
                            StaffBadge(
                              staffRole: user.staffRole,
                              size: 20,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '@${user.username}',
                        style: TextStyle(
                          color: SwiftSnapTheme.textMuted,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          if (user.accountStatus == AccountStatus.creator)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                gradient: SwiftSnapTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'Creator',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (user.accountStatus == AccountStatus.creator && user.staffRole != StaffRole.none)
                            const SizedBox.shrink(),
                          if (user.staffRole != StaffRole.none)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStaffColor(user.staffRole),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getStaffIcon(user.staffRole),
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _getStaffLabel(user.staffRole),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (user.bio != null) ...[
              const SizedBox(height: 16),
              Text(
                user.bio!,
                style: const TextStyle(
                  color: SwiftSnapTheme.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfileScreen(),
                        ),
                      );
                    },
                    child: _buildProfileAction(
                      icon: Icons.edit_rounded,
                      label: 'Edit Profile',
                      isPrimary: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _buildProfileIconAction(Icons.qr_code_rounded),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
    );
  }
  
  Widget _buildProfileAction({
    required IconData icon,
    required String label,
    bool isPrimary = false,
  }) {
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: isPrimary ? SwiftSnapTheme.primaryGradient : null,
          color: isPrimary ? null : SwiftSnapTheme.backgroundCard,
          borderRadius: BorderRadius.circular(12),
          border: !isPrimary
              ? Border.all(color: Colors.white.withOpacity(0.1))
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isPrimary ? Colors.white : SwiftSnapTheme.textSecondary,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isPrimary ? Colors.white : SwiftSnapTheme.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
  }
  
  Widget _buildProfileIconAction(IconData icon) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (icon == Icons.qr_code_rounded) {
          _showQRCode();
        }
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: SwiftSnapTheme.backgroundCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        child: Icon(
          icon,
          color: SwiftSnapTheme.textSecondary,
          size: 22,
        ),
      ),
    );
  }
  
  Widget _buildStatsCard(dynamic user, AppProvider provider) {
    final friendsCount = user.friendCount > 0 ? user.friendCount : provider.friends.length;
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: SwiftSnapTheme.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FriendsScreen(),
                  ),
                );
              },
              child: _buildStatItem(_formatCount(friendsCount), 'Friends', SwiftSnapTheme.primaryPurple),
            ),
            _buildStatDivider(),
            _buildStatItem('${user.streakDays}', 'Streak 🔥', SwiftSnapTheme.accentOrange),
            _buildStatDivider(),
            _buildStatItem(_formatCount(user.snapScore), 'Score', SwiftSnapTheme.accentCyan),
          ],
        ),
      ).animate(delay: 100.ms).fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
    );
  }
  
  Widget _buildStatItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: SwiftSnapTheme.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 40,
      color: Colors.white.withOpacity(0.1),
    );
  }

  String _formatCount(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return '$value';
  }
  
  Widget _buildSettingsSection() {
    return SliverToBoxAdapter(
      child: _buildSection(
        title: 'Settings',
        items: [
          _SettingsItem(
            icon: Icons.notifications_rounded,
            label: 'Notifications',
            trailing: _buildToggle(true),
          ),
          _SettingsItem(
            icon: Icons.dark_mode_rounded,
            label: 'Dark Mode',
            trailing: _buildToggle(true),
          ),
          _SettingsItem(
            icon: Icons.language_rounded,
            label: 'Language',
            value: 'English',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LanguageSettingsScreen(),
                ),
              );
            },
          ),
          _SettingsItem(
            icon: Icons.storage_rounded,
            label: 'Storage & Data',
            value: '2.4 GB',
          ),
        ],
      ).animate(delay: 200.ms).fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
    );
  }
  
  Widget _buildPrivacySection() {
    return SliverToBoxAdapter(
      child: _buildSection(
        title: 'Privacy & Security',
        items: [
          _SettingsItem(
            icon: Icons.lock_rounded,
            label: 'Two-Factor Auth',
            trailing: _buildBadge('Enabled', SwiftSnapTheme.accentGreen),
          ),
          _SettingsItem(
            icon: Icons.visibility_off_rounded,
            label: 'Hide Online Status',
            trailing: _buildToggle(false),
          ),
          _SettingsItem(
            icon: Icons.remove_red_eye_rounded,
            label: 'Read Receipts',
            trailing: _buildToggle(true),
          ),
          _SettingsItem(
            icon: Icons.screenshot_rounded,
            label: 'Screenshot Alerts',
            trailing: _buildToggle(true),
          ),
          _SettingsItem(
            icon: Icons.block_rounded,
            label: 'Blocked Users',
            value: '0 users',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BlockedUsersScreen(),
                ),
              );
            },
          ),
        ],
      ).animate(delay: 300.ms).fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
    );
  }
  
  Widget _buildAccountSection() {
    return SliverToBoxAdapter(
      child: _buildSection(
        title: 'Account',
        items: [
          _SettingsItem(
            icon: Icons.emoji_events_rounded,
            label: 'Achievements',
            subtitle: 'Your badges & progress',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AchievementsScreen(),
                ),
              );
            },
          ),
          _SettingsItem(
            icon: Icons.face_retouching_natural_rounded,
            label: 'Avatar Studio',
            subtitle: 'Create your SwiftSnap avatar',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AvatarStudioScreen(),
                ),
              );
            },
          ),
          _SettingsItem(
            icon: Icons.download_rounded,
            label: 'Download My Data',
            subtitle: 'GDPR Export',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DownloadDataScreen(),
                ),
              );
            },
          ),
          _SettingsItem(
            icon: Icons.support_agent_rounded,
            label: 'Support Center',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HelpSupportScreen(),
                ),
              );
            },
          ),
          _SettingsItem(
            icon: Icons.policy_rounded,
            label: 'Privacy Policy',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrivacyPolicyScreen(),
                ),
              );
            },
          ),
          _SettingsItem(
            icon: Icons.logout_rounded,
            label: 'Log Out',
            color: SwiftSnapTheme.busy,
            onTap: () {
              HapticFeedback.mediumImpact();
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: SwiftSnapTheme.backgroundCard,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: const Text('Log Out', style: TextStyle(color: SwiftSnapTheme.textPrimary, fontWeight: FontWeight.w700)),
                  content: Text('Are you sure you want to log out?', style: TextStyle(color: SwiftSnapTheme.textSecondary)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel', style: TextStyle(color: SwiftSnapTheme.textSecondary)),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Provider.of<AppProvider>(context, listen: false).logout();
                      },
                      child: Text('Log Out', style: TextStyle(color: SwiftSnapTheme.busy, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ).animate(delay: 400.ms).fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
    );
  }
  
  Widget _buildSection({
    required String title,
    required List<_SettingsItem> items,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              title,
              style: const TextStyle(
                color: SwiftSnapTheme.textMuted,
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
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
              ),
            ),
            child: Column(
              children: items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isLast = index == items.length - 1;
                
                return Column(
                  children: [
                    _buildSettingsTile(item),
                    if (!isLast)
                      Divider(
                        color: Colors.white.withOpacity(0.06),
                        height: 1,
                        indent: 56,
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSettingsTile(_SettingsItem item) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        if (item.onTap != null) {
          item.onTap!();
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: (item.color ?? SwiftSnapTheme.primaryPurple).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                item.icon,
                color: item.color ?? SwiftSnapTheme.primaryPurple,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label,
                    style: TextStyle(
                      color: item.color ?? SwiftSnapTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (item.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle!,
                      style: TextStyle(
                        color: SwiftSnapTheme.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (item.trailing != null)
              item.trailing!
            else if (item.value != null)
              Text(
                item.value!,
                style: TextStyle(
                  color: SwiftSnapTheme.textMuted,
                  fontSize: 14,
                ),
              )
            else
              Icon(
                Icons.chevron_right_rounded,
                color: SwiftSnapTheme.textMuted,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildToggle(bool value) {
    return Switch(
      value: value,
      onChanged: (_) => HapticFeedback.lightImpact(),
      activeColor: SwiftSnapTheme.primaryPurple,
      activeTrackColor: SwiftSnapTheme.primaryPurple.withOpacity(0.3),
      inactiveThumbColor: SwiftSnapTheme.textMuted,
      inactiveTrackColor: SwiftSnapTheme.backgroundCard,
    );
  }
  
  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getStaffColor(StaffRole role) {
    switch (role) {
      case StaffRole.administrator:
        return const Color(0xFFDC143C); // Crimson red
      case StaffRole.moderator:
        return const Color(0xFF32CD32); // Lime green
      case StaffRole.support:
        return const Color(0xFF1E90FF); // Dodger blue
      case StaffRole.none:
        return Colors.transparent;
    }
  }

  IconData _getStaffIcon(StaffRole role) {
    switch (role) {
      case StaffRole.administrator:
        return Icons.shield_rounded;
      case StaffRole.moderator:
        return Icons.security_rounded;
      case StaffRole.support:
        return Icons.support_agent_rounded;
      case StaffRole.none:
        return Icons.circle;
    }
  }

  String _getStaffLabel(StaffRole role) {
    switch (role) {
      case StaffRole.administrator:
        return 'Administrator';
      case StaffRole.moderator:
        return 'Moderator';
      case StaffRole.support:
        return 'Support';
      case StaffRole.none:
        return '';
    }
  }

  void _showQRCode() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SwiftSnapTheme.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'My QR Code',
          style: TextStyle(
            color: SwiftSnapTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 200,
              height: 200,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      gradient: SwiftSnapTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.qr_code_rounded,
                      size: 100,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Scan this code to add me as a friend',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: SwiftSnapTheme.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Share.share('Check out my SwiftSnap profile!');
            },
            child: const Text('Share', style: TextStyle(color: SwiftSnapTheme.primaryPurple)),
          ),
        ],
      ),
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final String label;
  final String? value;
  final String? subtitle;
  final Widget? trailing;
  final Color? color;
  final VoidCallback? onTap;
  
  _SettingsItem({
    required this.icon,
    required this.label,
    this.value,
    this.subtitle,
    this.trailing,
    this.color,
    this.onTap,
  });
}
