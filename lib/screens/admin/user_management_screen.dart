import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/theme.dart';
import '../../models/user_model.dart';
import '../../api/services/admin_service.dart';
import 'user_detail_screen.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen>
    with SingleTickerProviderStateMixin {
  final AdminService _adminService = AdminService();
  final TextEditingController _searchController = TextEditingController();
  late final TabController _tabController;

  List<UserModel> _users = [];
  bool _loading = false;
  String _selectedRole = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadUsers();
    _buildMockUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _buildMockUsers() {
    _users = [
      UserModel(
        id: 'u001',
        username: 'alex_vibe',
        displayName: 'Alex Chen',
        email: 'alex@swiftsnap.com',
        avatarUrl: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=100',
        isVerified: true,
        isOnline: true,
        accountStatus: AccountStatus.creator,
        staffRole: StaffRole.administrator,
        friendCount: 1240,
        streakDays: 87,
      ),
      UserModel(
        id: 'u002',
        username: 'sarah_creates',
        displayName: 'Sarah Miller',
        email: 'sarah@gmail.com',
        avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100',
        isVerified: true,
        isOnline: true,
        accountStatus: AccountStatus.creator,
        friendCount: 892,
        streakDays: 34,
      ),
      UserModel(
        id: 'u003',
        username: 'mike_photo',
        displayName: 'Mike Johnson',
        email: 'mike@gmail.com',
        avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100',
        isVerified: false,
        isOnline: false,
        accountStatus: AccountStatus.normal,
        friendCount: 45,
        streakDays: 7,
      ),
      UserModel(
        id: 'u004',
        username: 'emma_vibes',
        displayName: 'Emma Wilson',
        email: 'emma@gmail.com',
        avatarUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100',
        isVerified: true,
        isOnline: false,
        accountStatus: AccountStatus.verified,
        staffRole: StaffRole.moderator,
        friendCount: 578,
        streakDays: 22,
      ),
      UserModel(
        id: 'u005',
        username: 'james_art',
        displayName: 'James Brown',
        email: 'james@gmail.com',
        avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100',
        isVerified: false,
        isOnline: false,
        accountStatus: AccountStatus.normal,
        staffRole: StaffRole.support,
        friendCount: 123,
        streakDays: 3,
      ),
      UserModel(
        id: 'u006',
        username: 'lily_music',
        displayName: 'Lily Zhang',
        email: 'lily@gmail.com',
        avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100',
        isVerified: true,
        isOnline: true,
        accountStatus: AccountStatus.creator,
        friendCount: 2341,
        streakDays: 120,
      ),
    ];
  }

  Future<void> _loadUsers() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => _loading = false);
  }

  List<UserModel> get _filteredUsers {
    final query = _searchController.text.toLowerCase();
    return _users.where((u) {
      final matchesSearch = query.isEmpty ||
          u.displayName.toLowerCase().contains(query) ||
          u.username.toLowerCase().contains(query) ||
          (u.email?.toLowerCase().contains(query) ?? false);
      final matchesRole = _selectedRole == 'all' ||
          (_selectedRole == 'staff' && u.staffRole != StaffRole.none) ||
          (_selectedRole == 'verified' && u.isVerified) ||
          (_selectedRole == 'normal' && u.staffRole == StaffRole.none);
      return matchesSearch && matchesRole;
    }).toList();
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
          'User Management',
          style: TextStyle(
            color: SwiftSnapTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: SwiftSnapTheme.primaryGradient,
              borderRadius: BorderRadius.circular(SwiftSnapTheme.radiusFull),
            ),
            child: Text(
              '${_users.length} users',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              children: [
                _buildSearchBar(),
                const SizedBox(height: 10),
                _buildRoleFilter(),
              ],
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                color: SwiftSnapTheme.primaryPurple,
              ),
            )
          : _filteredUsers.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: _filteredUsers.length,
                  itemBuilder: (context, i) =>
                      _buildUserTile(_filteredUsers[i]),
                ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: SwiftSnapTheme.glassmorphicDecoration(
        borderRadius: SwiftSnapTheme.radiusMd,
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(color: SwiftSnapTheme.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search users by name, username or email...',
          hintStyle: const TextStyle(
            color: SwiftSnapTheme.textMuted,
            fontSize: 13,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: SwiftSnapTheme.textMuted,
            size: 20,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.clear_rounded,
                    color: SwiftSnapTheme.textMuted,
                    size: 18,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildRoleFilter() {
    final filters = [
      ('all', 'All'),
      ('staff', 'Staff'),
      ('verified', 'Verified'),
      ('normal', 'Regular'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final selected = _selectedRole == f.$1;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedRole = f.$1);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                gradient: selected ? SwiftSnapTheme.primaryGradient : null,
                color: selected ? null : SwiftSnapTheme.surfaceColor,
                borderRadius:
                    BorderRadius.circular(SwiftSnapTheme.radiusFull),
                border: Border.all(
                  color: selected
                      ? Colors.transparent
                      : Colors.white.withOpacity(0.1),
                ),
              ),
              child: Text(
                f.$2,
                style: TextStyle(
                  color: selected
                      ? Colors.white
                      : SwiftSnapTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildUserTile(UserModel user) {
    final roleColor = _getRoleColor(user.staffRole);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, animation, __) =>
                UserDetailScreen(user: user),
            transitionsBuilder: (_, animation, __, child) => SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                  parent: animation, curve: Curves.easeOutCubic)),
              child: child,
            ),
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: SwiftSnapTheme.glassmorphicDecoration(),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundImage: NetworkImage(user.avatarUrl),
                  backgroundColor: SwiftSnapTheme.surfaceLight,
                ),
                if (user.isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
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
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        user.displayName,
                        style: const TextStyle(
                          color: SwiftSnapTheme.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (user.isVerified) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.verified_rounded,
                          color: SwiftSnapTheme.primaryBlue,
                          size: 14,
                        ),
                      ],
                    ],
                  ),
                  Text(
                    '@${user.username}',
                    style: const TextStyle(
                      color: SwiftSnapTheme.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  if (user.email != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      user.email!,
                      style: const TextStyle(
                        color: SwiftSnapTheme.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _statChip(
                          '${user.friendCount} friends',
                          Icons.people_rounded),
                      const SizedBox(width: 6),
                      _statChip(
                          '${user.streakDays}d streak',
                          Icons.local_fire_department_rounded),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (user.staffRole != StaffRole.none)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: roleColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(
                          SwiftSnapTheme.radiusFull),
                    ),
                    child: Text(
                      _roleLabel(user.staffRole),
                      style: TextStyle(
                        color: roleColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                _quickActionMenu(user),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: SwiftSnapTheme.surfaceLight,
        borderRadius: BorderRadius.circular(SwiftSnapTheme.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: SwiftSnapTheme.textMuted),
          const SizedBox(width: 3),
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

  Widget _quickActionMenu(UserModel user) {
    return GestureDetector(
      onTap: () => _showUserActions(user),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: SwiftSnapTheme.surfaceLight,
          borderRadius: BorderRadius.circular(SwiftSnapTheme.radiusMd),
        ),
        child: const Icon(
          Icons.more_vert_rounded,
          color: SwiftSnapTheme.textMuted,
          size: 16,
        ),
      ),
    );
  }

  void _showUserActions(UserModel user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: SwiftSnapTheme.backgroundCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(SwiftSnapTheme.radius2Xl),
        ),
      ),
      builder: (_) => _UserActionsSheet(
        user: user,
        adminService: _adminService,
        onRoleChanged: (newRole) {
          setState(() {
            final idx = _users.indexWhere((u) => u.id == user.id);
            if (idx != -1) {
              _users[idx] = user.copyWith(staffRole: newRole);
            }
          });
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: SwiftSnapTheme.textMuted,
          ),
          const SizedBox(height: 16),
          const Text(
            'No users found',
            style: TextStyle(
              color: SwiftSnapTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try a different search term or filter',
            style: TextStyle(color: SwiftSnapTheme.textMuted, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(StaffRole role) {
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
        return 'ADMIN';
      case StaffRole.moderator:
        return 'MOD';
      case StaffRole.support:
        return 'SUPPORT';
      case StaffRole.none:
        return '';
    }
  }
}

// ─── User Actions Bottom Sheet ───────────────────────────────
class _UserActionsSheet extends StatelessWidget {
  final UserModel user;
  final AdminService adminService;
  final void Function(StaffRole) onRoleChanged;

  const _UserActionsSheet({
    required this.user,
    required this.adminService,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundImage: NetworkImage(user.avatarUrl),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName,
                    style: const TextStyle(
                      color: SwiftSnapTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '@${user.username}',
                    style: const TextStyle(
                      color: SwiftSnapTheme.textMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Assign Role',
            style: TextStyle(
              color: SwiftSnapTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _roleButton(
                  context, 'Admin', StaffRole.administrator,
                  SwiftSnapTheme.primaryPink),
              const SizedBox(width: 8),
              _roleButton(
                  context, 'Mod', StaffRole.moderator,
                  SwiftSnapTheme.primaryBlue),
              const SizedBox(width: 8),
              _roleButton(
                  context, 'Support', StaffRole.support,
                  SwiftSnapTheme.accentGreen),
              const SizedBox(width: 8),
              _roleButton(
                  context, 'None', StaffRole.none,
                  SwiftSnapTheme.textMuted),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white12),
          const SizedBox(height: 12),
          _actionTile(
            context,
            icon: Icons.warning_amber_rounded,
            color: SwiftSnapTheme.accentOrange,
            label: 'Send Warning',
            onTap: () {
              Navigator.pop(context);
              _showWarnDialog(context);
            },
          ),
          _actionTile(
            context,
            icon: Icons.block_rounded,
            color: SwiftSnapTheme.busy,
            label: 'Ban User',
            onTap: () {
              Navigator.pop(context);
              _showBanDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _roleButton(BuildContext context, String label, StaffRole role,
      Color color) {
    final selected = user.staffRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          onRoleChanged(role);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Role updated to $label'),
              backgroundColor: color,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? color.withOpacity(0.2) : SwiftSnapTheme.surfaceColor,
            borderRadius: BorderRadius.circular(SwiftSnapTheme.radiusMd),
            border: Border.all(
              color: selected ? color : Colors.transparent,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? color : SwiftSnapTheme.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionTile(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(SwiftSnapTheme.radiusMd),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showWarnDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: SwiftSnapTheme.backgroundCard,
        title: const Text('Send Warning',
            style: TextStyle(color: SwiftSnapTheme.textPrimary)),
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
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: SwiftSnapTheme.accentOrange),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Warning sent successfully'),
                  backgroundColor: SwiftSnapTheme.accentOrange,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _showBanDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: SwiftSnapTheme.backgroundCard,
        title: Text(
          'Ban ${user.displayName}?',
          style: const TextStyle(color: SwiftSnapTheme.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'This will immediately ban the user from the platform.',
              style: TextStyle(color: SwiftSnapTheme.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              style: const TextStyle(color: SwiftSnapTheme.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Reason for ban...',
                hintStyle: TextStyle(color: SwiftSnapTheme.textMuted),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: SwiftSnapTheme.busy),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${user.displayName} has been banned'),
                  backgroundColor: SwiftSnapTheme.busy,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Ban User'),
          ),
        ],
      ),
    );
  }
}
