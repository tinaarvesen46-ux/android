import 'dart:async';

import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/realtime_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final RealtimeService _realtime;

  AuthProvider({required AuthService authService, required RealtimeService realtimeService})
      : _authService = authService,
        _realtime = realtimeService;

  User? _currentUser;
  User? get currentUser => _currentUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  String? _pendingTwoFactorToken;
  String? get pendingTwoFactorToken => _pendingTwoFactorToken;

  bool get isAuthenticated => _currentUser != null;

  Future<bool> login({
    required String identifier,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    _pendingTwoFactorToken = null;
    notifyListeners();

    final result = await _authService.login(
      identifier: identifier,
      password: password,
    );

    _isLoading = false;
    if (result.success && result.user != null) {
      _currentUser = result.user;
      unawaited(_realtime.connect());
      notifyListeners();
      return true;
    }
    if (result.twoFactorPendingToken != null) {
      _pendingTwoFactorToken = result.twoFactorPendingToken;
      notifyListeners();
      return false;
    }
    _error = result.error;
    notifyListeners();
    return false;
  }

  Future<bool> verifyTwoFactor({String? code, String? recoveryCode}) async {
    final pending = _pendingTwoFactorToken;
    if (pending == null) return false;
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _authService.verifyTwoFactorLogin(
      pendingToken: pending,
      code: code,
      recoveryCode: recoveryCode,
    );

    _isLoading = false;
    if (result.success && result.user != null) {
      _currentUser = result.user;
      _pendingTwoFactorToken = null;
      unawaited(_realtime.connect());
      notifyListeners();
      return true;
    }
    _error = result.error;
    notifyListeners();
    return false;
  }

  Future<bool> register({
    required String name,
    required String username,
    required String email,
    required String password,
    required String birthday,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _authService.register(
      name: name,
      username: username,
      email: email,
      password: password,
      birthday: birthday,
    );

    _isLoading = false;
    if (result.success) {
      notifyListeners();
      return true;
    }
    _error = result.error;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    await _authService.logout();
    _realtime.disconnect();
    _currentUser = null;
    notifyListeners();
  }

  /// Called on app start when a stored session token already exists.
  void resumeRealtimeSession() => unawaited(_realtime.connect());

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Keeps the in-memory current user's 2FA flag in sync immediately after
  /// a real enable/disable response, so re-opening the 2FA screen shows the
  /// correct initial state without waiting for the next `/me` refetch.
  void setTwoFactorEnabled(bool enabled) {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(twoFactorEnabled: enabled);
    notifyListeners();
  }
}
