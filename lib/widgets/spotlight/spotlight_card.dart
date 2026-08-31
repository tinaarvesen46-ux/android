import 'package:flutter/material.dart';

import '../../models/spotlight_post.dart';
import '../../theme/theme.dart';
import '../common/snap_avatar.dart';

class SpotlightCard extends StatelessWidget {
  final SpotlightPost post;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onCreatorTap;
  final VoidCallback? onMore;

  const SpotlightCard({
    super.key,
    required this.post,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onCreatorTap,
    this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;
    final screenSize = MediaQuery.sizeOf(context);
    final insets = MediaQuery.paddingOf(context);

    return SizedBox(
      width: screenSize.width,
      height: screenSize.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _ReelMedia(post: post),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: screenSize.height * 0.35,
            child: DecoratedBox(
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
            ),
          ),
          Positioned(
            right: AppTheme.spacingMd,
            bottom: insets.bottom + AppTheme.spacingHuge * 3,
            child: Column(
              children: [
                _ActionButton(
                  icon: post.isLiked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  label: _formatCount(post.likeCount),
                  color: post.isLiked ? appColors.danger : appColors.onMedia,
                  onTap: onLike,
                ),
                const SizedBox(height: AppTheme.spacingXl),
                _ActionButton(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: _formatCount(post.commentCount),
                  onTap: onComment,
                ),
                const SizedBox(height: AppTheme.spacingXl),
                _ActionButton(
                  icon: Icons.send_rounded,
                  label: _formatCount(post.shareCount),
                  onTap: onShare,
                ),
                if (onMore != null) ...[
                  const SizedBox(height: AppTheme.spacingXl),
                  _ActionButton(icon: Icons.more_horiz_rounded, onTap: onMore),
                ],
              ],
            ),
          ),
          Positioned(
            left: AppTheme.spacingLg,
            right: AppTheme.spacingHuge * 2,
            bottom: insets.bottom + AppTheme.spacingXl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: onCreatorTap,
                  child: Row(
                    children: [
                      SnapAvatar(
                        imageUrl: post.creator.avatarUrl,
                        fallbackText: post.creator.displayName,
                        size: AppTheme.avatarSm,
                      ),
                      const SizedBox(width: AppTheme.spacingSm),
                      Expanded(
                        child: Text(
                          post.creator.displayName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: appColors.onMedia,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                if (post.caption != null) ...[
                  const SizedBox(height: AppTheme.spacingSm),
                  Text(
                    post.caption!,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: appColors.onMedia),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (post.hashtags.isNotEmpty) ...[
                  const SizedBox(height: AppTheme.spacingXs),
                  Text(
                    post.hashtags.map((t) => '#$t').join(' '),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: appColors.onMedia
                          .withValues(alpha: AppTheme.opacityOverlay),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '$count';
  }
}

/// Reel media. Video playback of the remote file requires the backend to serve
/// a streamable media URL; until a frame is available the poster image is used.
class _ReelMedia extends StatelessWidget {
  final SpotlightPost post;

  const _ReelMedia({required this.post});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;
    final url = post.thumbnailUrl ?? post.mediaUrl;

    if (url.isEmpty) {
      return ColoredBox(color: theme.colorScheme.surfaceContainerHighest);
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return ColoredBox(
          color: theme.colorScheme.surfaceContainerHighest,
          child: Center(
            child: SizedBox(
              width: AppTheme.iconMd,
              height: AppTheme.iconMd,
              child: CircularProgressIndicator(
                strokeWidth: AppTheme.borderThick,
                color: appColors.onMedia,
              ),
            ),
          ),
        );
      },
      errorBuilder: (context, _, __) => ColoredBox(
        color: theme.colorScheme.surfaceContainerHighest,
        child: Center(
          child: Icon(
            Icons.videocam_off_rounded,
            size: AppTheme.iconHuge,
            color: appColors.subtleText,
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String? label;
  final Color? color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    this.label,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;
    final effectiveColor = color ?? appColors.onMedia;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppTheme.iconLg, color: effectiveColor),
          if (label != null) ...[
            const SizedBox(height: AppTheme.spacingXxs),
            Text(
              label!,
              style: theme.textTheme.labelSmall?.copyWith(
                color: appColors.onMedia,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
