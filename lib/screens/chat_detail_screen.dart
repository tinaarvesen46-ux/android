import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/chat.dart';
import '../providers/chats_provider.dart';
import '../providers/social_provider.dart';
import '../theme/theme.dart';
import '../services/webrtc_service.dart';
import '../widgets/chats/message_bubble.dart';
import '../widgets/chats/message_composer.dart';
import '../widgets/common/app_top_bar.dart';
import '../widgets/common/async_state_view.dart';
import '../widgets/common/role_badge.dart';
import '../widgets/common/snap_icon_button.dart';
import '../widgets/common/snap_avatar.dart';

class ChatDetailScreen extends StatefulWidget {
  final String conversationId;

  const ChatDetailScreen({super.key, required this.conversationId});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ChatsProvider>().loadMessages(widget.conversationId);
      final social = context.read<SocialProvider>();
      _currentUserId = social.me.data?.id;
      if (_currentUserId == null) social.loadMe();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Conversation? get _conversation {
    final conversations =
        context.read<ChatsProvider>().conversations.data ?? const [];
    for (final conversation in conversations) {
      if (conversation.id == widget.conversationId) return conversation;
    }
    return null;
  }

  Future<void> _send(String text) async {
    final error = await context.read<ChatsProvider>().sendMessage(
          conversationId: widget.conversationId,
          content: text,
        );
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 120,
        duration: AppTheme.animNormal,
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _startCall(String kind) async {
    final conversation = _conversation;
    if (conversation == null || conversation.isGroup || conversation.isAi) return;
    try {
      final id = await context.read<WebRtcService>().createCall(
            calleeId: conversation.participant.id,
            kind: kind,
            conversationId: conversation.id,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(id.isEmpty ? 'Call request sent.' : '$kind call request sent.'),
      ));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Calling is unavailable right now.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChatsProvider>();
    final social = context.watch<SocialProvider>();
    final conversation = _conversation;
    final myId = social.me.data?.id ?? _currentUserId ?? '';
    final title = conversation == null
        ? 'Chat'
        : (conversation.isGroup
            ? (conversation.groupName ?? 'Group')
            : conversation.participant.displayName);
    final subtitle = conversation == null || conversation.isGroup
        ? null
        : (conversation.isTyping
            ? 'Typing…'
            : (provider.isUserOnline(conversation.participant.id)
                ? 'Online'
                : null));

    return Scaffold(
      body: Column(
        children: [
          AppTopBar(
            showBack: true,
            title: title,
            titleWidget: conversation == null || conversation.isGroup
                ? null
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SnapAvatar(
                        imageUrl: conversation.participant.avatarUrl,
                        renderUrl: conversation.participant.avatarRenderUrl,
                        fallbackText: conversation.participant.displayName,
                        size: AppTheme.avatarSm,
                        showStoryRing: true,
                      ),
                      const SizedBox(width: AppTheme.spacingSm),
                      Flexible(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.titleLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      RoleBadge(
                        role: conversation.participant.role,
                        roleLabel: conversation.participant.roleLabel,
                      ),
                    ],
                  ),
            actions: [
              if (conversation != null && !conversation.isGroup && !conversation.isAi) ...[
                SnapIconButton(
                  icon: Icons.phone_outlined,
                  onTap: () => _startCall('audio'),
                ),
                SnapIconButton(
                  icon: Icons.videocam_outlined,
                  onTap: () => _startCall('video'),
                ),
                SnapIconButton(
                  icon: Icons.person_outline_rounded,
                  onTap: () =>
                      context.push('/user/${conversation.participant.id}'),
                ),
              ],
            ],
          ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(
                left: AppTheme.spacingXl,
                bottom: AppTheme.spacingXs,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  subtitle,
                  key: ValueKey(subtitle),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: conversation!.isTyping
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                                .extension<AppColorsExtension>()!
                                .subtleText,
                      ),
                ),
              ),
            ),
          Expanded(
            child: AsyncStateView<List<ChatMessage>>(
              state: provider.messagesFor(widget.conversationId),
              emptyIcon: Icons.forum_outlined,
              emptyTitle: 'No messages yet',
              emptyMessage: 'Say hello to start the conversation.',
              onRetry: () =>
                  provider.loadMessages(widget.conversationId),
              builder: (messages) => ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingMd,
                  vertical: AppTheme.spacingLg,
                ),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  return MessageBubble(
                    message: message,
                    isMine: message.senderId == myId,
                  );
                },
              ),
            ),
          ),
          MessageComposer(
            onSend: _send,
            onTypingChanged: (isTyping) =>
                context.read<ChatsProvider>().setTyping(widget.conversationId, isTyping),
          ),
        ],
      ),
    );
  }
}
