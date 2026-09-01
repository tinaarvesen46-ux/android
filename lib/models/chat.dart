import 'user.dart';

enum MessageType { text, photo, video, voice, snap }

class ChatMessage {
  final String id;
  final String senderId;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final bool isRead;
  final bool isSaved;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.content,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.isSaved = false,
  });
}

class Conversation {
  final String id;
  /// Backend conversation type. `ai` is reserved for the built-in My AI
  /// entry and is never treated as a human participant.
  final String type;
  final User participant;
  final ChatMessage? lastMessage;
  final int unreadCount;
  final bool isPinned;
  final bool isMuted;
  final bool isTyping;
  final bool isGroup;
  final String? groupName;
  final List<User>? members;

  const Conversation({
    required this.id,
    this.type = 'direct',
    required this.participant,
    this.lastMessage,
    this.unreadCount = 0,
    this.isPinned = false,
    this.isMuted = false,
    this.isTyping = false,
    this.isGroup = false,
    this.groupName,
    this.members,
  });

  bool get isAi => type == 'ai';
}
