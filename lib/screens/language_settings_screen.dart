import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/theme.dart';

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  String _selectedLanguage = 'English';

  final List<Map<String, String>> _languages = [
    {'name': 'English', 'native': 'English', 'code': 'en'},
    {'name': 'Spanish', 'native': 'Español', 'code': 'es'},
    {'name': 'French', 'native': 'Français', 'code': 'fr'},
    {'name': 'German', 'native': 'Deutsch', 'code': 'de'},
    {'name': 'Italian', 'native': 'Italiano', 'code': 'it'},
    {'name': 'Portuguese', 'native': 'Português', 'code': 'pt'},
    {'name': 'Russian', 'native': 'Русский', 'code': 'ru'},
    {'name': 'Chinese', 'native': '中文', 'code': 'zh'},
    {'name': 'Japanese', 'native': '日本語', 'code': 'ja'},
    {'name': 'Korean', 'native': '한국어', 'code': 'ko'},
    {'name': 'Arabic', 'native': 'العربية', 'code': 'ar'},
    {'name': 'Hindi', 'native': 'हिन्दी', 'code': 'hi'},
    {'name': 'Turkish', 'native': 'Türkçe', 'code': 'tr'},
    {'name': 'Dutch', 'native': 'Nederlands', 'code': 'nl'},
    {'name': 'Polish', 'native': 'Polski', 'code': 'pl'},
    {'name': 'Swedish', 'native': 'Svenska', 'code': 'sv'},
    {'name': 'Thai', 'native': 'ไทย', 'code': 'th'},
    {'name': 'Vietnamese', 'native': 'Tiếng Việt', 'code': 'vi'},
    {'name': 'Indonesian', 'native': 'Bahasa Indonesia', 'code': 'id'},
    {'name': 'Filipino', 'native': 'Filipino', 'code': 'fil'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwiftSnapTheme.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _languages.length,
                itemBuilder: (context, index) {
                  final language = _languages[index];
                  return _buildLanguageTile(language)
                      .animate(delay: Duration(milliseconds: 30 * index))
                      .fadeIn(duration: 200.ms)
                      .slideX(begin: 0.2, end: 0);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
          const Text(
            'Language',
            style: TextStyle(
              color: SwiftSnapTheme.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageTile(Map<String, String> language) {
    final isSelected = _selectedLanguage == language['name'];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: SwiftSnapTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? SwiftSnapTheme.primaryPurple
              : Colors.white.withOpacity(0.1),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        title: Text(
          language['native']!,
          style: TextStyle(
            color: isSelected ? SwiftSnapTheme.primaryPurple : SwiftSnapTheme.textPrimary,
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
        subtitle: Text(
          language['name']!,
          style: TextStyle(
            color: SwiftSnapTheme.textMuted,
            fontSize: 13,
          ),
        ),
        trailing: isSelected
            ? Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  gradient: SwiftSnapTheme.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              )
            : null,
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() {
            _selectedLanguage = language['name']!;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Language changed to ${language['name']}'),
              backgroundColor: SwiftSnapTheme.accentGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
      ),
    );
  }
}
