import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/load_state.dart';
import '../models/chat.dart';
import '../models/story.dart';
import '../models/user.dart';
import '../providers/chats_provider.dart';
import '../theme/theme.dart';
import '../widgets/chats/chat_row.dart';
import '../widgets/chats/friend_picker_sheet.dart';
import '../widgets/chats/story_row.dart';
import '../widgets/common/app_top_bar.dart';
import '../widgets/common/async_state_view.dart';
import '../widgets/common/snap_icon_button.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ChatsProvider>().load();
    });
  }

  void _openConversationActions(Conversation conversation) {
    final provider = context.read<ChatsProvider>();
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(conversation.isMuted
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_off_rounded),
              title: Text(conversation.isMuted ? 'Unmute' : 'Mute'),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                final error = await provider.setMuted(
                    conversation.id, !conversation.isMuted);
                if (error != null) _notify(error);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_rounded),
              title: const Text('View profile'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                context.push('/user/${conversation.participant.id}');
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded),
              title: const Text('Delete conversation'),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                final confirmed = await _confirmDelete();
                if (!confirmed) return;
                final error = await provider.deleteConversation(conversation.id);
                if (error != null) _notify(error);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _confirmDelete() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete conversation?'),
        content: const Text('This removes the conversation from your list.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _openNewChat() async {
    final selected = await showModalBottomSheet<List<User>>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) =>
          const FriendPickerSheet(multiSelect: false, title: 'New chat'),
    );
    if (selected == null || selected.isEmpty || !mounted) return;
    final chats = context.read<ChatsProvider>();
    final conversationId = await chats.startConversationWith(selected.first.id);
    if (!mounted) return;
    if (conversationId == null) {
      _notify(chats.lastError ?? 'Could not start this chat.');
      return;
    }
    context.push('/chat/$conversationId');
  }

  void _notify(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<ChatsProvider>();

    return Column(
      children: [
        AppTopBar(
          title: 'Chat',
          leading: SnapIconButton(
            icon: Icons.search_rounded,
            onTap: () => context.push('/search'),
          ),
          actions: [
            SnapIconButton(
              icon: Icons.add_comment_rounded,
              onTap: _openNewChat,
            ),
            SnapIconButton(
              icon: Icons.notifications_none_rounded,
              onTap: () => context.push('/notifications'),
            ),
            SnapIconButton(
              icon: Icons.person_outline_rounded,
              onTap: () => context.push('/profile'),
            ),
          ],
        ),
        _StoriesSection(state: provider.stories),
        Divider(color: theme.colorScheme.outlineVariant),
        Expanded(
          child: RefreshIndicator(
            onRefresh: provider.loadConversations,
            child: AsyncStateView<List<Conversation>>(
              state: provider.conversations,
              emptyIcon: Icons.chat_bubble_outline_rounded,
              emptyTitle: 'No conversations yet',
              emptyMessage: 'Find friends to start chatting on SwiftSnap.',
              emptyActionLabel: 'New chat',
              onEmptyAction: _openNewChat,
              onRetry: provider.loadConversations,
              builder: (conversations) => ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: conversations.length,
                itemBuilder: (context, index) {
                  final conversation = conversations[index];
                  return ChatRow(
                    conversation: conversation,
                    onTap: () => context.push('/chat/${conversation.id}'),
                    onLongPress: () => _openConversationActions(conversation),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StoriesSection extends StatelessWidget {
  final LoadState<List<Story>> state;

  const _StoriesSection({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.hasError) {
      return InlineErrorBar(
        message: state.message,
        onRetry: () => context.read<ChatsProvider>().loadStories(),
      );
    }
    if (state.isLoading) {
      return const SizedBox(
        height: 88,
        child: Center(
          child: SizedBox(
            width: AppTheme.iconMd,
            height: AppTheme.iconMd,
            child: CircularProgressIndicator(strokeWidth: AppTheme.borderThick),
          ),
        ),
      );
    }

    final stories = state.data ?? const <Story>[];
    return StoryRow(
      stories: stories,
      onAddStory: () => context.go('/camera'),
      onStoryTap: (story) => context.push('/story', extra: story),
    );
  }
}
