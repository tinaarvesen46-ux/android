enum AccountStatus { normal, verified, creator }
enum PrivacyLevel { publicProfile, friendsOnly, privateProfile }
enum StaffRole { none, support, moderator, administrator }

class UserModel {
  final String id;
  final String username;
  final String displayName;
  final String? email;
  final String avatarUrl;
  final String? coverUrl;
  final String? bio;
  final String? pronouns;
  final String? location;
  final bool isVerified;
  final bool isOnline;
  final DateTime? lastSeen;
  final AccountStatus accountStatus;
  final PrivacyLevel privacyLevel;
  final int friendCount;
  final int streakDays;
  final int snapScore;
  final String? birthday;
  final String? phone;
  final bool isFavorite;
  final bool isCloseFriend;
  final StaffRole staffRole;
  
  const UserModel({
    required this.id,
    required this.username,
    required this.displayName,
    this.email,
    required this.avatarUrl,
    this.coverUrl,
    this.bio,
    this.pronouns,
    this.location,
    this.isVerified = false,
    this.isOnline = false,
    this.lastSeen,
    this.accountStatus = AccountStatus.normal,
    this.privacyLevel = PrivacyLevel.publicProfile,
    this.friendCount = 0,
    this.streakDays = 0,
    this.snapScore = 0,
    this.birthday,
    this.phone,
    this.isFavorite = false,
    this.isCloseFriend = false,
    this.staffRole = StaffRole.none,
  });
  
  String get statusBadge {
    switch (accountStatus) {
      case AccountStatus.creator:
        return '✨';
      case AccountStatus.verified:
        return '✓';
      case AccountStatus.normal:
        return '';
    }
  }
  
  String get lastSeenFormatted {
    if (isOnline) return 'Online';
    if (lastSeen == null) return 'Offline';
    
    final now = DateTime.now();
    final diff = now.difference(lastSeen!);
    
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return 'Long time ago';
  }
  
  UserModel copyWith({
    String? id,
    String? username,
    String? displayName,
    String? email,
    String? avatarUrl,
    String? coverUrl,
    String? bio,
    String? pronouns,
    String? location,
    bool? isVerified,
    bool? isOnline,
    DateTime? lastSeen,
    AccountStatus? accountStatus,
    PrivacyLevel? privacyLevel,
    int? friendCount,
    int? streakDays,
    int? snapScore,
    String? birthday,
    String? phone,
    bool? isFavorite,
    bool? isCloseFriend,
    StaffRole? staffRole,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      bio: bio ?? this.bio,
      pronouns: pronouns ?? this.pronouns,
      location: location ?? this.location,
      isVerified: isVerified ?? this.isVerified,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      accountStatus: accountStatus ?? this.accountStatus,
      privacyLevel: privacyLevel ?? this.privacyLevel,
      friendCount: friendCount ?? this.friendCount,
      streakDays: streakDays ?? this.streakDays,
      snapScore: snapScore ?? this.snapScore,
      birthday: birthday ?? this.birthday,
      phone: phone ?? this.phone,
      isFavorite: isFavorite ?? this.isFavorite,
      isCloseFriend: isCloseFriend ?? this.isCloseFriend,
      staffRole: staffRole ?? this.staffRole,
    );
  }
  
  // JSON serialization
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // The backend nests profile fields under `profile` (users/me, friends,
    // admin/users) but sends a flat mini-object elsewhere (friend-requests,
    // chat previews). Read profile first, fall back to top-level.
    final p = (json['profile'] as Map?) ?? const {};
    String? pick(String key) =>
        (p[key] ?? json[key])?.toString();

