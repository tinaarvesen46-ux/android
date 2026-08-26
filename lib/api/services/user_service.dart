import '../api_client.dart';
import '../api_config.dart';
import '../api_response.dart';
import '../../models/user_model.dart';

/// User Service
/// 
/// Handles user profile and user-related API calls
class UserService {
  final ApiClient _client = ApiClient();
  
  /// Get user by ID
  Future<ApiResponse<UserModel>> getUserById(String userId) async {
    return await _client.get(
      ApiConfig.getUserById(userId),
      fromJson: (data) => UserModel.fromJson(data),
    );
  }
  
  /// Update current user profile
  Future<ApiResponse<UserModel>> updateProfile({
    String? displayName,
    String? bio,
    String? pronouns,
    String? location,
    String? privacyLevel,
  }) async {
    final data = <String, dynamic>{};
    if (displayName != null) data['display_name'] = displayName;
    if (bio != null) data['bio'] = bio;
    if (pronouns != null) data['pronouns'] = pronouns;
    if (location != null) data['location'] = location;
    if (privacyLevel != null) data['privacy_level'] = privacyLevel;
    
    return await _client.put(
      ApiConfig.updateProfile,
      data: data,
      fromJson: (data) => UserModel.fromJson(data),
    );
  }
  
  /// Upload avatar
  Future<ApiResponse<Map<String, dynamic>>> uploadAvatar(String filePath) async {
    return await _client.uploadFile(
      ApiConfig.uploadAvatar,
      filePath,
      fieldName: 'file',
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }
  
  /// Upload cover photo
  Future<ApiResponse<Map<String, dynamic>>> uploadCover(String filePath) async {
    return await _client.uploadFile(
      ApiConfig.uploadCover,
      filePath,
      fieldName: 'file',
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }
  
  /// Search users
  Future<ApiResponse<List<UserModel>>> searchUsers({
    required String query,
    int page = 1,
    int perPage = 20,
  }) async {
    return await _client.get<List<UserModel>>(
      ApiConfig.searchUsers,
      queryParameters: {
        'query': query,
        'page': page,
        'per_page': perPage,
      },
      fromJson: (data) => data is List 
          ? data.map((item) => UserModel.fromJson(item)).toList() as List<UserModel>
          : [UserModel.fromJson(data)],
    );
  }
  
  /// Get discover users
  Future<ApiResponse<List<UserModel>>> getDiscoverUsers({
    int page = 1,
    int perPage = 20,
  }) async {
    return await _client.get<List<UserModel>>(
      ApiConfig.discoverUsers,
      queryParameters: {
        'page': page,
        'per_page': perPage,
      },
      fromJson: (data) => data is List 
          ? data.map((item) => UserModel.fromJson(item)).toList() as List<UserModel>
          : [UserModel.fromJson(data)],
    );
  }
  
  /// Block user
  Future<ApiResponse<void>> blockUser(String userId) async {
    return await _client.post(ApiConfig.blockUser(userId));
  }
  
  /// Unblock user
  Future<ApiResponse<void>> unblockUser(String userId) async {
    return await _client.delete(ApiConfig.unblockUser(userId));
  }
  
  /// Get blocked users
  Future<ApiResponse<List<UserModel>>> getBlockedUsers({
    int page = 1,
    int perPage = 20,
  }) async {
    return await _client.get<List<UserModel>>(
      ApiConfig.blockedUsers,
      queryParameters: {
        'page': page,
        'per_page': perPage,
      },
      fromJson: (data) => data is List 
          ? data.map((item) => UserModel.fromJson(item)).toList() as List<UserModel>
          : [UserModel.fromJson(data)],
    );
  }
  
  /// Update user settings
  Future<ApiResponse<Map<String, dynamic>>> updateSettings(
    Map<String, dynamic> settings,
  ) async {
    return await _client.put(
      ApiConfig.userSettings,
      data: settings,
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }
}
