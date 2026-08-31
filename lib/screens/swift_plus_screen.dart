import 'package:flutter/material.dart';

import '../theme/theme.dart';
import '../widgets/common/app_top_bar.dart';

/// Swift+ overview. Subscription entitlement, pricing and purchase flow are
/// owned by the backend and the store billing layer; nothing is simulated here.
class SwiftPlusScreen extends StatelessWidget {
  const SwiftPlusScreen({super.key});

  static const List<String> _benefits = [
    'Custom app icons and themes',
    'Story rewatch insights',
    'Priority uploads for reels',
    'Extended memories storage',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;

    return Scaffold(
      body: Column(
        children: [
          const AppTopBar(showBack: true, title: 'Swift+'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppTheme.spacingXl),
              children: [
                Icon(
                  Icons.workspace_premium_rounded,
                  size: AppTheme.iconHuge,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: AppTheme.spacingLg),
                Text('SwiftSnap Swift+', style: theme.textTheme.headlineSmall),
                const SizedBox(height: AppTheme.spacingSm),
                Text(
                  'Premium features for people who live in the camera.',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: appColors.subtleText),
                ),
                const SizedBox(height: AppTheme.spacingXl),
                ..._benefits.map(
                  (benefit) => Padding(
                    padding:
                        const EdgeInsets.only(bottom: AppTheme.spacingMd),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline_rounded,
                          size: AppTheme.iconSm,
                          color: appColors.success,
                        ),
                        const SizedBox(width: AppTheme.spacingMd),
                        Expanded(
                          child: Text(benefit,
                              style: theme.textTheme.bodyMedium),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXl),
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingLg),
                  decoration: BoxDecoration(
                    color: appColors.cardSurface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: Text(
                    'Subscription status, pricing and purchases are provided by the '
                    'SwiftSnap backend together with the App Store and Google Play '
                    'billing layer. No plan is active until that integration is connected.',
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
