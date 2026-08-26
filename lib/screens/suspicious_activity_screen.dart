import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/theme.dart';
import '../api/services/settings_service.dart';

/// Suspicious activity — bound to Laravel GET /security/suspicious-activity.
/// The backend currently returns an empty list (no anomalies detected / feature
/// not yet populated server-side), so this screen renders a real empty state.
class SuspiciousActivityScreen extends StatefulWidget {
  const SuspiciousActivityScreen({super.key});

  @override
  State<SuspiciousActivityScreen> createState() => _SuspiciousActivityScreenState();
}

class _SuspiciousActivityScreenState extends State<SuspiciousActivityScreen> {
  final SettingsService _service = SettingsService();
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final res = await _service.getSuspiciousActivity();
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (res.isSuccess) {
        _items = res.data ?? [];
      } else {
        _error = res.errorMessage;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwiftSnapTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: SwiftSnapTheme.surfaceColor,
        title: const Text('Suspicious Activity'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: SwiftSnapTheme.primaryPurple));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: SwiftSnapTheme.textSecondary)),
            const SizedBox(height: 12),
            TextButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.verified_user_rounded, color: SwiftSnapTheme.accentGreen, size: 56),
            SizedBox(height: 16),
            Text('No suspicious activity',
                style: TextStyle(color: SwiftSnapTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 6),
            Text('We haven\'t detected anything unusual on your account.',
                textAlign: TextAlign.center,
                style: TextStyle(color: SwiftSnapTheme.textSecondary, fontSize: 13)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final s = _items[i];
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: SwiftSnapTheme.surfaceColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: SwiftSnapTheme.busy.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: SwiftSnapTheme.busy),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('${s['description'] ?? s['type'] ?? s.toString()}',
                      style: const TextStyle(color: SwiftSnapTheme.textPrimary)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
