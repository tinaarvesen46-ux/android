import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/theme.dart';
import 'user_guide_screen.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwiftSnapTheme.backgroundDark,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildHeader(context),
            _buildSearchBar(),
            _buildQuickActions(),
            _buildCategoryFilter(),
            _buildFAQSection(),
            _buildContactSupport(),
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
              'Help & Support',
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

  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          decoration: BoxDecoration(
            color: SwiftSnapTheme.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(
              color: SwiftSnapTheme.textPrimary,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: 'Search for help...',
              hintStyle: TextStyle(
                color: SwiftSnapTheme.textMuted,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: SwiftSnapTheme.textMuted,
                size: 22,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear_rounded,
                        color: SwiftSnapTheme.textMuted,
                      ),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                        });
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            onChanged: (value) => setState(() {}),
          ),
        ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0),
      ),
    );
  }

  Widget _buildQuickActions() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'QUICK ACTIONS',
                style: TextStyle(
                  color: SwiftSnapTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: 'Live Chat',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    ),
                    onTap: () => _showLiveChat(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.email_outlined,
                    label: 'Email Us',
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF093FB), Color(0xFFF5576C)],
                    ),
                    onTap: () => _sendEmail(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.phone_outlined,
                    label: 'Call Support',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
                    ),
                    onTap: () => _callSupport(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.menu_book_rounded,
                    label: 'User Guide',
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFA709A), Color(0xFFFEE140)],
                    ),
                    onTap: () => _openUserGuide(),
                  ),
                ),
              ],
            ),
          ],
        ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = ['All', 'Account', 'Privacy', 'Payments', 'Technical', 'Other'];
    
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = _selectedCategory == category;
              
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: isSelected ? SwiftSnapTheme.primaryGradient : null,
                      color: isSelected ? null : SwiftSnapTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : Colors.white.withOpacity(0.1),
                      ),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? Colors.white : SwiftSnapTheme.textSecondary,
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
      ),
    );
  }

  Widget _buildFAQSection() {
    final faqs = [
      {
        'question': 'How do I change my password?',
        'answer': 'Go to Settings > Password and follow the instructions to update your password securely.',
        'category': 'Account',
      },
      {
        'question': 'How do I manage my privacy settings?',
        'answer': 'Navigate to Settings > Privacy Control to customize who can see your profile, stories, and contact you.',
        'category': 'Privacy',
      },
      {
        'question': 'Can I delete my account?',
        'answer': 'Yes, go to Settings > Delete Account. Please note this action is permanent and cannot be undone.',
        'category': 'Account',
      },
      {
        'question': 'How do I report inappropriate content?',
        'answer': 'Tap and hold on any message or content, then select "Report". Our team will review it within 24 hours.',
        'category': 'Other',
      },
      {
        'question': 'Why can\'t I send messages?',
        'answer': 'Check your internet connection, ensure the app is up to date, and verify you haven\'t been blocked by the recipient.',
        'category': 'Technical',
      },
      {
        'question': 'How do I enable two-factor authentication?',
        'answer': 'Go to Settings > Security > Two-Factor Authentication and follow the setup wizard.',
        'category': 'Account',
      },
      {
        'question': 'What payment methods do you accept?',
        'answer': 'We accept all major credit cards, PayPal, Apple Pay, and Google Pay for SwiftSnap+ subscriptions.',
        'category': 'Payments',
      },
      {
        'question': 'How do I cancel my subscription?',
        'answer': 'Visit Settings > Account > Manage Subscription and select Cancel. Your premium features will remain active until the end of the billing period.',
        'category': 'Payments',
      },
    ];

    final filteredFAQs = _selectedCategory == 'All'
        ? faqs
        : faqs.where((faq) => faq['category'] == _selectedCategory).toList();

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'FREQUENTLY ASKED QUESTIONS',
                style: TextStyle(
                  color: SwiftSnapTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            ...filteredFAQs.map((faq) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildFAQItem(
                    question: faq['question']!,
                    answer: faq['answer']!,
                  ),
                )),
          ],
        ).animate().fadeIn(duration: 300.ms, delay: 300.ms),
      ),
    );
  }

  Widget _buildFAQItem({
    required String question,
    required String answer,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: SwiftSnapTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Theme(
        data: ThemeData(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          title: Text(
            question,
            style: const TextStyle(
              color: SwiftSnapTheme.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: SwiftSnapTheme.textSecondary,
          ),
          children: [
            Text(
              answer,
              style: TextStyle(
                color: SwiftSnapTheme.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSupport() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                SwiftSnapTheme.primaryPurple.withOpacity(0.2),
                SwiftSnapTheme.primaryPink.withOpacity(0.15),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: SwiftSnapTheme.primaryPurple.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: SwiftSnapTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: SwiftSnapTheme.glowShadow(
                    SwiftSnapTheme.primaryPurple,
                    intensity: 0.4,
                  ),
                ),
                child: const Icon(
                  Icons.support_agent_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Still Need Help?',
                style: TextStyle(
                  color: SwiftSnapTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Our support team is available 24/7 to assist you',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: SwiftSnapTheme.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  _showContactForm();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: SwiftSnapTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: SwiftSnapTheme.glowShadow(
                      SwiftSnapTheme.primaryPurple,
                      intensity: 0.3,
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.mail_outline_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Contact Support',
                        style: TextStyle(
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
        ).animate().fadeIn(duration: 300.ms, delay: 400.ms).scale(delay: 400.ms),
      ),
    );
  }

  void _showLiveChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SwiftSnapTheme.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.chat_bubble_rounded, color: SwiftSnapTheme.primaryPurple),
            SizedBox(width: 12),
            Text(
              'Live Chat',
              style: TextStyle(color: SwiftSnapTheme.textPrimary, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Text(
          'Connect with our support team now for immediate assistance.',
          style: TextStyle(color: SwiftSnapTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: SwiftSnapTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Connecting to live chat...')),
              );
            },
            child: const Text('Start Chat', style: TextStyle(color: SwiftSnapTheme.primaryPurple)),
          ),
        ],
      ),
    );
  }

  void _sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@swiftsnap.one',
      query: 'subject=SwiftSnap Support Request',
    );
    
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  void _callSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SwiftSnapTheme.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.phone_rounded, color: SwiftSnapTheme.primaryPurple),
            SizedBox(width: 12),
            Text(
              'Call Support',
              style: TextStyle(color: SwiftSnapTheme.textPrimary, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.phone_in_talk_rounded,
              size: 64,
              color: SwiftSnapTheme.primaryPurple.withOpacity(0.5),
            ),
            const SizedBox(height: 20),
            const Text(
              'Phone Support',
              style: TextStyle(
                color: SwiftSnapTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Coming Soon',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: SwiftSnapTheme.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Phone support will be available in the next update. For now, please use Email or Live Chat.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: SwiftSnapTheme.textMuted,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it', style: TextStyle(color: SwiftSnapTheme.primaryPurple)),
          ),
        ],
      ),
    );
  }

  void _openUserGuide() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UserGuideScreen()),
    );
  }

  void _showContactForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: SwiftSnapTheme.backgroundCard,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text(
                'Contact Support',
                style: TextStyle(
                  color: SwiftSnapTheme.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                style: const TextStyle(color: SwiftSnapTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Subject',
                  hintStyle: TextStyle(color: SwiftSnapTheme.textMuted),
                  filled: true,
                  fillColor: SwiftSnapTheme.surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                maxLines: 4,
                style: const TextStyle(color: SwiftSnapTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Describe your issue...',
                  hintStyle: TextStyle(color: SwiftSnapTheme.textMuted),
                  filled: true,
                  fillColor: SwiftSnapTheme.surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Message sent! We\'ll respond within 24 hours.'),
                      backgroundColor: SwiftSnapTheme.accentGreen,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: SwiftSnapTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    'Send Message',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
