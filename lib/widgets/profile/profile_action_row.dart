import 'package:flutter/material.dart';
import '../../theme/theme.dart';

class ProfileActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;

  const ProfileActionRow({
    super.key,
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;
    final effectiveIconColor = iconColor ?? appColors.subtleText;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingLg,
          vertical: AppTheme.spacingMd,
        ),
        child: Row(
          children: [
            Icon(icon, size: AppTheme.iconMd, color: effectiveIconColor),
            const SizedBox(width: AppTheme.spacingMd),
            Expanded(
              child: Text(label, style: theme.textTheme.bodyMedium),
            ),
            if (trailing != null)
              Text(
                trailing!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: appColors.subtleText,
                ),
              ),
            const SizedBox(width: AppTheme.spacingSm),
            Icon(
              Icons.chevron_right_rounded,
              size: AppTheme.iconSm,
              color: appColors.subtleText,
            ),
          ],
        ),
      ),
    );
  }
}
