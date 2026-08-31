import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/media.dart';
import '../theme/theme.dart';
import '../widgets/camera/camera_controls.dart';
import '../widgets/camera/camera_permission_view.dart';

enum CameraReadiness { initialising, ready, denied, permanentlyDenied, failed }

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bootstrap();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _recordTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _recordTimer?.cancel();
      final old = _controller;
      _controller = null;
      if (mounted) setState(() => _isRecording = false);
      old?.dispose();
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

  Future<void> _startController(int index) async {
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

    if (!mounted) {
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
          onScaleStart: (_) => _baseZoom = _zoom,
          onScaleUpdate: (details) {
            if (details.pointerCount < 2) return;
            _setZoom(_baseZoom * details.scale);
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
}
