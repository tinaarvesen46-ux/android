import 'package:shared_preferences/shared_preferences.dart';
import '../api_client.dart';
import '../api_config.dart';
import '../api_response.dart';
import '../../models/user_model.dart';

/// Authentication Service
/// 
/// Handles all authentication-related API calls
class AuthService {
  final ApiClient _client = ApiClient();
  
  /// Login with email/username and password
  Future<ApiResponse<Map<String, dynamic>>> login({
    required String identifier, // email or username
    required String password,
    String? deviceName,
  }) async {
    return await _client.post(
      ApiConfig.login,
      data: {
        // Backend requires `email`; we also send `identifier`/`username`
        // so either an email or username in the field works.
        'email': identifier,
        'identifier': identifier,
        'username': identifier,
        'password': password,
        'device_name': deviceName ?? 'mobile',
      },
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }
  
  /// Register new user
  Future<ApiResponse<Map<String, dynamic>>> register({
    required String username,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String displayName,
    required DateTime dateOfBirth,
    String? firstName,
    String? lastName,
    bool acceptTerms = true,
  }) async {
    return await _client.post(
      ApiConfig.register,
      data: {
        'username': username,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'display_name': displayName,
        'first_name': firstName,
        'last_name': lastName,
        'birthday': dateOfBirth.toIso8601String().substring(0, 10),
        'accept_terms': acceptTerms,
      },
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }
  
  /// Logout current user
  Future<ApiResponse<void>> logout() async {
    final response = await _client.post(ApiConfig.logout);
    if (response.isSuccess) {
      await _client.clearTokens();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
    }
    return response;
  }
  
  /// Refresh access token
  Future<ApiResponse<Map<String, dynamic>>> refreshToken() async {
    final refreshToken = await _client.getRefreshToken();
    if (refreshToken == null) {
      return ApiResponse.error(message: 'No refresh token available');
    }
    
    return await _client.post(
      ApiConfig.refreshToken,
      data: {'refresh_token': refreshToken},
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }
  
  /// Forgot password - Send reset email
  Future<ApiResponse<void>> forgotPassword({
    required String email,
  }) async {
    return await _client.post(
      ApiConfig.forgotPassword,
      data: {'email': email},
    );
  }
  
  /// Reset password with token
  Future<ApiResponse<void>> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    return await _client.post(
      ApiConfig.resetPassword,
      data: {
        'email': email,
        'token': token,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
  }
  
  /// Verify email with token
  Future<ApiResponse<void>> verifyEmail({
    required String token,
  }) async {
    return await _client.post(
      ApiConfig.verifyEmail,
      data: {'token': token},
    );
  }
  
  /// Resend email verification
  Future<ApiResponse<void>> resendVerification({
    required String email,
  }) async {
    return await _client.post(
      ApiConfig.resendVerification,
      data: {'email': email},
    );
  }
  
  /// Get current authenticated user
  Future<ApiResponse<UserModel>> getCurrentUser() async {
    return await _client.get(
      ApiConfig.currentUser,
      fromJson: (data) => UserModel.fromJson(data),
    );
  }
  
  /// Save tokens after successful login/register.
  /// Persists to secure storage (used by ApiClient/Dio) AND SharedPreferences
  /// (used by LensService, presence, location, streak & media services).
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _client.setTokens(accessToken, refreshToken);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
  }
  
  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await _client.getAccessToken();
    return token != null;
  }
}
