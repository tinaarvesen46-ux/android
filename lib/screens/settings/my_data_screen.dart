import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/api_failure.dart';
import '../../repositories/account_repository.dart';
import '../../theme/theme.dart';
import '../../widgets/common/app_top_bar.dart';

class MyDataScreen extends StatefulWidget {
  const MyDataScreen({super.key});

  @override
  State<MyDataScreen> createState() => _MyDataScreenState();
}

class _MyDataScreenState extends State<MyDataScreen> {
  bool _busy = false;
  String? _downloadUrl;
  String? _error;

  Future<void> _requestExport() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final url = await context.read<AccountRepository>().exportData();
      setState(() => _downloadUrl = url);
    } on ApiFailure catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;

    return Scaffold(
      body: Column(
        children: [
          const AppTopBar(showBack: true, title: 'My Data'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              children: [
                Text(
                  'Request a copy of your SwiftSnap account data — profile, settings and message history you\'ve sent.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: AppTheme.spacingXl),
                if (_downloadUrl == null)
                  ElevatedButton(
                    onPressed: _busy ? null : _requestExport,
                    child: _busy
                        ? const SizedBox(
                            width: AppTheme.iconSm,
                            height: AppTheme.iconSm,
                            child: CircularProgressIndicator(strokeWidth: AppTheme.borderThick),
                          )
                        : const Text('Request my data'),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your export is ready.', style: theme.textTheme.titleSmall),
                      const SizedBox(height: AppTheme.spacingSm),
                      ElevatedButton.icon(
                        onPressed: () => launchUrl(Uri.parse(_downloadUrl!), mode: LaunchMode.externalApplication),
                        icon: const Icon(Icons.download_rounded),
                        label: const Text('Download'),
                      ),
                    ],
                  ),
                if (_error != null) ...[
                  const SizedBox(height: AppTheme.spacingMd),
                  Text(_error!, style: theme.textTheme.bodySmall?.copyWith(color: appColors.danger)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
