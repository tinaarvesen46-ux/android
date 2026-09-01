/// Flutter widget for rendering avataaars-style avatars.
///
/// Re-exports the pure Dart core (`Avataaar`, enums, `buildAvatarSvg`,
/// `AvatarColorMapper`) and adds Flutter-specific components:
/// `SvgCache` for rootBundle-based asset loading,
/// `FlutterAvatarColorMapper` for parse-time SVG color mapping,
/// and `AvatarWidget` for rendering.
library;

export 'package:avatar_builder_core/avatar_builder_core.dart';
export 'src/svg/svg_cache.dart';
export 'src/widgets/avatar_widget.dart';
export 'src/widgets/flutter_avatar_color_mapper.dart';
