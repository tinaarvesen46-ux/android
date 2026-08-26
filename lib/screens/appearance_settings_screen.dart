import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/theme.dart';
import '../api/services/settings_service.dart';

/// Appearance settings — bound to Laravel GET/PUT /settings/appearance (UserSettings).
/// Persists `theme` (light/dark/auto) and `language`.
class AppearanceSettingsScreen extends StatefulWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  State<AppearanceSettingsScreen> createState() => _AppearanceSettingsScreenState();
}

class _AppearanceSettingsScreenState extends State<AppearanceSettingsScreen> {
  final SettingsService _service = SettingsService();
  Map<String, dynamic> _settings = {};
  bool _loading = true;
  bool _saving = false;
  String? _error;

  static const _themes = ['light', 'dark', 'auto'];
  static const _languages = <String, String>{
    'en': 'English',
    'es': 'Español',
    'fr': 'Français',
    'de': 'Deutsch',
    'pt': 'Português',
    'ar': 'العربية',
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
    final res = await _service.getAppearanceSettings();
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

  Future<void> _save(String key, dynamic value) async {
    HapticFeedback.selectionClick();
    final prev = _settings[key];
    setState(() {
      _settings[key] = value;
      _saving = true;
    });
    final res = await _service.updateAppearanceSettings({key: value});
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
        title: const Text('App Appearance'),
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
    final theme = _themes.contains(_settings['theme']) ? _settings['theme'] as String : 'dark';
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text('Theme', style: TextStyle(color: SwiftSnapTheme.textSecondary, fontSize: 13)),
        ),
        ..._themes.map((t) => _card(
              child: RadioListTile<String>(
                contentPadding: EdgeInsets.zero,
                activeColor: SwiftSnapTheme.primaryPurple,
                title: Text(t[0].toUpperCase() + t.substring(1),
                    style: const TextStyle(color: SwiftSnapTheme.textPrimary)),
                value: t,
                groupValue: theme,
                onChanged: (v) => v == null ? null : _save('theme', v),
              ),
            )),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text('Language', style: TextStyle(color: SwiftSnapTheme.textSecondary, fontSize: 13)),
        ),
        _card(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('App language', style: TextStyle(color: SwiftSnapTheme.textPrimary)),
            trailing: DropdownButton<String>(
              dropdownColor: SwiftSnapTheme.surfaceLight,
              value: _languages.containsKey(_settings['language']) ? _settings['language'] as String : 'en',
              underline: const SizedBox(),
              items: _languages.entries
                  .map((e) => DropdownMenuItem(
                        value: e.key,
                        child: Text(e.value, style: const TextStyle(color: SwiftSnapTheme.textPrimary)),
                      ))
                  .toList(),
              onChanged: (v) => v == null ? null : _save('language', v),
            ),
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
