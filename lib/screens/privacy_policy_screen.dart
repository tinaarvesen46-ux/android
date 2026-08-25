import 'package:flutter/material.dart';
import '../theme/theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwiftSnapTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: SwiftSnapTheme.cardColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Privacy Policy',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 30),
            _buildSection(
              'Information We Collect',
              [
                'Account Information: Name, email, phone number, profile photo',
                'Usage Data: Messages, stories, interactions, and activity logs',
                'Device Information: IP address, device type, operating system',
                'Location Data: Approximate location for content personalization',
                'Media Files: Photos, videos, and audio shared on the platform',
              ],
            ),
            _buildSection(
              'How We Use Your Information',
              [
                'To provide and maintain SwiftSnap services',
                'To personalize your experience and content recommendations',
                'To communicate with you about updates and features',
                'To ensure platform security and prevent fraud',
                'To analyze usage patterns and improve our services',
                'To comply with legal obligations and protect user rights',
              ],
            ),
            _buildSection(
              'Information Sharing',
              [
                'With Other Users: Profile info, messages, and stories as per your settings',
                'Service Providers: Trusted partners for hosting, analytics, and support',
                'Legal Requirements: When required by law or to protect rights',
                'Business Transfers: In case of merger, acquisition, or asset sale',
                'We never sell your personal data to third parties',
              ],
            ),
            _buildSection(
              'Data Security',
              [
                'End-to-end encryption for messages and media',
                'Secure cloud infrastructure with regular security audits',
                'Multi-factor authentication and biometric login options',
                'Automatic logout and session management',
                'Regular security updates and vulnerability assessments',
              ],
            ),
            _buildSection(
              'Your Privacy Rights',
              [
                'Access and download your personal data',
                'Correct or update your information',
                'Delete your account and associated data',
                'Object to data processing',
                'Withdraw consent at any time',
                'Opt-out of marketing communications',
              ],
            ),
            _buildSection(
              'Data Retention',
              [
                'Active accounts: Data retained while account is active',
                'Deleted accounts: Most data removed within 30 days',
                'Legal requirements: Some data retained for compliance',
                'Backup systems: Up to 90 days for disaster recovery',
              ],
            ),
            _buildSection(
              'Children\'s Privacy',
              [
                'SwiftSnap is not intended for users under 13 years old',
                'We do not knowingly collect data from children',
                'Parents can contact us to delete children\'s data',
                'Age verification required during registration',
              ],
            ),
            _buildSection(
              'International Data Transfers',
              [
                'Data may be transferred to servers in different countries',
                'We ensure adequate protection through standard contractual clauses',
                'EU users: GDPR-compliant data processing agreements',
                'Cross-border transfers secured with appropriate safeguards',
              ],
            ),
            _buildSection(
              'Cookies and Tracking',
              [
                'Essential cookies for platform functionality',
                'Analytics cookies to improve user experience',
                'Preference cookies to remember your settings',
                'You can manage cookie preferences in settings',
              ],
            ),
            _buildSection(
              'Third-Party Services',
              [
                'Social media integration (optional)',
                'Payment processors for SwiftSnap+ subscriptions',
                'Cloud storage providers for media backup',
                'Analytics and performance monitoring tools',
                'All partners comply with our privacy standards',
              ],
            ),
            _buildSection(
              'Changes to This Policy',
              [
                'We may update this policy periodically',
                'Material changes will be notified via email or in-app',
                'Continued use constitutes acceptance of changes',
                'Previous versions available upon request',
              ],
            ),
            _buildContactSection(),
            const SizedBox(height: 20),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: SwiftSnapTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Privacy Matters',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Last Updated: January 15, 2026',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'This Privacy Policy explains how Nexa-Group and SwiftSnap collect, use, and protect your personal information.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<String> points) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...points.map((point) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      gradient: SwiftSnapTheme.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      point,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            )),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildContactSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SwiftSnapTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: SwiftSnapTheme.borderColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contact Us',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'If you have questions about this Privacy Policy:',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          _buildContactItem(Icons.email, 'privacy@swiftsnap.one'),
          _buildContactItem(Icons.language, 'https://nexa-group.org/privacy'),
          _buildContactItem(Icons.location_on, 'Nexa-Group Privacy Office\n123 Enterprise Blvd, Suite 500\nSan Francisco, CA 94107'),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => SwiftSnapTheme.primaryGradient.createShader(bounds),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Column(
        children: [
          Divider(color: SwiftSnapTheme.borderColor),
          const SizedBox(height: 16),
          Text(
            '© 2026 Nexa-Group. All rights reserved.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'SwiftSnap is a registered trademark of Nexa-Group',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
