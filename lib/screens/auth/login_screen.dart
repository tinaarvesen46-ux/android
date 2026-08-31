import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _identifier = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final identifier = _identifier.text.trim();
    if (identifier.isEmpty || _password.text.isEmpty) {
      setState(() => _error = 'Enter your username or email and password.');
      return;
    }
    setState(() => _error = null);

    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      identifier: identifier,
      password: _password.text,
    );
    if (!mounted) return;
    if (success) {
      context.go('/chats');
    } else {
      setState(() => _error = auth.error ?? 'Sign in failed.');
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
          padding: EdgeInsets.only(
            left: AppTheme.spacingXl,
            right: AppTheme.spacingXl,
            top: AppTheme.spacingHuge,
            bottom: AppTheme.spacingXl + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Image.asset(
                  'assets/icons/app_icon.png',
                  width: AppTheme.avatarXl,
                  height: AppTheme.avatarXl,
                ),
              ),
              const SizedBox(height: AppTheme.spacingXl),
              Text(
                'Welcome back',
                style: theme.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingSm),
              Text(
                'Sign in with your username or email.',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: appColors.subtleText),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingHuge),
              TextField(
                controller: _identifier,
                autocorrect: false,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'Username or email',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              TextField(
                controller: _password,
                obscureText: _obscure,
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  hintText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: AppTheme.spacingMd),
                Text(
                  _error!,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: appColors.danger),
                ),
              ],
              const SizedBox(height: AppTheme.spacingXl),
              ElevatedButton(
                onPressed: auth.isLoading ? null : _submit,
                child: auth.isLoading
                    ? const SizedBox(
                        width: AppTheme.iconSm,
                        height: AppTheme.iconSm,
                        child: CircularProgressIndicator(
                          strokeWidth: AppTheme.borderThick,
                        ),
                      )
                    : const Text('Sign in'),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              TextButton(
                onPressed: () => context.push('/register'),
                child: const Text('Create an account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
