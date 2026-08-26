import '../api_client.dart';
import '../api_config.dart';
import '../api_response.dart';

/// NotificationService — real Laravel `notifications/*` endpoints.
/// Response item: {id,uuid,type,title,body,data,is_read,read_at,sent_at,created_at}
class NotificationService {
  final ApiClient _client = ApiClient();
  static final String _base = ApiConfig.apiBaseUrl;

  Future<ApiResponse<List<Map<String, dynamic>>>> getNotifications({int page = 1}) async {
    return _client.get<List<Map<String, dynamic>>>(
      '$_base/notifications',
      queryParameters: {'page': page},
      fromJson: (d) => d is List
          ? d.cast<Map<String, dynamic>>()
          : (d is Map && d['data'] is List
              ? (d['data'] as List).cast<Map<String, dynamic>>()
              : <Map<String, dynamic>>[]),
    );
  }

  Future<ApiResponse<void>> markRead(String id) async {
    return _client.post('$_base/notifications/$id/read');
  }

  Future<ApiResponse<void>> markAllRead() async {
    return _client.post('$_base/notifications/read-all');
  }

  Future<ApiResponse<Map<String, dynamic>>> getSettings() async {
    return _client.get(
      '$_base/notifications/settings',
      fromJson: (d) => d as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> updateSettings(Map<String, dynamic> prefs) async {
    return _client.put(
      '$_base/notifications/settings',
      data: prefs,
      fromJson: (d) => d as Map<String, dynamic>,
    );
  }
}
