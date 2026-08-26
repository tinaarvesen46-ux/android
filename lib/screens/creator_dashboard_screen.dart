import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/theme.dart';
import '../api/services/lens_service.dart';

/// Creator Dashboard — real data from the SwiftSnap Lens Studio backend.
///
/// Bound to:
///  - GET /lens-studio/analytics  -> totals (uses, favorites, reports) + daily series
///  - GET /lenses/my              -> the creator's own lenses (all statuses)
///
/// Audience metrics (followers/engagement) and monetary earnings history are
/// intentionally NOT shown as numbers because the backend currently exposes no
/// read endpoint for them (a `creator_revenue` table is written on tips but has
/// no GET API, and there are no follower/engagement metrics endpoints). These
/// are surfaced as an honest "not available yet" card instead of fabricated data.
class CreatorDashboardScreen extends StatefulWidget {
  const CreatorDashboardScreen({super.key});

  @override
  State<CreatorDashboardScreen> createState() => _CreatorDashboardScreenState();
}

class _CreatorDashboardScreenState extends State<CreatorDashboardScreen> {
  final LensService _lens = LensService();
  bool _loading = true;
  Map<String, dynamic>? _analytics;
  List<Map<String, dynamic>> _myLenses = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final results = await Future.wait([
      _lens.analytics(days: 14),
      _lens.myLenses(),
    ]);
    if (!mounted) return;
    setState(() {
      _analytics = results[0] as Map<String, dynamic>?;
      _myLenses = (results[1] as List).cast<Map<String, dynamic>>();
      _loading = false;
    });
  }

  int _total(String key) {
    final totals = _analytics?['totals'];
    if (totals is Map && totals[key] is num) return (totals[key] as num).toInt();
    return 0;
  }

  List<int> _dailyUses() {
    final series = _analytics?['series'];
    if (series is List) {
      return series.map<int>((d) => (d is Map && d['uses'] is num) ? (d['uses'] as num).toInt() : 0).toList();
    }
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwiftSnapTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: SwiftSnapTheme.surfaceColor,
        title: const Text('Creator Studio'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: SwiftSnapTheme.primaryPurple))
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _statsRow(),
                  const SizedBox(height: 20),
                  _usesChart(),
                  const SizedBox(height: 20),
                  _myLensesSection(),
                  const SizedBox(height: 20),
                  _backendRequiredCard(),
                ],
              ),
            ),
    );
  }

  Widget _statsRow() {
    final stats = [
      ['Lens uses', _total('uses'), Icons.auto_awesome_rounded, SwiftSnapTheme.primaryPurple],
      ['Favorites', _total('favorites'), Icons.favorite_rounded, SwiftSnapTheme.primaryPink],
      ['Reports', _total('reports'), Icons.flag_rounded, SwiftSnapTheme.accentOrange],
    ];
    return Row(
      children: stats.map((s) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: SwiftSnapTheme.surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Column(
              children: [
                Icon(s[2] as IconData, color: s[3] as Color, size: 24),
                const SizedBox(height: 8),
                Text('${s[1]}',
                    style: const TextStyle(color: SwiftSnapTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(s[0] as String,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: SwiftSnapTheme.textSecondary, fontSize: 12)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _usesChart() {
    final data = _dailyUses();
    final maxVal = data.isEmpty ? 0 : data.reduce((a, b) => a > b ? a : b);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SwiftSnapTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Lens uses (last 14 days)',
              style: TextStyle(color: SwiftSnapTheme.textPrimary, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: data.isEmpty
                ? const Center(
                    child: Text('No activity yet',
                        style: TextStyle(color: SwiftSnapTheme.textSecondary)))
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: data.map((v) {
                      final h = maxVal == 0 ? 2.0 : (v / maxVal) * 90 + 2;
                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          height: h,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [SwiftSnapTheme.primaryPurple, SwiftSnapTheme.primaryPink],
                            ),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _myLensesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('My Lenses',
            style: TextStyle(color: SwiftSnapTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        if (_myLenses.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: SwiftSnapTheme.surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: const Center(
              child: Text('You haven\'t created any lenses yet.',
                  style: TextStyle(color: SwiftSnapTheme.textSecondary)),
            ),
          )
        else
          ..._myLenses.map(_lensTile),
      ],
    );
  }

  Widget _lensTile(Map<String, dynamic> lens) {
    final status = '${lens['moderation_status'] ?? 'pending'}';
    final statusColor = status == 'approved'
        ? SwiftSnapTheme.accentGreen
        : (status == 'pending' ? SwiftSnapTheme.accentOrange : SwiftSnapTheme.busy);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SwiftSnapTheme.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: SwiftSnapTheme.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: SwiftSnapTheme.primaryPurple),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${lens['name'] ?? 'Untitled'}',
                    style: const TextStyle(color: SwiftSnapTheme.textPrimary, fontWeight: FontWeight.w600),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text('${lens['use_count'] ?? 0} uses  •  ${lens['favorite_count'] ?? 0} favorites',
                    style: const TextStyle(color: SwiftSnapTheme.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(status,
                style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _backendRequiredCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SwiftSnapTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: SwiftSnapTheme.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Earnings & audience analytics',
                    style: TextStyle(color: SwiftSnapTheme.textPrimary, fontWeight: FontWeight.w700)),
                SizedBox(height: 6),
                Text(
                  'Follower counts, engagement rate and earnings history aren\'t available yet — '
                  'the backend needs a creator earnings/audience read API before these can be shown. '
                  'The stats above are your real lens performance figures.',
                  style: TextStyle(color: SwiftSnapTheme.textSecondary, fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
