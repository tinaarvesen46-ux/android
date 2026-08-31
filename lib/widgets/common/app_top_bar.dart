import 'package:flutter/material.dart';

import '../../theme/theme.dart';

/// Compact header used instead of an AppBar so screens keep the dense,
/// camera-first rhythm and can be composed inside a Column.
class AppTopBar extends StatelessWidget {
  final String? title;
  final Widget? leading;
  final List<Widget> actions;
  final bool showBack;
  final bool transparent;

  const AppTopBar({
    super.key,
    this.title,
    this.leading,
    this.actions = const [],
    this.showBack = false,
    this.transparent = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topInset = MediaQuery.paddingOf(context).top;

    return Container(
      color: transparent ? Colors.transparent : theme.colorScheme.surface,
      padding: EdgeInsets.only(
        top: topInset + AppTheme.spacingSm,
        left: AppTheme.spacingSm,
        right: AppTheme.spacingSm,
        bottom: AppTheme.spacingSm,
      ),
      child: Row(
        children: [
          if (showBack)
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              tooltip: 'Back',
              onPressed: () => Navigator.of(context).maybePop(),
            )
          else if (leading != null)
            Padding(
              padding: const EdgeInsets.only(left: AppTheme.spacingXs),
              child: leading,
            )
          else
            const SizedBox(width: AppTheme.spacingSm),
          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppTheme.spacingSm),
              child: Text(
                title ?? '',
                style: theme.textTheme.titleLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          ...actions,
        ],
      ),
    );
  }
}
