import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../core/api_failure.dart';
import '../core/load_state.dart';
import '../models/map_friend.dart';
import '../repositories/map_repository.dart';

enum LocationAccess { unknown, granted, denied, deniedForever, serviceDisabled }

class MapProvider extends ChangeNotifier {
  final MapRepository _map;

  MapProvider({required MapRepository mapRepository}) : _map = mapRepository;

  LocationAccess _access = LocationAccess.unknown;
  Position? _position;
  bool _isLocating = false;
  LoadState<List<MapFriend>> _friends = LoadState<List<MapFriend>>.idle();

  LocationAccess get access => _access;

  Position? get position => _position;

  bool get isLocating => _isLocating;

  LoadState<List<MapFriend>> get friends => _friends;

  /// Resolves the device position. The result is only sent to the backend when
  /// [shareWithBackend] is true, which Ghost Mode turns off.
  Future<void> requestLocation({required bool shareWithBackend}) async {
    _isLocating = true;
    notifyListeners();

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _access = LocationAccess.serviceDisabled;
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        _access = LocationAccess.deniedForever;
        return;
      }
      if (permission == LocationPermission.denied) {
        _access = LocationAccess.denied;
        return;
      }

      _access = LocationAccess.granted;
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
      _position = position;

      if (shareWithBackend) {
        try {
          await _map.shareLocation(
            latitude: position.latitude,
            longitude: position.longitude,
            accuracy: position.accuracy,
          );
        } on ApiFailure {
          // The position is still shown locally; sharing retries on refresh.
        }
      }
    } catch (_) {
      _access = LocationAccess.denied;
    } finally {
      _isLocating = false;
      notifyListeners();
    }
  }

  Future<void> loadFriends() async {
    _friends = LoadState<List<MapFriend>>.loading();
    notifyListeners();
    try {
      _friends = listState(await _map.fetchFriendLocations());
    } on ApiFailure catch (e) {
      _friends = LoadState<List<MapFriend>>.error(e.message);
    }
    notifyListeners();
  }

  Future<String?> setGhostMode(bool enabled) async {
    try {
      await _map.setGhostMode(enabled);
      return null;
    } on ApiFailure catch (e) {
      return e.message;
    }
  }

  Future<void> openSystemSettings() async {
    if (_access == LocationAccess.serviceDisabled) {
      await Geolocator.openLocationSettings();
      return;
    }
    await Geolocator.openAppSettings();
  }
}
