import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/theme.dart';
import '../providers/app_provider.dart';

class EditFieldScreen extends StatefulWidget {
  final String fieldName;
  final String currentValue;
  final Function(String) onSave;
  final bool isPassword;

  const EditFieldScreen({
    super.key,
    required this.fieldName,
    required this.currentValue,
    required this.onSave,
    this.isPassword = false,
  });

  @override
  State<EditFieldScreen> createState() => _EditFieldScreenState();
}

class _EditFieldScreenState extends State<EditFieldScreen> {
  late TextEditingController _controller;
  late TextEditingController _confirmController;
  bool _obscureText = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.isPassword ? '' : widget.currentValue,
    );
    _confirmController = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _confirmController.dispose();
    super.dispose();
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
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enter your ${widget.fieldName.toLowerCase()}',
                      style: TextStyle(
                        color: SwiftSnapTheme.textSecondary,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(),
                    if (widget.isPassword) ...[
                      const SizedBox(height: 20),
                      Text(
                        'Confirm password',
                        style: TextStyle(
                          color: SwiftSnapTheme.textSecondary,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildConfirmTextField(),
                    ],
                  ],
                ),
              ),
            ),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: SwiftSnapTheme.surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: SwiftSnapTheme.textPrimary,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Edit ${widget.fieldName}',
            style: const TextStyle(
              color: SwiftSnapTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField() {
    return Container(
      decoration: BoxDecoration(
        color: SwiftSnapTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        controller: _controller,
        obscureText: widget.isPassword && _obscureText,
        style: const TextStyle(
          color: SwiftSnapTheme.textPrimary,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(20),
          border: InputBorder.none,
          hintText: 'Enter ${widget.fieldName.toLowerCase()}',
          hintStyle: TextStyle(
            color: SwiftSnapTheme.textSecondary.withOpacity(0.5),
          ),
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                    color: SwiftSnapTheme.textSecondary,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
              : null,
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildConfirmTextField() {
    return Container(
      decoration: BoxDecoration(
        color: SwiftSnapTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        controller: _confirmController,
        obscureText: _obscureConfirm,
        style: const TextStyle(
          color: SwiftSnapTheme.textPrimary,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(20),
          border: InputBorder.none,
          hintText: 'Confirm password',
          hintStyle: TextStyle(
            color: SwiftSnapTheme.textSecondary.withOpacity(0.5),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirm ? Icons.visibility_rounded : Icons.visibility_off_rounded,
              color: SwiftSnapTheme.textSecondary,
            ),
            onPressed: () {
              setState(() {
                _obscureConfirm = !_obscureConfirm;
              });
            },
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 100.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: GestureDetector(
        onTap: _handleSave,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                SwiftSnapTheme.primaryPurple,
                SwiftSnapTheme.primaryPink,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: SwiftSnapTheme.primaryPurple.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Text(
            'Save Changes',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ).animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.3)),
    );
  }

  void _handleSave() {
    HapticFeedback.mediumImpact();
    
    if (widget.isPassword) {
      if (_controller.text != _confirmController.text) {
        _showError('Passwords do not match');
        return;
      }
      if (_controller.text.length < 6) {
        _showError('Password must be at least 6 characters');
        return;
      }
    }
    
    if (_controller.text.trim().isEmpty) {
      _showError('${widget.fieldName} cannot be empty');
      return;
    }

    widget.onSave(_controller.text);
    
    // Update provider if needed
    final provider = Provider.of<AppProvider>(context, listen: false);
    if (widget.fieldName == 'Name') {
      provider.updateCurrentUser(
        user: provider.currentUser!.copyWith(displayName: _controller.text),
      );
    } else if (widget.fieldName == 'Username') {
      provider.updateCurrentUser(
        user: provider.currentUser!.copyWith(username: _controller.text),
      );
    } else if (widget.fieldName == 'Email') {
      provider.updateCurrentUser(
        user: provider.currentUser!.copyWith(email: _controller.text),
      );
    }
    
    Navigator.pop(context);
    _showSuccess('${widget.fieldName} updated successfully');
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
