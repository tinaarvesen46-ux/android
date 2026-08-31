import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user.dart';
import '../../providers/social_provider.dart';
import '../../theme/theme.dart';
import '../../widgets/common/app_top_bar.dart';
import '../../widgets/common/async_state_view.dart';
import '../../widgets/common/snap_avatar.dart';

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<SocialProvider>().loadBlocked();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SocialProvider>();

    return Scaffold(
      body: Column(
        children: [
          const AppTopBar(showBack: true, title: 'Blocked accounts'),
          Expanded(
            child: AsyncStateView<List<User>>(
              state: provider.blocked,
              emptyIcon: Icons.block_rounded,
              emptyTitle: 'No blocked accounts',
              onRetry: provider.loadBlocked,
              builder: (users) => ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return ListTile(
                    leading: SnapAvatar(
                      imageUrl: user.avatarUrl,
                      fallbackText: user.displayName,
                      size: AppTheme.avatarSm,
                    ),
                    title: Text(user.displayName),
                    subtitle: Text('@${user.username}'),
                    trailing: TextButton(
                      onPressed: () async {
                        final error = await provider.unblockUser(user.id);
                        if (error != null && context.mounted) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text(error)));
                        }
                      },
                      child: const Text('Unblock'),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
