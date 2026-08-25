import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/theme.dart';
import 'story_creation_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with TickerProviderStateMixin {
  bool _isRecording = false;
  bool _isFrontCamera = true;
  int _selectedFilter = 0;
  late AnimationController _recordingController;
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
    _recordingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _recordingController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
  
  void _toggleRecording() {
    HapticFeedback.heavyImpact();
    setState(() {
      _isRecording = !_isRecording;
      if (_isRecording) {
        _recordingController.forward();
      } else {
        _recordingController.stop();
        _recordingController.reset();
      }
    });
  }
  
  void _switchCamera() {
    HapticFeedback.lightImpact();
    setState(() => _isFrontCamera = !_isFrontCamera);
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
          if (_isRecording) _buildRecordingIndicator(),
        ],
      ),
    );
  }
  
  Widget _buildCameraPreview() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            SwiftSnapTheme.backgroundDark,
            SwiftSnapTheme.surfaceColor.withOpacity(0.8),
            SwiftSnapTheme.backgroundDark,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: SwiftSnapTheme.primaryPurple.withOpacity(0.15),
              ),
              child: Icon(
                _isFrontCamera ? Icons.person_rounded : Icons.landscape_rounded,
                size: 60,
                color: SwiftSnapTheme.textMuted,
              ),
            ).animate(onPlay: (controller) => controller.repeat())
              .shimmer(duration: 2000.ms, color: SwiftSnapTheme.primaryPurple.withOpacity(0.3)),
            const SizedBox(height: 24),
            Text(
              'Camera Preview',
              style: TextStyle(
                color: SwiftSnapTheme.textMuted,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap capture button to take a photo',
              style: TextStyle(
                color: SwiftSnapTheme.textMuted.withOpacity(0.6),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOverlay() {
    return Container(
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
                    icon: Icons.flash_off_rounded,
                    onTap: () => HapticFeedback.lightImpact(),
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
          color: isActive
              ? SwiftSnapTheme.primaryPurple
              : Colors.black.withOpacity(0.4),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 22,
        ),
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
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
          ),
        ),
        child: const Icon(
          Icons.photo_library_rounded,
          color: Colors.white,
          size: 26,
        ),
      ),
    );
  }
  
  Widget _buildCaptureButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const StoryCreationScreen(),
          ),
        );
      },
      onLongPressStart: (_) => _toggleRecording(),
      onLongPressEnd: (_) {
        if (_isRecording) _toggleRecording();
      },
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Container(
            width: _isRecording ? 88 : 80,
            height: _isRecording ? 88 : 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _isRecording 
                    ? Colors.red 
                    : Colors.white,
                width: 4,
              ),
              boxShadow: _isRecording
                  ? [
                      BoxShadow(
                        color: Colors.red.withOpacity(
                          0.3 + (_pulseController.value * 0.3),
                        ),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ]
                  : null,
            ),
            padding: const EdgeInsets.all(4),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                gradient: _isRecording
                    ? const LinearGradient(
                        colors: [Colors.red, Color(0xFFFF6B6B)],
                      )
                    : SwiftSnapTheme.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: _isRecording
                  ? const Icon(
                      Icons.stop_rounded,
                      color: Colors.white,
                      size: 32,
                    )
                  : null,
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
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
          ),
        ),
        child: Icon(
          _isFrontCamera 
              ? Icons.camera_rear_rounded 
              : Icons.camera_front_rounded,
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
                  color: isSelected
                      ? filter.color.withOpacity(0.2)
                      : Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? filter.color
                        : Colors.white.withOpacity(0.1),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: filter.color.withOpacity(0.3),
                            blurRadius: 12,
                            spreadRadius: 0,
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      filter.icon,
                      color: isSelected ? filter.color : Colors.white.withOpacity(0.6),
                      size: 24,
                    ),
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
  
  Widget _buildRecordingIndicator() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 60, vertical: 16),
          child: AnimatedBuilder(
            animation: _recordingController,
            builder: (context, child) {
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ).animate(onPlay: (c) => c.repeat())
                        .fadeIn(duration: 500.ms)
                        .then()
                        .fadeOut(duration: 500.ms),
                      const SizedBox(width: 8),
                      Text(
                        _formatDuration(
                          Duration(seconds: (_recordingController.value * 60).toInt()),
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: _recordingController.value,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation(Colors.red),
                      minHeight: 4,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
  
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class FilterEffect {
  final String name;
  final IconData icon;
  final Color color;
  
  FilterEffect({
    required this.name,
    required this.icon,
    required this.color,
  });
}
