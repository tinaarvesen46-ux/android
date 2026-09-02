import '../core/api_failure.dart';
import '../core/json_mappers.dart';
import '../models/social.dart';
import '../models/user.dart';
import '../services/api_service.dart';

/// Identity, friendship, notifications, search, safety and achievements.
///
/// BACKEND CONTRACT (bearer auth on every route, JSON in / JSON out):
///   GET    /me                          -> user object
///   PUT    /me                          { display_name, username, bio }
///   POST   /me/avatar-config            { config: { part: value } }
///   POST   /me/delete                   { password }
///   GET    /users/{id}                  -> profile + relationship
///   GET    /users/search?q=             -> user list
///   GET    /friends                     -> user list
///   DELETE /friends/{userId}
///   GET    /friend-requests             -> requests with direction
///   POST   /friend-requests             { user_id }
///   POST   /friend-requests/{id}/accept
///   POST   /friend-requests/{id}/decline
///   DELETE /friend-requests/{id}
///   GET    /notifications               -> notification list
///   POST   /notifications/read-all
///   GET    /blocks                      -> user list
///   POST   /blocks                      { user_id }
///   DELETE /blocks/{userId}
///   POST   /reports                     { type, target_id, reason, description? }
///   GET    /achievements                -> achievements with progress
class SocialRepository {
  final ApiService _api;

  SocialRepository({required ApiService api}) : _api = api;

  Future<User> fetchMe() => guardApi(() async {
        final res = await _api.get('/me');
        return userFromJson(_single(res.data));
      });

  Future<User> updateProfile({
    required String displayName,
    required String username,
    required String bio,
    String? pronouns,
    String? birthday,
    String? location,
    String? website,
    String? phone,
    String? privacyLevel,
  }) =>
      guardApi(() async {
        final res = await _api.put('/me', data: {
          'display_name': displayName,
          'username': username,
          'bio': bio,
          if (pronouns != null) 'pronouns': pronouns,
          if (birthday != null) 'birthday': birthday,
          if (location != null) 'location': location,
          if (website != null) 'website': website,
          if (phone != null) 'phone': phone,
          if (privacyLevel != null) 'privacy_level': privacyLevel,
        });
        return userFromJson(_single(res.data));
      });

  Future<void> saveAvatarConfig(Map<String, String> config) =>
      guardApi(() => _api.put('/avatar', data: {'config': config}));

  Future<void> resetAvatar() => guardApi(() => _api.post('/avatar/reset'));

  Future<Map<String, dynamic>> fetchAvatarCatalog({String? q, String? category, int page = 1, int perPage = 40}) => guardApi(() async {
        final res = await _api.get('/avatar/catalog', queryParams: {
          if (q != null) 'q': q,
          if (category != null) 'category': category,
          'page': page,
          'per_page': perPage,
        });
        return asMap(res.data);
      });

  Future<Map<String, dynamic>?> fetchProfileHeader() => guardApi(() async {
        final res = await _api.get('/me/profile-header');
        return asMap(res.data);
      });

  Future<Map<String, dynamic>?> saveProfileHeader(Map<String, dynamic> config) => guardApi(() async {
        final res = await _api.put('/me/profile-header', data: config);
        return asMap(res.data);
      });

  Future<Map<String, dynamic>?> resetProfileHeader() => guardApi(() async {
        final res = await _api.post('/me/profile-header/reset');
        return asMap(res.data);
      });

  Future<void> deleteAccount(String password) =>
      guardApi(() => _api.post('/me/delete', data: {'password': password}));

  Future<UserProfile> fetchProfile(String userId) => guardApi(() async {
        final res = await _api.get('/users/$userId');
        return userProfileFromJson(_single(res.data));
      });

  Future<List<User>> search(String query) => guardApi(() async {
        final res = await _api.get('/users/search', queryParams: {'q': query});
        return asList(res.data).map(userFromJson).toList();
      });

  Future<List<User>> fetchFriends() => guardApi(() async {
        final res = await _api.get('/friends');
        return asList(res.data).map(userFromJson).toList();
      });

  Future<void> removeFriend(String userId) =>
      guardApi(() => _api.delete('/friends/$userId'));

  Future<List<FriendRequest>> fetchRequests() => guardApi(() async {
        final res = await _api.get('/friend-requests');
        return asList(res.data).map(friendRequestFromJson).toList();
      });

  Future<void> sendFriendRequest(String userId) =>
      guardApi(() => _api.post('/friend-requests', data: {'user_id': userId}));

  Future<void> acceptRequest(String requestId) =>
      guardApi(() => _api.post('/friend-requests/$requestId/accept'));

  Future<void> declineRequest(String requestId) =>
      guardApi(() => _api.post('/friend-requests/$requestId/decline'));

  Future<void> cancelRequest(String requestId) =>
      guardApi(() => _api.delete('/friend-requests/$requestId'));

  Future<List<AppNotification>> fetchNotifications() => guardApi(() async {
        final res = await _api.get('/notifications');
        return asList(res.data).map(notificationFromJson).toList();
      });

  Future<void> markNotificationsRead() =>
      guardApi(() => _api.post('/notifications/read-all'));

  Future<List<User>> fetchBlocked() => guardApi(() async {
        final res = await _api.get('/blocks');
        return asList(res.data).map(userFromJson).toList();
      });

  Future<void> blockUser(String userId) =>
      guardApi(() => _api.post('/blocks', data: {'user_id': userId}));

  Future<void> unblockUser(String userId) =>
      guardApi(() => _api.delete('/blocks/$userId'));

  Future<void> report({
    required String type,
    required String targetId,
    required String reason,
    String? description,
  }) =>
      guardApi(() => _api.post('/reports', data: {
            'type': type,
            'target_id': targetId,
            'reason': reason,
            if (description != null && description.isNotEmpty)
              'description': description,
          }));

  Future<List<Achievement>> fetchAchievements() => guardApi(() async {
        final res = await _api.get('/achievements');
        return asList(res.data).map(achievementFromJson).toList();
      });

      Future<void> createPublicProfile({
        required String displayName,
        required String username,
        String? bio,
      }) => guardApi(() => _api.post('/public-profiles', data: {
            'display_name': displayName,
            'username': username,
            if (bio != null) 'bio': bio,
          }));

      Future<void> updatePublicProfile({
        required String profileId,
        String? displayName,
        String? username,
        String? bio,
      }) => guardApi(() => _api.put('/public-profiles/$profileId', data: {
            if (displayName != null) 'display_name': displayName,
            if (username != null) 'username': username,
            if (bio != null) 'bio': bio,
          }));

      Future<void> disablePublicProfile(String profileId) =>
          guardApi(() => _api.delete('/public-profiles/$profileId'));

  Future<void> followUser(String userId) =>
      guardApi(() => _api.post('/users/$userId/follow'));

  Future<void> unfollowUser(String userId) =>
      guardApi(() => _api.post('/users/$userId/unfollow'));

  Future<List<User>> fetchFollowers(String userId) => guardApi(() async {
        final res = await _api.get('/users/$userId/followers');
        return asList(res.data).map(userFromJson).toList();
      });

  Future<List<User>> fetchFollowing(String userId) => guardApi(() async {
        final res = await _api.get('/users/$userId/following');
        return asList(res.data).map(userFromJson).toList();
      });

  Map<String, dynamic> _single(dynamic body) {
    if (body is Map && body['data'] != null) return asMap(body['data']);
    return asMap(body);
  }
}
