import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/theme.dart';
import '../../models/admin_models.dart';
import 'ticket_detail_screen.dart';

class SupportTicketsScreen extends StatefulWidget {
  const SupportTicketsScreen({super.key});

  @override
  State<SupportTicketsScreen> createState() => _SupportTicketsScreenState();
}

class _SupportTicketsScreenState extends State<SupportTicketsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  TicketStatus? _selectedStatus;

  final List<SupportTicket> _tickets = [
    SupportTicket(
      id: 'TKT-001',
      userId: 'u003',
      userDisplayName: 'Mike Johnson',
      userAvatar:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100',
      subject: 'Cannot access my account after password reset',
      description:
          'I tried to reset my password but never received the email. I have checked spam folder multiple times.',
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
      userAvatar:
          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100',
      subject: 'Story not showing to my friends',
      description:
          'I posted a story 3 hours ago but my friends say they cannot see it in their feed.',
      status: TicketStatus.inProgress,
      priority: TicketPriority.medium,
      category: TicketCategory.technical,
      assignedToName: 'Alex Chen',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
      replies: [
        TicketReply(
          id: 'r001',
          authorId: 'u001',
          authorName: 'Alex Chen',
          authorAvatar:
              'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=100',
          isStaff: true,
          content:
              'Hi James, we are investigating this issue. Our engineering team has been notified.',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      ],
    ),
    SupportTicket(
      id: 'TKT-003',
      userId: 'u006',
      userDisplayName: 'Lily Zhang',
      userAvatar:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100',
      subject: 'Subscription not applying after payment',
      description:
          'I paid for SwiftSnap+ but the premium features are not unlocked.',
      status: TicketStatus.open,
      priority: TicketPriority.high,
      category: TicketCategory.billing,
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    SupportTicket(
      id: 'TKT-004',
      userId: 'u002',
      userDisplayName: 'Sarah Miller',
      userAvatar:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100',
      subject: 'User harassing me in messages',
      description:
          'A user keeps sending me inappropriate messages even after I blocked them.',
      status: TicketStatus.resolved,
      priority: TicketPriority.high,
      category: TicketCategory.abuse,
      assignedToName: 'Emma Wilson',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedStatus = switch (_tabController.index) {
            0 => null,
            1 => TicketStatus.open,
            2 => TicketStatus.inProgress,
            3 => TicketStatus.resolved,
            _ => null,
          };
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<SupportTicket> get _filtered => _selectedStatus == null
      ? _tickets
      : _tickets.where((t) => t.status == _selectedStatus).toList();

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
          'Support Tickets',
          style: TextStyle(
            color: SwiftSnapTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: SwiftSnapTheme.primaryPurple,
          unselectedLabelColor: SwiftSnapTheme.textMuted,
          indicatorColor: SwiftSnapTheme.primaryPurple,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: [
            Tab(text: 'All (${_tickets.length})'),
            Tab(
                text:
                    'Open (${_tickets.where((t) => t.status == TicketStatus.open).length})'),
            Tab(
                text:
                    'Active (${_tickets.where((t) => t.status == TicketStatus.inProgress).length})'),
            const Tab(text: 'Resolved'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: List.generate(4, (_) => _buildTicketList()),
      ),
    );
  }

  Widget _buildTicketList() {
    final items = _filtered;
    if (items.isEmpty) {
      return const Center(
        child: Text(
          'No tickets in this category',
          style: TextStyle(color: SwiftSnapTheme.textMuted),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: items.length,
      itemBuilder: (ctx, i) => _buildTicketCard(items[i]),
    );
  }

  Widget _buildTicketCard(SupportTicket ticket) {
    final priorityColor = _priorityColor(ticket.priority);
    final statusColor = _statusColor(ticket.status);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, animation, __) =>
                TicketDetailScreen(ticket: ticket),
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
        decoration: SwiftSnapTheme.glassmorphicDecoration(
          borderColor: ticket.status == TicketStatus.open
              ? priorityColor.withOpacity(0.3)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage(ticket.userAvatar),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ticket.userDisplayName,
                        style: const TextStyle(
                          color: SwiftSnapTheme.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        ticket.id,
                        style: const TextStyle(
                          color: SwiftSnapTheme.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                _statusBadge(ticket.status, statusColor),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              ticket.subject,
              style: const TextStyle(
                color: SwiftSnapTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              ticket.description,
              style: const TextStyle(
                color: SwiftSnapTheme.textSecondary,
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _tagChip(
                  _priorityLabel(ticket.priority),
                  priorityColor,
                ),
                const SizedBox(width: 6),
                _tagChip(
                  _categoryLabel(ticket.category),
                  SwiftSnapTheme.primaryBlue,
                ),
                const Spacer(),
                Row(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 12,
                      color: SwiftSnapTheme.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${ticket.replies.length}',
                      style: const TextStyle(
                        color: SwiftSnapTheme.textMuted,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _timeAgo(ticket.createdAt),
                      style: const TextStyle(
                        color: SwiftSnapTheme.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (ticket.assignedToName != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.person_pin_rounded,
                    size: 12,
                    color: SwiftSnapTheme.primaryPurple,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Assigned to ${ticket.assignedToName}',
                    style: const TextStyle(
                      color: SwiftSnapTheme.primaryPurple,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(TicketStatus status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(SwiftSnapTheme.radiusFull),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        _statusLabel(status),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _tagChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(SwiftSnapTheme.radiusFull),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _priorityColor(TicketPriority p) {
    switch (p) {
      case TicketPriority.urgent:
        return SwiftSnapTheme.busy;
      case TicketPriority.high:
        return SwiftSnapTheme.accentOrange;
      case TicketPriority.medium:
        return SwiftSnapTheme.away;
      case TicketPriority.low:
        return SwiftSnapTheme.accentGreen;
    }
  }

  Color _statusColor(TicketStatus s) {
    switch (s) {
      case TicketStatus.open:
        return SwiftSnapTheme.busy;
      case TicketStatus.inProgress:
        return SwiftSnapTheme.primaryBlue;
      case TicketStatus.resolved:
        return SwiftSnapTheme.accentGreen;
      case TicketStatus.closed:
        return SwiftSnapTheme.textMuted;
    }
  }

  String _statusLabel(TicketStatus s) {
    switch (s) {
      case TicketStatus.open:
        return 'OPEN';
      case TicketStatus.inProgress:
        return 'IN PROGRESS';
      case TicketStatus.resolved:
        return 'RESOLVED';
      case TicketStatus.closed:
        return 'CLOSED';
    }
  }

  String _priorityLabel(TicketPriority p) {
    switch (p) {
      case TicketPriority.urgent:
        return '🔴 URGENT';
      case TicketPriority.high:
        return '🟠 HIGH';
      case TicketPriority.medium:
        return '🟡 MEDIUM';
      case TicketPriority.low:
        return '🟢 LOW';
    }
  }

  String _categoryLabel(TicketCategory c) {
    switch (c) {
      case TicketCategory.account:
        return 'Account';
      case TicketCategory.billing:
        return 'Billing';
      case TicketCategory.abuse:
        return 'Abuse';
      case TicketCategory.technical:
        return 'Technical';
      case TicketCategory.other:
        return 'Other';
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
