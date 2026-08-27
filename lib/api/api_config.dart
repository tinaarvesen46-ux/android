/// API Configuration for SwiftSnap Backend
/// 
/// Update BASE_URL to match your Laravel backend URL
class ApiConfig {
  // Base URL for your Laravel backend
  static const String BASE_URL = 'https://vexor.to'; // Update this!
  
  // API version
  static const String API_VERSION = 'v1';
  
  // Full API base URL
  static String get apiBaseUrl => '$BASE_URL/api/$API_VERSION';
  
  // Connection timeout
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
  
  // API Endpoints
  static const String auth = '/auth';
  static const String users = '/users';
  static const String chats = '/chats';
  static const String messages = '/messages';
  static const String stories = '/stories';
  static const String friends = '/friends';
  static const String friendRequests = '/friend-requests';
  static const String notifications = '/notifications';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String media = '/media';
  static const String search = '/search';
  static const String reports = '/reports';
  static const String subscription = '/subscription';
  static const String security = '/security';
  static const String privacy = '/privacy';
  
  // Auth endpoints
  static String get login => '$apiBaseUrl$auth/login';
  static String get register => '$apiBaseUrl$auth/register';
  static String get logout => '$apiBaseUrl$auth/logout';
  static String get refreshToken => '$apiBaseUrl$auth/refresh';
  static String get forgotPassword => '$apiBaseUrl$auth/forgot-password';
  static String get resetPassword => '$apiBaseUrl$auth/reset-password';
  static String get verifyEmail => '$apiBaseUrl$auth/verify-email';
  static String get resendVerification => '$apiBaseUrl$auth/resend-verification';
  
  // User endpoints
  static String get currentUser => '$apiBaseUrl$users/me';
  static String getUserById(String userId) => '$apiBaseUrl$users/$userId';
  static String get updateProfile => '$apiBaseUrl$users/me';
  static String get uploadAvatar => '$apiBaseUrl$users/me/avatar';
  static String get uploadCover => '$apiBaseUrl$users/me/cover';
  static String get userSettings => '$apiBaseUrl$users/me/settings';
  
  // Chat endpoints
  static String get chatsList => '$apiBaseUrl$chats';
  static String getChatById(String chatId) => '$apiBaseUrl$chats/$chatId';
  static String getChatMessages(String chatId) => '$apiBaseUrl$chats/$chatId/messages';
  static String sendMessage(String chatId) => '$apiBaseUrl$chats/$chatId/messages';
  static String markAsRead(String chatId) => '$apiBaseUrl$chats/$chatId/read';
  static String deleteMessage(String messageId) => '$apiBaseUrl$messages/$messageId';
  static String editMessage(String messageId) => '$apiBaseUrl$messages/$messageId';
  static String reactToMessage(String messageId) => '$apiBaseUrl$messages/$messageId/react';
  
  // Story endpoints
  static String get storiesList => '$apiBaseUrl$stories';
  static String get createStory => '$apiBaseUrl$stories';
  static String getStoryById(String storyId) => '$apiBaseUrl$stories/$storyId';
  static String deleteStory(String storyId) => '$apiBaseUrl$stories/$storyId';
  static String markStoryViewed(String storyId) => '$apiBaseUrl$stories/$storyId/view';
  static String getStoryViewers(String storyId) => '$apiBaseUrl$stories/$storyId/viewers';

  // ── SwiftSnap v31/v32 endpoints ──
  static String get publicStories => '$apiBaseUrl$stories/public';
  static String storyScreenshot(String id) => '$apiBaseUrl$stories/$id/screenshot';
  static String chatScreenshot(String id) => '$apiBaseUrl$chats/$id/screenshot';
  static String get creatorEarnings => '$apiBaseUrl/creator/earnings';
  static String get creatorTransactions => '$apiBaseUrl/creator/earnings/transactions';
  static String get achievements => '$apiBaseUrl/achievements';
  static String get deviceRegister => '$apiBaseUrl/devices/register';
  static String get deviceUnregister => '$apiBaseUrl/devices/unregister';
  static String get devicesList => '$apiBaseUrl/devices';
  static String get avatar => '$apiBaseUrl/avatar';
  static String get avatarReset => '$apiBaseUrl/avatar/reset';
  static String get callIceServers => '$apiBaseUrl/calls/ice-servers';
  static String get callsList => '$apiBaseUrl/calls';
  static String get callInitiate => '$apiBaseUrl/calls';
  static String callAccept(String uuid) => '$apiBaseUrl/calls/$uuid/accept';
  static String callDecline(String uuid) => '$apiBaseUrl/calls/$uuid/decline';
  static String callEnd(String uuid) => '$apiBaseUrl/calls/$uuid/end';
  static String callSignal(String uuid) => '$apiBaseUrl/calls/$uuid/signal';
  
