import 'package:meta/meta.dart';

/// Maps sentinel colors in SVG data to actual avatar colors via string
/// replacement.
///
/// The SVG fragments contain sentinel hex values (#AE5D29, #E8E1E1,
/// #FF5C5C, #FF488E, #A55728) for skin, hair, hat, clothing, and facial
/// hair colors. This mapper substitutes the real colors when applied to
/// an SVG string.
@immutable
class AvatarColorMapper {
  /// Creates a mapper that substitutes sentinel colors with the given values.
  ///
  /// Colors are ARGB [int] values (e.g. `0xFFAE5D29`).
  const AvatarColorMapper({
    required this.skinColor,
    required this.hairColor,
    required this.hatColor,
    required this.clotheColor,
    required this.facialHairColor,
  });

  // Sentinel hex values baked into SVG fragments during extraction.
  static const String _sentinelSkin = '#ae5d29';
  static const String _sentinelHair = '#e8e1e1';
  static const String _sentinelHairShadow = '#ccb55a';
  static const String _sentinelHat = '#ff5c5c';
  static const String _sentinelClothe = '#ff488e';
  static const String _sentinelFacialHair = '#a55728';

  /// The color to substitute for skin sentinel (ARGB int).
  final int skinColor;

  /// The color to substitute for hair sentinel (ARGB int).
  final int hairColor;

  /// The color to substitute for hat sentinel (ARGB int).
  final int hatColor;

  /// The color to substitute for clothing sentinel (ARGB int).
  final int clotheColor;

  /// The color to substitute for facial hair sentinel (ARGB int).
  final int facialHairColor;

  /// Applies this color mapping directly to an SVG string.
  ///
  /// Performs string replacements substituting the sentinel hex values
  /// with the configured colors.
  String applyToString(String svg) {
    final replacements = <String, String>{
      _sentinelSkin: _toHex(skinColor),
      _sentinelHair: _toHex(hairColor),
      _sentinelHairShadow: _toHex(darken(hairColor, 0.20)),
      _sentinelHat: _toHex(hatColor),
      _sentinelClothe: _toHex(clotheColor),
      _sentinelFacialHair: _toHex(facialHairColor),
    };

    final pattern = replacements.keys.join('|');
    final regex = RegExp(pattern, caseSensitive: false);

    return svg.replaceAllMapped(regex, (match) {
      final key = match.group(0)!.toLowerCase();
      return replacements[key] ?? match.group(0)!;
    });
  }

  /// Converts an ARGB int to a `#RRGGBB` hex string.
  static String _toHex(int argb) {
    final r = (argb >> 16) & 0xFF;
    final g = (argb >> 8) & 0xFF;
    final b = argb & 0xFF;
    return '#${r.toRadixString(16).padLeft(2, '0')}'
            '${g.toRadixString(16).padLeft(2, '0')}'
            '${b.toRadixString(16).padLeft(2, '0')}'
        .toUpperCase();
  }

  /// Darkens a color by reducing its RGB components by [amount] (0.0–1.0).
  static int darken(int argb, double amount) {
    final a = (argb >> 24) & 0xFF;
    var r = (argb >> 16) & 0xFF;
    var g = (argb >> 8) & 0xFF;
    var b = argb & 0xFF;
    r = (r * (1 - amount)).round().clamp(0, 255);
    g = (g * (1 - amount)).round().clamp(0, 255);
    b = (b * (1 - amount)).round().clamp(0, 255);
    return (a << 24) | (r << 16) | (g << 8) | b;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AvatarColorMapper &&
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
