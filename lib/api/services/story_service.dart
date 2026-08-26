import '../api_client.dart';
import '../api_config.dart';
import '../api_response.dart';

/// Story Service
/// 
/// Handles stories and temporary content API calls
class StoryService {
  final ApiClient _client = ApiClient();
  
  /// Get all stories from friends
  Future<ApiResponse<List<Map<String, dynamic>>>> getStories({
    int page = 1,
    int perPage = 50,
  }) async {
    return await _client.get<List<Map<String, dynamic>>>(
      ApiConfig.storiesList,
      queryParameters: {
        'page': page,
        'per_page': perPage,
      },
      fromJson: (data) => data is List
          ? data.cast<Map<String, dynamic>>()
          : [data as Map<String, dynamic>],
    );
  }
  
  /// Get story by ID
  Future<ApiResponse<Map<String, dynamic>>> getStoryById(String storyId) async {
    return await _client.get(
      ApiConfig.getStoryById(storyId),
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }
  
  /// Create new story.
  ///
  /// NOTE: the backend `StoryController@store` currently accepts only
  /// caption/location/visibility/expires_in_hours and does NOT attach uploaded
  /// media to the story (no story_media link). We send the correct fields plus
  /// media_id/media_url so it works once the backend attaches media.
  Future<ApiResponse<Map<String, dynamic>>> createStory({
    required String mediaUrl,
    String type = 'image',
    String? mediaId,
    String? caption,
    String audience = 'friends',
    int duration = 24,
  }) async {
    return await _client.post(
      ApiConfig.createStory,
      data: {
        'caption': caption,
        'visibility': audience == 'friends' ? 'friends' : audience,
        'expires_in_hours': duration,
        // extra fields for media attachment (ignored until backend supports it)
        'media_url': mediaUrl,
        'media_id': mediaId,
        'type': type,
      },
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }
  
  /// Upload story media
  Future<ApiResponse<Map<String, dynamic>>> uploadStoryMedia(
    String filePath, {
    String type = 'image',
    void Function(int sent, int total)? onProgress,
  }) async {
    return await _client.uploadFile(
      ApiConfig.uploadMedia,
      filePath,
      fieldName: 'file',
      additionalData: {
        'purpose': 'story',
        'type': type,
      },
      fromJson: (data) => data as Map<String, dynamic>,
      onSendProgress: onProgress,
    );
  }
  
  /// Delete story
  Future<ApiResponse<void>> deleteStory(String storyId) async {
    return await _client.delete(ApiConfig.deleteStory(storyId));
  }
  
  /// Mark story as viewed
  Future<ApiResponse<void>> markStoryViewed(String storyId) async {
    return await _client.post(ApiConfig.markStoryViewed(storyId));
  }
  
  /// Get story viewers
  Future<ApiResponse<List<Map<String, dynamic>>>> getStoryViewers({
    required String storyId,
    int page = 1,
    int perPage = 50,
  }) async {
    return await _client.get<List<Map<String, dynamic>>>(
      ApiConfig.getStoryViewers(storyId),
      queryParameters: {
        'page': page,
        'per_page': perPage,
      },
      fromJson: (data) => data is List
          ? data.cast<Map<String, dynamic>>()
          : [data as Map<String, dynamic>],
    );
  }
}
