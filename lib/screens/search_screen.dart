import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../providers/social_provider.dart';
import '../theme/theme.dart';
import '../widgets/common/app_top_bar.dart';
import '../widgets/common/async_state_view.dart';
import '../widgets/common/empty_state_view.dart';
import '../widgets/common/snap_avatar.dart';
import '../widgets/common/role_badge.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) context.read<SocialProvider>().search(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SocialProvider>();

    return Scaffold(
      body: Column(
        children: [
          const AppTopBar(showBack: true, title: 'Search'),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingLg,
              vertical: AppTheme.spacingSm,
            ),
            child: TextField(
              controller: _controller,
              autofocus: true,
              onChanged: _onChanged,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                hintText: 'Search by name or username',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          Expanded(
            child: provider.searchResults.isIdle
                ? const EmptyStateView(
                    icon: Icons.search_rounded,
                    title: 'Find people on SwiftSnap',
                    subtitle: 'Search by display name or username.',
                  )
                : AsyncStateView<List<User>>(
                    state: provider.searchResults,
                    emptyIcon: Icons.person_search_rounded,
                    emptyTitle: 'No matches',
                    emptyMessage: 'Try a different name or username.',
                    onRetry: () => provider.search(_controller.text),
                    builder: (results) => ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final user = results[index];
                        return ListTile(
                          leading: SnapAvatar(
                            imageUrl: user.avatarUrl,
                            renderUrl: user.avatarRenderUrl,
                            fallbackText: user.displayName,
                            size: AppTheme.avatarSm,
                          ),
                          title: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(user.displayName),
                              RoleBadge(role: user.role, roleLabel: user.roleLabel),
                            ],
                          ),
                          subtitle: Text('@${user.username}'),
                          onTap: () => context.push('/user/${user.id}'),
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
