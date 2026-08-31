import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/social.dart';
import '../models/user.dart';
import '../providers/social_provider.dart';
import '../theme/theme.dart';
import '../widgets/common/app_top_bar.dart';
import '../widgets/common/async_state_view.dart';
import '../widgets/common/snap_avatar.dart';
import '../widgets/common/role_badge.dart';
import '../widgets/common/snap_icon_button.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<SocialProvider>();
      provider.loadFriends();
      provider.loadRequests();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _notify(String? message, String fallback) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message ?? fallback)));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SocialProvider>();

    return Scaffold(
      body: Column(
        children: [
          AppTopBar(
            showBack: true,
            title: 'Friends',
            actions: [
              SnapIconButton(
                icon: Icons.person_add_alt_1_rounded,
                onTap: () => context.push('/search'),
              ),
            ],
          ),
          TabBar(
            controller: _tabController,
            tabs: const [Tab(text: 'Friends'), Tab(text: 'Requests')],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                AsyncStateView<List<User>>(
                  state: provider.friends,
                  emptyIcon: Icons.people_outline_rounded,
                  emptyTitle: 'No friends yet',
                  emptyMessage: 'Search for people to add them on SwiftSnap.',
                  emptyActionLabel: 'Find people',
                  onEmptyAction: () => context.push('/search'),
                  onRetry: provider.loadFriends,
                  builder: (friends) => ListView.builder(
                    itemCount: friends.length,
                    itemBuilder: (context, index) {
                      final friend = friends[index];
                      return ListTile(
                        leading: SnapAvatar(
                          imageUrl: friend.avatarUrl,
                          fallbackText: friend.displayName,
                          size: AppTheme.avatarSm,
                        ),
                        title: Text(friend.displayName),
                        subtitle: Text('@${friend.username}'),
                        trailing: RoleBadge(role: friend.role, roleLabel: friend.roleLabel),
                        onTap: () => context.push('/user/${friend.id}'),
                      );
                    },
                  ),
                ),
                AsyncStateView<List<FriendRequest>>(
                  state: provider.requests,
                  emptyIcon: Icons.mark_email_unread_outlined,
                  emptyTitle: 'No pending requests',
                  onRetry: provider.loadRequests,
                  builder: (requests) => ListView.builder(
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final request = requests[index];
                      final incoming = request.direction ==
                          FriendRequestDirection.incoming;
                      return ListTile(
                        leading: SnapAvatar(
                          imageUrl: request.user.avatarUrl,
                          fallbackText: request.user.displayName,
                          size: AppTheme.avatarSm,
                        ),
                        title: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(request.user.displayName),
                            RoleBadge(role: request.user.role, roleLabel: request.user.roleLabel),
                          ],
                        ),
                        subtitle:
                            Text(incoming ? 'Wants to be friends' : 'Request sent'),
                        onTap: () => context.push('/user/${request.user.id}'),
                        trailing: incoming
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.check_rounded),
                                    tooltip: 'Accept',
                                    onPressed: () async => _notify(
                                      await provider.acceptRequest(request.id),
                                      'Friend request accepted.',
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close_rounded),
                                    tooltip: 'Decline',
                                    onPressed: () async => _notify(
                                      await provider.declineRequest(request.id),
                                      'Friend request declined.',
                                    ),
                                  ),
                                ],
                              )
                            : TextButton(
                                onPressed: () async => _notify(
                                  await provider.cancelRequest(request.id),
                                  'Request cancelled.',
                                ),
                                child: const Text('Cancel'),
                              ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
