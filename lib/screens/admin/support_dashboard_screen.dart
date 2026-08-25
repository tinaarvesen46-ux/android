import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../theme/theme.dart';
import '../../providers/app_provider.dart';
import '../../models/admin_models.dart';
import 'support_tickets_screen.dart';
import 'ticket_detail_screen.dart';

class SupportDashboardScreen extends StatefulWidget {
  const SupportDashboardScreen({super.key});

  @override
  State<SupportDashboardScreen> createState() => _SupportDashboardScreenState();
}

class _SupportDashboardScreenState extends State<SupportDashboardScreen> {
  // Mock data - replace with real API calls
  final List<SupportTicket> _myTickets = [
    SupportTicket(
      id: 'TKT-001',
      userId: 'u003',
      userDisplayName: 'Mike Johnson',
      userAvatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100',
      subject: 'Cannot access account after password reset',
      description: 'I tried to reset my password but never received the email.',
      status: TicketStatus.open,
      priority: TicketPriority.urgent,
      category: TicketCategory.account,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    SupportTicket(
      id: 'TKT-002',
      userId: 'u005',
      userDisplayName: 'James Brown',
      userAvatar: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100',
      subject: 'Story not showing to friends',
      description: 'Posted a story 3 hours ago but friends cannot see it.',
      status: TicketStatus.inProgress,
      priority: TicketPriority.medium,
      category: TicketCategory.technical,
      assignedToName: 'You',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    SupportTicket(
      id: 'TKT-003',
      userId: 'u006',
      userDisplayName: 'Lily Zhang',
      userAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100',
      subject: 'Subscription not applying after payment',
      description: 'Paid for SwiftSnap+ but premium features not unlocked.',
      status: TicketStatus.open,
      priority: TicketPriority.high,
      category: TicketCategory.billing,
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
  ];

  int get _openCount => _myTickets.where((t) => t.status == TicketStatus.open).length;
  int get _inProgressCount => _myTickets.where((t) => t.status == TicketStatus.inProgress).length;
  int get _urgentCount => _myTickets.where((t) => t.priority == TicketPriority.urgent).length;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final user = provider.currentUser;
    final name = user?.displayName ?? 'Support Agent';

    return Scaffold(
      backgroundColor: SwiftSnapTheme.backgroundDark,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(name),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeBanner(name),
                  const SizedBox(height: 20),
                  _buildStatsRow(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Quick Actions'),
                  const SizedBox(height: 12),
                  _buildQuickActions(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('My Open Tickets (${_myTickets.length})'),
                  const SizedBox(height: 12),
                  ..._myTickets.map(_buildTicketCard),
                  const SizedBox(height: 24),
                  _buildTipsCard(),
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
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: SwiftSnapTheme.backgroundCard,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.headset_mic_rounded, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
            const Text(
              'Support Dashboard',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF06B6D4).withOpacity(0.15),
                SwiftSnapTheme.backgroundCard,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeBanner(String name) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF06B6D4).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, $name 👋',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _urgentCount > 0
                      ? '$_urgentCount urgent ticket${_urgentCount > 1 ? 's' : ''} need your attention!'
                      : 'All caught up! Great work.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.headset_mic_rounded, color: Colors.white, size: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            label: 'Open',
            value: _openCount.toString(),
            icon: Icons.inbox_rounded,
            color: const Color(0xFF06B6D4),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            label: 'In Progress',
            value: _inProgressCount.toString(),
            icon: Icons.pending_actions_rounded,
            color: SwiftSnapTheme.primaryPurple,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            label: 'Urgent',
            value: _urgentCount.toString(),
            icon: Icons.priority_high_rounded,
            color: const Color(0xFFEF4444),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            label: 'Rating',
            value: '4.8★',
            icon: Icons.star_rounded,
            color: const Color(0xFFFBBF24),
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SwiftSnapTheme.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: SwiftSnapTheme.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 17,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      _QuickAction(
        label: 'All Tickets',
        icon: Icons.confirmation_number_rounded,
        color: const Color(0xFF06B6D4),
        onTap: () => Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const SupportTicketsScreen(),
            transitionsBuilder: _slideTransition,
            transitionDuration: const Duration(milliseconds: 300),
          ),
        ),
      ),
      _QuickAction(
        label: 'Claim Ticket',
        icon: Icons.add_task_rounded,
        color: SwiftSnapTheme.primaryPurple,
        onTap: () => _showClaimDialog(),
      ),
      _QuickAction(
        label: 'Templates',
        icon: Icons.text_snippet_rounded,
        color: const Color(0xFF10B981),
        onTap: () => _showTemplatesSheet(),
      ),
      _QuickAction(
        label: 'My Stats',
        icon: Icons.bar_chart_rounded,
        color: const Color(0xFFF97316),
        onTap: () => _showStatsSheet(),
      ),
    ];

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 0.85,
      children: actions.map((a) => _buildActionTile(a)).toList(),
    );
  }

