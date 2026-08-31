import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../providers/account_provider.dart';
import '../providers/social_provider.dart';
import '../theme/theme.dart';
import '../widgets/common/app_top_bar.dart';
import '../widgets/common/async_state_view.dart';
import '../widgets/common/role_badge.dart';
import '../widgets/common/snap_avatar.dart';

/// Real contact-based friend discovery: hashes each device contact's phone
/// number on-device (SHA-256) and only ever sends hashes to
/// `POST /contacts/discover` — the raw contact book never leaves the phone.
class FindFriendsScreen extends StatefulWidget {
  const FindFriendsScreen({super.key});

  @override
  State<FindFriendsScreen> createState() => _FindFriendsScreenState();
}

enum _Phase { intro, scanning, done }

class _FindFriendsScreenState extends State<FindFriendsScreen> {
  _Phase _phase = _Phase.intro;
  String? _error;
  final Set<String> _sentRequests = {};

  String _normalize(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^\d+]'), '');
    return digits;
  }

  Future<void> _scan() async {
    setState(() {
      _phase = _Phase.scanning;
      _error = null;
    });

    await FlutterContacts.permissions.request(PermissionType.read);
    final granted = await FlutterContacts.permissions.has(PermissionType.read);
    if (!granted) {
      setState(() {
        _phase = _Phase.intro;
        _error = 'Contacts permission was denied. Enable it in system settings to use this feature.';
      });
      return;
    }

    try {
      final contacts = await FlutterContacts.getAll(properties: {ContactProperty.phone});
      final hashes = <String>{};
      for (final c in contacts) {
        for (final p in c.phones) {
          final normalized = _normalize(p.number);
          if (normalized.length < 7) continue;
          hashes.add(sha256.convert(utf8.encode(normalized)).toString());
        }
      }
      if (!mounted) return;
      if (hashes.isEmpty) {
        setState(() {
          _phase = _Phase.intro;
          _error = 'No phone numbers found in your contacts.';
        });
        return;
      }
      await context.read<AccountProvider>().discoverFromContacts(hashes.toList());
      if (mounted) setState(() => _phase = _Phase.done);
    } catch (e) {
      setState(() {
        _phase = _Phase.intro;
        _error = 'Could not read your contacts.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;

    return Scaffold(
      body: Column(
        children: [
          const AppTopBar(showBack: true, title: 'Find friends'),
          Expanded(child: _body(context, theme, appColors)),
        ],
      ),
    );
  }

  Widget _body(BuildContext context, ThemeData theme, AppColorsExtension appColors) {
    switch (_phase) {
      case _Phase.intro:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingXl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.contacts_rounded, size: AppTheme.iconHuge, color: appColors.subtleText),
                const SizedBox(height: AppTheme.spacingLg),
                Text(
                  'Match your contacts against SwiftSnap accounts. Numbers are '
                  'hashed on your device before anything is sent.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                if (_error != null) ...[
                  const SizedBox(height: AppTheme.spacingMd),
                  Text(_error!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(color: appColors.danger)),
                ],
                const SizedBox(height: AppTheme.spacingXl),
                ElevatedButton(onPressed: _scan, child: const Text('Scan contacts')),
              ],
            ),
          ),
        );
      case _Phase.scanning:
        return const Center(child: CircularProgressIndicator());
      case _Phase.done:
        final provider = context.watch<AccountProvider>();
        return AsyncStateView<List<User>>(
          state: provider.contactMatches,
          emptyIcon: Icons.person_search_rounded,
          emptyTitle: 'No SwiftSnap friends found in your contacts',
          onRetry: _scan,
          builder: (matches) => ListView.builder(
            itemCount: matches.length,
            itemBuilder: (context, index) {
              final u = matches[index];
              final sent = _sentRequests.contains(u.id);
              return ListTile(
                leading: SnapAvatar(imageUrl: u.avatarUrl, fallbackText: u.displayName, size: AppTheme.avatarMd),
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(u.displayName),
                    RoleBadge(role: u.role, roleLabel: u.roleLabel),
                  ],
                ),
                subtitle: Text('@${u.username}'),
                onTap: () => context.push('/user/${u.id}'),
                trailing: sent
                    ? const Text('Requested')
                    : TextButton(
                        onPressed: () async {
                          final error = await context.read<SocialProvider>().sendFriendRequest(u.id);
                          if (error == null && mounted) {
                            setState(() => _sentRequests.add(u.id));
                          } else if (error != null && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                          }
                        },
                        child: const Text('Add'),
                      ),
              );
            },
          ),
        );
    }
  }
}
