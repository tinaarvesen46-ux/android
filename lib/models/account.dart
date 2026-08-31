import '../core/json_mappers.dart';
import 'user.dart';

/// Real account-status fields — never fabricated, sourced from
/// `GET /account/status` (self-only; hidden from any other user's payload).
class AccountStatus {
  final String status;
  final int warningCount;
  final String? suspensionReason;
  final DateTime? suspensionEndsAt;
  final String? banReason;
  final DateTime? bannedAt;

  const AccountStatus({
    required this.status,
    required this.warningCount,
    this.suspensionReason,
    this.suspensionEndsAt,
    this.banReason,
    this.bannedAt,
  });

  bool get isGoodStanding => status == 'normal' || status == 'creator';

  factory AccountStatus.fromJson(Map<String, dynamic> json) => AccountStatus(
        status: asString(json['status'], fallback: 'normal'),
        warningCount: asInt(json['warning_count']),
        suspensionReason: asNullableString(json['suspension_reason']),
        suspensionEndsAt: asNullableDate(json['suspension_ends_at']),
        banReason: asNullableString(json['ban_reason']),
        bannedAt: asNullableDate(json['banned_at']),
      );
}

class TwoFactorSetup {
  final String secret;
  final String otpauthUri;

  const TwoFactorSetup({required this.secret, required this.otpauthUri});

  factory TwoFactorSetup.fromJson(Map<String, dynamic> json) => TwoFactorSetup(
        secret: asString(json['secret']),
        otpauthUri: asString(json['otpauth_uri']),
      );
}

class SecuritySession {
  final String id;
  final String name;
  final DateTime? lastUsedAt;
  final DateTime createdAt;
  final bool isCurrent;

  const SecuritySession({
    required this.id,
    required this.name,
    required this.createdAt,
    this.lastUsedAt,
    this.isCurrent = false,
  });

  factory SecuritySession.fromJson(Map<String, dynamic> json) => SecuritySession(
        id: asString(json['id']),
        name: asString(json['name'], fallback: 'Device'),
        createdAt: asDate(json['created_at']),
        lastUsedAt: asNullableDate(json['last_used_at']),
        isCurrent: asBool(json['current']),
      );
}

/// Mirrors Laravel `UserSettings` — privacy + appearance in one blob.
class PrivacySettings {
  final String theme;
  final String language;
  final bool showOnlineStatus;
  final bool showReadReceipts;
  final bool showTypingIndicator;
  final bool loginAlerts;
  final bool screenshotAlerts;
  final bool dataSharingAnalytics;
  final bool dataSharingPersonalization;
  final String allowMessagesFrom;
  final String allowFriendRequestsFrom;
  final String storyVisibility;
  final String swiftmapAppearance;

  const PrivacySettings({
    required this.theme,
    required this.language,
    required this.showOnlineStatus,
    required this.showReadReceipts,
    required this.showTypingIndicator,
    required this.loginAlerts,
    required this.screenshotAlerts,
    required this.dataSharingAnalytics,
    required this.dataSharingPersonalization,
    required this.allowMessagesFrom,
    required this.allowFriendRequestsFrom,
    required this.storyVisibility,
    required this.swiftmapAppearance,
  });

  factory PrivacySettings.fromJson(Map<String, dynamic> json) => PrivacySettings(
        theme: asString(json['theme'], fallback: 'dark'),
        language: asString(json['language'], fallback: 'en'),
        showOnlineStatus: asBool(json['show_online_status'], fallback: true),
        showReadReceipts: asBool(json['show_read_receipts'], fallback: true),
        showTypingIndicator: asBool(json['show_typing_indicator'], fallback: true),
        loginAlerts: asBool(json['login_alerts'], fallback: true),
        screenshotAlerts: asBool(json['screenshot_alerts'], fallback: true),
        dataSharingAnalytics: asBool(json['data_sharing_analytics'], fallback: true),
        dataSharingPersonalization: asBool(json['data_sharing_personalization'], fallback: true),
        allowMessagesFrom: asString(json['allow_messages_from'], fallback: 'friends'),
        allowFriendRequestsFrom: asString(json['allow_friend_requests_from'], fallback: 'everyone'),
        storyVisibility: asString(json['story_visibility'], fallback: 'friends'),
        swiftmapAppearance: asString(json['swiftmap_appearance'], fallback: 'auto'),
      );

