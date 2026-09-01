/// Pure Dart library for building avataaars-style cartoon avatars as SVG.
///
/// Provides the `Avataaar` model, all style enums, SVG composition via
/// `buildAvatarSvg`, and a pluggable `AssetLoader` for loading SVG fragments
/// from any source (filesystem, Flutter asset bundle, etc.).
///
/// For programs with `dart:io` available, import
/// `package:avatar_builder_core/file_asset_loader.dart` for a ready-made
/// filesystem-based `AssetLoader`.
library;

export 'src/models/avataaar.dart';
export 'src/models/avatar_style.dart';
export 'src/svg/asset_loader.dart';
export 'src/svg/color_mapper.dart';
export 'src/svg/svg_data.dart' show buildAvatarSvg;
