import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/theme.dart';

class BitmojiScreen extends StatefulWidget {
  const BitmojiScreen({super.key});

  @override
  State<BitmojiScreen> createState() => _BitmojiScreenState();
}

class _BitmojiScreenState extends State<BitmojiScreen> {
  bool _isLinked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwiftSnapTheme.backgroundDark,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildHeader(context),
            _buildContent(),
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
              'Bitmoji',
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

  Widget _buildContent() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    SwiftSnapTheme.primaryPurple.withOpacity(0.15),
                    SwiftSnapTheme.primaryPink.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: SwiftSnapTheme.primaryPurple.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: SwiftSnapTheme.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: SwiftSnapTheme.glowShadow(
                        SwiftSnapTheme.primaryPurple,
                        intensity: 0.4,
                      ),
                    ),
                    child: const Icon(
                      Icons.sentiment_satisfied_alt_rounded,
                      size: 70,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _isLinked ? 'Bitmoji Linked' : 'Link Your Bitmoji',
                    style: const TextStyle(
                      color: SwiftSnapTheme.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _isLinked
                        ? 'Your Bitmoji avatar is connected to SwiftSnap'
                        : 'Express yourself with your personalized Bitmoji avatar',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: SwiftSnapTheme.textSecondary,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      setState(() => _isLinked = !_isLinked);
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            _isLinked
                                ? 'Bitmoji linked successfully!'
                                : 'Bitmoji unlinked',
                          ),
                          backgroundColor: _isLinked
                              ? SwiftSnapTheme.accentGreen
                              : SwiftSnapTheme.surfaceColor,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: _isLinked ? null : SwiftSnapTheme.primaryGradient,
                        color: _isLinked ? SwiftSnapTheme.surfaceColor : null,
                        borderRadius: BorderRadius.circular(16),
                        border: _isLinked
                            ? Border.all(color: Colors.white.withOpacity(0.1))
                            : null,
                        boxShadow: _isLinked
                            ? null
                            : SwiftSnapTheme.glowShadow(
                                SwiftSnapTheme.primaryPurple,
                                intensity: 0.3,
                              ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isLinked ? Icons.link_off_rounded : Icons.link_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _isLinked ? 'Unlink Bitmoji' : 'Link Bitmoji',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms).scale(delay: 100.ms),
            if (_isLinked) ...[
              const SizedBox(height: 24),
              Container(
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
                      'Bitmoji Settings',
                      style: TextStyle(
                        color: SwiftSnapTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSettingsTile(
                      icon: Icons.person_outline_rounded,
                      title: 'Show in Profile',
                      value: true,
                    ),
                    _buildDivider(),
                    _buildSettingsTile(
                      icon: Icons.chat_outlined,
                      title: 'Use in Chats',
                      value: true,
                    ),
                    _buildDivider(),
                    _buildSettingsTile(
                      icon: Icons.auto_awesome_outlined,
                      title: 'Auto Suggestions',
                      value: false,
                    ),
                  ],
                ),
              ).animate(delay: 200.ms).fadeIn(duration: 300.ms),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required bool value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: SwiftSnapTheme.primaryGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
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
          Switch(
            value: value,
            onChanged: (_) => HapticFeedback.lightImpact(),
            activeColor: SwiftSnapTheme.primaryPurple,
            activeTrackColor: SwiftSnapTheme.primaryPurple.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: Colors.white.withOpacity(0.06),
      indent: 52,
    );
  }
}
