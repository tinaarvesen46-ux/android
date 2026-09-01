import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../models/media.dart';
import '../providers/memories_provider.dart';
import '../theme/theme.dart';
import '../widgets/common/async_state_view.dart';
import '../widgets/camera/camera_controls.dart';
import '../widgets/camera/camera_permission_view.dart';

enum CameraReadiness { initialising, ready, denied, permanentlyDenied, failed }

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
  with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  CameraController? _controller;
  List<CameraDescription> _cameras = const [];
  int _cameraIndex = 0;

  CameraReadiness _readiness = CameraReadiness.initialising;
  String _failureMessage = '';

  bool _isRecording = false;
  bool _isCapturing = false;
  FlashMode _flashMode = FlashMode.auto;

  double _minZoom = 1;
  double _maxZoom = 1;
  double _zoom = 1;
  double _baseZoom = 1;

  Timer? _recordTimer;
  Duration _recordDuration = Duration.zero;
  // Interactive Memories panel state
  late AnimationController _panelController;
  double _panelDragLastY = 0.0;
  bool _isScaling = false;
  bool _panelOpen = false;
  int _controllerGeneration = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _panelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );
    _bootstrap();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _recordTimer?.cancel();
    _controller?.dispose();
    _panelController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _controllerGeneration++;
      _recordTimer?.cancel();
      final old = _controller;
      _controller = null;
      _panelOpen = false;
      _panelController.value = 0.0;
      if (mounted) setState(() => _isRecording = false);
      unawaited(old?.dispose() ?? Future<void>.value());
    } else if (state == AppLifecycleState.resumed) {
      _bootstrap();
    }
  }

  Future<void> _bootstrap() async {
    if (!mounted) return;
    setState(() {
      _readiness = CameraReadiness.initialising;
      _failureMessage = '';
    });

    if (!kIsWeb) {
      final camera = await Permission.camera.request();
      if (camera.isPermanentlyDenied) {
        if (mounted) {
          setState(() => _readiness = CameraReadiness.permanentlyDenied);
        }
        return;
      }
      if (!camera.isGranted) {
        if (mounted) setState(() => _readiness = CameraReadiness.denied);
        return;
      }
      // Audio is required for video capture; a denial only removes sound.
      await Permission.microphone.request();
    }

    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        if (mounted) {
          setState(() {
            _readiness = CameraReadiness.failed;
            _failureMessage = 'No camera is available on this device.';
          });
        }
        return;
      }
      await _startController(_cameraIndex.clamp(0, _cameras.length - 1));
    } on CameraException catch (e) {
      if (mounted) {
        setState(() {
          _readiness = CameraReadiness.failed;
          _failureMessage = e.description ?? 'The camera could not be started.';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _readiness = CameraReadiness.failed;
          _failureMessage = 'The camera could not be started.';
        });
      }
    }
  }

  Future<void> _maybePausePreview() async {
    try {
      await _controller?.pausePreview();
    } catch (_) {}
  }

  Future<void> _maybeResumePreview() async {
    try {
      await _controller?.resumePreview();
    } catch (_) {}
  }

  Future<void> _startController(int index) async {
    final generation = ++_controllerGeneration;
    final previous = _controller;
    _controller = null;
    await previous?.dispose();

    final controller = CameraController(
      _cameras[index],
      ResolutionPreset.high,
      enableAudio: true,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await controller.initialize();
      _minZoom = await controller.getMinZoomLevel();
      _maxZoom = await controller.getMaxZoomLevel();
      await controller.setFlashMode(_flashMode);
    } on CameraException catch (e) {
      await controller.dispose();
      if (mounted) {
        setState(() {
          _readiness = CameraReadiness.failed;
          _failureMessage = e.description ?? 'The camera could not be started.';
        });
      }
      return;
    }

    if (!mounted || generation != _controllerGeneration) {
      await controller.dispose();
      return;
    }

    setState(() {
      _controller = controller;
      _cameraIndex = index;
      _zoom = _minZoom;
      _readiness = CameraReadiness.ready;
    });
  }

  bool get _isFrontCamera =>
      _cameras.isNotEmpty &&
      _cameras[_cameraIndex].lensDirection == CameraLensDirection.front;

  Future<void> _switchCamera() async {
    if (_cameras.length < 2 || _isRecording) return;
    HapticFeedback.selectionClick();
    await _startController((_cameraIndex + 1) % _cameras.length);
  }

  Future<void> _cycleFlash() async {
    const order = [FlashMode.auto, FlashMode.always, FlashMode.off];
    final next = order[(order.indexOf(_flashMode) + 1) % order.length];
    try {
      await _controller?.setFlashMode(next);
      if (mounted) setState(() => _flashMode = next);
    } on CameraException {
      _notify('Flash is not available on this camera.');
    }
  }

  Future<void> _setZoom(double value) async {
    final clamped = value.clamp(_minZoom, _maxZoom).toDouble();
    if ((clamped - _zoom).abs() < 0.01) return;
    try {
      await _controller?.setZoomLevel(clamped);
      if (mounted) setState(() => _zoom = clamped);
    } on CameraException {
      // Zoom is unsupported on this sensor.
    } catch (_) {
      // The controller may have been replaced during an async camera call.
    }
  }

  Future<void> _focusAt(Offset relative) async {
    final controller = _controller;
    if (controller == null) return;
    try {
      await controller.setFocusPoint(relative);
      await controller.setExposurePoint(relative);
      HapticFeedback.selectionClick();
    } on CameraException {
      // Tap-to-focus unsupported on this sensor.
    }
  }

  Future<void> _capturePhoto() async {
    final controller = _controller;
    if (controller == null || _isCapturing || _isRecording) return;

    setState(() => _isCapturing = true);
    HapticFeedback.mediumImpact();
    try {
      final file = await controller.takePicture();
      _openPreview(CaptureDraft(
        path: file.path,
        isVideo: false,
        isFrontCamera: _isFrontCamera,
      ));
    } on CameraException catch (e) {
      _notify(e.description ?? 'The photo could not be captured.');
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  Future<void> _startRecording() async {
    final controller = _controller;
    if (controller == null || _isRecording) return;
    try {
      await controller.startVideoRecording();
      HapticFeedback.heavyImpact();
      if (!mounted) return;
      setState(() {
        _isRecording = true;
        _recordDuration = Duration.zero;
      });
      _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() =>
            _recordDuration = _recordDuration + const Duration(seconds: 1));
      });
    } on CameraException catch (e) {
      _notify(e.description ?? 'Recording could not be started.');
    }
  }

  Future<void> _stopRecording() async {
    final controller = _controller;
    if (controller == null || !_isRecording) return;
    _recordTimer?.cancel();
    try {
      final file = await controller.stopVideoRecording();
      if (mounted) setState(() => _isRecording = false);
      _openPreview(CaptureDraft(
        path: file.path,
        isVideo: true,
        isFrontCamera: _isFrontCamera,
      ));
    } on CameraException catch (e) {
      if (mounted) setState(() => _isRecording = false);
      _notify(e.description ?? 'Recording could not be saved.');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final picked = await ImagePicker().pickMedia(imageQuality: 90);
      if (picked == null) return;
      final isVideo = picked.mimeType?.startsWith('video') ??
          picked.path.toLowerCase().endsWith('.mp4');
      _openPreview(CaptureDraft(path: picked.path, isVideo: isVideo));
    } catch (_) {
      _notify('The gallery could not be opened.');
    }
  }

  void _openPreview(CaptureDraft draft) {
    if (!mounted) return;
    context.push('/capture', extra: draft);
  }

  void _notify(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    return Container(
      color: appColors.mediaScrim,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildSurface(),
          if (_readiness == CameraReadiness.ready)
            CameraControls(
              isRecording: _isRecording,
              isCapturing: _isCapturing,
              recordDuration: _recordDuration,
              flashMode: _flashMode,
              canSwitchCamera: _cameras.length > 1,
              onFlashTap: _cycleFlash,
              onSwitchCamera: _switchCamera,
              onGalleryTap: _pickFromGallery,
              onCaptureTap: _capturePhoto,
              onRecordStart: _startRecording,
              onRecordStop: _stopRecording,
            ),
          // Interactive Memories panel overlay
          AnimatedBuilder(
            animation: _panelController,
            builder: (context, _) {
              final value = _panelController.value;
              final height = MediaQuery.of(context).size.height;
              return Positioned.fill(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Transform.translate(
                    offset: Offset(0, height * 0.95 * (1.0 - value)),
                    child: IgnorePointer(
                      ignoring: value <= 0.001,
                      child: SizedBox(
                        height: height * 0.95,
                        child: GestureDetector(
                          onVerticalDragUpdate: (d) {
                            final progress = (_panelController.value - d.delta.dy / height).clamp(0.0, 1.0);
                            _panelController.value = progress;
                          },
                          onVerticalDragEnd: (d) {
                            if ((d.primaryVelocity ?? 0) > 800 || _panelController.value < 0.35) {
                              _closePanel();
                            } else {
                              _openPanel();
                            }
                          },
                          child: Material(
                      color: Theme.of(context).colorScheme.surface,
                      elevation: 12,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Column(
                        children: [
                          // drag handle and header
                          Padding(
                            padding: const EdgeInsets.all(AppTheme.spacingSm),
                            child: Column(
                              children: [
                                Container(
                                  width: 40,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(height: AppTheme.spacingSm),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const SizedBox(width: 48),
                                    Text('Memories', style: Theme.of(context).textTheme.titleMedium),
                                    IconButton(
                                      icon: const Icon(Icons.close_rounded),
                                      onPressed: _closePanel,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSm),
                              child: AsyncStateView<List<MemoryItem>>(
                                state: context.watch<MemoriesProvider>().memories,
                                emptyIcon: Icons.bookmark_border_rounded,
                                emptyTitle: 'No memories saved',
                                emptyMessage: 'Captures you save to Memories will be archived here.',
                                onRetry: () => context.read<MemoriesProvider>().load(),
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
                                      onLongPress: () => showModalBottomSheet<void>(
                                        context: context,
                                        builder: (sheetContext) => SafeArea(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ListTile(
                                                leading: Icon(item.isFavorite ? Icons.star_rounded : Icons.star_border_rounded),
                                                title: Text(item.isFavorite ? 'Remove from favourites' : 'Add to favourites'),
                                                onTap: () async {
                                                  Navigator.of(sheetContext).pop();
                                                  final error = await context.read<MemoriesProvider>().toggleFavorite(item.id);
                                                  if (error != null && mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                                                },
                                              ),
                                              ListTile(
                                                leading: const Icon(Icons.delete_outline_rounded),
                                                title: const Text('Delete'),
                                                onTap: () async {
                                                  Navigator.of(sheetContext).pop();
                                                  final error = await context.read<MemoriesProvider>().delete(item.id);
                                                  if (error != null && mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            Image.network(item.thumbnailUrl ?? item.mediaUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Theme.of(context).colorScheme.surfaceContainerHighest)),
                                            if (item.isVideo)
                                              const Positioned(
                                                right: AppTheme.spacingXs,
                                                top: AppTheme.spacingXs,
                                                child: Icon(Icons.play_circle_fill_rounded, size: 18),
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
              },
          ),
        ],
      ),
    );
  }

  Widget _buildSurface() {
    switch (_readiness) {
      case CameraReadiness.initialising:
        return const Center(
          child: SizedBox(
            width: AppTheme.iconXl,
            height: AppTheme.iconXl,
            child: CircularProgressIndicator(strokeWidth: AppTheme.borderThick),
          ),
        );
      case CameraReadiness.denied:
        return CameraPermissionView(
          title: 'Camera access is off',
          message:
              'SwiftSnap needs the camera to capture snaps, stories and reels.',
          actionLabel: 'Allow camera',
          onAction: _bootstrap,
        );
      case CameraReadiness.permanentlyDenied:
        return CameraPermissionView(
          title: 'Camera access is blocked',
          message:
              'Camera access was permanently denied. Enable it in your device settings to continue.',
          actionLabel: 'Open settings',
          onAction: openAppSettings,
        );
      case CameraReadiness.failed:
        return CameraPermissionView(
          title: 'Camera unavailable',
          message: _failureMessage,
          actionLabel: 'Retry',
          onAction: _bootstrap,
        );
      case CameraReadiness.ready:
        return _buildPreview();
    }
  }

  /// Renders the live preview at the sensor's real aspect ratio, scaled to
  /// cover the viewport without stretching, so framing stays consistent
  /// between what is previewed and what is captured.
  Widget _buildPreview() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final previewRatio = controller.value.aspectRatio;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          // ScaleGestureRecognizer supports both a one-pointer vertical drag
          // and a two-pointer pinch without stealing taps from focus.
          onScaleStart: (details) {
            _baseZoom = _zoom;
            _panelDragLastY = details.focalPoint.dy;
            _isScaling = false;
          },
          onScaleUpdate: (details) {
            if (details.pointerCount >= 2) {
              _isScaling = true;
              unawaited(_setZoom(_baseZoom * details.scale));
              return;
            }
            if (_isScaling) return;
            final deltaY = details.focalPoint.dy - _panelDragLastY;
            _panelDragLastY = details.focalPoint.dy;
            if ((!_panelOpen && deltaY < 0) || (_panelOpen && deltaY > 0)) {
              _panelController.value = (_panelController.value - deltaY / constraints.maxHeight).clamp(0.0, 1.0);
            }
          },
          onScaleEnd: (details) {
            if (_isScaling) {
              _isScaling = false;
              return;
            }
            final velocityY = details.velocity.pixelsPerSecond.dy;
            if (_panelOpen) {
              if (velocityY > 800 || _panelController.value < 0.65) _closePanel();
              else _openPanel();
            } else if (velocityY < -800 || _panelController.value > 0.35) {
              _openPanel();
            } else {
              _closePanel();
            }
          },
          onTapUp: (details) {
            final local = details.localPosition;
            _focusAt(Offset(
              (local.dx / constraints.maxWidth).clamp(0.0, 1.0),
              (local.dy / constraints.maxHeight).clamp(0.0, 1.0),
            ));
          },
          child: ClipRect(
            child: OverflowBox(
              maxWidth: double.infinity,
              maxHeight: double.infinity,
              alignment: Alignment.center,
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxWidth * previewRatio,
                  child: CameraPreview(controller),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _openPanel() {
    _panelOpen = true;
    unawaited(_panelController.animateTo(1.0, curve: Curves.easeOut));
    unawaited(_maybePausePreview());
  }

  void _closePanel() {
    if (!_panelOpen && _panelController.value == 0.0) return;
    _panelOpen = false;
    unawaited(_panelController.animateBack(0.0, curve: Curves.easeOut).then((_) {
      if (mounted && !_panelOpen) unawaited(_maybeResumePreview());
    }));
  }
}
