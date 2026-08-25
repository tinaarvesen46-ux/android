import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/theme.dart';
import '../../models/admin_models.dart';
import '../../api/services/admin_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  final AdminService _adminService = AdminService();
  PlatformAnalytics? _analytics;
  bool _loading = true;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAnalytics();
  }

  @override
  void dispose() {
    _tabController.dispose();
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
    return Scaffold(
      backgroundColor: SwiftSnapTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: SwiftSnapTheme.backgroundDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Analytics',
          style: TextStyle(
            color: SwiftSnapTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              setState(() => _loading = true);
              _loadAnalytics();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: SwiftSnapTheme.primaryPurple,
          unselectedLabelColor: SwiftSnapTheme.textMuted,
          indicatorColor: SwiftSnapTheme.primaryPurple,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [
            Tab(text: 'Users'),
            Tab(text: 'Messages'),
            Tab(text: 'Growth'),
          ],
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                color: SwiftSnapTheme.primaryPurple,
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildUsersTab(),
                _buildMessagesTab(),
                _buildGrowthTab(),
              ],
            ),
    );
  }

  Widget _buildUsersTab() {
    final a = _analytics!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMetricsGrid([
            _Metric(
              'Total Users',
              _fmt(a.totalUsers),
              Icons.people_rounded,
              SwiftSnapTheme.primaryGradient,
            ),
            _Metric(
              'Active Today',
              _fmt(a.activeUsersToday),
              Icons.bolt_rounded,
              SwiftSnapTheme.secondaryGradient,
            ),
            _Metric(
              'Active Week',
              _fmt(a.activeUsersWeek),
              Icons.date_range_rounded,
              const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF06B6D4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            _Metric(
              'Active Month',
              _fmt(a.activeUsersMonth),
              Icons.calendar_month_rounded,
              const LinearGradient(
                colors: [Color(0xFFEC4899), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ]),
          const SizedBox(height: 20),
          _buildChartCard(
            'Daily Active Users (14d)',
            a.dailyActiveUsers,
            SwiftSnapTheme.primaryPurple,
          ),
          const SizedBox(height: 16),
          _buildEngagementCard(a),
        ],
      ),
    );
  }

  Widget _buildMessagesTab() {
    final a = _analytics!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildMetricsGrid([
            _Metric(
              'Total Messages',
              _fmt(a.totalMessages),
              Icons.chat_rounded,
              SwiftSnapTheme.primaryGradient,
            ),
            _Metric(
              'Today',
              _fmt(a.messagesToday),
              Icons.today_rounded,
              SwiftSnapTheme.secondaryGradient,
            ),
            _Metric(
              'Stories Total',
              _fmt(a.totalStories),
              Icons.amp_stories_rounded,
              const LinearGradient(
                colors: [Color(0xFFFBBF24), Color(0xFFF97316)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            _Metric(
              'Stories Today',
              _fmt(a.storiesToday),
              Icons.add_circle_rounded,
              const LinearGradient(
                colors: [Color(0xFFF97316), Color(0xFFEF4444)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ]),
          const SizedBox(height: 20),
          _buildChartCard(
            'Daily Messages (14d)',
            a.dailyMessages,
            SwiftSnapTheme.accentCyan,
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthTab() {
    final a = _analytics!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildMetricsGrid([
            _Metric(
              'New Today',
              '+${_fmt(a.newUsersToday)}',
              Icons.person_add_rounded,
              SwiftSnapTheme.primaryGradient,
            ),
            _Metric(
              'New This Week',
              '+${_fmt(a.newUsersWeek)}',
              Icons.trending_up_rounded,
              const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF06B6D4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            _Metric(
              'Open Tickets',
              '${a.openTickets}',
              Icons.support_agent_rounded,
              const LinearGradient(
                colors: [Color(0xFFF97316), Color(0xFFEF4444)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            _Metric(
              'Pending Reports',
              '${a.pendingReports}',
              Icons.flag_rounded,
              const LinearGradient(
                colors: [Color(0xFFEF4444), Color(0xFFEC4899)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ]),
          const SizedBox(height: 20),
          _buildChartCard(
            'New Users Per Day (14d)',
            a.dailyNewUsers,
            SwiftSnapTheme.accentGreen,
          ),
          const SizedBox(height: 16),
          _buildServerCard(a),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(List<_Metric> metrics) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.6,
      ),
      itemCount: metrics.length,
      itemBuilder: (_, i) {
        final m = metrics[i];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: SwiftSnapTheme.glassmorphicDecoration(),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: m.gradient,
                  borderRadius:
                      BorderRadius.circular(SwiftSnapTheme.radiusMd),
                ),
                child: Icon(m.icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      m.value,
                      style: const TextStyle(
                        color: SwiftSnapTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      m.label,
                      style: const TextStyle(
                        color: SwiftSnapTheme.textMuted,
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChartCard(
      String title, List<DailyMetric> data, Color color) {
    final spots = data.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.value.toDouble());
    }).toList();

    final maxY = data.fold<double>(
            0, (max, m) => m.value > max ? m.value.toDouble() : max) *
        1.2;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: SwiftSnapTheme.glassmorphicDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: SwiftSnapTheme.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: Colors.white.withOpacity(0.05),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, _) => Text(
                        _fmtAxisValue(value),
                        style: const TextStyle(
                          color: SwiftSnapTheme.textMuted,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (data.length - 1).toDouble(),
                minY: 0,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: color,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          color.withOpacity(0.3),
                          color.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEngagementCard(PlatformAnalytics a) {
    final dau = a.activeUsersToday;
    final mau = a.activeUsersMonth;
    final ratio = mau > 0 ? (dau / mau * 100) : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: SwiftSnapTheme.glassmorphicDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Engagement Rate',
            style: TextStyle(
              color: SwiftSnapTheme.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'DAU / MAU',
                style: TextStyle(
                  color: SwiftSnapTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
              Text(
                '${ratio.toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: SwiftSnapTheme.primaryPurple,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius:
                BorderRadius.circular(SwiftSnapTheme.radiusFull),
            child: LinearProgressIndicator(
              value: ratio / 100,
              backgroundColor: SwiftSnapTheme.surfaceLight,
              valueColor: const AlwaysStoppedAnimation<Color>(
                  SwiftSnapTheme.primaryPurple),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Healthy range: 20-25%',
            style: const TextStyle(
              color: SwiftSnapTheme.textMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServerCard(PlatformAnalytics a) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: SwiftSnapTheme.glassmorphicDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Infrastructure',
            style: TextStyle(
              color: SwiftSnapTheme.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          _progressRow('Server Load', a.serverLoad, SwiftSnapTheme.accentOrange),
          const SizedBox(height: 12),
          _progressRow('DB Health', 94.0, SwiftSnapTheme.accentGreen),
          const SizedBox(height: 12),
          _progressRow('API Uptime', 99.9, SwiftSnapTheme.primaryBlue),
        ],
      ),
    );
  }

  Widget _progressRow(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: SwiftSnapTheme.textSecondary,
                fontSize: 13,
              ),
            ),
            Text(
              '${value.toStringAsFixed(1)}%',
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(SwiftSnapTheme.radiusFull),
          child: LinearProgressIndicator(
            value: value / 100,
            backgroundColor: SwiftSnapTheme.surfaceLight,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }

  String _fmtAxisValue(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toInt().toString();
  }
}

class _Metric {
  final String label;
  final String value;
  final IconData icon;
  final LinearGradient gradient;
  const _Metric(this.label, this.value, this.icon, this.gradient);
}
