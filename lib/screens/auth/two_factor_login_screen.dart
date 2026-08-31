import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/theme.dart';

/// Real TOTP challenge shown after `/auth/login` returns
/// `two_factor_required`. Accepts either a 6-digit authenticator code or a
/// one-time recovery code — both verified server-side.
class TwoFactorLoginScreen extends StatefulWidget {
  const TwoFactorLoginScreen({super.key});

  @override
  State<TwoFactorLoginScreen> createState() => _TwoFactorLoginScreenState();
}

class _TwoFactorLoginScreenState extends State<TwoFactorLoginScreen> {
  final TextEditingController _code = TextEditingController();
  bool _useRecoveryCode = false;
  String? _error;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final value = _code.text.trim();
    if (value.isEmpty) {
      setState(() => _error = 'Enter your code.');
      return;
    }
    setState(() => _error = null);
    final auth = context.read<AuthProvider>();
    final success = await auth.verifyTwoFactor(
      code: _useRecoveryCode ? null : value,
      recoveryCode: _useRecoveryCode ? value : null,
    );
    if (!mounted) return;
    if (success) {
      context.go('/chats');
    } else {
      setState(() => _error = auth.error ?? 'Invalid code.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingXl,
            vertical: AppTheme.spacingHuge,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.shield_moon_rounded,
                  size: AppTheme.avatarLg, color: appColors.storyRing),
              const SizedBox(height: AppTheme.spacingXl),
              Text('Two-factor verification',
                  style: theme.textTheme.headlineMedium,
                  textAlign: TextAlign.center),
              const SizedBox(height: AppTheme.spacingSm),
              Text(
                _useRecoveryCode
                    ? 'Enter one of your saved recovery codes.'
                    : 'Enter the 6-digit code from your authenticator app.',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: appColors.subtleText),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingHuge),
              TextField(
                controller: _code,
                autofocus: true,
                keyboardType: _useRecoveryCode
                    ? TextInputType.text
                    : TextInputType.number,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall,
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  hintText: _useRecoveryCode ? 'XXXX-XXXX' : '000000',
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: AppTheme.spacingMd),
                Text(_error!,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: appColors.danger),
                    textAlign: TextAlign.center),
              ],
              const SizedBox(height: AppTheme.spacingXl),
              ElevatedButton(
                onPressed: auth.isLoading ? null : _submit,
                child: auth.isLoading
                    ? const SizedBox(
                        width: AppTheme.iconSm,
                        height: AppTheme.iconSm,
                        child: CircularProgressIndicator(
                            strokeWidth: AppTheme.borderThick),
                      )
                    : const Text('Verify'),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              TextButton(
                onPressed: () => setState(() {
                  _useRecoveryCode = !_useRecoveryCode;
                  _code.clear();
                  _error = null;
                }),
                child: Text(_useRecoveryCode
                    ? 'Use authenticator code instead'
                    : 'Use a recovery code instead'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
