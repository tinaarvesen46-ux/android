import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../theme/theme.dart';
import '../../providers/app_provider.dart';
import '../../models/admin_models.dart';
import '../../api/services/admin_service.dart';
import 'user_management_screen.dart';
import 'support_tickets_screen.dart';
import 'moderation_dashboard_screen.dart';
import 'analytics_screen.dart';
import 'system_settings_screen.dart';
import 'audit_logs_screen.dart';
import 'email_campaigns_screen.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen>
    with SingleTickerProviderStateMixin {
  final AdminService _adminService = AdminService();
  PlatformAnalytics? _analytics;
  bool _loading = true;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _loadAnalytics();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalytics() async {
    final result = await _adminService.getAnalytics();
    if (mounted) {
      setState(() {
        _analytics = result.data;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.currentUser;

    return Scaffold(
      backgroundColor: SwiftSnapTheme.backgroundDark,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(user?.displayName ?? 'Admin'),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRoleBanner(user),
                  const SizedBox(height: 20),
                  _buildMetricsRow(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Quick Actions'),
                  const SizedBox(height: 12),
                  _buildQuickActionsGrid(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Platform Status'),
                  const SizedBox(height: 12),
                  _buildStatusCard(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Recent Activity'),
                  const SizedBox(height: 12),
                  _buildRecentActivity(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(String name) {
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      backgroundColor: SwiftSnapTheme.backgroundDark,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A0533), Color(0xFF0A0A0F)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) => Transform.scale(
                          scale: _pulseAnimation.value,
                          child: child,
                        ),
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Color(0xFF22C55E),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'LIVE',
                        style: TextStyle(
                          color: SwiftSnapTheme.accentGreen,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ShaderMask(
                    shaderCallback: (bounds) =>
                        SwiftSnapTheme.primaryGradient.createShader(bounds),
                    child: const Text(
                      'Admin Panel',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    'SwiftSnap Control Center',
                    style: TextStyle(
                      color: SwiftSnapTheme.textMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleBanner(user) {
    final roleColor = _getRoleColor(user?.staffRole);
    final roleLabel = _getRoleLabel(user?.staffRole);
    final roleIcon = _getRoleIcon(user?.staffRole);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [roleColor.withOpacity(0.2), roleColor.withOpacity(0.05)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(SwiftSnapTheme.radiusMd),
        border: Border.all(color: roleColor.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(roleIcon, color: roleColor, size: 20),
          const SizedBox(width: 10),
          Text(
            'Logged in as $roleLabel',
            style: TextStyle(
              color: roleColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: roleColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(SwiftSnapTheme.radiusFull),
            ),
            child: Text(
              roleLabel.toUpperCase(),
              style: TextStyle(
                color: roleColor,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsRow() {
    if (_loading) {
      return Row(
        children: List.generate(
          2,
          (_) => Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _shimmerCard(height: 90),
            ),
          ),
        ),
      );
    }

    final a = _analytics;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _metricCard(
                label: 'Total Users',
                value: _formatNumber(a?.totalUsers ?? 0),
                icon: Icons.people_rounded,
                gradient: SwiftSnapTheme.primaryGradient,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _metricCard(
                label: 'Active Today',
                value: _formatNumber(a?.activeUsersToday ?? 0),
                icon: Icons.bolt_rounded,
                gradient: SwiftSnapTheme.secondaryGradient,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _metricCard(
                label: 'Open Tickets',
                value: '${a?.openTickets ?? 0}',
                icon: Icons.support_agent_rounded,
                gradient: const LinearGradient(
                  colors: [Color(0xFFF97316), Color(0xFFEF4444)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _metricCard(
                label: 'Reports',
                value: '${a?.pendingReports ?? 0}',
                icon: Icons.flag_rounded,
                gradient: const LinearGradient(
                  colors: [Color(0xFFEF4444), Color(0xFFEC4899)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _metricCard({
    required String label,
    required String value,
    required IconData icon,
    required LinearGradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: SwiftSnapTheme.glassmorphicDecoration(
        borderRadius: SwiftSnapTheme.radiusLg,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(SwiftSnapTheme.radiusMd),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: SwiftSnapTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: SwiftSnapTheme.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: SwiftSnapTheme.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    final actions = [
      _AdminAction(
        label: 'Users',
        icon: Icons.manage_accounts_rounded,
        gradient: SwiftSnapTheme.primaryGradient,
        screen: const UserManagementScreen(),
      ),
      _AdminAction(
        label: 'Tickets',
        icon: Icons.support_agent_rounded,
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF06B6D4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        screen: const SupportTicketsScreen(),
      ),
      _AdminAction(
        label: 'Moderation',
        icon: Icons.shield_rounded,
        gradient: const LinearGradient(
          colors: [Color(0xFFF97316), Color(0xFFEF4444)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        screen: const ModerationDashboardScreen(),
      ),
      _AdminAction(
        label: 'Analytics',
        icon: Icons.bar_chart_rounded,
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF06B6D4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        screen: const AnalyticsScreen(),
      ),
      _AdminAction(
        label: 'Campaigns',
        icon: Icons.campaign_rounded,
        gradient: const LinearGradient(
          colors: [Color(0xFFEC4899), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        screen: const EmailCampaignsScreen(),
      ),
      _AdminAction(
        label: 'Settings',
        icon: Icons.settings_rounded,
        gradient: const LinearGradient(
          colors: [Color(0xFF64748B), Color(0xFF475569)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        screen: const SystemSettingsScreen(),
      ),
      _AdminAction(
        label: 'Audit Logs',
        icon: Icons.history_rounded,
        gradient: const LinearGradient(
          colors: [Color(0xFFFBBF24), Color(0xFFF97316)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        screen: const AuditLogsScreen(),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: actions.length,
      itemBuilder: (context, i) => _buildActionTile(actions[i]),
    );
  }

  Widget _buildActionTile(_AdminAction action) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, animation, __) => action.screen,
            transitionsBuilder: (_, animation, __, child) => SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
              child: child,
            ),
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: action.gradient,
              borderRadius: BorderRadius.circular(SwiftSnapTheme.radiusMd),
              boxShadow: [
                BoxShadow(
                  color: (action.gradient.colors.first).withOpacity(0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(action.icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            action.label,
            style: const TextStyle(
              color: SwiftSnapTheme.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    final load = _analytics?.serverLoad ?? 62.4;
    final loadColor = load < 50
        ? SwiftSnapTheme.accentGreen
        : load < 80
            ? SwiftSnapTheme.accentOrange
            : SwiftSnapTheme.busy;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: SwiftSnapTheme.glassmorphicDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: SwiftSnapTheme.online,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'All Systems Operational',
                style: TextStyle(
                  color: SwiftSnapTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                'v1.0.0',
                style: TextStyle(
                  color: SwiftSnapTheme.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _statusRow(
            'API Server',
            'Healthy',
            SwiftSnapTheme.online,
            Icons.cloud_done_rounded,
          ),
          const SizedBox(height: 10),
          _statusRow(
            'Database',
            'Healthy',
            SwiftSnapTheme.online,
            Icons.storage_rounded,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.speed_rounded,
                color: loadColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Server Load',
                style: const TextStyle(
                  color: SwiftSnapTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              Text(
                '${load.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: loadColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(SwiftSnapTheme.radiusFull),
            child: LinearProgressIndicator(
              value: load / 100,
              backgroundColor: SwiftSnapTheme.surfaceLight,
              valueColor: AlwaysStoppedAnimation<Color>(loadColor),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusRow(
      String label, String status, Color color, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: SwiftSnapTheme.textSecondary,
            fontSize: 13,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(SwiftSnapTheme.radiusFull),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    final items = [
      _ActivityItem(
        icon: Icons.person_add_rounded,
        color: SwiftSnapTheme.primaryPurple,
        title: '1,240 new users today',
        subtitle: 'Growing +12% vs yesterday',
        time: 'Live',
      ),
      _ActivityItem(
        icon: Icons.support_agent_rounded,
        color: SwiftSnapTheme.primaryBlue,
        title: '3 tickets need attention',
        subtitle: '2 high priority, 1 urgent',
        time: '5m ago',
      ),
      _ActivityItem(
        icon: Icons.flag_rounded,
        color: SwiftSnapTheme.accentOrange,
        title: '5 new content reports',
        subtitle: 'Awaiting moderation review',
        time: '12m ago',
      ),
      _ActivityItem(
        icon: Icons.email_rounded,
        color: SwiftSnapTheme.primaryPink,
        title: 'Campaign "Summer Vibes" sent',
        subtitle: '89,330 recipients · 24.1% open rate',
        time: '2h ago',
      ),
    ];

    return Container(
      decoration: SwiftSnapTheme.glassmorphicDecoration(),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return Column(
            children: [
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(SwiftSnapTheme.radiusMd),
                  ),
                  child: Icon(item.icon, color: item.color, size: 20),
                ),
                title: Text(
                  item.title,
                  style: const TextStyle(
                    color: SwiftSnapTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  item.subtitle,
                  style: const TextStyle(
                    color: SwiftSnapTheme.textMuted,
                    fontSize: 11,
                  ),
                ),
                trailing: Text(
                  item.time,
                  style: const TextStyle(
                    color: SwiftSnapTheme.textMuted,
                    fontSize: 11,
                  ),
                ),
              ),
              if (i < items.length - 1)
                Divider(
                  height: 1,
                  color: Colors.white.withOpacity(0.05),
                  indent: 72,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _shimmerCard({required double height}) {
    return Container(
      height: height,
      decoration: SwiftSnapTheme.glassmorphicDecoration(),
    );
  }

  Color _getRoleColor(staffRole) {
    switch (staffRole?.toString()) {
      case 'StaffRole.administrator':
        return const Color(0xFFEC4899);
      case 'StaffRole.moderator':
        return const Color(0xFF3B82F6);
      case 'StaffRole.support':
        return const Color(0xFF10B981);
      default:
        return SwiftSnapTheme.primaryPurple;
    }
  }

  String _getRoleLabel(staffRole) {
    switch (staffRole?.toString()) {
      case 'StaffRole.administrator':
        return 'Administrator';
      case 'StaffRole.moderator':
        return 'Moderator';
      case 'StaffRole.support':
        return 'Support Agent';
      default:
        return 'Staff';
    }
  }

  IconData _getRoleIcon(staffRole) {
    switch (staffRole?.toString()) {
      case 'StaffRole.administrator':
        return Icons.admin_panel_settings_rounded;
      case 'StaffRole.moderator':
        return Icons.shield_rounded;
      case 'StaffRole.support':
        return Icons.support_agent_rounded;
      default:
        return Icons.badge_rounded;
    }
  }

  String _formatNumber(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}

class _AdminAction {
  final String label;
  final IconData icon;
  final LinearGradient gradient;
  final Widget screen;
  const _AdminAction({
    required this.label,
    required this.icon,
    required this.gradient,
    required this.screen,
  });
}

class _ActivityItem {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String time;
  const _ActivityItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.time,
  });
}
