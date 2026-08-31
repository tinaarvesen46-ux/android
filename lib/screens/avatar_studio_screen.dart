import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import '../providers/social_provider.dart';
import '../theme/theme.dart';
import '../widgets/common/app_top_bar.dart';

/// SwiftSnap-native avatar builder. The configuration is stored locally and
/// synced to the backend so it can be rendered anywhere the user appears.
class AvatarStudioScreen extends StatefulWidget {
  const AvatarStudioScreen({super.key});

  @override
  State<AvatarStudioScreen> createState() => _AvatarStudioScreenState();
}

class _AvatarStudioScreenState extends State<AvatarStudioScreen> {
  static const Map<String, List<String>> _parts = {
    'skin': ['Fair', 'Light', 'Medium', 'Tan', 'Deep'],
    'hair': ['Short', 'Curly', 'Long', 'Buzz', 'Wavy'],
    'eyes': ['Round', 'Almond', 'Wide', 'Narrow'],
    'outfit': ['Hoodie', 'Tee', 'Jacket', 'Shirt'],
    'accessory': ['None', 'Glasses', 'Cap', 'Earrings'],
  };

  bool _saving = false;

  Future<void> _save() async {
    setState(() => _saving = true);
    final settings = context.read<SettingsProvider>();
    final error =
        await context.read<SocialProvider>().saveAvatarConfig(settings.avatarConfig);
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? 'Avatar saved.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      body: Column(
        children: [
          const AppTopBar(showBack: true, title: 'Avatar studio'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              children: [
                for (final entry in _parts.entries) ...[
                  Text(
                    entry.key[0].toUpperCase() + entry.key.substring(1),
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  Wrap(
                    spacing: AppTheme.spacingSm,
                    children: [
                      for (final option in entry.value)
                        ChoiceChip(
                          label: Text(option),
                          selected: settings.stringFor(
                                '${SettingsProvider.avatarPrefix}${entry.key}',
                                fallback: entry.value.first,
                              ) ==
                              option,
                          onSelected: (_) =>
                              settings.setAvatarPart(entry.key, option),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingLg),
                ],
                ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: AppTheme.iconSm,
                          height: AppTheme.iconSm,
                          child: CircularProgressIndicator(
                            strokeWidth: AppTheme.borderThick,
                          ),
                        )
                      : const Text('Save avatar'),
                ),
                const SizedBox(height: AppTheme.spacingSm),
                TextButton(
                  onPressed: settings.resetAvatar,
                  child: const Text('Reset'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
