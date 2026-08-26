import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../theme/theme.dart';
import '../providers/app_provider.dart';
import '../models/chat_model.dart';
import '../widgets/chat_tile.dart';
import '../widgets/story_circle.dart';
import 'chat_detail_screen.dart';
import 'camera_first_screen.dart';
import 'notifications_screen.dart';
import '../widgets/report_dialog.dart';
import '../api/services/user_service.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;
  String _searchQuery = '';
  
  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
  
  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchQuery = '';
        _searchFocusNode.unfocus();
      } else {
        _searchFocusNode.requestFocus();
      }
    });
    HapticFeedback.lightImpact();
  }
  
  List<ChatModel> _filterChats(List<ChatModel> chats) {
    if (_searchQuery.isEmpty) return chats;
    return chats.where((chat) {
      return chat.participant.displayName
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          chat.participant.username
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
    }).toList();
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final filteredChats = _filterChats(provider.chats);
        final pinnedChats = filteredChats.where((c) => c.isPinned).toList();
        final regularChats = filteredChats.where((c) => !c.isPinned).toList();
        
        return Scaffold(
          backgroundColor: SwiftSnapTheme.backgroundDark,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(),
              if (!_isSearching) ...[
                _buildStoriesSection(provider),
              ],
              if (pinnedChats.isNotEmpty) ...[
                _buildSectionHeader('Pinned', Icons.push_pin_rounded),
                _buildChatsList(pinnedChats, isPinned: true),
              ],
              _buildSectionHeader(
                pinnedChats.isNotEmpty ? 'Messages' : 'All Messages',
                Icons.message_rounded,
              ),
              _buildChatsList(regularChats),
              const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      pinned: true,
      expandedHeight: _isSearching ? 70 : 70,
      backgroundColor: SwiftSnapTheme.backgroundDark,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                SwiftSnapTheme.backgroundDark,
                SwiftSnapTheme.backgroundDark.withOpacity(0.95),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _isSearching
            ? _buildSearchField()
            : Row(
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) =>
                        SwiftSnapTheme.primaryGradient.createShader(bounds),
                    child: const Text(
                      'SwiftSnap',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: SwiftSnapTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'PRO',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
      ),
      actions: [
        _buildNotificationBell(),
        _buildIconButton(
          icon: _isSearching ? Icons.close_rounded : Icons.search_rounded,
          onTap: _toggleSearch,
        ),
        _buildIconButton(
          icon: Icons.edit_square,
          onTap: () => _showNewChatSheet(),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildNotificationBell() {
    final unread = context.watch<AppProvider>().unreadNotificationCount;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NotificationsScreen()),
        );
      },
      child: Container(
        width: 44,
        height: 44,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: SwiftSnapTheme.surfaceColor,
          borderRadius: BorderRadius.circular(SwiftSnapTheme.radiusMd),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(Icons.notifications_rounded,
                color: SwiftSnapTheme.textPrimary, size: 22),
            if (unread > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  decoration: BoxDecoration(
                    color: SwiftSnapTheme.primaryPink,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: SwiftSnapTheme.backgroundDark, width: 1.5),
                  ),
                  child: Text(
                    unread > 99 ? '99+' : '$unread',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSearchField() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: SwiftSnapTheme.surfaceColor,
        borderRadius: BorderRadius.circular(SwiftSnapTheme.radiusMd),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        style: const TextStyle(
          color: SwiftSnapTheme.textPrimary,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: 'Search messages...',
          hintStyle: TextStyle(
            color: SwiftSnapTheme.textMuted,
            fontSize: 16,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: SwiftSnapTheme.textMuted,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: (value) {
          setState(() => _searchQuery = value);
        },
      ),
    );
  }
  
  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: SwiftSnapTheme.surfaceColor,
          borderRadius: BorderRadius.circular(SwiftSnapTheme.radiusMd),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        child: Icon(
          icon,
          color: SwiftSnapTheme.textPrimary,
          size: 22,
        ),
      ),
    );
  }
  
  Widget _buildStoriesSection(AppProvider provider) {
    return SliverToBoxAdapter(
      child: Container(
        height: 110,
        margin: const EdgeInsets.only(top: 8),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          physics: const BouncingScrollPhysics(),
          itemCount: provider.stories.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildAddStoryButton(provider);
            }
            final story = provider.stories[index - 1];
            return StoryCircle(
              story: story,
              onTap: () => _viewStory(story),
            ).animate(delay: Duration(milliseconds: 50 * index))
              .fadeIn(duration: 300.ms)
              .slideX(begin: 0.2, end: 0);
          },
        ),
      ),
    );
  }
  
  Widget _buildAddStoryButton(AppProvider provider) {
    final hasOwnStory = provider.stories.any((s) => s.isOwn);
    
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () => _addStory(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: hasOwnStory 
                    ? SwiftSnapTheme.storyGradient 
                    : null,
                border: hasOwnStory
                    ? null
                    : Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 2,
                      ),
              ),
              padding: const EdgeInsets.all(3),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: SwiftSnapTheme.surfaceColor,
                  image: hasOwnStory && provider.currentUser != null
                      ? DecorationImage(
                          image: NetworkImage(provider.currentUser!.avatarUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: hasOwnStory
                    ? null
                    : Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SwiftSnapTheme.primaryGradient,
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasOwnStory ? 'Your Story' : 'Add Story',
              style: const TextStyle(
                color: SwiftSnapTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionHeader(String title, IconData icon) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: SwiftSnapTheme.primaryPurple.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: SwiftSnapTheme.primaryPurple,
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                color: SwiftSnapTheme.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildChatsList(List<ChatModel> chats, {bool isPinned = false}) {
    if (chats.isEmpty) {
      return SliverToBoxAdapter(
        child: _buildEmptyState(),
      );
    }
    
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final chat = chats[index];
          return ChatTile(
            chat: chat,
            onTap: () => _openChat(chat),
            onLongPress: () => _showChatOptions(chat),
          ).animate(delay: Duration(milliseconds: 30 * index))
            .fadeIn(duration: 250.ms)
            .slideX(begin: 0.05, end: 0);
        },
        childCount: chats.length,
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: SwiftSnapTheme.primaryPurple.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              color: SwiftSnapTheme.primaryPurple,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No conversations yet',
            style: TextStyle(
              color: SwiftSnapTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start chatting with your friends',
            style: TextStyle(
              color: SwiftSnapTheme.textMuted,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
  
  void _openChat(ChatModel chat) {
    HapticFeedback.lightImpact();
    context.read<AppProvider>().markChatAsRead(chat.id);
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ChatDetailScreen(chat: chat),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
  
  void _showChatOptions(ChatModel chat) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _ChatOptionsSheet(chat: chat),
    );
  }
  
  void _viewStory(dynamic story) {
    HapticFeedback.lightImpact();
    context.read<AppProvider>().markStoryAsViewed(story.id);
  }
  
  void _addStory() async {
    HapticFeedback.mediumImpact();
    final result = await Navigator.push<CameraResult>(
      context,
      MaterialPageRoute(builder: (_) => const CameraFirstScreen()),
    );
    if (result == null || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(const SnackBar(content: Text('Uploading to your story…')));
    final err = await context
        .read<AppProvider>()
        .publishStoryFromFile(result.file.path, isVideo: result.isVideo);
    if (!mounted) return;
    messenger.showSnackBar(SnackBar(content: Text(err ?? 'Posted to your story!')));
  }
  
  void _showNewChatSheet() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const _NewChatSheet(),
    );
  }
}

class _ChatOptionsSheet extends StatelessWidget {
  final ChatModel chat;
  
  const _ChatOptionsSheet({required this.chat});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SwiftSnapTheme.surfaceColor,
        borderRadius: BorderRadius.circular(SwiftSnapTheme.radiusXl),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage(chat.participant.avatarUrl),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chat.participant.displayName,
                        style: const TextStyle(
                          color: SwiftSnapTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '@${chat.participant.username}',
                        style: const TextStyle(
                          color: SwiftSnapTheme.textMuted,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(
            color: Colors.white.withOpacity(0.08),
            height: 1,
          ),
          _buildOption(
            context,
            icon: chat.isPinned ? Icons.push_pin_outlined : Icons.push_pin_rounded,
            label: chat.isPinned ? 'Unpin Chat' : 'Pin Chat',
            onTap: () {
              context.read<AppProvider>().togglePinChat(chat.id);
              Navigator.pop(context);
            },
          ),
          _buildOption(
            context,
            icon: Icons.notifications_off_outlined,
            label: 'Mute Notifications',
            onTap: () => Navigator.pop(context),
          ),
          _buildOption(
            context,
            icon: Icons.timer_outlined,
            label: 'Disappearing Messages',
            onTap: () => Navigator.pop(context),
          ),
          _buildOption(
            context,
            icon: Icons.flag_outlined,
            label: 'Report User',
            onTap: () {
              Navigator.pop(context);
              ReportDialog.show(
                context,
                userId: chat.participant.id,
                targetLabel: '@${chat.participant.username}',
              );
            },
          ),
          _buildOption(
            context,
            icon: Icons.block_outlined,
            label: 'Block User',
            color: SwiftSnapTheme.busy,
            onTap: () async {
              Navigator.pop(context);
              final res = await UserService().blockUser(chat.participant.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(res.isSuccess
                      ? 'Blocked @${chat.participant.username}'
                      : res.errorMessage)),
                );
              }
            },
          ),
          _buildOption(
            context,
            icon: Icons.delete_outline_rounded,
            label: 'Delete Chat',
            color: SwiftSnapTheme.busy,
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
  
  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    Color? color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              color: color ?? SwiftSnapTheme.textSecondary,
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                color: color ?? SwiftSnapTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewChatSheet extends StatelessWidget {
  const _NewChatSheet();
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SwiftSnapTheme.surfaceColor,
        borderRadius: BorderRadius.circular(SwiftSnapTheme.radiusXl),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'New Message',
                  style: TextStyle(
                    color: SwiftSnapTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: SwiftSnapTheme.backgroundCard,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: SwiftSnapTheme.textSecondary,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: SwiftSnapTheme.backgroundCard,
                borderRadius: BorderRadius.circular(SwiftSnapTheme.radiusMd),
              ),
              child: TextField(
                style: const TextStyle(color: SwiftSnapTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search friends...',
                  hintStyle: TextStyle(color: SwiftSnapTheme.textMuted),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: SwiftSnapTheme.textMuted,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Consumer<AppProvider>(
              builder: (context, provider, _) {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: provider.friends.length,
                  itemBuilder: (context, index) {
                    final friend = provider.friends[index];
                    return ListTile(
                      leading: Stack(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundImage: NetworkImage(friend.avatarUrl),
                          ),
                          if (friend.isOnline)
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
                            friend.displayName,
                            style: const TextStyle(
                              color: SwiftSnapTheme.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (friend.isVerified) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.verified_rounded,
                              color: SwiftSnapTheme.primaryPurple,
                              size: 16,
                            ),
                          ],
                        ],
                      ),
                      subtitle: Text(
                        '@${friend.username}',
                        style: TextStyle(
                          color: SwiftSnapTheme.textMuted,
                        ),
                      ),
                      onTap: () => Navigator.pop(context),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
