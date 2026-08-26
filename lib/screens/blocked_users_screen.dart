import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/theme.dart';
import '../api/services/user_service.dart';
import '../models/user_model.dart';

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  final UserService _userService = UserService();
  List<UserModel> _blocked = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final res = await _userService.getBlockedUsers();
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (res.isSuccess) {
        _blocked = res.data ?? [];
      } else {
        _error = res.errorMessage;
      }
    });
  }

  Future<void> _unblock(UserModel user) async {
    HapticFeedback.lightImpact();
    final res = await _userService.unblockUser(user.id);
    if (!mounted) return;
    if (res.isSuccess) {
      setState(() => _blocked.removeWhere((u) => u.id == user.id));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unblocked @${user.username}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwiftSnapTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: SwiftSnapTheme.surfaceColor,
        title: const Text('Blocked Users'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: SwiftSnapTheme.primaryPurple),
      );
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: SwiftSnapTheme.textSecondary)),
            const SizedBox(height: 12),
            TextButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_blocked.isEmpty) {
      return const Center(
        child: Text('No blocked users',
            style: TextStyle(color: SwiftSnapTheme.textSecondary)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _blocked.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final u = _blocked[i];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: SwiftSnapTheme.surfaceColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: SwiftSnapTheme.surfaceLight,
                backgroundImage: u.avatarUrl.isNotEmpty ? NetworkImage(u.avatarUrl) : null,
                child: u.avatarUrl.isEmpty
                    ? Text(u.displayName.isNotEmpty ? u.displayName[0].toUpperCase() : '?',
                        style: const TextStyle(color: SwiftSnapTheme.textPrimary))
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(u.displayName,
                        style: const TextStyle(
                            color: SwiftSnapTheme.textPrimary, fontWeight: FontWeight.w600)),
                    Text('@${u.username}',
                        style: const TextStyle(color: SwiftSnapTheme.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => _unblock(u),
                child: const Text('Unblock',
                    style: TextStyle(color: SwiftSnapTheme.primaryPurple)),
              ),
            ],
          ),
        );
      },
    );
  }
}
