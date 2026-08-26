import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../theme/theme.dart';
import '../../providers/app_provider.dart';
import '../../models/admin_models.dart';
import '../../api/services/admin_service.dart';
import 'moderation_dashboard_screen.dart';

class ModeratorDashboardScreen extends StatefulWidget {
  const ModeratorDashboardScreen({super.key});

  @override
  State<ModeratorDashboardScreen> createState() => _ModeratorDashboardScreenState();
}

class _ModeratorDashboardScreenState extends State<ModeratorDashboardScreen> {
  final AdminService _adminService = AdminService();
  List<ModerationReport> _pendingReports = [];
  final List<Map<String, dynamic>> _recentActions = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await _adminService.getReports();
    if (!mounted) return;
    setState(() {
      _pendingReports = (res.data ?? [])
          .where((r) => r.status == ReportStatus.pending)
          .toList();
    });
  }

  int get _pendingCount => _pendingReports.where((r) => r.status == ReportStatus.pending).length;
  int get _actionsToday => _recentActions.length;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final user = provider.currentUser;
    final name = user?.displayName ?? 'Moderator';

    return Scaffold(
      backgroundColor: SwiftSnapTheme.backgroundDark,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
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
                  if (_pendingCount > 0) ...[
                    _buildUrgentBanner(),
                    const SizedBox(height: 16),
                  ],
                  _buildSectionTitle('Pending Reports ($_pendingCount)'),
                  const SizedBox(height: 12),
                  ..._pendingReports.map(_buildReportCard),
                  const SizedBox(height: 24),
                  _buildSectionTitle('My Recent Actions'),
                  const SizedBox(height: 12),
                  _buildRecentActionsCard(),
                  const SizedBox(height: 24),
                  _buildGuidelinesCard(),
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
                  colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.shield_rounded, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
            const Text(
              'Moderation',
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
                SwiftSnapTheme.primaryPurple.withOpacity(0.15),
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
          colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: SwiftSnapTheme.primaryPurple.withOpacity(0.3),
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
                  'Hey, $name 🛡️',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$_pendingCount report${_pendingCount != 1 ? 's' : ''} pending review · $_actionsToday actions today',
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
            child: const Icon(Icons.shield_rounded, color: Colors.white, size: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _statCard('Pending', _pendingCount.toString(), Icons.pending_actions_rounded, const Color(0xFFEF4444))),
        const SizedBox(width: 10),
        Expanded(child: _statCard('Actions\nToday', _actionsToday.toString(), Icons.gavel_rounded, SwiftSnapTheme.primaryPurple)),
        const SizedBox(width: 10),
        Expanded(child: _statCard('Reviewed\n(7d)', '23', Icons.fact_check_rounded, const Color(0xFF10B981))),
        const SizedBox(width: 10),
        Expanded(child: _statCard('Accuracy', '—', Icons.verified_rounded, const Color(0xFFFBBF24))),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
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
          Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: SwiftSnapTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      _QuickAction('All Reports', Icons.flag_rounded, const Color(0xFFEF4444), () {
        Navigator.push(context, PageRouteBuilder(
          pageBuilder: (_, __, ___) => const ModerationDashboardScreen(),
          transitionsBuilder: _slideTransition,
          transitionDuration: const Duration(milliseconds: 300),
        ));
      }),
      _QuickAction('User Lookup', Icons.person_search_rounded, SwiftSnapTheme.primaryPurple, _showUserLookup),
      _QuickAction('Issue\nWarning', Icons.warning_rounded, const Color(0xFFF97316), _showWarningDialog),
      _QuickAction('My Log', Icons.history_rounded, const Color(0xFF10B981), _showMyLog),
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
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUrgentBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$_pendingCount reports are awaiting your review. Please prioritize harassment and violence reports.',
              style: const TextStyle(color: Color(0xFFEF4444), fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(ModerationReport report) {
    final reasonColor = _reasonColor(report.reason);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showReportActionSheet(report);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
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
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(report.reporterAvatar),
                  backgroundColor: SwiftSnapTheme.surfaceColor,
                ),
                const SizedBox(width: 8),
                Text(report.reporterName, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                const Text(' reported ', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(report.reportedUserAvatar),
                  backgroundColor: SwiftSnapTheme.surfaceColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    report.reportedUserName,
                    style: const TextStyle(color: Color(0xFFEF4444), fontSize: 13, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: SwiftSnapTheme.surfaceColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                report.contentPreview,
                style: TextStyle(color: SwiftSnapTheme.textSecondary, fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: reasonColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _reasonLabel(report.reason),
                    style: TextStyle(color: reasonColor, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _contentTypeLabel(report.contentType),
                    style: TextStyle(color: SwiftSnapTheme.textMuted, fontSize: 11),
                  ),
                ),
                const Spacer(),
                Text(_timeAgo(report.createdAt), style: TextStyle(color: SwiftSnapTheme.textMuted, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActionsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SwiftSnapTheme.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: _recentActions.map((a) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                width: 8, height: 8,
                decoration: BoxDecoration(color: a['color'] as Color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${a['action']} — ${a['user']}',
                  style: TextStyle(color: SwiftSnapTheme.textSecondary, fontSize: 13),
                ),
              ),
              Text(a['time'] as String, style: TextStyle(color: SwiftSnapTheme.textMuted, fontSize: 12)),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildGuidelinesCard() {
    final guidelines = [
      '🚨 Harassment & Violence → immediate action required',
      '📢 Spam → remove content, 1st offense = warning',
      '🔞 Nudity → remove content, review for ban',
      '📰 Misinformation → escalate to senior mod',
      '⚖️ Document all actions with clear notes',
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
              const Icon(Icons.menu_book_rounded, color: Color(0xFF8B5CF6), size: 18),
              const SizedBox(width: 8),
              const Text('Moderation Guidelines', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          ...guidelines.map((g) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(g, style: TextStyle(color: SwiftSnapTheme.textSecondary, fontSize: 13)),
          )),
        ],
      ),
    );
  }

  void _showReportActionSheet(ModerationReport report) {
    showModalBottomSheet(
      context: context,
      backgroundColor: SwiftSnapTheme.backgroundCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: SwiftSnapTheme.textMuted, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Text('Action on ${report.id}', style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
            Text('Reported: @${report.reportedUserName}', style: TextStyle(color: SwiftSnapTheme.textSecondary, fontSize: 14)),
            const SizedBox(height: 20),
            _actionBtn('✅ Dismiss — No Violation', const Color(0xFF10B981), report),
            _actionBtn('⚠️ Issue Warning', const Color(0xFFFBBF24), report),
            _actionBtn('🗑️ Remove Content', const Color(0xFFF97316), report),
            _actionBtn('⏸️ Suspend Account', const Color(0xFFEF4444), report),
            _actionBtn('🚫 Permanent Ban', const Color(0xFF64748B), report),
          ],
        ),
      ),
    );
  }

  Widget _actionBtn(String label, Color color, ModerationReport report) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () {
          Navigator.pop(context);
          setState(() {
            final idx = _pendingReports.indexOf(report);
            if (idx >= 0) _pendingReports.removeAt(idx);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Action applied to ${report.id}'),
              backgroundColor: color,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Text(label, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  void _showUserLookup() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: SwiftSnapTheme.backgroundCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('User Lookup', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        content: TextField(
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search by username or email...',
            hintStyle: TextStyle(color: SwiftSnapTheme.textMuted),
            filled: true,
            fillColor: SwiftSnapTheme.surfaceColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            prefixIcon: Icon(Icons.search_rounded, color: SwiftSnapTheme.textMuted),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: SwiftSnapTheme.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Search', style: TextStyle(color: Color(0xFF8B5CF6), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showWarningDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: SwiftSnapTheme.backgroundCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Issue Warning', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Username...',
                hintStyle: TextStyle(color: SwiftSnapTheme.textMuted),
                filled: true,
                fillColor: SwiftSnapTheme.surfaceColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Reason for warning...',
                hintStyle: TextStyle(color: SwiftSnapTheme.textMuted),
                filled: true,
                fillColor: SwiftSnapTheme.surfaceColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: SwiftSnapTheme.textMuted))),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('⚠️ Warning issued successfully'),
                  backgroundColor: const Color(0xFFF97316),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            child: const Text('Issue Warning', style: TextStyle(color: Color(0xFFF97316), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showMyLog() {
    Navigator.push(context, PageRouteBuilder(
      pageBuilder: (_, __, ___) => _MyLogScreen(actions: _recentActions),
      transitionsBuilder: _slideTransition,
      transitionDuration: const Duration(milliseconds: 300),
    ));
  }

  Color _reasonColor(ReportReason r) {
    switch (r) {
      case ReportReason.spam: return const Color(0xFFF97316);
      case ReportReason.harassment: return const Color(0xFFEF4444);
      case ReportReason.violence: return const Color(0xFFEF4444);
      case ReportReason.misinformation: return const Color(0xFFFBBF24);
      case ReportReason.inappropriateContent: return const Color(0xFF8B5CF6);
      case ReportReason.other: return const Color(0xFF64748B);
    }
  }

  String _reasonLabel(ReportReason r) {
    switch (r) {
      case ReportReason.spam: return 'Spam';
      case ReportReason.harassment: return 'Harassment';
      case ReportReason.violence: return 'Violence';
      case ReportReason.misinformation: return 'Misinformation';
      case ReportReason.inappropriateContent: return 'Inappropriate';
      case ReportReason.other: return 'Other';
    }
  }

  String _contentTypeLabel(ContentType t) {
    switch (t) {
      case ContentType.message: return 'Message';
      case ContentType.story: return 'Story';
      case ContentType.profile: return 'Profile';
      case ContentType.comment: return 'Comment';
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
  const _QuickAction(this.label, this.icon, this.color, this.onTap);
}

// Simple log screen
class _MyLogScreen extends StatelessWidget {
  final List<Map<String, dynamic>> actions;
  const _MyLogScreen({required this.actions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwiftSnapTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: SwiftSnapTheme.backgroundCard,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('My Action Log', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: actions.length,
        itemBuilder: (_, i) {
          final a = actions[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: SwiftSnapTheme.backgroundCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Row(
              children: [
                Container(
                  width: 10, height: 10,
                  decoration: BoxDecoration(color: a['color'] as Color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${a['action']} — ${a['user']}',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
                Text(a['time'] as String, style: TextStyle(color: SwiftSnapTheme.textMuted, fontSize: 12)),
              ],
            ),
          );
        },
      ),
    );
  }
}
