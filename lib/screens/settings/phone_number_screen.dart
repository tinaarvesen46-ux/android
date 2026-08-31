import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api_failure.dart';
import '../../repositories/account_repository.dart';
import '../../theme/theme.dart';
import '../../widgets/common/app_top_bar.dart';

/// Real phone verification via Twilio SMS. Until an operator configures
/// TWILIO_ACCOUNT_SID/AUTH_TOKEN/FROM_NUMBER on the server, send-code
/// returns a genuine 503 here — never a fake "sent" state.
class PhoneNumberScreen extends StatefulWidget {
  const PhoneNumberScreen({super.key});

  @override
  State<PhoneNumberScreen> createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  final _phone = TextEditingController();
  final _code = TextEditingController();
  bool _codeSent = false;
  bool _busy = false;
  String? _error;
  String? _verifiedPhone;

  @override
  void dispose() {
    _phone.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final phone = _phone.text.trim();
    if (!RegExp(r'^\+[1-9]\d{6,14}$').hasMatch(phone)) {
      setState(() => _error = 'Enter your number in international format, e.g. +15551234567.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await context.read<AccountRepository>().sendPhoneCode(phone);
      setState(() => _codeSent = true);
    } on ApiFailure catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _verify() async {
    if (_code.text.trim().length != 6) {
      setState(() => _error = 'Enter the 6-digit code.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await context.read<AccountRepository>().verifyPhoneCode(_code.text.trim());
      setState(() => _verifiedPhone = _phone.text.trim());
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
          const AppTopBar(showBack: true, title: 'Mobile number'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              children: [
                if (_verifiedPhone != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle_rounded, size: AppTheme.iconHuge, color: appColors.success),
                      const SizedBox(height: AppTheme.spacingMd),
                      Text('$_verifiedPhone is verified', style: theme.textTheme.titleMedium),
                    ],
                  )
                else if (!_codeSent)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Add and verify a mobile number for account recovery.',
                          style: theme.textTheme.bodyMedium),
                      const SizedBox(height: AppTheme.spacingLg),
                      TextField(
                        controller: _phone,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone number',
                          hintText: '+15551234567',
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingXl),
                      ElevatedButton(
                        onPressed: _busy ? null : _sendCode,
                        child: _busy
                            ? const SizedBox(
                                width: AppTheme.iconSm,
                                height: AppTheme.iconSm,
                                child: CircularProgressIndicator(strokeWidth: AppTheme.borderThick),
                              )
                            : const Text('Send code'),
                      ),
                    ],
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Enter the code sent to ${_phone.text}', style: theme.textTheme.bodyMedium),
                      const SizedBox(height: AppTheme.spacingLg),
                      TextField(
                        controller: _code,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: '000000'),
                      ),
                      const SizedBox(height: AppTheme.spacingXl),
                      ElevatedButton(
                        onPressed: _busy ? null : _verify,
                        child: _busy
                            ? const SizedBox(
                                width: AppTheme.iconSm,
                                height: AppTheme.iconSm,
                                child: CircularProgressIndicator(strokeWidth: AppTheme.borderThick),
                              )
                            : const Text('Verify'),
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
