/// Filesystem-based `AssetLoader` for pure-Dart (non-Flutter) programs.
///
/// Requires `dart:io`. For Flutter apps, use `SvgCache` from
/// `package:avatar_builder` instead.
///
/// ```dart
/// import 'package:avatar_builder_core/file_asset_loader.dart';
///
/// final loader = await FileAssetLoader.defaultForPackage();
/// final svg = await avatar.toSvg(loadAsset: loader.load);
/// ```
library;

export 'src/svg/file_asset_loader.dart';
