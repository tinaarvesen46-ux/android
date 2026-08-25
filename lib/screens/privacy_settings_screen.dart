import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/theme.dart';
import '../providers/app_provider.dart';
import '../models/user_model.dart';
import 'blocked_users_screen.dart';
import 'restricted_words_screen.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  String _profileVisibility = 'Everyone';
  String _storyVisibility = 'Friends Only';
  String _messagePermission = 'Everyone';
  String _lastSeenVisibility = 'Friends Only';
  
  bool _readReceipts = true;
  bool _typingIndicators = true;
  bool _onlineStatus = true;
  bool _locationSharing = false;
  bool _dataAnalytics = true;
  bool _personalizedAds = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwiftSnapTheme.backgroundDark,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildHeader(context),
            _buildPrivacyLevelCard(),
            _buildVisibilitySection(),
            _buildMessagingSection(),
            _buildActivitySection(),
            _buildDataSection(),
            _buildBlockedSection(),
            const SliverPadding(padding: EdgeInsets.only(bottom: 50)),
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
              'Privacy Control',
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

  Widget _buildPrivacyLevelCard() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                SwiftSnapTheme.primaryPurple.withOpacity(0.2),
                SwiftSnapTheme.primaryPink.withOpacity(0.15),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: SwiftSnapTheme.primaryPurple.withOpacity(0.3)),
          ),
          child: Consumer<AppProvider>(
            builder: (context, provider, _) {
              final privacyLevel = provider.currentUser?.privacyLevel ?? PrivacyLevel.friendsOnly;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: SwiftSnapTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: SwiftSnapTheme.glowShadow(
                            SwiftSnapTheme.primaryPurple,
                            intensity: 0.3,
                          ),
                        ),
                        child: const Icon(
                          Icons.privacy_tip_rounded,
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
                              'Privacy Level',
                              style: TextStyle(
                                color: SwiftSnapTheme.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              _getPrivacyLevelText(privacyLevel),
                              style: TextStyle(
                                color: SwiftSnapTheme.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildPrivacyLevelSelector(provider),
                ],
              );
            },
          ),
        ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0),
      ),
    );
  }

  Widget _buildPrivacyLevelSelector(AppProvider provider) {
    final currentLevel = provider.currentUser?.privacyLevel ?? PrivacyLevel.friendsOnly;
    
    return Row(
      children: [
        Expanded(child: _buildLevelChip('Public', PrivacyLevel.publicProfile, currentLevel, provider)),
        const SizedBox(width: 8),
        Expanded(child: _buildLevelChip('Friends', PrivacyLevel.friendsOnly, currentLevel, provider)),
        const SizedBox(width: 8),
        Expanded(child: _buildLevelChip('Private', PrivacyLevel.privateProfile, currentLevel, provider)),
      ],
    );
  }

  Widget _buildLevelChip(String label, PrivacyLevel level, PrivacyLevel currentLevel, AppProvider provider) {
    final isSelected = level == currentLevel;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        provider.updateCurrentUser(privacyLevel: level);
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected ? SwiftSnapTheme.primaryGradient : null,
          color: isSelected ? null : SwiftSnapTheme.backgroundDark.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : SwiftSnapTheme.textSecondary,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _getPrivacyLevelText(PrivacyLevel level) {
    switch (level) {
      case PrivacyLevel.publicProfile:
        return 'Everyone can see your profile';
      case PrivacyLevel.friendsOnly:
        return 'Only friends can see your activity';
      case PrivacyLevel.privateProfile:
        return 'Maximum privacy protection';
    }
  }

  Widget _buildVisibilitySection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'VISIBILITY',
                style: TextStyle(
                  color: SwiftSnapTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
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
                  _buildSelectionTile(
                    icon: Icons.person_rounded,
                    title: 'Profile Visibility',
                    subtitle: _profileVisibility,
                    onTap: () => _showVisibilityDialog('Profile', _profileVisibility, (value) {
                      setState(() => _profileVisibility = value);
                    }),
                  ),
                  _buildDivider(),
                  _buildSelectionTile(
                    icon: Icons.auto_stories_rounded,
                    title: 'Story Visibility',
                    subtitle: _storyVisibility,
                    onTap: () => _showVisibilityDialog('Story', _storyVisibility, (value) {
                      setState(() => _storyVisibility = value);
                    }),
                  ),
                  _buildDivider(),
                  _buildSelectionTile(
                    icon: Icons.access_time_rounded,
                    title: 'Last Seen',
                    subtitle: _lastSeenVisibility,
                    onTap: () => _showVisibilityDialog('Last Seen', _lastSeenVisibility, (value) {
                      setState(() => _lastSeenVisibility = value);
                    }),
                  ),
                ],
              ),
            ),
          ],
        ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
      ),
    );
  }

  Widget _buildMessagingSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'MESSAGING',
                style: TextStyle(
                  color: SwiftSnapTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
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
                  _buildSelectionTile(
                    icon: Icons.message_rounded,
                    title: 'Who Can Message You',
                    subtitle: _messagePermission,
                    onTap: () => _showVisibilityDialog('Message Permission', _messagePermission, (value) {
                      setState(() => _messagePermission = value);
                    }),
                  ),
                  _buildDivider(),
                  _buildSwitchTile(
                    icon: Icons.done_all_rounded,
                    title: 'Read Receipts',
                    subtitle: 'Let others know when you\'ve read their messages',
                    value: _readReceipts,
                    onChanged: (value) => setState(() => _readReceipts = value),
                  ),
                  _buildDivider(),
                  _buildSwitchTile(
                    icon: Icons.keyboard_rounded,
                    title: 'Typing Indicators',
                    subtitle: 'Show when you\'re typing',
                    value: _typingIndicators,
                    onChanged: (value) => setState(() => _typingIndicators = value),
                  ),
                ],
              ),
            ),
          ],
        ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
      ),
    );
  }

  Widget _buildActivitySection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'ACTIVITY STATUS',
                style: TextStyle(
                  color: SwiftSnapTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
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
                  _buildSwitchTile(
                    icon: Icons.circle,
                    title: 'Show Online Status',
                    subtitle: 'Let friends see when you\'re online',
                    value: _onlineStatus,
                    onChanged: (value) => setState(() => _onlineStatus = value),
                  ),
                  _buildDivider(),
                  _buildSwitchTile(
                    icon: Icons.location_on_rounded,
                    title: 'Location Sharing',
                    subtitle: 'Share your location with friends',
                    value: _locationSharing,
                    onChanged: (value) => setState(() => _locationSharing = value),
                  ),
                ],
              ),
            ),
          ],
        ).animate().fadeIn(duration: 300.ms, delay: 300.ms),
      ),
    );
  }

  Widget _buildDataSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'DATA & PERSONALIZATION',
                style: TextStyle(
                  color: SwiftSnapTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
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
                  _buildSwitchTile(
                    icon: Icons.analytics_rounded,
                    title: 'Usage Analytics',
                    subtitle: 'Help improve SwiftSnap with usage data',
                    value: _dataAnalytics,
                    onChanged: (value) => setState(() => _dataAnalytics = value),
                  ),
                  _buildDivider(),
                  _buildSwitchTile(
                    icon: Icons.ads_click_rounded,
                    title: 'Personalized Ads',
                    subtitle: 'See ads tailored to your interests',
                    value: _personalizedAds,
                    onChanged: (value) => setState(() => _personalizedAds = value),
                  ),
                ],
              ),
            ),
          ],
        ).animate().fadeIn(duration: 300.ms, delay: 400.ms),
      ),
    );
  }

  Widget _buildBlockedSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'BLOCKED & RESTRICTED',
                style: TextStyle(
                  color: SwiftSnapTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
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
                  _buildNavigationTile(
                    icon: Icons.block_rounded,
                    title: 'Blocked Users',
                    subtitle: 'Manage blocked accounts',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const BlockedUsersScreen()),
                    ),
                  ),
                  _buildDivider(),
                  _buildNavigationTile(
                    icon: Icons.report_rounded,
                    title: 'Restricted Words',
                    subtitle: 'Filter messages with specific words',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RestrictedWordsScreen()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ).animate().fadeIn(duration: 300.ms, delay: 500.ms),
      ),
    );
  }

  Widget _buildSelectionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: Colors.transparent,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: SwiftSnapTheme.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: SwiftSnapTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: SwiftSnapTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
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

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: SwiftSnapTheme.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: SwiftSnapTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: SwiftSnapTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: value,
            onChanged: (newValue) {
              HapticFeedback.lightImpact();
              onChanged(newValue);
            },
            activeColor: SwiftSnapTheme.primaryPurple,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: Colors.transparent,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: SwiftSnapTheme.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: SwiftSnapTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: SwiftSnapTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
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

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 72),
      child: Divider(
        height: 1,
        thickness: 1,
        color: Colors.white.withOpacity(0.05),
      ),
    );
  }

  void _showVisibilityDialog(String title, String currentValue, Function(String) onSelected) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SwiftSnapTheme.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: const TextStyle(
            color: SwiftSnapTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogOption('Everyone', currentValue, onSelected),
            const SizedBox(height: 8),
            _buildDialogOption('Friends Only', currentValue, onSelected),
            const SizedBox(height: 8),
            _buildDialogOption('Nobody', currentValue, onSelected),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogOption(String option, String currentValue, Function(String) onSelected) {
    final isSelected = option == currentValue;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onSelected(option);
        Navigator.pop(context);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          gradient: isSelected ? SwiftSnapTheme.primaryGradient : null,
          color: isSelected ? null : SwiftSnapTheme.backgroundDark.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  color: isSelected ? Colors.white : SwiftSnapTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_rounded, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}
