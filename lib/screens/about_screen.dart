import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/theme.dart';
import 'terms_of_service_screen.dart';
import 'privacy_policy_screen.dart';
import 'cookie_policy_screen.dart';
import 'licenses_screen.dart';
import 'help_support_screen.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwiftSnapTheme.backgroundDark,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildHeader(context),
            _buildLogoSection(),
            _buildVersionInfo(),
            _buildCompanyInfo(),
            _buildFeaturesSection(),
            _buildLegalSection(),
            _buildSocialLinks(),
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
              'About',
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

  Widget _buildLogoSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        child: Column(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: SwiftSnapTheme.primaryGradient,
                borderRadius: BorderRadius.circular(32),
                boxShadow: SwiftSnapTheme.glowShadow(
                  SwiftSnapTheme.primaryPurple,
                  intensity: 0.5,
                ),
              ),
              child: const Icon(
                Icons.chat_bubble_rounded,
                color: Colors.white,
                size: 64,
              ),
            ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 24),
            ShaderMask(
              shaderCallback: (bounds) => SwiftSnapTheme.primaryGradient
                  .createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
              child: const Text(
                'SwiftSnap',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
            const SizedBox(height: 8),
            Text(
              'Connect. Share. Vibe.',
              style: TextStyle(
                color: SwiftSnapTheme.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionInfo() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: SwiftSnapTheme.surfaceColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              _buildInfoRow('Version', '1.0.0'),
              const SizedBox(height: 16),
              _buildInfoRow('Build', '2026.1.0'),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms, delay: 300.ms).slideY(begin: 0.2, end: 0),
      ),
    );
  }

  Widget _buildCompanyInfo() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                SwiftSnapTheme.primaryPurple.withOpacity(0.15),
                SwiftSnapTheme.primaryPink.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: SwiftSnapTheme.primaryPurple.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: SwiftSnapTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: SwiftSnapTheme.glowShadow(
                        SwiftSnapTheme.primaryPurple,
                        intensity: 0.3,
                      ),
                    ),
                    child: const Icon(
                      Icons.business_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nexa-Group',
                          style: TextStyle(
                            color: SwiftSnapTheme.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Parent Company',
                          style: TextStyle(
                            color: SwiftSnapTheme.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'SwiftSnap is proudly developed and maintained by Nexa-Group, a technology company focused on creating innovative communication solutions that bring people together.',
                style: TextStyle(
                  color: SwiftSnapTheme.textSecondary,
                  fontSize: 15,
                  height: 1.6,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: SwiftSnapTheme.backgroundDark.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Our Mission',
                      style: TextStyle(
                        color: SwiftSnapTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'To revolutionize digital communication by providing secure, intuitive, and feature-rich platforms that empower users to connect authentically and share meaningful moments.',
                      style: TextStyle(
                        color: SwiftSnapTheme.textSecondary,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms, delay: 400.ms).slideY(begin: 0.2, end: 0),
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 16, top: 8),
              child: Text(
                'ENTERPRISE FEATURES',
                style: TextStyle(
                  color: SwiftSnapTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            _buildFeatureCard(
              icon: Icons.security_rounded,
              title: 'Enterprise Security',
              description: 'End-to-end encryption, secure data storage, and compliance with international security standards.',
            ),
            const SizedBox(height: 12),
            _buildFeatureCard(
              icon: Icons.cloud_sync_rounded,
              title: 'Cloud Infrastructure',
              description: 'Scalable cloud architecture ensuring 99.9% uptime and seamless cross-device synchronization.',
            ),
            const SizedBox(height: 12),
            _buildFeatureCard(
              icon: Icons.support_agent_rounded,
              title: '24/7 Support',
              description: 'Dedicated enterprise support team available around the clock for all your needs.',
            ),
            const SizedBox(height: 12),
            _buildFeatureCard(
              icon: Icons.analytics_rounded,
              title: 'Advanced Analytics',
              description: 'Comprehensive insights and analytics to understand user engagement and platform performance.',
            ),
          ],
        ).animate().fadeIn(duration: 300.ms, delay: 500.ms),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SwiftSnapTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: SwiftSnapTheme.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: SwiftSnapTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: SwiftSnapTheme.textSecondary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'LEGAL',
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
                  _buildLegalTile('Terms of Service'),
                  _buildDivider(),
                  _buildLegalTile('Privacy Policy'),
                  _buildDivider(),
                  _buildLegalTile('Cookie Policy'),
                  _buildDivider(),
                  _buildLegalTile('Licenses'),
                ],
              ),
            ),
          ],
        ).animate().fadeIn(duration: 300.ms, delay: 600.ms),
      ),
    );
  }

  Widget _buildLegalTile(String title) {
    return Builder(
      builder: (context) => GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          _navigateToLegalDocument(context, title);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
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
              const Icon(
                Icons.chevron_right_rounded,
                color: SwiftSnapTheme.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToLegalDocument(BuildContext context, String title) {
    Widget? screen;
    
    switch (title) {
      case 'Terms of Service':
        screen = const TermsOfServiceScreen();
        break;
      case 'Privacy Policy':
        screen = const PrivacyPolicyScreen();
        break;
      case 'Cookie Policy':
        screen = const CookiePolicyScreen();
        break;
      case 'Licenses':
        screen = const LicensesScreen();
        break;
    }
    
    if (screen != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen!),
      );
    }
  }

  Widget _buildSocialLinks() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'CONNECT WITH US',
                style: TextStyle(
                  color: SwiftSnapTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: SwiftSnapTheme.surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildSocialButton(Icons.language_rounded, 'Website'),
                      _buildSocialButton(Icons.email_rounded, 'Email'),
                      _buildSocialButton(Icons.chat_rounded, 'Support'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '© 2026 Nexa-Group. All rights reserved.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: SwiftSnapTheme.textMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ).animate().fadeIn(duration: 300.ms, delay: 700.ms),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, String label) {
    return Builder(
      builder: (context) => GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          _handleSocialButtonTap(context, label);
        },
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: SwiftSnapTheme.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: SwiftSnapTheme.glowShadow(
                  SwiftSnapTheme.primaryPurple,
                  intensity: 0.2,
                ),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: SwiftSnapTheme.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSocialButtonTap(BuildContext context, String label) async {
    switch (label) {
      case 'Website':
        final Uri url = Uri.parse('https://nexa-group.org/');
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
        break;
      case 'Email':
        final Uri emailUri = Uri(
          scheme: 'mailto',
          path: 'contact@swiftsnap.one',
          query: 'subject=SwiftSnap Inquiry',
        );
        if (await canLaunchUrl(emailUri)) {
          await launchUrl(emailUri);
        }
        break;
      case 'Support':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HelpSupportScreen()),
        );
        break;
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: SwiftSnapTheme.textSecondary,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: SwiftSnapTheme.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.white.withOpacity(0.05),
    );
  }
}
