import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../core/api_failure.dart';
import '../models/media.dart';
import '../models/user.dart';
import '../providers/chats_provider.dart';
import '../providers/feed_provider.dart';
import '../repositories/media_repository.dart';
import '../theme/theme.dart';
import '../widgets/camera/camera_controls.dart';
import '../widgets/chats/friend_picker_sheet.dart';

/// A single draggable text overlay added by the user in the preview/editing
/// step. `position` is fractional (0..1) within the media area so it stays
/// correctly placed regardless of screen size.
class _TextOverlay {
  String text;
  Offset position;
  _TextOverlay({required this.text, required this.position});
}

/// Preview shown after a capture. Nothing is ever published automatically —
/// the user must explicitly edit (optional) and pick a destination.
class CapturePreviewScreen extends StatefulWidget {
  final CaptureDraft draft;

  const CapturePreviewScreen({super.key, required this.draft});

  @override
  State<CapturePreviewScreen> createState() => _CapturePreviewScreenState();
}

class _CapturePreviewScreenState extends State<CapturePreviewScreen> {
  final TextEditingController _caption = TextEditingController();
  final GlobalKey _compositeKey = GlobalKey();
  final List<_TextOverlay> _textOverlays = [];
  bool _isPublishing = false;

  @override
  void dispose() {
    _caption.dispose();
    super.dispose();
  }