  // Friend endpoints
  static String get friendsList => '$apiBaseUrl$friends';
  static String get friendRequestsList => '$apiBaseUrl$friendRequests';
  static String sendFriendRequest(String userId) => '$apiBaseUrl$friendRequests/send/$userId';
  static String acceptFriendRequest(String requestId) => '$apiBaseUrl$friendRequests/$requestId/accept';
  static String rejectFriendRequest(String requestId) => '$apiBaseUrl$friendRequests/$requestId/reject';
  static String cancelFriendRequest(String requestId) => '$apiBaseUrl$friendRequests/$requestId/cancel';
  static String unfriend(String userId) => '$apiBaseUrl$friends/$userId';
  static String blockUser(String userId) => '$apiBaseUrl$users/$userId/block';
  static String unblockUser(String userId) => '$apiBaseUrl$users/$userId/unblock';
  static String get blockedUsers => '$apiBaseUrl$users/blocked';
  
  // Search endpoints
  static String get searchUsers => '$apiBaseUrl$search/users';
  static String get searchMessages => '$apiBaseUrl$search/messages';
  static String get discoverUsers => '$apiBaseUrl$search/discover';
  
  // Notification endpoints
  static String get notificationsList => '$apiBaseUrl$notifications';
  static String markNotificationRead(String notificationId) => '$apiBaseUrl$notifications/$notificationId/read';
  static String get markAllNotificationsRead => '$apiBaseUrl$notifications/read-all';
  static String get notificationSettings => '$apiBaseUrl$notifications/settings';
  
  // Settings endpoints
  static String get privacySettings => '$apiBaseUrl$settings/privacy';
  static String get securitySettings => '$apiBaseUrl$settings/security';
  static String get notificationsSettings => '$apiBaseUrl$settings/notifications';
  static String get appearanceSettings => '$apiBaseUrl$settings/appearance';
  static String get changePassword => '$apiBaseUrl$settings/password';
  static String get enable2FA => '$apiBaseUrl$settings/2fa/enable';
  static String get disable2FA => '$apiBaseUrl$settings/2fa/disable';
  static String get verify2FA => '$apiBaseUrl$settings/2fa/verify';
  
  // Media endpoints
  static String get uploadMedia => '$apiBaseUrl$media/upload';
  static String getMediaUrl(String mediaId) => '$apiBaseUrl$media/$mediaId';
  static String deleteMedia(String mediaId) => '$apiBaseUrl$media/$mediaId';
  
  // Report endpoints
  static String get reportUser => '$apiBaseUrl$reports/user';
  static String get reportContent => '$apiBaseUrl$reports/content';
  static String get myReports => '$apiBaseUrl$reports/me';
  
  // Subscription endpoints
  static String get subscriptionPlans => '$apiBaseUrl$subscription/plans';
  static String get subscribe => '$apiBaseUrl$subscription/subscribe';
  static String get cancelSubscription => '$apiBaseUrl$subscription/cancel';
  static String get subscriptionStatus => '$apiBaseUrl$subscription/status';
  
  // Security endpoints
  static String get loginHistory => '$apiBaseUrl$security/login-history';
  static String get activeSessions => '$apiBaseUrl$security/sessions';
  static String revokeSession(String sessionId) => '$apiBaseUrl$security/sessions/$sessionId';
  static String get suspiciousActivity => '$apiBaseUrl$security/suspicious-activity';
  static String get exportData => '$apiBaseUrl$security/export-data';
  static String get deleteAccount => '$apiBaseUrl$security/delete-account';
  
  // Admin endpoints
  static const String admin = '/admin';
  static String get adminUsers => '$apiBaseUrl$admin/users';
  static String get adminTickets => '$apiBaseUrl$admin/tickets';
  static String get adminReports => '$apiBaseUrl$admin/reports';
  static String get adminAnalytics => '$apiBaseUrl$admin/analytics';
  static String get adminCampaigns => '$apiBaseUrl$admin/campaigns';
  static String get adminTemplates => '$apiBaseUrl$admin/email-templates';
  static String get adminSettings => '$apiBaseUrl$admin/settings';
  static String get adminAuditLogs => '$apiBaseUrl$admin/audit-logs';
  static String get adminDashboard => '$apiBaseUrl$admin/dashboard';

  // ── Realtime (Laravel Reverb, Pusher protocol) ──
  // Public app key (safe to embed). Server: wss://ws.vexor.to via Cloudflare.
  static const String reverbKey = '3a5662497ae6b060ad92c3d40116de69';
  static const String reverbHost = 'ws.vexor.to';
  static const int reverbPort = 443;

  // Token-authenticated broadcasting auth endpoint for private/presence channels.
  static String get broadcastAuthUrl => '$apiBaseUrl/broadcasting/auth';

  // WebSocket URL for real-time features
  static String get websocketUrl => 'wss://$reverbHost';
}
