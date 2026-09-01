import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/settings_provider.dart';
import '../../theme/theme.dart';
import '../../widgets/common/app_top_bar.dart';

class AppLanguageScreen extends StatelessWidget {
  const AppLanguageScreen({super.key});

  static const Map<String, String> _languageNames = {
    'en': 'English',
    'es': 'Español',
    'fr': 'Français',
    'de': 'Deutsch',
    'pt': 'Português',
    'hi': 'हिन्दी',
    'ja': '日本語',
  };

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final current = settings.language;

    return Scaffold(
      body: Column(
        children: [
          const AppTopBar(showBack: true, title: 'App language'),
          Expanded(
            child: ListView(
              children: _languageNames.entries.map((e) {
                return RadioListTile<String>(
                  title: Text(e.value),
                  value: e.key,
                  groupValue: current,
                  onChanged: (v) async {
                    if (v == null) return;
                    await settings.setLanguage(v);
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
