import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme/theme.dart';
import 'story_creation_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  // Real device camera
  CameraController? _controller;
  List<CameraDescription> _cameras = const [];
  int _currentIdx = 0;
  bool _initializing = true;
  bool _permissionDenied = false;
  bool _isFrontCamera = true;
  FlashMode _flash = FlashMode.off;

  int _selectedFilter = 0;
  late AnimationController _pulseController;

  final List<FilterEffect> _filters = [
    FilterEffect(name: 'Normal', icon: Icons.circle_outlined, color: Colors.white),
    FilterEffect(name: 'Glow', icon: Icons.auto_awesome, color: SwiftSnapTheme.primaryPurple),
    FilterEffect(name: 'Vintage', icon: Icons.filter_vintage, color: Colors.amber),
    FilterEffect(name: 'B&W', icon: Icons.contrast, color: Colors.grey),
    FilterEffect(name: 'Neon', icon: Icons.lightbulb, color: SwiftSnapTheme.primaryPink),
    FilterEffect(name: 'Cool', icon: Icons.ac_unit, color: SwiftSnapTheme.accentCyan),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _boot();
  }

  Future<void> _boot() async {
    // Camera permission is mandatory for a live preview. Mic is best-effort
    // (only needed for video with sound).
    final camStatus = await Permission.camera.request();
    await Permission.microphone.request();
    if (!camStatus.isGranted) {
      if (mounted) setState(() { _permissionDenied = true; _initializing = false; });
      return;
    }
    try {
      _cameras = await availableCameras();
    } catch (_) {
      _cameras = const [];
    }
    if (_cameras.isEmpty) {
      if (mounted) setState(() { _initializing = false; });
      return;
    }
    final frontIdx = _cameras.indexWhere((c) => c.lensDirection == CameraLensDirection.front);
    _currentIdx = _isFrontCamera && frontIdx >= 0 ? frontIdx : 0;
    _isFrontCamera = _cameras[_currentIdx].lensDirection == CameraLensDirection.front;
    await _initController();
    if (mounted) setState(() { _initializing = false; });
  }

  Future<void> _initController() async {
    await _controller?.dispose();
    if (_cameras.isEmpty) return;
    final controller = CameraController(
      _cameras[_currentIdx],
      ResolutionPreset.high,
      enableAudio: true,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    _controller = controller;
    try {
      await controller.initialize();
      await controller.setFlashMode(_flash);
    } catch (_) {/* leave preview loader visible if a camera fails */}
    if (mounted) setState(() {});
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;
    HapticFeedback.lightImpact();
    _currentIdx = (_currentIdx + 1) % _cameras.length;
    _isFrontCamera = _cameras[_currentIdx].lensDirection == CameraLensDirection.front;
    setState(() {});
    await _initController();
  }

  Future<void> _toggleFlash() async {
    HapticFeedback.lightImpact();
    _flash = switch (_flash) {
      FlashMode.off => FlashMode.auto,
      FlashMode.auto => FlashMode.always,
      _ => FlashMode.off,
    };
    try { await _controller?.setFlashMode(_flash); } catch (_) {}
    if (mounted) setState(() {});
  }

  Future<void> _takePhoto() async {
    HapticFeedback.mediumImpact();
    final c = _controller;
    if (c == null || !c.value.isInitialized || c.value.isTakingPicture) return;
    try {
      final shot = await c.takePicture();
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const StoryCreationScreen()),
      );
      debugPrint('SwiftSnap captured photo: ${shot.path}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not capture photo: $e')),
        );
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      c.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initController();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pulseController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildCameraPreview(),
          _buildOverlay(),
          _buildTopControls(),
          _buildBottomControls(),
          _buildFilterSelector(),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (_permissionDenied) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.camera_alt_outlined, size: 56, color: Colors.white54),
                const SizedBox(height: 16),
                const Text(
                  'SwiftSnap needs camera access',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enable camera permission in Settings to take snaps.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => openAppSettings(),
                  child: const Text('Open Settings'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final c = _controller;
    if (_initializing || c == null || !c.value.isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    // Full-bleed live preview (cover the whole screen without distortion).
    return ClipRect(
      child: OverflowBox(
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: c.value.previewSize?.height ?? MediaQuery.of(context).size.width,
            height: c.value.previewSize?.width ?? MediaQuery.of(context).size.height,
            child: CameraPreview(c),
          ),
        ),
      ),
    );
  }

  Widget _buildOverlay() {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.5),
              Colors.transparent,
              Colors.transparent,
              Colors.black.withOpacity(0.7),
            ],
            stops: const [0.0, 0.15, 0.75, 1.0],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    );
  }

  Widget _buildTopControls() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildControlButton(
                icon: Icons.close_rounded,
                onTap: () => Navigator.pop(context),
              ),
              Row(
                children: [
                  _buildControlButton(
                    icon: _flash == FlashMode.off
                        ? Icons.flash_off_rounded
                        : _flash == FlashMode.always
                            ? Icons.flash_on_rounded
                            : Icons.flash_auto_rounded,
                    onTap: _toggleFlash,
                    isActive: _flash != FlashMode.off,
                  ),
                  const SizedBox(width: 12),
                  _buildControlButton(
                    icon: Icons.music_note_rounded,
                    onTap: () => HapticFeedback.lightImpact(),
                  ),
                  const SizedBox(width: 12),
                  _buildControlButton(
                    icon: Icons.timer_outlined,
                    onTap: () => HapticFeedback.lightImpact(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isActive ? SwiftSnapTheme.primaryPurple : Colors.black.withOpacity(0.4),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildGalleryButton(),
              _buildCaptureButton(),
              _buildSwitchCameraButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGalleryButton() {
    return GestureDetector(
      onTap: () => HapticFeedback.lightImpact(),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: SwiftSnapTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: const Icon(Icons.photo_library_rounded, color: Colors.white, size: 26),
      ),
    );
  }

  Widget _buildCaptureButton() {
    return GestureDetector(
      onTap: _takePhoto,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
            ),
            padding: const EdgeInsets.all(4),
            child: Container(
              decoration: const BoxDecoration(
                gradient: SwiftSnapTheme.primaryGradient,
                shape: BoxShape.circle,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSwitchCameraButton() {
    return GestureDetector(
      onTap: _switchCamera,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: SwiftSnapTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Icon(
          _isFrontCamera ? Icons.camera_rear_rounded : Icons.camera_front_rounded,
          color: Colors.white,
          size: 26,
        ),
      ),
    );
  }

  Widget _buildFilterSelector() {
    return Positioned(
      bottom: 140,
      left: 0,
      right: 0,
      child: SizedBox(
        height: 80,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          physics: const BouncingScrollPhysics(),
          itemCount: _filters.length,
          itemBuilder: (context, index) {
            final filter = _filters[index];
            final isSelected = _selectedFilter == index;
            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() => _selectedFilter = index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 64,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: isSelected ? filter.color.withOpacity(0.2) : Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? filter.color : Colors.white.withOpacity(0.1),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(filter.icon,
                        color: isSelected ? filter.color : Colors.white.withOpacity(0.6), size: 24),
                    const SizedBox(height: 6),
                    Text(
                      filter.name,
                      style: TextStyle(
                        color: isSelected ? filter.color : Colors.white.withOpacity(0.6),
                        fontSize: 10,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class FilterEffect {
  final String name;
  final IconData icon;
  final Color color;

  FilterEffect({required this.name, required this.icon, required this.color});
}
