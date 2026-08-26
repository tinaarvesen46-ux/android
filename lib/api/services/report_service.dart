import '../api_client.dart';
import '../api_config.dart';
import '../api_response.dart';

/// ReportService — real Laravel `reports/*` endpoints for user-facing reports.
class ReportService {
  final ApiClient _client = ApiClient();
  static final String _base = ApiConfig.apiBaseUrl;

  Future<ApiResponse<Map<String, dynamic>>> reportUser({
    required String userId,
    required String reason,
    String? details,
  }) async {
    return _client.post(
      '$_base/reports/user',
      data: {'reported_id': int.tryParse(userId) ?? userId, 'reason': reason, if (details != null) 'description': details},
      fromJson: (d) => d as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> reportContent({
    required String contentType,
    required String contentId,
    required String reason,
    String? details,
  }) async {
    return _client.post(
      '$_base/reports/content',
      data: {
        'content_type': contentType,
        'content_id': int.tryParse(contentId) ?? contentId,
        'reason': reason,
        if (details != null) 'description': details,
      },
      fromJson: (d) => d as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> myReports() async {
    return _client.get<List<Map<String, dynamic>>>(
      '$_base/reports/me',
      fromJson: (d) {
        // Backend returns { user: [...], content: [...] } — merge both.
        if (d is Map) {
          final out = <Map<String, dynamic>>[];
          for (final k in ['user', 'content']) {
            if (d[k] is List) {
              out.addAll((d[k] as List).cast<Map<String, dynamic>>().map((e) => {...e, 'kind': k}));
            }
          }
          return out;
        }
        return d is List ? d.cast<Map<String, dynamic>>() : <Map<String, dynamic>>[];
      },
    );
  }
}
