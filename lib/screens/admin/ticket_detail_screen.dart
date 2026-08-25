import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/theme.dart';
import '../../models/admin_models.dart';
import '../../api/services/admin_service.dart';

class TicketDetailScreen extends StatefulWidget {
  final SupportTicket ticket;
  const TicketDetailScreen({super.key, required this.ticket});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  final AdminService _adminService = AdminService();
  final TextEditingController _replyController = TextEditingController();
  late SupportTicket _ticket;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _ticket = widget.ticket;
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _sendReply() async {
    if (_replyController.text.trim().isEmpty) return;
    setState(() => _sending = true);

    final content = _replyController.text.trim();
    await _adminService.replyToTicket(_ticket.id, content);

    final newReply = TicketReply(
      id: 'r${DateTime.now().millisecondsSinceEpoch}',
      authorId: 'admin',
      authorName: 'Support Team',
      authorAvatar:
          'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=100',
      isStaff: true,
      content: content,
      createdAt: DateTime.now(),
    );

    setState(() {
      _ticket = _ticket.copyWith(
        replies: [..._ticket.replies, newReply],
        status: TicketStatus.inProgress,
        updatedAt: DateTime.now(),
      );
      _sending = false;
    });

    _replyController.clear();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reply sent'),
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _ticket.id,
              style: const TextStyle(
                color: SwiftSnapTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              _statusLabel(_ticket.status),
              style: TextStyle(
                color: _statusColor(_ticket.status),
                fontSize: 11,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<TicketStatus>(
            icon: const Icon(Icons.tune_rounded),
            color: SwiftSnapTheme.backgroundCard,
            onSelected: (status) {
              _adminService.updateTicketStatus(_ticket.id, status);
              setState(() => _ticket = _ticket.copyWith(status: status));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Status updated to ${_statusLabel(status)}'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            itemBuilder: (_) => TicketStatus.values
                .map(
                  (s) => PopupMenuItem(
                    value: s,
                    child: Text(
                      _statusLabel(s),
                      style: TextStyle(color: _statusColor(s)),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildTicketHeader(),
                const SizedBox(height: 16),
                _buildOriginalMessage(),
                const SizedBox(height: 16),
                if (_ticket.replies.isNotEmpty) ...[
                  const Text(
                    'Conversation',
                    style: TextStyle(
                      color: SwiftSnapTheme.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._ticket.replies.map(_buildReplyBubble),
                ],
              ],
            ),
          ),
          _buildReplyComposer(),
        ],
      ),
    );
  }

  Widget _buildTicketHeader() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: SwiftSnapTheme.glassmorphicDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(_ticket.userAvatar),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _ticket.userDisplayName,
                      style: const TextStyle(
                        color: SwiftSnapTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _timeAgo(_ticket.createdAt),
                      style: const TextStyle(
                        color: SwiftSnapTheme.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _priorityColor(_ticket.priority).withOpacity(0.15),
                  borderRadius:
                      BorderRadius.circular(SwiftSnapTheme.radiusFull),
                ),
                child: Text(
                  _priorityLabel(_ticket.priority),
                  style: TextStyle(
                    color: _priorityColor(_ticket.priority),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _ticket.subject,
            style: const TextStyle(
              color: SwiftSnapTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _chip(_categoryLabel(_ticket.category),
                  SwiftSnapTheme.primaryBlue),
              if (_ticket.assignedToName != null) ...[
                const SizedBox(width: 8),
                _chip('→ ${_ticket.assignedToName!}',
                    SwiftSnapTheme.primaryPurple),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOriginalMessage() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SwiftSnapTheme.surfaceColor,
        borderRadius: BorderRadius.circular(SwiftSnapTheme.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Original Request',
            style: TextStyle(
              color: SwiftSnapTheme.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _ticket.description,
            style: const TextStyle(
              color: SwiftSnapTheme.textPrimary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyBubble(TicketReply reply) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!reply.isStaff)
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(reply.authorAvatar),
            ),
          if (reply.isStaff) const SizedBox(width: 32 + 8),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: reply.isStaff
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (reply.isStaff)
                      Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          gradient: SwiftSnapTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(
                              SwiftSnapTheme.radiusFull),
                        ),
                        child: const Text(
                          'STAFF',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    Text(
                      reply.authorName,
                      style: const TextStyle(
                        color: SwiftSnapTheme.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: reply.isStaff
                        ? SwiftSnapTheme.primaryGradient
                        : null,
                    color: reply.isStaff
                        ? null
                        : SwiftSnapTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(
                        SwiftSnapTheme.radiusMd),
                  ),
                  child: Text(
                    reply.content,
                    style: TextStyle(
                      color: reply.isStaff
                          ? Colors.white
                          : SwiftSnapTheme.textPrimary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _timeAgo(reply.createdAt),
                  style: const TextStyle(
                    color: SwiftSnapTheme.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (reply.isStaff)
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(reply.authorAvatar),
            ),
        ],
      ),
    );
  }

  Widget _buildReplyComposer() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: SwiftSnapTheme.backgroundCard,
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: SwiftSnapTheme.glassmorphicDecoration(
                borderRadius: SwiftSnapTheme.radiusMd,
              ),
              child: TextField(
                controller: _replyController,
                maxLines: null,
                style: const TextStyle(
                  color: SwiftSnapTheme.textPrimary,
                  fontSize: 14,
                ),
                decoration: const InputDecoration(
                  hintText: 'Write a reply...',
                  hintStyle: TextStyle(
                    color: SwiftSnapTheme.textMuted,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _sending ? null : _sendReply,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: _sending ? null : SwiftSnapTheme.primaryGradient,
                color: _sending ? SwiftSnapTheme.surfaceLight : null,
                borderRadius:
                    BorderRadius.circular(SwiftSnapTheme.radiusMd),
              ),
              child: _sending
                  ? const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: SwiftSnapTheme.primaryPurple,
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, Color color) {
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

  String _priorityLabel(TicketPriority p) {
    switch (p) {
      case TicketPriority.urgent:
        return 'URGENT';
      case TicketPriority.high:
        return 'HIGH';
      case TicketPriority.medium:
        return 'MEDIUM';
      case TicketPriority.low:
        return 'LOW';
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
        return 'Open';
      case TicketStatus.inProgress:
        return 'In Progress';
      case TicketStatus.resolved:
        return 'Resolved';
      case TicketStatus.closed:
        return 'Closed';
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
