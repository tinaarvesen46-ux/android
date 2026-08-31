import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/social.dart';
import '../providers/social_provider.dart';
import '../theme/theme.dart';
import '../widgets/common/app_top_bar.dart';
import '../widgets/common/async_state_view.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<SocialProvider>().loadAchievements();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;
    final provider = context.watch<SocialProvider>();

    return Scaffold(
      body: Column(
        children: [
          const AppTopBar(showBack: true, title: 'Achievements'),
          Expanded(
            child: AsyncStateView<List<Achievement>>(
              state: provider.achievements,
              emptyIcon: Icons.emoji_events_outlined,
              emptyTitle: 'No achievements yet',
              emptyMessage: 'Keep snapping to unlock achievements.',
              onRetry: provider.loadAchievements,
              builder: (achievements) => ListView.builder(
                padding: const EdgeInsets.all(AppTheme.spacingLg),
                itemCount: achievements.length,
                itemBuilder: (context, index) {
                  final achievement = achievements[index];
                  return Padding(
                    padding:
                        const EdgeInsets.only(bottom: AppTheme.spacingLg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              achievement.isUnlocked
                                  ? Icons.emoji_events_rounded
                                  : Icons.lock_outline_rounded,
                              size: AppTheme.iconMd,
                              color: achievement.isUnlocked
                                  ? theme.colorScheme.primary
                                  : appColors.subtleText,
                            ),
                            const SizedBox(width: AppTheme.spacingMd),
                            Expanded(
                              child: Text(
                                achievement.name,
                                style: theme.textTheme.titleSmall,
                              ),
                            ),
                            Text(
                              '${achievement.progress}/${achievement.target}',
                              style: theme.textTheme.labelSmall
                                  ?.copyWith(color: appColors.subtleText),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spacingSm),
                        Text(
                          achievement.description,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: appColors.subtleText),
                        ),
                        const SizedBox(height: AppTheme.spacingSm),
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusFull),
                          child: LinearProgressIndicator(
                            value: achievement.completion,
                            backgroundColor:
                                theme.colorScheme.surfaceContainerHighest,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