  Widget _buildActionTile(_QuickAction action) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        action.onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          color: SwiftSnapTheme.backgroundCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: action.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(action.icon, color: action.color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              action.label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketCard(SupportTicket ticket) {
    final priorityColor = _priorityColor(ticket.priority);
    final statusColor = _statusColor(ticket.status);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => TicketDetailScreen(ticket: ticket),
            transitionsBuilder: _slideTransition,
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: SwiftSnapTheme.backgroundCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: ticket.priority == TicketPriority.urgent
                ? const Color(0xFFEF4444).withOpacity(0.4)
                : Colors.white.withOpacity(0.06),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage(ticket.userAvatar),
                  backgroundColor: SwiftSnapTheme.surfaceColor,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ticket.userDisplayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        ticket.id,
                        style: TextStyle(
                          color: SwiftSnapTheme.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: priorityColor.withOpacity(0.4)),
                  ),
                  child: Text(
                    ticket.priority.name.toUpperCase(),
                    style: TextStyle(
                      color: priorityColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              ticket.subject,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              ticket.description,
              style: TextStyle(color: SwiftSnapTheme.textSecondary, fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusLabel(ticket.status),
                    style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
                const Spacer(),
                Icon(Icons.access_time_rounded, size: 12, color: SwiftSnapTheme.textMuted),
                const SizedBox(width: 4),
                Text(
                  _timeAgo(ticket.createdAt),
                  style: TextStyle(color: SwiftSnapTheme.textMuted, fontSize: 12),
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right_rounded, size: 16, color: SwiftSnapTheme.textMuted),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsCard() {
    final tips = [
      '✅ Always reply within 2 hours for urgent tickets',
      '📝 Use internal notes for team communication',
      '🔄 Mark tickets "Waiting for User" when response is needed',
      '⭐ Aim for 5-star satisfaction ratings',
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SwiftSnapTheme.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_rounded, color: Color(0xFFFBBF24), size: 18),
              const SizedBox(width: 8),
              const Text(
                'Support Tips',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...tips.map((tip) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(tip, style: TextStyle(color: SwiftSnapTheme.textSecondary, fontSize: 13)),
          )),
        ],
      ),
    );
  }

  void _showClaimDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: SwiftSnapTheme.backgroundCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Claim Next Ticket', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        content: Text(
          'You will be assigned the next unassigned urgent ticket. Continue?',
          style: TextStyle(color: SwiftSnapTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: SwiftSnapTheme.textMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('✅ Ticket TKT-007 assigned to you!'),
                  backgroundColor: const Color(0xFF06B6D4),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            child: const Text('Claim Ticket', style: TextStyle(color: Color(0xFF06B6D4), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showTemplatesSheet() {
    final templates = [
      'Thanks for reaching out! Let me look into this for you.',
      'I\'ve investigated your issue and found the following...',
      'Your account has been updated. Please try again in a few minutes.',
      'I\'ve escalated this to our technical team.',
      'Thank you for your patience. This issue has been resolved.',
      'Could you please provide more details so I can assist you better?',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: SwiftSnapTheme.backgroundCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Column(
        children: [
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 16),
            decoration: BoxDecoration(color: SwiftSnapTheme.textMuted, borderRadius: BorderRadius.circular(2)),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text('Canned Responses', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: templates.length,
              itemBuilder: (_, i) => ListTile(
                title: Text(templates[i], style: TextStyle(color: SwiftSnapTheme.textSecondary, fontSize: 14)),
                trailing: Icon(Icons.copy_rounded, color: SwiftSnapTheme.primaryPurple, size: 18),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('✅ Template copied to clipboard'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showStatsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: SwiftSnapTheme.backgroundCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(color: SwiftSnapTheme.textMuted, borderRadius: BorderRadius.circular(2)),
            ),
            const Text('My Performance (30 days)', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            _statRow('Tickets Resolved', '47'),
            _statRow('Avg First Response', '1h 23m'),
            _statRow('Avg Resolution Time', '4h 12m'),
            _statRow('Satisfaction Rating', '4.8 / 5.0 ⭐'),
            _statRow('SLA Compliance', '94%'),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: SwiftSnapTheme.textSecondary, fontSize: 14)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Color _priorityColor(TicketPriority p) {
    switch (p) {
      case TicketPriority.urgent: return const Color(0xFFEF4444);
      case TicketPriority.high: return const Color(0xFFF97316);
      case TicketPriority.medium: return const Color(0xFFFBBF24);
      case TicketPriority.low: return const Color(0xFF10B981);
    }
  }

  Color _statusColor(TicketStatus s) {
    switch (s) {
      case TicketStatus.open: return const Color(0xFF06B6D4);
      case TicketStatus.inProgress: return SwiftSnapTheme.primaryPurple;
      case TicketStatus.resolved: return const Color(0xFF10B981);
      case TicketStatus.closed: return SwiftSnapTheme.textMuted;
    }
  }

  String _statusLabel(TicketStatus s) {
    switch (s) {
      case TicketStatus.open: return 'Open';
      case TicketStatus.inProgress: return 'In Progress';
      case TicketStatus.resolved: return 'Resolved';
      case TicketStatus.closed: return 'Closed';
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Widget Function(BuildContext, Animation<double>, Animation<double>, Widget) get _slideTransition =>
      (context, animation, secondaryAnimation, child) => SlideTransition(
        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
        child: child,
      );
}

class _QuickAction {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
