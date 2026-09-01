import 'package:avatar_builder_core/avatar_builder_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Maps sentinel colors in SVG data to actual avatar colors at parse time.
///
/// Used with [SvgStringLoader] for efficient color substitution during SVG
/// parsing. Wraps the core [AvatarColorMapper] logic for Flutter/flutter_svg
/// integration.
@immutable
class FlutterAvatarColorMapper extends ColorMapper {
  /// Creates a mapper that substitutes sentinel colors with the given values.
  ///
  /// Colors are ARGB [int] values (e.g. `0xFFAE5D29`).
  const FlutterAvatarColorMapper({
    required this.skinColor,
    required this.hairColor,
    required this.hatColor,
    required this.clotheColor,
    required this.facialHairColor,
  });

  // Sentinel colors as Color objects for parse-time comparison.
  static const Color _skinSentinel = Color(0xFFAE5D29);
  static const Color _hairSentinel = Color(0xFFE8E1E1);
  static const Color _hairShadowSentinel = Color(0xFFCCB55A);
  static const Color _hatSentinel = Color(0xFFFF5C5C);
  static const Color _clotheSentinel = Color(0xFFFF488E);
  static const Color _facialHairSentinel = Color(0xFFA55728);

  /// The skin color (ARGB int).
  final int skinColor;

  /// The hair color (ARGB int).
  final int hairColor;

  /// The hat color (ARGB int).
  final int hatColor;

  /// The clothing color (ARGB int).
  final int clotheColor;

  /// The facial hair color (ARGB int).
  final int facialHairColor;

  @override
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  ) {
    if (color == _skinSentinel) return Color(skinColor);
    if (color == _hairSentinel) return Color(hairColor);
    if (color == _hairShadowSentinel) {
      return Color(AvatarColorMapper.darken(hairColor, 0.20));
    }
    if (color == _hatSentinel) return Color(hatColor);
    if (color == _clotheSentinel) return Color(clotheColor);
    if (color == _facialHairSentinel) return Color(facialHairColor);
    return color;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FlutterAvatarColorMapper &&
          skinColor == other.skinColor &&
          hairColor == other.hairColor &&
          hatColor == other.hatColor &&
          clotheColor == other.clotheColor &&
          facialHairColor == other.facialHairColor;

  @override
  int get hashCode => Object.hash(
    skinColor,
    hairColor,
    hatColor,
    clotheColor,
    facialHairColor,
  );
}