    return UserModel(
      id: (json['id'] ?? json['uuid'] ?? '').toString(),
      username: (json['username'] ?? '').toString(),
      displayName: (p['display_name'] ??
              json['display_name'] ??
              json['username'] ??
              '')
          .toString(),
      email: json['email']?.toString(),
      avatarUrl: pick('avatar_url') ?? '',
      coverUrl: pick('cover_url'),
      bio: pick('bio'),
      pronouns: pick('pronouns'),
      location: pick('location'),
      isVerified: json['email_verified_at'] != null ||
          (json['is_verified'] == true || json['is_verified'] == 1),
      isOnline: _toBool(json['is_online']),
      lastSeen: _toDate(json['last_seen_at'] ?? json['last_seen']),
      accountStatus: _accountStatusFromString(json['account_status'] as String?),
      privacyLevel: _privacyLevelFromString(json['privacy_level'] as String?),
      friendCount: _toInt(p['friend_count'] ?? json['friend_count']),
      streakDays: _toInt(json['streak_days']),
      snapScore: _toInt(p['snap_score'] ?? json['snap_score'] ?? json['score']),
      birthday: (p['birthday'] ?? json['birthday'] ?? json['date_of_birth'])
          ?.toString(),
      phone: (json['phone'] ?? json['mobile'] ?? json['phone_number'])
          ?.toString(),
      isFavorite: _toBool(json['is_favorite']),
      isCloseFriend: _toBool(json['is_close_friend']),
      staffRole: _staffRoleFromString(json['staff_role'] as String?),
    );
  }

  static int _toInt(dynamic v) =>
      v is int ? v : (v is num ? v.toInt() : int.tryParse('${v ?? ''}') ?? 0);

  static bool _toBool(dynamic v) =>
      v == true || v == 1 || v == '1' || v == 'true';

  static DateTime? _toDate(dynamic v) =>
      v is String && v.isNotEmpty ? DateTime.tryParse(v)?.toLocal() : null;
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'display_name': displayName,
      'email': email,
      'avatar_url': avatarUrl,
      'cover_url': coverUrl,
      'bio': bio,
      'pronouns': pronouns,
      'location': location,
      'is_verified': isVerified,
      'is_online': isOnline,
      'last_seen': lastSeen?.toIso8601String(),
      'account_status': _accountStatusToString(accountStatus),
      'privacy_level': _privacyLevelToString(privacyLevel),
      'friend_count': friendCount,
      'streak_days': streakDays,
      'snap_score': snapScore,
      'birthday': birthday,
      'phone': phone,
      'is_favorite': isFavorite,
      'is_close_friend': isCloseFriend,
      'staff_role': _staffRoleToString(staffRole),
    };
  }
  
  static AccountStatus _accountStatusFromString(String? status) {
    switch (status?.toLowerCase()) {
      case 'creator':
        return AccountStatus.creator;
      case 'verified':
        return AccountStatus.verified;
      default:
        return AccountStatus.normal;
    }
  }
  
  static String _accountStatusToString(AccountStatus status) {
    switch (status) {
      case AccountStatus.creator:
        return 'creator';
      case AccountStatus.verified:
        return 'verified';
      case AccountStatus.normal:
        return 'normal';
    }
  }
  
  static PrivacyLevel _privacyLevelFromString(String? level) {
    switch (level?.toLowerCase()) {
      case 'friends_only':
        return PrivacyLevel.friendsOnly;
      case 'private':
        return PrivacyLevel.privateProfile;
      default:
        return PrivacyLevel.publicProfile;
    }
  }
  
  static String _privacyLevelToString(PrivacyLevel level) {
    switch (level) {
      case PrivacyLevel.friendsOnly:
        return 'friends_only';
      case PrivacyLevel.privateProfile:
        return 'private';
      case PrivacyLevel.publicProfile:
        return 'public';
    }
  }
  
  static StaffRole _staffRoleFromString(String? role) {
    switch (role?.toLowerCase()) {
      case 'administrator':
        return StaffRole.administrator;
      case 'moderator':
        return StaffRole.moderator;
      case 'support':
        return StaffRole.support;
      default:
        return StaffRole.none;
    }
  }
  
  static String _staffRoleToString(StaffRole role) {
    switch (role) {
      case StaffRole.administrator:
        return 'administrator';
      case StaffRole.moderator:
        return 'moderator';
      case StaffRole.support:
        return 'support';
      case StaffRole.none:
        return 'none';
    }
  }
}
