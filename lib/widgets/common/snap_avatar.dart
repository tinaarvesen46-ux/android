import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
                child: ClipOval(
                  child: _AvatarImage(
                    imageUrl: imageUrl,
                    renderUrl: renderUrl,
                    fallbackText: fallbackText,
                    size: size,
                    fallbackColor: appColors.subtleText,
                  ),
                ),
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

/// Avatar renders are SVG documents while uploaded avatars are normally
/// raster images. Keeping this distinction here makes every profile, chat,
/// story and search avatar use the same decoding and fallback behavior.
class _AvatarImage extends StatelessWidget {
  final String? imageUrl;
  final String? renderUrl;
  final String fallbackText;
  final double size;
  final Color fallbackColor;

  const _AvatarImage({
    required this.imageUrl,
    required this.renderUrl,
    required this.fallbackText,
    required this.size,
    required this.fallbackColor,
  });

  Widget _fallback(BuildContext context) => Center(
        child: Text(
          fallbackText.isNotEmpty ? fallbackText[0].toUpperCase() : '?',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: fallbackColor,
                fontSize: size * 0.38,
              ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (renderUrl != null && renderUrl!.trim().isNotEmpty) {
      return SvgPicture.network(
        ApiService.resolveUrl(renderUrl!),
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholderBuilder: (_) => _fallback(context),
        errorBuilder: (_, __, ___) => _fallback(context),
      );
    }
    if (imageUrl != null && imageUrl!.trim().isNotEmpty) {
      return Image.network(
        ApiService.resolveUrl(imageUrl!),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(context),
      );
    }
    return SizedBox(width: size, height: size, child: _fallback(context));
  }
}
