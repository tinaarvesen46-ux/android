import 'dart:async';
import 'package:flutter/foundation.dart';

import '../core/api_failure.dart';
import '../core/json_mappers.dart';
import '../core/load_state.dart';
import '../models/chat.dart';
import '../models/story.dart';
import '../repositories/chat_repository.dart';
import '../repositories/feed_repository.dart';
import '../services/realtime_service.dart';

class ChatsProvider extends ChangeNotifier {
  final ChatRepository _chats;
  final FeedRepository _feed;
  final RealtimeService _rt;

  ChatsProvider({
    required ChatRepository chatRepository,
    required FeedRepository feedRepository,
    required RealtimeService realtimeService,
  })  : _chats = chatRepository,
        _feed = feedRepository,
        _rt = realtimeService;

  LoadState<List<Conversation>> _conversations =
      LoadState<List<Conversation>>.idle();
  LoadState<List<Story>> _stories = LoadState<List<Story>>.idle();
  final Map<String, LoadState<List<ChatMessage>>> _messages = {};
  final Map<String, LoadState<List<dynamic>>> _storyReplies = {};
  final Set<String> _onlineUserIds = {};
  final Set<String> _wiredChannels = {};
  final Set<String> _wiredStoryChannels = {};
  final Map<String, Timer> _typingTimers = {};
  bool _presenceWired = false;

  LoadState<List<Conversation>> get conversations => _conversations;

  LoadState<List<Story>> get stories => _stories;

  LoadState<List<ChatMessage>> messagesFor(String conversationId) =>
      _messages[conversationId] ?? LoadState<List<ChatMessage>>.idle();

    LoadState<List<dynamic>> storyRepliesFor(String storyItemId) =>
      _storyReplies[storyItemId] ?? LoadState<List<dynamic>>.idle();

  bool isUserOnline(String userId) => _onlineUserIds.contains(userId);

  Future<void> load() async {
    await Future.wait([loadConversations(), loadStories()]);
  }

  Future<void> loadConversations() async {
    _conversations = LoadState<List<Conversation>>.loading();
    notifyListeners();
    try {
      final list = await _chats.fetchConversations();
      _conversations = listState(_withBuiltInAi(list));
      _wirePresence();
      for (final c in list) {
        _wireConversationChannel(c.id);
      }
    } on ApiFailure catch (e) {
      _conversations = LoadState<List<Conversation>>.error(e.message);
    }
    notifyListeners();
  }

  List<Conversation> _withBuiltInAi(List<Conversation> conversations) {
    if (conversations.any((conversation) => conversation.isAi)) {
      return conversations;
    }
    final withoutAi = conversations.where((c) => !c.isAi).toList();
    final ai = Conversation(
      id: 'my-ai',
      type: 'ai',
      participant: const User(
        id: 'my-ai',
        username: 'myai',
        displayName: 'My AI',
        role: 'support',
        roleLabel: 'SwiftSnap AI',
      ),
      isPinned: true,
    );
    return [ai, ...withoutAi];
  }

  Future<void> loadStories() async {
    _stories = LoadState<List<Story>>.loading();
    notifyListeners();
    try {
      _stories = listState(await _feed.fetchStories());
    } on ApiFailure catch (e) {
      _stories = LoadState<List<Story>>.error(e.message);
    }
    notifyListeners();
  }

  Future<void> loadMessages(String conversationId) async {
    _wireConversationChannel(conversationId);
    _messages[conversationId] = LoadState<List<ChatMessage>>.loading();
    notifyListeners();
    try {
      _messages[conversationId] =
          listState(await _chats.fetchMessages(conversationId));
      await _chats.markRead(conversationId);
    } on ApiFailure catch (e) {
      _messages[conversationId] = LoadState<List<ChatMessage>>.error(e.message);
    }
    notifyListeners();
  }

