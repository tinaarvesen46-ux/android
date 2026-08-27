import 'dart:async';
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
import '../api/api_config.dart';

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
    // Media: the backend returns a `media` array; each item exposes a `uuid`
    // that streams through GET /media/message/{uuid} (auth-gated). Build the
    // absolute, token-authenticated URL clients render.
    String? mediaUrl;
    final media = json['media'];
    if (media is List && media.isNotEmpty && media.first is Map) {
      final uuid = (media.first['uuid'] ?? '').toString();
      if (uuid.isNotEmpty) mediaUrl = '${ApiConfig.apiBaseUrl}/media/message/$uuid';
    }
    mediaUrl ??= (json['media_url'] ?? json['mediaUrl'])?.toString();

    // Reactions
    final reactions = <MessageReaction>[];
    final rx = json['reactions'];
    if (rx is List) {
      for (final r in rx) {
        if (r is Map) {
          final e = (r['emoji'] ?? r['reaction'] ?? '').toString();
          if (e.isNotEmpty) {
            reactions.add(MessageReaction(
              emoji: e,
              userId: (r['user_id'] ?? r['userId'] ?? '').toString(),
              timestamp: _dateFrom(r['created_at']),
            ));
          }
        }
      }
    }

    final readAt = json['read_at'];
    final deliveredAt = json['delivered_at'];
    final status = (readAt != null && '$readAt'.isNotEmpty)
        ? MessageStatus.read
        : (deliveredAt != null && '$deliveredAt'.isNotEmpty)
            ? MessageStatus.delivered
            : MessageStatus.sent;

    return MessageModel(
      id: (json['id'] ?? json['uuid'] ?? '').toString(),
      senderId: (json['sender_id'] ?? json['senderId'] ?? fallbackSender).toString(),
      content: (json['content'] ?? json['text'] ?? '').toString(),
      timestamp: _dateFrom(json['timestamp'] ?? json['created_at'] ?? json['createdAt']),
      type: _messageTypeFrom(json['type']?.toString()),
      isRead: readAt != null && '$readAt'.isNotEmpty,
      status: status,
      mediaUrl: mediaUrl,
      reactions: reactions,
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
    // Ring on incoming calls even before opening any chat: listen on my own
    // private user channel.
    final myId = _currentUser?.id;
    if (myId != null && myId.isNotEmpty) {
      RealtimeService.instance.subscribe('private-user.$myId');
    }
  }

  // ── Calling: incoming ring + per-call signaling routing ──
  Map<String, dynamic>? _incomingCall;
  Map<String, dynamic>? get incomingCall => _incomingCall;
  void Function(String kind, Map<String, dynamic> data)? _callSignalHandler;

  void registerCallSignalHandler(void Function(String, Map<String, dynamic>) h) {
    _callSignalHandler = h;
  }

  void clearCallSignalHandler() => _callSignalHandler = null;

  void clearIncomingCall() {
    _incomingCall = null;
    notifyListeners();
  }

  Future<void> subscribeToCall(String uuid) =>
      RealtimeService.instance.subscribe('private-call.$uuid');
  Future<void> unsubscribeFromCall(String uuid) =>
      RealtimeService.instance.unsubscribe('private-call.$uuid');

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
    } else if (eventName == 'client-typing') {
      final from = '${data['user_id'] ?? ''}';
      if (from.isNotEmpty && from != (_currentUser?.id ?? '')) {
        _setTyping(convId);
      }
    } else if (eventName == 'CallInitiated') {
      final call = data['call'];
      if (call is Map) {
        _incomingCall = Map<String, dynamic>.from(call);
        notifyListeners();
      }
    } else if (eventName == 'CallSignal') {
      final from = '${data['from'] ?? ''}';
      if (from == (_currentUser?.id ?? '')) return; // ignore my own echoes
      final kind = (data['kind'] ?? '').toString();
      final payload = data['data'] is Map
          ? Map<String, dynamic>.from(data['data'])
          : <String, dynamic>{};
      _callSignalHandler?.call(kind, payload);
    }
  }

  // ── Typing indicators (Reverb client whispers; throttled, auto-expiring) ──
  final Map<String, bool> _typing = {};
  final Map<String, Timer> _typingTimers = {};
  DateTime _lastTypingSent = DateTime.fromMillisecondsSinceEpoch(0);

  bool isTypingIn(String chatId) => _typing[chatId] == true;

  /// Called as the user types; throttled to one whisper per ~2s.
  void sendTyping(String chatId) {
    final now = DateTime.now();
    if (now.difference(_lastTypingSent).inMilliseconds < 2000) return;
    _lastTypingSent = now;
    RealtimeService.instance.whisper(
      'private-conversation.$chatId',
      'client-typing',
      {'user_id': _currentUser?.id ?? ''},
    );
  }

  void _setTyping(String chatId) {
    _typing[chatId] = true;
    notifyListeners();
    _typingTimers[chatId]?.cancel();
    _typingTimers[chatId] = Timer(const Duration(seconds: 4), () {
      _typing[chatId] = false;
      notifyListeners();
    });
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
  /// Upload + send a real media message (photo/video) in a SINGLE multipart
  /// request to POST /chats/{id}/messages. Shows an optimistic pending bubble
  /// immediately; on success it is replaced by the server message (with media),
  /// on failure it is marked failed so the UI can offer a retry. Returns null
  /// on success or a human error string on failure.
  Future<String?> sendMediaMessage(String chatId, String filePath, {String type = 'image'}) async {
    final messages = _chatMessages[chatId] ?? [];
    final tempId = 'temp_${DateTime.now().microsecondsSinceEpoch}';
    final pending = MessageModel(
      id: tempId,
      senderId: _currentUser?.id ?? '',
      content: '',
      timestamp: DateTime.now(),
      type: type == 'video' ? MessageType.video : MessageType.image,
      status: MessageStatus.sending,
      mediaUrl: filePath, // local path preview while uploading
    );
    messages.add(pending);
    _chatMessages[chatId] = messages;
    notifyListeners();

    final res = await ChatService().sendMediaMessage(chatId, filePath, type: type);
    final idx = messages.indexWhere((m) => m.id == tempId);
    if (res.success && res.data != null) {
      final server = _messageFrom(res.data, fallbackSender: _currentUser?.id ?? '');
      if (idx != -1) messages[idx] = server;
      final ci = _chats.indexWhere((c) => c.id == chatId);
      if (ci != -1) _chats[ci] = _chats[ci].copyWith(lastMessage: server);
      notifyListeners();
      return null;
    }
    if (idx != -1) {
      messages[idx] = messages[idx].copyWith(status: MessageStatus.failed);
      notifyListeners();
    }
    return res.message ?? 'Could not send media';
  }

  /// React to a message (Snapchat-style). Optimistic: apply my reaction locally,
  /// then persist via POST /messages/{id}/react. Backend enforces one reaction
  /// per user (updateOrCreate).
  Future<void> reactToMessage(String chatId, String messageId, String emoji) async {
    final list = _chatMessages[chatId];
    if (list == null) return;
    final i = list.indexWhere((m) => m.id == messageId);
    if (i == -1) return;
    final mine = _currentUser?.id ?? '';
    final existing = List<MessageReaction>.from(list[i].reactions)
      ..removeWhere((r) => r.userId == mine);
    existing.add(MessageReaction(emoji: emoji, userId: mine, timestamp: DateTime.now()));
    list[i] = list[i].copyWith(reactions: existing);
    notifyListeners();
    await ChatService().reactToMessage(messageId: messageId, emoji: emoji);
  }

  Future<void> loadChatMessages(String chatId) async {
    try {
      final res = await ChatService().getChatMessages(chatId: chatId);
      if (res.isSuccess && res.data != null) {
        final msgs = res.data!.map((m) => _messageFrom(m, fallbackSender: '')).toList();
        // Backend returns newest-first (orderByDesc id); display oldest→newest.
        msgs.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        _chatMessages[chatId] = msgs;
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

  /// Send a captured photo/video to one or more friends. Opens (or reuses) a
  /// direct conversation with each and posts the media. Returns null on success
  /// or an error string. Used by the camera capture → destination chooser.
  Future<String?> sendCapturedMediaToFriends(
      List<int> friendIds, String filePath, {bool isVideo = false}) async {
    final type = isVideo ? 'video' : 'image';
    for (final fid in friendIds) {
      final chat = await ChatService().createDirectChat(fid);
      if (!chat.success || chat.data == null) return chat.message ?? 'Could not open chat';
      final chatId = (chat.data!['id'] ?? chat.data!['uuid'] ?? '').toString();
      if (chatId.isEmpty) return 'Could not resolve conversation';
      final res = await ChatService().sendMediaMessage(chatId, filePath, type: type);
      if (!res.success) return res.message ?? 'Could not send media';
    }
    await _loadChats();
    notifyListeners();
    return null;
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
