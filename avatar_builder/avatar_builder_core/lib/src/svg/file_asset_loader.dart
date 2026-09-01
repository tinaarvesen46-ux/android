import 'dart:io';
import 'dart:isolate';

import 'package:avatar_builder_core/src/svg/asset_loader.dart';

/// An [AssetLoader] that reads SVG fragment files from the local filesystem.
///
/// For pure-Dart (non-Flutter) programs where `dart:io` is available.
///
/// Use [FileAssetLoader.defaultForPackage] to automatically resolve the
/// `avatar_builder_core` asset directory:
///
/// ```dart
/// final loader = await FileAssetLoader.defaultForPackage();
/// final svg = await avatar.toSvg(loadAsset: loader.load);
/// ```
///
/// Or construct with an explicit directory path:
///
/// ```dart
/// final loader = FileAssetLoader('path/to/assets');
/// ```
class FileAssetLoader {
  /// Creates a loader that reads assets from [assetsDir].
  ///
  /// The [assetsDir] should point to the directory containing the `.svgf`
  /// fragment files (e.g. `lib/assets/` within the `avatar_builder_core`
  /// package).
  FileAssetLoader(this.assetsDir);

  /// The root directory containing the SVG asset fragment files.
  final String assetsDir;

  /// Creates a loader that resolves the `avatar_builder_core` package's
  /// built-in asset directory automatically.
  ///
  /// Uses [Isolate.resolvePackageUri] to locate the package on disk,
  /// which works for `dart run`, `dart test`, and compiled executables
  /// when a `.dart_tool/package_config.json` is available.
  static Future<FileAssetLoader> defaultForPackage() async {
    final uri = await Isolate.resolvePackageUri(
      Uri.parse('package:avatar_builder_core/assets/'),
    );
    if (uri == null) {
      throw StateError(
        'Could not resolve avatar_builder_core asset directory. '
        'Use FileAssetLoader(path) with an explicit path instead.',
      );
    }
    return FileAssetLoader(uri.toFilePath());
  }

  /// Loads an SVG fragment by its bare asset key.
  ///
  /// Returns an empty string for empty keys (used by "blank" variants).
  ///
  /// This method conforms to [AssetLoader].
  Future<String> load(String key) async {
    if (key.isEmpty) return '';
    return File('$assetsDir/$key').readAsString();
  }
}
