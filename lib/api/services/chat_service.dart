import '../api_client.dart';
import '../api_config.dart';
import '../api_response.dart';

/// Chat Service
/// 
/// Handles chat and messaging API calls
class ChatService {
  final ApiClient _client = ApiClient();
  
  /// Get all chats for current user
  Future<ApiResponse<List<Map<String, dynamic>>>> getChats({
    int page = 1,
    int perPage = 50,
  }) async {
    return await _client.get<List<Map<String, dynamic>>>(
      ApiConfig.chatsList,
      queryParameters: {
        'page': page,
        'per_page': perPage,
      },
      fromJson: (data) => data is List 
          ? data.cast<Map<String, dynamic>>()
          : [data as Map<String, dynamic>],
    );
  }
  
  /// Get chat by ID
  Future<ApiResponse<Map<String, dynamic>>> getChatById(String chatId) async {
    return await _client.get(
      ApiConfig.getChatById(chatId),
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }
  
  /// Get messages for a chat
  Future<ApiResponse<List<Map<String, dynamic>>>> getChatMessages({
    required String chatId,
    int page = 1,
    int perPage = 50,
  }) async {
    return await _client.get<List<Map<String, dynamic>>>(
      ApiConfig.getChatMessages(chatId),
      queryParameters: {
        'page': page,
        'per_page': perPage,
      },
      fromJson: (data) => data is List 
          ? data.cast<Map<String, dynamic>>()
          : [data as Map<String, dynamic>],
    );
  }
  
  /// Send message
  Future<ApiResponse<Map<String, dynamic>>> sendMessage({
    required String chatId,
    required String content,
    String type = 'text',
    String? mediaUrl,
    String? replyToId,
    String expiration = 'keep_forever',
    int? viewDuration,
  }) async {
    return await _client.post(
      ApiConfig.sendMessage(chatId),
      data: {
        'content': content,
        'type': type,
        'media_url': mediaUrl,
        'reply_to_id': replyToId,
        'expiration': expiration,
        'view_duration': viewDuration,
      },
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }
  
  /// Edit message
  Future<ApiResponse<Map<String, dynamic>>> editMessage({
    required String messageId,
    required String content,
  }) async {
    return await _client.patch(
      ApiConfig.editMessage(messageId),
      data: {'content': content},
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }
  
  /// Delete message
  Future<ApiResponse<void>> deleteMessage(String messageId) async {
    return await _client.delete(ApiConfig.deleteMessage(messageId));
  }
  
  /// React to message
  Future<ApiResponse<Map<String, dynamic>>> reactToMessage({
    required String messageId,
    required String emoji,
  }) async {
    return await _client.post(
      ApiConfig.reactToMessage(messageId),
      data: {'emoji': emoji},
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }
  
  /// Mark chat as read
  Future<ApiResponse<void>> markAsRead(String chatId) async {
    return await _client.post(ApiConfig.markAsRead(chatId));
  }
  
  /// Upload media for message
  Future<ApiResponse<Map<String, dynamic>>> uploadMedia(
    String filePath, {
    String type = 'image',
    void Function(int sent, int total)? onProgress,
  }) async {
    return await _client.uploadFile(
      ApiConfig.uploadMedia,
      filePath,
      fieldName: 'file',
      additionalData: {'purpose': 'chat', 'type': type},
      fromJson: (data) => data as Map<String, dynamic>,
      onSendProgress: onProgress,
    );
  }
  
  /// Search messages in a chat
  Future<ApiResponse<List<Map<String, dynamic>>>> searchMessages({
    required String query,
    String? chatId,
    int page = 1,
    int perPage = 20,
  }) async {
    return await _client.get<List<Map<String, dynamic>>>(
      ApiConfig.searchMessages,
      queryParameters: {
        'query': query,
        if (chatId != null) 'chat_id': chatId,
        'page': page,
        'per_page': perPage,
      },
      fromJson: (data) => data is List 
          ? data.cast<Map<String, dynamic>>()
          : [data as Map<String, dynamic>],
    );
  }
}
