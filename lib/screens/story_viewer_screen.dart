import 'dart:async';

import 'package:flutter/material.dart';

import '../models/story.dart';
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
