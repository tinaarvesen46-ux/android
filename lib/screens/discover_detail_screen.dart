import 'package:flutter/material.dart';

import '../models/discover_item.dart';
import '../theme/theme.dart';
import '../widgets/common/app_top_bar.dart';

class DiscoverDetailScreen extends StatelessWidget {
  final DiscoverItem item;

  const DiscoverDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;

    return Scaffold(
      body: Column(
        children: [
          const AppTopBar(showBack: true, title: 'Discover'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    child: Image.network(
                      item.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, _, __) => Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.image_not_supported_rounded,
                          size: AppTheme.iconXl,
                          color: appColors.subtleText,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingLg),
                Text(item.title, style: theme.textTheme.headlineSmall),
                const SizedBox(height: AppTheme.spacingSm),
                Text(
                  '${item.source} · ${item.category}',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: appColors.subtleText),
                ),
                if (item.subtitle != null) ...[
                  const SizedBox(height: AppTheme.spacingLg),
                  Text(item.subtitle!, style: theme.textTheme.bodyLarge),
                ],
                const SizedBox(height: AppTheme.spacingXl),
                Text(
                  'Full article content is served by the Discover content endpoint on the backend.',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: appColors.subtleText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
