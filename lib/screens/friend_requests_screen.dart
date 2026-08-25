import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/theme.dart';
import '../providers/app_provider.dart';
import '../models/friend_request_model.dart';

class FriendRequestsScreen extends StatelessWidget {
  const FriendRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwiftSnapTheme.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: Consumer<AppProvider>(
                builder: (context, provider, _) {
                  final requests = provider.friendRequests;
                  
                  if (requests.isEmpty) {
                    return _buildEmptyState();
                  }
                  
                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      return _FriendRequestTile(
                        request: requests[index],
                      ).animate(delay: Duration(milliseconds: 50 * index))
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
  
  Widget _buildAppBar(BuildContext context) {
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
            'Friend Requests',
            style: TextStyle(
              color: SwiftSnapTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
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
              Icons.person_add_disabled_rounded,
              size: 60,
              color: SwiftSnapTheme.textMuted,
            ),
          ).animate().scale(duration: 300.ms),
          const SizedBox(height: 24),
          const Text(
            'No Friend Requests',
            style: TextStyle(
              color: SwiftSnapTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
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

class _FriendRequestTile extends StatelessWidget {
  final FriendRequestModel request;
  
  const _FriendRequestTile({required this.request});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SwiftSnapTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Row(
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
                            request.sender.displayName,
                            style: const TextStyle(
                              color: SwiftSnapTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (request.sender.isVerified) ...[
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
                      '@${request.sender.username}',
                      style: TextStyle(
                        color: SwiftSnapTheme.textMuted,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      request.timeAgo,
                      style: TextStyle(
                        color: SwiftSnapTheme.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (request.message != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: SwiftSnapTheme.backgroundCard,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                request.message!,
                style: const TextStyle(
                  color: SwiftSnapTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  label: 'Accept',
                  icon: Icons.check_rounded,
                  isPrimary: true,
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    context.read<AppProvider>().acceptFriendRequest(request.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('You are now friends with ${request.sender.displayName}!'),
                        backgroundColor: SwiftSnapTheme.accentGreen,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  label: 'Reject',
                  icon: Icons.close_rounded,
                  isPrimary: false,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.read<AppProvider>().rejectFriendRequest(request.id);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildAvatar() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: request.sender.isOnline 
            ? SwiftSnapTheme.primaryGradient 
            : null,
        border: !request.sender.isOnline
            ? Border.all(color: Colors.white.withOpacity(0.2), width: 2)
            : null,
      ),
      padding: const EdgeInsets.all(2),
      child: Stack(
        children: [
          ClipOval(
            child: CachedNetworkImage(
              imageUrl: request.sender.avatarUrl,
              fit: BoxFit.cover,
              width: 52,
              height: 52,
            ),
          ),
          if (request.sender.isOnline)
            Positioned(
              bottom: 0,
              right: 0,
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
    );
  }
  
  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: isPrimary ? SwiftSnapTheme.primaryGradient : null,
          color: isPrimary ? null : SwiftSnapTheme.backgroundCard,
          borderRadius: BorderRadius.circular(12),
          border: !isPrimary
              ? Border.all(color: Colors.white.withOpacity(0.1))
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isPrimary ? Colors.white : SwiftSnapTheme.textMuted,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isPrimary ? Colors.white : SwiftSnapTheme.textMuted,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
