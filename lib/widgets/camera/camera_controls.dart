import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../theme/theme.dart';

/// Circular control drawn directly over media. Shared by the camera, the
/// capture preview and the map overlays.
class CameraOverlayButton extends StatelessWidget {
  final IconData icon;
  final String semanticLabel;
  final VoidCallback onTap;

  const CameraOverlayButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: AppTheme.controlSize,
          height: AppTheme.controlSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                appColors.mediaScrim.withValues(alpha: AppTheme.opacityOverlay),
          ),
          child: Icon(icon, size: AppTheme.iconMd, color: appColors.onMedia),
        ),
      ),
    );
  }
}

/// Overlay controls for the live camera: flash, lens switch, gallery and the
/// capture button (tap for a photo, press and hold for video).
class CameraControls extends StatelessWidget {
  final bool isRecording;
  final bool isCapturing;
  final Duration recordDuration;
  final FlashMode flashMode;
  final bool canSwitchCamera;
  final VoidCallback onFlashTap;
  final VoidCallback onSwitchCamera;
  final VoidCallback onGalleryTap;
  final VoidCallback onCaptureTap;
  final VoidCallback onRecordStart;
  final VoidCallback onRecordStop;

  const CameraControls({
    super.key,
    required this.isRecording,
    required this.isCapturing,
    required this.recordDuration,
    required this.flashMode,
    required this.canSwitchCamera,
    required this.onFlashTap,
    required this.onSwitchCamera,
    required this.onGalleryTap,
    required this.onCaptureTap,
    required this.onRecordStart,
    required this.onRecordStop,
  });

  IconData get _flashIcon {
    switch (flashMode) {
      case FlashMode.always:
        return Icons.flash_on_rounded;
      case FlashMode.off:
        return Icons.flash_off_rounded;
      case FlashMode.auto:
      case FlashMode.torch:
        return Icons.flash_auto_rounded;
    }
  }

  String _formatted(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;
    final insets = MediaQuery.paddingOf(context);

    return Padding(
      padding: EdgeInsets.only(
        top: insets.top + AppTheme.spacingSm,
        bottom: AppTheme.spacingXxl,
        left: AppTheme.spacingLg,
        right: AppTheme.spacingLg,
      ),
      child: Column(
        children: [
          Row(
            children: [
              CameraOverlayButton(
                icon: _flashIcon,
                semanticLabel: 'Flash mode',
                onTap: onFlashTap,
              ),
              const Spacer(),
              if (isRecording)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMd,
                    vertical: AppTheme.spacingXs,
                  ),
                  decoration: BoxDecoration(
                    color: appColors.danger,
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                  child: Text(
                    _formatted(recordDuration),
                    style: theme.textTheme.labelMedium
                        ?.copyWith(color: appColors.onMedia),
                  ),
                ),
              const Spacer(),
              if (canSwitchCamera)
                CameraOverlayButton(
                  icon: Icons.cameraswitch_rounded,
                  semanticLabel: 'Switch camera',
                  onTap: onSwitchCamera,
                )
              else
                const SizedBox(width: AppTheme.controlSize),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              CameraOverlayButton(
                icon: Icons.photo_library_outlined,
                semanticLabel: 'Open gallery',
                onTap: onGalleryTap,
              ),
              Expanded(
                child: Center(
                  child: Semantics(
                    button: true,
                    label: 'Capture. Tap for a photo, hold for video.',
                    child: GestureDetector(
                      onTap: isRecording ? onRecordStop : onCaptureTap,
                      onLongPressStart: (_) => onRecordStart(),
                      onLongPressEnd: (_) => onRecordStop(),
                      child: AnimatedContainer(
                        duration: AppTheme.animFast,
                        width: AppTheme.captureButtonSize,
                        height: AppTheme.captureButtonSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                isRecording ? appColors.danger : appColors.onMedia,
                            width: AppTheme.borderCapture,
                          ),
                          color: isCapturing
                              ? appColors.onMedia
                                  .withValues(alpha: AppTheme.opacitySubtle)
                              : Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.controlSize),
            ],
          ),
        ],
      ),
    );
  }
}
