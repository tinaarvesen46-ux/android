import 'user_model.dart';

enum StoryType { image, video }
enum StoryAudience { everyone, friendsOnly, closeFriends, custom }

class StoryModel {
  final String id;
  final UserModel user;
  final String mediaUrl;
  final StoryType type;
  final DateTime createdAt;
  final DateTime expiresAt;
  final int viewerCount;
  final bool hasUnviewed;
  final bool isOwn;
  final StoryAudience audience;
  final String? caption;
  final List<StoryReaction> reactions;
  final List<String> viewerIds;
  
  StoryModel({
    required this.id,
    required this.user,
    required this.mediaUrl,
    this.type = StoryType.image,
    required this.createdAt,
    DateTime? expiresAt,
    this.viewerCount = 0,
    this.hasUnviewed = true,
    this.isOwn = false,
    this.audience = StoryAudience.everyone,
    this.caption,
    this.reactions = const [],
    this.viewerIds = const [],
  }) : expiresAt = expiresAt ?? createdAt.add(const Duration(hours: 24));
  
  bool get isExpired => DateTime.now().isAfter(expiresAt);
  
  String get timeRemaining {
    final remaining = expiresAt.difference(DateTime.now());
    if (remaining.isNegative) return 'Expired';
    if (remaining.inHours > 0) return '${remaining.inHours}h left';
    return '${remaining.inMinutes}m left';
  }
  
  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    return '${diff.inHours}h';
  }
  
  StoryModel copyWith({
    String? id,
    UserModel? user,
    String? mediaUrl,
    StoryType? type,
    DateTime? createdAt,
    DateTime? expiresAt,
    int? viewerCount,
    bool? hasUnviewed,
    bool? isOwn,
    StoryAudience? audience,
    String? caption,
    List<StoryReaction>? reactions,
    List<String>? viewerIds,
  }) {
    return StoryModel(
      id: id ?? this.id,
      user: user ?? this.user,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      viewerCount: viewerCount ?? this.viewerCount,
      hasUnviewed: hasUnviewed ?? this.hasUnviewed,
      isOwn: isOwn ?? this.isOwn,
      audience: audience ?? this.audience,
      caption: caption ?? this.caption,
      reactions: reactions ?? this.reactions,
      viewerIds: viewerIds ?? this.viewerIds,
    );
  }
}

class StoryReaction {
  final String emoji;
  final String userId;
  final DateTime timestamp;
  
  const StoryReaction({
    required this.emoji,
    required this.userId,
    required this.timestamp,
  });
}
