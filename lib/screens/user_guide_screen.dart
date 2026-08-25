import 'package:flutter/material.dart';
import '../theme/theme.dart';

class UserGuideScreen extends StatelessWidget {
  const UserGuideScreen({super.key});

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
          'User Guide',
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
            _buildGuideSection(
              'Getting Started',
              Icons.rocket_launch,
              Colors.blue,
              [
                GuideStep('Create Your Account', 'Sign up with email or phone number'),
                GuideStep('Set Up Profile', 'Add photo, bio, and personalize your profile'),
                GuideStep('Find Friends', 'Search for contacts or invite friends'),
                GuideStep('Start Chatting', 'Send your first message and share stories'),
              ],
            ),
            _buildGuideSection(
              'Messaging',
              Icons.message,
              Colors.purple,
              [
                GuideStep('Send Messages', 'Type and send text, emoji, or voice messages'),
                GuideStep('Share Media', 'Attach photos, videos, and files'),
                GuideStep('Create Groups', 'Start group chats with multiple friends'),
                GuideStep('Voice & Video', 'Make high-quality calls anytime'),
              ],
            ),
            _buildGuideSection(
              'Stories',
              Icons.auto_awesome,
              Colors.orange,
              [
                GuideStep('Create Story', 'Share moments that disappear in 24 hours'),
                GuideStep('Add Effects', 'Use filters, stickers, and text overlays'),
                GuideStep('Control Visibility', 'Choose who can view your stories'),
                GuideStep('View Friends', 'Tap story circles to see what friends shared'),
              ],
            ),
            _buildGuideSection(
              'Privacy & Security',
              Icons.security,
              Colors.green,
              [
                GuideStep('Privacy Levels', 'Set profile to Public, Friends, or Private'),
                GuideStep('Block Users', 'Prevent unwanted contacts from messaging'),
                GuideStep('Two-Factor Auth', 'Enable 2FA for extra account protection'),
                GuideStep('End-to-End Encryption', 'All messages are securely encrypted'),
              ],
            ),
            _buildGuideSection(
              'Discover',
              Icons.explore,
              Colors.teal,
              [
                GuideStep('Find New Friends', 'Browse suggested profiles'),
                GuideStep('Trending Topics', 'Explore popular conversations'),
                GuideStep('Quick Actions', 'Add friends with one tap'),
                GuideStep('Search', 'Find people, groups, and content'),
              ],
            ),
            _buildGuideSection(
              'SwiftSnap+',
              Icons.workspace_premium,
              Colors.amber,
              [
                GuideStep('Premium Themes', 'Access exclusive app designs'),
                GuideStep('Extended Features', 'Unlock advanced customization'),
                GuideStep('Priority Support', 'Get help faster from our team'),
                GuideStep('No Ads', 'Enjoy uninterrupted experience'),
              ],
            ),
            _buildGuideSection(
              'Settings & Customization',
              Icons.settings,
              Colors.indigo,
              [
                GuideStep('App Appearance', 'Change themes and color schemes'),
                GuideStep('Notifications', 'Control alerts and sounds'),
                GuideStep('Language', 'Choose from 50+ supported languages'),
                GuideStep('Data Management', 'Download or delete your data'),
              ],
            ),
            const SizedBox(height: 30),
            _buildTipsCard(),
            const SizedBox(height: 20),
            _buildSupportCard(context),
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
            'Welcome to SwiftSnap!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Your complete guide to mastering all features and getting the most out of SwiftSnap.',
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

  Widget _buildGuideSection(
    String title,
    IconData icon,
    Color color,
    List<GuideStep> steps,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            return _buildStepItem(index + 1, step.title, step.description, color);
          }),
        ],
      ),
    );
  }

  Widget _buildStepItem(int number, String title, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            child: Center(
              child: Text(
                '$number',
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white70,
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

  Widget _buildTipsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade900, Colors.purple.shade900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.amber, size: 24),
              SizedBox(width: 12),
              Text(
                'Pro Tips',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTipItem('Hold a message to react with emoji'),
          _buildTipItem('Swipe right on a message to reply'),
          _buildTipItem('Double-tap a story to send a quick reaction'),
          _buildTipItem('Use @ to mention friends in group chats'),
          _buildTipItem('Long press on send button to schedule messages'),
        ],
      ),
    );
  }

  Widget _buildTipItem(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Colors.greenAccent, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportCard(BuildContext context) {
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
            'Need More Help?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Our support team is here to help you with any questions.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.support_agent),
            label: const Text('Contact Support'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GuideStep {
  final String title;
  final String description;

  GuideStep(this.title, this.description);
}
