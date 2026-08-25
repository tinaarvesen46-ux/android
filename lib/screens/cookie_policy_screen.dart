import 'package:flutter/material.dart';
import '../theme/theme.dart';

class CookiePolicyScreen extends StatelessWidget {
  const CookiePolicyScreen({super.key});

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
          'Cookie Policy',
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
              'What Are Cookies?',
              [
                'Small text files stored on your device',
                'Help us recognize you and remember your preferences',
                'Essential for platform functionality and user experience',
                'Can be managed through your browser or app settings',
              ],
            ),
            _buildSection(
              'Essential Cookies',
              [
                'Required for basic platform functionality',
                'Enable secure login and authentication',
                'Remember your session and prevent logout',
                'Cannot be disabled without affecting core features',
                'Duration: Session or up to 1 year',
              ],
            ),
            _buildSection(
              'Functional Cookies',
              [
                'Remember your preferences and settings',
                'Save your theme, language, and layout choices',
                'Store recently viewed content',
                'Enhance personalization features',
                'Duration: Up to 2 years',
              ],
            ),
            _buildSection(
              'Analytics Cookies',
              [
                'Help us understand how you use SwiftSnap',
                'Track page views, clicks, and navigation patterns',
                'Identify popular features and content',
                'Measure performance and optimize user experience',
                'Aggregated data only, no personal identification',
                'Duration: Up to 24 months',
              ],
            ),
            _buildSection(
              'Advertising Cookies',
              [
                'Used to show relevant content and promotions',
                'Measure effectiveness of campaigns',
                'Limit frequency of promotional messages',
                'Can be disabled in Privacy Settings',
                'Duration: Up to 12 months',
              ],
            ),
            _buildSection(
              'Third-Party Cookies',
              [
                'Social media plugins (share, like buttons)',
                'Payment processors for subscriptions',
                'Analytics providers (Google Analytics, etc.)',
                'Content delivery networks for media',
                'Governed by third-party privacy policies',
              ],
            ),
            _buildSection(
              'Managing Your Cookies',
              [
                'Browser Settings: Clear cookies through browser preferences',
                'App Settings: Manage preferences in Privacy & Security',
                'Opt-Out: Disable non-essential cookies anytime',
                'Do Not Track: We respect DNT browser signals',
                'Note: Disabling cookies may affect functionality',
              ],
            ),
            _buildCookieTable(),
            const SizedBox(height: 24),
            _buildSection(
              'Mobile App Data',
              [
                'Mobile identifiers instead of traditional cookies',
                'Device ID for session management',
                'Local storage for offline functionality',
                'Managed through device settings and app permissions',
              ],
            ),
            _buildSection(
              'Your Rights',
              [
                'Access information about cookies we use',
                'Withdraw consent at any time',
                'Request deletion of cookie data',
                'Object to profiling based on cookies',
                'File complaints with data protection authorities',
              ],
            ),
            _buildSection(
              'Updates to This Policy',
              [
                'We may update this Cookie Policy periodically',
                'Changes effective immediately upon posting',
                'Material changes notified via email or in-app',
                'Continued use implies acceptance of updates',
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
            'Cookie Policy',
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
            'This Cookie Policy explains how SwiftSnap uses cookies and similar technologies to provide, improve, and secure our services.',
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

  Widget _buildCookieTable() {
    return Container(
      padding: const EdgeInsets.all(16),
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
            'Cookie Types Overview',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildCookieRow('Essential', 'Always Active', Colors.green),
          _buildCookieRow('Functional', 'User Controlled', Colors.blue),
          _buildCookieRow('Analytics', 'User Controlled', Colors.orange),
          _buildCookieRow('Advertising', 'User Controlled', Colors.purple),
        ],
      ),
    );
  }

  Widget _buildCookieRow(String type, String status, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              type,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
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
            'Questions About Cookies?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildContactItem(Icons.email, 'cookies@swiftsnap.one'),
          _buildContactItem(Icons.settings, 'Manage in Privacy Settings'),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
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
        ],
      ),
    );
  }
}
