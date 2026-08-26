import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/theme.dart';
import '../api/services/settings_service.dart';

/// Change password — bound to Laravel POST /settings/password
/// (fields: current_password, new_password).
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  final SettingsService _service = SettingsService();
  bool _saving = false;
  bool _obscure = true;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_current.text.isEmpty || _next.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New password must be at least 8 characters')),
      );
      return;
    }
    if (_next.text != _confirm.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }
    HapticFeedback.lightImpact();
    setState(() => _saving = true);
    final res = await _service.changePassword(
      currentPassword: _current.text,
      newPassword: _next.text,
      newPasswordConfirmation: _confirm.text,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res.isSuccess ? 'Password updated' : res.errorMessage)),
    );
    if (res.isSuccess) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwiftSnapTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: SwiftSnapTheme.surfaceColor,
        title: const Text('Change Password'),
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
          _field('Current password', _current),
          _field('New password', _next),
          _field('Confirm new password', _confirm),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: SwiftSnapTheme.primaryPurple,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Update Password', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController c) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          controller: c,
          obscureText: _obscure,
          style: const TextStyle(color: SwiftSnapTheme.textPrimary),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: SwiftSnapTheme.textSecondary),
            filled: true,
            fillColor: SwiftSnapTheme.surfaceColor,
            suffixIcon: IconButton(
              icon: Icon(_obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  color: SwiftSnapTheme.textSecondary),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      );
}
