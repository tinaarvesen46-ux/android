import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../theme/theme.dart';

class SnapAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? renderUrl;
  final String fallbackText;
  final double size;
  final bool showStoryRing;
  final bool storySeen;
  final bool showOnlineIndicator;
  final bool isOnline;
  final VoidCallback? onTap;

  const SnapAvatar({
    super.key,
    this.imageUrl,
    this.renderUrl,
    required this.fallbackText,
    this.size = AppTheme.avatarMd,
    this.showStoryRing = false,
    this.storySeen = false,
    this.showOnlineIndicator = false,
    this.isOnline = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;

    final ringColor = storySeen ? appColors.storyRingSeen : appColors.storyRing;
    final ringPadding = showStoryRing ? AppTheme.storyRingWidth + AppTheme.spacingXxs : 0.0;
    final totalSize = size + (ringPadding * 2);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: totalSize,
        height: totalSize,
        child: Stack(
          children: [
            if (showStoryRing)
              Container(
                width: totalSize,
                height: totalSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: ringColor,
                    width: AppTheme.storyRingWidth,
                  ),
                ),
              ),
            Center(
              child: CircleAvatar(
                radius: size / 2,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                backgroundImage:
                  (imageUrl ?? renderUrl) != null
                      ? NetworkImage(ApiService.resolveUrl(imageUrl ?? renderUrl!))
                      : null,
                child: imageUrl == null
                    ? Text(
                        fallbackText.isNotEmpty
                            ? fallbackText[0].toUpperCase()
                            : '?',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: appColors.subtleText,
                          fontSize: size * 0.38,
                        ),
                      )
                    : null,
              ),
            ),
            if (showOnlineIndicator && isOnline)
              Positioned(
                right: ringPadding,
                bottom: ringPadding,
                child: Container(
                  width: size * 0.26,
                  height: size * 0.26,
                  decoration: BoxDecoration(
                    color: appColors.onlineGreen,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.surface,
                      width: AppTheme.borderThick,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
