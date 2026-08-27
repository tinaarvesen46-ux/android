import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/theme.dart';
import '../api/services/v32_service.dart';
import '../widgets/swiftsnap_avatar.dart';

/// SwiftSnap Avatar Studio — create/edit/preview/save/reset/randomize an
/// original avatar. Config + catalog come from GET /avatar; saves via PUT
/// /avatar; reset via POST /avatar/reset. Live CustomPainter preview.
class AvatarStudioScreen extends StatefulWidget {
  const AvatarStudioScreen({super.key});

  @override
  State<AvatarStudioScreen> createState() => _AvatarStudioScreenState();
}

class _AvatarStudioScreenState extends State<AvatarStudioScreen> {
  final SwiftSnapV32Service _api = SwiftSnapV32Service();
  final _rand = math.Random();
  bool _loading = true;
  bool _saving = false;
  String? _error;
  Map<String, String> _config = {};
  Map<String, List<String>> _catalog = {};
  Map<String, String> _default = {};
  String _activeCat = 'skin';

  static const _labels = {
    'skin': 'Skin', 'face': 'Face', 'hair': 'Hair', 'hair_color': 'Hair Color',
    'eyebrows': 'Brows', 'eyes': 'Eyes', 'eye_color': 'Eye Color', 'nose': 'Nose',
    'mouth': 'Mouth', 'facialHair': 'Beard', 'glasses': 'Glasses', 'hat': 'Hat',
    'top': 'Top', 'top_color': 'Top Color', 'bottom': 'Bottom', 'bottom_color': 'Bottom Color',
    'shoes': 'Shoes', 'accessories': 'Accessories', 'background': 'Background',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    final res = await _api.getAvatar();
    if (!mounted) return;
    if (!res.success || res.data == null) {
      setState(() { _loading = false; _error = res.message ?? 'Could not load avatar'; });
      return;
    }
    final d = res.data!;
    setState(() {
      _config = Map<String, String>.from((d['config'] ?? d['default'] ?? {}).map((k, v) => MapEntry('$k', '$v')));
      _default = Map<String, String>.from((d['default'] ?? {}).map((k, v) => MapEntry('$k', '$v')));
      _catalog = {
        for (final e in (d['catalog'] as Map? ?? {}).entries)
          '${e.key}': (e.value as List).map((x) => '$x').toList()
      };
      _loading = false;
    });
  }

  void _select(String cat, String id) {
    HapticFeedback.selectionClick();
    setState(() => _config[cat] = id);
  }

