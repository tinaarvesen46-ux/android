import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/theme.dart';

class PasswordSettingsScreen extends StatefulWidget {
  const PasswordSettingsScreen({super.key});

  @override
  State<PasswordSettingsScreen> createState() => _PasswordSettingsScreenState();
}

class _PasswordSettingsScreenState extends State<PasswordSettingsScreen> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;
  
  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_validatePassword);
  }
  
  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  
  void _validatePassword() {
    final password = _newPasswordController.text;
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasLowercase = password.contains(RegExp(r'[a-z]'));
      _hasNumber = password.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }
  
  bool get _isPasswordValid => _hasMinLength && _hasUppercase && _hasLowercase && _hasNumber && _hasSpecialChar;
  
  void _changePassword() {
    if (_currentPasswordController.text.isEmpty) {
      _showError('Please enter your current password');
      return;
    }
    
    if (!_isPasswordValid) {
      _showError('Password does not meet requirements');
      return;
    }
    
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showError('Passwords do not match');
      return;
    }
    
    HapticFeedback.mediumImpact();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pop(context);
          Navigator.pop(context);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Password changed successfully!'),
              backgroundColor: SwiftSnapTheme.accentGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        });
        
        return AlertDialog(
          backgroundColor: SwiftSnapTheme.surfaceColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(SwiftSnapTheme.primaryPurple),
              ),
              const SizedBox(height: 20),
              Text(
                'Updating password...',
                style: TextStyle(color: SwiftSnapTheme.textSecondary),
              ),
            ],
          ),
        );
      },
    );
  }
  
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: SwiftSnapTheme.busy,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwiftSnapTheme.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPasswordField(
                      controller: _currentPasswordController,
                      label: 'Current Password',
                      hint: 'Enter your current password',
                      obscureText: _obscureCurrentPassword,
                      onToggleVisibility: () => setState(() => _obscureCurrentPassword = !_obscureCurrentPassword),
                    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 24),
                    _buildPasswordField(
                      controller: _newPasswordController,
                      label: 'New Password',
                      hint: 'Enter your new password',
                      obscureText: _obscureNewPassword,
                      onToggleVisibility: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
                    ).animate().fadeIn(duration: 300.ms, delay: 100.ms).slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 24),
                    _buildPasswordField(
                      controller: _confirmPasswordController,
                      label: 'Confirm New Password',
                      hint: 'Re-enter your new password',
                      obscureText: _obscureConfirmPassword,
                      onToggleVisibility: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ).animate().fadeIn(duration: 300.ms, delay: 200.ms).slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 32),
                    _buildPasswordRequirements().animate().fadeIn(duration: 300.ms, delay: 300.ms),
                    const SizedBox(height: 32),
                    _buildChangePasswordButton().animate().fadeIn(duration: 300.ms, delay: 400.ms),
                    const SizedBox(height: 24),
                    _buildForgotPasswordLink().animate().fadeIn(duration: 300.ms, delay: 500.ms),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: SwiftSnapTheme.backgroundCard,
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              color: SwiftSnapTheme.textPrimary,
            ),
          ),
          const Text(
            'Change Password',
            style: TextStyle(
              color: SwiftSnapTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            label,
            style: const TextStyle(
              color: SwiftSnapTheme.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: SwiftSnapTheme.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            style: const TextStyle(
              color: SwiftSnapTheme.textPrimary,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: SwiftSnapTheme.textMuted),
              prefixIcon: Icon(
                Icons.lock_rounded,
                color: SwiftSnapTheme.textMuted,
                size: 22,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: SwiftSnapTheme.textMuted,
                  size: 22,
                ),
                onPressed: onToggleVisibility,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildPasswordRequirements() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SwiftSnapTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Password Requirements',
            style: TextStyle(
              color: SwiftSnapTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _buildRequirement('At least 8 characters', _hasMinLength),
          const SizedBox(height: 10),
          _buildRequirement('One uppercase letter', _hasUppercase),
          const SizedBox(height: 10),
          _buildRequirement('One lowercase letter', _hasLowercase),
          const SizedBox(height: 10),
          _buildRequirement('One number', _hasNumber),
          const SizedBox(height: 10),
          _buildRequirement('One special character', _hasSpecialChar),
        ],
      ),
    );
  }
  
  Widget _buildRequirement(String text, bool isMet) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle_rounded : Icons.circle_outlined,
          color: isMet ? SwiftSnapTheme.accentGreen : SwiftSnapTheme.textMuted,
          size: 20,
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            color: isMet ? SwiftSnapTheme.textPrimary : SwiftSnapTheme.textSecondary,
            fontSize: 14,
            fontWeight: isMet ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
  
  Widget _buildChangePasswordButton() {
    return GestureDetector(
      onTap: _changePassword,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: _isPasswordValid
              ? SwiftSnapTheme.primaryGradient
              : LinearGradient(
                  colors: [
                    SwiftSnapTheme.textMuted,
                    SwiftSnapTheme.textMuted,
                  ],
                ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: _isPasswordValid
              ? SwiftSnapTheme.glowShadow(SwiftSnapTheme.primaryPurple, intensity: 0.3)
              : [],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_rounded, color: Colors.white, size: 22),
            SizedBox(width: 8),
            Text(
              'Change Password',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildForgotPasswordLink() {
    return Center(
      child: TextButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: SwiftSnapTheme.surfaceColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text(
                'Forgot Password?',
                style: TextStyle(color: SwiftSnapTheme.textPrimary, fontWeight: FontWeight.w700),
              ),
              content: Text(
                'A password reset link will be sent to your email address.',
                style: TextStyle(color: SwiftSnapTheme.textSecondary),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: SwiftSnapTheme.textSecondary)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Password reset email sent!'),
                        backgroundColor: SwiftSnapTheme.accentGreen,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                  child: const Text('Send Email', style: TextStyle(color: SwiftSnapTheme.primaryPurple)),
                ),
              ],
            ),
          );
        },
        child: const Text(
          'Forgot your password?',
          style: TextStyle(
            color: SwiftSnapTheme.primaryPink,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
