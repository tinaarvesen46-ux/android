import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/theme.dart';
import '../api/services/settings_service.dart';
import 'blocked_users_screen.dart';
import 'restricted_words_screen.dart';

/// Privacy settings — bound to Laravel GET/PUT /settings/privacy (UserSettings).
class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  final SettingsService _service = SettingsService();
  Map<String, dynamic> _settings = {};
  bool _loading = true;
  bool _saving = false;
  String? _error;

  static const _bools = <String, String>{
    'show_online_status': 'Show online status',
    'show_read_receipts': 'Read receipts',
    'show_typing_indicator': 'Typing indicator',
    'login_alerts': 'Login alerts',
    'screenshot_alerts': 'Screenshot alerts',
  };

  // key -> (label, allowed enum options from the backend schema)
  static const _choices = <String, List<String>>{
    'allow_messages_from': ['everyone', 'friends', 'nobody'],
    'story_visibility': ['everyone', 'friends', 'close_friends', 'nobody'],
    'allow_friend_requests_from': ['everyone', 'friends_of_friends', 'nobody'],
  };

  static const _choiceLabels = <String, String>{
    'allow_messages_from': 'Who can message me',
    'story_visibility': 'Who can see my stories',
    'allow_friend_requests_from': 'Who can add me',
  };

  String _pretty(String v) =>
      v.split('_').map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1)).join(' ');

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
    final res = await _service.getPrivacySettings();
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

  Future<void> _save(String key, dynamic value) async {
    HapticFeedback.selectionClick();
    final prev = _settings[key];
    setState(() {
      _settings[key] = value;
      _saving = true;
    });
    final res = await _service.updatePrivacySettings({key: value});
    if (!mounted) return;
    setState(() {
      _saving = false;
      if (res.isSuccess && res.data != null) {
        _settings = Map<String, dynamic>.from(res.data!);
      }
    });
    if (!res.isSuccess) {
      setState(() => _settings[key] = prev);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.errorMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwiftSnapTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: SwiftSnapTheme.surfaceColor,
        title: const Text('Privacy Control'),
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
              child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ..._bools.entries.map((e) => _card(
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: SwiftSnapTheme.primaryPurple,
                title: Text(e.value, style: const TextStyle(color: SwiftSnapTheme.textPrimary)),
                value: _isOn(e.key),
                onChanged: (v) => _save(e.key, v),
              ),
            )),
        ..._choices.entries.map((e) => _card(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_choiceLabels[e.key]!, style: const TextStyle(color: SwiftSnapTheme.textPrimary)),
                trailing: DropdownButton<String>(
                  dropdownColor: SwiftSnapTheme.surfaceLight,
                  value: e.value.contains(_settings[e.key]) ? _settings[e.key] as String : null,
                  hint: const Text('Select', style: TextStyle(color: SwiftSnapTheme.textSecondary)),
                  underline: const SizedBox(),
                  items: e.value
                      .map((o) => DropdownMenuItem(
                            value: o,
                            child: Text(_pretty(o),
                                style: const TextStyle(color: SwiftSnapTheme.textPrimary)),
                          ))
                      .toList(),
                  onChanged: (v) => v == null ? null : _save(e.key, v),
                ),
              ),
            )),
        const SizedBox(height: 8),
        _card(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.block_rounded, color: SwiftSnapTheme.textSecondary),
            title: const Text('Blocked Users', style: TextStyle(color: SwiftSnapTheme.textPrimary)),
            trailing: const Icon(Icons.chevron_right_rounded, color: SwiftSnapTheme.textSecondary),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const BlockedUsersScreen())),
          ),
        ),
        _card(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.text_fields_rounded, color: SwiftSnapTheme.textSecondary),
            title: const Text('Restricted Words', style: TextStyle(color: SwiftSnapTheme.textPrimary)),
            trailing: const Icon(Icons.chevron_right_rounded, color: SwiftSnapTheme.textSecondary),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const RestrictedWordsScreen())),
          ),
        ),
      ],
    );
  }

  Widget _card({required Widget child}) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: SwiftSnapTheme.surfaceColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: child,
      );
}
