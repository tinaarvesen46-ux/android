import 'package:meta/meta.dart';
import 'api_service.dart';

/// Minimal push-device registration service.
///
/// This only encapsulates the contract to register/unregister a device token
/// with the backend. Actual
/// OS-level token acquisition (FCM/APNs) is intentionally left to the app
/// integrator because Firebase setup is environment-specific.
class PushService {
  final ApiService _api;
  PushService({required ApiService api}) : _api = api;

  Future<void> registerDevice({
    required String deviceId,
    required String pushToken,
    required String platform,
    String? deviceType,
    String? appVersion,
  }) async {
    try {
      await _api.post('/devices/register', data: {
        'device_id': deviceId,
        'push_token': pushToken,
        'platform': platform,
        if (deviceType != null) 'device_type': deviceType,
        if (appVersion != null) 'app_version': appVersion,
      });
    } catch (_) {}
  }

  Future<void> unregisterDevice(String deviceId) async {
    try {
      await _api.post('/devices/unregister', data: {'device_id': deviceId});
    } catch (_) {}
  }
}
