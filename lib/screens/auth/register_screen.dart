import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/theme.dart';
import '../../widgets/auth/auth_step_scaffold.dart';

/// Five-step registration:
///   1 name  ·  2 birthday  ·  3 username  ·  4 password  ·  5 email
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final PageController _pageController = PageController();

  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _surname = TextEditingController();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _email = TextEditingController();

  DateTime? _birthday;
  int _step = 0;
  bool _obscurePassword = true;
  String? _stepError;

  static const int _stepCount = 5;

  @override
  void dispose() {
    _pageController.dispose();
    _firstName.dispose();
    _surname.dispose();
    _username.dispose();
    _password.dispose();
    _email.dispose();
    super.dispose();
  }

  String get _fullName => [
        _firstName.text.trim(),
        _surname.text.trim(),
      ].where((part) => part.isNotEmpty).join(' ');

  String? _validateCurrentStep() {
    switch (_step) {
      case 0:
        if (_firstName.text.trim().isEmpty) return 'Enter your first name.';
        return null;
      case 1:
        if (_birthday == null) return 'Select your birthday.';
        final now = DateTime.now();
        var age = now.year - _birthday!.year;
        final hadBirthday = now.month > _birthday!.month ||
            (now.month == _birthday!.month && now.day >= _birthday!.day);
        if (!hadBirthday) age -= 1;
        if (age < 13) return 'You must be at least 13 years old to join.';
        return null;
      case 2:
        final username = _username.text.trim();
        if (username.length < 3) {
          return 'Usernames need at least 3 characters.';
        }
        if (!RegExp(r'^[a-zA-Z0-9._]+$').hasMatch(username)) {
          return 'Use letters, numbers, dots and underscores only.';
        }
        return null;
      case 3:
        if (_password.text.length < 8) {
          return 'Passwords need at least 8 characters.';
        }
        return null;
      case 4:
        final email = _email.text.trim();
        if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
          return 'Enter a valid email address.';
        }
        return null;
      default:
        return null;
    }
  }

  Future<void> _next() async {
    final error = _validateCurrentStep();
    if (error != null) {
      setState(() => _stepError = error);
      return;
    }
    setState(() => _stepError = null);

    if (_step < _stepCount - 1) {
      setState(() => _step += 1);
      _pageController.animateToPage(
        _step,
        duration: AppTheme.animNormal,
        curve: Curves.easeOut,
      );
      return;
    }
    await _submit();
  }

  void _back() {
    if (_step == 0) {
      context.pop();
      return;
    }
    setState(() {
      _step -= 1;
      _stepError = null;
    });
    _pageController.animateToPage(
      _step,
      duration: AppTheme.animNormal,
      curve: Curves.easeOut,
    );
  }

  Future<void> _pickBirthday() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthday ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(now.year - 100),
      lastDate: now,
      helpText: 'Select your birthday',
    );
    if (picked != null) {
      setState(() {
        _birthday = picked;
        _stepError = null;
      });
    }
  }

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    final birthday = _birthday!;
    final formatted = '${birthday.year.toString().padLeft(4, '0')}-'
        '${birthday.month.toString().padLeft(2, '0')}-'
        '${birthday.day.toString().padLeft(2, '0')}';

    final success = await auth.register(
      name: _fullName,
      username: _username.text.trim(),
      email: _email.text.trim(),
      password: _password.text,
      birthday: formatted,
    );

    if (!mounted) return;
    if (success) {
      context.go('/login');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created. Sign in to continue.')),
      );
    } else {
      setState(() => _stepError = auth.error ?? 'Registration failed.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return AuthStepScaffold(
      step: _step,
      stepCount: _stepCount,
      title: _titles[_step],
      subtitle: _subtitles[_step],
      error: _stepError,
      isBusy: auth.isLoading,
      primaryLabel: _step == _stepCount - 1 ? 'Create account' : 'Next',
      onPrimary: _next,
      onBack: _back,
      child: SizedBox(
        height: 180,
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            Column(
              children: [
                TextField(
                  controller: _firstName,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(hintText: 'First name'),
                ),
                const SizedBox(height: AppTheme.spacingMd),
                TextField(
                  controller: _surname,
                  textCapitalization: TextCapitalization.words,
                  decoration:
                      const InputDecoration(hintText: 'Surname (optional)'),
                ),
              ],
            ),
            Align(
              alignment: Alignment.topCenter,
              child: OutlinedButton(
                onPressed: _pickBirthday,
                child: Text(
                  _birthday == null
                      ? 'Select birthday'
                      : '${_birthday!.day}/${_birthday!.month}/${_birthday!.year}',
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: TextField(
                controller: _username,
                autocorrect: false,
                decoration: const InputDecoration(
                  hintText: 'Username',
                  prefixText: '@',
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: TextField(
                controller: _password,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                decoration: const InputDecoration(hintText: 'Email address'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const List<String> _titles = [
    'What is your name?',
    'When is your birthday?',
    'Choose a username',
    'Set a password',
    'Your email address',
  ];

  static const List<String> _subtitles = [
    'This is the name your friends will see.',
    'Your birthday is used to confirm your age and is never shown publicly.',
    'Your username is how people find you on SwiftSnap.',
    'Use at least 8 characters.',
    'We use this to secure your account and help you recover it.',
  ];
}