  Future<void> loadStoryReplies(String storyItemId) async {
    _wireStoryChannel(storyItemId);
    _storyReplies[storyItemId] = LoadState<List<dynamic>>.loading();
    notifyListeners();
    try {
      final list = await _feed.fetchStoryReplies(storyItemId);
      _storyReplies[storyItemId] = listState(list.map(storyCommentFromJson).toList());
    } on ApiFailure catch (e) {
      _storyReplies[storyItemId] = LoadState<List<dynamic>>.error(e.message);
    }
    notifyListeners();
  }

  Future<String?> sendStoryReply({required String storyItemId, required String content}) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return null;
    try {
      await _feed.replyToStory(storyItemId: storyItemId, content: trimmed);
      // optimistic: append a temporary placeholder will be reconciled by realtime
      final current = _storyReplies[storyItemId]?.data ?? const <dynamic>[];
      _storyReplies[storyItemId] = LoadState<List<dynamic>>.success([
        ...current,
      ]);
      notifyListeners();
      return null;
    } on ApiFailure catch (e) {
      return e.message;
    }
  }

  Future<String?> sendStoryReaction({required String storyItemId, required String reaction}) async {
    try {
      await _feed.postStoryReaction(storyItemId, reaction);
      return null;
    } on ApiFailure catch (e) {
      return e.message;
    }
  }

  /// Returns null on success, otherwise a user-facing message.
  Future<String?> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return null;
    try {
      final message = await _chats.sendTextMessage(
        conversationId: conversationId,
        content: trimmed,
      );
      final current = _messages[conversationId]?.data ?? const <ChatMessage>[];
      _messages[conversationId] =
          LoadState<List<ChatMessage>>.success([...current, message]);
      _bumpConversationWithMessage(conversationId, message);
      notifyListeners();
      return null;
    } on ApiFailure catch (e) {
      return e.message;
    }
  }

  /// Fire-and-forget realtime typing signal — never surfaces an error.
  void setTyping(String conversationId, bool isTyping) {
    unawaited(_chats.sendTyping(conversationId, isTyping).catchError((_) {}));
  }

  Future<String?> setMuted(String conversationId, bool muted) async {
    try {
      await _chats.setMuted(conversationId, muted);
      await loadConversations();
      return null;
    } on ApiFailure catch (e) {
      return e.message;
    }
  }

  Future<String?> deleteConversation(String conversationId) async {
    try {
      await _chats.deleteConversation(conversationId);
      _messages.remove(conversationId);
      await loadConversations();
      return null;
    } on ApiFailure catch (e) {
      return e.message;
    }
  }

  /// Opens (or creates, idempotently on the backend) a direct conversation
  /// with [userId]. Returns the conversation id, or null on failure — check
  /// [lastError] for the message to show.
  String? lastError;

  Future<String?> startConversationWith(String userId) async {
    lastError = null;
    try {
      final id = await _chats.createConversation(userId);
      unawaited(loadConversations());
      return id;
    } on ApiFailure catch (e) {
      lastError = e.message;
      return null;
    }
  }

  // ── Realtime (Laravel Reverb) ──────────────────────────────────────────

  void _wirePresence() {
    if (_presenceWired) return;
    _presenceWired = true;
    const channel = 'presence-online';

    _rt.on(channel, 'pusher_internal:subscription_succeeded', (data) {
      try {
        final hash = ((data['presence'] as Map?)?['hash'] as Map?) ?? const {};
        _onlineUserIds
          ..clear()
          ..addAll(hash.keys.map((k) => k.toString()));
        notifyListeners();
      } catch (_) {}
    });
    _rt.on(channel, 'pusher_internal:member_added', (data) {
      final id = data['user_id']?.toString();
      if (id != null && _onlineUserIds.add(id)) notifyListeners();
    });
    _rt.on(channel, 'pusher_internal:member_removed', (data) {
      final id = data['user_id']?.toString();
      if (id != null && _onlineUserIds.remove(id)) notifyListeners();
    });

    unawaited(_rt.subscribePresence(channel));
  }

  void _wireConversationChannel(String conversationId) {
    if (_wiredChannels.contains(conversationId)) return;
    _wiredChannels.add(conversationId);
    final channel = 'private-conversation.$conversationId';

    _rt.on(channel, 'message.created', (data) {
      final message = messageFromJson(data);
      final current = _messages[conversationId]?.data;
      if (current != null && !current.any((m) => m.id == message.id)) {
        _messages[conversationId] =
            LoadState<List<ChatMessage>>.success([...current, message]);
      }
      _bumpConversationWithMessage(conversationId, message);
      notifyListeners();
    });

    _rt.on(channel, 'message.read', (_) {
      final current = _messages[conversationId]?.data;
      if (current == null) return;
      _messages[conversationId] = LoadState<List<ChatMessage>>.success(
        current
            .map((m) => ChatMessage(
                  id: m.id,
                  senderId: m.senderId,
                  content: m.content,
                  type: m.type,
                  timestamp: m.timestamp,
                  isRead: true,
                  isSaved: m.isSaved,
                ))
            .toList(),
      );
      notifyListeners();
    });

    _rt.on(channel, 'user.typing', (data) {
      _setTypingLocally(conversationId, data['is_typing'] == true);
    });

    unawaited(_rt.subscribePrivate(channel));
  }

  void _wireStoryChannel(String storyItemId) {
    if (_wiredStoryChannels.contains(storyItemId)) return;
    _wiredStoryChannels.add(storyItemId);
    final channel = 'private-story.$storyItemId';

    _rt.on(channel, 'reply.created', (data) {
      try {
        final comment = storyCommentFromJson(data);
        final current = _storyReplies[storyItemId]?.data ?? <dynamic>[];
        if (!current.any((c) => (c as dynamic).id == comment.id)) {
          _storyReplies[storyItemId] = LoadState<List<dynamic>>.success([...current, comment]);
          notifyListeners();
        }
      } catch (_) {}
    });

    unawaited(_rt.subscribePrivate(channel));
  }

  void _bumpConversationWithMessage(String conversationId, ChatMessage message) {
    final list = _conversations.data;
    if (list == null) return;
    Conversation? updated;
    final rest = <Conversation>[];
    for (final c in list) {
      if (c.id == conversationId) {
        updated = Conversation(
          id: c.id,
          type: c.type,
          participant: c.participant,
          lastMessage: message,
          unreadCount: c.unreadCount,
          isPinned: c.isPinned,
          isMuted: c.isMuted,
          isTyping: false,
          isGroup: c.isGroup,
          groupName: c.groupName,
          members: c.members,
        );
      } else {
        rest.add(c);
      }
    }
    if (updated != null) {
      _conversations = LoadState<List<Conversation>>.success([updated, ...rest]);
    }
  }

  void _setTypingLocally(String conversationId, bool typing) {
    final list = _conversations.data;
    if (list != null) {
      _conversations = LoadState<List<Conversation>>.success(list.map((c) {
        if (c.id != conversationId) return c;
        return Conversation(
          id: c.id,
          type: c.type,
          participant: c.participant,
          lastMessage: c.lastMessage,
          unreadCount: c.unreadCount,
          isPinned: c.isPinned,
          isMuted: c.isMuted,
          isTyping: typing,
          isGroup: c.isGroup,
          groupName: c.groupName,
          members: c.members,
        );
      }).toList());
    }
    _typingTimers[conversationId]?.cancel();
    if (typing) {
      _typingTimers[conversationId] = Timer(const Duration(seconds: 6), () {
        _setTypingLocally(conversationId, false);
      });
    }
    notifyListeners();
  }

  @override
  void dispose() {
    for (final t in _typingTimers.values) {
      t.cancel();
    }
    super.dispose();
  }
}
