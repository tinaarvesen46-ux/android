import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// A previously-logged-in account kept for quick account switching.
///
/// The stored `token` is a REAL Sanctum personal access token that was
/// already issued by Laravel at a real login — nothing here is fabricated.
/// Sanctum tokens on this backend do not auto-expire (`expiration: null`),
/// so a saved token stays valid until the user explicitly removes it (which
/// revokes it server-side) or a security action (e.g. password change)
/// revokes it — at which point [AuthProvider.switchToSavedAccount] simply
/// fails with a real 401 and the account is dropped from the list.
class SavedAccount {
  final String userId;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final String token;

  const SavedAccount({
    required this.userId,
    required this.username,
    required this.displayName,
    required this.avatarUrl,
    required this.token,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'username': username,
        'displayName': displayName,
        'avatarUrl': avatarUrl,
        'token': token,
      };

  static SavedAccount fromJson(Map<String, dynamic> json) => SavedAccount(
        userId: json['userId'] as String,
        username: json['username'] as String,
        displayName: json['displayName'] as String,
        avatarUrl: json['avatarUrl'] as String?,
        token: json['token'] as String,
      );
}

/// Persists the list of saved accounts in secure storage, separate from the
/// single active `auth_token` key used by [ApiService].
class SavedAccountsStore {
  static const _key = 'saved_accounts';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<List<SavedAccount>> load() async {
    final raw = await _storage.read(key: _key);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => SavedAccount.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> _save(List<SavedAccount> accounts) async {
    await _storage.write(
      key: _key,
      value: jsonEncode(accounts.map((a) => a.toJson()).toList()),
    );
  }

  Future<void> upsert(SavedAccount account) async {
    final accounts = await load();
    accounts.removeWhere((a) => a.userId == account.userId);
    accounts.add(account);
    await _save(accounts);
  }

  Future<void> remove(String userId) async {
    final accounts = await load();
    accounts.removeWhere((a) => a.userId == userId);
    await _save(accounts);
  }
}
