import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/theme.dart';
import '../../models/admin_models.dart';

class ModerationDashboardScreen extends StatefulWidget {
  const ModerationDashboardScreen({super.key});

  @override
  State<ModerationDashboardScreen> createState() =>
      _ModerationDashboardScreenState();
}

class _ModerationDashboardScreenState
    extends State<ModerationDashboardScreen> {
  ReportStatus? _selectedStatus;

  final List<ModerationReport> _reports = [
    ModerationReport(
      id: 'RPT-001',
      reporterId: 'u002',
      reporterName: 'Sarah Miller',
      reporterAvatar:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100',
      reportedUserId: 'u007',
      reportedUserName: 'bad_actor_99',
      reportedUserAvatar:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
      contentType: ContentType.message,
      contentPreview:
          '"You are ugly and should delete this app. Nobody likes you..."',
      reason: ReportReason.harassment,
      status: ReportStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
    ModerationReport(
      id: 'RPT-002',
      reporterId: 'u003',
      reporterName: 'Mike Johnson',
      reporterAvatar:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100',
      reportedUserId: 'u008',
      reportedUserName: 'spam_king_2024',
      reportedUserAvatar:
          'https://images.unsplash.com/photo-1527980965255-d3b416303d12?w=100',
      contentType: ContentType.story,
      contentPreview: 'Story with repeated promotional links and fake giveaway claims.',
      reason: ReportReason.spam,
      status: ReportStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    ModerationReport(
      id: 'RPT-003',
      reporterId: 'u006',
      reporterName: 'Lily Zhang',
      reporterAvatar:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100',
      reportedUserId: 'u009',
      reportedUserName: 'violent_user',
      reportedUserAvatar:
          'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=100',
      contentType: ContentType.profile,
      contentPreview: 'Profile bio contains threatening language and hate speech.',
      reason: ReportReason.violence,
      status: ReportStatus.reviewed,
      reviewedByName: 'Emma Wilson',
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    ModerationReport(
      id: 'RPT-004',
      reporterId: 'u004',
      reporterName: 'Emma Wilson',
      reporterAvatar:
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100',
      reportedUserId: 'u010',
      reportedUserName: 'fake_news_spreader',
      reportedUserAvatar:
          'https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=100',
      contentType: ContentType.story,
      contentPreview: 'Story spreading false health information about vaccines.',
      reason: ReportReason.misinformation,
      status: ReportStatus.actioned,
      reviewedByName: 'Alex Chen',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  List<ModerationReport> get _filtered => _selectedStatus == null
      ? _reports
      : _reports.where((r) => r.status == _selectedStatus).toList();

  @override
  Widget build(BuildContext context) {
    final pending =
        _reports.where((r) => r.status == ReportStatus.pending).length;
    final reviewed =
        _reports.where((r) => r.status == ReportStatus.reviewed).length;

    return Scaffold(
      backgroundColor: SwiftSnapTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: SwiftSnapTheme.backgroundDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Moderation',
          style: TextStyle(
            color: SwiftSnapTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildSummaryRow(pending, reviewed),
          _buildStatusFilter(),
          Expanded(
            child: _filtered.isEmpty
                ? const Center(
                    child: Text(
                      'No reports in this category',
                      style: TextStyle(color: SwiftSnapTheme.textMuted),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: _filtered.length,
                    itemBuilder: (ctx, i) =>
                        _buildReportCard(_filtered[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(int pending, int reviewed) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: _summaryBox(
              '$pending',
              'Pending',
              SwiftSnapTheme.busy,
              Icons.pending_rounded,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _summaryBox(
              '$reviewed',
              'Under Review',
              SwiftSnapTheme.accentOrange,
              Icons.rate_review_rounded,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _summaryBox(
              '${_reports.length}',
              'Total',
              SwiftSnapTheme.primaryPurple,
              Icons.flag_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryBox(
      String value, String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(SwiftSnapTheme.radiusMd),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
        ],
      ),
    );
  }

  Widget _buildStatusFilter() {
    final options = [
      (null, 'All'),
      (ReportStatus.pending, 'Pending'),
      (ReportStatus.reviewed, 'Reviewed'),
      (ReportStatus.actioned, 'Actioned'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: options.map((o) {
            final selected = _selectedStatus == o.$1;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedStatus = o.$1);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  gradient:
                      selected ? SwiftSnapTheme.primaryGradient : null,
                  color: selected ? null : SwiftSnapTheme.surfaceColor,
                  borderRadius:
                      BorderRadius.circular(SwiftSnapTheme.radiusFull),
                ),
                child: Text(
                  o.$2,
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
      ),
    );
  }

  Widget _buildReportCard(ModerationReport report) {
    final reasonColor = _reasonColor(report.reason);

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(14),
      decoration: SwiftSnapTheme.glassmorphicDecoration(
        borderColor: report.status == ReportStatus.pending
            ? SwiftSnapTheme.busy.withOpacity(0.4)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.flag_rounded,
                color: SwiftSnapTheme.busy,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                report.id,
                style: const TextStyle(
                  color: SwiftSnapTheme.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              _statusBadge(report.status),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _avatarWithLabel(
                report.reporterAvatar,
                report.reporterName,
                'Reporter',
                SwiftSnapTheme.accentGreen,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: SwiftSnapTheme.textMuted,
                  size: 16,
                ),
              ),
              _avatarWithLabel(
                report.reportedUserAvatar,
                report.reportedUserName,
                'Reported',
                SwiftSnapTheme.busy,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _chip(_reasonLabel(report.reason), reasonColor),
              const SizedBox(width: 6),
              _chip(_contentTypeLabel(report.contentType),
                  SwiftSnapTheme.primaryBlue),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: SwiftSnapTheme.surfaceLight,
              borderRadius:
                  BorderRadius.circular(SwiftSnapTheme.radiusMd),
            ),
            child: Text(
              report.contentPreview,
              style: const TextStyle(
                color: SwiftSnapTheme.textSecondary,
                fontSize: 12,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (report.status == ReportStatus.pending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _actionBtn(
                    'Dismiss',
                    SwiftSnapTheme.textMuted,
                    () => _updateReport(report, ReportStatus.dismissed),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _actionBtn(
                    'Review',
                    SwiftSnapTheme.accentOrange,
                    () => _updateReport(report, ReportStatus.reviewed),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _actionBtn(
                    'Action',
                    SwiftSnapTheme.busy,
                    () => _showActionDialog(report),
                  ),
                ),
              ],
            ),
          ],
          if (report.reviewedByName != null) ...[
            const SizedBox(height: 8),
            Text(
              'Reviewed by ${report.reviewedByName}',
              style: const TextStyle(
                color: SwiftSnapTheme.textMuted,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _avatarWithLabel(
      String avatarUrl, String name, String role, Color color) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundImage: NetworkImage(avatarUrl),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                color: SwiftSnapTheme.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              role,
              style: TextStyle(
                color: color,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _actionBtn(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(SwiftSnapTheme.radiusMd),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  void _updateReport(ModerationReport report, ReportStatus status) {
    final idx = _reports.indexWhere((r) => r.id == report.id);
    if (idx != -1) {
      setState(() {
        _reports[idx] = ModerationReport(
          id: report.id,
          reporterId: report.reporterId,
          reporterName: report.reporterName,
          reporterAvatar: report.reporterAvatar,
          reportedUserId: report.reportedUserId,
          reportedUserName: report.reportedUserName,
          reportedUserAvatar: report.reportedUserAvatar,
          contentType: report.contentType,
          contentPreview: report.contentPreview,
          reason: report.reason,
          status: status,
          reviewedByName: 'You',
          createdAt: report.createdAt,
        );
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Report ${status.name}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showActionDialog(ModerationReport report) {
    showModalBottomSheet(
      context: context,
      backgroundColor: SwiftSnapTheme.backgroundCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(SwiftSnapTheme.radius2Xl)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Take Action on ${report.reportedUserName}',
              style: const TextStyle(
                color: SwiftSnapTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            _sheetAction(
              'Warn User',
              Icons.warning_amber_rounded,
              SwiftSnapTheme.accentOrange,
              () {
                Navigator.pop(context);
                _updateReport(report, ReportStatus.actioned);
              },
            ),
            _sheetAction(
              'Remove Content',
              Icons.delete_rounded,
              SwiftSnapTheme.busy,
              () {
                Navigator.pop(context);
                _updateReport(report, ReportStatus.actioned);
              },
            ),
            _sheetAction(
              'Ban User',
              Icons.block_rounded,
              SwiftSnapTheme.busy,
              () {
                Navigator.pop(context);
                _updateReport(report, ReportStatus.actioned);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _sheetAction(
      String label, IconData icon, Color color, VoidCallback onTap) {
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
      title: Text(label,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          )),
      onTap: onTap,
    );
  }

  Widget _statusBadge(ReportStatus status) {
    final color = _statusColor(status);
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(SwiftSnapTheme.radiusFull),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _chip(String label, Color color) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(SwiftSnapTheme.radiusFull),
        ),
        child: Text(
          label,
          style:
              TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600),
        ),
      );

  Color _reasonColor(ReportReason r) {
    switch (r) {
      case ReportReason.harassment:
        return SwiftSnapTheme.busy;
      case ReportReason.spam:
        return SwiftSnapTheme.accentOrange;
      case ReportReason.inappropriateContent:
        return SwiftSnapTheme.primaryPink;
      case ReportReason.violence:
        return SwiftSnapTheme.busy;
      case ReportReason.misinformation:
        return SwiftSnapTheme.away;
      case ReportReason.other:
        return SwiftSnapTheme.textMuted;
    }
  }

  Color _statusColor(ReportStatus s) {
    switch (s) {
      case ReportStatus.pending:
        return SwiftSnapTheme.busy;
      case ReportStatus.reviewed:
        return SwiftSnapTheme.accentOrange;
      case ReportStatus.actioned:
        return SwiftSnapTheme.accentGreen;
      case ReportStatus.dismissed:
        return SwiftSnapTheme.textMuted;
    }
  }

  String _reasonLabel(ReportReason r) {
    switch (r) {
      case ReportReason.harassment:
        return 'Harassment';
      case ReportReason.spam:
        return 'Spam';
      case ReportReason.inappropriateContent:
        return 'Inappropriate';
      case ReportReason.violence:
        return 'Violence';
      case ReportReason.misinformation:
        return 'Misinformation';
      case ReportReason.other:
        return 'Other';
    }
  }

  String _contentTypeLabel(ContentType t) {
    switch (t) {
      case ContentType.message:
        return 'Message';
      case ContentType.story:
        return 'Story';
      case ContentType.profile:
        return 'Profile';
      case ContentType.comment:
        return 'Comment';
    }
  }
}
