// ============================================================
// Admin Models — SwiftSnap
// ============================================================

// ─── Support Ticket ──────────────────────────────────────────
enum TicketStatus { open, inProgress, resolved, closed }
enum TicketPriority { low, medium, high, urgent }
enum TicketCategory { account, billing, abuse, technical, other }

class SupportTicket {
  final String id;
  final String userId;
  final String userDisplayName;
  final String userAvatar;
  final String subject;
  final String description;
  final TicketStatus status;
  final TicketPriority priority;
  final TicketCategory category;
  final String? assignedToId;
  final String? assignedToName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<TicketReply> replies;

  const SupportTicket({
    required this.id,
    required this.userId,
    required this.userDisplayName,
    required this.userAvatar,
    required this.subject,
    required this.description,
    this.status = TicketStatus.open,
    this.priority = TicketPriority.medium,
    this.category = TicketCategory.other,
    this.assignedToId,
    this.assignedToName,
    required this.createdAt,
    required this.updatedAt,
    this.replies = const [],
  });

  SupportTicket copyWith({
    TicketStatus? status,
    TicketPriority? priority,
    String? assignedToId,
    String? assignedToName,
    List<TicketReply>? replies,
    DateTime? updatedAt,
  }) {
    return SupportTicket(
      id: id,
      userId: userId,
      userDisplayName: userDisplayName,
      userAvatar: userAvatar,
      subject: subject,
      description: description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      category: category,
      assignedToId: assignedToId ?? this.assignedToId,
      assignedToName: assignedToName ?? this.assignedToName,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      replies: replies ?? this.replies,
    );
  }
}

class TicketReply {
  final String id;
  final String authorId;
  final String authorName;
  final String authorAvatar;
  final bool isStaff;
  final String content;
  final DateTime createdAt;

  const TicketReply({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorAvatar,
    required this.isStaff,
    required this.content,
    required this.createdAt,
  });
}

// ─── Moderation Report ───────────────────────────────────────
enum ReportStatus { pending, reviewed, actioned, dismissed }
enum ReportReason {
  spam,
  harassment,
  inappropriateContent,
  violence,
  misinformation,
  other,
}
enum ContentType { message, story, profile, comment }

class ModerationReport {
  final String id;
  final String reporterId;
  final String reporterName;
  final String reporterAvatar;
  final String reportedUserId;
  final String reportedUserName;
  final String reportedUserAvatar;
  final ContentType contentType;
  final String contentPreview;
  final ReportReason reason;
  final String? additionalInfo;
  final ReportStatus status;
  final String? reviewedById;
  final String? reviewedByName;
  final DateTime createdAt;

  const ModerationReport({
    required this.id,
    required this.reporterId,
    required this.reporterName,
    required this.reporterAvatar,
    required this.reportedUserId,
    required this.reportedUserName,
    required this.reportedUserAvatar,
    required this.contentType,
    required this.contentPreview,
    required this.reason,
    this.additionalInfo,
    this.status = ReportStatus.pending,
    this.reviewedById,
    this.reviewedByName,
    required this.createdAt,
  });
}

// ─── Audit Log ───────────────────────────────────────────────
enum AuditAction {
  userBanned,
  userUnbanned,
  userRoleChanged,
  contentRemoved,
  ticketResolved,
  settingChanged,
  campaignSent,
  userWarned,
}

class AuditLog {
  final String id;
  final String adminId;
  final String adminName;
  final String adminAvatar;
  final AuditAction action;
  final String targetId;
  final String targetName;
  final String description;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  const AuditLog({
    required this.id,
    required this.adminId,
    required this.adminName,
    required this.adminAvatar,
    required this.action,
    required this.targetId,
    required this.targetName,
    required this.description,
    this.metadata = const {},
    required this.createdAt,
  });
}

// ─── Platform Analytics ──────────────────────────────────────
class PlatformAnalytics {
  final int totalUsers;
  final int activeUsersToday;
  final int activeUsersWeek;
  final int activeUsersMonth;
  final int newUsersToday;
  final int newUsersWeek;
  final int totalMessages;
  final int messagesToday;
  final int totalStories;
  final int storiesToday;
  final int openTickets;
  final int pendingReports;
  final double serverLoad;
  final List<DailyMetric> dailyActiveUsers;
  final List<DailyMetric> dailyMessages;
  final List<DailyMetric> dailyNewUsers;

