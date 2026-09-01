import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../core/api_failure.dart';
import '../repositories/social_repository.dart';
import '../services/api_service.dart';
import '../widgets/common/snap_avatar.dart';

class ProfileHeaderEditorScreen extends StatefulWidget {
  const ProfileHeaderEditorScreen({super.key});

  @override
  State<ProfileHeaderEditorScreen> createState() => _ProfileHeaderEditorScreenState();
}

class _ProfileHeaderEditorScreenState extends State<ProfileHeaderEditorScreen> {
  Map<String, dynamic>? _original;
  Map<String, dynamic> _working = {};
  bool _loading = true;
  bool _saving = false;
  String? _error;
  // interaction state
  Offset _avatarOffset = Offset.zero;
  double _avatarScale = 1.0;
  double _initialScale = 1.0;
  Offset _initialFocal = Offset.zero;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() { _loading = true; _error = null; });
    final repo = Provider.of<SocialRepository>(context, listen: false);
    try {
      final data = await repo.fetchProfileHeader();
      if (!mounted) return;
      final original = data ?? <String, dynamic>{};
      final working = Map<String, dynamic>.from(original);
      final pos = working['avatar_position'] is Map
          ? Map<String, dynamic>.from(working['avatar_position'] as Map)
          : <String, dynamic>{};
      setState(() {
        _original = original;
        _working = working;
        _avatarOffset = Offset(
          ((pos['x'] as num?)?.toDouble() ?? 0.5).clamp(0.0, 1.0),
          ((pos['y'] as num?)?.toDouble() ?? 0.5).clamp(0.0, 1.0),
        );
        _avatarScale = ((working['avatar_scale'] as num?)?.toDouble() ?? 1.0).clamp(0.3, 3.0);
        _loading = false;
      });
    } on ApiFailure catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.message; });
    } catch (_) {
      if (mounted) setState(() { _loading = false; _error = 'The profile header could not be loaded.'; });
    }
  }

  void _updateField(String key, dynamic value) {
    setState(() {
      _working[key] = value;
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final repo = Provider.of<SocialRepository>(context, listen: false);
    // persist position/scale into working config
    _working['avatar_position'] = {'x': _avatarOffset.dx.clamp(0.0, 1.0), 'y': _avatarOffset.dy.clamp(0.0, 1.0)};
    _working['avatar_scale'] = _avatarScale;
    try {
      await repo.saveProfileHeader(_working);
      // refresh current user
      final auth = Provider.of<AuthProvider>(context, listen: false);
      await auth.hydrateFromExistingSession();
      if (mounted) {
        setState(() => _saving = false);
        Navigator.of(context).pop(true);
      }
    } on ApiFailure catch (e) {
      if (mounted) setState(() { _saving = false; _error = e.message; });
    } catch (_) {
      if (mounted) setState(() { _saving = false; _error = 'The profile header could not be saved.'; });
    }
  }

  Future<void> _reset() async {
    if (mounted) setState(() { _saving = true; _error = null; });
    try {
      final repo = Provider.of<SocialRepository>(context, listen: false);
      await repo.resetProfileHeader();
      await _load();
    } on ApiFailure catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customize Header'),
        actions: [
          TextButton(onPressed: _loading || _saving ? null : _save, child: const Text('SAVE')),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.error_outline, size: 48),
                      const SizedBox(height: 12),
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      OutlinedButton(onPressed: _load, child: const Text('Retry')),
                    ]),
                  ),
                )
              : Column(
              children: [
                // live preview with pan/zoom gestures
                AspectRatio(
                  aspectRatio: 1024 / 384,
                  child: Container(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    child: GestureDetector(
                      onScaleStart: (details) {
                        _initialScale = _avatarScale;
                        _initialFocal = details.focalPoint;
                      },
                      onScaleUpdate: (details) {
                        setState(() {
                          // scale about initial
                          _avatarScale = (_initialScale * details.scale).clamp(0.3, 3.0);
                          // pan using focal delta
                          final delta = details.focalPoint - _initialFocal;
                          _initialFocal = details.focalPoint;
                          _avatarOffset += Offset(delta.dx / 1024, delta.dy / 384);
                        });
                      },
                      child: Stack(
                        children: [
                          // background placeholder
                          if ((_working['background_id'] as String?) != null)
                            Positioned.fill(
                              child: Image.network(
                                ApiService.resolveUrl('/api/v1/avatar/asset/background/${_working['background_id']}/thumb'),
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                              ),
                            ),
                          // avatar positioned
                          LayoutBuilder(builder: (ctx, cons) {
                            final cx = cons.maxWidth * (_avatarOffset.dx.clamp(0.0, 1.0));
                            final cy = cons.maxHeight * (_avatarOffset.dy.clamp(0.0, 1.0));
                            return Stack(children: [
                              Positioned(
                                left: cx - (80 * _avatarScale),
                                top: cy - (80 * _avatarScale),
                                child: Transform.scale(
                                  scale: _avatarScale,
                                  child: SnapAvatar(
                                    imageUrl: user?.avatarUrl,
                                    renderUrl: user?.avatarRenderUrl,
                                    fallbackText: user?.displayName ?? '',
                                    size: 160,
                                  ),
                                ),
                              ),
                            ]);
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
                // controls (simplified): background, pose, position/scale
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(12),
                    children: [
                      ListTile(
                        title: const Text('Background'),
                        subtitle: Text(_working['background_id']?.toString() ?? 'Default'),
                        trailing: const Icon(Icons.edit),
                        onTap: () async {
                          // open selector: fetch backgrounds from catalog
                          final repo = Provider.of<SocialRepository>(context, listen: false);
                          final items = await repo.fetchAvatarCatalog(category: 'background');
                          final list = (items['items'] as List<dynamic>?) ?? [];
                          showModalBottomSheet(context: context, builder: (_) {
                            return SafeArea(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (list.isEmpty) const Padding(padding: EdgeInsets.all(16), child: Text('No backgrounds available yet.')),
                                  if (list.isNotEmpty)
                                    SizedBox(
                                      height: 120,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: list.length,
                                        itemBuilder: (ctx, i) {
                                          final it = list[i];
                                          final aid = it['asset_id'];
                                          if (it['available'] != true) return const SizedBox.shrink();
                                          return GestureDetector(
                                            onTap: () { _updateField('background_id', aid); Navigator.pop(context); },
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Image.network(ApiService.resolveUrl('/api/v1/avatar/asset/background/$aid/thumb'), width: 100, height: 100, fit: BoxFit.cover),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                ],
                              ),
                            );
                          });
                        },
                      ),
                      ListTile(
                        title: const Text('Pose'),
                        subtitle: Text(_working['pose_id']?.toString() ?? 'Default'),
                        trailing: const Icon(Icons.self_improvement),
                        onTap: () async {
                          final repo = Provider.of<SocialRepository>(context, listen: false);
                          final items = await repo.fetchAvatarCatalog(category: 'pose');
                          final list = (items['items'] as List<dynamic>?) ?? [];
                          showModalBottomSheet(context: context, builder: (_) {
                            return SafeArea(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (list.isEmpty) const Padding(padding: EdgeInsets.all(16), child: Text('No poses available yet.')),
                                  if (list.isNotEmpty)
                                    SizedBox(
                                      height: 120,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: list.length,
                                        itemBuilder: (ctx, i) {
                                          final it = list[i];
                                          final aid = it['asset_id'];
                                          if (it['available'] != true) return const SizedBox.shrink();
                                          return GestureDetector(
                                            onTap: () { _updateField('pose_id', aid); Navigator.pop(context); },
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Image.network(ApiService.resolveUrl('/api/v1/avatar/asset/pose/$aid/thumb'), width: 100, height: 100, fit: BoxFit.cover),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                ],
                              ),
                            );
                          });
                        },
                      ),
                      ListTile(
                        title: const Text('Position & Scale'),
                        subtitle: Text('x:${_avatarOffset.dx.toStringAsFixed(2)}, y:${_avatarOffset.dy.toStringAsFixed(2)}, scale:${_avatarScale.toStringAsFixed(2)}'),
                        trailing: const Icon(Icons.open_with),
                        onTap: () {},
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          OutlinedButton(onPressed: _loading || _saving ? null : () { setState(() { _working = Map<String, dynamic>.from(_original ?? {}); _avatarOffset = Offset((_original?['avatar_position']?['x'] ?? 0.5) as double, (_original?['avatar_position']?['y'] ?? 0.5) as double); _avatarScale = (_original?['avatar_scale'] ?? 1.0) as double; }); }, child: const Text('CANCEL')),
                          OutlinedButton(onPressed: _loading || _saving ? null : () { setState(() { _avatarOffset = const Offset(0.5, 0.5); _avatarScale = 1.0; }); }, child: const Text('RESET POSITION')),
                          OutlinedButton(onPressed: _loading || _saving ? null : _reset, child: const Text('RESET')),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
