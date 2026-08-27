import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../theme/theme.dart';
import '../providers/app_provider.dart';
import '../api/api_config.dart';
import '../api/api_client.dart';
import '../api/services/user_service.dart';
import '../api/services/friend_service.dart';
import '../api/services/v32_service.dart';
import '../models/user_model.dart';

/// Discover — real people discovery.
///
/// Bound to:
///  - GET /search/discover  -> suggested users when the search box is empty
///  - GET /search/users?query=... -> live user search
///  - POST /friend-requests/send/{id} -> add-friend action
///
/// NOTE: a "Trending topics / Spotlight" feed is intentionally not shown.
/// The backend exposes no trending/hashtag endpoint, so rather than fabricate
/// trending content we show real people you can discover and connect with.
class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final TextEditingController _searchController = TextEditingController();
  final UserService _userService = UserService();
  final FriendService _friendService = FriendService();
  final SwiftSnapV32Service _v32 = SwiftSnapV32Service();

  List<UserModel> _users = [];
  List<Map<String, dynamic>> _publicStories = [];
  final Set<String> _requested = {};
  bool _loading = true;
  String? _error;
  String _query = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadDiscover();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDiscover() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final res = await _userService.getDiscoverUsers();
    if (!mounted) return;
    // Public stories are shown only on the default (unsearched) Discover view.
    _v32.publicStories().then((r) {
      if (!mounted) return;
      final data = r.data?['data'];
      if (data is List) {
        setState(() => _publicStories = data.cast<Map<String, dynamic>>());
      }
    });
    setState(() {
      _loading = false;
      if (res.isSuccess) {
        _users = res.data ?? [];
      } else {
        _error = res.errorMessage;
      }
    });
  }

  Future<void> _search(String q) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final res = await _userService.searchUsers(query: q);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (res.isSuccess) {
        _users = res.data ?? [];
      } else {
        _error = res.errorMessage;
      }
    });
  }

  void _onQueryChanged(String v) {
    setState(() => _query = v);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (v.trim().isEmpty) {
        _loadDiscover();
      } else {
        _search(v.trim());
      }
    });
  }

  Future<void> _addFriend(UserModel u) async {
    HapticFeedback.lightImpact();
    setState(() => _requested.add(u.id));
    final res = await _friendService.sendFriendRequest(u.id);
    if (!mounted) return;
    if (!res.isSuccess) {
      setState(() => _requested.remove(u.id));
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res.isSuccess ? 'Friend request sent to @${u.username}' : res.errorMessage)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwiftSnapTheme.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  ShaderMask(
                    shaderCallback: (b) => SwiftSnapTheme.primaryGradient.createShader(b),
                    child: const Text('Discover',
                        style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _searchController,
                onChanged: _onQueryChanged,
                style: const TextStyle(color: SwiftSnapTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search people by name or @username',
                  hintStyle: const TextStyle(color: SwiftSnapTheme.textMuted),
                  prefixIcon: const Icon(Icons.search_rounded, color: SwiftSnapTheme.textMuted),
                  filled: true,
                  fillColor: SwiftSnapTheme.surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SwiftSnapTheme.radiusMd),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            if (_query.isEmpty) _publicStoriesStrip(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _publicStoriesStrip() {
    if (_publicStories.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 110,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 4, 16, 6),
            child: Text('Public Stories',
                style: TextStyle(color: SwiftSnapTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w700)),
          ),
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _publicStories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) => _publicStoryCircle(_publicStories[i]),
            ),
          ),
        ],
      ),
    );
  }

  String _mediaUrl(dynamic raw) {
    final s = (raw ?? '').toString();
    if (s.isEmpty) return '';
    if (s.startsWith('http')) return s;
    return '${ApiConfig.BASE_URL}$s';
  }

  Widget _publicStoryCircle(Map<String, dynamic> story) {
    final user = story['user'] is Map ? story['user'] as Map : const {};
    final username = (user['username'] ?? user['display_name'] ?? 'user').toString();
    final avatar = _mediaUrl((user['profile'] is Map ? user['profile']['avatar_url'] : null) ?? user['avatar_url']);
    return GestureDetector(
      onTap: () => _openPublicStory(story),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 62,
            height: 62,
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(shape: BoxShape.circle, gradient: SwiftSnapTheme.storyGradient),
            child: CircleAvatar(
              backgroundColor: SwiftSnapTheme.surfaceColor,
              backgroundImage: avatar.isNotEmpty
                  ? CachedNetworkImageProvider(avatar,
                      headers: {'Authorization': 'Bearer ${ApiClient.currentToken ?? ''}'})
                  : null,
              child: avatar.isEmpty
                  ? Text(username.isNotEmpty ? username[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.white))
                  : null,
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 64,
            child: Text('@$username',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(color: SwiftSnapTheme.textMuted, fontSize: 11)),
          ),
        ],
      ),
    );
  }

  void _openPublicStory(Map<String, dynamic> story) {
    final url = _mediaUrl(story['media_url'] ?? story['mediaUrl']);
    if (url.isEmpty) return;
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: CachedNetworkImage(
            imageUrl: url,
            httpHeaders: {'Authorization': 'Bearer ${ApiClient.currentToken ?? ''}'},
            fit: BoxFit.contain,
            placeholder: (c, _) => const SizedBox(
                height: 300, child: Center(child: CircularProgressIndicator(color: Colors.white))),
            errorWidget: (c, _, __) =>
                const SizedBox(height: 200, child: Icon(Icons.broken_image_rounded, color: Colors.white54)),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: SwiftSnapTheme.primaryPurple));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: SwiftSnapTheme.textSecondary)),
            const SizedBox(height: 12),
            TextButton(onPressed: _query.isEmpty ? _loadDiscover : () => _search(_query), child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_users.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_search_rounded, color: SwiftSnapTheme.textMuted, size: 56),
            const SizedBox(height: 16),
            Text(_query.isEmpty ? 'No suggestions right now' : 'No people found for "$_query"',
                style: const TextStyle(color: SwiftSnapTheme.textSecondary)),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: _users.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) => _userTile(_users[i]),
    );
  }

  Widget _userTile(UserModel u) {
    final isFriend =
        context.watch<AppProvider>().friends.any((f) => f.id == u.id);
    final requested = _requested.contains(u.id);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
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
                    style: const TextStyle(color: SwiftSnapTheme.textPrimary, fontWeight: FontWeight.w600),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('@${u.username}',
                    style: const TextStyle(color: SwiftSnapTheme.textSecondary, fontSize: 13),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          TextButton(
            onPressed: (isFriend || requested) ? null : () => _addFriend(u),
            child: Text(
                isFriend ? 'Friends' : (requested ? 'Requested' : 'Add'),
                style: TextStyle(
                    color: isFriend
                        ? SwiftSnapTheme.online
                        : (requested ? SwiftSnapTheme.textMuted : SwiftSnapTheme.primaryPurple),
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
