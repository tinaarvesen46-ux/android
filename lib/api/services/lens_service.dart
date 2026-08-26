import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_config.dart';

/// LensService — SwiftSnap lens catalog + beauty presets client.
class LensService {
  static final LensService _i = LensService._();
  factory LensService() => _i;
  LensService._();

  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.apiBaseUrl,
    headers: {'Accept': 'application/json'},
  ));

  Future<Map<String, String>> _auth() async {
    final t = (await SharedPreferences.getInstance()).getString('access_token') ?? '';
    return t.isEmpty ? {} : {'Authorization': 'Bearer $t'};
  }

  Future<List<Map<String, dynamic>>> browse({String? category, String sort = 'popular', String? search}) async {
    try {
      final res = await _dio.get('/lenses',
          queryParameters: {
            if (category != null) 'category': category,
            'sort': sort,
            if (search != null) 'search': search,
          },
          options: Options(headers: await _auth()));
      final data = (res.data as Map)['data'] as List;
      return List<Map<String, dynamic>>.from(data);
    } catch (_) { return const []; }
  }

  Future<List<Map<String, dynamic>>> categories() async {
    try {
      final res = await _dio.get('/lenses/categories', options: Options(headers: await _auth()));
      return List<Map<String, dynamic>>.from(res.data as List);
    } catch (_) { return const []; }
  }

  Future<List<Map<String, dynamic>>> beautyPresets() async {
    try {
      final res = await _dio.get('/lenses/beauty-presets', options: Options(headers: await _auth()));
      return List<Map<String, dynamic>>.from(res.data as List);
    } catch (_) { return const []; }
  }

  Future<Map<String, dynamic>?> saveBeautySettings({String? preset, int? smooth, int? tan, int? glow, int? teeth, int? eye}) async {
    try {
      final res = await _dio.put('/lenses/beauty-settings', data: {
        if (preset != null) 'preset': preset,
        if (smooth != null) 'smooth': smooth,
        if (tan != null) 'tan': tan,
        if (glow != null) 'glow': glow,
        if (teeth != null) 'teeth': teeth,
        if (eye != null) 'eye': eye,
      }, options: Options(headers: await _auth(), contentType: 'application/json'));
      return Map<String, dynamic>.from(res.data as Map);
    } catch (_) { return null; }
  }

  Future<void> logUse(String lensId, {String mediaType = 'photo'}) async {
    try {
      await _dio.post('/lenses/$lensId/use', data: {'media_type': mediaType}, options: Options(headers: await _auth(), contentType: 'application/json'));
    } catch (_) {}
  }

  Future<bool> favorite(String lensId, bool on) async {
    try {
      if (on) {
        await _dio.post('/lenses/$lensId/favorite', data: {}, options: Options(headers: await _auth(), contentType: 'application/json'));
      } else {
        await _dio.delete('/lenses/$lensId/favorite', options: Options(headers: await _auth()));
      }
      return true;
    } catch (_) { return false; }
  }

  /// Tip a lens creator.  Backend writes a real `creator_revenue` row.
  /// Returns the parsed response `{ ok, amount, net_to_creator, currency }`
  /// or null on failure.
  Future<Map<String, dynamic>?> tip(String lensId, {required double amount, String? message, String currency = 'USD'}) async {
    try {
      final res = await _dio.post('/lenses/$lensId/tip',
          data: {
            'amount': amount,
            if (message != null && message.isNotEmpty) 'message': message,
            'currency': currency,
          },
          options: Options(headers: await _auth(), contentType: 'application/json'));
      return Map<String, dynamic>.from(res.data as Map);
    } catch (_) { return null; }
  }
}
