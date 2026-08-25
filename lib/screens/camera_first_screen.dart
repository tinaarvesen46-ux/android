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
    // Ask for camera + mic (mic needed for video). Photos-only works fine without mic permission.
    final camOk = (await Permission.camera.request()).isGranted;
    final micOk = (await Permission.microphone.request()).isGranted;
    if (!camOk) { setState(() { _permissionDenied = true; _initializing = false; }); return; }

    _cameras = await availableCameras();
    // Prefer front camera if requested and available.
    _currentIdx = widget.startWithFrontCamera
        ? _cameras.indexWhere((c) => c.lensDirection == CameraLensDirection.front).clamp(0, _cameras.length - 1)
        : 0;
    await _initController();
    _presets = await LensService().beautyPresets();
    if (mounted) setState(() { _initializing = false; });
    // best-effort — if mic denied, video recording just won't produce audio.
    if (!micOk) debugPrint('mic permission denied — video will be silent');
  }

  Future<void> _initController() async {
    await _controller?.dispose();
    if (_cameras.isEmpty) return;
    _controller = CameraController(
      _cameras[_currentIdx],
      ResolutionPreset.high,
      enableAudio: true,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    await _controller!.initialize();
    await _controller!.setFlashMode(_flash);
    if (mounted) setState(() {});
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
    if (state == AppLifecycleState.inactive) _controller?.dispose();
    if (state == AppLifecycleState.resumed) _initController();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tick?.cancel();
    _controller?.dispose();
    super.dispose();
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
    if (_initializing || _controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator(color: Colors.white)));
    }

    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(fit: StackFit.expand, children: [
        // Live preview
        Center(
          child: AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: CameraPreview(_controller!),
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
            height: 66,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (_, i) {
                final p = _presets[i];
                final active = i == _presetIdx;
                return GestureDetector(
                  onTap: () => setState(() => _presetIdx = i),
                  child: Column(children: [
                    Container(
                      width: 52, height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: active ? const LinearGradient(colors: [Color(0xFFB78BFF), Color(0xFFFF80C6)]) : null,
                        border: Border.all(color: Colors.white70, width: active ? 2 : 1),
                      ),
                      child: Center(
                        child: Text('${p['label']}'.substring(0, 1),
                            style: TextStyle(color: Colors.white, fontWeight: active ? FontWeight.w800 : FontWeight.w500)),
                      ),
                    ),
                    Text(p['label'] ?? '', style: TextStyle(color: active ? Colors.white : Colors.white70, fontSize: 11)),
                  ]),
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
