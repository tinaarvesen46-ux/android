import 'package:flutter/material.dart';
import '../../models/story.dart';
import '../../theme/theme.dart';
import '../common/snap_avatar.dart';

class StoryRow extends StatelessWidget {
  final List<Story> stories;
  final VoidCallback? onAddStory;
  final ValueChanged<Story>? onStoryTap;

  const StoryRow({
    super.key,
    required this.stories,
    this.onAddStory,
    this.onStoryTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;

    return SizedBox(
      height: 88,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
        itemCount: stories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(right: AppTheme.spacingMd),
              child: GestureDetector(
                onTap: onAddStory,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: AppTheme.storyAvatarSize,
                      height: AppTheme.storyAvatarSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.surfaceContainerHighest,
                        border: Border.all(
                          color: theme.colorScheme.outline,
                          width: AppTheme.borderThin,
                        ),
                      ),
                      child: Icon(
                        Icons.add,
                        size: AppTheme.iconLg,
                        color: appColors.subtleText,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingXs),
                    Text(
                      'My Story',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: appColors.subtleText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          }

          final story = stories[index - 1];
          return Padding(
            padding: const EdgeInsets.only(right: AppTheme.spacingMd),
            child: GestureDetector(
              onTap: () => onStoryTap?.call(story),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SnapAvatar(
                    imageUrl: story.author.avatarUrl,
                    renderUrl: story.author.avatarRenderUrl,
                    fallbackText: story.author.displayName,
                    size: AppTheme.storyAvatarSize,
                    showStoryRing: true,
                    storySeen: story.isSeen,
                  ),
                  const SizedBox(height: AppTheme.spacingXs),
                  SizedBox(
                    width: AppTheme.storyAvatarSize + AppTheme.spacingSm,
                    child: Text(
                      story.author.displayName.split(' ').first,
                      style: theme.textTheme.labelSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
