import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/discover_item.dart';
import '../providers/feed_provider.dart';
import '../theme/theme.dart';
import '../widgets/common/app_top_bar.dart';
import '../widgets/common/async_state_view.dart';
import '../widgets/common/snap_icon_button.dart';
import '../widgets/discover/discover_category_bar.dart';
import '../widgets/discover/discover_tile.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final feed = context.read<FeedProvider>();
      feed.loadCategories();
      feed.loadDiscover();
    });
  }

  @override
  Widget build(BuildContext context) {
    final feed = context.watch<FeedProvider>();

    return Column(
      children: [
        AppTopBar(
          title: 'Discover',
          actions: [
            SnapIconButton(
              icon: Icons.search_rounded,
              onTap: () => context.push('/search'),
            ),
            SnapIconButton(
              icon: Icons.person_outline_rounded,
              onTap: () => context.push('/profile'),
            ),
          ],
        ),
        DiscoverCategoryBar(
          state: feed.categories,
          activeCategoryId: feed.activeCategoryId,
          onSelect: (id) => feed.loadDiscover(categoryId: id),
          onRetry: feed.loadCategories,
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () =>
                feed.loadDiscover(categoryId: feed.activeCategoryId),
            child: AsyncStateView<List<DiscoverItem>>(
              state: feed.discover,
              emptyIcon: Icons.explore_outlined,
              emptyTitle: 'Nothing to discover yet',
              emptyMessage:
                  'Published Discover content will appear here once it is available.',
              onRetry: () =>
                  feed.loadDiscover(categoryId: feed.activeCategoryId),
              builder: (items) => GridView.builder(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                gridDelegate:
                    const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 220,
                  mainAxisSpacing: AppTheme.spacingMd,
                  crossAxisSpacing: AppTheme.spacingMd,
                  childAspectRatio: 0.72,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) => DiscoverTile(
                  item: items[index],
                  onTap: () =>
                      context.push('/article/${items[index].id}',
                          extra: items[index]),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
