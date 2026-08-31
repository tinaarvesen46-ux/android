import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/spotlight_post.dart';
import '../providers/feed_provider.dart';
import '../providers/social_provider.dart';
import '../widgets/common/async_state_view.dart';
import '../widgets/spotlight/spotlight_card.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<FeedProvider>().loadReels();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _notify(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _openActions(SpotlightPost post) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(post.isSaved
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded),
              title: Text(post.isSaved ? 'Remove from saved' : 'Save'),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                final error =
                    await context.read<FeedProvider>().toggleSave(post);
                if (error != null) _notify(error);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_rounded),
              title: const Text('View creator'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                context.push('/user/${post.creator.id}');
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: const Text('Report'),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                final error = await context.read<SocialProvider>().report(
                      type: 'reel',
                      targetId: post.id,
                      reason: 'inappropriate',
                    );
                _notify(error ?? 'Report submitted for review.');
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FeedProvider>();

    return AsyncStateView<List<SpotlightPost>>(
      state: provider.reels,
      emptyIcon: Icons.play_circle_outline_rounded,
      emptyTitle: 'No reels yet',
      emptyMessage: 'Reels published by creators you follow will appear here.',
      emptyActionLabel: 'Create a reel',
      onEmptyAction: () => context.go('/camera'),
      onRetry: provider.loadReels,
      builder: (posts) => PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return SpotlightCard(
            post: post,
            onLike: () async {
              final error = await provider.toggleLike(post);
              if (error != null) _notify(error);
            },
            onComment: () => _notify(
              'Comments require the reel comments endpoint on the backend.',
            ),
            onShare: () => _notify(
              'Sharing requires the reel share endpoint on the backend.',
            ),
            onCreatorTap: () => context.push('/user/${post.creator.id}'),
            onMore: () => _openActions(post),
          );
        },
      ),
    );
  }
}
