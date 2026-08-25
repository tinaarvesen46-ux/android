import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/theme.dart';

class DownloadDataScreen extends StatefulWidget {
  const DownloadDataScreen({super.key});

  @override
  State<DownloadDataScreen> createState() => _DownloadDataScreenState();
}

class _DownloadDataScreenState extends State<DownloadDataScreen> {
  bool _includeMessages = true;
  bool _includeMedia = true;
  bool _includeProfile = true;
  bool _includeContacts = true;
  bool _isRequesting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwiftSnapTheme.backgroundDark,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildHeader(context),
            _buildInfoCard(),
            _buildDataOptions(),
            _buildActionButton(),
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
              'Download My Data',
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

  Widget _buildInfoCard() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              SwiftSnapTheme.primaryPurple.withOpacity(0.15),
              SwiftSnapTheme.primaryPink.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: SwiftSnapTheme.primaryPurple.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: SwiftSnapTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.download_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'GDPR Data Export',
                    style: TextStyle(
                      color: SwiftSnapTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Request a copy of all your data from SwiftSnap. This includes your profile, messages, media, and account activity.',
              style: TextStyle(
                color: SwiftSnapTheme.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: SwiftSnapTheme.backgroundCard,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: SwiftSnapTheme.accentCyan,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Processing usually takes 24-48 hours. You\'ll receive a download link via email.',
                      style: TextStyle(
                        color: SwiftSnapTheme.textSecondary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0),
    );
  }

  Widget _buildDataOptions() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
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
                'SELECT DATA TO INCLUDE',
                style: TextStyle(
                  color: SwiftSnapTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            _buildDataOption(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'Messages',
              subtitle: 'All chat conversations and DMs',
              value: _includeMessages,
              onChanged: (value) => setState(() => _includeMessages = value),
            ),
            _buildDivider(),
            _buildDataOption(
              icon: Icons.photo_library_outlined,
              title: 'Media Files',
              subtitle: 'Photos, videos, and documents',
              value: _includeMedia,
              onChanged: (value) => setState(() => _includeMedia = value),
            ),
            _buildDivider(),
            _buildDataOption(
              icon: Icons.person_outline_rounded,
              title: 'Profile Data',
              subtitle: 'Account details and preferences',
              value: _includeProfile,
              onChanged: (value) => setState(() => _includeProfile = value),
            ),
            _buildDivider(),
            _buildDataOption(
              icon: Icons.contacts_outlined,
              title: 'Contacts',
              subtitle: 'Friends and blocked users',
              value: _includeContacts,
              onChanged: (value) => setState(() => _includeContacts = value),
            ),
          ],
        ),
      ).animate(delay: 100.ms).fadeIn(duration: 300.ms),
    );
  }

  Widget _buildDataOption({
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

  Widget _buildActionButton() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
        child: GestureDetector(
          onTap: _isRequesting ? null : _requestDataDownload,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              gradient: _isRequesting ? null : SwiftSnapTheme.primaryGradient,
              color: _isRequesting ? SwiftSnapTheme.surfaceColor : null,
              borderRadius: BorderRadius.circular(16),
              boxShadow: _isRequesting
                  ? null
                  : SwiftSnapTheme.glowShadow(
                      SwiftSnapTheme.primaryPurple,
                      intensity: 0.3,
                    ),
            ),
            child: _isRequesting
                ? const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(SwiftSnapTheme.primaryPurple),
                      ),
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.download_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Request Data Export',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
          ),
        ).animate(delay: 200.ms).fadeIn(duration: 300.ms).scale(delay: 200.ms),
      ),
    );
  }

  Future<void> _requestDataDownload() async {
    setState(() => _isRequesting = true);
    
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    setState(() => _isRequesting = false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SwiftSnapTheme.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: SwiftSnapTheme.accentGreen, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Request Submitted',
                style: TextStyle(
                  color: SwiftSnapTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Your data export request has been received. You\'ll receive a download link at your registered email within 24-48 hours.',
          style: TextStyle(color: SwiftSnapTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK', style: TextStyle(color: SwiftSnapTheme.primaryPurple)),
          ),
        ],
      ),
    );
  }
}
