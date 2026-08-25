import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/theme.dart';

class ManageExtensionsScreen extends StatefulWidget {
  const ManageExtensionsScreen({super.key});

  @override
  State<ManageExtensionsScreen> createState() => _ManageExtensionsScreenState();
}

class _ManageExtensionsScreenState extends State<ManageExtensionsScreen> {
  final List<Map<String, dynamic>> _extensions = [
    {
      'name': 'GIF Keyboard',
      'description': 'Send animated GIFs in chats',
      'icon': Icons.gif_box_rounded,
      'enabled': true,
      'premium': false,
    },
    {
      'name': 'Voice Effects',
      'description': 'Add filters to voice messages',
      'icon': Icons.mic_rounded,
      'enabled': true,
      'premium': true,
    },
    {
      'name': 'AR Stickers',
      'description': 'Augmented reality stickers',
      'icon': Icons.auto_awesome_rounded,
      'enabled': false,
      'premium': true,
    },
    {
      'name': 'Screen Share',
      'description': 'Share your screen in video calls',
      'icon': Icons.screen_share_rounded,
      'enabled': true,
      'premium': false,
    },
    {
      'name': 'Music Status',
      'description': 'Share what you\'re listening to',
      'icon': Icons.music_note_rounded,
      'enabled': false,
      'premium': false,
    },
    {
      'name': 'Games',
      'description': 'Play mini-games with friends',
      'icon': Icons.games_rounded,
      'enabled': true,
      'premium': true,
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
            _buildInfoCard(),
            _buildExtensionsList(),
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
              'Manage Extensions',
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

  Widget _buildInfoCard() {
    final enabledCount = _extensions.where((e) => e['enabled'] == true).length;
    
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              SwiftSnapTheme.primaryPurple.withOpacity(0.15),
              SwiftSnapTheme.primaryPink.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: SwiftSnapTheme.primaryPurple.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: SwiftSnapTheme.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.extension_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$enabledCount Active Extensions',
                    style: const TextStyle(
                      color: SwiftSnapTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Enhance your SwiftSnap experience',
                    style: TextStyle(
                      color: SwiftSnapTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0),
    );
  }

  Widget _buildExtensionsList() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final extension = _extensions[index];
            return _buildExtensionCard(extension, index)
                .animate(delay: Duration(milliseconds: 50 * index))
                .fadeIn(duration: 300.ms)
                .slideX(begin: 0.2, end: 0);
          },
          childCount: _extensions.length,
        ),
      ),
    );
  }

  Widget _buildExtensionCard(Map<String, dynamic> extension, int index) {
    final isEnabled = extension['enabled'] as bool;
    final isPremium = extension['premium'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SwiftSnapTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEnabled
              ? SwiftSnapTheme.primaryPurple.withOpacity(0.3)
              : Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: isEnabled ? SwiftSnapTheme.primaryGradient : null,
              color: isEnabled ? null : SwiftSnapTheme.backgroundCard,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              extension['icon'] as IconData,
              color: isEnabled ? Colors.white : SwiftSnapTheme.textMuted,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        extension['name'],
                        style: TextStyle(
                          color: isEnabled
                              ? SwiftSnapTheme.textPrimary
                              : SwiftSnapTheme.textMuted,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (isPremium) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          gradient: SwiftSnapTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, color: Colors.white, size: 10),
                            SizedBox(width: 2),
                            Text(
                              'PRO',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  extension['description'],
                  style: const TextStyle(
                    color: SwiftSnapTheme.textMuted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: isEnabled,
            onChanged: (value) {
              HapticFeedback.lightImpact();
              setState(() {
                _extensions[index]['enabled'] = value;
              });
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${extension['name']} ${value ? 'enabled' : 'disabled'}',
                  ),
                  backgroundColor: value
                      ? SwiftSnapTheme.accentGreen
                      : SwiftSnapTheme.surfaceColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            activeColor: SwiftSnapTheme.primaryPurple,
            activeTrackColor: SwiftSnapTheme.primaryPurple.withOpacity(0.3),
          ),
        ],
      ),
    );
  }
}
