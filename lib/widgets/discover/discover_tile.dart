import 'package:flutter/material.dart';

import '../../models/discover_item.dart';
import '../../theme/theme.dart';

class DiscoverTile extends StatelessWidget {
  final DiscoverItem item;
  final VoidCallback? onTap;
  final bool isLarge;

  const DiscoverTile({
    super.key,
    required this.item,
    this.onTap,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          color: theme.colorScheme.surfaceContainerHighest,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (item.imageUrl.isEmpty)
              Icon(
                Icons.image_rounded,
                size: isLarge ? AppTheme.iconHuge : AppTheme.iconXl,
                color: theme.colorScheme.outline,
              )
            else
              Image.network(
                item.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, _, __) => Icon(
                  Icons.broken_image_outlined,
                  size: isLarge ? AppTheme.iconHuge : AppTheme.iconXl,
                  color: theme.colorScheme.outline,
                ),
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(AppTheme.spacingSm),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      appColors.mediaScrim.withValues(alpha: 0.0),
                      appColors.mediaScrim
                          .withValues(alpha: AppTheme.opacityOverlay),
                    ],
                    stops: const [0.0, 1.0],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.title,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: appColors.onMedia,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppTheme.spacingXxs),
                    Text(
                      item.source,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: appColors.onMedia
                            .withValues(alpha: AppTheme.opacityOverlay),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            if (item.isSponsored)
              Positioned(
                top: AppTheme.spacingSm,
                left: AppTheme.spacingSm,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingSm,
                    vertical: AppTheme.spacingXxs,
                  ),
                  decoration: BoxDecoration(
                    color: appColors.mediaScrim
                        .withValues(alpha: AppTheme.opacityHint),
                    borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                  ),
                  child: Text(
                    'AD',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: appColors.onMedia,
                      fontWeight: FontWeight.w700,
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
