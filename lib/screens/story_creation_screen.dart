import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../theme/theme.dart';
import '../providers/app_provider.dart';
import '../models/story_model.dart';

class StoryCreationScreen extends StatefulWidget {
  final String? mediaUrl;
  
  const StoryCreationScreen({super.key, this.mediaUrl});

  @override
  State<StoryCreationScreen> createState() => _StoryCreationScreenState();
}

class _StoryCreationScreenState extends State<StoryCreationScreen> {
  final TextEditingController _captionController = TextEditingController();
  bool _isPublic = true;
  
  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }
  
  void _publishStory() {
    HapticFeedback.mediumImpact();
    
    final mediaUrl = widget.mediaUrl ?? 'https://images.unsplash.com/photo-1682687220742-aba13b6e50ba?w=600';
    context.read<AppProvider>().addStory(mediaUrl, StoryType.image);
    
    Navigator.pop(context);
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Story published successfully!'),
        backgroundColor: SwiftSnapTheme.accentGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildPreview(),
          _buildOverlay(),
          _buildTopControls(),
          _buildBottomControls(),
        ],
      ),
    );
  }
  
  Widget _buildPreview() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            SwiftSnapTheme.primaryPurple.withOpacity(0.3),
            SwiftSnapTheme.primaryPink.withOpacity(0.2),
            SwiftSnapTheme.backgroundDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SwiftSnapTheme.primaryGradient,
                boxShadow: SwiftSnapTheme.glowShadow(
                  SwiftSnapTheme.primaryPurple,
                  intensity: 0.4,
                ),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                size: 70,
                color: Colors.white,
              ),
            ).animate(onPlay: (c) => c.repeat())
              .scale(
                duration: 2000.ms,
                begin: const Offset(0.9, 0.9),
                end: const Offset(1.0, 1.0),
              ),
            const SizedBox(height: 24),
            const Text(
              'Story Preview',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your story will appear here',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
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
            Colors.black.withOpacity(0.6),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withOpacity(0.8),
          ],
          stops: const [0.0, 0.15, 0.7, 1.0],
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              Row(
                children: [
                  _buildTopButton(
                    icon: Icons.text_fields_rounded,
                    label: 'Text',
                  ),
                  const SizedBox(width: 8),
                  _buildTopButton(
                    icon: Icons.draw_rounded,
                    label: 'Draw',
                  ),
                  const SizedBox(width: 8),
                  _buildTopButton(
                    icon: Icons.music_note_rounded,
                    label: 'Music',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildTopButton({
    required IconData icon,
    required String label,
  }) {
    return GestureDetector(
      onTap: () => HapticFeedback.lightImpact(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
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
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: SwiftSnapTheme.backgroundCard.withOpacity(0.8),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildCaptionField(),
                  const SizedBox(height: 16),
                  _buildAudienceSelector(),
                  const SizedBox(height: 16),
                  _buildPublishButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildCaptionField() {
    return Container(
      decoration: BoxDecoration(
        color: SwiftSnapTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: TextField(
        controller: _captionController,
        style: const TextStyle(
          color: SwiftSnapTheme.textPrimary,
          fontSize: 15,
        ),
        maxLines: 2,
        decoration: InputDecoration(
          hintText: 'Add a caption...',
          hintStyle: TextStyle(
            color: SwiftSnapTheme.textMuted,
          ),
          prefixIcon: Icon(
            Icons.edit_note_rounded,
            color: SwiftSnapTheme.textMuted,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
  
  Widget _buildAudienceSelector() {
    return Row(
      children: [
        Expanded(
          child: _buildAudienceOption(
            icon: Icons.public_rounded,
            label: 'Public',
            isSelected: _isPublic,
            onTap: () => setState(() => _isPublic = true),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildAudienceOption(
            icon: Icons.people_rounded,
            label: 'Friends Only',
            isSelected: !_isPublic,
            onTap: () => setState(() => _isPublic = false),
          ),
        ),
      ],
    );
  }
  
  Widget _buildAudienceOption({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected ? SwiftSnapTheme.primaryGradient : null,
          color: isSelected ? null : SwiftSnapTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: !isSelected
              ? Border.all(color: Colors.white.withOpacity(0.1))
              : null,
          boxShadow: isSelected
              ? SwiftSnapTheme.glowShadow(
                  SwiftSnapTheme.primaryPurple,
                  intensity: 0.2,
                )
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : SwiftSnapTheme.textMuted,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : SwiftSnapTheme.textMuted,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPublishButton() {
    return GestureDetector(
      onTap: _publishStory,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: SwiftSnapTheme.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: SwiftSnapTheme.glowShadow(
            SwiftSnapTheme.primaryPurple,
            intensity: 0.4,
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.send_rounded,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'Publish Story',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
