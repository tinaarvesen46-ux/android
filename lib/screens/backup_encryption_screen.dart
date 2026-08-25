import 'package:flutter/material.dart';
import '../theme/theme.dart';

class BackupEncryptionScreen extends StatefulWidget {
  const BackupEncryptionScreen({super.key});

  @override
  State<BackupEncryptionScreen> createState() => _BackupEncryptionScreenState();
}

class _BackupEncryptionScreenState extends State<BackupEncryptionScreen> {
  bool _backupEnabled = true;
  bool _encryptionEnabled = true;
  bool _autoBackup = true;
  String _backupFrequency = 'Daily';
  bool _includeMedia = true;
  bool _wifiOnly = true;

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
          'Backup & Encryption',
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
                      Icons.cloud_upload,
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
                          'Secure Backup',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Last backup: Today at 3:42 AM',
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

            // Backup Settings
            _buildSectionTitle('Backup Settings'),
            const SizedBox(height: 12),
            _buildSwitchTile(
              'Enable Backup',
              'Automatically backup your data',
              Icons.backup,
              _backupEnabled,
              (value) => setState(() => _backupEnabled = value),
            ),
            const SizedBox(height: 12),
            _buildSwitchTile(
              'End-to-End Encryption',
              'Encrypt backups with your password',
              Icons.lock,
              _encryptionEnabled,
              (value) => setState(() => _encryptionEnabled = value),
            ),
            const SizedBox(height: 12),
            _buildSwitchTile(
              'Auto Backup',
              'Backup automatically on schedule',
              Icons.schedule,
              _autoBackup,
              (value) => setState(() => _autoBackup = value),
            ),
            const SizedBox(height: 24),

            // Backup Frequency
            _buildSectionTitle('Backup Frequency'),
            const SizedBox(height: 12),
            Container(
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
                  _buildFrequencyOption('Daily', 'Backup every day'),
                  _buildDivider(),
                  _buildFrequencyOption('Weekly', 'Backup every week'),
                  _buildDivider(),
                  _buildFrequencyOption('Monthly', 'Backup every month'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Content Settings
            _buildSectionTitle('Backup Content'),
            const SizedBox(height: 12),
            _buildSwitchTile(
              'Include Media',
              'Backup photos and videos',
              Icons.photo_library,
              _includeMedia,
              (value) => setState(() => _includeMedia = value),
            ),
            const SizedBox(height: 12),
            _buildSwitchTile(
              'WiFi Only',
              'Only backup when connected to WiFi',
              Icons.wifi,
              _wifiOnly,
              (value) => setState(() => _wifiOnly = value),
            ),
            const SizedBox(height: 24),

            // Storage Info
            _buildSectionTitle('Storage Information'),
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
                  _buildStorageRow('Messages', '245 MB'),
                  const SizedBox(height: 12),
                  _buildStorageRow('Media Files', '1.2 GB'),
                  const SizedBox(height: 12),
                  _buildStorageRow('Documents', '89 MB'),
                  const Divider(color: Colors.white10, height: 24),
                  _buildStorageRow('Total Backup Size', '1.53 GB', isBold: true),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            _buildActionButton(
              'Backup Now',
              Icons.backup,
              () => _backupNow(),
              isPrimary: true,
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              'Restore from Backup',
              Icons.restore,
              () => _showRestoreDialog(),
              isPrimary: false,
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              'Delete All Backups',
              Icons.delete_forever,
              () => _showDeleteDialog(),
              isPrimary: false,
              isDestructive: true,
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

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
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
      child: SwitchListTile(
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
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 13,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: SwiftSnapTheme.primaryPurple,
      ),
    );
  }

  Widget _buildFrequencyOption(String title, String subtitle) {
    final isSelected = _backupFrequency == title;
    return ListTile(
      leading: Radio<String>(
        value: title,
        groupValue: _backupFrequency,
        onChanged: (value) => setState(() => _backupFrequency = value!),
        activeColor: SwiftSnapTheme.primaryPurple,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: Colors.white60,
          fontSize: 13,
        ),
      ),
      onTap: () => setState(() => _backupFrequency = title),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      color: Colors.white10,
      height: 1,
      indent: 16,
      endIndent: 16,
    );
  }

  Widget _buildStorageRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 15,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    VoidCallback onPressed, {
    required bool isPrimary,
    bool isDestructive = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: isPrimary
            ? LinearGradient(
                colors: [
                  SwiftSnapTheme.primaryPurple,
                  SwiftSnapTheme.primaryPink,
                ],
              )
            : null,
        color: isPrimary
            ? null
            : isDestructive
                ? Colors.red.withOpacity(0.1)
                : SwiftSnapTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDestructive
              ? Colors.red.withOpacity(0.3)
              : SwiftSnapTheme.borderColor,
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
                Icon(
                  icon,
                  color: isDestructive ? Colors.red : Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: isDestructive ? Colors.red : Colors.white,
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

  void _backupNow() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: SwiftSnapTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: SwiftSnapTheme.primaryPurple),
            const SizedBox(height: 16),
            const Text(
              'Backing up your data...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Backup completed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  void _showRestoreDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SwiftSnapTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Restore from Backup',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'This will restore your data from the last backup. Current data will be replaced.',
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Restore started...'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: Text(
              'Restore',
              style: TextStyle(color: SwiftSnapTheme.primaryPurple),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SwiftSnapTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete All Backups',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'This will permanently delete all your backups. This action cannot be undone.',
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All backups deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
