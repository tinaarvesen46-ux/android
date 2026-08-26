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
    return UserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      displayName: json['display_name'] as String,
      email: json['email'] as String?,
      avatarUrl: json['avatar_url'] as String? ?? '',
      coverUrl: json['cover_url'] as String?,
      bio: json['bio'] as String?,
      pronouns: json['pronouns'] as String?,
      location: json['location'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      isOnline: json['is_online'] as bool? ?? false,
      lastSeen: json['last_seen'] != null 
          ? DateTime.parse(json['last_seen'] as String)
          : null,
      accountStatus: _accountStatusFromString(json['account_status'] as String?),
      privacyLevel: _privacyLevelFromString(json['privacy_level'] as String?),
      friendCount: json['friend_count'] as int? ?? 0,
      streakDays: json['streak_days'] as int? ?? 0,
      snapScore: json['snap_score'] as int? ?? json['score'] as int? ?? 0,
      birthday: json['birthday'] as String? ?? json['date_of_birth'] as String?,
      phone: json['phone'] as String? ?? json['mobile'] as String? ?? json['phone_number'] as String?,
      isFavorite: json['is_favorite'] as bool? ?? false,
      isCloseFriend: json['is_close_friend'] as bool? ?? false,
      staffRole: _staffRoleFromString(json['staff_role'] as String?),
    );
  }
  
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
