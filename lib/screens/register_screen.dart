import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/theme.dart';
import '../providers/app_provider.dart';
import '../models/user_model.dart';
import 'terms_of_service_screen.dart';
import 'privacy_policy_screen.dart';
import '../api/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 1; // 1, 2, 3

  // Step 1 fields
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _selectedMonth;
  final _dayController = TextEditingController();
  final _yearController = TextEditingController();

  // Step 2 fields
  bool _useEmail = true; // true = email, false = phone
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  // Step 3 fields
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());
  int _resendSeconds = 58;
  Timer? _resendTimer;
  bool _isLoading = false;

  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _dayController.dispose();
    _yearController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    for (final c in _otpControllers) c.dispose();
    for (final f in _otpFocusNodes) f.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _goToStep(int step) {
    setState(() => _currentStep = step);
    _pageController.animateToPage(
      step - 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  void _startResendTimer() {
    _resendSeconds = 58;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendSeconds <= 0) {
        t.cancel();
      } else {
        setState(() => _resendSeconds--);
      }
    });
  }

  // ── Step 1 validation ────────────────────────────────────────────────────
  void _submitStep1() {
    HapticFeedback.lightImpact();
    if (_firstNameController.text.trim().isEmpty) {
      _showError('Please enter your first name');
      return;
    }
    if (_selectedMonth == null || _dayController.text.isEmpty || _yearController.text.isEmpty) {
      _showError('Please enter your birthday');
      return;
    }
    if (_usernameController.text.trim().isEmpty) {
      _showError('Please choose a username');
      return;
    }
    if (_passwordController.text.length < 8) {
      _showError('Password must be at least 8 characters');
      return;
    }
    _goToStep(2);
  }

  // ── Step 2 validation ────────────────────────────────────────────────────
  void _submitStep2() {
    HapticFeedback.lightImpact();
    if (_useEmail) {
      final email = _emailController.text.trim();
      if (email.isEmpty || !email.contains('@')) {
        _showError('Please enter a valid email address');
        return;
      }
    } else {
      if (_phoneController.text.trim().length < 8) {
        _showError('Please enter a valid phone number');
        return;
      }
    }
    _goToStep(3);
    _startResendTimer();
  }

  // ── Step 3 — verify OTP & complete registration ──────────────────────────
  void _submitStep3() async {
    HapticFeedback.mediumImpact();
    final code = _otpControllers.map((c) => c.text).join();
    if (code.length < 6) {
      _showError('Please enter the 6-digit code');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final auth = AuthService();
      final monthIndex = _selectedMonth != null ? _months.indexOf(_selectedMonth!) + 1 : 1;
      final dob = DateTime(
        int.tryParse(_yearController.text.trim()) ?? 2000,
        monthIndex < 1 ? 1 : monthIndex,
        int.tryParse(_dayController.text.trim()) ?? 1,
      );
      final res = await auth.register(
        username: _usernameController.text.trim(),
        email: _useEmail
            ? _emailController.text.trim()
            : '${_phoneController.text.trim()}@phone.local',
        password: _passwordController.text,
        passwordConfirmation: _passwordController.text,
        displayName: _firstNameController.text.trim() +
            (_lastNameController.text.trim().isNotEmpty
                ? ' ${_lastNameController.text.trim()}'
                : ''),
        dateOfBirth: dob,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim().isEmpty
            ? null
            : _lastNameController.text.trim(),
      );

      if (!res.isSuccess || res.data == null) {
        if (mounted) {
          setState(() => _isLoading = false);
          _showError(res.errorMessage);
        }
        return;
      }

      final payload = res.data!;
      final tokenRaw = payload['access_token'] ?? payload['token'] ?? payload['access'];
      final token = tokenRaw is String ? tokenRaw : '';
      final refreshRaw = payload['refresh_token'] ?? payload['refresh'];
      final refresh = refreshRaw is String ? refreshRaw : token;
      if (token.isNotEmpty) await auth.saveTokens(token, refresh);

      UserModel? user;
      final inlineUser = payload['user'] ?? payload['data'];
      if (inlineUser is Map<String, dynamic>) {
        try {
          user = UserModel.fromJson(inlineUser);
        } catch (_) {}
      }
      user ??= (await auth.getCurrentUser()).data;

      if (!mounted) return;
      setState(() => _isLoading = false);
      if (user == null) {
        _showError('Account created, but could not load your profile.');
        return;
      }
      Provider.of<AppProvider>(context, listen: false).login(user);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Registration failed. Please try again.');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: SwiftSnapTheme.busy,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwiftSnapTheme.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildProgressBar(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── HEADER ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          if (_currentStep > 1)
            GestureDetector(
              onTap: () => _goToStep(_currentStep - 1),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: SwiftSnapTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: SwiftSnapTheme.textPrimary, size: 18),
              ),
            )
          else
            const SizedBox(width: 40),
          const SizedBox(width: 12),
          // Logo + Title
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [
                SwiftSnapTheme.primaryPurple,
                SwiftSnapTheme.primaryPink,
              ]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.flash_on_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sign Up',
                style: TextStyle(
                  color: SwiftSnapTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Step $_currentStep of 3',
                style: const TextStyle(
                  color: SwiftSnapTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: List.generate(3, (i) {
          final active = i < _currentStep;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 3,
              margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: active
                    ? const LinearGradient(colors: [
                        SwiftSnapTheme.primaryPurple,
                        SwiftSnapTheme.primaryPink,
                      ])
                    : null,
                color: active ? null : SwiftSnapTheme.surfaceLight,
              ),
            ),
          );
        }),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // STEP 1 — Name, Birthday, Username, Password
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          // Social sign-in row
          Row(
            children: [
              Expanded(child: _buildGoogleButton()),
              const SizedBox(width: 12),
              Expanded(child: _buildAppleButton()),
            ],
          ),
          const SizedBox(height: 20),
          _buildOrDivider(),
          const SizedBox(height: 20),

          // Name
          _buildLabel('NAME'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildTextField(_firstNameController, 'First name')),
              const SizedBox(width: 12),
              Expanded(child: _buildTextField(_lastNameController, 'Last name (optional)')),
            ],
          ),
          const SizedBox(height: 20),

          // Birthday
          _buildLabel('BIRTHDAY'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: _buildMonthDropdown(),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: _buildTextField(
                  _dayController,
                  'Day',
                  keyboardType: TextInputType.number,
                  maxLength: 2,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: _buildTextField(
                  _yearController,
                  'Year',
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Username
          _buildLabel('USERNAME'),
          const SizedBox(height: 8),
          _buildTextField(_usernameController, 'Enter your username'),
          const SizedBox(height: 4),
          const Text(
            'You can change this later',
            style: TextStyle(color: SwiftSnapTheme.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 20),

          // Password
          _buildLabel('PASSWORD'),
          const SizedBox(height: 8),
          _buildPasswordField(),
          const SizedBox(height: 4),
          const Text(
            'Password must be at least 8 characters',
            style: TextStyle(color: SwiftSnapTheme.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 24),

          // Terms
          _buildTermsText(),
          const SizedBox(height: 20),

          // CTA
          _buildGradientButton('Agree and Continue', _submitStep1),
          const SizedBox(height: 20),
          _buildLoginLink(),
          const SizedBox(height: 16),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // STEP 2 — Email OR Phone choice
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 32),

          // Toggle pills — Email / Phone
          _buildContactToggle(),
          const SizedBox(height: 28),

          if (_useEmail) ...[
            _buildLabel('EMAIL ADDRESS'),
            const SizedBox(height: 8),
            _buildTextField(
              _emailController,
              'you@example.com',
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
            ),
          ] else ...[
            _buildLabel('PHONE NUMBER'),
            const SizedBox(height: 8),
            _buildTextField(
              _phoneController,
              '+1 555 000 0000',
              keyboardType: TextInputType.phone,
              autofocus: true,
            ),
          ],

          const SizedBox(height: 8),
          Text(
            _useEmail
                ? 'We\'ll send a confirmation code to this email.'
                : 'We\'ll send a confirmation code via SMS.',
            style: const TextStyle(
                color: SwiftSnapTheme.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 32),

          _buildGradientButton('Next', _submitStep2),
          const SizedBox(height: 20),
          _buildLoginLink(),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildContactToggle() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: SwiftSnapTheme.surfaceColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(child: _buildTogglePill('Email', true)),
          Expanded(child: _buildTogglePill('Phone', false)),
        ],
      ),
    );
  }

  Widget _buildTogglePill(String label, bool isEmail) {
    final isActive = _useEmail == isEmail;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _useEmail = isEmail);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(colors: [
                  SwiftSnapTheme.primaryPurple,
                  SwiftSnapTheme.primaryPink,
                ])
              : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : SwiftSnapTheme.textSecondary,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // STEP 3 — OTP confirmation code
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildStep3() {
    final contact = _useEmail
        ? _emailController.text.trim()
        : _phoneController.text.trim();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 32),

          Text(
            'We sent a confirmation code to',
            style: TextStyle(
                color: SwiftSnapTheme.textSecondary, fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            contact,
            style: const TextStyle(
              color: SwiftSnapTheme.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 32),

          _buildLabel('CONFIRMATION CODE'),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(),
              Text(
                _resendSeconds > 0
                    ? 'Resend code in ${_resendSeconds}s'
                    : 'Resend code',
                style: TextStyle(
                  color: _resendSeconds > 0
                      ? SwiftSnapTheme.textMuted
                      : SwiftSnapTheme.primaryPink,
                  fontSize: 13,
                  fontWeight: _resendSeconds <= 0 ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // OTP boxes
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(6, (i) => _buildOtpBox(i)),
          ),

          const SizedBox(height: 40),

          _isLoading
              ? const Center(child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(SwiftSnapTheme.primaryPurple),
                ))
              : _buildGradientButton('Next', _submitStep3),

          const SizedBox(height: 20),
          _buildLoginLink(),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildOtpBox(int index) {
    return Expanded(
      child: Container(
        height: 56,
        margin: EdgeInsets.only(right: index < 5 ? 8 : 0),
        decoration: BoxDecoration(
          color: SwiftSnapTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _otpFocusNodes[index].hasFocus
                ? SwiftSnapTheme.primaryPurple
                : Colors.white.withOpacity(0.1),
            width: _otpFocusNodes[index].hasFocus ? 2 : 1,
          ),
        ),
        child: TextField(
          controller: _otpControllers[index],
          focusNode: _otpFocusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: const TextStyle(
            color: SwiftSnapTheme.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            counterText: '',
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (val) {
            if (val.isNotEmpty && index < 5) {
              _otpFocusNodes[index + 1].requestFocus();
            }
            if (val.isEmpty && index > 0) {
              _otpFocusNodes[index - 1].requestFocus();
            }
            setState(() {}); // Refresh border color
          },
          onTap: () => setState(() {}),
        ),
      ),
    );
  }

  // ── SHARED WIDGETS ────────────────────────────────────────────────────────

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: SwiftSnapTheme.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    bool autofocus = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: SwiftSnapTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLength: maxLength,
        autofocus: autofocus,
        style: const TextStyle(color: SwiftSnapTheme.textPrimary, fontSize: 15),
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
          hintText: hint,
          counterText: '',
          hintStyle: TextStyle(
            color: SwiftSnapTheme.textSecondary.withOpacity(0.5),
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildMonthDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: SwiftSnapTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedMonth,
          hint: const Text('Month',
              style: TextStyle(
                  color: SwiftSnapTheme.textSecondary, fontSize: 15)),
          isExpanded: true,
          dropdownColor: SwiftSnapTheme.backgroundCard,
          iconEnabledColor: SwiftSnapTheme.textSecondary,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          style: const TextStyle(
              color: SwiftSnapTheme.textPrimary, fontSize: 15),
          borderRadius: BorderRadius.circular(12),
          items: _months
              .map((m) => DropdownMenuItem(value: m, child: Text(m)))
              .toList(),
          onChanged: (val) => setState(() => _selectedMonth = val),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: SwiftSnapTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        style: const TextStyle(color: SwiftSnapTheme.textPrimary, fontSize: 15),
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
          hintText: 'Enter a secure password',
          hintStyle: TextStyle(
            color: SwiftSnapTheme.textSecondary.withOpacity(0.5),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_rounded
                  : Icons.visibility_off_rounded,
              color: SwiftSnapTheme.textSecondary,
              size: 20,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        // TODO: call GoogleSignIn().signIn() after adding google_sign_in package
        // and placing google-services.json + GoogleService-Info.plist.
        // See lib/config/oauth_config.dart for setup instructions.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Google Sign-In: add google_sign_in package & keys to enable'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: SwiftSnapTheme.surfaceColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: const Center(
                child: Text(
                  'G',
                  style: TextStyle(
                    color: Color(0xFF4285F4),
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Google',
              style: TextStyle(
                color: SwiftSnapTheme.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppleButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        // TODO: call SignInWithApple.getAppleIDCredential() after adding
        // sign_in_with_apple package and configuring Apple Developer portal.
        // See lib/config/oauth_config.dart for setup instructions.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Apple Sign-In: add sign_in_with_apple package & keys to enable'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: SwiftSnapTheme.surfaceColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.apple_rounded,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'Apple',
              style: TextStyle(
                color: SwiftSnapTheme.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text('OR',
              style: TextStyle(
                  color: SwiftSnapTheme.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ),
        Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
      ],
    );
  }

  Widget _buildTermsText() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(color: SwiftSnapTheme.textSecondary, fontSize: 13),
        children: [
          const TextSpan(text: 'By tapping "Agree and Continue" you agree to the '),
          WidgetSpan(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TermsOfServiceScreen(),
                  ),
                );
              },
              child: const Text(
                'Terms of Service',
                style: TextStyle(
                  color: SwiftSnapTheme.primaryPink,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  decoration: TextDecoration.underline,
                  decorationColor: SwiftSnapTheme.primaryPink,
                ),
              ),
            ),
          ),
          const TextSpan(text: ' and acknowledge you have read the '),
          WidgetSpan(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PrivacyPolicyScreen(),
                  ),
                );
              },
              child: const Text(
                'Privacy Policy',
                style: TextStyle(
                  color: SwiftSnapTheme.primaryPink,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  decoration: TextDecoration.underline,
                  decorationColor: SwiftSnapTheme.primaryPink,
                ),
              ),
            ),
          ),
          const TextSpan(text: '.'),
        ],
      ),
    );
  }

  Widget _buildGradientButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [
            SwiftSnapTheme.primaryPurple,
            SwiftSnapTheme.primaryPink,
          ]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: SwiftSnapTheme.primaryPurple.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: TextStyle(color: SwiftSnapTheme.textSecondary, fontSize: 14),
        ),
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
          child: const Text(
            'Log in',
            style: TextStyle(
              color: SwiftSnapTheme.primaryPink,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
