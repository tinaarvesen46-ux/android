import 'package:flutter/material.dart';
import 'change_password_screen.dart';

/// Password settings entry — delegates to the real change-password form
/// (bound to Laravel POST /settings/password).
class PasswordSettingsScreen extends StatelessWidget {
  const PasswordSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => const ChangePasswordScreen();
}
