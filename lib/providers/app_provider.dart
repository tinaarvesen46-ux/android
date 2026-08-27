import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/chat_model.dart';
import '../models/story_model.dart';
import '../models/friend_request_model.dart';
import '../api/services/chat_service.dart';
import '../api/services/friend_service.dart';
import '../api/services/story_service.dart';
import '../api/services/notification_service.dart';
import '../api/services/realtime_service.dart';

class AppProvider extends ChangeNotifier {
  int _currentIndex = 0;
  bool _isOnline = true;
  bool _isLoggedIn = false;
  bool _isLoadingData = false;
  UserModel? _currentUser;
  List<ChatModel> _chats = [];
  List<StoryModel> _stories = [];
  List<UserModel> _friends = [];
  List<FriendRequestModel> _friendRequests = [];
  final Map<String, List<MessageModel>> _chatMessages = {};
  List<Map<String, dynamic>> _notifications = [];
  String? _activeChatId;

  List<Map<String, dynamic>> get notifications => _notifications;
  int get unreadNotificationCount =>
      _notifications.where((n) => n['is_read'] != true && n['read_at'] == null).length;

  int get currentIndex => _currentIndex;
  bool get isOnline => _isOnline;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoadingData => _isLoadingData;
  UserModel? get currentUser => _currentUser;
  List<ChatModel> get chats => _chats;
  List<StoryModel> get stories => _stories;
  List<UserModel> get friends => _friends;
  List<FriendRequestModel> get friendRequests => _friendRequests
      .where((r) => r.receiver.id == _currentUser?.id && r.status == FriendRequestStatus.pending)
      .toList();
  int get friendRequestsCount => friendRequests.length;

  AppProvider();

  /// Called after a successful API login with the real authenticated user.
  /// Sets the user, routes to HomeScreen, then loads the user's real data
  /// (friends, chats, stories, friend requests) from the Laravel backend.
  void login(UserModel user) {
    _currentUser = user;
    _isLoggedIn = true;
    _currentIndex = 0;
    notifyListeners();
    _initRealtime();
    loadInitialData();
  }

