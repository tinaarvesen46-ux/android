import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_config.dart';

/// LocationService — SwiftMap client with strict privacy semantics.
///
/// Never publishes coordinates unless the user has explicitly enabled a
/// visibility other than `off` or `ghost` on the server.  All uploads are
/// rate-limited server-side to 60/min.
class LocationService {
  static final LocationService _i = LocationService._();
  factory LocationService() => _i;
  LocationService._();

  final Dio _dio = Dio(BaseOptions(baseUrl: ApiConfig.apiBaseUrl, headers: {'Accept': 'application/json'}));

  Future<Map<String, String>> _auth() async {
    final t = (await SharedPreferences.getInstance()).getString('access_token') ?? '';
    return t.isEmpty ? {} : {'Authorization': 'Bearer $t'};
  }

  Future<Map<String, dynamic>?> settings() async {
    try {
      final res = await _dio.get('/location/settings', options: Options(headers: await _auth()));
      return Map<String, dynamic>.from(res.data as Map);
    } catch (_) { return null; }
  }

  Future<Map<String, dynamic>?> updateSettings({String? visibility, List<int>? selectedFriendIds, String? swiftmapAppearance}) async {
    try {
      final body = <String, dynamic>{};
      if (visibility != null) body['visibility'] = visibility;
      if (selectedFriendIds != null) body['selected_friend_ids'] = selectedFriendIds;
      if (swiftmapAppearance != null) body['swiftmap_appearance'] = swiftmapAppearance;
      final res = await _dio.put('/location/settings', data: body, options: Options(headers: await _auth(), contentType: 'application/json'));
      return Map<String, dynamic>.from(res.data as Map);
    } catch (_) { return null; }
  }

  Future<bool> push({required double lat, required double lng, int? accuracyM, int expiresInMinutes = 480}) async {
    try {
      await _dio.post('/location/update', data: {
        'latitude': lat,
        'longitude': lng,
        if (accuracyM != null) 'accuracy_m': accuracyM,
        'expires_in_minutes': expiresInMinutes,
      }, options: Options(headers: await _auth(), contentType: 'application/json'));
      return true;
    } catch (_) { return false; }
  }

  Future<void> stop() async {
    try {
      await _dio.post('/location/stop', data: {}, options: Options(headers: await _auth(), contentType: 'application/json'));
    } catch (_) {}
  }

  Future<List<Map<String, dynamic>>> friends() async {
    try {
      final res = await _dio.get('/location/friends', options: Options(headers: await _auth()));
      return List<Map<String, dynamic>>.from(res.data as List);
    } catch (_) { return const []; }
  }

  /// Full list of my friends (not just the ones sharing on the map).  Used
  /// by the Selected Friend Picker so I can pick anyone in my friend list.
  Future<List<Map<String, dynamic>>> friendList() async {
    try {
      final res = await _dio.get('/friends', options: Options(headers: await _auth()));
      return List<Map<String, dynamic>>.from(res.data as List);
    } catch (_) { return const []; }
  }

  /// Friends I've most recently swapped messages with, top N.  Used for
  /// the "Recent snap partners" quick-pick strip in the picker.
  Future<List<Map<String, dynamic>>> recentPartners({int limit = 8}) async {
    try {
      final res = await _dio.get('/friends/recent-partners',
          queryParameters: {'limit': limit},
          options: Options(headers: await _auth()));
      return List<Map<String, dynamic>>.from(res.data as List);
    } catch (_) { return const []; }
  }
}
