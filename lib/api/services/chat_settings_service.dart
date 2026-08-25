import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_config.dart';

/// ChatSettingsService — per-conversation prefs: mute, notification sound,
/// pinning (with server-side Swift+ tier enforcement).
class ChatSettingsService {
  static final ChatSettingsService _i = ChatSettingsService._();
  factory ChatSettingsService() => _i;
  ChatSettingsService._();

  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.apiBaseUrl,
    headers: {'Accept': 'application/json'},
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  ));

  Future<Map<String, String>> _auth() async {
    final t = (await SharedPreferences.getInstance()).getString('access_token') ?? '';
    return t.isEmpty ? {} : {'Authorization': 'Bearer $t'};
  }

  Future<Map<String, dynamic>?> show(String chatId) async {
    try {
      final res = await _dio.get('/chats/$chatId/settings', options: Options(headers: await _auth()));
      return Map<String, dynamic>.from(res.data as Map);
    } catch (_) { return null; }
  }

  Future<Map<String, dynamic>?> update(String chatId, {bool? isMuted, DateTime? mutedUntil, String? sound}) async {
    try {
      final body = <String, dynamic>{};
      if (isMuted != null)     body['is_muted'] = isMuted;
      if (mutedUntil != null)  body['muted_until'] = mutedUntil.toIso8601String();
      if (sound != null)       body['notification_sound'] = sound;
      final res = await _dio.put('/chats/$chatId/settings',
          data: body,
          options: Options(headers: await _auth(), contentType: 'application/json'));
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      // 402 = Swift+ required; expose so UI can prompt the upgrade
      return {'error': e.response?.statusCode == 402 ? 'swift_plus_required' : 'failed', 'message': e.response?.data?['message']};
    } catch (_) { return null; }
  }

  Future<Map<String, dynamic>?> pin(String chatId) async {
    try {
      final res = await _dio.post('/chats/$chatId/pin', data: {}, options: Options(headers: await _auth(), contentType: 'application/json'));
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      return {'error': e.response?.statusCode == 402 ? 'pin_limit_reached' : 'failed', 'message': e.response?.data?['message']};
    } catch (_) { return null; }
  }

  Future<Map<String, dynamic>?> unpin(String chatId) async {
    try {
      final res = await _dio.delete('/chats/$chatId/pin', options: Options(headers: await _auth()));
      return Map<String, dynamic>.from(res.data as Map);
    } catch (_) { return null; }
  }
}
