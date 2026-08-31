import 'dart:io';

import 'package:dio/dio.dart' show FormData, MultipartFile;

import '../core/api_failure.dart';
import '../core/json_mappers.dart';
import '../models/account.dart';
import '../models/user.dart';
import '../services/api_service.dart';

/// Security, privacy, notifications, phone verification and contact
/// discovery.
///
/// BACKEND CONTRACT (bearer auth on every route):
///   POST /settings/password { current_password, new_password }
///   POST /settings/2fa/enable  -> { secret, otpauth_uri }
///   POST /settings/2fa/verify  { code } -> { verified, recovery_codes[] }
///   POST /settings/2fa/disable { password, code }
///   POST /auth/2fa/verify-login { pending_token, code|recovery_code } -> { token, user }
///   GET  /security/sessions -> [{ id, name, last_used_at, created_at, current }]
///   DELETE /security/sessions/{id}
///   GET  /security/login-history
///   GET  /security/suspicious-activity
///   POST /security/export-data -> { status, download_url }
///   POST /me/delete { password }
///   GET  /account/status -> { status, warning_count, suspension_reason, ... }
///   GET  /users/me/settings, PUT /users/me/settings  (privacy + appearance)
///   GET  /notifications/settings, PUT /notifications/settings
///   GET  /reports/me -> { user: [...], content: [...] }
///   POST /phone/send-code { phone }
///   POST /phone/verify-code { code }
///   POST /contacts/discover { hashes[] } -> [User]
class AccountRepository {
  final ApiService _api;

  AccountRepository({required ApiService api}) : _api = api;

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) =>
      guardApi(() => _api.post('/settings/password', data: {
            'current_password': currentPassword,
            'new_password': newPassword,
          }));

  Future<TwoFactorSetup> startTwoFactorSetup() => guardApi(() async {
        final res = await _api.post('/settings/2fa/enable');
        return TwoFactorSetup.fromJson(asMap(res.data));
      });

  Future<List<String>> confirmTwoFactorSetup(String code) => guardApi(() async {
        final res = await _api.post('/settings/2fa/verify', data: {'code': code});
        final codes = asMap(res.data)['recovery_codes'];
        return codes is List ? codes.map((e) => '$e').toList() : const [];
      });

  Future<void> disableTwoFactor({required String password, required String code}) =>
      guardApi(() => _api.post('/settings/2fa/disable', data: {
            'password': password,
            'code': code,
          }));

  Future<List<SecuritySession>> fetchSessions() => guardApi(() async {
        final res = await _api.get('/security/sessions');
        return asList(res.data).map(SecuritySession.fromJson).toList();
      });

  Future<void> revokeSession(String id) =>
      guardApi(() => _api.delete('/security/sessions/$id'));

  Future<String> exportData() => guardApi(() async {
        final res = await _api.post('/security/export-data');
        return asString(asMap(res.data)['download_url']);
      });

  Future<AccountStatus> fetchAccountStatus() => guardApi(() async {
        final res = await _api.get('/account/status');
        return AccountStatus.fromJson(asMap(res.data));
      });

  Future<PrivacySettings> fetchPrivacySettings() => guardApi(() async {
        final res = await _api.get('/users/me/settings');
        return PrivacySettings.fromJson(asMap(res.data));
      });

  Future<PrivacySettings> updatePrivacySettings(Map<String, dynamic> patch) =>
      guardApi(() async {
        final res = await _api.put('/users/me/settings', data: patch);
        return PrivacySettings.fromJson(asMap(res.data));
      });

  Future<NotificationSettings> fetchNotificationSettings() => guardApi(() async {
        final res = await _api.get('/notifications/settings');
        return NotificationSettings.fromJson(asMap(res.data));
      });

  Future<NotificationSettings> updateNotificationSettings(
    Map<String, dynamic> patch,
  ) =>
      guardApi(() async {
        final res = await _api.put('/notifications/settings', data: patch);
        return NotificationSettings.fromJson(asMap(res.data));
      });

  Future<List<MyReport>> fetchMyReports() => guardApi(() async {
        final res = await _api.get('/reports/me');
        final data = asMap(res.data);
        final combined = [
          ...asList(data['user']),
          ...asList(data['content']),
        ];
        combined.sort((a, b) => asString(b['created_at']).compareTo(asString(a['created_at'])));
        return combined.map(MyReport.fromJson).toList();
      });

  Future<void> sendPhoneCode(String phoneE164) =>
      guardApi(() => _api.post('/phone/send-code', data: {'phone': phoneE164}));

  Future<void> verifyPhoneCode(String code) =>
      guardApi(() => _api.post('/phone/verify-code', data: {'code': code}));

  Future<List<User>> discoverFriendsFromContacts(List<String> phoneHashes) =>
      guardApi(() async {
        final res = await _api.post('/contacts/discover', data: {'hashes': phoneHashes});
        return asList(res.data).map(userFromJson).toList();
      });

  Future<String> uploadAvatar(File file) => guardApi(() async {
        final form = FormData.fromMap({'file': await MultipartFile.fromFile(file.path)});
        final res = await _api.post('/users/me/avatar', data: form);
        return asString(asMap(res.data)['url']);
      });
}
