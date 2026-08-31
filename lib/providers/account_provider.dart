import 'package:flutter/foundation.dart';

import '../core/api_failure.dart';
import '../core/load_state.dart';
import '../models/account.dart';
import '../models/user.dart';
import '../repositories/account_repository.dart';

class AccountProvider extends ChangeNotifier {
  final AccountRepository _account;

  AccountProvider({required AccountRepository accountRepository})
      : _account = accountRepository;

  LoadState<AccountStatus> _status = LoadState<AccountStatus>.idle();
  LoadState<PrivacySettings> _privacy = LoadState<PrivacySettings>.idle();
  LoadState<NotificationSettings> _notificationSettings =
      LoadState<NotificationSettings>.idle();
  LoadState<List<SecuritySession>> _sessions =
      LoadState<List<SecuritySession>>.idle();
  LoadState<List<MyReport>> _reports = LoadState<List<MyReport>>.idle();
  LoadState<List<User>> _contactMatches = LoadState<List<User>>.idle();

  LoadState<AccountStatus> get status => _status;
  LoadState<PrivacySettings> get privacy => _privacy;
  LoadState<NotificationSettings> get notificationSettings => _notificationSettings;
  LoadState<List<SecuritySession>> get sessions => _sessions;
  LoadState<List<MyReport>> get reports => _reports;
  LoadState<List<User>> get contactMatches => _contactMatches;

  Future<void> loadAccountStatus() async {
    _status = LoadState<AccountStatus>.loading();
    notifyListeners();
    try {
      _status = LoadState<AccountStatus>.success(await _account.fetchAccountStatus());
    } on ApiFailure catch (e) {
      _status = LoadState<AccountStatus>.error(e.message);
    }
    notifyListeners();
  }

  Future<void> loadPrivacySettings() async {
    _privacy = LoadState<PrivacySettings>.loading();
    notifyListeners();
    try {
      _privacy = LoadState<PrivacySettings>.success(await _account.fetchPrivacySettings());
    } on ApiFailure catch (e) {
      _privacy = LoadState<PrivacySettings>.error(e.message);
    }
    notifyListeners();
  }

  Future<String?> updatePrivacySettings(Map<String, dynamic> patch) async {
    try {
      _privacy = LoadState<PrivacySettings>.success(
        await _account.updatePrivacySettings(patch),
      );
      notifyListeners();
      return null;
    } on ApiFailure catch (e) {
      return e.message;
    }
  }

  Future<void> loadNotificationSettings() async {
    _notificationSettings = LoadState<NotificationSettings>.loading();
    notifyListeners();
    try {
      _notificationSettings =
          LoadState<NotificationSettings>.success(await _account.fetchNotificationSettings());
    } on ApiFailure catch (e) {
      _notificationSettings = LoadState<NotificationSettings>.error(e.message);
    }
    notifyListeners();
  }

  Future<String?> updateNotificationSettings(Map<String, dynamic> patch) async {
    try {
      _notificationSettings = LoadState<NotificationSettings>.success(
        await _account.updateNotificationSettings(patch),
      );
      notifyListeners();
      return null;
    } on ApiFailure catch (e) {
      return e.message;
    }
  }

  Future<void> loadSessions() async {
    _sessions = LoadState<List<SecuritySession>>.loading();
    notifyListeners();
    try {
      _sessions = listState(await _account.fetchSessions());
    } on ApiFailure catch (e) {
      _sessions = LoadState<List<SecuritySession>>.error(e.message);
    }
    notifyListeners();
  }

  Future<String?> revokeSession(String id) async {
    try {
      await _account.revokeSession(id);
      await loadSessions();
      return null;
    } on ApiFailure catch (e) {
      return e.message;
    }
  }

  Future<void> loadMyReports() async {
    _reports = LoadState<List<MyReport>>.loading();
    notifyListeners();
    try {
      _reports = listState(await _account.fetchMyReports());
    } on ApiFailure catch (e) {
      _reports = LoadState<List<MyReport>>.error(e.message);
    }
    notifyListeners();
  }

  Future<void> discoverFromContacts(List<String> hashes) async {
    _contactMatches = LoadState<List<User>>.loading();
    notifyListeners();
    try {
      _contactMatches = listState(await _account.discoverFriendsFromContacts(hashes));
    } on ApiFailure catch (e) {
      _contactMatches = LoadState<List<User>>.error(e.message);
    }
    notifyListeners();
  }
}
