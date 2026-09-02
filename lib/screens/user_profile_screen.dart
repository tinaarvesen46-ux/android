import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../models/social.dart';
import '../models/user.dart';
import '../providers/chats_provider.dart';
import '../services/realtime_service.dart';
import '../services/webrtc_service.dart';
import '../providers/social_provider.dart';
import '../theme/theme.dart';
import '../widgets/common/async_state_view.dart';
import 'profile_screen.dart';
import '../widgets/profile/profile_stat.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_loadProfile());
      // Subscribe to realtime updates for this user's avatar and refresh when it changes
      try {
        final realtime = context.read<RealtimeService>();
        unawaited(realtime.connect());
        final channel = 'private-user.${widget.userId}';
        unawaited(realtime.subscribePrivate(channel));
        realtime.on(channel, 'AvatarUpdated', (payload) {
          try {
            if (mounted) unawaited(_loadProfile());
          } catch (_) {}
        });
      } catch (_) {}
    });
  }

  Future<void> _loadProfile() async {
    final social = context.read<SocialProvider>();
    await social.loadProfile(widget.userId);
    if (!mounted) return;

    // Any contextual profile link can point at the signed-in user. Keep the
    // owner view on the same shared profile hub instead of exposing the
    // stranger/friend action surface for our own account.
    if (social.me.data?.id == social.profile.data?.user.id) {
      context.go('/profile');
    }
  }

  Future<void> _run(Future<String?> Function() action) async {
    setState(() => _busy = true);
    final error = await action();
    if (!mounted) return;
    setState(() => _busy = false);
    if (error != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Future<void> _messageFriend(UserProfile profile) async {
    setState(() => _busy = true);
    final chats = context.read<ChatsProvider>();
    final conversationId = await chats.startConversationWith(widget.userId);
    if (!mounted) return;
    setState(() => _busy = false);
    if (conversationId != null) {
      context.push('/chat/$conversationId');
    } else if (chats.lastError != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(chats.lastError!)));
    }
  }

  Future<void> _toggleFollow(UserProfile profile) async {
    setState(() => _busy = true);
    final social = context.read<SocialProvider>();
    String? err;
    if (profile.isFollowing) {
      err = await social.unfollowUser(widget.userId);
    } else {
      err = await social.followUser(widget.userId);
    }
    if (!mounted) return;
    setState(() => _busy = false);
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
  }

  Future<void> _startCall(UserProfile profile, String kind) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final callId = await context.read<WebRtcService>().createCall(
            calleeId: profile.user.id,
            kind: kind,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(callId.isEmpty
              ? 'Call request sent.'
              : '$kind call request sent.'),
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Calling is unavailable right now.')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _profileUrl(User user) => 'https://vexor.to/u/${user.username}';

  void _shareProfile(User user) {
    SharePlus.instance.share(
      ShareParams(
        text: 'Add me on SwiftSnap: ${_profileUrl(user)}',
        subject: 'SwiftSnap profile',
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
              ),
              const SizedBox(height: AppTheme.spacingMd),
              TextButton(
                onPressed: () => Navigator.of(sheetContext).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SocialProvider>();

    return Scaffold(
      body: AsyncStateView<UserProfile>(
        state: provider.profile,
        emptyIcon: Icons.person_off_outlined,
        emptyTitle: 'Profile unavailable',
        onRetry: _loadProfile,
        builder: (profile) => CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: ProfileHero(
                user: profile.user,
                unreadNotifications: 0,
                onBack: () => Navigator.of(context).maybePop(),
                onNotifications: () => context.push('/notifications'),
                onShare: () => _shareProfile(profile.user),
                onQr: () => _showQrCode(profile.user),
                onSettings: () => _showProfileActions(profile),
                onEditHeader: null,
                onEditProfile: profile.canMessage
                    ? () => _messageFriend(profile)
                    : profile.relationship == RelationshipState.none &&
                            profile.canSendFriendRequest
                        ? () => _run(() => provider.sendFriendRequest(widget.userId))
                        : null,
                onPublicProfile: () => _shareProfile(profile.user),
                primaryActionLabel: profile.canMessage
                    ? 'Message'
                    : profile.relationship == RelationshipState.none &&
                            profile.canSendFriendRequest
                        ? 'Add friend'
                        : 'Profile',
                secondaryActionLabel: 'Share profile',
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  ProfileCard(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSm),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ProfileStat(value: '${profile.friendCount}', label: 'Friends'),
                          ProfileStat(value: '${profile.storyCount}', label: 'Stories'),
                          ProfileStat(value: '${profile.reelCount}', label: 'Reels'),
                          GestureDetector(
                            onTap: profile.canViewContent
                                ? () => context.push('/user/${profile.user.id}/followers')
                                : null,
                            child: ProfileStat(value: '${profile.followerCount}', label: 'Followers'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingLg),
                  ProfileCard(
                    child: _RelationshipActions(
                      profile: profile,
                      busy: _busy,
                      canSendFriendRequest: profile.canSendFriendRequest,
                      onMessage: () => _messageFriend(profile),
                      onAudioCall: () => _startCall(profile, 'audio'),
                      onVideoCall: () => _startCall(profile, 'video'),
                      onAdd: () => _run(() => provider.sendFriendRequest(widget.userId)),
                      onCancel: profile.friendRequestId == null
                          ? null
                          : () => _run(() => provider.cancelRequest(
                                profile.friendRequestId!,
                                profileId: widget.userId,
                              )),
                      onRemove: () => _run(() => provider.removeFriend(widget.userId)),
                      onAccept: profile.friendRequestId == null
                          ? null
                          : () => _run(() => provider.acceptRequest(profile.friendRequestId!)),
                      onDecline: profile.friendRequestId == null
                          ? null
                          : () => _run(() => provider.declineRequest(profile.friendRequestId!)),
                      onBlock: () => _run(() => provider.blockUser(widget.userId)),
                      onUnblock: () => _run(() => provider.unblockUser(widget.userId)),
                      onReport: () => _run(() => provider.report(
                        type: 'user',
                        targetId: widget.userId,
                        reason: 'inappropriate',
                      )),
                    ),
                  ),
                  if (profile.isPublicProfile) ...[
                    const SizedBox(height: AppTheme.spacingLg),
                    ProfileCard(
                      child: ListTile(
                        leading: const Icon(Icons.public_rounded),
                        title: const Text('Public profile'),
                        subtitle: Text('${profile.followerCount} followers'),
                        trailing: FilledButton(
                          onPressed: _busy ? null : () => _toggleFollow(profile),
                          child: Text(profile.isFollowing ? 'Following' : 'Follow'),
                        ),
                        onTap: _busy ? null : () => _toggleFollow(profile),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppTheme.spacingLg),
                  if (profile.canViewContent) ...[
                    ProfileCard(
                      child: ListTile(
                        leading: const Icon(Icons.auto_stories_rounded),
                        title: const Text('Stories'),
                        subtitle: Text('${profile.storyCount} stories'),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingSm),
                    ProfileCard(
                      child: ListTile(
                        leading: const Icon(Icons.play_circle_outline_rounded),
                        title: const Text('Spotlight'),
                        subtitle: Text('${profile.reelCount} posts'),
                      ),
                    ),
                  ] else
                    ProfileCard(
                      child: ListTile(
                        leading: const Icon(Icons.lock_outline_rounded),
                        title: const Text('Private profile'),
                        subtitle: const Text('Only approved friends can view this content.'),
                      ),
                    ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProfileActions(UserProfile profile) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.block_rounded),
              title: const Text('Block'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _run(() => context.read<SocialProvider>().blockUser(profile.user.id));
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: const Text('Report'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _run(() => context.read<SocialProvider>().report(
                  type: 'user',
                  targetId: profile.user.id,
                  reason: 'inappropriate',
                ));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _RelationshipActions extends StatelessWidget {
  final UserProfile profile;
  final bool busy;
  final bool canSendFriendRequest;
  final VoidCallback onMessage;
  final VoidCallback onAudioCall;
  final VoidCallback onVideoCall;
  final VoidCallback onAdd;
  final VoidCallback? onCancel;
  final VoidCallback onRemove;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final VoidCallback onBlock;
  final VoidCallback onUnblock;
  final VoidCallback onReport;

  const _RelationshipActions({
    required this.profile,
    required this.busy,
    required this.canSendFriendRequest,
    required this.onMessage,
    required this.onAudioCall,
    required this.onVideoCall,
    required this.onAdd,
    required this.onCancel,
    required this.onRemove,
    required this.onAccept,
    required this.onDecline,
    required this.onBlock,
    required this.onUnblock,
    required this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;

    if (profile.relationship == RelationshipState.blockedBy) {
      return Text(
        'This profile is not available.',
        style: theme.textTheme.bodyMedium?.copyWith(color: appColors.subtleText),
        textAlign: TextAlign.center,
      );
    }

    if (profile.relationship == RelationshipState.blocked) {
      return OutlinedButton(
        onPressed: busy ? null : onUnblock,
        child: const Text('Unblock'),
      );
    }

    late final Widget primary;
    late final Widget? secondary;
    switch (profile.relationship) {
      case RelationshipState.friends:
        primary = Wrap(
          alignment: WrapAlignment.center,
          spacing: AppTheme.spacingSm,
          runSpacing: AppTheme.spacingSm,
          children: [
            ElevatedButton.icon(
              onPressed: busy ? null : onMessage,
              icon: const Icon(Icons.chat_bubble_rounded),
              label: const Text('Message'),
            ),
            OutlinedButton.icon(
              onPressed: busy ? null : onAudioCall,
              icon: const Icon(Icons.phone_outlined),
              label: const Text('Audio call'),
            ),
            OutlinedButton.icon(
              onPressed: busy ? null : onVideoCall,
              icon: const Icon(Icons.videocam_outlined),
              label: const Text('Video call'),
            ),
          ],
        );
        secondary = OutlinedButton(
          onPressed: busy ? null : onRemove,
          child: const Text('Remove friend'),
        );
        break;
      case RelationshipState.requestSent:
        primary = OutlinedButton(
          onPressed: busy || onCancel == null ? null : onCancel,
          child: Text(onCancel == null ? 'Request sent' : 'Cancel request'),
        );
        secondary = null;
        break;
      case RelationshipState.requestReceived:
        primary = onAccept == null || onDecline == null
            ? Text(
                'This person sent you a friend request. Respond from Friends.',
                style: theme.textTheme.bodySmall?.copyWith(
                    color: appColors.subtleText),
                textAlign: TextAlign.center,
              )
            : Wrap(
                alignment: WrapAlignment.center,
                spacing: AppTheme.spacingSm,
                children: [
                  ElevatedButton(
                    onPressed: busy ? null : onAccept,
                    child: const Text('Accept'),
                  ),
                  OutlinedButton(
                    onPressed: busy ? null : onDecline,
                    child: const Text('Decline'),
                  ),
                ],
              );
        secondary = null;
        break;
      default:
        final actions = <Widget>[];
        if (profile.canMessage) {
          actions.add(ElevatedButton.icon(
            onPressed: busy ? null : onMessage,
            icon: const Icon(Icons.chat_bubble_outline_rounded),
            label: const Text('Message'),
          ));
        }
        if (canSendFriendRequest) {
          actions.add(OutlinedButton(
            onPressed: busy ? null : onAdd,
            child: const Text('Add friend'),
          ));
        }
        primary = actions.isEmpty
            ? OutlinedButton(
                onPressed: null,
                child: const Text('No actions available'),
              )
            : Wrap(
                alignment: WrapAlignment.center,
                spacing: AppTheme.spacingSm,
                runSpacing: AppTheme.spacingSm,
                children: actions,
              );
        secondary = null;
    }

    return Column(
      children: [
        primary,
        if (secondary != null) ...[
          const SizedBox(height: AppTheme.spacingMd),
          secondary,
        ],
        const SizedBox(height: AppTheme.spacingMd),
        OutlinedButton(
          onPressed: busy ? null : onBlock,
          child: const Text('Block'),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        TextButton(
          onPressed: busy ? null : onReport,
          child: const Text('Report'),
        ),
      ],
    );
  }
}
