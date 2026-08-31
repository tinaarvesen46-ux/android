import 'user.dart';

enum RelationshipState {
  none,
  requestSent,
  requestReceived,
  friends,
  blocked,
  blockedBy,
}

RelationshipState relationshipFromString(String? value) {
  switch (value) {
    case 'request_sent':
    case 'pending_outgoing':
      return RelationshipState.requestSent;
    case 'request_received':
    case 'pending_incoming':
      return RelationshipState.requestReceived;
    case 'friends':
    case 'accepted':
      return RelationshipState.friends;
    case 'blocked':
      return RelationshipState.blocked;
    case 'blocked_by':
      return RelationshipState.blockedBy;
    default:
      return RelationshipState.none;
  }
}

class UserProfile {
  final User user;
  final RelationshipState relationship;
  final int friendCount;
  final int storyCount;
  final int reelCount;
  final bool isPublicProfile;
  final bool isFollowing;
  final int followerCount;

  const UserProfile({
    required this.user,
    this.relationship = RelationshipState.none,
    this.friendCount = 0,
    this.storyCount = 0,
    this.reelCount = 0,
    this.isPublicProfile = false,
    this.isFollowing = false,
    this.followerCount = 0,
  });
}

enum FriendRequestDirection { incoming, outgoing }

class FriendRequest {
  final String id;
  final User user;
  final FriendRequestDirection direction;
  final DateTime createdAt;

  const FriendRequest({
    required this.id,
    required this.user,
    required this.direction,
    required this.createdAt,
  });
}

enum NotificationKind {
  message,
  friendRequest,
  friendAccepted,
  story,
  reel,
  comment,
  like,
  mention,
  creator,
  system,
}

NotificationKind notificationKindFromString(String? value) {
  switch (value) {
    case 'message':
      return NotificationKind.message;
    case 'friend_request':
      return NotificationKind.friendRequest;
    case 'friend_accepted':
      return NotificationKind.friendAccepted;
    case 'story':
      return NotificationKind.story;
    case 'reel':
    case 'spotlight':
      return NotificationKind.reel;
    case 'comment':
      return NotificationKind.comment;
    case 'like':
      return NotificationKind.like;
    case 'mention':
      return NotificationKind.mention;
    case 'creator':
      return NotificationKind.creator;
    default:
      return NotificationKind.system;
  }
}

class AppNotification {
  final String id;
  final NotificationKind kind;
  final String title;
  final String body;
  final User? actor;
  final String? targetId;
  final bool isRead;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    this.actor,
    this.targetId,
    this.isRead = false,
    required this.createdAt,
  });
}

class Achievement {
  final String id;
  final String name;
  final String description;
  final String category;
  final bool isUnlocked;
  final int progress;
  final int target;
  final DateTime? unlockedAt;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    this.category = '',
    this.isUnlocked = false,
    this.progress = 0,
    this.target = 1,
    this.unlockedAt,
  });

  double get completion {
    if (isUnlocked) return 1;
    if (target <= 0) return 0;
    return (progress / target).clamp(0.0, 1.0);
  }
}
