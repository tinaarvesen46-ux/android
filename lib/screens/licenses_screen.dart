import 'package:flutter/material.dart';
import '../theme/theme.dart';

class LicensesScreen extends StatelessWidget {
  const LicensesScreen({super.key});

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
          'Open Source Licenses',
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
            _buildLicenseCard(
              'Flutter',
              'BSD 3-Clause License',
              'UI framework for building beautiful applications',
              '© Google LLC',
            ),
            _buildLicenseCard(
              'Provider',
              'MIT License',
              'State management solution for Flutter applications',
              '© Remi Rousselet',
            ),
            _buildLicenseCard(
              'Google Fonts',
              'Apache License 2.0',
              'Font assets for beautiful typography',
              '© Google LLC',
            ),
            _buildLicenseCard(
              'Flex Color Scheme',
              'BSD 3-Clause License',
              'Advanced theming and color schemes',
              '© Mike Rydstrom',
            ),
            _buildLicenseCard(
              'Cached Network Image',
              'MIT License',
              'Efficient image loading and caching',
              '© Baseflow',
            ),
            _buildLicenseCard(
              'URL Launcher',
              'BSD 3-Clause License',
              'Platform integration for opening URLs',
              '© Flutter Team',
            ),
            _buildLicenseCard(
              'Share Plus',
              'BSD 3-Clause License',
              'Cross-platform sharing functionality',
              '© Flutter Community',
            ),
            _buildLicenseCard(
              'Dio',
              'MIT License',
              'Powerful HTTP client for Dart',
              '© Wendux',
            ),
            _buildLicenseCard(
              'Shared Preferences',
              'BSD 3-Clause License',
              'Platform-specific persistent storage',
              '© Flutter Team',
            ),
            _buildLicenseCard(
              'Flutter Secure Storage',
              'BSD 3-Clause License',
              'Encrypted storage for sensitive data',
              '© Mogol',
            ),
            _buildLicenseCard(
              'Intl',
              'BSD 3-Clause License',
              'Internationalization and localization',
              '© Dart Team',
            ),
            _buildLicenseCard(
              'UUID',
              'MIT License',
              'RFC4122 UUID generator',
              '© Paul DeMarco',
            ),
            _buildLicenseCard(
              'Connectivity Plus',
              'BSD 3-Clause License',
              'Network connectivity detection',
              '© Flutter Community',
            ),
            _buildLicenseCard(
              'Package Info Plus',
              'BSD 3-Clause License',
              'Application package information',
              '© Flutter Community',
            ),
            const SizedBox(height: 20),
            _buildNotice(),
            const SizedBox(height: 20),
            _buildFooter(context),
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
            'Open Source Licenses',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'SwiftSnap is built with amazing open source software. We thank all contributors and maintainers.',
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

  Widget _buildLicenseCard(
    String name,
    String license,
    String description,
    String copyright,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SwiftSnapTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: SwiftSnapTheme.borderColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: SwiftSnapTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.code,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      license,
                      style: TextStyle(
                        color: Colors.purple.shade300,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            copyright,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SwiftSnapTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.blue.shade300,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'This list includes major open source components. For a complete list of all dependencies and their licenses, please visit our GitHub repository or contact our legal team.',
              style: TextStyle(
                color: Colors.blue.shade200,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Column(
      children: [
        Divider(color: SwiftSnapTheme.borderColor),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () {
            showLicensePage(
              context: context,
              applicationName: 'SwiftSnap',
              applicationVersion: '3.2.1',
              applicationLegalese: '© 2026 Nexa-Group. All rights reserved.',
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            decoration: BoxDecoration(
              gradient: SwiftSnapTheme.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.article, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'View Full License Details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          '© 2026 Nexa-Group. All rights reserved.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
