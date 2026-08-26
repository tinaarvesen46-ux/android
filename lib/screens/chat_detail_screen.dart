import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../theme/theme.dart';
import '../models/chat_model.dart';
import '../models/user_model.dart';
import '../providers/app_provider.dart';

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
  bool _showEmoji = false;
  late AnimationController _sendButtonController;
  
  @override
  void initState() {
    super.initState();
    _sendButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    // Load real message history + mark conversation read.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AppProvider>();
      provider.loadChatMessages(widget.chat.id);
      provider.markChatAsRead(widget.chat.id);
    });
  }
  
  @override
  void dispose() {
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
                  onTap: () => _showProfileSheet(),
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
                                widget.chat.participant.displayName,
                                style: const TextStyle(
                                  color: SwiftSnapTheme.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (widget.chat.participant.isVerified) ...[
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
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: widget.chat.participant.isOnline
                                      ? SwiftSnapTheme.online
                                      : SwiftSnapTheme.offline,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                widget.chat.participant.isOnline
                                    ? 'Online'
                                    : widget.chat.participant.lastSeenFormatted,
                                style: TextStyle(
                                  color: widget.chat.participant.isOnline
                                      ? SwiftSnapTheme.online
                                      : SwiftSnapTheme.textMuted,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                _buildHeaderAction(Icons.videocam_rounded),
                _buildHeaderAction(Icons.call_rounded),
                _buildHeaderAction(Icons.more_vert_rounded),
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
  
  Widget _buildHeaderAction(IconData icon) {
    return GestureDetector(
      onTap: () => HapticFeedback.lightImpact(),
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
            onTap: () => HapticFeedback.lightImpact(),
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
                          _sendButtonController.forward();
                        } else {
                          _sendButtonController.reverse();
                        }
                      },
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _showEmoji = !_showEmoji),
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
  
  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.showAvatar,
    required this.participant,
  });
  
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
                  child: _buildActionButton(
                    icon: Icons.person_add_outlined,
                    label: 'Add Friend',
                    isPrimary: true,
                  ),
                ),
                const SizedBox(width: 12),
                _buildIconAction(Icons.more_horiz_rounded),
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
                  _buildProfileStat('Friends', '2.4K'),
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
                  _buildProfileStat('Score', '15.2K'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    bool isPrimary = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        gradient: isPrimary ? SwiftSnapTheme.primaryGradient : null,
        color: isPrimary ? null : SwiftSnapTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isPrimary ? Colors.white : SwiftSnapTheme.textSecondary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isPrimary ? Colors.white : SwiftSnapTheme.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
