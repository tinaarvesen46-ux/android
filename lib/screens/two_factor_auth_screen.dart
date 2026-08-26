import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/theme.dart';
import '../api/services/settings_service.dart';

/// Two-Factor Authentication — bound to Laravel /settings/2fa/{enable,disable,verify}.
/// Current status is read from users/me (two_factor_enabled).
/// NOTE: backend TOTP verification is currently a placeholder (accepts any 6-digit
/// code while 2FA is enabled); the secret/otpauth returned by enable is real.
class TwoFactorAuthScreen extends StatefulWidget {
  const TwoFactorAuthScreen({super.key});

  @override
  State<TwoFactorAuthScreen> createState() => _TwoFactorAuthScreenState();
}

class _TwoFactorAuthScreenState extends State<TwoFactorAuthScreen> {
  final SettingsService _service = SettingsService();
  bool _loading = true;
  bool _busy = false;
  bool _enabled = false;
  String? _secret;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final res = await _service.getTwoFactorStatus();
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (res.isSuccess) {
        _enabled = res.data ?? false;
      } else {
        _error = res.errorMessage;
      }
    });
  }

  Future<void> _enable() async {
    HapticFeedback.lightImpact();
    setState(() => _busy = true);
    final res = await _service.enable2FA();
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (res.isSuccess && res.data != null) {
        _enabled = true;
        _secret = res.data!['secret']?.toString();
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res.isSuccess ? 'Two-factor authentication enabled' : res.errorMessage)),
    );
  }

  Future<void> _disable() async {
    final controller = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SwiftSnapTheme.surfaceColor,
        title: const Text('Disable 2FA', style: TextStyle(color: SwiftSnapTheme.textPrimary)),
        content: TextField(
          controller: controller,
          obscureText: true,
          style: const TextStyle(color: SwiftSnapTheme.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Confirm with your password',
            hintStyle: TextStyle(color: SwiftSnapTheme.textSecondary),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Disable')),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _busy = true);
    final res = await _service.disable2FA(password: controller.text);
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (res.isSuccess) {
        _enabled = false;
        _secret = null;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res.isSuccess ? 'Two-factor authentication disabled' : res.errorMessage)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwiftSnapTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: SwiftSnapTheme.surfaceColor,
        title: const Text('Two-Factor Authentication'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: SwiftSnapTheme.primaryPurple));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: SwiftSnapTheme.textSecondary)),
            const SizedBox(height: 12),
            TextButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: SwiftSnapTheme.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Row(
            children: [
              Icon(_enabled ? Icons.verified_user_rounded : Icons.shield_outlined,
                  color: _enabled ? SwiftSnapTheme.accentGreen : SwiftSnapTheme.textSecondary, size: 40),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_enabled ? '2FA is ON' : '2FA is OFF',
                        style: const TextStyle(color: SwiftSnapTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
                    Text(
                      _enabled
                          ? 'Your account has an extra layer of security.'
                          : 'Add an extra layer of security to your account.',
                      style: const TextStyle(color: SwiftSnapTheme.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_secret != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: SwiftSnapTheme.backgroundCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: SwiftSnapTheme.primaryPurple.withOpacity(0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Your authenticator secret',
                    style: TextStyle(color: SwiftSnapTheme.textSecondary, fontSize: 13)),
                const SizedBox(height: 8),
                SelectableText(_secret!,
                    style: const TextStyle(color: SwiftSnapTheme.textPrimary, fontSize: 18, letterSpacing: 2, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                const Text('Add this key to your authenticator app (e.g. Google Authenticator).',
                    style: TextStyle(color: SwiftSnapTheme.textSecondary, fontSize: 12)),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _enabled ? SwiftSnapTheme.busy : SwiftSnapTheme.primaryPurple,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: _busy ? null : (_enabled ? _disable : _enable),
            child: _busy
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(_enabled ? 'Disable 2FA' : 'Enable 2FA',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }
}
