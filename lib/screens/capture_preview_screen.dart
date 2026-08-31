import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_failure.dart';
import '../core/load_state.dart';
import '../models/chat.dart';
import '../models/media.dart';
import '../providers/chats_provider.dart';
import '../providers/feed_provider.dart';
import '../repositories/media_repository.dart';
import '../theme/theme.dart';
import '../widgets/camera/camera_controls.dart';
import '../widgets/common/snap_avatar.dart';

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

  Future<void> _publish(
    CaptureDestination destination, {
    String? conversationId,
  }) async {
    if (_isPublishing) return;
    setState(() => _isPublishing = true);

    final repository = context.read<MediaRepository>();
    try {
      final mediaId = await repository.uploadCapture(widget.draft);
      await repository.publish(
        destination: destination,
        mediaId: mediaId,
        caption: _caption.text.trim(),
        conversationId: conversationId,
      );
      if (!mounted) return;
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
            onPressed: () => _publish(destination, conversationId: conversationId),
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

  void _openSendTo() async {
    final chats = context.read<ChatsProvider>();
    if (chats.conversations.data == null && !chats.conversations.isLoading) {
      unawaited(chats.loadConversations());
    }
    final selected = await showModalBottomSheet<Conversation>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => const _SendToSheet(),
    );
    if (selected == null || !mounted) return;
    await _publish(CaptureDestination.sendTo, conversationId: selected.id);
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

/// Real conversation picker for "Send To" — lists the user's actual
/// conversations from [ChatsProvider] so a capture can be sent as a snap.
class _SendToSheet extends StatelessWidget {
  const _SendToSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = context.watch<ChatsProvider>().conversations;
    final insets = MediaQuery.paddingOf(context);

    Widget body;
    if (state.isLoading || state.isIdle) {
      body = const Padding(
        padding: EdgeInsets.symmetric(vertical: AppTheme.spacingXl),
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (state.hasError) {
      body = Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(state.message.isNotEmpty
                ? state.message
                : 'Could not load conversations.'),
            const SizedBox(height: AppTheme.spacingSm),
            TextButton(
              onPressed: () => context.read<ChatsProvider>().loadConversations(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    } else {
      final conversations = state.data ?? const <Conversation>[];
      if (conversations.isEmpty) {
        body = const Padding(
          padding: EdgeInsets.all(AppTheme.spacingXl),
          child: Center(child: Text('Add friends to send snaps to them.')),
        );
      } else {
        body = ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.6,
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              return ListTile(
                leading: SnapAvatar(
                  imageUrl: conversation.participant.avatarUrl,
                  fallbackText: conversation.participant.displayName,
                  size: AppTheme.avatarSm,
                ),
                title: Text(conversation.isGroup
                    ? (conversation.groupName ??
                        conversation.participant.displayName)
                    : conversation.participant.displayName),
                onTap: () => Navigator.of(context).pop(conversation),
              );
            },
          ),
        );
      }
    }

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: insets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              child: Text('Send To', style: theme.textTheme.titleMedium),
            ),
            body,
            const SizedBox(height: AppTheme.spacingSm),
          ],
        ),
      ),
    );
  }
}
