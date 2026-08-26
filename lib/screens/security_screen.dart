import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/theme.dart';
import '../api/services/settings_service.dart';
import 'change_password_screen.dart';
import 'login_history_screen.dart';
import 'suspicious_activity_screen.dart';
import 'backup_encryption_screen.dart';
import 'app_permissions_screen.dart';
import 'trusted_contacts_screen.dart';
import 'download_data_screen.dart';
import 'two_factor_auth_screen.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final SettingsService _settingsService = SettingsService();
  bool _twoFactorEnabled = false;
  bool _biometricEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadTwoFactor();
  }

  Future<void> _loadTwoFactor() async {
    final res = await _settingsService.getTwoFactorStatus();
    if (mounted && res.isSuccess) {
      setState(() => _twoFactorEnabled = res.data ?? false);
    }
  }

  Future<void> _openTwoFactor() async {
    HapticFeedback.lightImpact();
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TwoFactorAuthScreen()),
    );
    _loadTwoFactor();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwiftSnapTheme.backgroundDark,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildHeader(context),
            _buildSecurityStatus(),
            _buildAuthenticationSection(),
            _buildDeviceSecuritySection(),
            _buildActivityMonitoring(),
            _buildDataProtection(),
            _buildAdvancedSecurity(),
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
              'Security',
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

  Widget _buildSecurityStatus() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF10B981).withOpacity(0.2),
                const Color(0xFF059669).withOpacity(0.15),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Security Status',
                      style: TextStyle(
                        color: SwiftSnapTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Protected',
                          style: TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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
        ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0),
      ),
    );
  }

  Widget _buildAuthenticationSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'AUTHENTICATION',
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
                    icon: Icons.lock_clock_rounded,
                    title: 'Two-Factor Authentication',
                    subtitle: 'Add an extra layer of security',
                    value: _twoFactorEnabled,
                    onChanged: (value) => _openTwoFactor(),
                    recommended: true,
                  ),
                  _buildDivider(),
                  _buildSwitchTile(
                    icon: Icons.fingerprint_rounded,
                    title: 'Biometric Authentication',
                    subtitle: 'Use Face ID or fingerprint',
                    value: _biometricEnabled,
                    onChanged: (value) => setState(() => _biometricEnabled = value),
                  ),
                  _buildDivider(),
                  _buildNavigationTile(
                    icon: Icons.vpn_key_rounded,
                    title: 'Change Password',
                    subtitle: 'Update your account password',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
      ),
    );
  }

  Widget _buildDeviceSecuritySection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'DEVICE & SESSION SECURITY',
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
                    icon: Icons.devices_rounded,
                    title: 'Active Sessions',
                    subtitle: 'Manage your logged-in devices',
                    onTap: () => _showActiveSessions(),
                  ),
                  _buildDivider(),
                  _buildNavigationTile(
                    icon: Icons.history_rounded,
                    title: 'Login History',
                    subtitle: 'View recent login attempts',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginHistoryScreen()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
      ),
    );
  }

  Widget _buildActivityMonitoring() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'ACTIVITY MONITORING',
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
                    icon: Icons.shield_rounded,
                    title: 'Suspicious Activity',
                    subtitle: 'Review unusual account activity',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SuspiciousActivityScreen()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ).animate().fadeIn(duration: 300.ms, delay: 300.ms),
      ),
    );
  }

  Widget _buildDataProtection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'DATA PROTECTION',
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
                  _buildInfoTile(
                    icon: Icons.lock_rounded,
                    title: 'End-to-End Encryption',
                    subtitle: 'All messages are encrypted',
                    statusIcon: Icons.check_circle_rounded,
                    statusColor: const Color(0xFF10B981),
                  ),
                  _buildDivider(),
                  _buildNavigationTile(
                    icon: Icons.cloud_rounded,
                    title: 'Backup Encryption',
                    subtitle: 'Encrypted cloud backups enabled',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const BackupEncryptionScreen()),
                    ),
                  ),
                  _buildDivider(),
                  _buildNavigationTile(
                    icon: Icons.folder_special_rounded,
                    title: 'Data Export',
                    subtitle: 'Download your data securely',
                    onTap: () => _exportData(),
                  ),
                ],
              ),
            ),
          ],
        ).animate().fadeIn(duration: 300.ms, delay: 400.ms),
      ),
    );
  }

  Widget _buildAdvancedSecurity() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'ADVANCED SECURITY',
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
                    icon: Icons.admin_panel_settings_rounded,
                    title: 'App Permissions',
                    subtitle: 'Manage app access permissions',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AppPermissionsScreen()),
                    ),
                  ),
                  _buildDivider(),
                  _buildNavigationTile(
                    icon: Icons.verified_user_rounded,
                    title: 'Trusted Contacts',
                    subtitle: 'Manage trusted contacts list',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TrustedContactsScreen()),
                    ),
                  ),
                  _buildDivider(),
                  _buildNavigationTile(
                    icon: Icons.logout_rounded,
                    title: 'Sign Out All Devices',
                    subtitle: 'Log out from all active sessions',
                    titleColor: SwiftSnapTheme.busy,
                    onTap: () => _signOutAllDevices(),
                  ),
                ],
              ),
            ),
          ],
        ).animate().fadeIn(duration: 300.ms, delay: 500.ms),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool recommended = false,
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
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: SwiftSnapTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (recommended) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Recommended',
                          style: TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
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
    Color? titleColor,
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
                    style: TextStyle(
                      color: titleColor ?? SwiftSnapTheme.textPrimary,
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

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required IconData statusIcon,
    required Color statusColor,
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
          Icon(statusIcon, color: statusColor, size: 24),
        ],
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

  void _showActiveSessions() {
    final settingsService = SettingsService();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: SwiftSnapTheme.backgroundCard,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text(
                'Active Sessions',
                style: TextStyle(
                  color: SwiftSnapTheme.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: FutureBuilder(
                  future: settingsService.getActiveSessions(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: SwiftSnapTheme.primaryPurple),
                      );
                    }
                    final res = snapshot.data;
                    final sessions = (res != null && res.isSuccess) ? (res.data ?? []) : [];
                    if (sessions.isEmpty) {
                      return const Center(
                        child: Text('No active sessions',
                            style: TextStyle(color: SwiftSnapTheme.textSecondary)),
                      );
                    }
                    return ListView.separated(
                      controller: scrollController,
                      itemCount: sessions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final s = sessions[i] as Map<String, dynamic>;
                        final isCurrent = s['current'] == true;
                        return _buildSessionItem(
                          '${s['name'] ?? 'Session'}',
                          'Last active ${s['last_used_at'] ?? s['created_at'] ?? ''}',
                          isCurrent,
                          () async {
                            final r = await settingsService.revokeSession('${s['id']}');
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(r.isSuccess ? 'Session revoked' : r.errorMessage)),
                              );
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSessionItem(String device, String status, bool isCurrent, [VoidCallback? onRevoke]) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SwiftSnapTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(isCurrent ? Icons.verified_user_rounded : Icons.devices_rounded,
              color: isCurrent ? SwiftSnapTheme.accentGreen : SwiftSnapTheme.textSecondary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device,
                  style: const TextStyle(
                    color: SwiftSnapTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  isCurrent ? 'Current device' : status,
                  style: const TextStyle(
                    color: SwiftSnapTheme.textSecondary,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (!isCurrent)
            TextButton(
              onPressed: onRevoke,
              child: const Text('Revoke', style: TextStyle(color: SwiftSnapTheme.busy)),
            ),
        ],
      ),
    );
  }

  void _exportData() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DownloadDataScreen()),
    );
  }

  Future<void> _signOutAllDevices() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SwiftSnapTheme.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Sign Out All Devices?',
          style: TextStyle(color: SwiftSnapTheme.textPrimary, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'You will be logged out from all other active sessions except this one.',
          style: TextStyle(color: SwiftSnapTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: SwiftSnapTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out', style: TextStyle(color: SwiftSnapTheme.busy)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    // Fetch active sessions and revoke every non-current one via the real API.
    final sessionsRes = await _settingsService.getActiveSessions();
    if (!mounted) return;
    if (!sessionsRes.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(sessionsRes.errorMessage)));
      return;
    }
    final sessions = sessionsRes.data ?? [];
    int revoked = 0;
    for (final s in sessions) {
      if (s['current'] == true) continue;
      final r = await _settingsService.revokeSession('${s['id']}');
      if (r.isSuccess) revoked++;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Signed out of $revoked other device(s)')),
    );
  }
}