  PrivacySettings copyWith({
    String? theme,
    String? language,
    bool? showOnlineStatus,
    bool? showReadReceipts,
    bool? showTypingIndicator,
    bool? loginAlerts,
    bool? screenshotAlerts,
    bool? dataSharingAnalytics,
    bool? dataSharingPersonalization,
    String? allowMessagesFrom,
    String? allowFriendRequestsFrom,
    String? storyVisibility,
    String? swiftmapAppearance,
  }) => PrivacySettings(
        theme: theme ?? this.theme,
        language: language ?? this.language,
        showOnlineStatus: showOnlineStatus ?? this.showOnlineStatus,
        showReadReceipts: showReadReceipts ?? this.showReadReceipts,
        showTypingIndicator: showTypingIndicator ?? this.showTypingIndicator,
        loginAlerts: loginAlerts ?? this.loginAlerts,
        screenshotAlerts: screenshotAlerts ?? this.screenshotAlerts,
        dataSharingAnalytics: dataSharingAnalytics ?? this.dataSharingAnalytics,
        dataSharingPersonalization: dataSharingPersonalization ?? this.dataSharingPersonalization,
        allowMessagesFrom: allowMessagesFrom ?? this.allowMessagesFrom,
        allowFriendRequestsFrom: allowFriendRequestsFrom ?? this.allowFriendRequestsFrom,
        storyVisibility: storyVisibility ?? this.storyVisibility,
        swiftmapAppearance: swiftmapAppearance ?? this.swiftmapAppearance,
      );
}

/// Mirrors Laravel `NotificationPreference`.
class NotificationSettings {
  final bool newMessage;
  final bool friendRequest;
  final bool friendAccepted;
  final bool storyView;
  final bool storyReaction;
  final bool streakReminder;
  final bool streakAchievement;
  final bool mention;
  final bool groupInvite;
  final bool marketingEmails;
  final bool securityAlerts;
  final bool pushEnabled;
  final bool emailEnabled;
  final bool smsEnabled;

  const NotificationSettings({
    required this.newMessage,
    required this.friendRequest,
    required this.friendAccepted,
    required this.storyView,
    required this.storyReaction,
    required this.streakReminder,
    required this.streakAchievement,
    required this.mention,
    required this.groupInvite,
    required this.marketingEmails,
    required this.securityAlerts,
    required this.pushEnabled,
    required this.emailEnabled,
    required this.smsEnabled,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) => NotificationSettings(
        newMessage: asBool(json['new_message'], fallback: true),
        friendRequest: asBool(json['friend_request'], fallback: true),
        friendAccepted: asBool(json['friend_accepted'], fallback: true),
        storyView: asBool(json['story_view'], fallback: true),
        storyReaction: asBool(json['story_reaction'], fallback: true),
        streakReminder: asBool(json['streak_reminder'], fallback: true),
        streakAchievement: asBool(json['streak_achievement'], fallback: true),
        mention: asBool(json['mention'], fallback: true),
        groupInvite: asBool(json['group_invite'], fallback: true),
        marketingEmails: asBool(json['marketing_emails']),
        securityAlerts: asBool(json['security_alerts'], fallback: true),
        pushEnabled: asBool(json['push_enabled'], fallback: true),
        emailEnabled: asBool(json['email_enabled'], fallback: true),
        smsEnabled: asBool(json['sms_enabled']),
      );
}

class MyReport {
  final String id;
  final String reason;
  final String status;
  final DateTime createdAt;

  const MyReport({
    required this.id,
    required this.reason,
    required this.status,
    required this.createdAt,
  });

  factory MyReport.fromJson(Map<String, dynamic> json) => MyReport(
        id: asString(json['id']),
        reason: asString(json['reason']),
        status: asString(json['status'], fallback: 'submitted'),
        createdAt: asDate(json['created_at']),
      );
}

class ContactMatch {
  final User user;
  const ContactMatch(this.user);
}
