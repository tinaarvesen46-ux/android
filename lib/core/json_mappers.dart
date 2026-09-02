import '../models/chat.dart';
import '../models/discover_item.dart';
import '../models/map_friend.dart';
import '../models/media.dart';
import '../models/social.dart';
import '../models/spotlight_post.dart';
import '../models/story.dart';
import '../models/story_comment.dart';
import '../models/user.dart';

/// Defensive JSON access helpers.
///
/// The backend may return a bare array, a Laravel resource envelope
/// (`{ data: [...] }`) or a paginator (`{ data: [...], meta: {...} }`).
/// Mapping tolerates all three and never throws on a missing field.

Map<String, dynamic> asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return value.cast<String, dynamic>();
  return <String, dynamic>{};
}

List<Map<String, dynamic>> asList(dynamic value) {
  dynamic source = value;
  if (source is Map) {
    source = source['data'] ?? source['items'] ?? source['results'];
  }
  if (source is List) return source.map(asMap).toList();
  return const <Map<String, dynamic>>[];
}

String asString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  if (value is String) return value;
  return '$value';
}

String? asNullableString(dynamic value) {
  if (value == null) return null;
  final text = asString(value);
  return text.isEmpty ? null : text;
}

int asInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

double asDouble(dynamic value, {double fallback = 0}) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? fallback;
  return fallback;
}

bool asBool(dynamic value, {bool fallback = false}) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final lower = value.toLowerCase();
    if (lower == 'true' || lower == '1') return true;
    if (lower == 'false' || lower == '0') return false;
  }
  return fallback;
}

DateTime asDate(dynamic value) => asNullableDate(value) ?? DateTime.now();

DateTime? asNullableDate(dynamic value) {
  if (value is DateTime) return value;
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(
      value > 99999999999 ? value : value * 1000,
    );
  }
  if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
  return null;
}

// ─────────────────────────── users & social ───────────────────────────

User userFromJson(Map<String, dynamic> json) => User(
      id: asString(json['id']),
      username: asString(json['username']),
      displayName: asString(
        json['display_name'] ?? json['name'] ?? json['username'],
      ),
  avatarUrl: asNullableString(json['avatar_url'] ?? json['avatar']),
  avatarRenderUrl: asNullableString(json['avatar_render_url'] ?? json['render_url']),
      bio: asNullableString(json['bio']),
      isOnline: asBool(json['is_online']),
      lastSeen: asNullableDate(json['last_seen_at'] ?? json['last_seen']),
      friendCount: asInt(json['friend_count'] ?? json['friends_count']),
      isVerified: asBool(json['is_verified']),
      role: asString(json['role'], fallback: 'user'),
      roleLabel: asString(json['role_label']),
      twoFactorEnabled: asBool(json['two_factor_enabled']),
    );

UserProfile userProfileFromJson(Map<String, dynamic> json) {
  final userJson = Map<String, dynamic>.from(
    asMap(json['user'] ?? json['profile'] ?? json),
  );
  // Profile endpoints return the render URL beside the nested user object.
  // Fold it into the shared User model so profile, chat, story and search
  // consumers all receive the same current avatar identity.
  final renderUrl = asNullableString(
    json['avatar_render_url'] ?? json['render_url'],
  );
  if (renderUrl != null &&
      asNullableString(userJson['avatar_render_url'] ?? userJson['render_url']) ==
          null) {
    userJson['avatar_render_url'] = renderUrl;
  }
  return UserProfile(
    user: userFromJson(userJson),
    relationship: relationshipFromString(
      asNullableString(json['relationship'] ?? json['friendship_status']),
    ),
    friendCount: asInt(json['friend_count'] ?? json['friends_count']),
    storyCount: asInt(json['story_count'] ?? json['stories_count']),
    reelCount: asInt(json['reel_count'] ?? json['spotlight_count']),
    isPublicProfile: asBool(json['is_public'], fallback: true),
    canViewContent: asBool(
      json['can_view_content'],
      fallback: asBool(json['is_public'], fallback: false),
    ),
    canMessage: asBool(json['can_message']),
    canSendFriendRequest: asBool(json['can_send_friend_request']),
    friendRequestId: asNullableString(
      json['friend_request_id'] ?? json['request_id'],
    ),
    isFollowing: asBool(json['is_following']),
    followerCount: asInt(json['follower_count'] ?? json['followers_count']),
  );
}

