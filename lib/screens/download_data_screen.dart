import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/theme.dart';
import '../api/services/settings_service.dart';

/// Download my data — bound to Laravel POST /security/export-data.
/// Backend prepares a JSON export and returns {status, path, note}; the file is
/// made available to the account owner via support (server-side).
class DownloadDataScreen extends StatefulWidget {
  const DownloadDataScreen({super.key});

  @override
  State<DownloadDataScreen> createState() => _DownloadDataScreenState();
}

class _DownloadDataScreenState extends State<DownloadDataScreen> {
  final SettingsService _service = SettingsService();
  bool _requesting = false;
  Map<String, dynamic>? _result;
  String? _error;

  Future<void> _request() async {
    HapticFeedback.lightImpact();
    setState(() {
      _requesting = true;
      _error = null;
      _result = null;
    });
    final res = await _service.exportData();
    if (!mounted) return;
    setState(() {
      _requesting = false;
      if (res.isSuccess) {
        _result = res.data;
      } else {
        _error = res.errorMessage;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwiftSnapTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: SwiftSnapTheme.surfaceColor,
        title: const Text('Download My Data'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: SwiftSnapTheme.surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.download_rounded, color: SwiftSnapTheme.primaryPurple, size: 40),
                SizedBox(height: 12),
                Text('Request a copy of your data',
                    style: TextStyle(color: SwiftSnapTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
                SizedBox(height: 8),
                Text('We\'ll prepare a JSON export of your account, profile, settings and recent messages.',
                    style: TextStyle(color: SwiftSnapTheme.textSecondary, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (_result != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SwiftSnapTheme.accentGreen.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: SwiftSnapTheme.accentGreen.withOpacity(0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.check_circle_rounded, color: SwiftSnapTheme.accentGreen),
                      SizedBox(width: 8),
                      Text('Export ready',
                          style: TextStyle(color: SwiftSnapTheme.textPrimary, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('${_result!['note'] ?? 'Your data export has been prepared.'}',
                      style: const TextStyle(color: SwiftSnapTheme.textSecondary, fontSize: 13)),
                ],
              ),
            ),
          if (_error != null)
            Text(_error!, style: const TextStyle(color: SwiftSnapTheme.busy)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: SwiftSnapTheme.primaryPurple,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _requesting ? null : _request,
              child: _requesting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Request Data Export', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
