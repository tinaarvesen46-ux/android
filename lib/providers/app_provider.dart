import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/chat_model.dart';
import '../models/story_model.dart';
import '../models/friend_request_model.dart';
import '../api/services/chat_service.dart';

class AppProvider extends ChangeNotifier {
  int _currentIndex = 0;
  bool _isOnline = true;
  bool _isLoggedIn = false;
  UserModel? _currentUser;
  List<ChatModel> _chats = [];
  List<StoryModel> _stories = [];
  List<UserModel> _friends = [];
  List<FriendRequestModel> _friendRequests = [];
  Map<String, List<MessageModel>> _chatMessages = {};

  int get currentIndex => _currentIndex;
  bool get isOnline => _isOnline;
  bool get isLoggedIn => _isLoggedIn;
  UserModel? get currentUser => _currentUser;
  List<ChatModel> get chats => _chats;
  List<StoryModel> get stories => _stories;
  List<UserModel> get friends => _friends;
  List<FriendRequestModel> get friendRequests => _friendRequests
      .where((r) => r.receiver.id == _currentUser?.id && r.status == FriendRequestStatus.pending)
      .toList();
  int get friendRequestsCount => friendRequests.length;

  AppProvider();

  /// Call this after a successful API login to populate state and show HomeScreen.
  void login(UserModel user) {
    _currentUser = user;
    _isLoggedIn = true;
    _currentIndex = 0;
    _initializeMockData();
    notifyListeners();
  }

