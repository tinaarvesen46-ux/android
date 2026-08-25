import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/theme.dart';
import '../../models/user_model.dart';

/// Admin screen to fully edit any user's account details.
class EditUserScreen extends StatefulWidget {
  final UserModel user;
  final ValueChanged<UserModel> onSave;

  const EditUserScreen({
    super.key,
    required this.user,
    required this.onSave,
  });

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  // Text controllers
  late final TextEditingController _displayNameCtrl;
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _bioCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _pronounsCtrl;
  late final TextEditingController _newPasswordCtrl;
  late final TextEditingController _confirmPasswordCtrl;

  // Dropdown values
  late AccountStatus _accountStatus;
  late StaffRole _staffRole;
  late PrivacyLevel _privacyLevel;
  late bool _isVerified;

  bool _obscureNewPw = true;
  bool _obscureConfirmPw = true;

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    _displayNameCtrl = TextEditingController(text: u.displayName);
    _usernameCtrl = TextEditingController(text: u.username);
    _emailCtrl = TextEditingController(text: u.email ?? '');
    _phoneCtrl = TextEditingController(text: '');
    _bioCtrl = TextEditingController(text: u.bio ?? '');
    _locationCtrl = TextEditingController(text: u.location ?? '');
    _pronounsCtrl = TextEditingController(text: u.pronouns ?? '');
    _newPasswordCtrl = TextEditingController();
    _confirmPasswordCtrl = TextEditingController();
    _accountStatus = u.accountStatus;
    _staffRole = u.staffRole;
    _privacyLevel = u.privacyLevel;
    _isVerified = u.isVerified;
  }

  @override
  void dispose() {
    _displayNameCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _bioCtrl.dispose();
    _locationCtrl.dispose();
    _pronounsCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    // Extra: password match check
    if (_newPasswordCtrl.text.isNotEmpty &&
        _newPasswordCtrl.text != _confirmPasswordCtrl.text) {
      _showError('Passwords do not match');
      return;
    }
    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

    // TODO: Replace with real API call — AdminService.updateUser(...)
    await Future.delayed(const Duration(milliseconds: 900));

    final updated = widget.user.copyWith(
      displayName: _displayNameCtrl.text.trim(),
      username: _usernameCtrl.text.trim(),
      email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
      bio: _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
      location:
          _locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text.trim(),
      pronouns:
          _pronounsCtrl.text.trim().isEmpty ? null : _pronounsCtrl.text.trim(),
      accountStatus: _accountStatus,
      staffRole: _staffRole,
      privacyLevel: _privacyLevel,
      isVerified: _isVerified,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);
    widget.onSave(updated);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Text('${updated.displayName}\'s profile updated'),
          ],
        ),
        backgroundColor: SwiftSnapTheme.accentGreen,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: SwiftSnapTheme.busy,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwiftSnapTheme.backgroundDark,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildUserHeader(),
                    const SizedBox(height: 20),
                    _buildSection(
                      icon: Icons.person_rounded,
                      title: 'Basic Information',
                      color: SwiftSnapTheme.primaryPurple,
                      children: [
                        _buildField(
                          controller: _displayNameCtrl,
                          label: 'Display Name',
                          icon: Icons.badge_rounded,
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Display name is required'
                              : null,
                        ),
                        const SizedBox(height: 14),
                        _buildField(
                          controller: _usernameCtrl,
                          label: 'Username',
                          icon: Icons.alternate_email_rounded,
                          prefix: '@',
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Username is required';
                            }
                            if (!RegExp(r'^[a-zA-Z0-9_]{3,30}$')
                                .hasMatch(v.trim())) {
                              return '3–30 chars, letters/numbers/underscore only';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        _buildField(
                          controller: _bioCtrl,
                          label: 'Bio',
                          icon: Icons.edit_note_rounded,
                          maxLines: 3,
                          maxLength: 150,
                        ),
                        const SizedBox(height: 14),
                        _buildField(
                          controller: _pronounsCtrl,
                          label: 'Pronouns',
                          icon: Icons.wc_rounded,
                          hint: 'e.g. they/them',
                        ),
                        const SizedBox(height: 14),
                        _buildField(
                          controller: _locationCtrl,
                          label: 'Location',
                          icon: Icons.location_on_rounded,
                          hint: 'City, Country',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      icon: Icons.contact_mail_rounded,
                      title: 'Contact & Credentials',
                      color: SwiftSnapTheme.primaryBlue,
                      children: [
                        _buildField(
                          controller: _emailCtrl,
                          label: 'Email Address',
                          icon: Icons.email_rounded,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v != null &&
                                v.trim().isNotEmpty &&
                                !v.contains('@')) {
                              return 'Enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        _buildField(
                          controller: _phoneCtrl,
                          label: 'Phone Number',
                          icon: Icons.phone_rounded,
                          keyboardType: TextInputType.phone,
                          hint: '+1 555 000 0000',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      icon: Icons.lock_rounded,
                      title: 'Reset Password',
                      color: SwiftSnapTheme.accentOrange,
                      subtitle: 'Leave blank to keep current password',
                      children: [
                        _buildPasswordField(
                          controller: _newPasswordCtrl,
                          label: 'New Password',
                          obscure: _obscureNewPw,
                          onToggle: () =>
                              setState(() => _obscureNewPw = !_obscureNewPw),
                          validator: (v) {
                            if (v != null &&
                                v.isNotEmpty &&
                                v.length < 8) {
                              return 'Minimum 8 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        _buildPasswordField(
                          controller: _confirmPasswordCtrl,
                          label: 'Confirm New Password',
                          obscure: _obscureConfirmPw,
                          onToggle: () => setState(
                              () => _obscureConfirmPw = !_obscureConfirmPw),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      icon: Icons.admin_panel_settings_rounded,
                      title: 'Account Settings',
                      color: SwiftSnapTheme.primaryPink,
                      children: [
                        _buildDropdownRow<AccountStatus>(
                          label: 'Account Status',
                          icon: Icons.stars_rounded,
                          value: _accountStatus,
                          items: AccountStatus.values,
                          itemLabel: _statusLabel,
                          itemColor: _statusColor,
                          onChanged: (v) =>
                              setState(() => _accountStatus = v!),
                        ),
                        const SizedBox(height: 14),
                        _buildDropdownRow<StaffRole>(
                          label: 'Staff Role',
                          icon: Icons.security_rounded,
                          value: _staffRole,
                          items: StaffRole.values,
                          itemLabel: _roleLabel,
                          itemColor: _roleColor,
                          onChanged: (v) => setState(() => _staffRole = v!),
                        ),
                        const SizedBox(height: 14),
                        _buildDropdownRow<PrivacyLevel>(
                          label: 'Privacy Level',
                          icon: Icons.privacy_tip_rounded,
                          value: _privacyLevel,
                          items: PrivacyLevel.values,
                          itemLabel: _privacyLabel,
                          itemColor: (_) => SwiftSnapTheme.textSecondary,
                          onChanged: (v) =>
                              setState(() => _privacyLevel = v!),
                        ),
                        const SizedBox(height: 14),
                        _buildSwitchRow(
                          label: 'Verified Badge',
                          icon: Icons.verified_rounded,
                          subtitle: 'Show blue verified checkmark',
                          value: _isVerified,
                          color: SwiftSnapTheme.primaryBlue,
                          onChanged: (v) => setState(() => _isVerified = v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    _buildSaveButton(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: SwiftSnapTheme.backgroundDark,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded,
            color: SwiftSnapTheme.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Edit User',
        style: TextStyle(
          color: SwiftSnapTheme.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: TextButton.icon(
            onPressed: _isSaving ? null : _handleSave,
            icon: _isSaving
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : const Icon(Icons.check_rounded,
                    color: Colors.white, size: 18),
            label: Text(
              _isSaving ? 'Saving…' : 'Save',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w700),
            ),
            style: TextButton.styleFrom(
              backgroundColor: SwiftSnapTheme.primaryPurple.withOpacity(0.25),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            SwiftSnapTheme.primaryPurple.withOpacity(0.18),
            SwiftSnapTheme.primaryPink.withOpacity(0.12),
          ],
        ),
        borderRadius: BorderRadius.circular(SwiftSnapTheme.radiusLg),
        border: Border.all(
            color: SwiftSnapTheme.primaryPurple.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(widget.user.avatarUrl),
            backgroundColor: SwiftSnapTheme.surfaceLight,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Editing: ${widget.user.displayName}',
                  style: const TextStyle(
                    color: SwiftSnapTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '@${widget.user.username} • ID: ${widget.user.id}',
                  style: const TextStyle(
                    color: SwiftSnapTheme.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: SwiftSnapTheme.accentOrange.withOpacity(0.15),
              borderRadius: BorderRadius.circular(SwiftSnapTheme.radiusFull),
              border: Border.all(
                  color: SwiftSnapTheme.accentOrange.withOpacity(0.4)),
            ),
            child: const Text(
              'ADMIN EDIT',
              style: TextStyle(
                color: SwiftSnapTheme.accentOrange,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required Color color,
    required List<Widget> children,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: SwiftSnapTheme.glassmorphicDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: color,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle != null)
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
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    int? maxLength,
    String? hint,
    String? prefix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      style: const TextStyle(color: SwiftSnapTheme.textPrimary, fontSize: 14),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixText: prefix,
        prefixIcon: Icon(icon, color: SwiftSnapTheme.textMuted, size: 18),
        labelStyle:
            const TextStyle(color: SwiftSnapTheme.textSecondary, fontSize: 13),
        hintStyle:
            const TextStyle(color: SwiftSnapTheme.textMuted, fontSize: 13),
        prefixStyle:
            const TextStyle(color: SwiftSnapTheme.textSecondary, fontSize: 14),
        counterStyle:
            const TextStyle(color: SwiftSnapTheme.textMuted, fontSize: 11),
        filled: true,
        fillColor: SwiftSnapTheme.surfaceColor,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SwiftSnapTheme.radiusMd),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SwiftSnapTheme.radiusMd),
          borderSide: const BorderSide(
              color: SwiftSnapTheme.primaryPurple, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SwiftSnapTheme.radiusMd),
          borderSide: BorderSide(color: SwiftSnapTheme.busy.withOpacity(0.8)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SwiftSnapTheme.radiusMd),
          borderSide: const BorderSide(color: SwiftSnapTheme.busy, width: 1.5),
        ),
        errorStyle: const TextStyle(color: SwiftSnapTheme.busy, fontSize: 11),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: SwiftSnapTheme.textPrimary, fontSize: 14),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline_rounded,
            color: SwiftSnapTheme.textMuted, size: 18),
        suffixIcon: IconButton(
          icon: Icon(
            obscure
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: SwiftSnapTheme.textSecondary,
            size: 18,
          ),
          onPressed: onToggle,
        ),
        labelStyle:
            const TextStyle(color: SwiftSnapTheme.textSecondary, fontSize: 13),
        filled: true,
        fillColor: SwiftSnapTheme.surfaceColor,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SwiftSnapTheme.radiusMd),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SwiftSnapTheme.radiusMd),
          borderSide: const BorderSide(
              color: SwiftSnapTheme.accentOrange, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SwiftSnapTheme.radiusMd),
          borderSide: BorderSide(color: SwiftSnapTheme.busy.withOpacity(0.8)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SwiftSnapTheme.radiusMd),
          borderSide: const BorderSide(color: SwiftSnapTheme.busy, width: 1.5),
        ),
        errorStyle: const TextStyle(color: SwiftSnapTheme.busy, fontSize: 11),
      ),
    );
  }

  Widget _buildDropdownRow<T>({
    required String label,
    required IconData icon,
    required T value,
    required List<T> items,
    required String Function(T) itemLabel,
    required Color Function(T) itemColor,
    required ValueChanged<T?> onChanged,
  }) {
    return Row(
      children: [
        Icon(icon, color: SwiftSnapTheme.textMuted, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: SwiftSnapTheme.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: SwiftSnapTheme.surfaceColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              dropdownColor: SwiftSnapTheme.backgroundCard,
              iconEnabledColor: SwiftSnapTheme.textSecondary,
              style: TextStyle(
                color: itemColor(value),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              borderRadius: BorderRadius.circular(12),
              items: items
                  .map((item) => DropdownMenuItem<T>(
                        value: item,
                        child: Text(
                          itemLabel(item),
                          style: TextStyle(
                            color: itemColor(item),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchRow({
    required String label,
    required IconData icon,
    required String subtitle,
    required bool value,
    required Color color,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: SwiftSnapTheme.textPrimary,
                  fontSize: 13,
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
          onChanged: onChanged,
          activeColor: color,
          inactiveTrackColor: SwiftSnapTheme.surfaceLight,
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: _isSaving ? null : _handleSave,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: _isSaving
              ? null
              : const LinearGradient(colors: [
                  SwiftSnapTheme.primaryPurple,
                  SwiftSnapTheme.primaryPink,
                ]),
          color: _isSaving ? SwiftSnapTheme.surfaceColor : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _isSaving
              ? []
              : [
                  BoxShadow(
                    color: SwiftSnapTheme.primaryPurple.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Center(
          child: _isSaving
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_rounded,
                        color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Save Changes',
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
    );
  }

  // ─── Label helpers ──────────────────────────────────────────────────────

  String _statusLabel(AccountStatus s) {
    switch (s) {
      case AccountStatus.normal:
        return 'Normal';
      case AccountStatus.verified:
        return 'Verified';
      case AccountStatus.creator:
        return 'Creator';
    }
  }

  Color _statusColor(AccountStatus s) {
    switch (s) {
      case AccountStatus.normal:
        return SwiftSnapTheme.textSecondary;
      case AccountStatus.verified:
        return SwiftSnapTheme.primaryBlue;
      case AccountStatus.creator:
        return SwiftSnapTheme.accentOrange;
    }
  }

  String _roleLabel(StaffRole r) {
    switch (r) {
      case StaffRole.none:
        return 'No Role';
      case StaffRole.support:
        return 'Support';
      case StaffRole.moderator:
        return 'Moderator';
      case StaffRole.administrator:
        return 'Administrator';
    }
  }

  Color _roleColor(StaffRole r) {
    switch (r) {
      case StaffRole.none:
        return SwiftSnapTheme.textMuted;
      case StaffRole.support:
        return SwiftSnapTheme.accentGreen;
      case StaffRole.moderator:
        return SwiftSnapTheme.primaryBlue;
      case StaffRole.administrator:
        return SwiftSnapTheme.primaryPink;
    }
  }

  String _privacyLabel(PrivacyLevel p) {
    switch (p) {
      case PrivacyLevel.publicProfile:
        return 'Public';
      case PrivacyLevel.friendsOnly:
        return 'Friends Only';
      case PrivacyLevel.privateProfile:
        return 'Private';
    }
  }
}
