import 'dart:async';

import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../repositories/social_repository.dart';
import '../services/auth_service.dart';
import '../services/realtime_service.dart';
import '../services/saved_accounts_store.dart';
import 'social_provider.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final RealtimeService _realtime;
  final SocialRepository _social;
  final SavedAccountsStore _savedAccounts = SavedAccountsStore();
  final SocialProvider? _socialProvider;

  AuthProvider({
    required AuthService authService,
    required RealtimeService realtimeService,
    required SocialRepository socialRepository,
    SocialProvider? socialProvider,
  })  : _authService = authService,
        _realtime = realtimeService,
        _social = socialRepository,
        _socialProvider = socialProvider {
    unawaited(loadSavedAccounts());
  }

  List<SavedAccount> _savedAccountsList = const [];
  List<SavedAccount> get savedAccounts => _savedAccountsList;

  Future<void> loadSavedAccounts() async {
    _savedAccountsList = await _savedAccounts.load();
    notifyListeners();
  }

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
      final channel = 'private-user.${_currentUser!.id}';
      unawaited(_realtime.subscribePrivate(channel));
      _realtime.on(channel, 'AvatarUpdated', (payload) {
        try {
          final avatarUrl = payload['avatar_url'] as String?;
          _currentUser = _currentUser!.copyWith(
            avatarUrl: avatarUrl ?? _currentUser!.avatarUrl,
            avatarRenderUrl: _currentUser!.avatarRenderUrl,
          );
          // Also refresh SocialProvider state so UI consumers of SocialProvider.me update
          unawaited(_socialProvider?.loadMe());
          notifyListeners();
        } catch (_) {}
      });
      _realtime.on(channel, 'ProfileHeaderUpdated', (payload) async {
        try {
          final user = await _social.fetchMe();
          _currentUser = user;
          unawaited(_socialProvider?.loadMe());
          notifyListeners();
        } catch (_) {}
      });
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
      final channel = 'private-user.${_currentUser!.id}';
      unawaited(_realtime.subscribePrivate(channel));
      _realtime.on(channel, 'AvatarUpdated', (payload) {
        try {
          final avatarUrl = payload['avatar_url'] as String?;
          _currentUser = _currentUser!.copyWith(
            avatarUrl: avatarUrl ?? _currentUser!.avatarUrl,
            avatarRenderUrl: _currentUser!.avatarRenderUrl,
          );
          unawaited(_socialProvider?.loadMe());
          notifyListeners();
        } catch (_) {}
      });
      _realtime.on(channel, 'ProfileHeaderUpdated', (payload) async {
        try {
          final user = await _social.fetchMe();
          _currentUser = user;
          unawaited(_socialProvider?.loadMe());
          notifyListeners();
        } catch (_) {}
      });
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

  Future<void> logout({bool remember = false}) async {
    final user = _currentUser;
    if (remember && user != null) {
      final token = await _authService.currentToken();
      if (token != null) {
        await _savedAccounts.upsert(SavedAccount(
          userId: user.id,
          username: user.username,
          displayName: user.displayName,
          avatarUrl: user.avatarUrl,
          token: token,
        ));
      }
      await _authService.logoutKeepingToken();
    } else {
      await _authService.logout();
    }
    _realtime.disconnect();
    _currentUser = null;
    notifyListeners();
    unawaited(loadSavedAccounts());
  }

  /// Switches straight into a previously saved account using its real
  /// stored Sanctum token — validated live against `/me` rather than
  /// trusted blindly. Removes the account from the saved list if the
  /// token was revoked (e.g. by a password change) so a stale entry never
  /// lingers.
  Future<bool> switchToSavedAccount(SavedAccount account) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    await _authService.switchToken(account.token);
    try {
      final user = await _social.fetchMe();
      _currentUser = user;
      _isLoading = false;
      unawaited(_realtime.connect());
      final channel = 'private-user.${_currentUser!.id}';
      unawaited(_realtime.subscribePrivate(channel));
      _realtime.on(channel, 'AvatarUpdated', (payload) {
        try {
          final avatarUrl = payload['avatar_url'] as String?;
          _currentUser = _currentUser!.copyWith(
            avatarUrl: avatarUrl ?? _currentUser!.avatarUrl,
            avatarRenderUrl: _currentUser!.avatarRenderUrl,
          );
          unawaited(_socialProvider?.loadMe());
          notifyListeners();
        } catch (_) {}
      });
      notifyListeners();
      return true;
    } catch (_) {
      await _authService.logoutKeepingToken();
      await _savedAccounts.remove(account.userId);
      await loadSavedAccounts();
      _isLoading = false;
      _error = 'That session has expired. Please sign in again.';
      notifyListeners();
      return false;
    }
  }

  Future<void> removeSavedAccount(String userId) async {
    await _savedAccounts.remove(userId);
    await loadSavedAccounts();
  }

  /// Called on app start when a stored session token already exists —
  /// hydrates the real current user (so 2FA/role state is accurate
  /// immediately) and reconnects realtime.
  Future<void> hydrateFromExistingSession() async {
    try {
      _currentUser = await _social.fetchMe();
      unawaited(_realtime.connect());
      final channel = 'private-user.${_currentUser!.id}';
      unawaited(_realtime.subscribePrivate(channel));
      _realtime.on(channel, 'AvatarUpdated', (payload) {
        if (_currentUser == null) return;
        final avatarUrl = payload['avatar_url'] as String?;
        _currentUser = _currentUser!.copyWith(
          avatarUrl: avatarUrl ?? _currentUser!.avatarUrl,
          avatarRenderUrl: _currentUser!.avatarRenderUrl,
        );
        unawaited(_socialProvider?.loadMe());
        notifyListeners();
      });
      _realtime.on(channel, 'ProfileHeaderUpdated', (payload) async {
        try {
          _currentUser = await _social.fetchMe();
          unawaited(_socialProvider?.loadMe());
          notifyListeners();
        } catch (_) {}
      });
      notifyListeners();
    } catch (_) {
      // Token turned out to be invalid; leave currentUser null and let the
      // next authenticated call surface the real 401 to the user.
    }
  }

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
