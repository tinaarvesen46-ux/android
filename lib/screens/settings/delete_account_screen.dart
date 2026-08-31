import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/social_provider.dart';
import '../../theme/theme.dart';
import '../../widgets/common/app_top_bar.dart';

/// Real deletion, gated by password confirmation — soft-deletes via
/// `POST /me/delete`, revokes all sessions server-side.
class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final _password = TextEditingController();
  bool _confirmed = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    if (_password.text.isEmpty) {
      setState(() => _error = 'Enter your password to confirm.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final error = await context.read<SocialProvider>().deleteAccount(_password.text);
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _busy = false;
        _error = error;
      });
      return;
    }
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;

    return Scaffold(
      body: Column(
        children: [
          const AppTopBar(showBack: true, title: 'Delete account'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              children: [
                Icon(Icons.warning_amber_rounded, size: AppTheme.iconHuge, color: appColors.danger),
                const SizedBox(height: AppTheme.spacingLg),
                Text('This is permanent', style: theme.textTheme.titleLarge),
                const SizedBox(height: AppTheme.spacingSm),
                Text(
                  'Deleting your account will sign you out everywhere, hide your profile, '
                  'stories and Spotlight posts from everyone, and cannot be undone from the app.',
                  style: theme.textTheme.bodyMedium?.copyWith(color: appColors.subtleText),
                ),
                const SizedBox(height: AppTheme.spacingXl),
                CheckboxListTile(
                  value: _confirmed,
                  onChanged: (v) => setState(() => _confirmed = v ?? false),
                  title: const Text('I understand this cannot be undone'),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: AppTheme.spacingMd),
                TextField(
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Confirm your password'),
                ),
                if (_error != null) ...[
                  const SizedBox(height: AppTheme.spacingMd),
                  Text(_error!, style: theme.textTheme.bodySmall?.copyWith(color: appColors.danger)),
                ],
                const SizedBox(height: AppTheme.spacingXl),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: appColors.danger),
                  onPressed: (_confirmed && !_busy) ? _delete : null,
                  child: _busy
                      ? const SizedBox(
                          width: AppTheme.iconSm,
                          height: AppTheme.iconSm,
                          child: CircularProgressIndicator(strokeWidth: AppTheme.borderThick),
                        )
                      : const Text('Delete my account'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
