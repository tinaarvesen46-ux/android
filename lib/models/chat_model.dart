import 'user_model.dart';

enum MessageType { text, image, video, voice, gif }
enum MessageStatus { sending, sent, delivered, read, failed }
enum MediaExpiration { viewOnce, timedView, keepForever }

class MessageModel {
  final String id;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final MessageType type;
  final MessageStatus status;
  final bool isRead;
  final String? mediaUrl;
  final MediaExpiration expiration;
  final int? viewDuration;
  final String? replyToId;
  final List<MessageReaction> reactions;
  final bool isEdited;
  final DateTime? editedAt;
  
  const MessageModel({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
    this.type = MessageType.text,
    this.status = MessageStatus.sent,
    this.isRead = false,
    this.mediaUrl,
    this.expiration = MediaExpiration.keepForever,
    this.viewDuration,
    this.replyToId,
    this.reactions = const [],
    this.isEdited = false,
    this.editedAt,
  });
  
  String get timeFormatted {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    
    if (diff.inMinutes < 1) return 'Now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${timestamp.day}/${timestamp.month}';
  }
  
  MessageModel copyWith({
    String? id,
    String? senderId,
    String? content,
    DateTime? timestamp,
    MessageType? type,
    MessageStatus? status,
    bool? isRead,
    String? mediaUrl,
    MediaExpiration? expiration,
    int? viewDuration,
    String? replyToId,
    List<MessageReaction>? reactions,
    bool? isEdited,
    DateTime? editedAt,
  }) {
    return MessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      status: status ?? this.status,
      isRead: isRead ?? this.isRead,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      expiration: expiration ?? this.expiration,
      viewDuration: viewDuration ?? this.viewDuration,
      replyToId: replyToId ?? this.replyToId,
      reactions: reactions ?? this.reactions,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
    );
  }
}

class MessageReaction {
  final String emoji;
  final String userId;
  final DateTime timestamp;
  
  const MessageReaction({
    required this.emoji,
    required this.userId,
    required this.timestamp,
  });
}

class ChatModel {
  final String id;
  final UserModel participant;
  final MessageModel lastMessage;
  final bool isPinned;
  final bool isMuted;
  final int unreadCount;
  final bool disappearingEnabled;
  final int? disappearingDuration;
  final bool screenshotDisabled;
  
  const ChatModel({
    required this.id,
    required this.participant,
    required this.lastMessage,
    this.isPinned = false,
    this.isMuted = false,
    this.unreadCount = 0,
    this.disappearingEnabled = false,
    this.disappearingDuration,
    this.screenshotDisabled = false,
  });
  
  ChatModel copyWith({
    String? id,
    UserModel? participant,
    MessageModel? lastMessage,
    bool? isPinned,
    bool? isMuted,
    int? unreadCount,
    bool? disappearingEnabled,
    int? disappearingDuration,
    bool? screenshotDisabled,
  }) {
    return ChatModel(
      id: id ?? this.id,
      participant: participant ?? this.participant,
      lastMessage: lastMessage ?? this.lastMessage,
      isPinned: isPinned ?? this.isPinned,
      isMuted: isMuted ?? this.isMuted,
      unreadCount: unreadCount ?? this.unreadCount,
      disappearingEnabled: disappearingEnabled ?? this.disappearingEnabled,
      disappearingDuration: disappearingDuration ?? this.disappearingDuration,
      screenshotDisabled: screenshotDisabled ?? this.screenshotDisabled,
    );
  }
}
