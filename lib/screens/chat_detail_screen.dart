import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import '../theme/theme.dart';
import '../models/chat_model.dart';
import '../models/user_model.dart';
import '../providers/app_provider.dart';
import '../widgets/report_dialog.dart';
import '../api/api_client.dart';
import '../api/services/user_service.dart';
import '../api/services/friend_service.dart';
import '../api/services/v32_service.dart';
import 'call_screen.dart';
import 'group_info_screen.dart';

class ChatDetailScreen extends StatefulWidget {
  final ChatModel chat;
  
  const ChatDetailScreen({super.key, required this.chat});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _isTyping = false;
  late AnimationController _sendButtonController;
  AppProvider? _provider;
  
  @override
  void initState() {
    super.initState();
    _sendButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    // Load real message history + mark conversation read + go live.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AppProvider>();
      _provider = provider;
      provider.loadChatMessages(widget.chat.id);
      provider.markChatAsRead(widget.chat.id);
      provider.subscribeToConversation(widget.chat.id);
    });
  }
  
  @override
  void dispose() {
    _provider?.unsubscribeFromConversation(widget.chat.id);
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _sendButtonController.dispose();
    super.dispose();
  }
  
  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    
    HapticFeedback.lightImpact();
    final content = _messageController.text.trim();
    _messageController.clear();
    setState(() => _isTyping = false);
    _sendButtonController.reverse();
    
    context.read<AppProvider>().sendMessage(widget.chat.id, content);
    _scrollToBottom();
  }

  void _openGroupInfo() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GroupInfoScreen(chat: widget.chat)),
    );
  }


  Future<void> _startCall(bool video) async {
    HapticFeedback.mediumImpact();    final calleeId = int.tryParse(widget.chat.participant.id);
    if (calleeId == null) return;
    final conversationId = int.tryParse(widget.chat.id);
    final messenger = ScaffoldMessenger.of(context);
    final res = await SwiftSnapV32Service().initiateCall(
      calleeId: calleeId,
      type: video ? 'video' : 'audio',
      conversationId: conversationId,
    );
    if (!mounted) return;
    if (!res.success || res.data == null) {
      messenger.showSnackBar(SnackBar(content: Text(res.message ?? 'Could not start call')));
      return;
    }
    final uuid = (res.data!['uuid'] ?? '').toString();
    if (uuid.isEmpty) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => CallScreen(
        callUuid: uuid,
        isCaller: true,
        isVideo: video,
        peerName: widget.chat.participant.displayName,
      ),
    ));
  }

  Future<void> _pickAndSendMedia() async {
    final source = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: SwiftSnapTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: SwiftSnapTheme.primaryPurple),
              title: const Text('Take a photo', style: TextStyle(color: SwiftSnapTheme.textPrimary)),
              subtitle: const Text('Snap & send directly', style: TextStyle(color: SwiftSnapTheme.textMuted, fontSize: 12)),
              onTap: () => Navigator.pop(context, 'camera'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_rounded, color: SwiftSnapTheme.primaryPink),
              title: const Text('Photo from library', style: TextStyle(color: SwiftSnapTheme.textPrimary)),
              onTap: () => Navigator.pop(context, 'image'),
            ),
            ListTile(
              leading: const Icon(Icons.videocam_rounded, color: SwiftSnapTheme.busy),
              title: const Text('Video from library', style: TextStyle(color: SwiftSnapTheme.textPrimary)),
              onTap: () => Navigator.pop(context, 'video'),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;
    final picker = ImagePicker();
    XFile? file;
    String type = 'image';
    try {
      if (source == 'camera') {
        file = await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
      } else if (source == 'video') {
        file = await picker.pickVideo(source: ImageSource.gallery);
        type = 'video';
      } else {
        file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      }
    } catch (_) {}
    if (file == null || !mounted) return;
    // Optimistic pending bubble is shown by the provider; only surface errors.
    final err = await context
        .read<AppProvider>()
        .sendMediaMessage(widget.chat.id, file.path, type: type);
    if (!mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
    _scrollToBottom();
  }

  void _showEmojiSheet() {
    const emojis = ['😀','😂','😍','😊','😉','😎','😢','😭','😡','👍','👎','🙏',
      '👏','🔥','❤️','💜','💯','🎉','😅','🤔','😴','🥳','😱','🤩','😇','🙌','💪','✨'];
    showModalBottomSheet(
      context: context,
      backgroundColor: SwiftSnapTheme.surfaceColor,
      builder: (_) => SafeArea(
        child: Container(
          height: 240,
          padding: const EdgeInsets.all(12),
          child: GridView.count(
            crossAxisCount: 7,
            children: emojis
                .map((e) => GestureDetector(
                      onTap: () {
                        _messageController.text += e;
                        setState(() => _isTyping = _messageController.text.isNotEmpty);
                        _sendButtonController.forward();
                        Navigator.pop(context);
                        _focusNode.requestFocus();
                      },
                      child: Center(child: Text(e, style: const TextStyle(fontSize: 26))),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }

  void _showChatOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: SwiftSnapTheme.surfaceColor,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_rounded, color: SwiftSnapTheme.textPrimary),
              title: const Text('View profile', style: TextStyle(color: SwiftSnapTheme.textPrimary)),
              onTap: () { Navigator.pop(context); _showProfileSheet(); },
            ),
            ListTile(
              leading: const Icon(Icons.flag_outlined, color: SwiftSnapTheme.textPrimary),
              title: const Text('Report user', style: TextStyle(color: SwiftSnapTheme.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                ReportDialog.show(context,
                    userId: widget.chat.participant.id,
                    targetLabel: '@${widget.chat.participant.username}');
              },
            ),
            ListTile(
              leading: const Icon(Icons.block_rounded, color: SwiftSnapTheme.busy),
              title: const Text('Block user', style: TextStyle(color: SwiftSnapTheme.busy)),
              onTap: () async {
                Navigator.pop(context);
                final res = await UserService().blockUser(widget.chat.participant.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(res.isSuccess
                          ? 'Blocked @${widget.chat.participant.username}'
                          : res.errorMessage)));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwiftSnapTheme.backgroundDark,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _buildMessagesList(),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }
  
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: BoxDecoration(
        color: SwiftSnapTheme.backgroundCard.withOpacity(0.95),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.08),
          ),
        ),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios_rounded,
                    color: SwiftSnapTheme.textPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: () => widget.chat.isGroup ? _openGroupInfo() : _showProfileSheet(),
                  child: Row(
                    children: [
                      _buildAvatar(),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Text(
                                widget.chat.title,
                                style: const TextStyle(
                                  color: SwiftSnapTheme.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (!widget.chat.isGroup && widget.chat.participant.isVerified) ...[
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.verified_rounded,
                                  color: SwiftSnapTheme.primaryPurple,
                                  size: 16,
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          if (widget.chat.isGroup)
                            Builder(builder: (context) {
                              final live = context.watch<AppProvider>();
                              return Text(
                                live.isTypingIn(widget.chat.id)
                                    ? 'typing…'
                                    : '${widget.chat.participants.length + 1} members',
                                style: const TextStyle(
                                    color: SwiftSnapTheme.textMuted, fontSize: 12),
                              );
                            })
                          else
                          Builder(builder: (context) {
                            final live = context.watch<AppProvider>();
                            final online = live.isUserOnline(widget.chat.participant.id);
                            return Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: online
                                      ? SwiftSnapTheme.online
                                      : SwiftSnapTheme.offline,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                live.isTypingIn(widget.chat.id)
                                    ? 'typing…'
                                    : (online
                                        ? 'Online'
                                        : widget.chat.participant.lastSeenFormatted),
                                style: TextStyle(
                                  color: online
                                      ? SwiftSnapTheme.online
                                      : SwiftSnapTheme.textMuted,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          );}),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (widget.chat.isGroup)
                  _buildHeaderAction(Icons.group_rounded, _openGroupInfo)
                else ...[
                  _buildHeaderAction(Icons.videocam_rounded,
                      () => _startCall(true)),
                  _buildHeaderAction(Icons.call_rounded,
                      () => _startCall(false)),
                ],
                _buildHeaderAction(Icons.more_vert_rounded, _showChatOptions),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildAvatar() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: widget.chat.participant.isOnline
            ? SwiftSnapTheme.primaryGradient
            : null,
        border: !widget.chat.participant.isOnline
            ? Border.all(color: Colors.white.withOpacity(0.2), width: 2)
            : null,
      ),
      padding: const EdgeInsets.all(2),
      child: CircleAvatar(
        backgroundImage: NetworkImage(widget.chat.participant.avatarUrl),
      ),
    );
  }
  
  Widget _buildHeaderAction(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 40,
        height: 40,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: SwiftSnapTheme.surfaceColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: SwiftSnapTheme.textSecondary,
          size: 20,
        ),
      ),
    );
  }
  
  Widget _buildMessagesList() {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final messages = provider.getChatMessages(widget.chat.id);
        
        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          physics: const BouncingScrollPhysics(),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            final isMe = message.senderId == provider.currentUser?.id;
            final showAvatar = !isMe && 
                (index == messages.length - 1 || 
                 messages[index + 1].senderId != message.senderId);
            
            return _MessageBubble(
              message: message,
              isMe: isMe,
              showAvatar: showAvatar,
              participant: widget.chat.participant,
              chatId: widget.chat.id,
            ).animate(delay: Duration(milliseconds: 30 * index))
              .fadeIn(duration: 200.ms)
              .slideY(begin: 0.1, end: 0);
          },
        );
      },
    );
  }
  
  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: SwiftSnapTheme.backgroundCard.withOpacity(0.95),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.08),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: _pickAndSendMedia,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: SwiftSnapTheme.surfaceColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_rounded,
                color: SwiftSnapTheme.textSecondary,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: SwiftSnapTheme.surfaceColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      focusNode: _focusNode,
                      maxLines: 5,
                      minLines: 1,
                      style: const TextStyle(
                        color: SwiftSnapTheme.textPrimary,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Message...',
                        hintStyle: TextStyle(
                          color: SwiftSnapTheme.textMuted,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onChanged: (value) {
                        setState(() => _isTyping = value.isNotEmpty);
                        if (value.isNotEmpty) {
                          context.read<AppProvider>().sendTyping(widget.chat.id);
                          _sendButtonController.forward();
                        } else {
                          _sendButtonController.reverse();
                        }
                      },
                    ),
                  ),
                  GestureDetector(
                    onTap: _showEmojiSheet,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        Icons.emoji_emotions_outlined,
                        color: SwiftSnapTheme.textMuted,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _isTyping ? _sendMessage : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: _isTyping ? SwiftSnapTheme.primaryGradient : null,
                color: _isTyping ? null : SwiftSnapTheme.surfaceColor,
                shape: BoxShape.circle,
                boxShadow: _isTyping
                    ? SwiftSnapTheme.glowShadow(
                        SwiftSnapTheme.primaryPurple,
                        intensity: 0.3,
                      )
                    : null,
              ),
              child: Icon(
                _isTyping ? Icons.send_rounded : Icons.mic_rounded,
                color: _isTyping ? Colors.white : SwiftSnapTheme.textSecondary,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showProfileSheet() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _ProfileSheet(user: widget.chat.participant),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final bool showAvatar;
  final UserModel participant;
  final String chatId;
  
  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.showAvatar,
    required this.participant,
    required this.chatId,
  });

  bool get _hasMedia =>
      (message.type == MessageType.image || message.type == MessageType.video) &&
      (message.mediaUrl != null && message.mediaUrl!.isNotEmpty);

  Widget _buildMedia(BuildContext context) {
    final url = message.mediaUrl!;
    final isLocal = !url.startsWith('http');
    final w = MediaQuery.of(context).size.width * 0.62;
    Widget child;
    if (message.type == MessageType.video) {
      child = GestureDetector(
        onTap: isLocal ? null : () => _openVideo(context, url),
        child: Container(
          width: w,
          height: w * 1.1,
          color: Colors.black26,
          child: const Center(
            child: Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 54),
          ),
        ),
      );
    } else if (isLocal) {
      child = Image.file(File(url), width: w, fit: BoxFit.cover);
    } else {
      child = CachedNetworkImage(
        imageUrl: url,
        httpHeaders: {'Authorization': 'Bearer ${ApiClient.currentToken ?? ''}'},
        width: w,
        fit: BoxFit.cover,
        placeholder: (c, _) => Container(
          width: w, height: w,
          color: Colors.black26,
          child: const Center(
            child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)),
          ),
        ),
        errorWidget: (c, _, __) => Container(
          width: w, height: w,
          color: Colors.black26,
          child: const Icon(Icons.broken_image_rounded, color: Colors.white54),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        children: [
          child,
          if (message.status == MessageStatus.sending)
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0x66000000),
                child: Center(
                  child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                ),
              ),
            ),
          if (message.status == MessageStatus.failed)
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0x88000000),
                child: Center(child: Icon(Icons.error_outline_rounded, color: Colors.white, size: 34)),
              ),
            ),
        ],
      ),
    );
  }

  void _openVideo(BuildContext context, String url) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => _VideoPlayerScreen(url: url),
    ));
  }
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            if (showAvatar)
              CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(participant.avatarUrl),
              )
            else
              const SizedBox(width: 32),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: GestureDetector(
              onLongPress: () => _showReactionPicker(context),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: isMe ? SwiftSnapTheme.primaryGradient : null,
                  color: isMe ? null : SwiftSnapTheme.surfaceColor,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(isMe ? 20 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 20),
                  ),
                  boxShadow: isMe
                      ? [
                          BoxShadow(
                            color: SwiftSnapTheme.primaryPurple.withOpacity(0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (_hasMedia) ...[
                      _buildMedia(context),
                      if (message.content.isNotEmpty) const SizedBox(height: 6),
                    ],
                    if (message.content.isNotEmpty)
                      Text(
                        message.content,
                        style: TextStyle(
                          color: isMe
                              ? Colors.white
                              : SwiftSnapTheme.textPrimary,
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                    if (message.reactions.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 2,
                        children: message.reactions
                            .map((r) => Text(r.emoji, style: const TextStyle(fontSize: 15)))
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          message.timeFormatted,
                          style: TextStyle(
                            color: isMe
                                ? Colors.white.withOpacity(0.7)
                                : SwiftSnapTheme.textMuted,
                            fontSize: 11,
                          ),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 4),
                          Icon(
                            message.status == MessageStatus.read
                                ? Icons.done_all_rounded
                                : message.status == MessageStatus.delivered
                                    ? Icons.done_all_rounded
                                    : Icons.done_rounded,
                            size: 14,
                            color: message.status == MessageStatus.read
                                ? Colors.white
                                : Colors.white.withOpacity(0.7),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }
  
  void _showReactionPicker(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 100,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: SwiftSnapTheme.surfaceColor,
          borderRadius: BorderRadius.circular(SwiftSnapTheme.radiusXl),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['❤️', '😂', '😮', '😢', '😡', '👍']
              .map((emoji) => GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.read<AppProvider>().reactToMessage(chatId, message.id, emoji);
                      Navigator.pop(context);
                    },
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

/// Minimal full-screen player for chat video messages (authed stream URL).
class _VideoPlayerScreen extends StatefulWidget {
  final String url;
  const _VideoPlayerScreen({required this.url});
  @override
  State<_VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<_VideoPlayerScreen> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.url),
      httpHeaders: {'Authorization': 'Bearer ${ApiClient.currentToken ?? ''}'},
    )..initialize().then((_) {
        if (mounted) {
          setState(() {});
          _controller?.play();
        }
      });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: (c != null && c.value.isInitialized)
            ? AspectRatio(aspectRatio: c.value.aspectRatio, child: VideoPlayer(c))
            : const CircularProgressIndicator(color: Colors.white),
      ),
      floatingActionButton: (c != null && c.value.isInitialized)
          ? FloatingActionButton(
              backgroundColor: SwiftSnapTheme.primaryPurple,
              onPressed: () => setState(() => c.value.isPlaying ? c.pause() : c.play()),
              child: Icon(c.value.isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white),
            )
          : null,
    );
  }
}

class _ProfileSheet extends StatelessWidget {
  final UserModel user;
  
  const _ProfileSheet({required this.user});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: BoxDecoration(
        color: SwiftSnapTheme.backgroundCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SwiftSnapTheme.primaryGradient,
            ),
            padding: const EdgeInsets.all(3),
            child: CircleAvatar(
              radius: 48,
              backgroundImage: NetworkImage(user.avatarUrl),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                user.displayName,
                style: const TextStyle(
                  color: SwiftSnapTheme.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (user.isVerified) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.verified_rounded,
                  color: SwiftSnapTheme.primaryPurple,
                  size: 24,
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '@${user.username}',
            style: const TextStyle(
              color: SwiftSnapTheme.textMuted,
              fontSize: 16,
            ),
          ),
          if (user.bio != null) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                user.bio!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: SwiftSnapTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: _FriendActionButton(user: user),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => _showProfileOptions(context),
                  child: _buildIconAction(Icons.more_horiz_rounded),
                ),
              ],
            ),
          ),
          const Spacer(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildProfileStat('Friends', '${user.friendCount}'),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white.withOpacity(0.1),
                  ),
                  _buildProfileStat('Streak', '${user.streakDays} 🔥'),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white.withOpacity(0.1),
                  ),
                  _buildProfileStat('Score', '${user.snapScore}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showProfileOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: SwiftSnapTheme.surfaceColor,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.flag_outlined, color: SwiftSnapTheme.textPrimary),
              title: const Text('Report user', style: TextStyle(color: SwiftSnapTheme.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                ReportDialog.show(context, userId: user.id, targetLabel: '@${user.username}');
              },
            ),
            ListTile(
              leading: const Icon(Icons.block_rounded, color: SwiftSnapTheme.busy),
              title: const Text('Block user', style: TextStyle(color: SwiftSnapTheme.busy)),
              onTap: () async {
                Navigator.pop(context);
                final res = await UserService().blockUser(user.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(res.isSuccess ? 'Blocked @${user.username}' : res.errorMessage)));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconAction(IconData icon) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: SwiftSnapTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: SwiftSnapTheme.textSecondary,
        size: 24,
      ),
    );
  }
  
  Widget _buildProfileStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: SwiftSnapTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: SwiftSnapTheme.textMuted,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}


