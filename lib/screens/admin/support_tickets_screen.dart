import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/theme.dart';
import '../../models/admin_models.dart';
import '../../api/services/admin_service.dart';
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
  final AdminService _adminService = AdminService();
  List<SupportTicket> _tickets = [];
  bool _loading = true;

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
    _load();
  }

  Future<void> _load() async {
    final res = await _adminService.getTickets();
    if (!mounted) return;
    setState(() {
      _tickets = res.data ?? [];
      _loading = false;
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
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: SwiftSnapTheme.primaryPurple));
    }
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
                  backgroundColor: SwiftSnapTheme.surfaceLight,
                  backgroundImage: ticket.userAvatar.isNotEmpty ? NetworkImage(ticket.userAvatar) : null,
                  child: ticket.userAvatar.isEmpty
                      ? Text(ticket.userDisplayName.isNotEmpty ? ticket.userDisplayName[0].toUpperCase() : '?',
                          style: const TextStyle(color: SwiftSnapTheme.textPrimary))
                      : null,
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
