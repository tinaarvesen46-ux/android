import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import '../api/services/location_service.dart';
import '../widgets/selected_friend_picker.dart';
import '../services/streak_boost_service.dart';

/// SwiftMapScreen — Snapchat-style friend map.
///
/// Uses OpenStreetMap free tiles by default (`flutter_map` + `latlong2`).
/// Day/night mode is inferred from the user's local sunrise/sunset when
/// `swiftmap_appearance = auto` (default) — implemented via a simple hour
/// window so no network call is needed.
///
/// Privacy is fully server-side enforced.  This screen never trusts the
/// client to hide markers — the /location/friends endpoint only returns
/// friends who authorized visibility.
class SwiftMapScreen extends StatefulWidget {
  const SwiftMapScreen({super.key});

  @override
  State<SwiftMapScreen> createState() => _SwiftMapScreenState();
}

class _SwiftMapScreenState extends State<SwiftMapScreen> {
  final MapController _map = MapController();
  Map<String, dynamic>? _settings;
  List<Map<String, dynamic>> _friends = const [];
  LatLng? _mePos;
  bool _loading = true;
  Timer? _refresh;

  @override
  void initState() { super.initState(); _boot(); }

  Future<void> _boot() async {
    final settings = await LocationService().settings();
    _settings = settings;
    _friends = await LocationService().friends();

    // Try to acquire my current position if I've allowed sharing.
    if (settings != null && settings['visibility'] != 'off' && settings['visibility'] != 'ghost') {
      final perm = await Permission.locationWhenInUse.request();
      if (perm.isGranted) {
        try {
          final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
          _mePos = LatLng(pos.latitude, pos.longitude);
          // Push to server; the server applies visibility rules on read.
          await LocationService().push(lat: pos.latitude, lng: pos.longitude, accuracyM: pos.accuracy.toInt());
        } catch (_) {}
      }
    }

    if (mounted) setState(() => _loading = false);
    _refresh = Timer.periodic(const Duration(seconds: 30), (_) async {
      _friends = await LocationService().friends();
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() { _refresh?.cancel(); super.dispose(); }

  bool _isNight() {
    final appearance = _settings?['swiftmap_appearance'] ?? 'auto';
    if (appearance == 'dark') return true;
    if (appearance == 'light') return false;
    final h = DateTime.now().hour;   // local hour
    return h < 6 || h >= 19;         // simple 6pm-6am fallback; sunset API can replace later
  }

  String _tileUrl() {
    return _isNight()
        // CartoDB dark tiles (attribution required, free for personal use up to modest traffic)
        ? 'https://a.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}@2x.png'
        : 'https://a.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}@2x.png';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final center = _mePos ?? (_friends.isNotEmpty
        ? LatLng((_friends.first['lat'] as num).toDouble(), (_friends.first['lng'] as num).toDouble())
        : const LatLng(59.9139, 10.7522));   // Oslo fallback

    final darkMode = _isNight();

    return Scaffold(
      backgroundColor: darkMode ? Colors.black : Colors.white,
      body: SafeArea(
        child: Stack(children: [
          FlutterMap(
            mapController: _map,
            options: MapOptions(initialCenter: center, initialZoom: 12),
            children: [
              TileLayer(
                urlTemplate: _tileUrl(),
                userAgentPackageName: 'com.swiftsnap.app',
                maxZoom: 19,
              ),
              MarkerLayer(
                markers: [
                  if (_mePos != null)
                    Marker(
                      point: _mePos!,
                      width: 44, height: 44,
                      child: Container(
                        decoration: BoxDecoration(shape: BoxShape.circle,
                          gradient: const LinearGradient(colors: [Color(0xFFB78BFF), Color(0xFFFF80C6)]),
                          border: Border.all(color: Colors.white, width: 3)),
                        child: const Icon(Icons.person, color: Colors.white),
                      ),
                    ),
                  for (final f in _friends)
                    Marker(
                      point: LatLng((f['lat'] as num).toDouble(), (f['lng'] as num).toDouble()),
                      width: 44, height: 44,
                      child: GestureDetector(
                        onTap: () => _showFriendCard(context, f),
                        child: Container(
                          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white,
                              border: Border.all(color: darkMode ? Colors.white70 : Colors.black26, width: 2)),
                          child: ClipOval(
                            child: f['avatar_url'] != null
                                ? Image.network(f['avatar_url'], fit: BoxFit.cover)
                                : Center(child: Text(
                                    ((f['username'] ?? '?').toString()).substring(0, 1).toUpperCase(),
                                    style: const TextStyle(fontWeight: FontWeight.w800))),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              // Attribution required by CartoDB / OSM
              RichAttributionWidget(attributions: const [
                TextSourceAttribution('OpenStreetMap contributors · Tiles © CartoDB'),
              ]),
            ],
          ),
          // Top bar
          Positioned(top: 8, left: 8, right: 8, child: _topBar(darkMode)),
          // Streak-boost strip — surfaces friends whose streak is about to
          // break so the user can tap-to-snap them straight from the map.
          Positioned(
            top: 68, left: 0, right: 0,
            child: StreakBoostStrip(
              onSendSnap: (id, f) {
                Navigator.pop(context, {'openChat': true, 'friend_id': id});
              },
            ),
          ),
          // Ghost mode / share toggle
          Positioned(bottom: 24, right: 16, child: _actions(darkMode)),
        ]),
      ),
    );
  }

  Widget _topBar(bool darkMode) {
    final fg = darkMode ? Colors.white : Colors.black;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: (darkMode ? Colors.black : Colors.white).withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(children: [
        IconButton(icon: Icon(Icons.arrow_back, color: fg), onPressed: () => Navigator.pop(context)),
        Icon(Icons.map, color: fg),
        const SizedBox(width: 6),
        Text('SwiftMap', style: TextStyle(fontWeight: FontWeight.w700, color: fg)),
        const Spacer(),
        Text(_settings?['visibility'] ?? 'off',
            style: TextStyle(color: fg.withOpacity(0.6), fontSize: 12)),
      ]),
    );
  }

  Widget _actions(bool darkMode) {
    final bg = darkMode ? Colors.white : Colors.black;
    final visibility = (_settings?['visibility'] ?? 'off') as String;
    return Column(children: [
      // Visibility cycle: off → friends → selected → ghost → off
      FloatingActionButton.extended(
        heroTag: 'visibility',
        backgroundColor: bg,
        onPressed: () async {
          final next = _nextVisibility(visibility);
          _settings = await LocationService().updateSettings(visibility: next);
          if (!mounted) return;
          setState(() {});
          if (next == 'selected') await _openPicker();
        },
        icon: Icon(_visibilityIcon(visibility), color: darkMode ? Colors.black : Colors.white),
        label: Text(_visibilityLabel(visibility),
            style: TextStyle(color: darkMode ? Colors.black : Colors.white, fontWeight: FontWeight.w700)),
      ),
      // "Manage picked" button only makes sense when visibility is selected.
      if (visibility == 'selected') ...[
        const SizedBox(height: 8),
        FloatingActionButton(
          heroTag: 'picker',
          backgroundColor: bg,
          tooltip: 'Choose who sees me',
          onPressed: _openPicker,
          child: Icon(Icons.group, color: darkMode ? Colors.black : Colors.white),
        ),
      ],
      const SizedBox(height: 8),
      FloatingActionButton(
        heroTag: 'appearance',
        backgroundColor: bg,
        onPressed: () async {
          final cur = _settings?['swiftmap_appearance'] ?? 'auto';
          final next = cur == 'auto' ? 'light' : cur == 'light' ? 'dark' : 'auto';
          _settings = await LocationService().updateSettings(swiftmapAppearance: next);
          if (mounted) setState(() {});
        },
        child: Icon(Icons.brightness_4, color: darkMode ? Colors.black : Colors.white),
      ),
    ]);
  }

  String _nextVisibility(String v) => switch (v) {
        'off'      => 'friends',
        'friends'  => 'selected',
        'selected' => 'ghost',
        _          => 'off',
      };

  IconData _visibilityIcon(String v) => switch (v) {
        'friends'  => Icons.public,
        'selected' => Icons.groups,
        'ghost'    => Icons.visibility_off,
        _          => Icons.location_off,
      };

  String _visibilityLabel(String v) => switch (v) {
        'friends'  => 'Friends',
        'selected' => 'Selected',
        'ghost'    => 'Ghost',
        _          => 'Off',
      };

  Future<void> _openPicker() async {
    final initial = ((_settings?['selected_friend_ids'] as List?) ?? const [])
        .map((e) => (e as num).toInt())
        .toList();
    final result = await SelectedFriendPicker.show(context, initial: initial);
    if (result != null) {
      _settings = await LocationService().settings();
      _friends = await LocationService().friends();
      if (mounted) setState(() {});
    }
  }

  void _showFriendCard(BuildContext ctx, Map<String, dynamic> f) {
    showModalBottomSheet(context: ctx, builder: (_) => Padding(
      padding: const EdgeInsets.all(20),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        CircleAvatar(radius: 32,
          backgroundImage: f['avatar_url'] != null ? NetworkImage(f['avatar_url']) : null,
          child: f['avatar_url'] == null ? Text('${f['username']}'.substring(0,1).toUpperCase()) : null),
        const SizedBox(height: 8),
        Text(f['display_name'] ?? f['username'] ?? '?', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        Text('@${f['username']}', style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 4),
        Text('Updated ${f['updated_at'] ?? '—'}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ]),
    ));
  }
}
