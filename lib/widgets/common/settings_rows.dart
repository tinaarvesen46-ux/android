import 'package:flutter/material.dart';

import '../../theme/theme.dart';

class SettingsGroupLabel extends StatelessWidget {
  final String label;

  const SettingsGroupLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacingLg,
        AppTheme.spacingXl,
        AppTheme.spacingLg,
        AppTheme.spacingSm,
      ),
      child: Text(
        label.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: appColors.subtleText,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class SettingsNavigationRow extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String? value;
  final String? subtitle;
  final VoidCallback onTap;
  final bool destructive;

  const SettingsNavigationRow({
    super.key,
    this.icon,
    required this.title,
    this.value,
    this.subtitle,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;
    final color =
        destructive ? theme.colorScheme.error : theme.colorScheme.onSurface;

    return ListTile(
      leading: icon == null ? null : Icon(icon, color: color),
      title:
          Text(title, style: theme.textTheme.bodyLarge?.copyWith(color: color)),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: appColors.subtleText),
            ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null)
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 140),
              child: Text(
                value!,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: appColors.subtleText),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
              ),
            ),
          const SizedBox(width: AppTheme.spacingXs),
          Icon(
            Icons.chevron_right_rounded,
            size: AppTheme.iconMd,
            color: appColors.subtleText,
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}

class SettingsToggleRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingsToggleRow({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;

    return SwitchListTile(
      title: Text(title, style: theme.textTheme.bodyLarge),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: appColors.subtleText),
            ),
      value: value,
      onChanged: onChanged,
    );
  }
}

class SettingsActionRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool destructive;
  final bool busy;

  const SettingsActionRow({
    super.key,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.destructive = false,
    this.busy = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;
    final color =
        destructive ? theme.colorScheme.error : theme.colorScheme.onSurface;

    return ListTile(
      title:
          Text(title, style: theme.textTheme.bodyLarge?.copyWith(color: color)),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: appColors.subtleText),
            ),
      trailing: busy
          ? const SizedBox(
              width: AppTheme.iconSm,
              height: AppTheme.iconSm,
              child:
                  CircularProgressIndicator(strokeWidth: AppTheme.borderThick),
            )
          : null,
      onTap: busy ? null : onTap,
    );
  }
}

class SettingsInfoRow extends StatelessWidget {
  final String title;
  final String value;

  const SettingsInfoRow({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;

    return ListTile(
      title: Text(title, style: theme.textTheme.bodyLarge),
      trailing: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 180),
        child: Text(
          value,
          style:
              theme.textTheme.bodyMedium?.copyWith(color: appColors.subtleText),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.right,
        ),
      ),
    );
  }
}