  /// Call this on logout — clears all state and routes back to LoginScreen.
  void logout() {
    _isLoggedIn = false;
    _currentUser = null;
    _chats = [];
    _stories = [];
    _friends = [];
    _friendRequests = [];
    _chatMessages.clear();
    _currentIndex = 0;
    _isOnline = true;
    _activeChatId = null;
    RealtimeService.instance.disconnect();
    notifyListeners();
  }

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void toggleOnlineStatus() {
    _isOnline = !_isOnline;
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // REAL BACKEND DATA LOADING
  // Populates the provider from the Laravel API. Each source is loaded
  // independently and defensively: a failure or unexpected shape yields an
  // empty list for that section rather than crashing or showing demo data.
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> loadInitialData() async {
    _isLoadingData = true;
    notifyListeners();
    await Future.wait([
      _loadFriends(),
      _loadFriendRequests(),
      _loadChats(),
      _loadStories(),
      _loadNotifications(),
    ]);
    _isLoadingData = false;
    notifyListeners();
  }

  Future<void> refresh() => loadInitialData();

  Future<void> _loadFriends() async {
    try {
      final res = await FriendService().getFriends();
      if (res.isSuccess && res.data != null) {
        _friends = res.data!;
      }
    } catch (_) {/* keep whatever we have; never inject demo data */}
  }

  Future<void> _loadFriendRequests() async {
    try {
      final res = await FriendService().getFriendRequests();
      if (res.isSuccess && res.data != null) {
        _friendRequests = res.data!
            .map(_friendRequestFromJson)
            .whereType<FriendRequestModel>()
            .toList();
      }
    } catch (_) {}
  }

  Future<void> _loadChats() async {
    try {
      final res = await ChatService().getChats();
      if (res.isSuccess && res.data != null) {
        _chats = res.data!
            .map(_chatFromJson)
            .whereType<ChatModel>()
            .toList();
        _chats.sort((a, b) {
          if (a.isPinned && !b.isPinned) return -1;
          if (!a.isPinned && b.isPinned) return 1;
          return b.lastMessage.timestamp.compareTo(a.lastMessage.timestamp);
        });
        // One conversation per friend (Snapchat-style): keep the most recent
        // chat per participant, dropping duplicate 1-on-1 threads.
        final seen = <String>{};
        _chats = _chats.where((c) {
          final key = c.participant.id;
          if (key.isEmpty) return true;
          return seen.add(key);
        }).toList();
      }
    } catch (_) {}
  }

  Future<void> _loadStories() async {
    try {
      final res = await StoryService().getStories();
      if (res.isSuccess && res.data != null) {
        _stories = res.data!
            .map(_storyFromJson)
            .whereType<StoryModel>()
            .toList();
      }
    } catch (_) {}
  }

  Future<void> _loadNotifications() async {
    try {
      final res = await NotificationService().getNotifications();
      if (res.isSuccess && res.data != null) {
        _notifications = res.data!;
      }
    } catch (_) {}
  }

  Future<void> markNotificationRead(String id) async {
    final i = _notifications.indexWhere((n) => '${n['id']}' == id);
    if (i != -1) {
      _notifications[i] = {..._notifications[i], 'is_read': true, 'read_at': DateTime.now().toIso8601String()};
      notifyListeners();
    }
    await NotificationService().markRead(id);
  }

  Future<void> markAllNotificationsRead() async {
    _notifications = _notifications
        .map((n) => {...n, 'is_read': true, 'read_at': DateTime.now().toIso8601String()})
        .toList();
    notifyListeners();
    await NotificationService().markAllRead();
  }

  // ─── Tolerant JSON → model parsers (Laravel snake_case conventions) ───

  UserModel? _userFrom(dynamic json) {
    if (json is! Map) return null;
    try {
      return UserModel.fromJson(Map<String, dynamic>.from(json));
    } catch (_) {
      return null;
    }
  }

  DateTime _dateFrom(dynamic v) {
    if (v is String) {
      return DateTime.tryParse(v)?.toLocal() ?? DateTime.now();
    }
    return DateTime.now();
  }

  FriendRequestModel? _friendRequestFromJson(Map<String, dynamic> json) {
    final sender = _userFrom(json['sender'] ?? json['from'] ?? json['user']);
    final receiver = _userFrom(json['receiver'] ?? json['to']) ?? _currentUser;
    if (sender == null || receiver == null) return null;
    return FriendRequestModel(
      id: (json['id'] ?? json['uuid'] ?? '').toString(),
      sender: sender,
      receiver: receiver,
      status: _requestStatusFrom(json['status']?.toString()),
      createdAt: _dateFrom(json['created_at'] ?? json['createdAt']),
      message: json['message']?.toString(),
    );
  }

  FriendRequestStatus _requestStatusFrom(String? s) {
    switch (s?.toLowerCase()) {
      case 'accepted':
        return FriendRequestStatus.accepted;
      case 'rejected':
        return FriendRequestStatus.rejected;
      default:
        return FriendRequestStatus.pending;
    }
  }

  MessageModel _messageFrom(dynamic json, {String fallbackSender = ''}) {
    if (json is! Map) {
      return MessageModel(
        id: 'm_${DateTime.now().microsecondsSinceEpoch}',
        senderId: fallbackSender,
        content: '',
        timestamp: DateTime.now(),
      );
    }
    return MessageModel(
      id: (json['id'] ?? json['uuid'] ?? '').toString(),
      senderId: (json['sender_id'] ?? json['senderId'] ?? fallbackSender).toString(),
      content: (json['content'] ?? json['text'] ?? '').toString(),
      timestamp: _dateFrom(json['timestamp'] ?? json['created_at'] ?? json['createdAt']),
      type: _messageTypeFrom(json['type']?.toString()),
      isRead: json['is_read'] == true || json['read'] == true,
    );
  }

  MessageType _messageTypeFrom(String? s) {
    switch (s?.toLowerCase()) {
      case 'image':
        return MessageType.image;
      case 'video':
        return MessageType.video;
      case 'voice':
        return MessageType.voice;
      case 'gif':
        return MessageType.gif;
      default:
        return MessageType.text;
    }
  }

  ChatModel? _chatFromJson(Map<String, dynamic> json) {
    final parts = json['other_participants'];
    final participant = _userFrom(
      json['participant'] ??
          json['user'] ??
          json['other_user'] ??
          ((parts is List && parts.isNotEmpty) ? parts.first : null),
    );
    if (participant == null) return null;
    final lastMsgJson = json['last_message'] ?? json['lastMessage'];
    return ChatModel(
      id: (json['id'] ?? json['uuid'] ?? '').toString(),
      participant: participant,
      lastMessage: _messageFrom(lastMsgJson, fallbackSender: participant.id),
      isPinned: json['is_pinned'] == true || json['pinned'] == true,
      isMuted: json['is_muted'] == true,
      unreadCount: (json['unread_count'] ?? json['unreadCount'] ?? 0) is int
          ? (json['unread_count'] ?? json['unreadCount'] ?? 0) as int
          : int.tryParse('${json['unread_count'] ?? json['unreadCount'] ?? 0}') ?? 0,
    );
  }

  StoryModel? _storyFromJson(Map<String, dynamic> json) {
    final user = _userFrom(json['user'] ?? json['owner']);
    final mediaUrl = (json['media_url'] ?? json['mediaUrl'] ?? '').toString();
    if (user == null || mediaUrl.isEmpty) return null;
    return StoryModel(
      id: (json['id'] ?? json['uuid'] ?? '').toString(),
      user: user,
      mediaUrl: mediaUrl,
      type: (json['type']?.toString().toLowerCase() == 'video')
          ? StoryType.video
          : StoryType.image,
      createdAt: _dateFrom(json['created_at'] ?? json['createdAt']),
      viewerCount: (json['viewer_count'] ?? json['views'] ?? 0) is int
          ? (json['viewer_count'] ?? json['views'] ?? 0) as int
          : int.tryParse('${json['viewer_count'] ?? json['views'] ?? 0}') ?? 0,
      hasUnviewed: json['has_unviewed'] == true || json['is_new'] == true,
      isOwn: json['is_own'] == true || (user.id == _currentUser?.id),
      caption: json['caption']?.toString(),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // REALTIME (Laravel Reverb) — live message delivery + read receipts
  // ─────────────────────────────────────────────────────────────────────────
  void _initRealtime() {
    RealtimeService.instance.onEvent = _onRealtimeEvent;
    RealtimeService.instance.connect();
  }

  /// Subscribe to a conversation's private channel while its screen is open.
  Future<void> subscribeToConversation(String chatId) async {
    _activeChatId = chatId;
    await RealtimeService.instance.subscribe('private-conversation.$chatId');
  }

  Future<void> unsubscribeFromConversation(String chatId) async {
    if (_activeChatId == chatId) _activeChatId = null;
    await RealtimeService.instance.unsubscribe('private-conversation.$chatId');
  }

  void _onRealtimeEvent(String channelName, String eventName, Map<String, dynamic> data) {
    final convId = channelName.split('.').last;
    if (eventName == 'MessageSent') {
      final m = data['message'];
      if (m is Map) _applyIncomingMessage(convId, Map<String, dynamic>.from(m));
    } else if (eventName == 'MessageRead') {
      _applyReadReceipt(convId, data);
    }
  }

  void _applyIncomingMessage(String chatId, Map<String, dynamic> json) {
    final msg = _messageFrom(json, fallbackSender: '');
    final list = _chatMessages[chatId] ?? [];

    final existing = list.indexWhere((m) => m.id == msg.id);
    if (existing != -1) {
      list[existing] = msg;
    } else {
      // Replace an optimistic (temp_) echo of my own just-sent message.
      final temp = list.indexWhere((m) =>
          m.id.startsWith('temp_') &&
          m.senderId == msg.senderId &&
          m.content == msg.content);
      if (temp != -1) {
        list[temp] = msg;
      } else {
        list.add(msg);
      }
    }
    _chatMessages[chatId] = list;

    final ci = _chats.indexWhere((c) => c.id == chatId);
    if (ci != -1) {
      final isMine = msg.senderId == (_currentUser?.id ?? '');
      final bump = !isMine && _activeChatId != chatId;
      _chats[ci] = _chats[ci].copyWith(
        lastMessage: msg,
        unreadCount: bump ? _chats[ci].unreadCount + 1 : _chats[ci].unreadCount,
      );
      _chats.sort((a, b) {
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        return b.lastMessage.timestamp.compareTo(a.lastMessage.timestamp);
      });
    }
    notifyListeners();
  }

  void _applyReadReceipt(String chatId, Map<String, dynamic> data) {
    final list = _chatMessages[chatId];
    if (list == null) return;
    final readerId = '${data['user_id'] ?? ''}';
    if (readerId == (_currentUser?.id ?? '')) return; // ignore my own read
    var changed = false;
    for (var i = 0; i < list.length; i++) {
      if (list[i].senderId == (_currentUser?.id ?? '') && !list[i].isRead) {
        list[i] = list[i].copyWith(isRead: true, status: MessageStatus.read);
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // MESSAGES
  // ─────────────────────────────────────────────────────────────────────────
  List<MessageModel> getChatMessages(String chatId) {
    return _chatMessages[chatId] ?? [];
  }

  /// Loads real message history for a conversation from the backend.
  /// Upload + send a real media message (photo/video) via the chat API.
  Future<String?> sendMediaMessage(String chatId, String filePath, {String type = 'image'}) async {
    final upload = await ChatService().uploadMedia(filePath, type: type);
    if (!upload.success || upload.data == null) return upload.message ?? 'Upload failed';
    final d = upload.data!;
    final mediaUrl = (d['url'] ?? d['media_url'] ?? d['path'] ?? '').toString();
    if (mediaUrl.isEmpty) return 'Upload returned no media URL';
    final res = await ChatService().sendMessage(
      chatId: chatId, content: '', type: type, mediaUrl: mediaUrl);
    if (!res.success) return res.message ?? 'Could not send media';
    await loadChatMessages(chatId);
    return null;
  }

  Future<void> loadChatMessages(String chatId) async {
    try {
      final res = await ChatService().getChatMessages(chatId: chatId);
      if (res.isSuccess && res.data != null) {
        _chatMessages[chatId] = res.data!.map((m) => _messageFrom(m, fallbackSender: '')).toList();
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> sendMessage(String chatId, String content) async {
    final messages = _chatMessages[chatId] ?? [];
    final tempId = 'temp_${DateTime.now().microsecondsSinceEpoch}';
    final newMessage = MessageModel(
      id: tempId,
      senderId: _currentUser?.id ?? '',
      content: content,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
    );

    messages.add(newMessage);
    _chatMessages[chatId] = messages;

    final chatIndex = _chats.indexWhere((c) => c.id == chatId);
    if (chatIndex != -1) {
      _chats[chatIndex] = _chats[chatIndex].copyWith(lastMessage: newMessage);
      _chats.sort((a, b) {
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        return b.lastMessage.timestamp.compareTo(a.lastMessage.timestamp);
      });
    }
    notifyListeners();

    try {
      final res = await ChatService().sendMessage(chatId: chatId, content: content, type: 'text');
      final idx = messages.indexWhere((m) => m.id == tempId);
      if (idx == -1) return;
      if (res.success && res.data != null) {
        final serverId = (res.data!['id'] ?? res.data!['uuid'] ?? tempId).toString();
        messages[idx] = messages[idx].copyWith(id: serverId, status: MessageStatus.sent);
      } else {
        messages[idx] = messages[idx].copyWith(status: MessageStatus.failed);
      }
    } catch (_) {
      final idx = messages.indexWhere((m) => m.id == tempId);
      if (idx != -1) {
        messages[idx] = messages[idx].copyWith(status: MessageStatus.failed);
      }
    }
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // FRIEND REQUESTS
  // ─────────────────────────────────────────────────────────────────────────
  void acceptFriendRequest(String requestId) {
    final index = _friendRequests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      final request = _friendRequests[index];
      _friendRequests[index] = request.copyWith(status: FriendRequestStatus.accepted);
      if (!_friends.any((f) => f.id == request.sender.id)) {
        _friends.add(request.sender);
      }
      notifyListeners();
    }
    FriendService().acceptFriendRequest(requestId).then((_) {}, onError: (_) {});
  }

  void rejectFriendRequest(String requestId) {
    final index = _friendRequests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      _friendRequests[index] = _friendRequests[index].copyWith(status: FriendRequestStatus.rejected);
      notifyListeners();
    }
    FriendService().rejectFriendRequest(requestId).then((_) {}, onError: (_) {});
  }

  void sendFriendRequest(UserModel user, {String? message}) {
    if (_currentUser == null) return;
    final request = FriendRequestModel(
      id: 'req_${DateTime.now().millisecondsSinceEpoch}',
      sender: _currentUser!,
      receiver: user,
      createdAt: DateTime.now(),
      message: message,
    );
    _friendRequests.add(request);
    notifyListeners();
    FriendService().sendFriendRequest(user.id).then((_) {}, onError: (_) {});
  }

  void removeFriend(String userId) {
    _friends.removeWhere((f) => f.id == userId);
    notifyListeners();
    FriendService().unfriend(userId).then((_) {}, onError: (_) {});
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PROFILE / USER MUTATIONS (local state; backend sync handled by services)
  // ─────────────────────────────────────────────────────────────────────────
  void adminUpdateUser(UserModel updated) {
    if (_currentUser?.id == updated.id) {
      _currentUser = updated;
    }
    final fi = _friends.indexWhere((u) => u.id == updated.id);
    if (fi != -1) _friends[fi] = updated;
    notifyListeners();
  }

  void updateCurrentUser({UserModel? user, PrivacyLevel? privacyLevel}) {
    if (user != null) {
      _currentUser = user;
    } else if (privacyLevel != null && _currentUser != null) {
      _currentUser = _currentUser!.copyWith(privacyLevel: privacyLevel);
    }
    notifyListeners();
  }

  void updateUserProfile({
    String? displayName,
    String? bio,
    String? avatarUrl,
    String? coverUrl,
    String? pronouns,
    String? location,
  }) {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(
      displayName: displayName,
      bio: bio,
      avatarUrl: avatarUrl,
      coverUrl: coverUrl,
      pronouns: pronouns,
      location: location,
    );
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // STORIES / CHATS LOCAL HELPERS
  // ─────────────────────────────────────────────────────────────────────────
  void addStory(String mediaUrl, StoryType type) {
    if (_currentUser == null) return;
    final story = StoryModel(
      id: 'story_${DateTime.now().millisecondsSinceEpoch}',
      user: _currentUser!,
      mediaUrl: mediaUrl,
      type: type,
      createdAt: DateTime.now(),
      viewerCount: 0,
      isOwn: true,
    );
    _stories.insert(0, story);
    notifyListeners();
  }

  /// Publish a real story from a captured media file:
  /// media/upload -> stories (create) -> refresh. Returns null on success or an
  /// error message on failure. Used by the camera FAB and the Stories/Chats
  /// add-story entry points so every story is persisted on the backend.
  Future<String?> publishStoryFromFile(String filePath, {bool isVideo = false}) async {
    final storyService = StoryService();
    final type = isVideo ? 'video' : 'image';
    final upload = await storyService.uploadStoryMedia(filePath, type: type);
    if (!upload.success || upload.data == null) {
      return upload.message ?? 'Upload failed';
    }
    final data = upload.data!;
    final mediaUrl = (data['url'] ?? data['media_url'] ?? data['path'] ?? '').toString();
    final mediaId = (data['id'] ?? data['media_id'] ?? '').toString();
    if (mediaUrl.isEmpty) return 'Upload returned no media URL';
    final created = await storyService.createStory(
      mediaUrl: mediaUrl,
      type: type,
      mediaId: mediaId.isEmpty ? null : mediaId,
    );
    if (!created.success) return created.message ?? 'Could not post story';
    await refresh();
    return null;
  }

  void markStoryAsViewed(String storyId) {
    final index = _stories.indexWhere((s) => s.id == storyId);
    if (index != -1 && _stories[index].hasUnviewed) {
      _stories[index] = _stories[index].copyWith(hasUnviewed: false);
      notifyListeners();
      StoryService().markStoryViewed(storyId).then((_) {}, onError: (_) {});
    }
  }

  void markChatAsRead(String chatId) {
    final index = _chats.indexWhere((c) => c.id == chatId);
    if (index != -1) {
      _chats[index] = _chats[index].copyWith(unreadCount: 0);
      notifyListeners();
      ChatService().markAsRead(chatId).then((_) {}, onError: (_) {});
    }
  }

  void togglePinChat(String chatId) {
    final index = _chats.indexWhere((c) => c.id == chatId);
    if (index != -1) {
      _chats[index] = _chats[index].copyWith(isPinned: !_chats[index].isPinned);
      _chats.sort((a, b) {
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        return b.lastMessage.timestamp.compareTo(a.lastMessage.timestamp);
      });
      notifyListeners();
    }
  }
}
