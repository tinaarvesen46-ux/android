import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/theme.dart';
import '../providers/app_provider.dart';

class CreatorDashboardScreen extends StatefulWidget {
  const CreatorDashboardScreen({super.key});

  @override
  State<CreatorDashboardScreen> createState() => _CreatorDashboardScreenState();
}

class _CreatorDashboardScreenState extends State<CreatorDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String _selectedPeriod = '30d';

  final List<Map<String, dynamic>> _revenueItems = [
    {'type': 'Tips', 'amount': 142.50, 'date': '2 hours ago', 'from': '@vibe_fan_01', 'color': const Color(0xFF10B981)},
    {'type': 'Subscription', 'amount': 9.99, 'date': '1 day ago', 'from': 'SwiftSnap Platform', 'color': const Color(0xFF8B5CF6)},
    {'type': 'Tips', 'amount': 25.00, 'date': '2 days ago', 'from': '@content_lover', 'color': const Color(0xFF10B981)},
    {'type': 'Ad Revenue', 'amount': 67.33, 'date': '3 days ago', 'from': 'SwiftSnap Ads', 'color': const Color(0xFF06B6D4)},
    {'type': 'Tips', 'amount': 10.00, 'date': '5 days ago', 'from': '@supporter_99', 'color': const Color(0xFF10B981)},
  ];

  final List<Map<String, dynamic>> _contentPerformance = [
    {'title': 'Morning vibe 🌅', 'views': 12400, 'reactions': 847, 'engagement': 6.8, 'time': '2d ago'},
    {'title': 'Behind the scenes 🎬', 'views': 8900, 'reactions': 523, 'engagement': 5.9, 'time': '4d ago'},
    {'title': 'Fitness routine 💪', 'views': 15600, 'reactions': 1203, 'engagement': 7.7, 'time': '6d ago'},
    {'title': 'Day in my life ☀️', 'views': 7200, 'reactions': 391, 'engagement': 5.4, 'time': '8d ago'},
    {'title': 'Cooking my fav meal 🍝', 'views': 21000, 'reactions': 1876, 'engagement': 8.9, 'time': '10d ago'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final user = provider.currentUser;
    final name = user?.displayName ?? 'Creator';

    return Scaffold(
      backgroundColor: SwiftSnapTheme.backgroundDark,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildSliverAppBar(name),
        ],
        body: Column(
          children: [
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(user?.displayName ?? 'Creator'),
                  _buildAnalyticsTab(),
                  _buildRevenueTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(String name) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: SwiftSnapTheme.backgroundCard,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                SwiftSnapTheme.primaryPurple.withOpacity(0.2),
                SwiftSnapTheme.primaryPink.withOpacity(0.1),
                SwiftSnapTheme.backgroundCard,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 60),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.stars_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                '⭐ CREATOR',
                                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Creator Dashboard',
                          style: TextStyle(color: SwiftSnapTheme.textSecondary, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showShareSheet(),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.share_rounded, color: Colors.white, size: 20),
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

  Widget _buildTabBar() {
    return Container(
      color: SwiftSnapTheme.backgroundCard,
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Analytics'),
          Tab(text: 'Revenue'),
        ],
        labelColor: Colors.white,
        unselectedLabelColor: SwiftSnapTheme.textMuted,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        indicatorColor: SwiftSnapTheme.primaryPurple,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.tab,
      ),
    );
  }

  // ──────────────────────────────────────────
  // OVERVIEW TAB
  // ──────────────────────────────────────────

  Widget _buildOverviewTab(String name) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroStats(),
          const SizedBox(height: 20),
          _buildQuickActionsSection(),
          const SizedBox(height: 20),
          _buildSectionTitle('Content Performance'),
          const SizedBox(height: 12),
          _buildContentTable(),
          const SizedBox(height: 20),
          _buildGrowthTipsCard(),
        ],
      ),
    );
  }

  Widget _buildHeroStats() {
    final stats = [
      _StatItem('Total Followers', '24.8K', Icons.people_rounded, const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)])),
      _StatItem('Story Views\n(30d)', '187K', Icons.visibility_rounded, const LinearGradient(colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)])),
      _StatItem('Engagement\nRate', '7.2%', Icons.trending_up_rounded, const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF06B6D4)])),
      _StatItem('Revenue\n(MTD)', '\$254', Icons.attach_money_rounded, const LinearGradient(colors: [Color(0xFFFBBF24), Color(0xFFF97316)])),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: stats.map((s) => _heroStatCard(s)).toList(),
    );
  }

  Widget _heroStatCard(_StatItem stat) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            SwiftSnapTheme.backgroundCard,
            SwiftSnapTheme.surfaceColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => stat.gradient.createShader(bounds),
            child: Icon(stat.icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  stat.value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  stat.label,
                  style: TextStyle(
                    color: SwiftSnapTheme.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    final actions = [
      _Action('New Story', Icons.add_photo_alternate_rounded, SwiftSnapTheme.primaryPurple, _showNewStory),
      _Action('Insights', Icons.bar_chart_rounded, const Color(0xFF06B6D4), () => _tabController.animateTo(1)),
      _Action('Revenue', Icons.attach_money_rounded, const Color(0xFF10B981), () => _tabController.animateTo(2)),
      _Action('Share\nProfile', Icons.ios_share_rounded, const Color(0xFFFBBF24), _showShareSheet),
      _Action('Apply\nVerified', Icons.verified_rounded, const Color(0xFFEC4899), _showVerificationSheet),
      _Action('Edit\nProfile', Icons.edit_rounded, const Color(0xFF94A3B8), () {}),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Quick Actions'),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.1,
          children: actions.map(_buildActionTile).toList(),
        ),
      ],
    );
  }

  Widget _buildActionTile(_Action action) {
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

  Widget _buildContentTable() {
    return Container(
      decoration: BoxDecoration(
        color: SwiftSnapTheme.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(child: Text('Story', style: TextStyle(color: SwiftSnapTheme.textMuted, fontSize: 12, fontWeight: FontWeight.w600))),
                SizedBox(width: 60, child: Text('Views', style: TextStyle(color: SwiftSnapTheme.textMuted, fontSize: 12), textAlign: TextAlign.center)),
                SizedBox(width: 60, child: Text('Eng %', style: TextStyle(color: SwiftSnapTheme.textMuted, fontSize: 12), textAlign: TextAlign.center)),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white12),
          ..._contentPerformance.map((c) => _contentRow(c)),
        ],
      ),
    );
  }

  Widget _contentRow(Map<String, dynamic> c) {
    final engagement = c['engagement'] as double;
    final engColor = engagement >= 7 ? const Color(0xFF10B981) : engagement >= 5 ? const Color(0xFFFBBF24) : const Color(0xFFEF4444);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.04))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c['title'] as String, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
                Text(c['time'] as String, style: TextStyle(color: SwiftSnapTheme.textMuted, fontSize: 11)),
              ],
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(
              _formatNumber(c['views'] as int),
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 60,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: engColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${engagement}%',
                style: TextStyle(color: engColor, fontSize: 11, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthTipsCard() {
    final tips = [
      '📅 Post consistently — at least 3 stories per week',
      '⏰ Best times: 8-10 AM and 7-9 PM in your timezone',
      '💬 Engage with followers who react to your stories',
      '🔥 Maintain your daily streak to boost visibility',
      '🏷️ Use location tags to reach new audiences',
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 10),
              const Text('Growth Tips', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          ...tips.map((t) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(t, style: TextStyle(color: SwiftSnapTheme.textSecondary, fontSize: 13, height: 1.5)),
          )),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────
  // ANALYTICS TAB
  // ──────────────────────────────────────────

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPeriodSelector(),
          const SizedBox(height: 16),
          _buildAnalyticsMetricsRow(),
          const SizedBox(height: 20),
          _buildSectionTitle('Story Views Trend'),
          const SizedBox(height: 12),
          _buildMockChart(
            bars: [4200, 6800, 5100, 8900, 7200, 12400, 9800, 15600, 11200, 18900, 14300, 21000, 17500, 24800],
            color: SwiftSnapTheme.primaryPurple,
          ),
          const SizedBox(height: 20),
          _buildSectionTitle('Follower Growth'),
          const SizedBox(height: 12),
          _buildMockChart(
            bars: [100, 180, 240, 310, 280, 420, 390, 510, 460, 620, 580, 710, 660, 840],
            color: const Color(0xFF10B981),
          ),
          const SizedBox(height: 20),
          _buildSectionTitle('Audience Breakdown'),
          const SizedBox(height: 12),
          _buildAudienceBreakdown(),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    final periods = ['7d', '30d', '90d', '1y'];
    return Row(
      children: periods.map((p) {
        final isSelected = _selectedPeriod == p;
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() => _selectedPeriod = p);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: isSelected ? SwiftSnapTheme.primaryGradient : null,
              color: isSelected ? null : SwiftSnapTheme.backgroundCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.1)),
            ),
            child: Text(
              p,
              style: TextStyle(
                color: isSelected ? Colors.white : SwiftSnapTheme.textMuted,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAnalyticsMetricsRow() {
    final metrics = [
      _Metric('Story Views', '187K', '+12%', true),
      _Metric('Profile Visits', '43K', '+8%', true),
      _Metric('New Followers', '2.4K', '+18%', true),
      _Metric('Engagement', '7.2%', '-0.3%', false),
    ];

    return Row(
      children: metrics.asMap().entries.map((entry) {
        final m = entry.value;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(left: entry.key == 0 ? 0 : 5),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: SwiftSnapTheme.backgroundCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(
                  m.change,
                  style: TextStyle(
                    color: m.isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(m.label, style: TextStyle(color: SwiftSnapTheme.textMuted, fontSize: 10), maxLines: 2),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMockChart({required List<int> bars, required Color color}) {
    final maxVal = bars.reduce((a, b) => a > b ? a : b).toDouble();

    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SwiftSnapTheme.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: bars.map((val) {
          final height = (val / maxVal) * 80;
          final isMax = val == bars.reduce((a, b) => a > b ? a : b);
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300 + bars.indexOf(val) * 30),
                height: height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isMax
                        ? [SwiftSnapTheme.primaryPurple, SwiftSnapTheme.primaryPink]
                        : [color.withOpacity(0.7), color.withOpacity(0.4)],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAudienceBreakdown() {
    final segments = [
      _Segment('18-24', 42, SwiftSnapTheme.primaryPurple),
      _Segment('25-34', 31, SwiftSnapTheme.primaryPink),
      _Segment('35-44', 15, const Color(0xFF06B6D4)),
      _Segment('45+', 12, const Color(0xFF10B981)),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SwiftSnapTheme.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: segments.map((s) {
                return Expanded(
                  flex: s.percentage,
                  child: Container(
                    height: 12,
                    color: s.color,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: segments.map((s) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 10, height: 10, decoration: BoxDecoration(color: s.color, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text('${s.label}: ${s.percentage}%', style: TextStyle(color: SwiftSnapTheme.textSecondary, fontSize: 13)),
              ],
            )).toList(),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────
  // REVENUE TAB
  // ──────────────────────────────────────────

  Widget _buildRevenueTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRevenueSummaryCard(),
          const SizedBox(height: 20),
          _buildSectionTitle('Revenue Breakdown'),
          const SizedBox(height: 12),
          _buildRevenueBreakdown(),
          const SizedBox(height: 20),
          _buildSectionTitle('Recent Transactions'),
          const SizedBox(height: 12),
          ..._revenueItems.map(_buildRevenueItem),
          const SizedBox(height: 20),
          _buildMonetizationCard(),
        ],
      ),
    );
  }

  Widget _buildRevenueSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF06B6D4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total Revenue (MTD)', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
          const SizedBox(height: 6),
          const Text('\$254.82', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          Row(
            children: [
              _revenuePill('Pending', '\$42.00', Colors.white.withOpacity(0.2)),
              const SizedBox(width: 10),
              _revenuePill('Paid', '\$212.82', Colors.white.withOpacity(0.2)),
              const Spacer(),
              Row(
                children: [
                  const Icon(Icons.trending_up_rounded, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text('+23% vs last month', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _revenuePill(String label, String value, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11)),
          const SizedBox(width: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildRevenueBreakdown() {
    final sources = [
      _RevenueSource('Tips', 55.9, const Color(0xFF10B981)),
      _RevenueSource('Ad Revenue', 26.4, const Color(0xFF06B6D4)),
      _RevenueSource('Subscriptions', 15.6, SwiftSnapTheme.primaryPurple),
      _RevenueSource('Other', 2.1, const Color(0xFF64748B)),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SwiftSnapTheme.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: sources.map((s) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(width: 10, height: 10, decoration: BoxDecoration(color: s.color, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Text(s.name, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  Text('${s.percentage}%', style: TextStyle(color: SwiftSnapTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: s.percentage / 100,
                  backgroundColor: Colors.white.withOpacity(0.08),
                  valueColor: AlwaysStoppedAnimation<Color>(s.color),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildRevenueItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SwiftSnapTheme.backgroundCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (item['color'] as Color).withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              item['type'] == 'Tips' ? Icons.volunteer_activism_rounded
                  : item['type'] == 'Subscription' ? Icons.stars_rounded
                  : Icons.ads_click_rounded,
              color: item['color'] as Color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['type'] as String, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                Text(item['from'] as String, style: TextStyle(color: SwiftSnapTheme.textMuted, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+\$${(item['amount'] as double).toStringAsFixed(2)}',
                style: TextStyle(color: item['color'] as Color, fontSize: 14, fontWeight: FontWeight.w700),
              ),
              Text(item['date'] as String, style: TextStyle(color: SwiftSnapTheme.textMuted, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonetizationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SwiftSnapTheme.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SwiftSnapTheme.primaryPurple.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.monetization_on_rounded, color: Color(0xFFFBBF24), size: 20),
              const SizedBox(width: 8),
              const Text('Monetization Tools', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 16),
          _monetizationRow('Tips enabled', true),
          _monetizationRow('Ad revenue sharing', true),
          _monetizationRow('Exclusive content (coming soon)', false),
          _monetizationRow('Merchandise store (coming soon)', false),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Payout settings coming soon!'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF06B6D4)]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  alignment: Alignment.center,
                  child: const Text('Set Up Payout', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _monetizationRow(String label, bool active) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(
            active ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            color: active ? const Color(0xFF10B981) : SwiftSnapTheme.textMuted,
            size: 18,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : SwiftSnapTheme.textMuted,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────
  // HELPERS
  // ──────────────────────────────────────────

  Widget _buildSectionTitle(String title) => Text(
    title,
    style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
  );

  String _formatNumber(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }

  void _showNewStory() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('📸 Opening story creator...'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showShareSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: SwiftSnapTheme.backgroundCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: SwiftSnapTheme.textMuted, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            const Text('Share Your Profile', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('swiftsnap.app/@creator', style: TextStyle(color: SwiftSnapTheme.primaryPurple, fontSize: 14)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _shareOption('Copy Link', Icons.link_rounded, SwiftSnapTheme.primaryPurple),
                _shareOption('Instagram', Icons.camera_alt_rounded, SwiftSnapTheme.primaryPink),
                _shareOption('Twitter/X', Icons.flutter_dash_rounded, const Color(0xFF06B6D4)),
                _shareOption('QR Code', Icons.qr_code_rounded, const Color(0xFF10B981)),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _shareOption(String label, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$label action triggered'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(color: SwiftSnapTheme.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }

  void _showVerificationSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: SwiftSnapTheme.backgroundCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: SwiftSnapTheme.textMuted, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            const Text('Apply for Verified Badge', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('Requirements:', style: TextStyle(color: SwiftSnapTheme.textSecondary, fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ...['✅ 1,000+ followers', '✅ 30+ days active', '✅ No recent violations', '⏳ Review takes 3-5 business days'].map((r) =>
              Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(r, style: TextStyle(color: SwiftSnapTheme.textSecondary, fontSize: 14)))
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(gradient: SwiftSnapTheme.primaryGradient, borderRadius: BorderRadius.circular(14)),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, padding: const EdgeInsets.symmetric(vertical: 14)),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('✅ Verification application submitted!'),
                        backgroundColor: SwiftSnapTheme.primaryPurple,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                  child: const Text('Apply Now', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// Data classes
class _StatItem {
  final String label;
  final String value;
  final IconData icon;
  final LinearGradient gradient;
  const _StatItem(this.label, this.value, this.icon, this.gradient);
}

class _Action {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _Action(this.label, this.icon, this.color, this.onTap);
}

class _Metric {
  final String label, value, change;
  final bool isPositive;
  const _Metric(this.label, this.value, this.change, this.isPositive);
}

class _Segment {
  final String label;
  final int percentage;
  final Color color;
  const _Segment(this.label, this.percentage, this.color);
}

class _RevenueSource {
  final String name;
  final double percentage;
  final Color color;
  const _RevenueSource(this.name, this.percentage, this.color);
}
