import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../api/services/lens_service.dart';
import '../services/beauty_engine.dart';

/// CameraFirstScreen — Snapchat-style camera-first landing screen.
///
/// Opens straight into the live camera preview.  Real device camera via
/// the `camera` plugin.  Handles permissions, front/rear switch, flash,
/// tap-to-focus, photo/video capture, and a live beauty preset bar.
///
/// Media is written to a temp file that the caller can then send to a
/// chat, story, or memories.  This screen does NOT itself upload — it
/// hands the final file back via `Navigator.pop(context, CameraResult)`.
class CameraFirstScreen extends StatefulWidget {
  final bool startWithFrontCamera;
  const CameraFirstScreen({super.key, this.startWithFrontCamera = true});

  @override
  State<CameraFirstScreen> createState() => _CameraFirstScreenState();
}

class CameraResult {
  final File file;
  final bool isVideo;
  final String? lensId;
  final Map<String, int>? beautyParams;
  CameraResult({required this.file, required this.isVideo, this.lensId, this.beautyParams});
}

class _CameraFirstScreenState extends State<CameraFirstScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = const [];
  int _currentIdx = 0;
  bool _initializing = true;
  bool _permissionDenied = false;
  String? _initError;
  FlashMode _flash = FlashMode.off;
  bool _isRecording = false;
  DateTime? _recordStart;
  Timer? _tick;
  String _elapsed = '';

  List<Map<String, dynamic>> _presets = const [];
  int _presetIdx = 0;   // 0 = off

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _boot();
  }

  Future<void> _boot() async {
    setState(() { _initError = null; _initializing = true; });
    try {
      // Ask for camera + mic (mic needed for video). Photos-only works fine without mic permission.
      final camOk = (await Permission.camera.request()).isGranted;
      final micOk = (await Permission.microphone.request()).isGranted;
      if (!camOk) { setState(() { _permissionDenied = true; _initializing = false; }); return; }

      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() { _initError = 'No camera found on this device.'; _initializing = false; });
        return;
      }
      // Prefer front camera if requested and available.
      final frontIdx = _cameras.indexWhere((c) => c.lensDirection == CameraLensDirection.front);
      _currentIdx = (widget.startWithFrontCamera && frontIdx >= 0) ? frontIdx : 0;
      await _initController();
      try { _presets = await LensService().beautyPresets(); } catch (_) { _presets = const []; }
      if (mounted) setState(() { _initializing = false; });
      if (!micOk) debugPrint('mic permission denied — video will be silent');
    } catch (e) {
      if (mounted) setState(() { _initError = 'Camera failed to start. Tap retry.'; _initializing = false; });
    }
  }

  Future<void> _initController() async {
    final old = _controller;
    _controller = null;
    await old?.dispose();
    if (_cameras.isEmpty) return;
    final controller = CameraController(
      _cameras[_currentIdx],
      ResolutionPreset.high,
      enableAudio: true,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    await controller.initialize();
    await controller.setFlashMode(_flash);
    if (!mounted) { await controller.dispose(); return; }
    setState(() { _controller = controller; });
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;
    _currentIdx = (_currentIdx + 1) % _cameras.length;
    await _initController();
  }

  Future<void> _toggleFlash() async {
    _flash = switch (_flash) { FlashMode.off => FlashMode.auto, FlashMode.auto => FlashMode.always, _ => FlashMode.off };
    await _controller?.setFlashMode(_flash);
    if (mounted) setState(() {});
  }

  Future<void> _takePhoto() async {
    final c = _controller;
    if (c == null || !c.value.isInitialized || c.value.isTakingPicture) return;
    final xfile = await c.takePicture();
    final params = _presets.isNotEmpty ? Map<String, int>.from(_presets[_presetIdx]['params'] as Map) : null;
    File out = File(xfile.path);
    // Apply on-device beauty engine.  If teeth/eye are requested, the auto
    // pipeline runs ML Kit face detection first and confines those effects
    // to the actual landmark regions; otherwise it falls back to the safe
    // skin-tone / global pass.
    if (params != null && (params['smooth']! > 0 || params['tan']! > 0 || params['glow']! > 0 || (params['teeth'] ?? 0) > 0 || (params['eye'] ?? 0) > 0)) {
      out = await BeautyEngine.processPhotoAuto(out, params);
    }
    if (!mounted) return;
    Navigator.pop(context, CameraResult(file: out, isVideo: false, beautyParams: params));
  }

  Future<void> _startVideo() async {
    final c = _controller;
    if (c == null || !c.value.isInitialized || c.value.isRecordingVideo) return;
    await c.startVideoRecording();
    setState(() {
      _isRecording = true;
      _recordStart = DateTime.now();
    });
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || !_isRecording) return;
      final d = DateTime.now().difference(_recordStart!);
      setState(() { _elapsed = '${d.inMinutes.toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}'; });
      if (d.inSeconds >= 60) _stopVideo();  // cap at 60s like Snapchat
    });
  }

  Future<void> _stopVideo() async {
    final c = _controller;
    if (c == null || !c.value.isRecordingVideo) return;
    _tick?.cancel();
    final xfile = await c.stopVideoRecording();
    if (!mounted) return;
    setState(() { _isRecording = false; _elapsed = ''; });
    Navigator.pop(context, CameraResult(file: File(xfile.path), isVideo: true));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final c = _controller;
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      if (c != null) {
        _controller = null;
        c.dispose();
        if (mounted) setState(() {});
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_controller == null && !_initializing && _cameras.isNotEmpty) {
        _initController();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tick?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  /// Builds a 4x5 color matrix from the active lens preset so the effect is
  /// visible live on the preview (warmth from `tan`, brightness from `glow`,
  /// gentle saturation drop from `smooth`). Preset 0 / no presets = identity.
  List<double> _livePreviewMatrix() {
    const identity = <double>[
      1, 0, 0, 0, 0,
      0, 1, 0, 0, 0,
      0, 0, 1, 0, 0,
      0, 0, 0, 1, 0,
    ];
    if (_presets.isEmpty || _presetIdx <= 0 || _presetIdx >= _presets.length) {
      return identity;
    }
    final params = (_presets[_presetIdx]['params'] as Map?) ?? const {};
    final glow = ((params['glow'] ?? 0) as num).toDouble() / 100.0;
    final tan = ((params['tan'] ?? 0) as num).toDouble() / 100.0;
    final smooth = ((params['smooth'] ?? 0) as num).toDouble() / 100.0;

    final s = 1.0 - smooth * 0.30; // saturation factor
    final rGain = 1.0 + tan * 0.18; // warm
    final bGain = 1.0 - tan * 0.14;
    final bright = glow * 28.0; // additive brightness (0..255 scale)

    const lr = 0.2126, lg = 0.7152, lb = 0.0722;
    double sat(double l, bool diag) => diag ? l + s * (1 - l) : l - s * l;

    final r0 = sat(lr, true) * rGain, r1 = sat(lg, false) * rGain, r2 = sat(lb, false) * rGain;
    final g0 = sat(lr, false), g1 = sat(lg, true), g2 = sat(lb, false);
    final b0 = sat(lr, false) * bGain, b1 = sat(lg, false) * bGain, b2 = sat(lb, true) * bGain;

    return <double>[
      r0, r1, r2, 0, bright,
      g0, g1, g2, 0, bright,
      b0, b1, b2, 0, bright,
      0, 0, 0, 1, 0,
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_permissionDenied) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.camera_alt_outlined, size: 48, color: Colors.white54),
              const SizedBox(height: 12),
              const Text('SwiftSnap needs camera access',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              const Text('Enable it in Settings to take snaps.',
                  style: TextStyle(color: Colors.white70), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: () => openAppSettings(), child: const Text('Open Settings')),
            ]),
          ),
        ),
      );
    }
    if (_initError != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.videocam_off_rounded, size: 48, color: Colors.white54),
              const SizedBox(height: 12),
              Text(_initError!,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _boot, child: const Text('Retry')),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close', style: TextStyle(color: Colors.white70)),
              ),
            ]),
          ),
        ),
      );
    }
    if (_initializing || _controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator(color: Colors.white)));
    }

    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(fit: StackFit.expand, children: [
        // Live preview — full-screen cover (fills like Snapchat, crops excess).
        // A live ColorFilter previews the selected lens so the effect is
        // visibly applied on-screen (full pixel processing runs at capture).
        Positioned.fill(
          child: ClipRect(
            child: ColorFiltered(
              colorFilter: ColorFilter.matrix(_livePreviewMatrix()),
              child: OverflowBox(
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: size.width,
                    height: size.width / _controller!.value.aspectRatio,
                    child: CameraPreview(_controller!),
                  ),
                ),
              ),
            ),
          ),
        ),
        // Top bar
        Positioned(
          top: MediaQuery.of(context).padding.top + 8, left: 8, right: 8,
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
            if (_isRecording)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.fiber_manual_record, size: 12, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(_elapsed, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ]),
              ),
            Row(children: [
              IconButton(
                icon: Icon(
                  _flash == FlashMode.off ? Icons.flash_off : _flash == FlashMode.always ? Icons.flash_on : Icons.flash_auto,
                  color: Colors.white),
                onPressed: _toggleFlash,
              ),
              IconButton(icon: const Icon(Icons.cameraswitch, color: Colors.white), onPressed: _switchCamera),
            ]),
          ]),
        ),
        // Beauty presets rail (bottom-left)
        Positioned(
          bottom: 120, left: 0, right: 0,
          child: SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (_, i) {
                final p = _presets[i];
                final active = i == _presetIdx;
                return Center(
                  child: GestureDetector(
                    onTap: () => setState(() => _presetIdx = i),
                    child: Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: active ? const LinearGradient(colors: [Color(0xFFB78BFF), Color(0xFFFF80C6)]) : null,
                        color: active ? null : Colors.black.withOpacity(0.35),
                        border: Border.all(color: Colors.white70, width: active ? 2 : 1),
                      ),
                      child: Center(
                        child: Text('${p['label']}'.substring(0, 1),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: active ? FontWeight.w800 : FontWeight.w500)),
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemCount: _presets.length,
            ),
          ),
        ),
        // Capture button
        Positioned(
          bottom: 24, left: 0, right: 0,
          child: Center(
            child: GestureDetector(
              onTap: _isRecording ? _stopVideo : _takePhoto,
              onLongPress: _startVideo,
              onLongPressEnd: (_) => _stopVideo(),
              child: Container(
                width: 78, height: 78,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isRecording ? Colors.red : Colors.transparent,
                  border: Border.all(color: Colors.white, width: 5),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
