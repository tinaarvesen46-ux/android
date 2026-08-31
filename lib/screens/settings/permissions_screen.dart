import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../theme/theme.dart';
import '../../widgets/common/app_top_bar.dart';
import '../../widgets/common/settings_rows.dart';

/// Live device permission states. Values come from the operating system —
/// nothing here is simulated.
class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  static const Map<String, Permission> _permissions = {
    'Camera': Permission.camera,
    'Microphone': Permission.microphone,
    'Location': Permission.locationWhenInUse,
    'Photos': Permission.photos,
    'Notifications': Permission.notification,
  };

  final Map<String, PermissionStatus> _statuses = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    for (final entry in _permissions.entries) {
      _statuses[entry.key] = await entry.value.status;
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _request(String label) async {
    final permission = _permissions[label]!;
    final status = await permission.request();
    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
    await _refresh();
  }

  String _describe(PermissionStatus? status) {
    if (status == null) return 'Unknown';
    if (status.isGranted) return 'Allowed';
    if (status.isLimited) return 'Limited';
    if (status.isPermanentlyDenied) return 'Blocked';
    if (status.isRestricted) return 'Restricted';
    return 'Not allowed';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const AppTopBar(showBack: true, title: 'App permissions'),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(AppTheme.spacingXl),
              child: CircularProgressIndicator(
                  strokeWidth: AppTheme.borderThick),
            )
          else
            Expanded(
              child: ListView(
                children: [
                  ..._permissions.keys.map(
                    (label) => SettingsNavigationRow(
                      title: label,
                      value: _describe(_statuses[label]),
                      onTap: () => _request(label),
                    ),
                  ),
                  const SettingsGroupLabel(label: 'Device'),
                  SettingsActionRow(
                    title: 'Open system settings',
                    onTap: openAppSettings,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
