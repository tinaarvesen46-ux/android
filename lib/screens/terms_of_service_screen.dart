import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/theme.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

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
              'Terms of Service',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    SwiftSnapTheme.primaryPurple.withOpacity(0.15),
                    SwiftSnapTheme.primaryPink.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: SwiftSnapTheme.primaryPurple.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: SwiftSnapTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.gavel_rounded,
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
                              'Effective Date',
                              style: TextStyle(
                                color: SwiftSnapTheme.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'January 1, 2026',
                              style: TextStyle(
                                color: SwiftSnapTheme.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0),
            const SizedBox(height: 24),
            _buildSection(
              'Welcome to SwiftSnap',
              'These Terms of Service ("Terms") govern your use of the SwiftSnap platform operated by Nexa-Group ("we," "us," or "our"). By accessing or using SwiftSnap, you agree to be bound by these Terms.',
            ),
            _buildSection(
              '1. Acceptance of Terms',
              'By creating an account, accessing, or using SwiftSnap, you acknowledge that you have read, understood, and agree to be bound by these Terms and our Privacy Policy. If you do not agree with any part of these Terms, you must not use our service.',
            ),
            _buildSection(
              '2. Eligibility',
              'You must be at least 13 years old to use SwiftSnap. By using our service, you represent and warrant that you meet this age requirement and have the legal capacity to enter into these Terms.',
            ),
            _buildSection(
              '3. User Accounts',
              '• You are responsible for maintaining the confidentiality of your account credentials\n• You must provide accurate and complete information when creating your account\n• You are solely responsible for all activities that occur under your account\n• You must immediately notify us of any unauthorized use of your account',
            ),
            _buildSection(
              '4. Content and Conduct',
              'You agree not to post, share, or transmit content that:\n• Is illegal, harmful, or violates any laws or regulations\n• Infringes on intellectual property rights of others\n• Contains hate speech, harassment, or threats\n• Is false, misleading, or fraudulent\n• Contains malware, viruses, or malicious code\n• Violates the privacy or rights of others',
            ),
            _buildSection(
              '5. Intellectual Property',
              'All content, features, and functionality of SwiftSnap, including but not limited to text, graphics, logos, and software, are owned by Nexa-Group and protected by international copyright, trademark, and other intellectual property laws.',
            ),
            _buildSection(
              '6. Privacy and Data',
              'Your privacy is important to us. Our collection and use of personal information is governed by our Privacy Policy. By using SwiftSnap, you consent to our data practices as described in the Privacy Policy.',
            ),
            _buildSection(
              '7. Termination',
              'We reserve the right to suspend or terminate your account at any time, with or without notice, for any reason, including but not limited to violation of these Terms. Upon termination, your right to use SwiftSnap will immediately cease.',
            ),
            _buildSection(
              '8. Disclaimers',
              'SwiftSnap is provided "as is" and "as available" without warranties of any kind, either express or implied. We do not guarantee that the service will be uninterrupted, secure, or error-free.',
            ),
            _buildSection(
              '9. Limitation of Liability',
              'To the maximum extent permitted by law, Nexa-Group shall not be liable for any indirect, incidental, special, consequential, or punitive damages resulting from your use or inability to use SwiftSnap.',
            ),
            _buildSection(
              '10. Changes to Terms',
              'We reserve the right to modify these Terms at any time. We will notify users of significant changes via email or through the app. Continued use of SwiftSnap after changes constitutes acceptance of the updated Terms.',
            ),
            _buildSection(
              '11. Governing Law',
              'These Terms shall be governed by and construed in accordance with the laws of the jurisdiction where Nexa-Group is headquartered, without regard to its conflict of law provisions.',
            ),
            _buildSection(
              '12. Contact Information',
              'For questions about these Terms, please contact us at:\n\nEmail: legal@nexa-group.org\nAddress: Nexa-Group Legal Department\nWebsite: https://nexa-group.org/legal',
            ),
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
                    'Last Updated',
                    style: TextStyle(
                      color: SwiftSnapTheme.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'January 1, 2026',
                    style: TextStyle(
                      color: SwiftSnapTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'By continuing to use SwiftSnap, you acknowledge that you have read and understood these Terms of Service.',
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
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SwiftSnapTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: SwiftSnapTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              color: SwiftSnapTheme.textSecondary,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }
}
