import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/theme.dart';
import '../providers/app_provider.dart';
import '../models/user_model.dart';
import '../models/chat_model.dart';
import '../api/services/user_service.dart';
import 'friend_requests_screen.dart';
import 'chat_detail_screen.dart';
import 'discover_screen.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  String _searchQuery = '';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwiftSnapTheme.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildSearchBar(),
            _buildFriendRequestsBanner(),
            Expanded(
              child: Consumer<AppProvider>(
                builder: (context, provider, _) {
                  final friends = provider.friends.where((friend) {
                    if (_searchQuery.isEmpty) return true;
                    return friend.displayName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                           friend.username.toLowerCase().contains(_searchQuery.toLowerCase());
                  }).toList();
                  
                  if (friends.isEmpty) {
                    return _buildEmptyState();
                  }
                  
                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: friends.length,
                    itemBuilder: (context, index) {
                      return _FriendTile(
                        user: friends[index],
                      ).animate(delay: Duration(milliseconds: 30 * index))
                        .fadeIn(duration: 300.ms)
                        .slideX(begin: -0.1, end: 0);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: SwiftSnapTheme.backgroundCard,
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.08),
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              color: SwiftSnapTheme.textPrimary,
            ),
          ),
          const Text(
            'Friends',
            style: TextStyle(
              color: SwiftSnapTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const DiscoverScreen()));
            },
            icon: const Icon(
              Icons.person_add_rounded,
              color: SwiftSnapTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: SwiftSnapTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: TextField(
        style: const TextStyle(
          color: SwiftSnapTheme.textPrimary,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          hintText: 'Search friends...',
          hintStyle: TextStyle(
            color: SwiftSnapTheme.textMuted,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: SwiftSnapTheme.textMuted,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onChanged: (value) {
          setState(() => _searchQuery = value);
        },
      ),
    );
  }
  
  Widget _buildFriendRequestsBanner() {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final count = provider.friendRequestsCount;
        if (count == 0) return const SizedBox();
        
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FriendRequestsScreen(),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: SwiftSnapTheme.primaryGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: SwiftSnapTheme.glowShadow(
                SwiftSnapTheme.primaryPurple,
                intensity: 0.2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_add_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Friend Requests',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$count ${count == 1 ? 'request' : 'requests'} waiting',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1, end: 0),
        );
      },
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: SwiftSnapTheme.surfaceColor,
            ),
            child: Icon(
              Icons.people_rounded,
              size: 60,
              color: SwiftSnapTheme.textMuted,
            ),
          ).animate().scale(duration: 300.ms),
          const SizedBox(height: 24),
          const Text(
            'No Friends Found',
            style: TextStyle(
              color: SwiftSnapTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty 
                ? 'Start adding friends to see them here'
                : 'Try a different search',
            style: TextStyle(
              color: SwiftSnapTheme.textMuted,
              fontSize: 14,
            ),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }
}

class _FriendTile extends StatelessWidget {
  final UserModel user;
  
  const _FriendTile({required this.user});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: SwiftSnapTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: InkWell(
        onTap: () => _openChat(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              _buildAvatar(),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            user.displayName,
                            style: const TextStyle(
                              color: SwiftSnapTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (user.isVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified_rounded,
                            color: SwiftSnapTheme.primaryPurple,
                            size: 16,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '@${user.username}',
                      style: TextStyle(
                        color: SwiftSnapTheme.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              _buildMoreButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openChat(BuildContext context) async {
    HapticFeedback.lightImpact();
    final id = int.tryParse(user.id);
    if (id == null) return;
    final chat = await context.read<AppProvider>().openDirectChat(id);
    if (chat != null && context.mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => ChatDetailScreen(chat: chat)));
    }
  }

  void _showActions(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: SwiftSnapTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.chat_bubble_rounded, color: SwiftSnapTheme.primaryPurple),
              title: const Text('Message', style: TextStyle(color: SwiftSnapTheme.textPrimary)),
              onTap: () { Navigator.pop(sheetCtx); _openChat(context); },
            ),
            ListTile(
              leading: const Icon(Icons.block_rounded, color: SwiftSnapTheme.busy),
              title: Text('Block @${user.username}', style: const TextStyle(color: SwiftSnapTheme.busy)),
              onTap: () async {
                Navigator.pop(sheetCtx);
                final id = int.tryParse(user.id);
                if (id == null) return;
                final res = await UserService().blockUser(id.toString());
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(res.isSuccess ? 'Blocked @${user.username}' : res.errorMessage),
                  ));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAvatar() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: user.isOnline ? SwiftSnapTheme.primaryGradient : null,
        border: !user.isOnline
            ? Border.all(color: Colors.white.withOpacity(0.2), width: 2)
            : null,
      ),
      padding: const EdgeInsets.all(2),
      child: Stack(
        children: [
          ClipOval(
            child: CachedNetworkImage(
              imageUrl: user.avatarUrl,
              fit: BoxFit.cover,
              width: 48,
              height: 48,
            ),
          ),
          if (user.isOnline)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 12,
                height: 12,
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
    );
  }
  
  Widget _buildMoreButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showActions(context),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: SwiftSnapTheme.backgroundCard,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.more_horiz_rounded,
          color: SwiftSnapTheme.textMuted,
          size: 20,
        ),
      ),
    );
  }
}