  void _randomize() {
    HapticFeedback.mediumImpact();
    setState(() {
      for (final e in _catalog.entries) {
        _config[e.key] = e.value[_rand.nextInt(e.value.length)];
      }
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    HapticFeedback.mediumImpact();
    final res = await _api.updateAvatar(_config);
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res.success ? 'Avatar saved!' : (res.message ?? 'Save failed'))),
    );
    if (res.success) Navigator.pop(context, true);
  }

  Future<void> _reset() async {
    setState(() => _saving = true);
    final res = await _api.resetAvatar();
    if (!mounted) return;
    setState(() {
      _saving = false;
      if (res.success && res.data?['config'] != null) {
        _config = Map<String, String>.from((res.data!['config'] as Map).map((k, v) => MapEntry('$k', '$v')));
      } else if (_default.isNotEmpty) {
        _config = Map<String, String>.from(_default);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.success ? 'Reset to default' : 'Reset failed')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwiftSnapTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: SwiftSnapTheme.backgroundDark,
        elevation: 0,
        title: const Text('Avatar Studio', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            key: const Key('avatar-randomize-btn'),
            icon: const Icon(Icons.shuffle_rounded),
            onPressed: _loading ? null : _randomize,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: SwiftSnapTheme.primaryPurple))
          : _error != null
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(_error!, style: const TextStyle(color: SwiftSnapTheme.textSecondary)),
                  const SizedBox(height: 12),
                  TextButton(onPressed: _load, child: const Text('Retry')),
                ]))
              : Column(
                  children: [
                    const SizedBox(height: 12),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                        ),
                        child: SwiftSnapAvatar(config: _config, size: 200),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _categoryRail(),
                    const Divider(height: 1, color: Colors.white12),
                    Expanded(child: _optionsGrid()),
                    _bottomBar(),
                  ],
                ),
    );
  }

  Widget _categoryRail() {
    final cats = _catalog.keys.toList();
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: cats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final cat = cats[i];
          final active = cat == _activeCat;
          return GestureDetector(
            onTap: () => setState(() => _activeCat = cat),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                gradient: active ? SwiftSnapTheme.primaryGradient : null,
                color: active ? null : SwiftSnapTheme.surfaceColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(_labels[cat] ?? cat,
                  style: TextStyle(
                      color: active ? Colors.white : SwiftSnapTheme.textSecondary,
                      fontWeight: FontWeight.w600, fontSize: 13)),
            ),
          );
        },
      ),
    );
  }

  Widget _optionsGrid() {
    final options = _catalog[_activeCat] ?? [];
    final selected = _config[_activeCat];
    final isColor = _activeCat.contains('color') || _activeCat == 'background';
    return GridView.builder(
      padding: const EdgeInsets.all(14),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isColor ? 6 : 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: options.length,
      itemBuilder: (_, i) {
        final id = options[i];
        final active = id == selected;
        return GestureDetector(
          onTap: () => _select(_activeCat, id),
          child: Container(
            decoration: BoxDecoration(
              color: SwiftSnapTheme.surfaceColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: active ? SwiftSnapTheme.primaryPurple : Colors.white.withOpacity(0.06),
                width: active ? 2 : 1,
              ),
            ),
            child: isColor
                ? Center(
                    child: Container(
                      width: 26, height: 26,
                      decoration: BoxDecoration(color: _swatch(_activeCat, id), shape: BoxShape.circle),
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    // Mini live preview: current config with only this component swapped.
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SwiftSnapAvatar(
                        config: {..._config, _activeCat: id},
                        size: 120,
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }

  Color _swatch(String cat, String id) {
    final i = int.tryParse(RegExp(r'(\d+)$').firstMatch(id)?.group(1) ?? '1') ?? 1;
    const hair = [Color(0xFF2B2B2B), Color(0xFF4A2C13), Color(0xFF6B4226), Color(0xFF8D5A2B), Color(0xFFB87333), Color(0xFFD9A441), Color(0xFFE7C56B), Color(0xFFF2E4A9), Color(0xFF9E9E9E), Color(0xFFE0E0E0), Color(0xFF7B3FE4), Color(0xFFE0457B)];
    const eye = [Color(0xFF5B3A1E), Color(0xFF7B5230), Color(0xFF3E6B52), Color(0xFF2F7DB0), Color(0xFF4A4A4A), Color(0xFF6A4CA0), Color(0xFF2E8B57), Color(0xFF1C1C1C)];
    const cloth = [Color(0xFF7B3FE4), Color(0xFFE0457B), Color(0xFF2F7DB0), Color(0xFF2E8B57), Color(0xFFE7A33E), Color(0xFFE24A4A), Color(0xFF3A3A3A), Color(0xFFECECEC), Color(0xFF16B5A0), Color(0xFF9E5BF5), Color(0xFFF06292), Color(0xFF546E7A)];
    const bg = [Color(0xFF1E1B2E), Color(0xFF2A1E3F), Color(0xFF1B2E2A), Color(0xFF2E2418), Color(0xFF241E2E), Color(0xFF16232E), Color(0xFF2E1620), Color(0xFF20262E), Color(0xFF3A2E5A), Color(0xFF102A24)];
    List<Color> p;
    if (cat == 'hair_color') { p = hair; }
    else if (cat == 'eye_color') { p = eye; }
    else if (cat == 'background') { p = bg; }
    else { p = cloth; }
    return p[(i - 1).clamp(0, p.length - 1) % p.length];
  }

  Widget _bottomBar() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(
          children: [
            OutlinedButton(
              key: const Key('avatar-reset-btn'),
              onPressed: _saving ? null : _reset,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: SwiftSnapTheme.textMuted),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              ),
              child: const Text('Reset', style: TextStyle(color: SwiftSnapTheme.textSecondary)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  key: const Key('avatar-save-btn'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SwiftSnapTheme.primaryPurple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Save Avatar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
