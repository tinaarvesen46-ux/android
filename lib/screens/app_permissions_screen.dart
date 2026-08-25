import 'package:flutter/material.dart';
import '../theme/theme.dart';

class AppPermissionsScreen extends StatefulWidget {
  const AppPermissionsScreen({super.key});

  @override
  State<AppPermissionsScreen> createState() => _AppPermissionsScreenState();
}

class _AppPermissionsScreenState extends State<AppPermissionsScreen> {
  final Map<String, bool> _permissions = {
    'Camera': true,
    'Microphone': true,
    'Location': false,
    'Contacts': true,
    'Photos': true,
    'Notifications': true,
    'Storage': true,
    'Calendar': false,
  };

  final Map<String, String> _permissionDescriptions = {
    'Camera': 'Take photos and record videos',
    'Microphone': 'Record audio messages',
    'Location': 'Share your location with friends',
    'Contacts': 'Find friends from your contacts',
    'Photos': 'Share photos and videos',
    'Notifications': 'Receive message notifications',
    'Storage': 'Save media and files',
    'Calendar': 'Add events to your calendar',
  };

  final Map<String, IconData> _permissionIcons = {
    'Camera': Icons.camera_alt,
    'Microphone': Icons.mic,
    'Location': Icons.location_on,
    'Contacts': Icons.contacts,
    'Photos': Icons.photo_library,
    'Notifications': Icons.notifications,
    'Storage': Icons.storage,
    'Calendar': Icons.calendar_today,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwiftSnapTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'App Permissions',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with gradient
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    SwiftSnapTheme.primaryPurple,
                    SwiftSnapTheme.primaryPink,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: SwiftSnapTheme.primaryPurple.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.security,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Manage Permissions',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Control what SwiftSnap can access',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Info banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[300], size: 20),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Some features require specific permissions to work properly',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Essential Permissions
            _buildSectionTitle('Essential Permissions'),
            const SizedBox(height: 12),
            _buildPermissionsList(['Camera', 'Microphone', 'Notifications', 'Storage']),
            const SizedBox(height: 24),

            // Optional Permissions
            _buildSectionTitle('Optional Permissions'),
            const SizedBox(height: 12),
            _buildPermissionsList(['Location', 'Contacts', 'Photos', 'Calendar']),
            const SizedBox(height: 24),

            // Permission Summary
            _buildSectionTitle('Permission Summary'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: SwiftSnapTheme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: SwiftSnapTheme.borderColor,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  _buildSummaryRow(
                    'Allowed Permissions',
                    '${_permissions.values.where((v) => v).length}/${_permissions.length}',
                    Colors.green,
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryRow(
                    'Denied Permissions',
                    '${_permissions.values.where((v) => !v).length}/${_permissions.length}',
                    Colors.red,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            _buildActionButton(
              'Open System Settings',
              Icons.settings,
              () => _openSystemSettings(),
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              'Reset All Permissions',
              Icons.refresh,
              () => _showResetDialog(),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildPermissionsList(List<String> permissions) {
    return Container(
      decoration: BoxDecoration(
        color: SwiftSnapTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: SwiftSnapTheme.borderColor,
          width: 1,
        ),
      ),
      child: Column(
        children: permissions
            .asMap()
            .entries
            .map((entry) {
              final index = entry.key;
              final permission = entry.value;
              return Column(
                children: [
                  _buildPermissionTile(permission),
                  if (index < permissions.length - 1)
                    const Divider(
                      color: Colors.white10,
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                    ),
                ],
              );
            })
            .toList(),
      ),
    );
  }

  Widget _buildPermissionTile(String permission) {
    return SwitchListTile(
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              SwiftSnapTheme.primaryPurple.withOpacity(0.3),
              SwiftSnapTheme.primaryPink.withOpacity(0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          _permissionIcons[permission],
          color: Colors.white,
          size: 20,
        ),
      ),
      title: Text(
        permission,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        _permissionDescriptions[permission]!,
        style: const TextStyle(
          color: Colors.white60,
          fontSize: 13,
        ),
      ),
      value: _permissions[permission]!,
      onChanged: (value) {
        setState(() => _permissions[permission] = value);
        _showPermissionDialog(permission, value);
      },
      activeColor: SwiftSnapTheme.primaryPurple,
    );
  }

  Widget _buildSummaryRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 15,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: SwiftSnapTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: SwiftSnapTheme.borderColor,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPermissionDialog(String permission, bool granted) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SwiftSnapTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              _permissionIcons[permission],
              color: granted ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 12),
            Text(
              '$permission Permission',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          granted
              ? '$permission permission has been granted. You can now use features that require ${permission.toLowerCase()} access.'
              : '$permission permission has been denied. Some features may not work properly.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _openSystemSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening system settings...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SwiftSnapTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Reset All Permissions',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'This will reset all permissions to their default values. You\'ll need to grant permissions again when needed.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _permissions.updateAll((key, value) => false);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All permissions have been reset'),
                ),
              );
            },
            child: const Text(
              'Reset',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