FriendRequest friendRequestFromJson(Map<String, dynamic> json) {
  final direction = asString(json['direction'] ?? json['type']) == 'outgoing'
      ? FriendRequestDirection.outgoing
      : FriendRequestDirection.incoming;
  return FriendRequest(
    id: asString(json['id']),
    user: userFromJson(asMap(json['user'] ?? json['from'] ?? json['to'])),
    direction: direction,
    createdAt: asDate(json['created_at']),
  );
}

AppNotification notificationFromJson(Map<String, dynamic> json) {
  final actor = json['actor'] ?? json['from_user'];
  return AppNotification(
    id: asString(json['id']),
    kind: notificationKindFromString(asNullableString(json['type'])),
    title: asString(json['title']),
    body: asString(json['body'] ?? json['message']),
    actor: actor == null ? null : userFromJson(asMap(actor)),
    targetId: asNullableString(json['target_id'] ?? json['conversation_id']),
    isRead: asBool(json['is_read'] ?? json['read']),
    createdAt: asDate(json['created_at']),
  );
}

Achievement achievementFromJson(Map<String, dynamic> json) => Achievement(
      id: asString(json['id']),
      name: asString(json['name'] ?? json['title']),
      description: asString(json['description']),
      category: asString(json['category']),
      isUnlocked: asBool(json['is_unlocked'] ?? json['unlocked']),
      progress: asInt(json['progress']),
      target: asInt(json['target'], fallback: 1),
      unlockedAt: asNullableDate(json['unlocked_at']),
    );

// ─────────────────────────── chat ───────────────────────────

MessageType _messageTypeFromString(String? value) {
  switch (value) {
    case 'photo':
    case 'image':
      return MessageType.photo;
    case 'video':
      return MessageType.video;
    case 'voice':
    case 'audio':
      return MessageType.voice;
    case 'snap':
      return MessageType.snap;
    default:
      return MessageType.text;
  }
}

ChatMessage messageFromJson(Map<String, dynamic> json) => ChatMessage(
      id: asString(json['id']),
      senderId: asString(json['sender_id'] ?? json['user_id']),
      content: asString(json['content'] ?? json['body'] ?? json['media_url']),
      type: _messageTypeFromString(asNullableString(json['type'])),
      timestamp: asDate(json['created_at'] ?? json['sent_at']),
      isRead: asBool(json['is_read'] ?? json['read']),
      isSaved: asBool(json['is_saved'] ?? json['saved']),
    );

Conversation conversationFromJson(Map<String, dynamic> json) {
  final members =
      asList(json['members'] ?? json['participants']).map(userFromJson).toList();
  final participantJson = json['participant'] ?? json['user'] ?? json['other'];
  return Conversation(
    id: asString(json['id']),
    type: asString(json['type'], fallback: asBool(json['is_ai']) ? 'ai' : 'direct'),
    participant: participantJson != null
        ? userFromJson(asMap(participantJson))
        : (members.isNotEmpty
            ? members.first
            : const User(id: '', username: '', displayName: '')),
    lastMessage: json['last_message'] == null
        ? null
        : messageFromJson(asMap(json['last_message'])),
    unreadCount: asInt(json['unread_count']),
    isPinned: asBool(json['is_pinned']),
    isMuted: asBool(json['is_muted']),
    isTyping: asBool(json['is_typing']),
    isGroup: asBool(json['is_group']),
    groupName: asNullableString(json['group_name'] ?? json['name']),
    members: members.isEmpty ? null : members,
  );
}

// ─────────────────────────── stories & feeds ───────────────────────────

StoryItem storyItemFromJson(Map<String, dynamic> json) => StoryItem(
      id: asString(json['id']),
      mediaUrl: asString(json['media_url'] ?? json['url']),
      isVideo: asBool(json['is_video']),
      duration: Duration(seconds: asInt(json['duration'], fallback: 5)),
      createdAt: asDate(json['created_at']),
      viewCount: asInt(json['view_count'] ?? json['views_count']),
      replyCount: asInt(json['reply_count'] ?? json['replies_count']),
    );

