import '../api_client.dart';
import '../api_config.dart';
import '../api_response.dart';

/// SwiftSnapV32Service — wires the verified v31 backend endpoints:
/// public stories (Discover), creator earnings, achievements, device
/// registration (push), avatar, and calling. All against the live VPS.
class SwiftSnapV32Service {
  final ApiClient _client = ApiClient();

  // ── Discover: public stories ──
  Future<ApiResponse<Map<String, dynamic>>> publicStories({int page = 1, int perPage = 20}) {
    return _client.get<Map<String, dynamic>>(
      ApiConfig.publicStories,
      queryParameters: {'page': page, 'per_page': perPage},
      fromJson: (data) => data is Map<String, dynamic>
          ? data
          : {'data': (data as List).cast<Map<String, dynamic>>()},
    );
  }

  // ── Creator earnings ──
  Future<ApiResponse<Map<String, dynamic>>> creatorEarnings() {
    return _client.get<Map<String, dynamic>>(
      ApiConfig.creatorEarnings,
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> creatorTransactions({int page = 1}) {
    return _client.get<Map<String, dynamic>>(
      ApiConfig.creatorTransactions,
      queryParameters: {'page': page},
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  // ── Achievements ──
  Future<ApiResponse<List<Map<String, dynamic>>>> achievements() {
    return _client.get<List<Map<String, dynamic>>>(
      ApiConfig.achievements,
      fromJson: (data) => data is List
          ? data.cast<Map<String, dynamic>>()
          : <Map<String, dynamic>>[],
    );
  }

  // ── Device registration (push; VPS is source of truth) ──
  Future<ApiResponse<Map<String, dynamic>>> registerDevice({
    required String deviceId,
    required String pushToken,
    String platform = 'fcm',
    String deviceType = 'android',
    String? deviceName,
    String? osVersion,
    String? appVersion,
  }) {
    return _client.post(
      ApiConfig.deviceRegister,
      data: {
        'device_id': deviceId,
        'push_token': pushToken,
        'platform': platform,
        'device_type': deviceType,
        if (deviceName != null) 'device_name': deviceName,
        if (osVersion != null) 'os_version': osVersion,
        if (appVersion != null) 'app_version': appVersion,
      },
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> unregisterDevice(String deviceId) {
    return _client.post(
      ApiConfig.deviceUnregister,
      data: {'device_id': deviceId},
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  // ── Avatar ──
  Future<ApiResponse<Map<String, dynamic>>> getAvatar() {
    return _client.get<Map<String, dynamic>>(
      ApiConfig.avatar,
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> updateAvatar(Map<String, String> config) {
    return _client.put(
      ApiConfig.avatar,
      data: {'config': config},
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> resetAvatar() {
    return _client.post(
      ApiConfig.avatarReset,
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  // ── Calling ──
  Future<ApiResponse<Map<String, dynamic>>> iceServers() {
    return _client.get<Map<String, dynamic>>(
      ApiConfig.callIceServers,
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> initiateCall({
    required int calleeId,
    String type = 'audio',
    int? conversationId,
  }) {
    return _client.post(
      ApiConfig.callInitiate,
      data: {
        'callee_id': calleeId,
        'type': type,
        if (conversationId != null) 'conversation_id': conversationId,
      },
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> acceptCall(String uuid) =>
      _client.post(ApiConfig.callAccept(uuid), fromJson: (d) => d as Map<String, dynamic>);
  Future<ApiResponse<Map<String, dynamic>>> declineCall(String uuid) =>
      _client.post(ApiConfig.callDecline(uuid), fromJson: (d) => d as Map<String, dynamic>);
  Future<ApiResponse<Map<String, dynamic>>> endCall(String uuid) =>
      _client.post(ApiConfig.callEnd(uuid), fromJson: (d) => d as Map<String, dynamic>);

  Future<ApiResponse<Map<String, dynamic>>> sendCallSignal(
      String uuid, String kind, Map<String, dynamic> data) {
    return _client.post(
      ApiConfig.callSignal(uuid),
      data: {'kind': kind, 'data': data},
      fromJson: (d) => d as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> callHistory({int page = 1}) {
    return _client.get<Map<String, dynamic>>(
      ApiConfig.callsList,
      queryParameters: {'page': page},
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }
}
