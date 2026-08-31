import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../theme/theme.dart';
import '../../widgets/common/app_top_bar.dart';
import '../../widgets/common/settings_rows.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  PackageInfo? _info;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) setState(() => _info = info);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;

    return Scaffold(
      body: Column(
        children: [
          const AppTopBar(showBack: true, title: 'About SwiftSnap'),
          Expanded(
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingXl),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusLg),
                        child: Image.asset(
                          'assets/icons/app_icon.png',
                          width: AppTheme.avatarXl,
                          height: AppTheme.avatarXl,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingMd),
                      Text('SwiftSnap', style: theme.textTheme.titleLarge),
                    ],
                  ),
                ),
                SettingsInfoRow(
                  title: 'Version',
                  value: _info == null
                      ? '—'
                      : '${_info!.version} (${_info!.buildNumber})',
                ),
                SettingsInfoRow(
                  title: 'Package',
                  value: _info?.packageName ?? '—',
                ),
                Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingLg),
                  child: Text(
                    'SwiftSnap is an independent camera-first social app. It is not '
                    'affiliated with, endorsed by, or connected to Snap Inc.',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: appColors.subtleText),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