  Future<void> _addOrEditText([_TextOverlay? existing]) async {
    final controller = TextEditingController(text: existing?.text ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(existing == null ? 'Add text' : 'Edit text'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 80,
          decoration: const InputDecoration(hintText: 'Say something...'),
        ),
        actions: [
          if (existing != null)
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop('__delete__'),
              child: Text('Remove',
                  style: TextStyle(
                      color: Theme.of(dialogContext).colorScheme.error)),
            ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(controller.text.trim()),
            child: Text(existing == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      if (result == '__delete__') {
        if (existing != null) _textOverlays.remove(existing);
      } else if (result.isNotEmpty) {
        if (existing != null) {
          existing.text = result;
        } else {
          _textOverlays.add(
            _TextOverlay(text: result, position: const Offset(0.5, 0.45)),
          );
        }
      }
    });
  }

  /// Bakes the current text overlays into the actual captured photo so the
  /// published media matches exactly what the user saw while editing. Only
  /// used for photos with at least one overlay — a plain capture with no
  /// edits is always uploaded untouched at its original resolution.
  Future<String> _resolveUploadPath() async {
    if (widget.draft.isVideo || _textOverlays.isEmpty) return widget.draft.path;
    final boundary =
        _compositeKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return widget.draft.path;
    final image = await boundary.toImage(pixelRatio: 2.0);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) return widget.draft.path;
    final out = File(
      '${widget.draft.path}_edited_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await out.writeAsBytes(bytes.buffer.asUint8List(
      bytes.offsetInBytes,
      bytes.lengthInBytes,
    ));
    return out.path;
  }

  Future<void> _publish(
    CaptureDestination destination, {
    List<String>? friendIds,
    String? storyAudience,
  }) async {
    if (_isPublishing) return;
    setState(() => _isPublishing = true);

    final repository = context.read<MediaRepository>();
    try {
      final uploadDraft = CaptureDraft(
        path: await _resolveUploadPath(),
        isVideo: widget.draft.isVideo,
        isFrontCamera: widget.draft.isFrontCamera,
      );
      final mediaId = await repository.uploadCapture(uploadDraft);

      if (destination == CaptureDestination.sendTo) {
        final chats = context.read<ChatsProvider>();
        var anySucceeded = false;
        String? lastError;
        for (final friendId in friendIds ?? const <String>[]) {
          final conversationId = await chats.startConversationWith(friendId);
          if (conversationId == null) {
            lastError = chats.lastError;
            continue;
          }
          try {
            await repository.publish(
              destination: destination,
              mediaId: mediaId,
              conversationId: conversationId,
            );
            anySucceeded = true;
          } on ApiFailure catch (e) {
            lastError = e.message;
          }
        }
        if (!anySucceeded) {
          throw ApiFailure(lastError ?? 'Could not send to the selected friends.');
        }
        unawaited(chats.loadConversations());
      } else {
        await repository.publish(
          destination: destination,
          mediaId: mediaId,
          caption: _caption.text.trim(),
          storyAudience: storyAudience,
        );
        // The Chats/Reels tabs stay mounted in the shell's IndexedStack, so a
        // fresh capture never triggers their initState — refresh the shared
        // provider here so those tabs show the new content immediately.
        switch (destination) {
          case CaptureDestination.story:
            unawaited(context.read<ChatsProvider>().loadStories());
            break;
          case CaptureDestination.reels:
            unawaited(context.read<FeedProvider>().loadReels());
            break;
          case CaptureDestination.memories:
          case CaptureDestination.sendTo:
            break;
        }
      }

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_successMessage(destination))),
      );
    } on ApiFailure catch (e) {
      if (!mounted) return;
      setState(() => _isPublishing = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(e.message),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () => _publish(
              destination,
              friendIds: friendIds,
              storyAudience: storyAudience,
            ),
          ),
        ));
    }
  }

  String _successMessage(CaptureDestination destination) {
    switch (destination) {
      case CaptureDestination.story:
        return 'Added to your story.';
      case CaptureDestination.reels:
        return 'Published to Reels.';
      case CaptureDestination.memories:
        return 'Saved to Memories.';
      case CaptureDestination.sendTo:
        return 'Sent.';
    }
  }

  Future<void> _openSendTo() async {
    final selected = await showModalBottomSheet<List<User>>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) =>
          const FriendPickerSheet(multiSelect: true, title: 'Send To'),
    );
    if (selected == null || selected.isEmpty || !mounted) return;
    await _publish(
      CaptureDestination.sendTo,
      friendIds: selected.map((u) => u.id).toList(),
    );
  }

  Future<void> _openStoryAudiencePicker() async {
    final audience = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(AppTheme.spacingLg),
              child: Text('Post to'),
            ),
            ListTile(
              leading: const Icon(Icons.group_rounded),
              title: const Text('My Story — Friends'),
              subtitle: const Text('Visible to your friends'),
              onTap: () => Navigator.of(sheetContext).pop('friends'),
            ),
            ListTile(
              leading: const Icon(Icons.public_rounded),
              title: const Text('My Public Story'),
              subtitle: const Text('Visible to everyone'),
              onTap: () => Navigator.of(sheetContext).pop('public'),
            ),
            const SizedBox(height: AppTheme.spacingSm),
          ],
        ),
      ),
    );
    if (audience == null || !mounted) return;
    await _publish(CaptureDestination.story, storyAudience: audience);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;
    final insets = MediaQuery.paddingOf(context);

    return Scaffold(
      backgroundColor: appColors.mediaScrim,
      body: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            key: _compositeKey,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _MediaPreview(draft: widget.draft),
                ..._textOverlays.map((overlay) => _DraggableTextOverlay(
                      key: ObjectKey(overlay),
                      overlay: overlay,
                      onTap: () => _addOrEditText(overlay),
                      onDrag: (delta) => setState(() {
                        final size = MediaQuery.sizeOf(context);
                        overlay.position = Offset(
                          (overlay.position.dx + delta.dx / size.width)
                              .clamp(0.05, 0.95),
                          (overlay.position.dy + delta.dy / size.height)
                              .clamp(0.05, 0.95),
                        );
                      }),
                    )),
              ],
            ),
          ),
          Positioned(
            top: insets.top + AppTheme.spacingSm,
            left: AppTheme.spacingMd,
            right: AppTheme.spacingMd,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CameraOverlayButton(
                  icon: Icons.close_rounded,
                  semanticLabel: 'Retake',
                  onTap: () => Navigator.of(context).maybePop(),
                ),
                Row(
                  children: [
                    if (!widget.draft.isVideo)
                      CameraOverlayButton(
                        icon: Icons.text_fields_rounded,
                        semanticLabel: 'Add text',
                        onTap: () => _addOrEditText(),
                      ),
                    if (_isPublishing) ...[
                      const SizedBox(width: AppTheme.spacingMd),
                      SizedBox(
                        width: AppTheme.iconMd,
                        height: AppTheme.iconMd,
                        child: CircularProgressIndicator(
                          strokeWidth: AppTheme.borderThick,
                          color: appColors.onMedia,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _DestinationBar(
              captionController: _caption,
              isBusy: _isPublishing,
              onStory: _openStoryAudiencePicker,
              onReels: () => _publish(CaptureDestination.reels),
              onMemories: () => _publish(CaptureDestination.memories),
              onSendTo: _openSendTo,
            ),
          ),
        ],
      ),
    );
  }
}

class _DraggableTextOverlay extends StatelessWidget {
  final _TextOverlay overlay;
  final VoidCallback onTap;
  final void Function(Offset delta) onDrag;

