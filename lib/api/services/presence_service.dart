import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_config.dart';

/// PresenceService — sends periodic heartbeats to the Laravel backend so
/// friends see the user as online.  A single heartbeat lands every 45 s
/// while the app is in the foreground; a final `offline` call is fired
/// on sign-out or app-suspend.
///
/// The backend interprets any heartbeat within the last 90 s as "online",
/// anything within 30 min as "recently active", anything older as offline.
class PresenceService {
  static final PresenceService _i = PresenceService._();
  factory PresenceService() => _i;
  PresenceService._();

  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Accept': 'application/json'},
  ));

  Future<Map<String, String>> _auth() async {
    final t = (await SharedPreferences.getInstance()).getString('access_token') ?? '';
    return t.isEmpty ? {} : {'Authorization': 'Bearer $t'};
  }

  Future<void> heartbeat() async {
    try {
      await _dio.post('/presence/heartbeat',
          data: {},
          options: Options(headers: await _auth(), contentType: 'application/json'));
    } catch (_) {/* best-effort */}
  }

  Future<void> offline() async {
    try {
      await _dio.post('/presence/offline',
          data: {},
          options: Options(headers: await _auth(), contentType: 'application/json'));
    } catch (_) {}
  }

  Future<List<Map<String, dynamic>>> bulk(List<int> userIds) async {
    try {
      final res = await _dio.get('/presence',
          queryParameters: {'user_ids': userIds.join(',')},
          options: Options(headers: await _auth()));
      return List<Map<String, dynamic>>.from(res.data as List);
    } catch (_) {
      return const [];
    }
  }
}
