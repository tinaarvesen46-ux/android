import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/theme.dart';
import '../api/services/notification_service.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() => _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState extends State<NotificationsSettingsScreen> {
  final NotificationService _service = NotificationService();
  Map<String, dynamic> _settings = {};
  bool _loading = true;
  bool _saving = false;
  String? _error;

  // Boolean preference keys returned by /notifications/settings.
  static const _prefs = <String, String>{
    'new_message': 'New messages',
    'friend_request': 'Friend requests',
    'friend_accepted': 'Friend accepted',
    'story_view': 'Story views',
    'story_reaction': 'Story reactions',
    'streak_reminder': 'Streak reminders',
    'streak_achievement': 'Streak achievements',
    'mention': 'Mentions',
  };

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
    final res = await _service.getSettings();
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (res.isSuccess && res.data != null) {
        _settings = Map<String, dynamic>.from(res.data!);
      } else {
        _error = res.errorMessage;
      }
    });
  }

  bool _isOn(String key) => _settings[key] == 1 || _settings[key] == true;

  Future<void> _toggle(String key, bool value) async {
    HapticFeedback.selectionClick();
    setState(() {
      _settings[key] = value ? 1 : 0;
      _saving = true;
    });
    final res = await _service.updateSettings({key: value ? 1 : 0});
    if (!mounted) return;
    setState(() => _saving = false);
    if (!res.isSuccess) {
      setState(() => _settings[key] = value ? 0 : 1); // revert on failure
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.errorMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwiftSnapTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: SwiftSnapTheme.surfaceColor,
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                  width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
            ),
        ],
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
    final keys = _prefs.keys.where((k) => _settings.containsKey(k)).toList();
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: keys.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final key = keys[i];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: SwiftSnapTheme.surfaceColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeColor: SwiftSnapTheme.primaryPurple,
            title: Text(_prefs[key]!, style: const TextStyle(color: SwiftSnapTheme.textPrimary)),
            value: _isOn(key),
            onChanged: (v) => _toggle(key, v),
          ),
        );
      },
    );
  }
}
