import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/api_failure.dart';
import '../../models/account.dart';
import '../../providers/auth_provider.dart';
import '../../repositories/account_repository.dart';
import '../../theme/theme.dart';
import '../../widgets/common/app_top_bar.dart';
import '../../widgets/common/settings_rows.dart';

enum _Step { intro, scanQr, confirmCode, recoveryCodes, disable }

/// Real TOTP setup: generates a secret server-side, shows it as a QR
/// (otpauth://) for any authenticator app, requires a valid 6-digit code
/// before activating, then shows one-time recovery codes.
class TwoFactorScreen extends StatefulWidget {
  final bool initiallyEnabled;
  const TwoFactorScreen({super.key, required this.initiallyEnabled});

  @override
  State<TwoFactorScreen> createState() => _TwoFactorScreenState();
}

class _TwoFactorScreenState extends State<TwoFactorScreen> {
  late bool _enabled = widget.initiallyEnabled;
  _Step _step = _Step.intro;
  TwoFactorSetup? _setup;
  List<String> _recoveryCodes = [];
  final _code = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _code.dispose();
    _password.dispose();
    super.dispose();
  }

  AccountRepository get _repo => context.read<AccountRepository>();

  Future<void> _startSetup() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final setup = await _repo.startTwoFactorSetup();
      setState(() {
        _setup = setup;
        _step = _Step.scanQr;
      });
    } on ApiFailure catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirmCode() async {
    if (_code.text.trim().length != 6) {
      setState(() => _error = 'Enter the 6-digit code.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final codes = await _repo.confirmTwoFactorSetup(_code.text.trim());
      if (!mounted) return;
      context.read<AuthProvider>().setTwoFactorEnabled(true);
      setState(() {
        _recoveryCodes = codes;
        _step = _Step.recoveryCodes;
        _enabled = true;
      });
    } on ApiFailure catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _disable() async {
    if (_password.text.isEmpty || _code.text.trim().length != 6) {
      setState(() => _error = 'Enter your password and current 6-digit code.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await _repo.disableTwoFactor(password: _password.text, code: _code.text.trim());
      if (!mounted) return;
      context.read<AuthProvider>().setTwoFactorEnabled(false);
      setState(() {
        _enabled = false;
        _step = _Step.intro;
      });
    } on ApiFailure catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const AppTopBar(showBack: true, title: 'Two-factor authentication'),
          Expanded(child: _body(context)),
        ],
      ),
    );
  }

  Widget _body(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;

    switch (_step) {
      case _Step.intro:
        return ListView(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          children: [
            Icon(
              _enabled ? Icons.verified_user_rounded : Icons.shield_outlined,
              size: AppTheme.iconHuge,
              color: _enabled ? appColors.success : appColors.subtleText,
            ),
            const SizedBox(height: AppTheme.spacingLg),
            Text(
              _enabled
                  ? 'Two-factor authentication is on.'
                  : 'Add an authenticator app as a second step when signing in.',
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingXl),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
                child: Text(_error!, style: theme.textTheme.bodySmall?.copyWith(color: appColors.danger)),
              ),
            ElevatedButton(
              onPressed: _busy
                  ? null
                  : () => _enabled
                      ? setState(() => _step = _Step.disable)
                      : _startSetup(),
              child: _busy
                  ? const SizedBox(
                      width: AppTheme.iconSm,
                      height: AppTheme.iconSm,
                      child: CircularProgressIndicator(strokeWidth: AppTheme.borderThick),
                    )
                  : Text(_enabled ? 'Turn off' : 'Turn on'),
            ),
          ],
        );

      case _Step.scanQr:
        final setup = _setup!;
        return ListView(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          children: [
            Text('1. Scan this QR with your authenticator app',
                style: theme.textTheme.titleSmall),
            const SizedBox(height: AppTheme.spacingLg),
            Center(
              child: Container(
                padding: const EdgeInsets.all(AppTheme.spacingLg),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                ),
                child: QrImageView(data: setup.otpauthUri, size: 180),
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            SettingsInfoRow(title: 'Can\'t scan? Enter manually', value: setup.secret),
            const SizedBox(height: AppTheme.spacingXl),
            Text('2. Enter the 6-digit code it shows', style: theme.textTheme.titleSmall),
            const SizedBox(height: AppTheme.spacingMd),
            TextField(
              controller: _code,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(hintText: '000000'),
            ),
            if (_error != null) ...[
              const SizedBox(height: AppTheme.spacingMd),
              Text(_error!, style: theme.textTheme.bodySmall?.copyWith(color: appColors.danger)),
            ],
            const SizedBox(height: AppTheme.spacingXl),
            ElevatedButton(
              onPressed: _busy ? null : _confirmCode,
              child: _busy
                  ? const SizedBox(
                      width: AppTheme.iconSm,
                      height: AppTheme.iconSm,
                      child: CircularProgressIndicator(strokeWidth: AppTheme.borderThick),
                    )
                  : const Text('Confirm and turn on'),
            ),
          ],
        );

      case _Step.confirmCode:
        return const SizedBox.shrink();

      case _Step.recoveryCodes:
        return ListView(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          children: [
            Icon(Icons.check_circle_rounded, size: AppTheme.iconHuge, color: appColors.success),
            const SizedBox(height: AppTheme.spacingLg),
            Text('Two-factor authentication is on', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              'Save these recovery codes somewhere safe. Each one can be used once if you lose access to your authenticator app.',
              style: theme.textTheme.bodySmall?.copyWith(color: appColors.subtleText),
            ),
            const SizedBox(height: AppTheme.spacingLg),
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              ),
              child: Wrap(
                spacing: AppTheme.spacingMd,
                runSpacing: AppTheme.spacingSm,
                children: _recoveryCodes
                    .map((c) => Text(c, style: theme.textTheme.bodyMedium))
                    .toList(),
              ),
            ),
            const SizedBox(height: AppTheme.spacingXl),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('I\'ve saved these codes'),
            ),
          ],
        );

      case _Step.disable:
        return ListView(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          children: [
            Text('Enter your password and current authenticator code to turn off 2FA.',
                style: theme.textTheme.bodyMedium),
            const SizedBox(height: AppTheme.spacingLg),
            TextField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            TextField(
              controller: _code,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '6-digit code'),
            ),
            if (_error != null) ...[
              const SizedBox(height: AppTheme.spacingMd),
              Text(_error!, style: theme.textTheme.bodySmall?.copyWith(color: appColors.danger)),
            ],
            const SizedBox(height: AppTheme.spacingXl),
            ElevatedButton(
              onPressed: _busy ? null : _disable,
              child: _busy
                  ? const SizedBox(
                      width: AppTheme.iconSm,
                      height: AppTheme.iconSm,
                      child: CircularProgressIndicator(strokeWidth: AppTheme.borderThick),
                    )
                  : const Text('Turn off 2FA'),
            ),
          ],
        );
    }
  }
}
