class User {
  final String id;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final String? avatarRenderUrl;
  final String? bio;
  final bool isOnline;
  final DateTime? lastSeen;
  final int friendCount;
  final bool isVerified;

  /// Backend-owned badge — one of: user, verified, creator, support,
  /// moderator, administrator. Never client-assigned. See
  /// `User::getRoleAttribute()` on the Laravel side.
  final String role;
  final String roleLabel;

  /// Real server-owned 2FA flag (`users.two_factor_enabled`). Used only to
  /// pick the initial state of the Two-Factor screen — every actual toggle
  /// is verified against the backend.
  final bool twoFactorEnabled;

  const User({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    this.avatarRenderUrl,
    this.bio,
    this.isOnline = false,
    this.lastSeen,
    this.friendCount = 0,
    this.isVerified = false,
    this.role = 'user',
    this.roleLabel = '',
    this.twoFactorEnabled = false,
  });

  User copyWith({
    String? username,
    String? displayName,
    String? avatarUrl,
    String? avatarRenderUrl,
    String? bio,
    bool? isOnline,
    DateTime? lastSeen,
    int? friendCount,
    bool? isVerified,
    String? role,
    String? roleLabel,
    bool? twoFactorEnabled,
  }) =>
      User(
        id: id,
        username: username ?? this.username,
        displayName: displayName ?? this.displayName,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        avatarRenderUrl: avatarRenderUrl ?? this.avatarRenderUrl,
        bio: bio ?? this.bio,
        isOnline: isOnline ?? this.isOnline,
        lastSeen: lastSeen ?? this.lastSeen,
        friendCount: friendCount ?? this.friendCount,
        isVerified: isVerified ?? this.isVerified,
        role: role ?? this.role,
        roleLabel: roleLabel ?? this.roleLabel,
        twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      );
}
