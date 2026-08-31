import 'package:flutter/foundation.dart';

import '../core/api_failure.dart';
import '../core/load_state.dart';
import '../models/social.dart';
import '../models/user.dart';
import '../repositories/social_repository.dart';

class SocialProvider extends ChangeNotifier {
  final SocialRepository _social;

  SocialProvider({required SocialRepository socialRepository})
      : _social = socialRepository;

  LoadState<User> _me = LoadState<User>.idle();
  LoadState<List<User>> _friends = LoadState<List<User>>.idle();
  LoadState<List<FriendRequest>> _requests =
      LoadState<List<FriendRequest>>.idle();
  LoadState<List<AppNotification>> _notifications =
      LoadState<List<AppNotification>>.idle();
  LoadState<List<User>> _searchResults = LoadState<List<User>>.idle();
  LoadState<List<User>> _blocked = LoadState<List<User>>.idle();
  LoadState<List<Achievement>> _achievements =
      LoadState<List<Achievement>>.idle();
  LoadState<UserProfile> _profile = LoadState<UserProfile>.idle();

  LoadState<User> get me => _me;

  LoadState<List<User>> get friends => _friends;

  LoadState<List<FriendRequest>> get requests => _requests;

  LoadState<List<AppNotification>> get notifications => _notifications;

  LoadState<List<User>> get searchResults => _searchResults;

  LoadState<List<User>> get blocked => _blocked;

  LoadState<List<Achievement>> get achievements => _achievements;

  LoadState<UserProfile> get profile => _profile;

  Future<void> loadMe() async {
    _me = LoadState<User>.loading();
    notifyListeners();
    try {
      _me = LoadState<User>.success(await _social.fetchMe());
    } on ApiFailure catch (e) {
      _me = LoadState<User>.error(e.message);
    }
    notifyListeners();
  }

  Future<void> loadFriends() async {
    _friends = LoadState<List<User>>.loading();
    notifyListeners();
    try {
      _friends = listState(await _social.fetchFriends());
    } on ApiFailure catch (e) {
      _friends = LoadState<List<User>>.error(e.message);
    }
    notifyListeners();
  }

  Future<void> loadRequests() async {
    _requests = LoadState<List<FriendRequest>>.loading();
    notifyListeners();
    try {
      _requests = listState(await _social.fetchRequests());
    } on ApiFailure catch (e) {
      _requests = LoadState<List<FriendRequest>>.error(e.message);
    }
    notifyListeners();
  }

  Future<void> loadNotifications() async {
    _notifications = LoadState<List<AppNotification>>.loading();
    notifyListeners();
    try {
      _notifications = listState(await _social.fetchNotifications());
    } on ApiFailure catch (e) {
      _notifications = LoadState<List<AppNotification>>.error(e.message);
    }
    notifyListeners();
  }

  Future<void> loadBlocked() async {
    _blocked = LoadState<List<User>>.loading();
    notifyListeners();
    try {
      _blocked = listState(await _social.fetchBlocked());
    } on ApiFailure catch (e) {
      _blocked = LoadState<List<User>>.error(e.message);
    }
    notifyListeners();
  }

  Future<void> loadAchievements() async {
    _achievements = LoadState<List<Achievement>>.loading();
    notifyListeners();
    try {
      _achievements = listState(await _social.fetchAchievements());
    } on ApiFailure catch (e) {
      _achievements = LoadState<List<Achievement>>.error(e.message);
    }
    notifyListeners();
  }

  Future<void> loadProfile(String userId) async {
    _profile = LoadState<UserProfile>.loading();
    notifyListeners();
    try {
      _profile =
          LoadState<UserProfile>.success(await _social.fetchProfile(userId));
    } on ApiFailure catch (e) {
      _profile = LoadState<UserProfile>.error(e.message);
    }
    notifyListeners();
  }

  Future<void> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      _searchResults = LoadState<List<User>>.idle();
      notifyListeners();
      return;
    }
    _searchResults = LoadState<List<User>>.loading();
    notifyListeners();
    try {
      _searchResults = listState(await _social.search(trimmed));
    } on ApiFailure catch (e) {
      _searchResults = LoadState<List<User>>.error(e.message);
    }
    notifyListeners();
  }

  Future<String?> sendFriendRequest(String userId) =>
      _mutate(() => _social.sendFriendRequest(userId), profileId: userId);

  Future<String?> removeFriend(String userId) async {
    final error =
        await _mutate(() => _social.removeFriend(userId), profileId: userId);
    if (error == null) await loadFriends();
    return error;
  }

  Future<String?> blockUser(String userId) async {
    final error =
        await _mutate(() => _social.blockUser(userId), profileId: userId);
    if (error == null) await loadFriends();
    return error;
  }

  Future<String?> unblockUser(String userId) async {
    final error = await _mutate(() => _social.unblockUser(userId));
    if (error == null) await loadBlocked();
    return error;
  }

  Future<String?> acceptRequest(String requestId) async {
    final error = await _mutate(() => _social.acceptRequest(requestId));
    if (error == null) {
      await loadRequests();
      await loadFriends();
    }
    return error;
  }

  Future<String?> declineRequest(String requestId) async {
    final error = await _mutate(() => _social.declineRequest(requestId));
    if (error == null) await loadRequests();
    return error;
  }

  Future<String?> cancelRequest(String requestId) async {
    final error = await _mutate(() => _social.cancelRequest(requestId));
    if (error == null) await loadRequests();
    return error;
  }

  Future<String?> report({
    required String type,
    required String targetId,
    required String reason,
    String? description,
  }) =>
      _mutate(() => _social.report(
            type: type,
            targetId: targetId,
            reason: reason,
            description: description,
          ));

  Future<String?> markNotificationsRead() async {
    final error = await _mutate(_social.markNotificationsRead);
    if (error == null) await loadNotifications();
    return error;
  }

  Future<String?> updateProfile({
    required String displayName,
    required String username,
    required String bio,
  }) async {
    try {
      final user = await _social.updateProfile(
        displayName: displayName,
        username: username,
        bio: bio,
      );
      _me = LoadState<User>.success(user);
      notifyListeners();
      return null;
    } on ApiFailure catch (e) {
      return e.message;
    }
  }

  Future<String?> saveAvatarConfig(Map<String, String> config) =>
      _mutate(() => _social.saveAvatarConfig(config));

  Future<String?> deleteAccount(String password) =>
      _mutate(() => _social.deleteAccount(password));

  Future<String?> _mutate(
    Future<void> Function() action, {
    String? profileId,
  }) async {
    try {
      await action();
      if (profileId != null) await loadProfile(profileId);
      return null;
    } on ApiFailure catch (e) {
      return e.message;
    }
  }
}
