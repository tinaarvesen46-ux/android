import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_config.dart';

/// StreakRestoreService — Snapchat-style paid streak recovery client
/// (Swift+ only, 1 per rolling 30 days, backend-enforced).
class StreakRestoreService {
  static final StreakRestoreService _i = StreakRestoreService._();
  factory StreakRestoreService() => _i;
  StreakRestoreService._();

  final Dio _dio = Dio(BaseOptions(baseUrl: ApiConfig.apiBaseUrl, headers: {'Accept': 'application/json'}));

  Future<Map<String, String>> _auth() async {
    final t = (await SharedPreferences.getInstance()).getString('access_token') ?? '';
    return t.isEmpty ? {} : {'Authorization': 'Bearer $t'};
  }

  Future<Map<String, dynamic>?> eligibility(int partnerId) async {
    try {
      final res = await _dio.get('/streaks/restore/eligibility',
          queryParameters: {'partner_id': partnerId},
          options: Options(headers: await _auth()));
      return Map<String, dynamic>.from(res.data as Map);
    } catch (_) { return null; }
  }

  Future<Map<String, dynamic>?> restore(int partnerId) async {
    try {
      final res = await _dio.post('/streaks/restore',
          data: {'partner_id': partnerId},
          options: Options(headers: await _auth(), contentType: 'application/json'));
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      return {'error': code == 402 ? 'swift_plus_required_or_used' : (code == 410 ? 'window_closed' : 'failed'),
              'message': e.response?.data?['message']};
    } catch (_) { return null; }
  }
}
