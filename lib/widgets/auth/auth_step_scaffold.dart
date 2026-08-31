import 'package:flutter/material.dart';

import '../../theme/theme.dart';

/// Shared layout for a single step of the sign-up flow.
class AuthStepScaffold extends StatelessWidget {
  final int step;
  final int stepCount;
  final String title;
  final String subtitle;
  final String? error;
  final bool isBusy;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final VoidCallback onBack;
  final Widget child;

  const AuthStepScaffold({
    super.key,
    required this.step,
    required this.stepCount,
    required this.title,
    required this.subtitle,
    this.error,
    required this.isBusy,
    required this.primaryLabel,
    required this.onPrimary,
    required this.onBack,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  tooltip: 'Back',
                  onPressed: isBusy ? null : onBack,
                ),
                Expanded(
                  child: LinearProgressIndicator(
                    value: (step + 1) / stepCount,
                    minHeight: AppTheme.spacingXs,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingXxl),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingXl,
                  vertical: AppTheme.spacingXxl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(title, style: theme.textTheme.headlineMedium),
                    const SizedBox(height: AppTheme.spacingSm),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: appColors.subtleText),
                    ),
                    const SizedBox(height: AppTheme.spacingXxl),
                    child,
                    if (error != null) ...[
                      const SizedBox(height: AppTheme.spacingMd),
                      Text(
                        error!,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: appColors.danger),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: AppTheme.spacingXl,
                right: AppTheme.spacingXl,
                bottom: AppTheme.spacingXl +
                    MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: ElevatedButton(
                onPressed: isBusy ? null : onPrimary,
                child: isBusy
                    ? const SizedBox(
                        width: AppTheme.iconSm,
                        height: AppTheme.iconSm,
                        child: CircularProgressIndicator(
                          strokeWidth: AppTheme.borderThick,
                        ),
                      )
                    : Text(primaryLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
