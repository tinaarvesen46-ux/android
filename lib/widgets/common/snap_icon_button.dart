import 'package:flutter/material.dart';
import '../../theme/theme.dart';

class SnapIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final Color? color;
  final Color? backgroundColor;
  final String? badge;

  const SnapIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.size = AppTheme.iconMd,
    this.color,
    this.backgroundColor,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.onSurface;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: size + AppTheme.spacingLg,
        height: size + AppTheme.spacingLg,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (backgroundColor != null)
              Container(
                width: size + AppTheme.spacingMd,
                height: size + AppTheme.spacingMd,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  shape: BoxShape.circle,
                ),
              ),
            Icon(icon, size: size, color: effectiveColor),
            if (badge != null)
              Positioned(
                top: AppTheme.spacingXs,
                right: AppTheme.spacingXs,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingXs,
                    vertical: AppTheme.spacingXxs,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error,
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Center(
                    child: Text(
                      badge!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onError,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
