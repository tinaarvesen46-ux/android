import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/theme.dart';
import '../api/services/v32_service.dart';

/// Achievements — bound to GET /api/v1/achievements. Shows real locked/unlocked
/// state and progress from the backend AchievementService. No fabricated data.
class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final SwiftSnapV32Service _api = SwiftSnapV32Service();
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    final res = await _api.achievements();
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (res.isSuccess && res.data != null) {
        _items = res.data!;
      } else {
        _error = res.errorMessage;
      }
    });
  }

  Color _color(Map<String, dynamic> a) {
    final hex = (a['badge_color'] ?? '#8B5CF6').toString().replaceAll('#', '');
    final v = int.tryParse(hex.length == 6 ? 'FF$hex' : hex, radix: 16);
    return v != null ? Color(v) : SwiftSnapTheme.primaryPurple;
  }

  IconData _icon(String name) {
    switch (name) {
      case 'user': return Icons.person_rounded;
      case 'users': return Icons.group_rounded;
      case 'fire': return Icons.local_fire_department_rounded;
      case 'message': return Icons.chat_bubble_rounded;
      case 'camera': return Icons.camera_alt_rounded;
      case 'star': return Icons.star_rounded;
      case 'trophy': return Icons.emoji_events_rounded;
      case 'heart': return Icons.favorite_rounded;
      default: return Icons.workspace_premium_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final earned = _items.where((a) => a['earned'] == true).length;
    return Scaffold(
      backgroundColor: SwiftSnapTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: SwiftSnapTheme.backgroundDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () { HapticFeedback.lightImpact(); Navigator.pop(context); },
        ),
        title: Text('Achievements${_items.isNotEmpty ? '  ·  $earned/${_items.length}' : ''}',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: SwiftSnapTheme.primaryPurple))
          : _error != null
              ? Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(_error!, style: const TextStyle(color: SwiftSnapTheme.textSecondary)),
                    const SizedBox(height: 12),
                    TextButton(onPressed: _load, child: const Text('Retry')),
                  ]),
                )
              : _items.isEmpty
                  ? const Center(
                      child: Text('No achievements yet.',
                          style: TextStyle(color: SwiftSnapTheme.textSecondary)))
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(14, 10, 14, 30),
                        itemCount: _items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) => _tile(_items[i]),
                      ),
                    ),
    );
  }

  Widget _tile(Map<String, dynamic> a) {
    final earned = a['earned'] == true;
    final progress = (a['progress'] is num) ? (a['progress'] as num).toInt() : 0;
    final threshold = (a['threshold'] is num) ? (a['threshold'] as num).toInt() : 1;
    final ratio = threshold > 0 ? (progress / threshold).clamp(0.0, 1.0) : 0.0;
    final c = _color(a);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SwiftSnapTheme.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: earned ? c.withOpacity(0.6) : Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: earned ? c.withOpacity(0.2) : Colors.white.withOpacity(0.05),
            ),
            child: Icon(_icon((a['icon'] ?? '').toString()),
                color: earned ? c : SwiftSnapTheme.textMuted, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text((a['name'] ?? '').toString(),
                    style: TextStyle(
                        color: earned ? SwiftSnapTheme.textPrimary : SwiftSnapTheme.textSecondary,
                        fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 2),
                Text((a['description'] ?? '').toString(),
                    style: const TextStyle(color: SwiftSnapTheme.textMuted, fontSize: 12)),
                if (!earned) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: ratio,
                      minHeight: 5,
                      backgroundColor: Colors.white.withOpacity(0.06),
                      valueColor: AlwaysStoppedAnimation(c),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('$progress / $threshold',
                      style: const TextStyle(color: SwiftSnapTheme.textMuted, fontSize: 11)),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(earned ? Icons.check_circle_rounded : Icons.lock_outline_rounded,
              color: earned ? c : SwiftSnapTheme.textMuted, size: 20),
        ],
      ),
    );
  }
}
