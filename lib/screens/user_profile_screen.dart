import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/social.dart';
import '../providers/social_provider.dart';
import '../theme/theme.dart';
import '../widgets/common/app_top_bar.dart';
import '../widgets/common/async_state_view.dart';
import '../widgets/common/snap_avatar.dart';
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
      if (mounted) context.read<SocialProvider>().loadProfile(widget.userId);
    });
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SocialProvider>();

    return Scaffold(
      body: Column(
        children: [
          const AppTopBar(showBack: true, title: 'Profile'),
          Expanded(
            child: AsyncStateView<UserProfile>(
              state: provider.profile,
              emptyIcon: Icons.person_off_outlined,
              emptyTitle: 'Profile unavailable',
              onRetry: () => provider.loadProfile(widget.userId),
              builder: (profile) => ListView(
                padding: const EdgeInsets.all(AppTheme.spacingXl),
                children: [
                  Center(
                    child: SnapAvatar(
                      imageUrl: profile.user.avatarUrl,
                      fallbackText: profile.user.displayName,
                      size: AppTheme.avatarXl,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  Text(
                    profile.user.displayName,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.spacingXxs),
                  Text(
                    '@${profile.user.username}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .extension<AppColorsExtension>()!
                              .subtleText,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.spacingXl),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ProfileStat(
                        value: '${profile.friendCount}',
                        label: 'Friends',
                      ),
                      ProfileStat(
                        value: '${profile.storyCount}',
                        label: 'Stories',
                      ),
                      ProfileStat(
                        value: '${profile.reelCount}',
                        label: 'Reels',
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingXxl),
                  _RelationshipActions(
                    profile: profile,
                    busy: _busy,
                    onAdd: () => _run(
                        () => provider.sendFriendRequest(widget.userId)),
                    onRemove: () =>
                        _run(() => provider.removeFriend(widget.userId)),
                    onBlock: () =>
                        _run(() => provider.blockUser(widget.userId)),
                    onUnblock: () =>
                        _run(() => provider.unblockUser(widget.userId)),
                    onReport: () => _run(() => provider.report(
                          type: 'user',
                          targetId: widget.userId,
                          reason: 'inappropriate',
                        )),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RelationshipActions extends StatelessWidget {
  final UserProfile profile;
  final bool busy;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final VoidCallback onBlock;
  final VoidCallback onUnblock;
  final VoidCallback onReport;

  const _RelationshipActions({
    required this.profile,
    required this.busy,
    required this.onAdd,
    required this.onRemove,
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
    switch (profile.relationship) {
      case RelationshipState.friends:
        primary = OutlinedButton(
          onPressed: busy ? null : onRemove,
          child: const Text('Remove friend'),
        );
        break;
      case RelationshipState.requestSent:
        primary = OutlinedButton(
          onPressed: null,
          child: const Text('Request sent'),
        );
        break;
      case RelationshipState.requestReceived:
        primary = Text(
          'This person sent you a friend request. Respond from Friends.',
          style:
              theme.textTheme.bodySmall?.copyWith(color: appColors.subtleText),
          textAlign: TextAlign.center,
        );
        break;
      default:
        primary = ElevatedButton(
          onPressed: busy ? null : onAdd,
          child: const Text('Add friend'),
        );
    }

    return Column(
      children: [
        primary,
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
