import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/theme.dart';
import '../models/story_model.dart';

class StoryCircle extends StatelessWidget {
  final StoryModel story;
  final VoidCallback onTap;
  
  const StoryCircle({
    super.key,
    required this.story,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final hasUnviewed = story.hasUnviewed;
    
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: hasUnviewed
                    ? SwiftSnapTheme.storyGradient
                    : LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.3),
                          Colors.white.withOpacity(0.1),
                        ],
                      ),
                boxShadow: hasUnviewed
                    ? [
                        BoxShadow(
                          color: SwiftSnapTheme.primaryPink.withOpacity(0.3),
                          blurRadius: 12,
                          spreadRadius: 0,
                        ),
                      ]
                    : null,
              ),
              padding: const EdgeInsets.all(3),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: SwiftSnapTheme.backgroundDark,
                ),
                padding: const EdgeInsets.all(2),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: story.user.avatarUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: SwiftSnapTheme.surfaceColor,
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: SwiftSnapTheme.surfaceColor,
                      child: const Icon(
                        Icons.person_rounded,
                        color: SwiftSnapTheme.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 68,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      story.user.displayName.split(' ').first,
                      style: TextStyle(
                        color: hasUnviewed
                            ? SwiftSnapTheme.textPrimary
                            : SwiftSnapTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: hasUnviewed ? FontWeight.w600 : FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (story.user.isVerified) ...[
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.verified_rounded,
                      color: SwiftSnapTheme.primaryPurple,
                      size: 12,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
