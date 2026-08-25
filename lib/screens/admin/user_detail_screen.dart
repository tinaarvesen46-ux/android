import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/theme.dart';
import '../../models/user_model.dart';
import '../../api/services/admin_service.dart';
import 'edit_user_screen.dart';

class UserDetailScreen extends StatefulWidget {
  final UserModel user;
  const UserDetailScreen({super.key, required this.user});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  final AdminService _adminService = AdminService();
  late UserModel _user;
  bool _isBanned = false;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwiftSnapTheme.backgroundDark,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(),
                  const SizedBox(height: 16),
                  _buildStatsCard(),
                  const SizedBox(height: 16),
                  _buildRoleCard(),
                  const SizedBox(height: 16),
                  _buildActionsCard(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: SwiftSnapTheme.backgroundDark,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1A0533), Color(0xFF0A0A0F)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              child: Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(_user.avatarUrl),
                        backgroundColor: SwiftSnapTheme.surfaceLight,
                      ),
                      if (_user.isOnline)
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: SwiftSnapTheme.online,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: SwiftSnapTheme.backgroundDark,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            _user.displayName,
                            style: const TextStyle(
                              color: SwiftSnapTheme.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (_user.isVerified) ...[
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.verified_rounded,
                              color: SwiftSnapTheme.primaryBlue,
                              size: 18,
                            ),
                          ],
                        ],
                      ),
                      Text(
                        '@${_user.username}',
                        style: const TextStyle(
                          color: SwiftSnapTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        _user.isOnline
                            ? 'Online now'
                            : _user.lastSeenFormatted,
                        style: TextStyle(
                          color: _user.isOnline
                              ? SwiftSnapTheme.online
                              : SwiftSnapTheme.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: SwiftSnapTheme.glassmorphicDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Account Information',
            style: TextStyle(
              color: SwiftSnapTheme.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          _infoRow(
              Icons.badge_rounded, 'User ID', _user.id),
          _infoRow(
              Icons.email_rounded, 'Email', _user.email ?? 'Not set'),
          _infoRow(
              Icons.info_rounded, 'Bio', _user.bio ?? 'No bio'),
          _infoRow(
              Icons.location_on_rounded, 'Location',
              _user.location ?? 'Not set'),
          _infoRow(
              Icons.privacy_tip_rounded, 'Privacy',
              _privacyLabel(_user.privacyLevel)),
          _infoRow(
              Icons.account_circle_rounded, 'Account Type',
              _statusLabel(_user.accountStatus)),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: SwiftSnapTheme.glassmorphicDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statistics',
            style: TextStyle(
              color: SwiftSnapTheme.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _statBox(
                  '${_user.friendCount}',
                  'Friends',
                  Icons.people_rounded,
                  SwiftSnapTheme.primaryPurple,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _statBox(
                  '${_user.streakDays}',
                  'Day Streak',
                  Icons.local_fire_department_rounded,
                  SwiftSnapTheme.accentOrange,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _statBox(
                  _user.isVerified ? '✓' : '—',
                  'Verified',
                  Icons.verified_rounded,
                  SwiftSnapTheme.primaryBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statBox(
      String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(SwiftSnapTheme.radiusMd),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: SwiftSnapTheme.textMuted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: SwiftSnapTheme.glassmorphicDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Staff Role',
            style: TextStyle(
              color: SwiftSnapTheme.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: StaffRole.values.map((role) {
              final color = _roleColor(role);
              final selected = _user.staffRole == role;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _user = _user.copyWith(staffRole: role));
                  _adminService.updateUserRole(_user.id, role);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Role updated to ${_roleLabel(role)}'),
                      backgroundColor: color,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? color.withOpacity(0.2)
                        : SwiftSnapTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(
                        SwiftSnapTheme.radiusFull),
                    border: Border.all(
                      color: selected ? color : Colors.white12,
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    _roleLabel(role),
                    style: TextStyle(
                      color: selected ? color : SwiftSnapTheme.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: SwiftSnapTheme.glassmorphicDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Admin Actions',
            style: TextStyle(
              color: SwiftSnapTheme.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          // Primary edit button — full profile edit
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditUserScreen(
                    user: _user,
                    onSave: (updated) => setState(() => _user = updated),
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [SwiftSnapTheme.primaryPurple, SwiftSnapTheme.primaryPink],
                ),
                borderRadius: BorderRadius.circular(SwiftSnapTheme.radiusMd),
                boxShadow: [
                  BoxShadow(
                    color: SwiftSnapTheme.primaryPurple.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.edit_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 12),
                  Text(
                    'Edit User Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.chevron_right_rounded,
                      color: Colors.white70, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          _actionButton(
            icon: Icons.warning_amber_rounded,
            label: 'Send Warning',
            color: SwiftSnapTheme.accentOrange,
            onTap: () => _showWarnDialog(),
          ),
          const SizedBox(height: 10),
          _actionButton(
            icon: _isBanned ? Icons.check_circle_rounded : Icons.block_rounded,
            label: _isBanned ? 'Unban User' : 'Ban User',
            color: _isBanned ? SwiftSnapTheme.accentGreen : SwiftSnapTheme.busy,
            onTap: () => _toggleBan(),
          ),
          const SizedBox(height: 10),
          _actionButton(
            icon: Icons.email_rounded,
            label: 'Send Email',
            color: SwiftSnapTheme.primaryBlue,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Email sent to user'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(SwiftSnapTheme.radiusMd),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right_rounded,
              color: color.withOpacity(0.6),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: SwiftSnapTheme.primaryPurple),
          const SizedBox(width: 10),
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                color: SwiftSnapTheme.textMuted,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: SwiftSnapTheme.textPrimary,
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  void _showWarnDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: SwiftSnapTheme.backgroundCard,
        title: Text(
          'Warn ${_user.displayName}',
          style: const TextStyle(color: SwiftSnapTheme.textPrimary),
        ),
        content: TextField(
          controller: controller,
          maxLines: 3,
          style: const TextStyle(color: SwiftSnapTheme.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Warning message...',
            hintStyle: TextStyle(color: SwiftSnapTheme.textMuted),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: SwiftSnapTheme.accentOrange),
            onPressed: () {
              Navigator.pop(context);
              _adminService.warnUser(_user.id, controller.text);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Warning sent'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Send Warning'),
          ),
        ],
      ),
    );
  }

  void _toggleBan() {
    if (_isBanned) {
      _adminService.unbanUser(_user.id);
      setState(() => _isBanned = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_user.displayName} has been unbanned'),
          backgroundColor: SwiftSnapTheme.accentGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      _adminService.banUser(_user.id, 'Admin action');
      setState(() => _isBanned = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_user.displayName} has been banned'),
          backgroundColor: SwiftSnapTheme.busy,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Color _roleColor(StaffRole role) {
    switch (role) {
      case StaffRole.administrator:
        return SwiftSnapTheme.primaryPink;
      case StaffRole.moderator:
        return SwiftSnapTheme.primaryBlue;
      case StaffRole.support:
        return SwiftSnapTheme.accentGreen;
      case StaffRole.none:
        return SwiftSnapTheme.textMuted;
    }
  }

  String _roleLabel(StaffRole role) {
    switch (role) {
      case StaffRole.administrator:
        return 'Administrator';
      case StaffRole.moderator:
        return 'Moderator';
      case StaffRole.support:
        return 'Support';
      case StaffRole.none:
        return 'No Role';
    }
  }

  String _privacyLabel(PrivacyLevel level) {
    switch (level) {
      case PrivacyLevel.publicProfile:
        return 'Public';
      case PrivacyLevel.friendsOnly:
        return 'Friends Only';
      case PrivacyLevel.privateProfile:
        return 'Private';
    }
  }

  String _statusLabel(AccountStatus status) {
    switch (status) {
      case AccountStatus.normal:
        return 'Normal';
      case AccountStatus.verified:
        return 'Verified';
      case AccountStatus.creator:
        return 'Creator';
    }
  }
}