/// Relationship-aware action button in the chat profile sheet. Shows "Friends"
/// (disabled) when already connected, otherwise "Add Friend" which sends a real
/// request and flips to "Requested". Truthful state — no hardcoded label.
class _FriendActionButton extends StatefulWidget {
  final UserModel user;
  const _FriendActionButton({required this.user});
  @override
  State<_FriendActionButton> createState() => _FriendActionButtonState();
}

class _FriendActionButtonState extends State<_FriendActionButton> {
  bool _requested = false;
  bool _sending = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isFriend = provider.friends.any((f) => f.id == widget.user.id);

    late final IconData icon;
    late final String label;
    late final bool isPrimary;
    VoidCallback? onTap;

    if (isFriend) {
      icon = Icons.check_rounded;
      label = 'Friends';
      isPrimary = false;
      onTap = null;
    } else if (_requested) {
      icon = Icons.hourglass_top_rounded;
      label = 'Requested';
      isPrimary = false;
      onTap = null;
    } else {
      icon = Icons.person_add_outlined;
      label = 'Add Friend';
      isPrimary = true;
      onTap = _sending
          ? null
          : () async {
              setState(() => _sending = true);
              final res = await FriendService().sendFriendRequest(widget.user.id);
              if (!mounted) return;
              setState(() {
                _sending = false;
                _requested = res.isSuccess;
              });
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(res.isSuccess
                      ? 'Friend request sent to @${widget.user.username}'
                      : res.errorMessage)));
            };
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: isPrimary ? SwiftSnapTheme.primaryGradient : null,
          color: isPrimary ? null : SwiftSnapTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _sending
                ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Icon(icon,
                    color: isPrimary ? Colors.white : SwiftSnapTheme.textSecondary, size: 20),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                  color: isPrimary ? Colors.white : SwiftSnapTheme.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                )),
          ],
        ),
      ),
    );
  }
}
