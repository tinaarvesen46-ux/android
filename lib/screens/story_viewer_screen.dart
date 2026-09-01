import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/story.dart';
import '../models/story_comment.dart';
import '../providers/chats_provider.dart';
import '../theme/theme.dart';
import '../widgets/common/snap_avatar.dart';

class StoryViewerScreen extends StatefulWidget {
  final Story story;

  const StoryViewerScreen({super.key, required this.story});

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen> {
  int _index = 0;
  double _progress = 0;
  Timer? _timer;
  bool _paused = false;

  static const Duration _tick = Duration(milliseconds: 50);

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  StoryItem? get _current =>
      _index < widget.story.items.length ? widget.story.items[_index] : null;

  void _start() {
    _timer?.cancel();
    _progress = 0;
    final item = _current;
    if (item == null) return;
    final total = item.duration.inMilliseconds;
    _timer = Timer.periodic(_tick, (_) {
      if (!mounted || _paused) return;
      setState(() => _progress += _tick.inMilliseconds / total);
      if (_progress >= 1) _next();
    });
  }

  void _next() {
    if (_index + 1 >= widget.story.items.length) {
      Navigator.of(context).maybePop();
      return;
    }
    setState(() => _index++);
    _start();
  }

  void _previous() {
    if (_index == 0) {
      _start();
      return;
    }
    setState(() => _index--);
    _start();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;
    final item = _current;
    final width = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: appColors.mediaScrim,
      body: GestureDetector(
        onTapUp: (details) {
          if (details.localPosition.dx < width / 3) {
            _previous();
          } else {
            _next();
          }
        },
        onLongPressStart: (_) => setState(() => _paused = true),
        onLongPressEnd: (_) => setState(() => _paused = false),
        onVerticalDragEnd: (details) {
          if ((details.primaryVelocity ?? 0) > 200) {
            Navigator.of(context).maybePop();
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (item != null)
              Image.network(
                item.mediaUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, _, __) => Center(
                  child: Text(
                    'This story could not be loaded.',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: appColors.onMedia),
                  ),
                ),
              ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                child: Column(
                  children: [
                    Row(
                      children: List.generate(
                        widget.story.items.length,
                        (i) => Expanded(
                          child: Container(
                            height: AppTheme.spacingXs,
                            margin: const EdgeInsets.symmetric(
                                horizontal: AppTheme.spacingXxs),
                            decoration: BoxDecoration(
                              color: appColors.onMedia
                                  .withValues(alpha: AppTheme.opacitySubtle),
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusFull),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: i < _index
                                  ? 1
                                  : (i == _index
                                      ? _progress.clamp(0.0, 1.0)
                                      : 0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: appColors.onMedia,
                                  borderRadius: BorderRadius.circular(
                                      AppTheme.radiusFull),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                    Row(
                      children: [
                        SnapAvatar(
                          imageUrl: widget.story.author.avatarUrl,
                          fallbackText: widget.story.author.displayName,
                          size: AppTheme.avatarSm,
                        ),
                        const SizedBox(width: AppTheme.spacingSm),
                        Expanded(
                          child: Text(
                            widget.story.author.displayName,
                            style: theme.textTheme.titleSmall
                                ?.copyWith(color: appColors.onMedia),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.emoji_emotions_outlined,
                              color: appColors.onMedia),
                          tooltip: 'React',
                          onPressed: () {
                            final item = _current;
                            if (item == null) return;
                            showModalBottomSheet(
                              context: context,
                              builder: (ctx) => SafeArea(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: ['❤️', '🔥', '👍', '😂', '😮']
                                      .map((e) => IconButton(
                                            icon: Text(e, style: const TextStyle(fontSize: 24)),
                                            onPressed: () async {
                                              Navigator.of(ctx).maybePop();
                                              final err = await context.read<ChatsProvider>().sendStoryReaction(
                                                    storyItemId: item.id,
                                                    reaction: e,
                                                  );
                                              if (err != null) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
                                            },
                                          ))
                                      .toList(),
                                ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.close_rounded,
                              color: appColors.onMedia),
                          tooltip: 'Close',
                          onPressed: () => Navigator.of(context).maybePop(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

void showStoryCommentsSheet(BuildContext context, String storyItemId) async {
  final provider = context.read<ChatsProvider>();
  await provider.loadStoryReplies(storyItemId);
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Expanded(
              child: Consumer<ChatsProvider>(
                builder: (c, prov, _) {
                  final state = prov.storyRepliesFor(storyItemId);
                  if (state.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.isError) {
                    return Center(child: Text(state.error ?? 'Failed to load'));
                  }
                   final list = state.data ?? const <StoryComment>[];
                  if (list.isEmpty) {
                    return const Center(child: Text('No comments yet'));
                  }
                  return ListView.builder(
                    controller: scrollController,
                    itemCount: list.length,
                    itemBuilder: (context, i) {
                       final cmt = list[i];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: cmt.author.avatarUrl != null
                              ? NetworkImage(cmt.author.avatarUrl!)
                              : null,
                          child: cmt.author.avatarUrl == null
                              ? Text(cmt.author.displayName.isNotEmpty
                                  ? cmt.author.displayName[0]
                                  : '?')
                              : null,
                        ),
                        title: Text(cmt.author.displayName),
                        subtitle: Text(cmt.content),
                        trailing: Text(
                          '${timeAgo(cmt.createdAt)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            _CommentInput(storyItemId: storyItemId),
          ],
        ),
      ),
    ),
  );
}

String timeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inSeconds < 60) return '${diff.inSeconds}s';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}h';
  return '${diff.inDays}d';
}

class _CommentInput extends StatefulWidget {
  final String storyItemId;

  const _CommentInput({required this.storyItemId});

  @override
  State<_CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<_CommentInput> {
  final _ctrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                decoration: const InputDecoration(hintText: 'Write a comment...'),
                minLines: 1,
                maxLines: 4,
              ),
            ),
            const SizedBox(width: 8),
            _loading
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator())
                : IconButton(
                    icon: const Icon(Icons.send_rounded),
                    onPressed: () async {
                      final text = _ctrl.text.trim();
                      if (text.isEmpty) return;
                      setState(() => _loading = true);
                      final res = await context.read<ChatsProvider>().sendStoryReply(
                            storyItemId: widget.storyItemId,
                            content: text,
                          );
                      setState(() => _loading = false);
                      if (res != null) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res)));
                      } else {
                        _ctrl.clear();
                        // reload to get fresh comment with id/timestamp
                        await context.read<ChatsProvider>().loadStoryReplies(widget.storyItemId);
                      }
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
