import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/theme.dart';

class TwoFactorAuthScreen extends StatefulWidget {
  const TwoFactorAuthScreen({super.key});

  @override
  State<TwoFactorAuthScreen> createState() => _TwoFactorAuthScreenState();
}

class _TwoFactorAuthScreenState extends State<TwoFactorAuthScreen> {
  bool _isEnabled = true;
  bool _smsEnabled = true;
  bool _appEnabled = false;
  bool _emailEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwiftSnapTheme.backgroundDark,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildHeader(context),
            _buildStatusCard(),
            _buildMasterToggle(),
            if (_isEnabled) ...[
              _buildMethodsSection(),
              _buildBackupCodesCard(),
            ],
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
              'Two-Factor Authentication',
              style: TextStyle(
                color: SwiftSnapTheme.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isEnabled
                ? [
                    SwiftSnapTheme.accentGreen.withOpacity(0.15),
                    SwiftSnapTheme.accentGreen.withOpacity(0.05),
                  ]
                : [
                    SwiftSnapTheme.busy.withOpacity(0.15),
                    SwiftSnapTheme.busy.withOpacity(0.05),
                  ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isEnabled
                ? SwiftSnapTheme.accentGreen.withOpacity(0.3)
                : SwiftSnapTheme.busy.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: (_isEnabled ? SwiftSnapTheme.accentGreen : SwiftSnapTheme.busy).withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                _isEnabled ? Icons.shield_rounded : Icons.shield_outlined,
                color: _isEnabled ? SwiftSnapTheme.accentGreen : SwiftSnapTheme.busy,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isEnabled ? 'Enabled' : 'Disabled',
                    style: TextStyle(
                      color: _isEnabled ? SwiftSnapTheme.accentGreen : SwiftSnapTheme.busy,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isEnabled
                        ? 'Your account is protected with 2FA'
                        : 'Enable 2FA to secure your account',
                    style: TextStyle(
                      color: SwiftSnapTheme.textSecondary,
                      fontSize: 13,
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

  Widget _buildMasterToggle() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: SwiftSnapTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: SwiftSnapTheme.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.lock_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enable 2FA',
                    style: TextStyle(
                      color: SwiftSnapTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Add an extra layer of security',
                    style: TextStyle(
                      color: SwiftSnapTheme.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: _isEnabled,
              onChanged: (value) {
                HapticFeedback.lightImpact();
                setState(() => _isEnabled = value);
              },
              activeColor: SwiftSnapTheme.accentGreen,
              activeTrackColor: SwiftSnapTheme.accentGreen.withOpacity(0.3),
            ),
          ],
        ),
      ).animate(delay: 100.ms).fadeIn(duration: 300.ms),
    );
  }

  Widget _buildMethodsSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'AUTHENTICATION METHODS',
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
                  _buildMethodTile(
                    icon: Icons.sms_rounded,
                    title: 'SMS Verification',
                    subtitle: 'Receive codes via text message',
                    value: _smsEnabled,
                    onChanged: (value) => setState(() => _smsEnabled = value),
                  ),
                  _buildDivider(),
                  _buildMethodTile(
                    icon: Icons.phone_android_rounded,
                    title: 'Authenticator App',
                    subtitle: 'Google Authenticator or similar',
                    value: _appEnabled,
                    onChanged: (value) => setState(() => _appEnabled = value),
                  ),
                  _buildDivider(),
                  _buildMethodTile(
                    icon: Icons.email_rounded,
                    title: 'Email Verification',
                    subtitle: 'Receive codes via email',
                    value: _emailEnabled,
                    onChanged: (value) => setState(() => _emailEnabled = value),
                  ),
                ],
              ),
            ),
          ],
        ).animate(delay: 200.ms).fadeIn(duration: 300.ms),
      ),
    );
  }

  Widget _buildMethodTile({
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

  Widget _buildBackupCodesCard() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: SwiftSnapTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: SwiftSnapTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.key_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Backup Codes',
                    style: TextStyle(
                      color: SwiftSnapTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Generate backup codes to access your account if you lose your 2FA device.',
              style: TextStyle(
                color: SwiftSnapTheme.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                _showBackupCodes();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: SwiftSnapTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Generate Backup Codes',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ).animate(delay: 300.ms).fadeIn(duration: 300.ms),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: Colors.white.withOpacity(0.06),
      indent: 72,
    );
  }

  void _showBackupCodes() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SwiftSnapTheme.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Backup Codes',
          style: TextStyle(color: SwiftSnapTheme.textPrimary, fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Save these codes in a secure location. Each code can only be used once.',
              style: TextStyle(color: SwiftSnapTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SwiftSnapTheme.backgroundCard,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: List.generate(
                  4,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      '${index + 1}. XXXX-XXXX-XXXX',
                      style: const TextStyle(
                        color: SwiftSnapTheme.textPrimary,
                        fontFamily: 'monospace',
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
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
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Backup codes copied to clipboard'),
                  backgroundColor: SwiftSnapTheme.accentGreen,
                ),
              );
            },
            child: const Text('Copy', style: TextStyle(color: SwiftSnapTheme.primaryPurple)),
          ),
        ],
      ),
    );
  }
}
