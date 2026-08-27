import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/theme.dart';
import '../theme/design_system.dart';
import '../api/api_config.dart';
import '../api/api_client.dart';
import '../api/services/v32_service.dart';

/// Spotlight — full-screen vertical media feed backed by REAL public stories
/// (GET /stories/public). No fabricated content: if the backend returns zero
/// public stories a polished empty state is shown. Videos autoplay per page,
/// images fill edge-to-edge (cover, never stretched). Like is a client-side
/// visual toggle (no spotlight-like endpoint exists, so no fake counts are
/// shown); share uses the native sheet.
class SpotlightScreen extends StatefulWidget {
  const SpotlightScreen({super.key});

  @override
  State<SpotlightScreen> createState() => _SpotlightScreenState();
}

class _SpotlightScreenState extends State<SpotlightScreen> {
  final SwiftSnapV32Service _v32 = SwiftSnapV32Service();
  final PageController _pager = PageController();

  List<Map<String, dynamic>> _items = [];
  bool _loading = true;
  String? _error;

  int _index = 0;
  VideoPlayerController? _video;
  final Set<int> _liked = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _video?.dispose();
    _pager.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final res = await _v32.publicStories();
    if (!mounted) return;
    if (res.isSuccess) {
      final data = res.data?['data'];
      final list = data is List ? data.cast<Map<String, dynamic>>() : <Map<String, dynamic>>[];
      setState(() {
        _items = list;
        _loading = false;
      });
      if (list.isNotEmpty) _prepareMedia(0);
    } else {
      setState(() {
        _error = res.errorMessage;
        _loading = false;
      });
    }
  }

  String _mediaUrl(dynamic raw) {
    final s = (raw ?? '').toString();
    if (s.isEmpty) return '';
    return s.startsWith('http') ? s : '${ApiConfig.BASE_URL}$s';
  }

  bool _isVideo(Map<String, dynamic> story) {
    final t = (story['media_type'] ?? story['type'] ?? '').toString().toLowerCase();
    if (t.contains('video')) return true;
    final u = _mediaUrl(story['media_url'] ?? story['mediaUrl']).toLowerCase();
    return u.endsWith('.mp4') || u.endsWith('.mov') || u.endsWith('.webm') || u.endsWith('.m4v');
  }

  Future<void> _prepareMedia(int i) async {
    _video?.dispose();
    _video = null;
    if (i < 0 || i >= _items.length) return;
    final story = _items[i];
    if (!_isVideo(story)) {
      if (mounted) setState(() {});
      return;
    }
    final url = _mediaUrl(story['media_url'] ?? story['mediaUrl']);
    if (url.isEmpty) return;
    final c = VideoPlayerController.networkUrl(
      Uri.parse(url),
      httpHeaders: {'Authorization': 'Bearer ${ApiClient.currentToken ?? ''}'},
    );
    try {
      await c.initialize();
      await c.setLooping(true);
      await c.play();
      if (!mounted) {
        c.dispose();
        return;
      }
      setState(() => _video = c);
    } catch (_) {
      c.dispose();
    }
  }

  Map _userOf(Map<String, dynamic> story) => story['user'] is Map ? story['user'] as Map : const {};

  String _username(Map<String, dynamic> story) {
    final u = _userOf(story);
    return (u['username'] ?? u['display_name'] ?? 'user').toString();
  }

  String _avatarOf(Map<String, dynamic> story) {
    final u = _userOf(story);
    return _mediaUrl((u['profile'] is Map ? u['profile']['avatar_url'] : null) ?? u['avatar_url']);
  }

  void _share(Map<String, dynamic> story) {
    HapticFeedback.lightImpact();
    Share.share('Check out @${_username(story)} on SwiftSnap Spotlight');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }
    if (_error != null) {
      return SafeArea(
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.wifi_off_rounded, color: Colors.white54, size: 40),
            const SizedBox(height: SSGap.md),
            Text(_error!, style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center),
            const SizedBox(height: SSGap.md),
            TextButton(onPressed: _load, child: const Text('Retry')),
          ]),
        ),
      );
    }
    if (_items.isEmpty) {
      return SafeArea(
        child: Column(children: [
          _topBar(),
          const Expanded(
            child: SSEmptyState(
              icon: Icons.play_circle_outline_rounded,
              title: 'Spotlight is quiet right now',
              subtitle: 'Public stories from creators will appear here as soon as they post.',
            ),
          ),
        ]),
      );
    }
    return Stack(children: [
      PageView.builder(
        controller: _pager,
        scrollDirection: Axis.vertical,
        itemCount: _items.length,
        onPageChanged: (i) {
          setState(() => _index = i);
          _prepareMedia(i);
        },
        itemBuilder: (_, i) => _page(_items[i], i),
      ),
      Positioned(top: 0, left: 0, right: 0, child: SafeArea(bottom: false, child: _topBar())),
    ]);
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(SSGap.lg, SSGap.sm, SSGap.sm, SSGap.sm),
      child: Row(children: [
        const Icon(Icons.bolt_rounded, color: Colors.white, size: 20),
        const SizedBox(width: 6),
        const Text('Spotlight',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
        const Spacer(),
        SSIconButton(icon: Icons.refresh_rounded, color: Colors.white, onTap: _load),
      ]),
    );
  }

  Widget _page(Map<String, dynamic> story, int i) {
    final url = _mediaUrl(story['media_url'] ?? story['mediaUrl']);
    final caption = (story['caption'] ?? '').toString();
    final liked = _liked.contains(i);
    return Stack(fit: StackFit.expand, children: [
      // Media (edge-to-edge cover)
      if (_isVideo(story))
        (_index == i && _video != null && _video!.value.isInitialized)
            ? FittedBox(
                fit: BoxFit.cover,
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  width: _video!.value.size.width,
                  height: _video!.value.size.height,
                  child: VideoPlayer(_video!),
                ),
              )
            : const Center(child: CircularProgressIndicator(color: Colors.white))
      else if (url.isNotEmpty)
        CachedNetworkImage(
          imageUrl: url,
          httpHeaders: {'Authorization': 'Bearer ${ApiClient.currentToken ?? ''}'},
          fit: BoxFit.cover,
          placeholder: (_, __) => const ColoredBox(color: SwiftSnapTheme.surfaceColor),
          errorWidget: (_, __, ___) =>
              const ColoredBox(color: SwiftSnapTheme.surfaceColor, child: Icon(Icons.broken_image_rounded, color: Colors.white38)),
        )
      else
        const ColoredBox(color: SwiftSnapTheme.surfaceColor),
      // Bottom gradient for legibility
      Positioned(
        bottom: 0, left: 0, right: 0, height: 220,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black87],
            ),
          ),
        ),
      ),
      // Creator + caption
      Positioned(
        left: SSGap.lg, right: 72, bottom: 0,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.only(bottom: SSGap.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('@${_username(story)}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                if (caption.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(caption,
                      style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
                      maxLines: 3, overflow: TextOverflow.ellipsis),
                ],
              ],
            ),
          ),
        ),
      ),
      // Right action rail
      Positioned(
        right: SSGap.sm, bottom: 0,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.only(bottom: SSGap.lg),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              _railAvatar(story),
              const SizedBox(height: SSGap.lg),
              _railButton(
                icon: liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: liked ? SwiftSnapTheme.primaryPink : Colors.white,
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => liked ? _liked.remove(i) : _liked.add(i));
                },
              ),
              const SizedBox(height: SSGap.lg),
              _railButton(icon: Icons.reply_rounded, color: Colors.white, onTap: () => _share(story)),
            ]),
          ),
        ),
      ),
    ]);
  }

  Widget _railAvatar(Map<String, dynamic> story) {
    final avatar = _avatarOf(story);
    final name = _username(story);
    return Container(
      width: 46, height: 46,
      padding: const EdgeInsets.all(2),
      decoration: const BoxDecoration(shape: BoxShape.circle, gradient: SwiftSnapTheme.storyGradient),
      child: CircleAvatar(
        backgroundColor: SwiftSnapTheme.surfaceColor,
        backgroundImage: avatar.isNotEmpty
            ? CachedNetworkImageProvider(avatar, headers: {'Authorization': 'Bearer ${ApiClient.currentToken ?? ''}'})
            : null,
        child: avatar.isEmpty
            ? Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white))
            : null,
      ),
    );
  }

  Widget _railButton({required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkResponse(
      onTap: onTap,
      radius: 26,
      child: Icon(icon, color: color, size: 30),
    );
  }
}
