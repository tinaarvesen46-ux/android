import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/theme.dart';
import '../providers/app_provider.dart';
import '../models/user_model.dart';
import '../widgets/verification_badge.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showQRScanner() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SwiftSnapTheme.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.qr_code_scanner_rounded, color: SwiftSnapTheme.primaryPurple),
            SizedBox(width: 12),
            Text(
              'QR Code Scanner',
              style: TextStyle(color: SwiftSnapTheme.textPrimary, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                gradient: SwiftSnapTheme.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.qr_code_scanner,
                size: 120,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Point your camera at a QR code to scan',
              textAlign: TextAlign.center,
              style: TextStyle(color: SwiftSnapTheme.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAddFriendsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SwiftSnapTheme.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.person_add_rounded, color: SwiftSnapTheme.primaryPurple),
            SizedBox(width: 12),
            Text(
              'Add Friends',
              style: TextStyle(color: SwiftSnapTheme.textPrimary, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: const Text(
          'Find friends by username, phone, or scan their QR code.',
          style: TextStyle(color: SwiftSnapTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showCreateGroupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SwiftSnapTheme.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.group_add_rounded, color: SwiftSnapTheme.primaryPurple),
            SizedBox(width: 12),
            Text(
              'Create Group',
              style: TextStyle(color: SwiftSnapTheme.textPrimary, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              style: const TextStyle(color: SwiftSnapTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'Group Name',
                hintStyle: const TextStyle(color: SwiftSnapTheme.textMuted),
                filled: true,
                fillColor: SwiftSnapTheme.backgroundCard,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'You can add members after creating the group.',
              style: TextStyle(color: SwiftSnapTheme.textSecondary, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Group created successfully!'),
                  backgroundColor: SwiftSnapTheme.accentGreen,
                ),
              );
            },
            child: const Text('Create', style: TextStyle(color: SwiftSnapTheme.primaryPurple)),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwiftSnapTheme.backgroundDark,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildHeader(),
            _buildSearchBar(),
            if (_searchQuery.isEmpty) ...[
              _buildQuickActions(),
              _buildSuggestedSection(),
              _buildTrendingSection(),
            ] else
              _buildSearchResults(),
            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Discover',
              style: TextStyle(
                color: SwiftSnapTheme.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _showQRScanner();
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: SwiftSnapTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                child: const Icon(
                  Icons.qr_code_scanner_rounded,
                  color: SwiftSnapTheme.textPrimary,
                  size: 22,
                ),
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Container(
          decoration: BoxDecoration(
            color: SwiftSnapTheme.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(
              color: SwiftSnapTheme.textPrimary,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: 'Search by username...',
              hintStyle: TextStyle(
                color: SwiftSnapTheme.textMuted,
                fontSize: 16,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: SwiftSnapTheme.textMuted,
                size: 22,
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                      child: Icon(
                        Icons.close_rounded,
                        color: SwiftSnapTheme.textMuted,
                        size: 20,
                      ),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            onChanged: (value) {
              setState(() => _searchQuery = value);
            },
          ),
        ),
      ),
    );
  }
  
  Widget _buildQuickActions() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.person_add_rounded,
                label: 'Add Friends',
                gradient: SwiftSnapTheme.primaryGradient,
                onTap: _showAddFriendsDialog,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.group_add_rounded,
                label: 'Create Group',
                gradient: SwiftSnapTheme.secondaryGradient,
                onTap: _showCreateGroupDialog,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
    );
  }
  
  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (gradient as LinearGradient).colors.first.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSuggestedSection() {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final suggestions = provider.friends.take(4).toList();
        
        return SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Suggested Friends',
                      style: TextStyle(
                        color: SwiftSnapTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => HapticFeedback.lightImpact(),
                      child: const Text(
                        'See All',
                        style: TextStyle(
                          color: SwiftSnapTheme.primaryPurple,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: suggestions.length,
                  itemBuilder: (context, index) {
                    return _SuggestionCard(user: suggestions[index])
                        .animate(delay: Duration(milliseconds: 50 * index))
                        .fadeIn(duration: 300.ms)
                        .slideX(begin: 0.2, end: 0);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildTrendingSection() {
    final trendingTopics = [
      TrendingTopic(
        title: '#PhotoChallenge',
        participants: '12.5K',
        imageUrl: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=400',
      ),
      TrendingTopic(
        title: '#NightVibes',
        participants: '8.3K',
        imageUrl: 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=400',
      ),
      TrendingTopic(
        title: '#CreatorLife',
        participants: '21.2K',
        imageUrl: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400',
      ),
    ];
    
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: Text(
              'Trending Now',
              style: TextStyle(
                color: SwiftSnapTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ...trendingTopics.asMap().entries.map((entry) {
            return _TrendingCard(topic: entry.value)
                .animate(delay: Duration(milliseconds: 50 * entry.key))
                .fadeIn(duration: 300.ms)
                .slideX(begin: 0.1, end: 0);
          }),
        ],
      ),
    );
  }
  
  Widget _buildSearchResults() {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final results = provider.friends.where((user) {
          return user.displayName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              user.username.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();
        
        if (results.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: SwiftSnapTheme.surfaceColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.search_off_rounded,
                      color: SwiftSnapTheme.textMuted,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'No users found',
                    style: TextStyle(
                      color: SwiftSnapTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try a different username',
                    style: TextStyle(
                      color: SwiftSnapTheme.textMuted,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final user = results[index];
                return _SearchResultCard(user: user)
                    .animate(delay: Duration(milliseconds: 30 * index))
                    .fadeIn(duration: 200.ms);
              },
              childCount: results.length,
            ),
          ),
        );
      },
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final UserModel user;
  
  const _SuggestionCard({required this.user});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: SwiftSnapTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: user.isOnline ? SwiftSnapTheme.primaryGradient : null,
              border: !user.isOnline
                  ? Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 2,
                    )
                  : null,
            ),
            padding: const EdgeInsets.all(2),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: user.avatarUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  user.displayName,
                  style: const TextStyle(
                    color: SwiftSnapTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (user.accountStatus != AccountStatus.normal) ...[
                const SizedBox(width: 4),
                VerificationBadge(
                  accountStatus: user.accountStatus,
                  size: 14,
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${user.friendCount} mutual friends',
            style: TextStyle(
              color: SwiftSnapTheme.textMuted,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 12),
          Consumer<AppProvider>(
            builder: (context, provider, _) {
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  provider.sendFriendRequest(user);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Friend request sent to ${user.displayName}'),
                      backgroundColor: SwiftSnapTheme.primaryPurple,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: SwiftSnapTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Add',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TrendingCard extends StatelessWidget {
  final TrendingTopic topic;
  
  const _TrendingCard({required this.topic});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: SwiftSnapTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: topic.imageUrl,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          topic.title,
          style: const TextStyle(
            color: SwiftSnapTheme.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${topic.participants} participants',
          style: TextStyle(
            color: SwiftSnapTheme.textMuted,
            fontSize: 13,
          ),
        ),
        trailing: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Joined ${topic.title}!'),
                backgroundColor: SwiftSnapTheme.accentGreen,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: SwiftSnapTheme.primaryPurple.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Join',
              style: TextStyle(
                color: SwiftSnapTheme.primaryPurple,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        onTap: () => HapticFeedback.lightImpact(),
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  final UserModel user;
  
  const _SearchResultCard({required this.user});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: SwiftSnapTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundImage: CachedNetworkImageProvider(user.avatarUrl),
            ),
            if (user.isOnline)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: SwiftSnapTheme.online,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: SwiftSnapTheme.surfaceColor,
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Text(
              user.displayName,
              style: const TextStyle(
                color: SwiftSnapTheme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (user.accountStatus != AccountStatus.normal) ...[
              const SizedBox(width: 4),
              VerificationBadge(
                accountStatus: user.accountStatus,
                size: 16,
              ),
            ],
          ],
        ),
        subtitle: Text(
          '@${user.username}',
          style: TextStyle(
            color: SwiftSnapTheme.textMuted,
            fontSize: 13,
          ),
        ),
        trailing: Consumer<AppProvider>(
          builder: (context, provider, _) {
            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                provider.sendFriendRequest(user);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Friend request sent to ${user.displayName}'),
                    backgroundColor: SwiftSnapTheme.primaryPurple,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: SwiftSnapTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Add',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          },
        ),
        onTap: () => HapticFeedback.lightImpact(),
      ),
    );
  }
}

class TrendingTopic {
  final String title;
  final String participants;
  final String imageUrl;
  
  TrendingTopic({
    required this.title,
    required this.participants,
    required this.imageUrl,
  });
}
