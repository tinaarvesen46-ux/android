import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/theme.dart';
import '../../models/admin_models.dart';
import '../../api/services/admin_service.dart';

class SystemSettingsScreen extends StatefulWidget {
  const SystemSettingsScreen({super.key});

  @override
  State<SystemSettingsScreen> createState() => _SystemSettingsScreenState();
}

class _SystemSettingsScreenState extends State<SystemSettingsScreen> {
  final AdminService _adminService = AdminService();
  SystemSettings _settings = const SystemSettings();
  bool _loading = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _loading = true);
    final result = await _adminService.getSystemSettings();
    if (mounted) {
      setState(() {
        _settings = result.data ?? const SystemSettings();
        _loading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _saving = true);
    await _adminService.updateSystemSettings({
      'maintenance_mode': _settings.maintenanceMode,
      'registration_enabled': _settings.registrationEnabled,
      'story_enabled': _settings.storyEnabled,
      'discover_enabled': _settings.discoverEnabled,
      'email_verification_required': _settings.emailVerificationRequired,
      'max_friends_per_user': _settings.maxFriendsPerUser,
      'max_stories_per_day': _settings.maxStoriesPerDay,
      'message_retention_days': _settings.messageRetentionDays,
      'support_email': _settings.supportEmail,
    });
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved successfully'),
          backgroundColor: SwiftSnapTheme.accentGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwiftSnapTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: SwiftSnapTheme.backgroundDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'System Settings',
          style: TextStyle(
            color: SwiftSnapTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          _saving
              ? const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: SwiftSnapTheme.primaryPurple,
                      strokeWidth: 2,
                    ),
                  ),
                )
              : TextButton(
                  onPressed: _saveSettings,
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      color: SwiftSnapTheme.primaryPurple,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                color: SwiftSnapTheme.primaryPurple,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_settings.maintenanceMode)
                    _buildWarningBanner(),
                  const SizedBox(height: 8),
                  _buildSection(
                    'Platform Switches',
                    Icons.toggle_on_rounded,
                    SwiftSnapTheme.primaryPurple,
                    [
                      _SettingToggle(
                        label: 'Maintenance Mode',
                        subtitle:
                            'Show maintenance page to all users',
                        icon: Icons.build_circle_rounded,
                        iconColor: SwiftSnapTheme.busy,
                        value: _settings.maintenanceMode,
                        onChanged: (v) => setState(
                            () => _settings = _settings.copyWith(
                                maintenanceMode: v)),
                        isDanger: true,
                      ),
                      _SettingToggle(
                        label: 'New Registrations',
                        subtitle: 'Allow new users to sign up',
                        icon: Icons.person_add_rounded,
                        iconColor: SwiftSnapTheme.accentGreen,
                        value: _settings.registrationEnabled,
                        onChanged: (v) => setState(
                            () => _settings = _settings.copyWith(
                                registrationEnabled: v)),
                      ),
                      _SettingToggle(
                        label: 'Stories Feature',
                        subtitle: 'Enable story creation and viewing',
                        icon: Icons.amp_stories_rounded,
                        iconColor: SwiftSnapTheme.accentOrange,
                        value: _settings.storyEnabled,
                        onChanged: (v) => setState(
                            () => _settings =
                                _settings.copyWith(storyEnabled: v)),
                      ),
                      _SettingToggle(
                        label: 'Discover Feature',
                        subtitle: 'Enable user discovery section',
                        icon: Icons.explore_rounded,
                        iconColor: SwiftSnapTheme.accentCyan,
                        value: _settings.discoverEnabled,
                        onChanged: (v) => setState(
                            () => _settings =
                                _settings.copyWith(discoverEnabled: v)),
                      ),
                      _SettingToggle(
                        label: 'Email Verification',
                        subtitle:
                            'Require email verification to use app',
                        icon: Icons.mark_email_read_rounded,
                        iconColor: SwiftSnapTheme.primaryBlue,
                        value: _settings.emailVerificationRequired,
                        onChanged: (v) => setState(
                            () => _settings = _settings.copyWith(
                                emailVerificationRequired: v)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    'Limits & Quotas',
                    Icons.tune_rounded,
                    SwiftSnapTheme.primaryBlue,
                    [
                      _buildSliderSetting(
                        label: 'Max Friends per User',
                        value: _settings.maxFriendsPerUser.toDouble(),
                        min: 50,
                        max: 2000,
                        divisions: 39,
                        display:
                            '${_settings.maxFriendsPerUser} friends',
                        icon: Icons.people_rounded,
                        onChanged: (v) => setState(
                            () => _settings = _settings.copyWith(
                                maxFriendsPerUser: v.round())),
                      ),
                      _buildSliderSetting(
                        label: 'Max Stories per Day',
                        value: _settings.maxStoriesPerDay.toDouble(),
                        min: 1,
                        max: 50,
                        divisions: 49,
                        display:
                            '${_settings.maxStoriesPerDay} stories',
                        icon: Icons.amp_stories_rounded,
                        onChanged: (v) => setState(
                            () => _settings = _settings.copyWith(
                                maxStoriesPerDay: v.round())),
                      ),
                      _buildSliderSetting(
                        label: 'Message Retention',
                        value:
                            _settings.messageRetentionDays.toDouble(),
                        min: 7,
                        max: 365,
                        divisions: 51,
                        display:
                            '${_settings.messageRetentionDays} days',
                        icon: Icons.chat_rounded,
                        onChanged: (v) => setState(
                            () => _settings = _settings.copyWith(
                                messageRetentionDays: v.round())),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    'Contact & Info',
                    Icons.info_rounded,
                    SwiftSnapTheme.accentGreen,
                    [
                      _buildInfoRow(
                          'Support Email', _settings.supportEmail,
                          Icons.email_rounded),
                      _buildInfoRow(
                          'App Version', _settings.appVersion,
                          Icons.info_rounded),
                      _buildInfoRow(
                          'Min Required Version',
                          _settings.minRequiredVersion,
                          Icons.system_update_rounded),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildDangerZone(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildWarningBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: SwiftSnapTheme.busy.withOpacity(0.15),
        borderRadius: BorderRadius.circular(SwiftSnapTheme.radiusMd),
        border: Border.all(color: SwiftSnapTheme.busy.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_rounded,
            color: SwiftSnapTheme.busy,
            size: 20,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'MAINTENANCE MODE IS ACTIVE — Users cannot access the app',
              style: TextStyle(
                color: SwiftSnapTheme.busy,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
      String title, IconData icon, Color color, List<Widget> children) {
    return Container(
      decoration: SwiftSnapTheme.glassmorphicDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: SwiftSnapTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          ...children.asMap().entries.map((e) => Column(
                children: [
                  if (e.key > 0)
                    Divider(
                      height: 1,
                      color: Colors.white.withOpacity(0.05),
                      indent: 16,
                    ),
                  e.value,
                ],
              )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSliderSetting({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String display,
    required IconData icon,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: SwiftSnapTheme.primaryPurple),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: SwiftSnapTheme.textPrimary,
                    fontSize: 14,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: SwiftSnapTheme.primaryPurple.withOpacity(0.15),
                  borderRadius:
                      BorderRadius.circular(SwiftSnapTheme.radiusFull),
                ),
                child: Text(
                  display,
                  style: const TextStyle(
                    color: SwiftSnapTheme.primaryPurple,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: SwiftSnapTheme.primaryPurple,
              inactiveTrackColor: SwiftSnapTheme.surfaceLight,
              thumbColor: SwiftSnapTheme.primaryPurple,
              overlayColor: SwiftSnapTheme.primaryPurple.withOpacity(0.2),
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: SwiftSnapTheme.textMuted),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: SwiftSnapTheme.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: SwiftSnapTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZone() {
    return Container(
      decoration: BoxDecoration(
        color: SwiftSnapTheme.busy.withOpacity(0.05),
        borderRadius: BorderRadius.circular(SwiftSnapTheme.radiusLg),
        border: Border.all(color: SwiftSnapTheme.busy.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                const Icon(
                    Icons.dangerous_rounded,
                    color: SwiftSnapTheme.busy,
                    size: 18),
                const SizedBox(width: 8),
                const Text(
                  'Danger Zone',
                  style: TextStyle(
                    color: SwiftSnapTheme.busy,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          _dangerAction(
            'Clear Cache',
            'Remove all cached data from servers',
            Icons.clear_all_rounded,
            () => _confirmDangerAction('Clear all server cache?'),
          ),
          Divider(height: 1, color: SwiftSnapTheme.busy.withOpacity(0.1)),
          _dangerAction(
            'Purge Old Messages',
            'Delete messages older than retention period',
            Icons.delete_sweep_rounded,
            () => _confirmDangerAction('Purge old messages?'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _dangerAction(
      String label, String subtitle, IconData icon, VoidCallback onTap) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(icon, color: SwiftSnapTheme.busy, size: 20),
      title: Text(
        label,
        style: const TextStyle(
          color: SwiftSnapTheme.busy,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: SwiftSnapTheme.textMuted,
          fontSize: 12,
        ),
      ),
      trailing: const Icon(
          Icons.chevron_right_rounded,
          color: SwiftSnapTheme.busy,
          size: 18),
      onTap: onTap,
    );
  }

  void _confirmDangerAction(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: SwiftSnapTheme.backgroundCard,
        title: const Text(
          'Are you sure?',
          style: TextStyle(color: SwiftSnapTheme.busy),
        ),
        content: Text(
          message,
          style: const TextStyle(color: SwiftSnapTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: SwiftSnapTheme.busy),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Action completed'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

class _SettingToggle extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isDanger;

  const _SettingToggle({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.onChanged,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius:
                  BorderRadius.circular(SwiftSnapTheme.radiusMd),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: isDanger && value
                        ? SwiftSnapTheme.busy
                        : SwiftSnapTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: SwiftSnapTheme.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: (v) {
              HapticFeedback.lightImpact();
              onChanged(v);
            },
            activeColor: isDanger ? SwiftSnapTheme.busy : SwiftSnapTheme.primaryPurple,
            inactiveThumbColor: SwiftSnapTheme.textMuted,
            inactiveTrackColor: SwiftSnapTheme.surfaceLight,
          ),
        ],
      ),
    );
  }
}
