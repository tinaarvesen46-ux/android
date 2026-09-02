import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/social_provider.dart';
import '../core/api_failure.dart';
import '../repositories/social_repository.dart';
import '../services/api_service.dart';
import '../theme/theme.dart';
import '../widgets/common/app_top_bar.dart';
import '../widgets/common/avatar_asset_image.dart';

/// SwiftSnap-native avatar builder. The configuration is stored locally and
/// synced to the backend so it can be rendered anywhere the user appears.
class AvatarStudioScreen extends StatefulWidget {
  const AvatarStudioScreen({super.key});

  @override
  State<AvatarStudioScreen> createState() => _AvatarStudioScreenState();
}

class _AvatarStudioScreenState extends State<AvatarStudioScreen> {
  bool _saving = false;
  bool _loading = true;
  String? _error;
  Map<String, List<Map<String, dynamic>>> _catalog = {};

  @override
  void initState() {
    super.initState();
    _loadCatalog();
  }

  Future<void> _loadCatalog() async {
    if (mounted) setState(() { _loading = true; _error = null; });
    try {
      final repo = context.read<SocialRepository>();
      final merged = <String, dynamic>{'items': <dynamic>[]};
      Map<String, dynamic> catalog = const <String, dynamic>{};
      var paged = false;
      var page = 1;
      while (true) {
        catalog = await repo.fetchAvatarCatalog(page: page, perPage: 100);
        final items = catalog['items'];
        if (items is! List) break;
        paged = true;
        if (items.isEmpty) break;
        (merged['items'] as List<dynamic>).addAll(items);
        if (items.length < 100) break;
        page++;
      }
      // Support multiple backend shapes:
      // 1) Paged response: { total, page, per_page, items: [...] }
      // 2) Catalog map: { category: [ { asset... }, ... ], ... }
      final Map<String, List<Map<String, dynamic>>> grouped = {};
      if (paged) {
        final items = merged['items'] as List;
        for (final it in items) {
          final Map<String, dynamic> m = Map<String, dynamic>.from(it);
          final cat = (m['category'] as String?) ?? 'misc';
          grouped[cat] = (grouped[cat] ?? [])..add(m);
        }
      } else {
        // assume top-level is category -> list
        for (final entry in catalog.entries) {
          if (entry.value is List) {
            final List vals = entry.value as List;
            grouped[entry.key] = vals.map((v) => Map<String, dynamic>.from(v)).toList();
          }
        }
      }
      if (mounted) setState(() => _catalog = grouped);
    } on ApiFailure catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'The avatar catalog could not be loaded.');
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final settings = context.read<SettingsProvider>();
    final error =
        await context.read<SocialProvider>().saveAvatarConfig(settings.avatarConfig);
    if (!mounted) return;
    if (error == null) {
      await context.read<AuthProvider>().hydrateFromExistingSession();
      if (!mounted) return;
    }
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? 'Avatar saved.')),
    );
  }

  Future<void> _reset() async {
    if (mounted) setState(() => _saving = true);
    final error = await context.read<SocialProvider>().resetAvatar();
    if (!mounted) return;
    if (error != null) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    await context.read<AuthProvider>().hydrateFromExistingSession();
    if (!mounted) return;
    await context.read<SettingsProvider>().resetAvatar();
    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      body: Column(
        children: [
          const AppTopBar(showBack: true, title: 'Avatar studio'),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : (_error != null
                    ? Center(
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.error_outline, size: 48),
                          const SizedBox(height: AppTheme.spacingMd),
                          Text(_error!, textAlign: TextAlign.center),
                          const SizedBox(height: AppTheme.spacingMd),
                          OutlinedButton(onPressed: _loadCatalog, child: const Text('Retry')),
                        ]),
                      )
                    : (_catalog.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.face_retouching_natural, size: 64, color: theme.colorScheme.primary),
                              const SizedBox(height: AppTheme.spacingMd),
                              const Text('No avatar assets available yet.'),
                              const SizedBox(height: AppTheme.spacingSm),
                              const Text('Once the SwiftMoji catalog is imported on the server, thumbnails will appear here.'),
                            ],
                          ),
                        ),
                      )
                    : DefaultTabController(
                        length: _catalog.keys.length,
                        child: Column(
                          children: [
                            TabBar(
                              isScrollable: true,
                              tabs: _catalog.keys.map((k) => Tab(text: k[0].toUpperCase() + k.substring(1))).toList(),
                            ),
                            Expanded(
                              child: TabBarView(
                                children: _catalog.keys.map((k) {
                                  final list = _catalog[k]!;
                                  return Padding(
                                    padding: const EdgeInsets.all(AppTheme.spacingLg),
                                    child: GridView.builder(
                                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                        maxCrossAxisExtent: 112,
                                        crossAxisSpacing: AppTheme.spacingSm,
                                        mainAxisSpacing: AppTheme.spacingSm,
                                        childAspectRatio: 1,
                                      ),
                                      itemCount: list.length,
                                      itemBuilder: (ctx, i) {
                                        final it = Map<String, dynamic>.from(list[i]);
                                        final aid = (it['asset_id'] ?? it['id'] ?? '').toString();
                                        final selected = (settings.avatarConfig['${k}'] ?? '') == aid;
                                        // Determine availability: explicit `available` flag from API first,
                                        // fall back to presence of a filename (imported asset).
                                        final bool available = it['available'] == true;

                                        return GestureDetector(
                                          onTap: !available
                                              ? () {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(content: Text('This item is not available on the server.')),
                                                  );
                                                }
                                              : () async {
                                                  try {
                                                    await settings.setAvatarPart(k, aid);
                                                    setState(() {});
                                                  } catch (e) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text('Failed to select avatar part: $e')),
                                                    );
                                                  }
                                                },
                                          onLongPress: () {
                                            // Long-press shows a preview (if thumbnail exists) or details dialog
                                            showDialog(
                                              context: context,
                                              builder: (_) => AlertDialog(
                                                title: Text(it['name'] ?? aid),
                                                content: SizedBox(
                                                  width: 280,
                                                  height: 280,
                                                  child: _CatalogAssetImage(
                                                    asset: it,
                                                    fit: BoxFit.contain,
                                                    fallback: Text(
                                                      available ? 'Preview unavailable' : 'Item not available',
                                                      style: theme.textTheme.bodyMedium,
                                                    ),
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
                                                  if (available)
                                                    TextButton(
                                                      onPressed: () async {
                                                        Navigator.of(context).pop();
                                                        try {
                                                          await settings.setAvatarPart(k, aid);
                                                          setState(() {});
                                                        } catch (e) {
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            SnackBar(content: Text('Failed to select avatar part: $e')),
                                                          );
                                                        }
                                                      },
                                                      child: const Text('Use'),
                                                    ),
                                                ],
                                              ),
                                            );
                                          },
                                          child: Stack(
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: theme.colorScheme.surface,
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: selected ? Border.all(color: theme.colorScheme.primary, width: 2) : null,
                                                ),
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(8),
                                                    child: _CatalogAssetImage(
                                                      asset: it,
                                                      fit: BoxFit.cover,
                                                      fallback: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Icon(Icons.image_not_supported, size: 28, color: theme.colorScheme.onSurfaceVariant),
                                                          const SizedBox(height: AppTheme.spacingSm),
                                                          Text(aid, style: theme.textTheme.bodySmall),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                              ),
                                              if (!available)
                                                Positioned.fill(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.black.withOpacity(0.45),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Center(
                                                      child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Icon(Icons.block, color: Colors.white70),
                                                          const SizedBox(height: AppTheme.spacingSm),
                                                          const Text('Unavailable', style: TextStyle(color: Colors.white70)),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(AppTheme.spacingLg),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: _saving ? null : _save,
                                      child: _saving
                                          ? const SizedBox(
                                              width: AppTheme.iconSm,
                                              height: AppTheme.iconSm,
                                              child: CircularProgressIndicator(
                                                strokeWidth: AppTheme.borderThick,
                                              ),
                                            )
                                          : const Text('Save avatar'),
                                    ),
                                  ),
                                  const SizedBox(width: AppTheme.spacingSm),
                                  OutlinedButton(onPressed: _saving ? null : _reset, child: const Text('Reset')),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ))),
          ),
        ],
      ),
    );
  }
}

/// Catalog assets include both PNG files and the imported SVGF artwork. The
/// API deliberately exposes one thumbnail URL for both, so choose the decoder
/// from the asset filename instead of asking Flutter's raster decoder to read
/// an SVG document.
class _CatalogAssetImage extends StatelessWidget {
  final Map<String, dynamic> asset;
  final BoxFit fit;
  final Widget fallback;

  const _CatalogAssetImage({
    required this.asset,
    required this.fit,
    required this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final rawUrl = asset['thumbnail_url'];
    final url = rawUrl is String && rawUrl.trim().isNotEmpty
        ? ApiService.resolveUrl(rawUrl)
        : null;
    if (url == null) return Center(child: fallback);

    return AvatarAssetImage(
      url: url,
      filename: asset['filename']?.toString(),
      fit: fit,
      fallback: Center(child: fallback),
    );
  }
}
