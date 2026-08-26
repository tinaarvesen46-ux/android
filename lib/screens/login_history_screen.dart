import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/theme.dart';
import '../api/services/settings_service.dart';

/// Login history — bound to Laravel GET /security/login-history
/// (returns the user's access tokens: {id, name, last_used_at, created_at}).
class LoginHistoryScreen extends StatefulWidget {
  const LoginHistoryScreen({super.key});

  @override
  State<LoginHistoryScreen> createState() => _LoginHistoryScreenState();
}

class _LoginHistoryScreenState extends State<LoginHistoryScreen> {
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
    final res = await _service.getLoginHistory();
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
        title: const Text('Login History'),
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
      return const Center(
        child: Text('No login history', style: TextStyle(color: SwiftSnapTheme.textSecondary)),
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
          final last = s['last_used_at']?.toString();
          final created = s['created_at']?.toString();
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: SwiftSnapTheme.surfaceColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Row(
              children: [
                const Icon(Icons.devices_rounded, color: SwiftSnapTheme.textSecondary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${s['name'] ?? 'Session'}',
                          style: const TextStyle(color: SwiftSnapTheme.textPrimary, fontWeight: FontWeight.w600)),
                      Text('Signed in ${created ?? ''}',
                          style: const TextStyle(color: SwiftSnapTheme.textSecondary, fontSize: 12)),
                      if (last != null && last.isNotEmpty)
                        Text('Last active $last',
                            style: const TextStyle(color: SwiftSnapTheme.textMuted, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