StoryComment storyCommentFromJson(Map<String, dynamic> json) => StoryComment(
      id: asString(json['id']),
      author: userFromJson(asMap(json['user'] ?? json['author'] ?? json['from'] ?? json['actor'] ?? {})),
      content: asString(json['content'] ?? json['body'] ?? json['message']),
      createdAt: asDate(json['created_at'] ?? json['createdAt'] ?? json['sent_at']),
    );

Story storyFromJson(Map<String, dynamic> json) => Story(
      id: asString(json['id']),
      author: userFromJson(asMap(json['author'] ?? json['user'])),
      items:
          asList(json['items'] ?? json['stories']).map(storyItemFromJson).toList(),
      isSeen: asBool(json['is_seen'] ?? json['seen']),
      createdAt: asDate(json['created_at']),
    );

SpotlightPost spotlightPostFromJson(Map<String, dynamic> json) => SpotlightPost(
      id: asString(json['id']),
      creator: userFromJson(asMap(json['creator'] ?? json['user'])),
      mediaUrl: asString(json['media_url'] ?? json['url']),
      thumbnailUrl: asNullableString(json['thumbnail_url']),
      isVideo: asBool(json['is_video'], fallback: true),
      caption: asNullableString(json['caption']),
      hashtags: json['hashtags'] is List
          ? (json['hashtags'] as List).map((e) => asString(e)).toList()
          : const <String>[],
      likeCount: asInt(json['like_count'] ?? json['likes_count']),
      commentCount: asInt(json['comment_count'] ?? json['comments_count']),
      shareCount: asInt(json['share_count'] ?? json['shares_count']),
      viewCount: asInt(json['view_count'] ?? json['views_count']),
      isLiked: asBool(json['is_liked']),
      isSaved: asBool(json['is_saved']),
      createdAt: asDate(json['created_at']),
    );

DiscoverCategory discoverCategoryFromJson(Map<String, dynamic> json) =>
    DiscoverCategory(
      id: asString(json['id'] ?? json['slug']),
      name: asString(json['name'] ?? json['title']),
      icon: asString(json['icon']),
    );

DiscoverItem discoverItemFromJson(Map<String, dynamic> json) => DiscoverItem(
      id: asString(json['id']),
      title: asString(json['title']),
      subtitle: asNullableString(json['subtitle'] ?? json['excerpt']),
      imageUrl: asString(json['image_url'] ?? json['cover_url']),
      category: asString(json['category']),
      source: asString(json['source'] ?? json['publisher']),
      viewCount: asInt(json['view_count'] ?? json['views_count']),
      publishedAt: asDate(json['published_at'] ?? json['created_at']),
      isSponsored: asBool(json['is_sponsored']),
    );

// ─────────────────────────── media & map ───────────────────────────

MemoryKind _memoryKindFromString(String? value) {
  switch (value) {
    case 'story':
      return MemoryKind.story;
    case 'camera_roll':
    case 'camera-roll':
      return MemoryKind.cameraRoll;
    default:
      return MemoryKind.snap;
  }
}

MemoryItem memoryFromJson(Map<String, dynamic> json) => MemoryItem(
      id: asString(json['id']),
      mediaUrl: asString(json['media_url'] ?? json['url']),
      thumbnailUrl: asNullableString(json['thumbnail_url']),
      isVideo: asBool(json['is_video']),
      kind: _memoryKindFromString(asNullableString(json['kind'])),
      isFavorite: asBool(json['is_favorite'] ?? json['favorite']),
      createdAt: asDate(json['created_at']),
    );

MapFriend mapFriendFromJson(Map<String, dynamic> json) => MapFriend(
      user: userFromJson(asMap(json['user'] ?? json)),
      latitude: asDouble(json['latitude'] ?? json['lat']),
      longitude: asDouble(json['longitude'] ?? json['lng'] ?? json['lon']),
      updatedAt: asDate(json['updated_at'] ?? json['shared_at']),
    );