  /// Call this on logout — clears all state and routes back to LoginScreen.
  void logout() {
    _isLoggedIn = false;
    _currentUser = null;
    _chats = [];
    _stories = [];
    _friends = [];
    _friendRequests = [];
    _chatMessages = {};
    _currentIndex = 0;
    _isOnline = true;
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
  
  void _initializeMockData() {
    _currentUser = UserModel(
      id: 'user_001',
      username: 'alex_vibe',
      displayName: 'Alex Chen',
      email: 'alex@swiftsnap.com',
      avatarUrl: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=400&h=400&fit=crop',
      bio: 'Creator • Photographer • Adventure Seeker 📸',
      isVerified: true,
      isOnline: true,
      accountStatus: AccountStatus.creator,
      privacyLevel: PrivacyLevel.friendsOnly,
      staffRole: StaffRole.administrator,
    );
    
    _friends = [
      UserModel(
        id: 'user_002',
        username: 'sarah_creates',
        displayName: 'Sarah Miller',
        avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
        isVerified: true,
        isOnline: true,
        accountStatus: AccountStatus.creator,
      ),
      UserModel(
        id: 'user_003',
        username: 'mike_photo',
        displayName: 'Mike Johnson',
        avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200',
        isVerified: false,
        isOnline: true,
        accountStatus: AccountStatus.normal,
      ),
      UserModel(
        id: 'user_004',
        username: 'emma_vibes',
        displayName: 'Emma Wilson',
        avatarUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200',
        isVerified: true,
        isOnline: false,
        lastSeen: DateTime.now().subtract(const Duration(hours: 2)),
        accountStatus: AccountStatus.verified,
      ),
      UserModel(
        id: 'user_005',
        username: 'james_art',
        displayName: 'James Brown',
        avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200',
        isVerified: false,
        isOnline: false,
        lastSeen: DateTime.now().subtract(const Duration(minutes: 30)),
        accountStatus: AccountStatus.normal,
      ),
      UserModel(
        id: 'user_006',
        username: 'lily_music',
        displayName: 'Lily Zhang',
        avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
        isVerified: true,
        isOnline: true,
        accountStatus: AccountStatus.creator,
      ),
      UserModel(
        id: 'user_007',
        username: 'david_tech',
        displayName: 'David Kim',
        avatarUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=200',
        isVerified: false,
        isOnline: true,
        accountStatus: AccountStatus.normal,
      ),
      UserModel(
        id: 'user_008',
        username: 'nina_style',
        displayName: 'Nina Garcia',
        avatarUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200',
        isVerified: true,
        isOnline: false,
        lastSeen: DateTime.now().subtract(const Duration(days: 1)),
        accountStatus: AccountStatus.verified,
      ),
    ];
    
    _chats = [
      ChatModel(
        id: 'chat_001',
        participant: _friends[0],
        lastMessage: MessageModel(
          id: 'msg_001',
          senderId: _friends[0].id,
          content: 'Just uploaded a new photo set! 📸',
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          type: MessageType.text,
          isRead: false,
        ),
        isPinned: true,
        unreadCount: 3,
      ),
      ChatModel(
        id: 'chat_002',
        participant: _friends[1],
        lastMessage: MessageModel(
          id: 'msg_002',
          senderId: 'user_001',
          content: 'That sunset was amazing!',
          timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
          type: MessageType.text,
          isRead: true,
        ),
        isPinned: true,
        unreadCount: 0,
      ),
      ChatModel(
        id: 'chat_003',
        participant: _friends[2],
        lastMessage: MessageModel(
          id: 'msg_003',
          senderId: _friends[2].id,
          content: '📷 Sent a photo',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          type: MessageType.image,
          isRead: false,
        ),
        isPinned: false,
        unreadCount: 1,
      ),
      ChatModel(
        id: 'chat_004',
        participant: _friends[3],
        lastMessage: MessageModel(
          id: 'msg_004',
          senderId: _friends[3].id,
          content: 'Are you coming to the event tonight?',
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
          type: MessageType.text,
          isRead: true,
        ),
        isPinned: false,
        unreadCount: 0,
      ),
      ChatModel(
        id: 'chat_005',
        participant: _friends[4],
        lastMessage: MessageModel(
          id: 'msg_005',
          senderId: 'user_001',
          content: '🎵 Voice note',
          timestamp: DateTime.now().subtract(const Duration(hours: 5)),
          type: MessageType.voice,
          isRead: true,
        ),
        isPinned: false,
        unreadCount: 0,
      ),
      ChatModel(
        id: 'chat_006',
        participant: _friends[5],
        lastMessage: MessageModel(
          id: 'msg_006',
          senderId: _friends[5].id,
          content: 'Check out this new feature!',
          timestamp: DateTime.now().subtract(const Duration(hours: 8)),
          type: MessageType.text,
          isRead: true,
        ),
        isPinned: false,
        unreadCount: 0,
      ),
      ChatModel(
        id: 'chat_007',
        participant: _friends[6],
        lastMessage: MessageModel(
          id: 'msg_007',
          senderId: _friends[6].id,
          content: 'Love your latest post! 🔥',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          type: MessageType.text,
          isRead: true,
        ),
        isPinned: false,
        unreadCount: 0,
      ),
    ];
    
    _stories = [
      StoryModel(
        id: 'story_001',
        user: _currentUser!,
        mediaUrl: 'https://images.unsplash.com/photo-1682687220742-aba13b6e50ba?w=600',
        type: StoryType.image,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        viewerCount: 156,
        isOwn: true,
      ),
      StoryModel(
        id: 'story_002',
        user: _friends[0],
        mediaUrl: 'https://images.unsplash.com/photo-1682687982501-1e58ab814714?w=600',
        type: StoryType.image,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        viewerCount: 234,
        hasUnviewed: true,
      ),
      StoryModel(
        id: 'story_003',
        user: _friends[4],
        mediaUrl: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=600',
        type: StoryType.image,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        viewerCount: 89,
        hasUnviewed: true,
      ),
      StoryModel(
        id: 'story_004',
        user: _friends[2],
        mediaUrl: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=600',
        type: StoryType.image,
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        viewerCount: 167,
        hasUnviewed: false,
      ),
      StoryModel(
        id: 'story_005',
        user: _friends[5],
        mediaUrl: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=600',
        type: StoryType.image,
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        viewerCount: 312,
        hasUnviewed: true,
      ),
      StoryModel(
        id: 'story_006',
        user: _friends[1],
        mediaUrl: 'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=600',
        type: StoryType.image,
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        viewerCount: 445,
        hasUnviewed: false,
      ),
    ];
    
    _friendRequests = [
      FriendRequestModel(
        id: 'req_001',
        sender: UserModel(
          id: 'user_009',
          username: 'sophie_design',
          displayName: 'Sophie Anderson',
          avatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200',
          isVerified: false,
          isOnline: true,
        ),
        receiver: _currentUser!,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        message: 'Hey! I love your content!',
      ),
      FriendRequestModel(
        id: 'req_002',
        sender: UserModel(
          id: 'user_010',
          username: 'alex_dev',
          displayName: 'Alex Rodriguez',
          avatarUrl: 'https://images.unsplash.com/photo-1527980965255-d3b416303d12?w=200',
          isVerified: true,
          isOnline: false,
          lastSeen: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        receiver: _currentUser!,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      FriendRequestModel(
        id: 'req_003',
        sender: UserModel(
          id: 'user_011',
          username: 'maya_photo',
          displayName: 'Maya Johnson',
          avatarUrl: 'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?w=200',
          isVerified: false,
          isOnline: true,
        ),
        receiver: _currentUser!,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        message: 'Would love to connect!',
      ),
    ];
    
    _initializeChatMessages();
    
    notifyListeners();
  }
  
  void _initializeChatMessages() {
    for (final chat in _chats) {
      final now = DateTime.now();
      _chatMessages[chat.id] = [
        MessageModel(
          id: '${chat.id}_m1',
          senderId: chat.participant.id,
          content: 'Hey! How are you doing? 👋',
          timestamp: now.subtract(const Duration(hours: 2)),
          isRead: true,
          status: MessageStatus.read,
        ),
        MessageModel(
          id: '${chat.id}_m2',
          senderId: _currentUser!.id,
          content: 'I\'m great! Just finished editing some photos',
          timestamp: now.subtract(const Duration(hours: 1, minutes: 55)),
          isRead: true,
          status: MessageStatus.read,
        ),
        MessageModel(
          id: '${chat.id}_m3',
          senderId: chat.participant.id,
          content: chat.lastMessage.content,
          timestamp: chat.lastMessage.timestamp,
          isRead: chat.lastMessage.isRead,
          status: chat.lastMessage.isRead ? MessageStatus.read : MessageStatus.delivered,
        ),
      ];
    }
  }
  
  List<MessageModel> getChatMessages(String chatId) {
    return _chatMessages[chatId] ?? [];
  }
  
  Future<void> sendMessage(String chatId, String content) async {
    final messages = _chatMessages[chatId] ?? [];
    // Optimistic local message with a temporary client-side id
    final tempId = 'temp_${DateTime.now().microsecondsSinceEpoch}';
    final newMessage = MessageModel(
      id: tempId,
      senderId: _currentUser!.id,
      content: content,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
    );

    messages.add(newMessage);
    _chatMessages[chatId] = messages;

    final chatIndex = _chats.indexWhere((c) => c.id == chatId);
    if (chatIndex != -1) {
      _chats[chatIndex] = _chats[chatIndex].copyWith(
        lastMessage: newMessage,
      );
      _chats.sort((a, b) {
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        return b.lastMessage.timestamp.compareTo(a.lastMessage.timestamp);
      });
    }
    notifyListeners();

    // Real network call to the Laravel backend so the LE audit log records every message.
    try {
      final res = await ChatService().sendMessage(
        chatId: chatId,
        content: content,
        type: 'text',
      );

      final idx = messages.indexWhere((m) => m.id == tempId);
      if (idx == -1) return;

      if (res.success && res.data != null) {
        final serverId = (res.data!['id'] ?? res.data!['uuid'] ?? tempId).toString();
        messages[idx] = messages[idx].copyWith(
          id: serverId,
          status: MessageStatus.sent,
        );
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
  
  void acceptFriendRequest(String requestId) {
    final index = _friendRequests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      final request = _friendRequests[index];
      _friendRequests[index] = request.copyWith(
        status: FriendRequestStatus.accepted,
      );
      
      if (!_friends.any((f) => f.id == request.sender.id)) {
        _friends.add(request.sender);
      }
      
      notifyListeners();
    }
  }
  
  void rejectFriendRequest(String requestId) {
    final index = _friendRequests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      _friendRequests[index] = _friendRequests[index].copyWith(
        status: FriendRequestStatus.rejected,
      );
      notifyListeners();
    }
  }
  
  void sendFriendRequest(UserModel user, {String? message}) {
    final request = FriendRequestModel(
      id: 'req_${DateTime.now().millisecondsSinceEpoch}',
      sender: _currentUser!,
      receiver: user,
      createdAt: DateTime.now(),
      message: message,
    );
    _friendRequests.add(request);
    notifyListeners();
  }
  
  void removeFriend(String userId) {
    _friends.removeWhere((f) => f.id == userId);
    notifyListeners();
  }

  /// Called by admin EditUserScreen to update any user in the local state.
  /// In production this becomes a call to AdminService.updateUser().
  void adminUpdateUser(UserModel updated) {
    // If the edited user is the currently logged-in user, update that too
    if (_currentUser?.id == updated.id) {
      _currentUser = updated;
    }
    // Update in friends list if present
    final fi = _friends.indexWhere((u) => u.id == updated.id);
    if (fi != -1) _friends[fi] = updated;
    notifyListeners();
  }
  
  void updateCurrentUser({
    UserModel? user,
    PrivacyLevel? privacyLevel,
  }) {
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
  
  void addStory(String mediaUrl, StoryType type) {
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
  
  void markStoryAsViewed(String storyId) {
    final index = _stories.indexWhere((s) => s.id == storyId);
    if (index != -1 && _stories[index].hasUnviewed) {
      _stories[index] = _stories[index].copyWith(hasUnviewed: false);
      notifyListeners();
    }
  }
  
  void markChatAsRead(String chatId) {
    final index = _chats.indexWhere((c) => c.id == chatId);
    if (index != -1) {
      _chats[index] = _chats[index].copyWith(unreadCount: 0);
      notifyListeners();
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
