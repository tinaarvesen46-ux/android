import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user.dart';
import '../../providers/social_provider.dart';
import '../../theme/theme.dart';
import '../common/role_badge.dart';
import '../common/snap_avatar.dart';

/// Real friend picker backed by [SocialProvider.friends] — the SAME
/// authoritative friendship source used by the Friends screen, search and
/// profiles. Used for "Send To" (multi-select) and "New chat" (single tap).
/// Distinguishes LOADING / ERROR / EMPTY / HAS-FRIENDS explicitly; never
/// shows the empty state for a loading or failed request.
class FriendPickerSheet extends StatefulWidget {
  final bool multiSelect;
  final String title;

  const FriendPickerSheet({
    super.key,
    this.multiSelect = false,
    this.title = 'Friends',
  });

  @override
  State<FriendPickerSheet> createState() => _FriendPickerSheetState();
}

class _FriendPickerSheetState extends State<FriendPickerSheet> {
  final Set<String> _selected = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final social = context.read<SocialProvider>();
      if (social.friends.isIdle) unawaited(social.loadFriends());
    });
  }

  void _confirmSingle(User user) {
    Navigator.of(context).pop(<User>[user]);
  }

  void _toggle(String userId) {
    setState(() {
      if (_selected.contains(userId)) {
        _selected.remove(userId);
      } else {
        _selected.add(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = context.watch<SocialProvider>().friends;
    final insets = MediaQuery.paddingOf(context);

    Widget body;
    if (state.isLoading || state.isIdle) {
      body = const Padding(
        padding: EdgeInsets.symmetric(vertical: AppTheme.spacingXl),
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (state.hasError) {
      body = Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(state.message.isNotEmpty
                ? state.message
                : 'Could not load your friends.'),
            const SizedBox(height: AppTheme.spacingSm),
            TextButton(
              onPressed: () => context.read<SocialProvider>().loadFriends(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    } else if (state.isEmpty) {
      body = const Padding(
        padding: EdgeInsets.all(AppTheme.spacingXl),
        child: Center(child: Text('Add friends to send snaps to them.')),
      );
    } else {
      final friends = state.data ?? const <User>[];
      body = ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.55,
        ),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: friends.length,
          itemBuilder: (context, index) {
            final friend = friends[index];
            final isSelected = _selected.contains(friend.id);
            return ListTile(
              leading: SnapAvatar(
                imageUrl: friend.avatarUrl,
                fallbackText: friend.displayName,
                size: AppTheme.avatarSm,
              ),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(child: Text(friend.displayName, overflow: TextOverflow.ellipsis)),
                  RoleBadge(role: friend.role, roleLabel: friend.roleLabel),
                ],
              ),
              subtitle: Text('@${friend.username}'),
              trailing: widget.multiSelect
                  ? Checkbox(
                      value: isSelected,
                      onChanged: (_) => _toggle(friend.id),
                    )
                  : null,
              onTap: widget.multiSelect
                  ? () => _toggle(friend.id)
                  : () => _confirmSingle(friend),
            );
          },
        ),
      );
    }

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: insets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              child: Text(widget.title, style: theme.textTheme.titleMedium),
            ),
            body,
            if (widget.multiSelect && state.isSuccess) ...[
              const SizedBox(height: AppTheme.spacingSm),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingLg,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selected.isEmpty
                        ? null
                        : () {
                            final friends =
                                state.data ?? const <User>[];
                            final chosen = friends
                                .where((f) => _selected.contains(f.id))
                                .toList();
                            Navigator.of(context).pop(chosen);
                          },
                    child: Text(_selected.isEmpty
                        ? 'Send'
                        : 'Send to ${_selected.length}'),
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppTheme.spacingSm),
          ],
        ),
      ),
    );
  }
}
