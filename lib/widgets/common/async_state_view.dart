import 'package:flutter/material.dart';

import '../../core/load_state.dart';
import '../../theme/theme.dart';
import 'empty_state_view.dart';

/// Renders a [LoadState] consistently across the app: a spinner while loading,
/// an empty state when the backend returns nothing, and an error state with a
/// retry action when the request fails.
class AsyncStateView<T> extends StatelessWidget {
  final LoadState<T> state;
  final Widget Function(T data) builder;
  final IconData emptyIcon;
  final String emptyTitle;
  final String? emptyMessage;
  final String? emptyActionLabel;
  final VoidCallback? onEmptyAction;
  final VoidCallback? onRetry;

  const AsyncStateView({
    super.key,
    required this.state,
    required this.builder,
    this.emptyIcon = Icons.inbox_outlined,
    this.emptyTitle = 'Nothing here yet',
    this.emptyMessage,
    this.emptyActionLabel,
    this.onEmptyAction,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (state.isLoading || state.isIdle) {
      return const Center(
        child: SizedBox(
          width: AppTheme.iconXl,
          height: AppTheme.iconXl,
          child: CircularProgressIndicator(strokeWidth: AppTheme.borderThick),
        ),
      );
    }

    if (state.hasError) {
      return _ErrorState(message: state.message, onRetry: onRetry);
    }

    final data = state.data;
    if (state.isEmpty || data == null) {
      return EmptyStateView(
        icon: emptyIcon,
        title: emptyTitle,
        subtitle: emptyMessage,
        actionLabel: emptyActionLabel,
        onAction: onEmptyAction,
      );
    }

    return builder(data);
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _ErrorState({required this.message, this.onRetry});

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
              Icons.cloud_off_rounded,
              size: AppTheme.iconHuge,
              color: appColors.subtleText,
            ),
            const SizedBox(height: AppTheme.spacingLg),
            Text(
              message.isEmpty ? 'This could not be loaded right now.' : message,
              style:
                  theme.textTheme.bodyMedium?.copyWith(color: appColors.subtleText),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppTheme.spacingXl),
              OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ],
        ),
      ),
    );
  }
}

/// Compact failure strip for a section that fails while the rest of the screen
/// still has content.
class InlineErrorBar extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const InlineErrorBar({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingLg,
        vertical: AppTheme.spacingSm,
      ),
      color: theme.colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: AppTheme.iconSm,
            color: appColors.warning,
          ),
          const SizedBox(width: AppTheme.spacingSm),
          Expanded(
            child: Text(
              message.isEmpty ? 'This section is unavailable.' : message,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurface),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
