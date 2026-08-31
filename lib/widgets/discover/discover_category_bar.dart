import 'package:flutter/material.dart';

import '../../core/load_state.dart';
import '../../models/discover_item.dart';
import '../../theme/theme.dart';

/// Horizontal category selector driven by the same [LoadState] the rest of the
/// app uses, so a failed category request degrades to an inline retry rather
/// than an empty strip.
class DiscoverCategoryBar extends StatelessWidget {
  final LoadState<List<DiscoverCategory>> state;
  final String? activeCategoryId;
  final ValueChanged<String?> onSelect;
  final VoidCallback onRetry;

  const DiscoverCategoryBar({
    super.key,
    required this.state,
    required this.activeCategoryId,
    required this.onSelect,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;

    if (state.hasError) {
      return SizedBox(
        height: AppTheme.rowHeight,
        child: Row(
          children: [
            const SizedBox(width: AppTheme.spacingLg),
            Expanded(
              child: Text(
                'Categories unavailable',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: appColors.subtleText),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      );
    }

    final categories = state.data ?? const <DiscoverCategory>[];
    if (categories.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: AppTheme.rowHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
        itemCount: categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: AppTheme.spacingSm),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _CategoryChip(
              label: 'All',
              isSelected: activeCategoryId == null,
              onTap: () => onSelect(null),
            );
          }
          final category = categories[index - 1];
          return _CategoryChip(
            label: category.name,
            isSelected: activeCategoryId == category.id,
            onTap: () => onSelect(category.id),
          );
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppTheme.animFast,
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingLg,
            vertical: AppTheme.spacingSm,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          ),
          child: Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: isSelected
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
