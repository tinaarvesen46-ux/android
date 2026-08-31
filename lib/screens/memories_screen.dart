import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/media.dart';
import '../providers/memories_provider.dart';
import '../theme/theme.dart';
import '../widgets/common/app_top_bar.dart';
import '../widgets/common/async_state_view.dart';

class MemoriesScreen extends StatefulWidget {
  const MemoriesScreen({super.key});

  @override
  State<MemoriesScreen> createState() => _MemoriesScreenState();
}

class _MemoriesScreenState extends State<MemoriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<MemoriesProvider>().load();
    });
  }

  void _openActions(MemoryItem item) {
    final provider = context.read<MemoriesProvider>();
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(item.isFavorite
                  ? Icons.star_rounded
                  : Icons.star_border_rounded),
              title: Text(
                  item.isFavorite ? 'Remove from favourites' : 'Add to favourites'),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                final error = await provider.toggleFavorite(item.id);
                if (error != null && mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(error)));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded),
              title: const Text('Delete'),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                final error = await provider.delete(item.id);
                if (error != null && mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(error)));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;
    final provider = context.watch<MemoriesProvider>();

    return Scaffold(
      body: Column(
        children: [
          const AppTopBar(showBack: true, title: 'Memories'),
          Expanded(
            child: AsyncStateView<List<MemoryItem>>(
              state: provider.memories,
              emptyIcon: Icons.bookmark_border_rounded,
              emptyTitle: 'No memories saved',
              emptyMessage:
                  'Captures you save to Memories will be archived here.',
              onRetry: () => provider.load(kind: provider.activeKind),
              builder: (items) => GridView.builder(
                padding: const EdgeInsets.all(AppTheme.spacingSm),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 160,
                  mainAxisSpacing: AppTheme.spacingSm,
                  crossAxisSpacing: AppTheme.spacingSm,
                  childAspectRatio: 0.72,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return GestureDetector(
                    onLongPress: () => _openActions(item),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            item.thumbnailUrl ?? item.mediaUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, _, __) => Container(
                              color: theme.colorScheme.surfaceContainerHighest,
                              child: Icon(
                                Icons.broken_image_outlined,
                                color: appColors.subtleText,
                              ),
                            ),
                          ),
                          if (item.isVideo)
                            Positioned(
                              right: AppTheme.spacingXs,
                              top: AppTheme.spacingXs,
                              child: Icon(
                                Icons.play_circle_fill_rounded,
                                size: AppTheme.iconSm,
                                color: appColors.onMedia,
                              ),
                            ),
                        ],
                      ),
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
