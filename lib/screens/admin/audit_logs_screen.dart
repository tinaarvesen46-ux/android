import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../models/admin_models.dart';

class AuditLogsScreen extends StatefulWidget {
  const AuditLogsScreen({super.key});

  @override
  State<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends State<AuditLogsScreen> {
  final List<AuditLog> _logs = [
    AuditLog(
      id: 'log_001',
      adminId: 'u001',
      adminName: 'Alex Chen',
      adminAvatar:
          'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=100',
      action: AuditAction.userBanned,
      targetId: 'u_bad',
      targetName: 'bad_actor_99',
      description: 'Banned user for repeated harassment reports',
      createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
    ),
    AuditLog(
      id: 'log_002',
      adminId: 'u004',
      adminName: 'Emma Wilson',
      adminAvatar:
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100',
      action: AuditAction.contentRemoved,
      targetId: 'story_xyz',
      targetName: 'Spam Story',
      description: 'Removed story containing prohibited content',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    AuditLog(
      id: 'log_003',
      adminId: 'u001',
      adminName: 'Alex Chen',
      adminAvatar:
          'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=100',
      action: AuditAction.userRoleChanged,
      targetId: 'u004',
      targetName: 'Emma Wilson',
      description: 'Changed role from Support to Moderator',
      metadata: {'from': 'support', 'to': 'moderator'},
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    AuditLog(
      id: 'log_004',
      adminId: 'u001',
      adminName: 'Alex Chen',
      adminAvatar:
          'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=100',
      action: AuditAction.campaignSent,
      targetId: 'camp_001',
      targetName: 'Summer Vibes Newsletter',
      description: 'Email campaign sent to 89,330 users',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    AuditLog(
      id: 'log_005',
      adminId: 'u005',
      adminName: 'James Brown',
      adminAvatar:
          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100',
      action: AuditAction.ticketResolved,
      targetId: 'TKT-004',
      targetName: 'TKT-004 Harassment Report',
      description: 'Resolved support ticket for harassment complaint',
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    AuditLog(
      id: 'log_006',
      adminId: 'u001',
      adminName: 'Alex Chen',
      adminAvatar:
          'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=100',
      action: AuditAction.settingChanged,
      targetId: 'system',
      targetName: 'System Settings',
      description: 'Changed message retention period from 30 to 60 days',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    AuditLog(
      id: 'log_007',
      adminId: 'u004',
      adminName: 'Emma Wilson',
      adminAvatar:
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100',
      action: AuditAction.userWarned,
      targetId: 'u_spammer',
      targetName: 'spam_king_2024',
      description: 'Issued formal warning for spam activity',
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
    ),
  ];

  AuditAction? _selectedAction;

  List<AuditLog> get _filtered => _selectedAction == null
      ? _logs
      : _logs.where((l) => l.action == _selectedAction).toList();

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
          'Audit Logs',
          style: TextStyle(
            color: SwiftSnapTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: SwiftSnapTheme.surfaceColor,
              borderRadius:
                  BorderRadius.circular(SwiftSnapTheme.radiusFull),
            ),
            child: Text(
              '${_logs.length} entries',
              style: const TextStyle(
                color: SwiftSnapTheme.textMuted,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilter(),
          Expanded(
            child: _filtered.isEmpty
                ? const Center(
                    child: Text(
                      'No logs found',
                      style: TextStyle(color: SwiftSnapTheme.textMuted),
                    ),
                  )
                : ListView.builder(
                    padding:
                        const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) => _buildLogCard(_filtered[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _filterChip(null, 'All'),
            ...AuditAction.values.map(
              (a) => _filterChip(a, _actionLabel(a)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(AuditAction? action, String label) {
    final selected = _selectedAction == action;
    return GestureDetector(
      onTap: () => setState(() => _selectedAction = action),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          gradient: selected ? SwiftSnapTheme.primaryGradient : null,
          color: selected ? null : SwiftSnapTheme.surfaceColor,
          borderRadius:
              BorderRadius.circular(SwiftSnapTheme.radiusFull),
        ),
        child: Text(
          label,
          style: TextStyle(
            color:
                selected ? Colors.white : SwiftSnapTheme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildLogCard(AuditLog log) {
    final actionColor = _actionColor(log.action);
    final actionIcon = _actionIcon(log.action);

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(14),
      decoration: SwiftSnapTheme.glassmorphicDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: actionColor.withOpacity(0.15),
              borderRadius:
                  BorderRadius.circular(SwiftSnapTheme.radiusMd),
            ),
            child: Icon(actionIcon, color: actionColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: actionColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                            SwiftSnapTheme.radiusFull),
                      ),
                      child: Text(
                        _actionLabel(log.action),
                        style: TextStyle(
                          color: actionColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _timeAgo(log.createdAt),
                      style: const TextStyle(
                        color: SwiftSnapTheme.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  log.description,
                  style: const TextStyle(
                    color: SwiftSnapTheme.textPrimary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 10,
                      backgroundImage: NetworkImage(log.adminAvatar),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      log.adminName,
                      style: const TextStyle(
                        color: SwiftSnapTheme.primaryPurple,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Text(
                      ' → ',
                      style: TextStyle(
                          color: SwiftSnapTheme.textMuted, fontSize: 11),
                    ),
                    Expanded(
                      child: Text(
                        log.targetName,
                        style: const TextStyle(
                          color: SwiftSnapTheme.textSecondary,
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _actionColor(AuditAction action) {
    switch (action) {
      case AuditAction.userBanned:
        return SwiftSnapTheme.busy;
      case AuditAction.userUnbanned:
        return SwiftSnapTheme.accentGreen;
      case AuditAction.userRoleChanged:
        return SwiftSnapTheme.primaryBlue;
      case AuditAction.contentRemoved:
        return SwiftSnapTheme.accentOrange;
      case AuditAction.ticketResolved:
        return SwiftSnapTheme.accentGreen;
      case AuditAction.settingChanged:
        return SwiftSnapTheme.primaryPurple;
      case AuditAction.campaignSent:
        return SwiftSnapTheme.primaryPink;
      case AuditAction.userWarned:
        return SwiftSnapTheme.away;
    }
  }

  IconData _actionIcon(AuditAction action) {
    switch (action) {
      case AuditAction.userBanned:
        return Icons.block_rounded;
      case AuditAction.userUnbanned:
        return Icons.check_circle_rounded;
      case AuditAction.userRoleChanged:
        return Icons.badge_rounded;
      case AuditAction.contentRemoved:
        return Icons.delete_rounded;
      case AuditAction.ticketResolved:
        return Icons.support_agent_rounded;
      case AuditAction.settingChanged:
        return Icons.settings_rounded;
      case AuditAction.campaignSent:
        return Icons.campaign_rounded;
      case AuditAction.userWarned:
        return Icons.warning_rounded;
    }
  }

  String _actionLabel(AuditAction action) {
    switch (action) {
      case AuditAction.userBanned:
        return 'User Banned';
      case AuditAction.userUnbanned:
        return 'User Unbanned';
      case AuditAction.userRoleChanged:
        return 'Role Changed';
      case AuditAction.contentRemoved:
        return 'Content Removed';
      case AuditAction.ticketResolved:
        return 'Ticket Resolved';
      case AuditAction.settingChanged:
        return 'Setting Changed';
      case AuditAction.campaignSent:
        return 'Campaign Sent';
      case AuditAction.userWarned:
        return 'User Warned';
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
