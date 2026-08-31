import '../core/api_failure.dart';
import '../core/json_mappers.dart';
import '../models/map_friend.dart';
import '../services/api_service.dart';

/// Friend locations for the map.
///
/// BACKEND CONTRACT (bearer auth on every route):
///   GET  /map/friends      -> [{ user, latitude, longitude, updated_at }]
///   POST /map/location     { latitude, longitude, accuracy? }
///   POST /map/ghost-mode   { enabled: bool }
///
/// Ghost Mode must also be enforced server-side: while it is enabled the
/// backend should discard location writes and omit the user from every other
/// user's `/map/friends` response.
class MapRepository {
  final ApiService _api;

  MapRepository({required ApiService api}) : _api = api;

  Future<List<MapFriend>> fetchFriendLocations() => guardApi(() async {
        final res = await _api.get('/map/friends');
        return asList(res.data).map(mapFriendFromJson).toList();
      });

  Future<void> shareLocation({
    required double latitude,
    required double longitude,
    double? accuracy,
  }) =>
      guardApi(() => _api.post('/map/location', data: {
            'latitude': latitude,
            'longitude': longitude,
            if (accuracy != null) 'accuracy': accuracy,
          }));

  Future<void> setGhostMode(bool enabled) =>
      guardApi(() => _api.post('/map/ghost-mode', data: {'enabled': enabled}));
}
