import '../core/json_mappers.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthResult {
  final bool success;
  final String? error;
  final User? user;
  final String? token;
  final String? twoFactorPendingToken;

  const AuthResult({
    required this.success,
    this.error,
    this.user,
    this.token,
    this.twoFactorPendingToken,
  });
}

class AuthService {
  final ApiService _api;

  AuthService({required ApiService api}) : _api = api;

  Future<AuthResult> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final response = await _api.post('/auth/login', data: {
        'identifier': identifier,
        'password': password,
      });
      final data = response.data as Map<String, dynamic>;
      if (data['two_factor_required'] == true) {
        return AuthResult(
          success: false,
          twoFactorPendingToken: data['pending_token'] as String?,
        );
      }
      final token = data['token'] as String;
      await _api.setToken(token);
      return AuthResult(
        success: true,
        token: token,
        user: userFromJson(asMap(data['user'])),
      );
    } catch (e) {
      return AuthResult(
        success: false,
        error: _parseError(e),
      );
    }
  }

  Future<AuthResult> verifyTwoFactorLogin({
    required String pendingToken,
    String? code,
    String? recoveryCode,
  }) async {
    try {
      final response = await _api.post('/auth/2fa/verify-login', data: {
        'pending_token': pendingToken,
        if (code != null) 'code': code,
        if (recoveryCode != null) 'recovery_code': recoveryCode,
      });
      final data = response.data as Map<String, dynamic>;
      final token = data['token'] as String;
      await _api.setToken(token);
      return AuthResult(
        success: true,
        token: token,
        user: userFromJson(asMap(data['user'])),
      );
    } catch (e) {
      return AuthResult(success: false, error: _parseError(e));
    }
  }

  Future<AuthResult> register({
    required String name,
    required String username,
    required String email,
    required String password,
    required String birthday,
  }) async {
    try {
      final response = await _api.post('/auth/register', data: {
        'name': name,
        'username': username,
        'email': email,
        'password': password,
        'birthday': birthday,
      });
      final data = response.data as Map<String, dynamic>;
      return AuthResult(
        success: true,
        token: data['token'] as String?,
      );
    } catch (e) {
      return AuthResult(success: false, error: _parseError(e));
    }
  }

  Future<void> logout() async {
    try {
      await _api.post('/auth/logout');
    } finally {
      await _api.clearToken();
    }
  }

  /// Clears the active session locally WITHOUT revoking the token on the
  /// server — used when the user chooses to save the account for quick
  /// switching. The real Sanctum token stays valid for a future
  /// [switchToken] call.
  Future<void> logoutKeepingToken() => _api.clearToken();

  Future<String?> currentToken() => _api.getToken();

  Future<void> switchToken(String token) => _api.setToken(token);

  Future<bool> isAuthenticated() async {
    final token = await _api.getToken();
    return token != null;
  }

  String _parseError(dynamic e) {
    if (e is Exception) {
      return 'Connection failed. Please check your internet and try again.';
    }
    return 'An unexpected error occurred.';
  }
}