  const _DraggableTextOverlay({
    super.key,
    required this.overlay,
    required this.onTap,
    required this.onDrag,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Positioned(
      left: overlay.position.dx * size.width - 100,
      top: overlay.position.dy * size.height - 20,
      width: 200,
      child: GestureDetector(
        onTap: onTap,
        onPanUpdate: (details) => onDrag(details.delta),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMd,
            vertical: AppTheme.spacingSm,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.28),
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
          child: Text(
            overlay.text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              shadows: [Shadow(blurRadius: 6, color: Colors.black54)],
            ),
          ),
        ),
      ),
    );
  }
}

class _MediaPreview extends StatefulWidget {
  final CaptureDraft draft;

  const _MediaPreview({required this.draft});

  @override
  State<_MediaPreview> createState() => _MediaPreviewState();
}

class _MediaPreviewState extends State<_MediaPreview> {
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    if (widget.draft.isVideo && !kIsWeb) {
      final controller = VideoPlayerController.file(File(widget.draft.path));
      _videoController = controller;
      controller.initialize().then((_) {
        if (!mounted) return;
        controller.setLooping(true);
        controller.play();
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _togglePlay() {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) return;
    setState(() {
      if (controller.value.isPlaying) {
        controller.pause();
      } else {
        controller.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;

    if (widget.draft.isVideo) {
      final controller = _videoController;
      if (kIsWeb || controller == null || !controller.value.isInitialized) {
        return const Center(
          child: CircularProgressIndicator(strokeWidth: AppTheme.borderThick),
        );
      }
      return GestureDetector(
        onTap: _togglePlay,
        child: Center(
          child: AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: Stack(
              alignment: Alignment.center,
              children: [
                VideoPlayer(controller),
                if (!controller.value.isPlaying)
                  Icon(
                    Icons.play_arrow_rounded,
                    size: AppTheme.iconHuge,
                    color: appColors.onMedia.withValues(alpha: 0.85),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    final image = kIsWeb
        ? Image.network(widget.draft.path, fit: BoxFit.contain)
        : Image.file(File(widget.draft.path), fit: BoxFit.contain);

    // The front camera preview is mirrored, so the saved file is un-mirrored
    // back to match what the user actually saw while framing the shot.
    return Center(
      child: widget.draft.isFrontCamera
          ? Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()..scale(-1.0, 1.0, 1.0),
              child: image,
            )
          : image,
    );
  }
}

class _DestinationBar extends StatelessWidget {
  final TextEditingController captionController;
  final bool isBusy;
  final VoidCallback onStory;
  final VoidCallback onReels;
  final VoidCallback onMemories;
  final VoidCallback onSendTo;

  const _DestinationBar({
    required this.captionController,
    required this.isBusy,
    required this.onStory,
    required this.onReels,
    required this.onMemories,
    required this.onSendTo,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final safeBottom = MediaQuery.paddingOf(context).bottom;

    return Container(
      padding: EdgeInsets.only(
        left: AppTheme.spacingLg,
        right: AppTheme.spacingLg,
        top: AppTheme.spacingLg,
        bottom: AppTheme.spacingLg + safeBottom + bottomInset,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            appColors.mediaScrim.withValues(alpha: 0.0),
            appColors.mediaScrim.withValues(alpha: AppTheme.opacityOverlay),
          ],
          stops: const [0.0, 1.0],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: captionController,
            enabled: !isBusy,
            style: theme.textTheme.bodyMedium,
            decoration: const InputDecoration(hintText: 'Add a caption'),
            maxLength: 200,
            buildCounter: (_,
                    {required currentLength,
                    required isFocused,
                    required maxLength}) =>
                null,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _DestinationChip(
                  icon: Icons.auto_stories_rounded,
                  label: 'My Story',
                  onTap: isBusy ? null : onStory,
                ),
                _DestinationChip(
                  icon: Icons.send_rounded,
                  label: 'Send To',
                  onTap: isBusy ? null : onSendTo,
                ),
                _DestinationChip(
                  icon: Icons.play_circle_fill_rounded,
                  label: 'Reels',
                  onTap: isBusy ? null : onReels,
                ),
                _DestinationChip(
                  icon: Icons.bookmark_rounded,
                  label: 'Memories',
                  onTap: isBusy ? null : onMemories,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DestinationChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _DestinationChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;
    final enabled = onTap != null;

    return Padding(
      padding: const EdgeInsets.only(right: AppTheme.spacingSm),
      child: GestureDetector(
        onTap: onTap,
        child: Opacity(
          opacity: enabled ? 1 : AppTheme.opacityDisabled,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingLg,
              vertical: AppTheme.spacingSm,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: AppTheme.iconSm, color: appColors.onMedia),
                const SizedBox(width: AppTheme.spacingSm),
                Text(
                  label,
                  style: theme.textTheme.labelMedium
                      ?.copyWith(color: appColors.onMedia),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