  const PlatformAnalytics({
    required this.totalUsers,
    required this.activeUsersToday,
    required this.activeUsersWeek,
    required this.activeUsersMonth,
    required this.newUsersToday,
    required this.newUsersWeek,
    required this.totalMessages,
    required this.messagesToday,
    required this.totalStories,
    required this.storiesToday,
    required this.openTickets,
    required this.pendingReports,
    required this.serverLoad,
    required this.dailyActiveUsers,
    required this.dailyMessages,
    required this.dailyNewUsers,
  });
}

class DailyMetric {
  final DateTime date;
  final int value;

  const DailyMetric({required this.date, required this.value});
}

// ─── Email Campaign ──────────────────────────────────────────
enum CampaignStatus { draft, scheduled, sending, sent, failed }
enum TemplateCategory {
  welcome,
  promotional,
  notification,
  security,
  update,
  winback,
}

class EmailTemplate {
  final String id;
  final String name;
  final String subject;
  final String previewText;
  final String htmlContent;
  final TemplateCategory category;
  final String thumbnailColor;
  final List<String> variables;
  final bool isPremium;
  final DateTime createdAt;

  const EmailTemplate({
    required this.id,
    required this.name,
    required this.subject,
    required this.previewText,
    required this.htmlContent,
    required this.category,
    required this.thumbnailColor,
    this.variables = const [],
    this.isPremium = false,
    required this.createdAt,
  });
}

class EmailCampaign {
  final String id;
  final String name;
  final String templateId;
  final String templateName;
  final String subject;
  final List<String> targetAudience;
  final int recipientCount;
  final CampaignStatus status;
  final DateTime? scheduledAt;
  final DateTime? sentAt;
  final int? sentCount;
  final int? openCount;
  final int? clickCount;
  final DateTime createdAt;

  const EmailCampaign({
    required this.id,
    required this.name,
    required this.templateId,
    required this.templateName,
    required this.subject,
    required this.targetAudience,
    required this.recipientCount,
    this.status = CampaignStatus.draft,
    this.scheduledAt,
    this.sentAt,
    this.sentCount,
    this.openCount,
    this.clickCount,
    required this.createdAt,
  });

  double get openRate =>
      sentCount != null && sentCount! > 0
          ? (openCount ?? 0) / sentCount! * 100
          : 0;

  double get clickRate =>
      sentCount != null && sentCount! > 0
          ? (clickCount ?? 0) / sentCount! * 100
          : 0;
}

// ─── System Settings ─────────────────────────────────────────
class SystemSettings {
  final bool maintenanceMode;
  final bool registrationEnabled;
  final bool storyEnabled;
  final bool discoverEnabled;
  final bool emailVerificationRequired;
  final int maxFriendsPerUser;
  final int maxStoriesPerDay;
  final int messageRetentionDays;
  final String supportEmail;
  final String appVersion;
  final String minRequiredVersion;

  const SystemSettings({
    this.maintenanceMode = false,
    this.registrationEnabled = true,
    this.storyEnabled = true,
    this.discoverEnabled = true,
    this.emailVerificationRequired = true,
    this.maxFriendsPerUser = 500,
    this.maxStoriesPerDay = 10,
    this.messageRetentionDays = 30,
    this.supportEmail = 'support@swiftsnap.com',
    this.appVersion = '1.0.0',
    this.minRequiredVersion = '1.0.0',
  });

  SystemSettings copyWith({
    bool? maintenanceMode,
    bool? registrationEnabled,
    bool? storyEnabled,
    bool? discoverEnabled,
    bool? emailVerificationRequired,
    int? maxFriendsPerUser,
    int? maxStoriesPerDay,
    int? messageRetentionDays,
    String? supportEmail,
    String? appVersion,
    String? minRequiredVersion,
  }) {
    return SystemSettings(
      maintenanceMode: maintenanceMode ?? this.maintenanceMode,
      registrationEnabled: registrationEnabled ?? this.registrationEnabled,
      storyEnabled: storyEnabled ?? this.storyEnabled,
      discoverEnabled: discoverEnabled ?? this.discoverEnabled,
      emailVerificationRequired:
          emailVerificationRequired ?? this.emailVerificationRequired,
      maxFriendsPerUser: maxFriendsPerUser ?? this.maxFriendsPerUser,
      maxStoriesPerDay: maxStoriesPerDay ?? this.maxStoriesPerDay,
      messageRetentionDays: messageRetentionDays ?? this.messageRetentionDays,
      supportEmail: supportEmail ?? this.supportEmail,
      appVersion: appVersion ?? this.appVersion,
      minRequiredVersion: minRequiredVersion ?? this.minRequiredVersion,
    );
  }
}
