import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/theme.dart';

class MySelfieScreen extends StatefulWidget {
  const MySelfieScreen({super.key});

  @override
  State<MySelfieScreen> createState() => _MySelfieScreenState();
}

class _MySelfieScreenState extends State<MySelfieScreen> {
  bool _selfieEnabled = true;
  bool _autoUpdate = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwiftSnapTheme.backgroundDark,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildHeader(context),
            _buildSelfiePreview(),
            _buildSettingsSection(),
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
              'My Selfie',
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

  Widget _buildSelfiePreview() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              SwiftSnapTheme.primaryPurple.withOpacity(0.15),
              SwiftSnapTheme.primaryPink.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: SwiftSnapTheme.primaryPurple.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SwiftSnapTheme.primaryGradient,
                boxShadow: SwiftSnapTheme.glowShadow(
                  SwiftSnapTheme.primaryPurple,
                  intensity: 0.4,
                ),
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                size: 70,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Your Selfie',
              style: TextStyle(
                color: SwiftSnapTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Personalize your profile with a daily selfie',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: SwiftSnapTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                _showCaptureOptions();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: SwiftSnapTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: SwiftSnapTheme.glowShadow(
                    SwiftSnapTheme.primaryPurple,
                    intensity: 0.3,
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt_rounded, color: Colors.white, size: 22),
                    SizedBox(width: 12),
                    Text(
                      'Take Selfie',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms).scale(delay: 100.ms),
    );
  }

  Widget _buildSettingsSection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 24, 16, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: SwiftSnapTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'SELFIE SETTINGS',
                style: TextStyle(
                  color: SwiftSnapTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            _buildSettingsTile(
              icon: Icons.visibility_outlined,
              title: 'Show Selfie on Profile',
              subtitle: 'Display your selfie to friends',
              value: _selfieEnabled,
              onChanged: (value) => setState(() => _selfieEnabled = value),
            ),
            _buildDivider(),
            _buildSettingsTile(
              icon: Icons.update_rounded,
              title: 'Auto Update',
              subtitle: 'Prompt for new selfie daily',
              value: _autoUpdate,
              onChanged: (value) => setState(() => _autoUpdate = value),
            ),
            _buildDivider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: SwiftSnapTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.history_rounded, color: Colors.white, size: 22),
              ),
              title: const Text(
                'Selfie History',
                style: TextStyle(
                  color: SwiftSnapTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: const Text(
                'View past selfies',
                style: TextStyle(
                  color: SwiftSnapTheme.textMuted,
                  fontSize: 12,
                ),
              ),
              trailing: const Icon(
                Icons.chevron_right_rounded,
                color: SwiftSnapTheme.textSecondary,
              ),
              onTap: () => HapticFeedback.lightImpact(),
            ),
          ],
        ),
      ).animate(delay: 200.ms).fadeIn(duration: 300.ms),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: SwiftSnapTheme.primaryGradient,
              borderRadius: BorderRadius.circular(10),
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
                  style: const TextStyle(
                    color: SwiftSnapTheme.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: (newValue) {
              HapticFeedback.lightImpact();
              onChanged(newValue);
            },
            activeColor: SwiftSnapTheme.primaryPurple,
            activeTrackColor: SwiftSnapTheme.primaryPurple.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: Colors.white.withOpacity(0.06),
      indent: 56,
    );
  }

  void _showCaptureOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: SwiftSnapTheme.backgroundCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Capture Selfie',
              style: TextStyle(
                color: SwiftSnapTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),
            _buildCaptureOption(
              icon: Icons.camera_alt_rounded,
              title: 'Take Photo',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Opening camera...'),
                    backgroundColor: SwiftSnapTheme.accentGreen,
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildCaptureOption(
              icon: Icons.photo_library_rounded,
              title: 'Choose from Gallery',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Opening gallery...'),
                    backgroundColor: SwiftSnapTheme.accentGreen,
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCaptureOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: SwiftSnapTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: SwiftSnapTheme.primaryPurple, size: 24),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                color: SwiftSnapTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
