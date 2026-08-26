import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../models/admin_models.dart';
import '../../api/services/admin_service.dart';

class AuditLogsScreen extends StatefulWidget {
  const AuditLogsScreen({super.key});

  @override
  State<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends State<AuditLogsScreen> {
  final AdminService _adminService = AdminService();
  List<AuditLog> _logs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await _adminService.getAuditLogs();
    if (!mounted) return;
    setState(() {
      _logs = res.data ?? [];
      _loading = false;
    });
  }

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
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: SwiftSnapTheme.primaryPurple),
                  )
                : _filtered.isEmpty
                    ? const Center(
                        child: Text(
                          'No audit logs yet',
                          style: TextStyle(color: SwiftSnapTheme.textMuted),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
                      backgroundColor: SwiftSnapTheme.surfaceLight,
                      backgroundImage: log.adminAvatar.isNotEmpty ? NetworkImage(log.adminAvatar) : null,
                      child: log.adminAvatar.isEmpty
                          ? const Icon(Icons.shield_rounded, size: 11, color: SwiftSnapTheme.primaryPurple)
                          : null,
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
