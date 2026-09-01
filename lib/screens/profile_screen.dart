import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../core/load_state.dart';
import '../models/media.dart';
import '../models/spotlight_post.dart';
import '../models/story.dart';
import '../models/user.dart';
import '../providers/chats_provider.dart';
import '../providers/feed_provider.dart';
import '../providers/memories_provider.dart';
import '../providers/social_provider.dart';
import '../services/api_service.dart';
import '../theme/theme.dart';
import '../widgets/common/async_state_view.dart';
import '../widgets/common/role_badge.dart';
import '../widgets/common/snap_avatar.dart';
import '../widgets/profile/profile_stat.dart';

/// Header-first profile hub. Profile is reached contextually from the shell's
/// other destinations and keeps the deeper account controls in Settings.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_loadInitialData());
    });
  }

  Future<void> _loadInitialData() async {
    final social = context.read<SocialProvider>();
    await social.loadMe();
    if (!mounted) return;

    final user = social.me.data;
    final loads = <Future<void>>[
      context.read<MemoriesProvider>().load(),
      context.read<ChatsProvider>().loadStories(),
      context.read<FeedProvider>().loadReels(),
      social.loadNotifications(),
    ];
    if (user != null) loads.add(social.loadProfile(user.id));
    await Future.wait(loads);
  }

  String _profileUrl(User user) => 'https://vexor.to/u/${user.username}';

  void _shareProfile(User user) {
    SharePlus.instance.share(
      ShareParams(
        text: 'Add me on SwiftSnap: ${_profileUrl(user)}',
        subject: 'My SwiftSnap profile',
      ),
    );
  }

  void _showQrCode(User user) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingXl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('@${user.username}', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppTheme.spacingLg),
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingLg),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                ),
                child: QrImageView(data: _profileUrl(user), size: 220),
              ),
              const SizedBox(height: AppTheme.spacingLg),
              Text(
                'Scan to open ${user.displayName}\'s SwiftSnap profile',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openPublicProfile() async {
    final social = context.read<SocialProvider>();
    final me = social.me.data;
    if (me == null) return;
    if (social.profile.data?.user.id != me.id) {
      await social.loadProfile(me.id);
    }
    if (!mounted) return;
    if (social.profile.data?.isPublicProfile == true) {
      context.push('/profile/public/edit');
    } else {
      context.push('/profile/public/create');
    }
  }

  void _showFamilyCentre() {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingXl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.family_restroom_rounded, size: AppTheme.iconHuge),
              const SizedBox(height: AppTheme.spacingMd),
              Text('Family Centre', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppTheme.spacingSm),
              Text(
                'Family safety tools will appear here when family supervision is enabled for your SwiftSnap account.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppTheme.spacingLg),
              FilledButton(
                onPressed: () => Navigator.of(sheetContext).pop(),
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final social = context.watch<SocialProvider>();

    return Scaffold(
      body: AsyncStateView<User>(
        state: social.me,
        onRetry: _loadInitialData,
        builder: (user) {
          final profile = social.profile.data;
          final memories = context.watch<MemoriesProvider>();
          final stories = context.watch<ChatsProvider>();
          final feed = context.watch<FeedProvider>();
          final unread = social.notifications.data
                  ?.where((notification) => !notification.isRead)
                  .length ??
              0;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _ProfileHero(
                  user: user,
                  unreadNotifications: unread,
                  onBack: () => Navigator.of(context).maybePop(),
                  onNotifications: () => context.push('/notifications'),
                  onShare: () => _shareProfile(user),
                  onQr: () => _showQrCode(user),
                  onSettings: () => context.push('/settings'),
                  onEditHeader: () => context.push('/profile/header'),
                  onEditProfile: () => context.push('/profile/edit'),
                  onPublicProfile: _openPublicProfile,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.spacingLg,
                  AppTheme.spacingLg,
                  AppTheme.spacingLg,
                  AppTheme.spacingHuge,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _StatsCard(
                      friends: profile?.friendCount ?? user.friendCount,
                      stories: profile?.storyCount ?? stories.stories.data?.length ?? 0,
                      spotlight: profile?.reelCount ?? feed.reels.data?.length ?? 0,
                      onFriends: () => context.push('/friends'),
                      onStories: () => context.push('/chats'),
                      onSpotlight: () => context.push('/reels'),
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                    _SwiftPlusCard(onTap: () => context.push('/swiftplus')),
                    const SizedBox(height: AppTheme.spacingMd),
                    _SectionHeading(title: 'Family Centre'),
                    _ProfileCard(
                      child: _ProfileActionTile(
                        icon: Icons.family_restroom_rounded,
                        title: 'Family Centre',
                        subtitle: 'Family safety and supervision tools',
                        onTap: _showFamilyCentre,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingLg),
                    _SectionHeading(
                      title: 'Post to...',
                      action: TextButton(
                        onPressed: () => context.push('/camera'),
                        child: const Text('New Story'),
                      ),
                    ),
                    _ProfileCard(
                      child: Column(
                        children: [
                          _ProfileActionTile(
                            icon: Icons.play_circle_fill_rounded,
                            title: 'Spotlight',
                            subtitle: 'Reach people beyond your friends',
                            trailing: 'Post',
                            onTap: () => context.push('/camera'),
                          ),
                          _ProfileActionTile(
                            icon: Icons.camera_alt_outlined,
                            title: 'My Story · Friends Only',
                            subtitle: 'Visible to your friends',
                            trailing: 'Add',
                            onTap: () => context.push('/camera'),
                          ),
                          _ProfileActionTile(
                            icon: Icons.public_rounded,
                            title: 'My Story · Public',
                            subtitle: 'Friends, followers, and everyone',
                            trailing: 'Add',
                            onTap: () => context.push('/camera'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingLg),
                    _SectionHeading(
                      title: 'My Stories',
                      action: TextButton(
                        onPressed: () => context.push('/chats'),
                        child: const Text('See all'),
                      ),
                    ),
                    _ProfileCard(
                      child: Column(
                        children: [
                          if (stories.stories.data != null &&
                              stories.stories.data!.isNotEmpty)
                            ...stories.stories.data!.map(
                              (story) => _BackendStoryTile(
                                story: story,
                                onTap: () => context.push('/story', extra: story),
                              ),
                            )
                          else
                            const _EmptyProfileRow(
                              icon: Icons.auto_stories_outlined,
                              text: 'Your published stories will appear here.',
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingLg),
                    _SectionHeading(
                      title: 'Memories',
                      action: TextButton(
                        onPressed: () => context.push('/memories'),
                        child: const Text('See all'),
                      ),
                    ),
                    _MemoryPreview(state: memories),
                    const SizedBox(height: AppTheme.spacingLg),
                    _SectionHeading(
                      title: 'Spotlight',
                      action: TextButton(
                        onPressed: () => context.push('/reels'),
                        child: const Text('See all'),
                      ),
                    ),
                    _SpotlightPreview(state: feed.reels),
                    const SizedBox(height: AppTheme.spacingLg),
                    _SectionHeading(title: 'Friends & Map'),
                    _ProfileCard(
                      child: Column(
                        children: [
                          _ProfileActionTile(
                            icon: Icons.people_alt_outlined,
                            title: 'Friends',
                            subtitle: '${user.friendCount} friends',
                            onTap: () => context.push('/friends'),
                          ),
                          _ProfileActionTile(
                            icon: Icons.person_add_alt_1_rounded,
                            title: 'Find friends',
                            subtitle: 'Add people from search or contacts',
                            onTap: () => context.push('/find-friends'),
                          ),
                          _ProfileActionTile(
                            icon: Icons.map_outlined,
                            title: 'Snap Map',
                            subtitle: 'See friends who share their location',
                            onTap: () => context.go('/map'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingLg),
                    _SectionHeading(title: 'My Favourites'),
                    _ProfileCard(
                      child: _ProfileActionTile(
                        icon: Icons.star_border_rounded,
                        title: 'My Favourites',
                        subtitle:
                            '${memories.memories.data?.where((item) => item.isFavorite).length ?? 0} saved memories',
                        onTap: () => context.push('/memories'),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingLg),
                    _SectionHeading(title: 'Public Profile'),
                    _ProfileCard(
                      child: _ProfileActionTile(
                        icon: Icons.public_rounded,
                        title: profile?.isPublicProfile == true
                            ? 'Edit Public Profile'
                            : 'Create Public Profile',
                        subtitle: profile?.isPublicProfile == true
                            ? 'Share your public presence with followers'
                            : 'Publish a profile for people to discover',
                        onTap: _openPublicProfile,
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  final User user;
  final int unreadNotifications;
  final VoidCallback onBack;
  final VoidCallback onNotifications;
  final VoidCallback onShare;
  final VoidCallback onQr;
  final VoidCallback onSettings;
  final VoidCallback onEditHeader;
  final VoidCallback onEditProfile;
  final VoidCallback onPublicProfile;

  const _ProfileHero({
    required this.user,
    required this.unreadNotifications,
    required this.onBack,
    required this.onNotifications,
    required this.onShare,
    required this.onQr,
    required this.onSettings,
    required this.onEditHeader,
    required this.onEditProfile,
    required this.onPublicProfile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final top = MediaQuery.paddingOf(context).top;

    return SizedBox(
      height: 420,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            SvgPicture.network(
              ApiService.resolveUrl('/api/v1/avatar/header/${user.id}'),
              fit: BoxFit.cover,
              placeholderBuilder: (_) => DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.32),
                    Colors.black.withValues(alpha: 0.06),
                    Colors.black.withValues(alpha: 0.72),
                  ],
                  stops: const [0, 0.4, 1],
                ),
              ),
            ),
            Positioned(
              top: top + AppTheme.spacingSm,
              left: AppTheme.spacingSm,
              right: AppTheme.spacingSm,
              child: Row(
                children: [
                  _HeaderIconButton(icon: Icons.arrow_back_rounded, tooltip: 'Back', onTap: onBack),
                  const Spacer(),
                  _HeaderIconButton(
                    icon: Icons.notifications_none_rounded,
                    tooltip: 'Notifications',
                    badge: unreadNotifications == 0 ? null : unreadNotifications,
                    onTap: onNotifications,
                  ),
                  _HeaderIconButton(icon: Icons.share_rounded, tooltip: 'Share profile', onTap: onShare),
                  _HeaderIconButton(icon: Icons.qr_code_rounded, tooltip: 'Profile QR code', onTap: onQr),
                  _HeaderIconButton(icon: Icons.settings_outlined, tooltip: 'Settings', onTap: onSettings),
                ],
              ),
            ),
            Positioned(
              top: top + 72,
              left: AppTheme.spacingLg,
              right: AppTheme.spacingLg,
              bottom: 86,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: SnapAvatar(
                          imageUrl: user.avatarUrl,
                          renderUrl: user.avatarRenderUrl,
                          fallbackText: user.displayName,
                          size: 128,
                        ),
                      ),
                      Positioned(
                        right: -4,
                        bottom: 0,
                        child: Material(
                          color: Colors.white,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: onEditHeader,
                            child: const Padding(
                              padding: EdgeInsets.all(10),
                              child: Icon(Icons.edit_rounded, color: Colors.black, size: 20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          user.displayName,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (user.isVerified && user.role == 'user')
                        const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Icon(Icons.verified_rounded, color: Colors.lightBlueAccent, size: 18),
                        ),
                      RoleBadge(role: user.role, roleLabel: user.roleLabel),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingXs),
                  Text('@${user.username}', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                ],
              ),
            ),
            Positioned(
              left: AppTheme.spacingLg,
              right: AppTheme.spacingLg,
              bottom: AppTheme.spacingLg,
              child: Row(
                children: [
                  Expanded(child: _HeroPill(label: 'My Account', filled: true, onTap: onEditProfile)),
                  const SizedBox(width: AppTheme.spacingMd),
                  Expanded(child: _HeroPill(label: 'Public Profile', onTap: onPublicProfile)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final int? badge;

  const _HeaderIconButton({required this.icon, required this.tooltip, required this.onTap, this.badge});

  @override
  Widget build(BuildContext context) => Tooltip(
        message: tooltip,
        child: Material(
          color: Colors.black.withValues(alpha: 0.42),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              width: 44,
              height: 44,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: AppTheme.iconMd),
                  if (badge != null)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        constraints: const BoxConstraints(minWidth: 8, minHeight: 8),
                        padding: badge! > 9
                            ? const EdgeInsets.symmetric(horizontal: 3, vertical: 1)
                            : EdgeInsets.zero,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error,
                          shape: BoxShape.circle,
                        ),
                        child: badge! > 9
                            ? Text(badge! > 99 ? '99+' : '$badge', style: const TextStyle(fontSize: 8, color: Colors.white))
                            : null,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
}

class _HeroPill extends StatelessWidget {
  final String label;
  final bool filled;
  final VoidCallback onTap;

  const _HeroPill({required this.label, required this.onTap, this.filled = false});

  @override
  Widget build(BuildContext context) => OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          backgroundColor: filled ? Colors.black.withValues(alpha: 0.42) : Colors.white.withValues(alpha: 0.18),
          foregroundColor: Colors.white,
          side: BorderSide(color: filled ? Colors.white : Colors.white54, width: filled ? 2 : 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        ),
        child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      );
}

class _StatsCard extends StatelessWidget {
  final int friends;
  final int stories;
  final int spotlight;
  final VoidCallback onFriends;
  final VoidCallback onStories;
  final VoidCallback onSpotlight;

  const _StatsCard({required this.friends, required this.stories, required this.spotlight, required this.onFriends, required this.onStories, required this.onSpotlight});

  @override
  Widget build(BuildContext context) => _ProfileCard(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ProfileStat(value: '$friends', label: 'Friends', onTap: onFriends),
            ProfileStat(value: '$stories', label: 'Stories', onTap: onStories),
            ProfileStat(value: '$spotlight', label: 'Spotlight', onTap: onSpotlight),
          ],
        ),
      );
}

class _SwiftPlusCard extends StatelessWidget {
  final VoidCallback onTap;

  const _SwiftPlusCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _ProfileCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.55)),
            ),
            child: Icon(Icons.workspace_premium_rounded, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SwiftSnap+', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: AppTheme.spacingXs),
                Text('Exclusive, experimental, and pre-release features.', style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;
  final Widget? action;

  const _SectionHeading({required this.title, this.action});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            if (action != null) action!,
          ],
        ),
      );
}

class _ProfileCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _ProfileCard({required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final card = Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.55)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingXs),
        child: child,
      ),
    );
    return onTap == null
        ? card
        : Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              onTap: onTap,
              child: card,
            ),
          );
  }
}

class _ProfileActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? trailing;
  final VoidCallback onTap;

  const _ProfileActionTile({required this.icon, required this.title, required this.onTap, this.subtitle, this.trailing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: subtitle == null
          ? null
          : Text(subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall?.copyWith(color: appColors.subtleText)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null) Text(trailing!, style: theme.textTheme.labelLarge?.copyWith(color: appColors.subtleText)),
          const SizedBox(width: AppTheme.spacingXs),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
      onTap: onTap,
    );
  }
}

class _BackendStoryTile extends StatelessWidget {
  final Story story;
  final VoidCallback onTap;

  const _BackendStoryTile({required this.story, required this.onTap});

  @override
  Widget build(BuildContext context) => ListTile(
        leading: SnapAvatar(
          imageUrl: story.author.avatarUrl,
          renderUrl: story.author.avatarRenderUrl,
          fallbackText: story.author.displayName,
          size: AppTheme.avatarMd,
          showStoryRing: true,
          storySeen: story.isSeen,
        ),
        title: Text('${story.author.displayName}\'s Story', maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text('${story.items.length} snap${story.items.length == 1 ? '' : 's'}'),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      );
}

class _MemoryPreview extends StatelessWidget {
  final MemoriesProvider state;

  const _MemoryPreview({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.memories.hasError) {
      return _InlineStatus(text: state.memories.message, onRetry: () => state.load());
    }
    final items = state.memories.data ?? const <MemoryItem>[];
    if (items.isEmpty) {
      return const _ProfileCard(
        child: _EmptyProfileRow(icon: Icons.bookmark_border_rounded, text: 'Captures you save to Memories will appear here.'),
      );
    }
    final preview = items.take(6).toList();
    return _ProfileCard(
      child: SizedBox(
        height: 104,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd, vertical: AppTheme.spacingSm),
          itemCount: preview.length,
          separatorBuilder: (_, __) => const SizedBox(width: AppTheme.spacingSm),
          itemBuilder: (context, index) {
            final item = preview[index];
            return ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              child: Image.network(
                ApiService.resolveUrl(item.thumbnailUrl ?? item.mediaUrl),
                width: 128,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => ColoredBox(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const SizedBox(width: 128, child: Icon(Icons.broken_image_outlined)),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SpotlightPreview extends StatelessWidget {
  final LoadState<List<SpotlightPost>> state;

  const _SpotlightPreview({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.hasError) return _InlineStatus(text: state.message);
    final posts = state.data ?? const <SpotlightPost>[];
    if (posts.isEmpty) {
      return const _ProfileCard(
        child: _EmptyProfileRow(icon: Icons.play_circle_outline_rounded, text: 'Spotlight posts from creators you follow will appear here.'),
      );
    }
    final visiblePosts = posts.take(6).toList();
    return _ProfileCard(
      child: SizedBox(
        height: 168,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(AppTheme.spacingSm),
          itemCount: visiblePosts.length,
          separatorBuilder: (_, __) => const SizedBox(width: AppTheme.spacingSm),
          itemBuilder: (context, index) {
            final post = visiblePosts[index];
            return ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              child: Image.network(
                ApiService.resolveUrl(post.thumbnailUrl ?? post.mediaUrl),
                width: 132,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => ColoredBox(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const SizedBox(width: 132, child: Icon(Icons.broken_image_outlined)),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _EmptyProfileRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _EmptyProfileRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: AppTheme.spacingMd),
            Expanded(child: Text(text)),
          ],
        ),
      );
}

class _InlineStatus extends StatelessWidget {
  final String text;
  final VoidCallback? onRetry;

  const _InlineStatus({required this.text, this.onRetry});

  @override
  Widget build(BuildContext context) => _ProfileCard(
        child: ListTile(
          leading: const Icon(Icons.cloud_off_rounded),
          title: Text(text.isEmpty ? 'This section is unavailable.' : text),
          trailing: onRetry == null
              ? null
              : IconButton(icon: const Icon(Icons.refresh_rounded), tooltip: 'Retry', onPressed: onRetry),
        ),
      );
}
