import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../theme/theme.dart';
import '../providers/app_provider.dart';
import '../widgets/selected_friend_picker.dart';
import 'camera_first_screen.dart';

/// CapturePreviewScreen — Snapchat-style "send to" step shown AFTER a snap.
/// The user reviews the photo/video and explicitly chooses a destination
/// (My Story or one/more friends). Nothing is posted automatically.
class CapturePreviewScreen extends StatefulWidget {
  final CameraResult result;
  const CapturePreviewScreen({super.key, required this.result});

  @override
  State<CapturePreviewScreen> createState() => _CapturePreviewScreenState();
}

class _CapturePreviewScreenState extends State<CapturePreviewScreen> {
  VideoPlayerController? _video;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    if (widget.result.isVideo) {
      _video = VideoPlayerController.file(widget.result.file)
        ..initialize().then((_) {
          if (mounted) {
            setState(() {});
            _video?.setLooping(true);
            _video?.play();
          }
        });
    }
  }

  @override
  void dispose() {
    _video?.dispose();
    super.dispose();
  }

  Future<void> _postStory() async {
    if (_busy) return;
    setState(() => _busy = true);
    HapticFeedback.mediumImpact();
    final err = await context
        .read<AppProvider>()
        .publishStoryFromFile(widget.result.file.path, isVideo: widget.result.isVideo);
    if (!mounted) return;
    setState(() => _busy = false);
    _finish(err, success: 'Posted to your story!');
  }

  Future<void> _sendToFriends() async {
    if (_busy) return;
    final ids = await SelectedFriendPicker.show(context);
    if (ids == null || ids.isEmpty || !mounted) return;
    setState(() => _busy = true);
    HapticFeedback.mediumImpact();
    final err = await context
        .read<AppProvider>()
        .sendCapturedMediaToFriends(ids, widget.result.file.path, isVideo: widget.result.isVideo);
    if (!mounted) return;
    setState(() => _busy = false);
    _finish(err, success: 'Sent to ${ids.length} ${ids.length == 1 ? 'friend' : 'friends'}!');
  }

  void _finish(String? err, {required String success}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(err ?? success)),
    );
    if (err == null) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Media preview
          if (widget.result.isVideo)
            (_video != null && _video!.value.isInitialized)
                ? FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _video!.value.size.width,
                      height: _video!.value.size.height,
                      child: VideoPlayer(_video!),
                    ),
                  )
                : const Center(child: CircularProgressIndicator(color: Colors.white))
          else
            Image.file(widget.result.file, fit: BoxFit.cover),

          // Close
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white, size: 30),
              onPressed: _busy ? null : () => Navigator.pop(context),
            ),
          ),

          if (_busy)
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0x66000000),
                child: Center(child: CircularProgressIndicator(color: Colors.white)),
              ),
            ),

          // Destination actions
          Positioned(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).padding.bottom + 24,
            child: Row(
              children: [
                Expanded(
                  child: _DestButton(
                    icon: Icons.amp_stories_rounded,
                    label: 'My Story',
                    onTap: _busy ? null : _postStory,
                    testId: 'capture-post-story',
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _DestButton(
                    icon: Icons.send_rounded,
                    label: 'Send To',
                    primary: true,
                    onTap: _busy ? null : _sendToFriends,
                    testId: 'capture-send-to',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DestButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool primary;
  final VoidCallback? onTap;
  final String testId;
  const _DestButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.testId,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: Key(testId),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: primary ? SwiftSnapTheme.primaryGradient : null,
          color: primary ? null : Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withOpacity(0.6)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
