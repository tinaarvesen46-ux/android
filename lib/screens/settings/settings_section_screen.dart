import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/settings_provider.dart';
import '../../theme/theme.dart';
import '../../widgets/common/app_top_bar.dart';
import '../../widgets/common/empty_state_view.dart';
import '../../widgets/common/settings_rows.dart';
import 'settings_catalog.dart';

/// Renders one settings section from [SettingsCatalog]. Every change is
/// persisted immediately, so toggles keep their state across restarts.
class SettingsSectionScreen extends StatelessWidget {
  final String sectionId;

  const SettingsSectionScreen({super.key, required this.sectionId});

  Future<void> _pickChoice(
    BuildContext context,
    SettingsRowSpec row,
    String current,
  ) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: row.options
              .map(
                (option) => ListTile(
                  title: Text(option),
                  trailing: option == current
                      ? const Icon(Icons.check_rounded)
                      : null,
                  onTap: () => Navigator.of(sheetContext).pop(option),
                ),
              )
              .toList(),
        ),
      ),
    );
    if (selected == null || !context.mounted) return;
    await context.read<SettingsProvider>().setString(row.key!, selected);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;
    final section = SettingsCatalog.byId(sectionId);
    final settings = context.watch<SettingsProvider>();

    if (section == null) {
      return const Scaffold(
        body: Column(
          children: [
            AppTopBar(showBack: true, title: 'Settings'),
            Expanded(
              child: EmptyStateView(
                icon: Icons.settings_outlined,
                title: 'Section not found',
              ),
            ),
          ],
        ),
      );
    }

    final children = <Widget>[];
    for (final group in section.groups) {
      if (group.title != null) {
        children.add(SettingsGroupLabel(label: group.title!));
      }
      for (final row in group.rows) {
        switch (row.kind) {
          case SettingsRowKind.toggle:
            children.add(
              SettingsToggleRow(
                title: row.title,
                subtitle: row.subtitle,
                value:
                    settings.boolFor(row.key!, fallback: row.defaultBool),
                onChanged: (value) => settings.setBool(row.key!, value),
              ),
            );
            break;
          case SettingsRowKind.choice:
            final current =
                settings.stringFor(row.key!, fallback: row.defaultChoice);
            children.add(
              SettingsNavigationRow(
                title: row.title,
                subtitle: row.subtitle,
                value: current,
                onTap: () => _pickChoice(context, row, current),
              ),
            );
            break;
          case SettingsRowKind.info:
            children.add(
              SettingsInfoRow(title: row.title, value: row.infoValue ?? ''),
            );
            break;
        }
      }
    }

    if (section.footer != null) {
      children.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.spacingLg,
            AppTheme.spacingXl,
            AppTheme.spacingLg,
            AppTheme.spacingHuge,
          ),
          child: Text(
            section.footer!,
            style:
                theme.textTheme.bodySmall?.copyWith(color: appColors.subtleText),
          ),
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          AppTopBar(showBack: true, title: section.title),
          Expanded(child: ListView(children: children)),
        ],
      ),
    );
  }
}
