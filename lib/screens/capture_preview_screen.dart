import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_failure.dart';
import '../models/media.dart';
import '../repositories/media_repository.dart';
import '../theme/theme.dart';
import '../widgets/camera/camera_controls.dart';

/// Preview shown after a capture. Nothing is ever published automatically —
/// the user must explicitly pick a destination.
class CapturePreviewScreen extends StatefulWidget {
  final CaptureDraft draft;

  const CapturePreviewScreen({super.key, required this.draft});

  @override
  State<CapturePreviewScreen> createState() => _CapturePreviewScreenState();
}

class _CapturePreviewScreenState extends State<CapturePreviewScreen> {
  final TextEditingController _caption = TextEditingController();
  bool _isPublishing = false;

  @override
  void dispose() {
    _caption.dispose();
    super.dispose();
  }

  Future<void> _publish(CaptureDestination destination) async {
    if (_isPublishing) return;
    setState(() => _isPublishing = true);

    final repository = context.read<MediaRepository>();
    try {
      final mediaId = await repository.uploadCapture(widget.draft);
      await repository.publish(destination: destination, mediaId: mediaId);
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
            onPressed: () => _publish(destination),
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

  void _openSendTo() {
    // Sending to a specific conversation happens from the chat composer,
    // which owns the conversation id.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Open a chat and use the composer camera to send this capture.',
        ),
      ),
    );
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
          _MediaPreview(draft: widget.draft),
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
                if (_isPublishing)
                  SizedBox(
                    width: AppTheme.iconMd,
                    height: AppTheme.iconMd,
                    child: CircularProgressIndicator(
                      strokeWidth: AppTheme.borderThick,
                      color: appColors.onMedia,
                    ),
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
              onStory: () => _publish(CaptureDestination.story),
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

class _MediaPreview extends StatelessWidget {
  final CaptureDraft draft;

  const _MediaPreview({required this.draft});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;

    if (draft.isVideo) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.videocam_rounded,
              size: AppTheme.iconHuge,
              color: appColors.onMedia,
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              'Video ready to publish',
              style:
                  theme.textTheme.bodyMedium?.copyWith(color: appColors.onMedia),
            ),
          ],
        ),
      );
    }

    final image = kIsWeb
        ? Image.network(draft.path, fit: BoxFit.contain)
        : Image.file(File(draft.path), fit: BoxFit.contain);

    // The front camera preview is mirrored, so the saved file is un-mirrored
    // back to match what the user actually saw while framing the shot.
    return Center(
      child: draft.isFrontCamera
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
