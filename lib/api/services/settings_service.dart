import '../api_client.dart';
import '../api_config.dart';
import '../api_response.dart';

/// Settings Service
/// 
/// Handles settings-related API calls
class SettingsService {
  final ApiClient _client = ApiClient();
  
  /// Get privacy settings
  Future<ApiResponse<Map<String, dynamic>>> getPrivacySettings() async {
    return await _client.get(
      ApiConfig.privacySettings,
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }
  
  /// Update privacy settings
  Future<ApiResponse<Map<String, dynamic>>> updatePrivacySettings(
    Map<String, dynamic> settings,
  ) async {
    return await _client.put(
      ApiConfig.privacySettings,
      data: settings,
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }
  
  /// Get security settings
  Future<ApiResponse<Map<String, dynamic>>> getSecuritySettings() async {
    return await _client.get(
      ApiConfig.securitySettings,
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }
  
  /// Update security settings
  Future<ApiResponse<Map<String, dynamic>>> updateSecuritySettings(
    Map<String, dynamic> settings,
  ) async {
    return await _client.patch(
      ApiConfig.securitySettings,
      data: settings,
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }
  
  /// Get notification settings
  Future<ApiResponse<Map<String, dynamic>>> getNotificationSettings() async {
    return await _client.get(
      ApiConfig.notificationsSettings,
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }
  
  /// Update notification settings
  Future<ApiResponse<Map<String, dynamic>>> updateNotificationSettings(
    Map<String, dynamic> settings,
  ) async {
    return await _client.put(
      ApiConfig.notificationsSettings,
      data: settings,
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }
  
  /// Get appearance settings
  Future<ApiResponse<Map<String, dynamic>>> getAppearanceSettings() async {
    return await _client.get(
      ApiConfig.appearanceSettings,
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }
  
  /// Update appearance settings
  Future<ApiResponse<Map<String, dynamic>>> updateAppearanceSettings(
    Map<String, dynamic> settings,
  ) async {
    return await _client.put(
      ApiConfig.appearanceSettings,
      data: settings,
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }
  
  /// Change password
  Future<ApiResponse<void>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    return await _client.post(
      ApiConfig.changePassword,
      data: {
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': newPasswordConfirmation,
      },
    );
  }
  
  /// Enable Two-Factor Authentication
  Future<ApiResponse<Map<String, dynamic>>> enable2FA() async {
    return await _client.post(
      ApiConfig.enable2FA,
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }
  
  /// Verify Two-Factor Authentication
  Future<ApiResponse<Map<String, dynamic>>> verify2FA({
    required String code,
  }) async {
    return await _client.post(
      ApiConfig.verify2FA,
      data: {'code': code},
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }
  
  /// Disable Two-Factor Authentication
  Future<ApiResponse<void>> disable2FA({
    required String password,
  }) async {
    return await _client.post(
      ApiConfig.disable2FA,
      data: {'password': password},
    );
  }
  
  /// Get login history
  Future<ApiResponse<List<Map<String, dynamic>>>> getLoginHistory({
    int page = 1,
    int perPage = 20,
  }) async {
    return await _client.get<List<Map<String, dynamic>>>(
      ApiConfig.loginHistory,
      queryParameters: {
        'page': page,
        'per_page': perPage,
      },
      fromJson: (data) => data is List
          ? data.cast<Map<String, dynamic>>()
          : [data as Map<String, dynamic>],
    );
  }
  
  /// Get active sessions
  Future<ApiResponse<List<Map<String, dynamic>>>> getActiveSessions() async {
    return await _client.get<List<Map<String, dynamic>>>(
      ApiConfig.activeSessions,
      fromJson: (data) => data is List
          ? data.cast<Map<String, dynamic>>()
          : [data as Map<String, dynamic>],
    );
  }
  
  /// Revoke session
  Future<ApiResponse<void>> revokeSession(String sessionId) async {
    return await _client.delete(ApiConfig.revokeSession(sessionId));
  }
  
  /// Get suspicious activity
  Future<ApiResponse<List<Map<String, dynamic>>>> getSuspiciousActivity({
    int page = 1,
    int perPage = 20,
  }) async {
    return await _client.get<List<Map<String, dynamic>>>(
      ApiConfig.suspiciousActivity,
      queryParameters: {
        'page': page,
        'per_page': perPage,
      },
      fromJson: (data) => data is List
          ? data.cast<Map<String, dynamic>>()
          : [data as Map<String, dynamic>],
    );
  }
  
  /// Export user data (GDPR)
  Future<ApiResponse<Map<String, dynamic>>> exportData() async {
    return await _client.post(
      ApiConfig.exportData,
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }
  
  /// Delete account — backend route is POST /security/delete-account (requires password).
  Future<ApiResponse<void>> deleteAccount({
    required String password,
    String? reason,
  }) async {
    return await _client.post(
      ApiConfig.deleteAccount,
      data: {
        'password': password,
        if (reason != null) 'reason': reason,
      },
    );
  }

  /// Current 2FA status from users/me (`two_factor_enabled`).
  Future<ApiResponse<bool>> getTwoFactorStatus() async {
    return await _client.get<bool>(
      ApiConfig.currentUser,
      fromJson: (data) {
        final v = (data is Map) ? data['two_factor_enabled'] : null;
        return v == 1 || v == true;
      },
    );
  }
}
