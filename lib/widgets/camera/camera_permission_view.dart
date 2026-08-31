import 'package:flutter/material.dart';

import '../../theme/theme.dart';

/// Shown in place of the camera preview when permission is missing or the
/// sensor cannot be started. The action always leads to a real recovery path.
class CameraPermissionView extends StatelessWidget {
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const CameraPermissionView({
    super.key,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingHuge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.photo_camera_outlined,
              size: AppTheme.iconHuge,
              color: appColors.onMedia,
            ),
            const SizedBox(height: AppTheme.spacingLg),
            Text(
              title,
              style:
                  theme.textTheme.titleLarge?.copyWith(color: appColors.onMedia),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              message,
              style:
                  theme.textTheme.bodyMedium?.copyWith(color: appColors.subtleText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingXl),
            ElevatedButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
