import 'dart:collection';

import 'package:avatar_builder_core/avatar_builder_core.dart';
import 'package:flutter/services.dart' show rootBundle;

/// LRU cache for loaded SVG asset fragments.
///
/// Assets are loaded on demand via [load] and cached for subsequent access.
/// When [maxEntries] is set, least-recently-used entries are evicted once
/// the cache exceeds that size.
///
/// Use [instance] for the shared global cache, or [SvgCache.fromMap] to
/// create a pre-populated cache for testing.
///
/// The [load] method conforms to [AssetLoader] and can be passed directly
/// to [Avataaar.toSvg] or [buildAvatarSvg]:
///
/// ```dart
/// final svg = await avatar.toSvg(loadAsset: SvgCache.instance.load);
/// ```
class SvgCache {
  /// Create an empty cache that loads assets via [rootBundle].
  SvgCache({this.maxEntries}) : _cache = LinkedHashMap<String, String>();

  /// Create a pre-populated cache (useful for testing).
  ///
  /// Keys must be bare asset keys (e.g. `eyes/close.svgf`), matching the
  /// keys used by [buildAvatarSvg].
  SvgCache.fromMap(Map<String, String> data, {this.maxEntries})
    : _cache = LinkedHashMap<String, String>.of(data);

  /// Shared global cache instance.
  static final SvgCache instance = SvgCache();

  /// The Flutter asset prefix for core package assets.
  static const _assetPrefix = 'packages/avatar_builder_core/lib/assets';

  /// Maximum number of cached entries. When null, entries are never evicted.
  final int? maxEntries;

  final LinkedHashMap<String, String> _cache;

  /// Load an asset by bare key, returning cached content if available.
  ///
  /// The [key] is a bare relative path within the assets directory
  /// (e.g. `eyes/close.svgf`). The Flutter asset prefix is added
  /// automatically.
  ///
  /// Returns an empty string immediately if [key] is empty (used for
  /// variants like "blank" that have no SVG fragment).
  ///
  /// This method conforms to [AssetLoader].
  Future<String> load(String key) async {
    if (key.isEmpty) return '';
    final existing = _cache.remove(key);
    if (existing != null) {
      _cache[key] = existing; // promote to most-recently-used
      return existing;
    }
    final content = await rootBundle.loadString('$_assetPrefix/$key');
    _cache[key] = content;
    _evict();
    return content;
  }

  /// Get a previously loaded fragment by bare key.
  /// Throws if not yet loaded.
  String operator [](String key) => _cache[key]!;

  void _evict() {
    final max = maxEntries;
    if (max == null) return;
    while (_cache.length > max) {
      _cache.remove(_cache.keys.first);
    }
  }
}
