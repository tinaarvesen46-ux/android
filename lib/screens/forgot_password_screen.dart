import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/theme.dart';
import '../api/services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  int _step = 1; // 1 = enter contact, 2 = enter OTP, 3 = new password

  bool _useEmail = true;
  final _contactController = TextEditingController();
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  int _resendSeconds = 58;
  Timer? _resendTimer;

  @override
  void dispose() {
    _contactController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    for (final c in _otpControllers) c.dispose();
    for (final f in _otpFocusNodes) f.dispose();
    _resendTimer?.cancel();
    super.dispose();
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

  void _submitStep1() async {
    HapticFeedback.lightImpact();
    final val = _contactController.text.trim();
    if (val.isEmpty) {
      _showError(_useEmail ? 'Please enter your email' : 'Please enter your phone number');
      return;
    }
    setState(() => _isLoading = true);
    final res = await AuthService().forgotPassword(email: val);
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (!res.isSuccess) {
      _showError(res.errorMessage.isNotEmpty
          ? res.errorMessage
          : 'Could not send a reset code. Please try again.');
      return;
    }
    setState(() => _step = 2);
    _startResendTimer();
  }

  void _submitStep2() {
    HapticFeedback.lightImpact();
    final code = _otpControllers.map((c) => c.text).join();
    if (code.length < 6) {
      _showError('Please enter the 6-digit code');
      return;
    }
    setState(() => _step = 3);
  }

  void _submitStep3() async {
    HapticFeedback.mediumImpact();
    if (_newPasswordController.text.length < 8) {
      _showError('Password must be at least 8 characters');
      return;
    }
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showError('Passwords do not match');
      return;
    }
    setState(() => _isLoading = true);
    final code = _otpControllers.map((c) => c.text).join();
    final res = await AuthService().resetPassword(
      email: _contactController.text.trim(),
      token: code,
      password: _newPasswordController.text,
      passwordConfirmation: _confirmPasswordController.text,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (!res.isSuccess) {
      _showError(res.errorMessage.isNotEmpty
          ? res.errorMessage
          : 'Reset failed. Check the code and try again.');
      return;
    }
    _showSuccess();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: SwiftSnapTheme.busy,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  void _showSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: SwiftSnapTheme.backgroundCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [
                  SwiftSnapTheme.primaryPurple,
                  SwiftSnapTheme.primaryPink,
                ]),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 16),
            const Text(
              'Password Reset!',
              style: TextStyle(
                color: SwiftSnapTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your password has been updated. You can now log in with your new password.',
              textAlign: TextAlign.center,
              style: TextStyle(color: SwiftSnapTheme.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.pop(ctx);
                Navigator.pop(context); // back to login
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [
                    SwiftSnapTheme.primaryPurple,
                    SwiftSnapTheme.primaryPink,
                  ]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'Back to Login',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _step == 1
                    ? _buildStep1()
                    : _step == 2
                        ? _buildStep2()
                        : _buildStep3(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (_step > 1) {
                setState(() => _step--);
              } else {
                Navigator.pop(context);
              }
            },
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
          ),
          const SizedBox(width: 12),
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
                'Reset Password',
                style: TextStyle(
                  color: SwiftSnapTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Step $_step of 3',
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
          final active = i < _step;
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

  // ── STEP 1 — Enter email or phone ─────────────────────────────────────────

  Widget _buildStep1() {
    return SingleChildScrollView(
      key: const ValueKey('step1'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 32),
          // Lock illustration
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [
                  SwiftSnapTheme.primaryPurple,
                  SwiftSnapTheme.primaryPink,
                ]),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: SwiftSnapTheme.primaryPurple.withOpacity(0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.lock_reset_rounded,
                  color: Colors.white, size: 38),
            ),
          ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
          const SizedBox(height: 24),

          const Text(
            'Forgot your password?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: SwiftSnapTheme.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No worries! Enter your email or phone and we\'ll send you a reset code.',
            textAlign: TextAlign.center,
            style: TextStyle(color: SwiftSnapTheme.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 32),

          // Toggle
          _buildContactToggle(),
          const SizedBox(height: 20),

          if (_useEmail) ...[
            _buildLabel('EMAIL ADDRESS'),
            const SizedBox(height: 8),
            _buildTextField(
              _contactController,
              'you@example.com',
              keyboardType: TextInputType.emailAddress,
            ),
          ] else ...[
            _buildLabel('PHONE NUMBER'),
            const SizedBox(height: 8),
            _buildTextField(
              _contactController,
              '+1 555 000 0000',
              keyboardType: TextInputType.phone,
            ),
          ],

          const SizedBox(height: 32),

          _isLoading
              ? const Center(child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(SwiftSnapTheme.primaryPurple),
                ))
              : _buildGradientButton('Send Reset Code', _submitStep1),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  // ── STEP 2 — Enter OTP ───────────────────────────────────────────────────

  Widget _buildStep2() {
    final contact = _contactController.text.trim();
    return SingleChildScrollView(
      key: const ValueKey('step2'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 32),
          Text(
            'We sent a confirmation code to',
            style: TextStyle(color: SwiftSnapTheme.textSecondary, fontSize: 15),
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

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLabel('CONFIRMATION CODE'),
              GestureDetector(
                onTap: _resendSeconds <= 0 ? () {
                  _submitStep1();
                  _startResendTimer();
                } : null,
                child: Text(
                  _resendSeconds > 0
                      ? 'Resend code in ${_resendSeconds}s'
                      : 'Resend code',
                  style: TextStyle(
                    color: _resendSeconds > 0
                        ? SwiftSnapTheme.textMuted
                        : SwiftSnapTheme.primaryPink,
                    fontSize: 13,
                    fontWeight: _resendSeconds <= 0
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: List.generate(6, (i) => _buildOtpBox(i)),
          ),

          const SizedBox(height: 40),
          _buildGradientButton('Next', _submitStep2),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  // ── STEP 3 — New password ─────────────────────────────────────────────────

  Widget _buildStep3() {
    return SingleChildScrollView(
      key: const ValueKey('step3'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 32),
          const Text(
            'Create new password',
            style: TextStyle(
              color: SwiftSnapTheme.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your new password must be at least 8 characters.',
            style: TextStyle(color: SwiftSnapTheme.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 32),

          _buildLabel('NEW PASSWORD'),
          const SizedBox(height: 8),
          _buildPasswordField(_newPasswordController, _obscureNew, () {
            setState(() => _obscureNew = !_obscureNew);
          }),
          const SizedBox(height: 20),

          _buildLabel('CONFIRM PASSWORD'),
          const SizedBox(height: 8),
          _buildPasswordField(_confirmPasswordController, _obscureConfirm, () {
            setState(() => _obscureConfirm = !_obscureConfirm);
          }),

          const SizedBox(height: 32),
          _isLoading
              ? const Center(child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(SwiftSnapTheme.primaryPurple),
                ))
              : _buildGradientButton('Reset Password', _submitStep3),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
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
        style: const TextStyle(color: SwiftSnapTheme.textPrimary, fontSize: 15),
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(
            color: SwiftSnapTheme.textSecondary.withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(
    TextEditingController controller,
    bool obscure,
    VoidCallback toggle,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: SwiftSnapTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: SwiftSnapTheme.textPrimary, fontSize: 15),
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
          hintText: 'Enter password',
          hintStyle: TextStyle(
            color: SwiftSnapTheme.textSecondary.withOpacity(0.5),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              obscure
                  ? Icons.visibility_rounded
                  : Icons.visibility_off_rounded,
              color: SwiftSnapTheme.textSecondary,
              size: 20,
            ),
            onPressed: toggle,
          ),
        ),
      ),
    );
  }

  Widget _buildContactToggle() {
    return Container(
      height: 46,
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
        setState(() {
          _useEmail = isEmail;
          _contactController.clear();
        });
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
            setState(() {});
          },
          onTap: () => setState(() {}),
        ),
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
}
