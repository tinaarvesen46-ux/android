import '../models/user.dart';
import 'api_service.dart';

class AuthResult {
  final bool success;
  final String? error;
  final User? user;
  final String? token;

  const AuthResult({required this.success, this.error, this.user, this.token});
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
      final token = data['token'] as String;
      await _api.setToken(token);
      return AuthResult(
        success: true,
        token: token,
        user: User(
          id: data['user']['id'].toString(),
          username: data['user']['username'] as String,
          displayName: data['user']['display_name'] as String,
          avatarUrl: data['user']['avatar_url'] as String?,
        ),
      );
    } catch (e) {
      return AuthResult(
        success: false,
        error: _parseError(e),
      );
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
