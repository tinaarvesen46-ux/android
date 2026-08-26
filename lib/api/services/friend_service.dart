import '../api_client.dart';
import '../api_config.dart';
import '../api_response.dart';
import '../../models/user_model.dart';

/// Friend Service
/// 
/// Handles friends and friend requests API calls
class FriendService {
  final ApiClient _client = ApiClient();
  
  /// Get friends list
  Future<ApiResponse<List<UserModel>>> getFriends({
    int page = 1,
    int perPage = 50,
  }) async {
    return await _client.get<List<UserModel>>(
      ApiConfig.friendsList,
      queryParameters: {
        'page': page,
        'per_page': perPage,
      },
      fromJson: (data) => data is List
          ? data.map((item) => UserModel.fromJson(item)).toList()
          : [UserModel.fromJson(data)],
    );
  }
  
  /// Get friend requests
  Future<ApiResponse<List<Map<String, dynamic>>>> getFriendRequests({
    String type = 'received', // received, sent, all
    int page = 1,
    int perPage = 50,
  }) async {
    return await _client.get<List<Map<String, dynamic>>>(
      ApiConfig.friendRequestsList,
      queryParameters: {
        'type': type,
        'page': page,
        'per_page': perPage,
      },
      fromJson: (data) {
        // Backend returns { incoming: [...], outgoing: [...] }.
        // We surface INCOMING (received) requests here.
        if (data is Map && data['incoming'] is List) {
          return (data['incoming'] as List).cast<Map<String, dynamic>>();
        }
        if (data is List) return data.cast<Map<String, dynamic>>();
        return <Map<String, dynamic>>[];
      },
    );
  }

  /// Send friend request
  Future<ApiResponse<Map<String, dynamic>>> sendFriendRequest(String userId) async {
    return await _client.post(
      ApiConfig.sendFriendRequest(userId),
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }
  
  /// Accept friend request
  Future<ApiResponse<Map<String, dynamic>>> acceptFriendRequest(String requestId) async {
    return await _client.post(
      ApiConfig.acceptFriendRequest(requestId),
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }
  
  /// Reject friend request
  Future<ApiResponse<void>> rejectFriendRequest(String requestId) async {
    return await _client.post(ApiConfig.rejectFriendRequest(requestId));
  }
  
  /// Cancel friend request (sent by user)
  Future<ApiResponse<void>> cancelFriendRequest(String requestId) async {
    return await _client.delete(ApiConfig.cancelFriendRequest(requestId));
  }
  
  /// Unfriend user
  Future<ApiResponse<void>> unfriend(String userId) async {
    return await _client.delete(ApiConfig.unfriend(userId));
  }
}
