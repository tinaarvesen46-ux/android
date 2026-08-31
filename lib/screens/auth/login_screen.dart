import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/saved_accounts_store.dart';
import '../../theme/theme.dart';
import '../../widgets/common/snap_avatar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _identifier = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _obscure = true;
  bool _showManualForm = false;
  String? _error;
  bool _switching = false;

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
    } else if (auth.pendingTwoFactorToken != null) {
      context.push('/2fa-login');
    } else {
      setState(() => _error = auth.error ?? 'Sign in failed.');
    }
  }

  Future<void> _continueAs(SavedAccount account) async {
    setState(() {
      _switching = true;
      _error = null;
    });
    final auth = context.read<AuthProvider>();
    final success = await auth.switchToSavedAccount(account);
    if (!mounted) return;
    setState(() => _switching = false);
    if (success) {
      context.go('/chats');
    } else {
      setState(() => _error = auth.error ?? 'That session has expired.');
    }
  }

  Future<void> _removeSaved(SavedAccount account) async {
    await context.read<AuthProvider>().removeSavedAccount(account.userId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;
    final auth = context.watch<AuthProvider>();
    final savedAccounts = auth.savedAccounts;

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
                savedAccounts.isEmpty ? 'Welcome back' : 'Choose an account',
                style: theme.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingSm),
              Text(
                savedAccounts.isEmpty
                    ? 'Sign in with your username or email.'
                    : 'Tap an account to continue, or sign in with another one.',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: appColors.subtleText),
                textAlign: TextAlign.center,
              ),
              if (savedAccounts.isNotEmpty) ...[
                const SizedBox(height: AppTheme.spacingHuge),
                ...savedAccounts.map((account) => Padding(
                      padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
                      child: Material(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          onTap: _switching ? null : () => _continueAs(account),
                          child: Padding(
                            padding: const EdgeInsets.all(AppTheme.spacingMd),
                            child: Row(
                              children: [
                                SnapAvatar(
                                  imageUrl: account.avatarUrl,
                                  fallbackText: account.displayName,
                                  size: AppTheme.avatarMd,
                                ),
                                const SizedBox(width: AppTheme.spacingMd),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(account.displayName,
                                          style: theme.textTheme.bodyMedium),
                                      Text('@${account.username}',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                              color: appColors.subtleText)),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close_rounded, size: AppTheme.iconSm),
                                  onPressed: _switching ? null : () => _removeSaved(account),
                                  tooltip: 'Remove',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )),
                if (_switching) ...[
                  const SizedBox(height: AppTheme.spacingSm),
                  const Center(child: CircularProgressIndicator()),
                ],
                const SizedBox(height: AppTheme.spacingMd),
                TextButton(
                  onPressed: () => setState(() => _showManualForm = !_showManualForm),
                  child: Text(_showManualForm
                      ? 'Hide sign in form'
                      : 'Sign in with a different account'),
                ),
              ],
              if (savedAccounts.isEmpty || _showManualForm) ...[
                const SizedBox(height: AppTheme.spacingXl),
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
              ] else if (_error != null) ...[
                const SizedBox(height: AppTheme.spacingMd),
                Text(
                  _error!,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: appColors.danger),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
