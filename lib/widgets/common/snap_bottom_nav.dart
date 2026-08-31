import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/theme.dart';

/// SwiftSnap primary navigation.
///
/// Structure is fixed: [ MAP ] [ CHAT ] [ CAMERA ] [ DISCOVER ] [ REELS ].
/// The camera is visually emphasised but remains a child of this same
/// container — it is never a floating action button.
class SnapBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const SnapBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const List<_NavSpec> _specs = [
    _NavSpec(Icons.map_rounded, Icons.map_outlined, 'Map'),
    _NavSpec(
        Icons.chat_bubble_rounded, Icons.chat_bubble_outline_rounded, 'Chat'),
    _NavSpec(Icons.camera_alt_rounded, Icons.camera_alt_rounded, 'Camera'),
    _NavSpec(Icons.explore_rounded, Icons.explore_outlined, 'Discover'),
    _NavSpec(Icons.play_circle_fill_rounded,
        Icons.play_circle_outline_rounded, 'Reels'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    // Keep labels readable without letting large system fonts break the row.
    final textScale =
        MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.2);

    return Container(
      decoration: BoxDecoration(
        color: appColors.navBar,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: AppTheme.borderThin,
          ),
        ),
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: textScale),
        child: SizedBox(
          height: AppTheme.navBarHeight,
          child: Row(
            children: List.generate(_specs.length, (index) {
              if (index == 2) {
                return _CameraNavItem(
                  isSelected: currentIndex == index,
                  onTap: () => _handleTap(index),
                );
              }
              return _NavItem(
                spec: _specs[index],
                isSelected: currentIndex == index,
                onTap: () => _handleTap(index),
              );
            }),
          ),
        ),
      ),
    );
  }

  void _handleTap(int index) {
    HapticFeedback.selectionClick();
    onTap(index);
  }
}

class _NavSpec {
  final IconData activeIcon;
  final IconData icon;
  final String label;

  const _NavSpec(this.activeIcon, this.icon, this.label);
}

class _NavItem extends StatelessWidget {
  final _NavSpec spec;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.spec,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;
    final color =
        isSelected ? theme.colorScheme.onSurface : appColors.subtleText;

    return Expanded(
      child: Semantics(
        button: true,
        selected: isSelected,
        label: spec.label,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? spec.activeIcon : spec.icon,
                size: AppTheme.iconMd,
                color: color,
              ),
              const SizedBox(height: AppTheme.spacingXxs),
              Flexible(
                child: Text(
                  spec.label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CameraNavItem extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const _CameraNavItem({required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;

    return Expanded(
      child: Semantics(
        button: true,
        selected: isSelected,
        label: 'Camera',
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Center(
            child: AnimatedContainer(
              duration: AppTheme.animFast,
              width: AppTheme.cameraButtonSize,
              height: AppTheme.cameraButtonSize - AppTheme.spacingMd,
              decoration: BoxDecoration(
                color: isSelected
                    ? appColors.snapYellow
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Icon(
                Icons.camera_alt_rounded,
                size: AppTheme.iconLg,
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
