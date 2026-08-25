import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/theme.dart';

class AppearanceSettingsScreen extends StatefulWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  State<AppearanceSettingsScreen> createState() => _AppearanceSettingsScreenState();
}

class _AppearanceSettingsScreenState extends State<AppearanceSettingsScreen> {
  String _selectedTheme = 'Classic Purple';
  bool _premiumUser = true; // Simulate premium status

  final List<Map<String, dynamic>> _themes = [
    {
      'name': 'Classic Purple',
      'gradient': [Color(0xFF8B5CF6), Color(0xFFEC4899)],
      'isPremium': false,
    },
    {
      'name': 'Ocean Blue',
      'gradient': [Color(0xFF0EA5E9), Color(0xFF6366F1)],
      'isPremium': true,
    },
    {
      'name': 'Forest Green',
      'gradient': [Color(0xFF10B981), Color(0xFF059669)],
      'isPremium': true,
    },
    {
      'name': 'Sunset Orange',
      'gradient': [Color(0xFFF59E0B), Color(0xFFEF4444)],
      'isPremium': true,
    },
    {
      'name': 'Royal Gold',
      'gradient': [Color(0xFFFFD700), Color(0xFFFFA500)],
      'isPremium': true,
    },
    {
      'name': 'Midnight Blue',
      'gradient': [Color(0xFF1E293B), Color(0xFF334155)],
      'isPremium': true,
    },
    {
      'name': 'Rose Pink',
      'gradient': [Color(0xFFEC4899), Color(0xFFF472B6)],
      'isPremium': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwiftSnapTheme.backgroundDark,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildHeader(context),
            _buildThemeSection(),
            _buildOtherSettings(),
            const SliverPadding(padding: EdgeInsets.only(bottom: 50)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
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
            const Text(
              'App Appearance',
              style: TextStyle(
                color: SwiftSnapTheme.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'THEME SELECTION',
                style: TextStyle(
                  color: SwiftSnapTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
              ),
              itemCount: _themes.length,
              itemBuilder: (context, index) {
                final theme = _themes[index];
                return _buildThemeCard(theme);
              },
            ),
          ],
        ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0),
      ),
    );
  }

  Widget _buildThemeCard(Map<String, dynamic> theme) {
    final isSelected = _selectedTheme == theme['name'];
    final isPremium = theme['isPremium'] as bool;
    final canSelect = !isPremium || _premiumUser;

    return GestureDetector(
      onTap: () {
        if (!canSelect) {
          _showPremiumDialog();
          return;
        }
        HapticFeedback.lightImpact();
        setState(() => _selectedTheme = theme['name']);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Theme changed to ${theme['name']}'),
            backgroundColor: SwiftSnapTheme.accentGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: theme['gradient'] as List<Color>,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (theme['gradient'] as List<Color>)[0].withOpacity(0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            if (isSelected)
              const Positioned(
                top: 8,
                right: 8,
                child: Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            if (isPremium && !_premiumUser)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 12),
                      SizedBox(width: 4),
                      Text(
                        'Premium',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Center(
              child: Text(
                theme['name'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      blurRadius: 8,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtherSettings() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'DISPLAY SETTINGS',
                style: TextStyle(
                  color: SwiftSnapTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: SwiftSnapTheme.surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  _buildSettingsTile(
                    icon: Icons.text_fields,
                    title: 'Font Size',
                    value: 'Medium',
                    onTap: () => _showFontSizeDialog(),
                  ),
                  _buildDivider(),
                  _buildSettingsTile(
                    icon: Icons.animation,
                    title: 'Animations',
                    trailing: Switch(
                      value: true,
                      onChanged: (value) {
                        HapticFeedback.lightImpact();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(value ? 'Animations enabled' : 'Animations disabled'),
                            backgroundColor: SwiftSnapTheme.accentGreen,
                          ),
                        );
                      },
                      activeColor: SwiftSnapTheme.primaryPurple,
                    ),
                  ),
                  _buildDivider(),
                  _buildSettingsTile(
                    icon: Icons.grid_view,
                    title: 'Chat Bubble Style',
                    value: 'Modern',
                    onTap: () => _showBubbleStyleDialog(),
                  ),
                ],
              ),
            ),
          ],
        ).animate(delay: 100.ms).fadeIn(duration: 300.ms),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? value,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap != null
          ? () {
              HapticFeedback.lightImpact();
              onTap();
            }
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: Colors.transparent,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: SwiftSnapTheme.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: SwiftSnapTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (trailing != null)
              trailing
            else if (value != null)
              Row(
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      color: SwiftSnapTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: SwiftSnapTheme.textSecondary,
                    size: 20,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.only(left: 72),
      child: Divider(
        height: 1,
        thickness: 1,
        color: Colors.white10,
      ),
    );
  }

  void _showPremiumDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SwiftSnapTheme.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.star, color: Colors.amber),
            SizedBox(width: 12),
            Text(
              'SwiftSnap+ Required',
              style: TextStyle(
                color: SwiftSnapTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Text(
          'This theme is exclusive to SwiftSnap+ members. Upgrade now to unlock all premium themes!',
          style: TextStyle(color: SwiftSnapTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to subscription
            },
            child: Text(
              'Upgrade',
              style: TextStyle(color: SwiftSnapTheme.primaryPurple),
            ),
          ),
        ],
      ),
    );
  }

  void _showFontSizeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SwiftSnapTheme.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Font Size',
          style: TextStyle(color: SwiftSnapTheme.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Small', 'Medium', 'Large', 'Extra Large'].map((size) {
            return ListTile(
              title: Text(size, style: const TextStyle(color: SwiftSnapTheme.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Font size changed to $size'),
                    backgroundColor: SwiftSnapTheme.accentGreen,
                  ),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showBubbleStyleDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SwiftSnapTheme.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Chat Bubble Style',
          style: TextStyle(color: SwiftSnapTheme.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Modern', 'Classic', 'Minimal', 'Rounded'].map((style) {
            return ListTile(
              title: Text(style, style: const TextStyle(color: SwiftSnapTheme.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Chat bubble style changed to $style'),
                    backgroundColor: SwiftSnapTheme.accentGreen,
                  ),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
