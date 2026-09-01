import 'dart:math';

import 'package:avatar_builder_core/src/models/avatar_style.dart';
import 'package:avatar_builder_core/src/svg/asset_loader.dart';
import 'package:avatar_builder_core/src/svg/color_mapper.dart';
import 'package:avatar_builder_core/src/svg/svg_data.dart';

export 'package:avatar_builder_core/src/models/avatar_style.dart';

/// Holds the full set of selected avatar attributes.
///
/// Color fields store ARGB [int] values directly, allowing both predefined
/// palette colors (via the enums in `avatar_style.dart`) and fully custom
/// colors. Use the convenience getters like [hairColorEnum] to look up
/// the matching palette entry (returns `null` for custom colors).
class Avataaar {
  /// Creates an avatar with the given attributes, using sensible defaults.
  Avataaar({
    this.style = AvatarStyle.circle,
    this.topType = TopType.longHairStraight,
    this.accessoriesType = AccessoriesType.blank,
    int? hairColor,
    int? hatColor,
    this.facialHairType = FacialHairType.blank,
    int? facialHairColor,
    this.clotheType = ClotheType.shirtCrewNeck,
    int? clotheColor,
    this.graphicType = GraphicType.bat,
    this.eyeType = EyeType.defaultEye,
    this.eyebrowType = EyebrowType.defaultBrow,
    this.mouthType = MouthType.defaultMouth,
    int? skinColor,
  }) : hairColor = hairColor ?? HairColor.brownDark.color,
       hatColor = hatColor ?? HatColor.gray01.color,
       facialHairColor = facialHairColor ?? FacialHairColor.brownDark.color,
       clotheColor = clotheColor ?? ClotheColor.gray01.color,
       skinColor = skinColor ?? SkinColor.light.color;

  /// Generate a completely random avatar.
  factory Avataaar.random([Random? rng]) {
    final r = rng ?? Random();
    T pick<T>(List<T> values) => values[r.nextInt(values.length)];

    return Avataaar(
      style: pick(AvatarStyle.values),
      topType: pick(TopType.values),
      accessoriesType: _weightedPick(r, _accessoriesWeights),
      hairColor: pick(HairColor.values).color,
      hatColor: pick(HatColor.values).color,
      facialHairType: _weightedPick(r, _facialHairWeights),
      facialHairColor: pick(FacialHairColor.values).color,
      clotheType: pick(ClotheType.values),
      clotheColor: pick(ClotheColor.values).color,
      graphicType: pick(GraphicType.values),
      eyeType: _weightedPick(r, _eyeWeights),
      eyebrowType: pick(EyebrowType.values),
      mouthType: _weightedPick(r, _mouthWeights),
      skinColor: pick(SkinColor.values).color,
    );
  }

  /// Creates an [Avataaar] from a JSON map (as produced by [toJson]).
  factory Avataaar.fromJson(Map<String, dynamic> json) {
    return Avataaar(
      style: AvatarStyle.values.byName(json['style'] as String),
      topType: TopType.values.byName(json['topType'] as String),
      accessoriesType: AccessoriesType.values.byName(
        json['accessoriesType'] as String,
      ),
      hairColor: _hexToArgb(json['hairColor'] as String),
      hatColor: _hexToArgb(json['hatColor'] as String),
      facialHairType: FacialHairType.values.byName(
        json['facialHairType'] as String,
      ),
      facialHairColor: _hexToArgb(json['facialHairColor'] as String),
      clotheType: ClotheType.values.byName(json['clotheType'] as String),
      clotheColor: _hexToArgb(json['clotheColor'] as String),
      graphicType: GraphicType.values.byName(json['graphicType'] as String),
      eyeType: EyeType.values.byName(json['eyeType'] as String),
      eyebrowType: EyebrowType.values.byName(json['eyebrowType'] as String),
      mouthType: MouthType.values.byName(json['mouthType'] as String),
      skinColor: _hexToArgb(json['skinColor'] as String),
    );
  }

  // Weights for random avatar generation. Higher values = more likely.
  static const Map<AccessoriesType, int> _accessoriesWeights = {
    AccessoriesType.blank: 3,
    AccessoriesType.kurt: 1,
    AccessoriesType.prescription01: 1,
    AccessoriesType.prescription02: 1,
    AccessoriesType.round: 1,
    AccessoriesType.sunglasses: 1,
    AccessoriesType.wayfarers: 1,
  };

  static const Map<FacialHairType, int> _facialHairWeights = {
    FacialHairType.blank: 5,
    FacialHairType.beardLight: 1,
    FacialHairType.beardMajestic: 1,
    FacialHairType.beardMedium: 1,
    FacialHairType.moustacheFancy: 1,
    FacialHairType.moustacheMagnum: 1,
  };

  static const Map<EyeType, int> _eyeWeights = {
    EyeType.close: 1,
    EyeType.cry: 1,
    EyeType.defaultEye: 3,
    EyeType.dizzy: 1,
    EyeType.eyeRoll: 1,
    EyeType.happy: 3,
    EyeType.hearts: 1,
    EyeType.side: 3,
    EyeType.squint: 3,
    EyeType.surprised: 3,
    EyeType.wink: 1,
    EyeType.winkWacky: 1,
  };

  static const Map<MouthType, int> _mouthWeights = {
    MouthType.concerned: 3,
    MouthType.defaultMouth: 3,
    MouthType.disbelief: 1,
    MouthType.eating: 1,
    MouthType.grimace: 1,
    MouthType.sad: 1,
    MouthType.screamOpen: 1,
    MouthType.serious: 3,
    MouthType.smile: 3,
    MouthType.tongue: 1,
    MouthType.twinkle: 3,
    MouthType.vomit: 1,
  };

  /// Picks a random value from [weights] using weighted random selection.
  static T _weightedPick<T>(Random r, Map<T, int> weights) {
    var roll = r.nextInt(weights.values.fold(0, (a, b) => a + b));
    for (final entry in weights.entries) {
      roll -= entry.value;
      if (roll < 0) return entry.key;
    }
    return weights.keys.last;
  }

  /// Returns the [HairColor] enum matching [hairColor], or `null`.
  HairColor? get hairColorEnum =>
      HairColor.values.where((e) => e.color == hairColor).firstOrNull;

  /// Returns the [HatColor] enum matching [hatColor], or `null`.
  HatColor? get hatColorEnum =>
      HatColor.values.where((e) => e.color == hatColor).firstOrNull;

  /// Returns the [FacialHairColor] enum matching [facialHairColor],
  /// or `null`.
  FacialHairColor? get facialHairColorEnum => FacialHairColor.values
      .where((e) => e.color == facialHairColor)
      .firstOrNull;

  /// Returns the [ClotheColor] enum matching [clotheColor], or `null`.
  ClotheColor? get clotheColorEnum =>
      ClotheColor.values.where((e) => e.color == clotheColor).firstOrNull;

  /// Returns the [SkinColor] enum matching [skinColor], or `null`.
  SkinColor? get skinColorEnum =>
      SkinColor.values.where((e) => e.color == skinColor).firstOrNull;

  /// The background style of the avatar.
  AvatarStyle style;

  /// The hair or hat type.
  TopType topType;

  /// The accessories (glasses) type.
  AccessoriesType accessoriesType;

  /// The hair color (ARGB int).
  int hairColor;

  /// The hat color (ARGB int).
  int hatColor;

  /// The facial hair type.
  FacialHairType facialHairType;

  /// The facial hair color (ARGB int).
  int facialHairColor;

  /// The clothing type.
  ClotheType clotheType;

  /// The clothing color (ARGB int).
  int clotheColor;

  /// The graphic on a graphic shirt.
  GraphicType graphicType;

  /// The eye type.
  EyeType eyeType;

  /// The eyebrow type.
  EyebrowType eyebrowType;

  /// The mouth type.
  MouthType mouthType;

  /// The skin color (ARGB int).
  int skinColor;

  /// Serialises this avatar to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'style': style.name,
      'topType': topType.name,
      'accessoriesType': accessoriesType.name,
      'hairColor': _argbToHex(hairColor),
      'hatColor': _argbToHex(hatColor),
      'facialHairType': facialHairType.name,
      'facialHairColor': _argbToHex(facialHairColor),
      'clotheType': clotheType.name,
      'clotheColor': _argbToHex(clotheColor),
      'graphicType': graphicType.name,
      'eyeType': eyeType.name,
      'eyebrowType': eyebrowType.name,
      'mouthType': mouthType.name,
      'skinColor': _argbToHex(skinColor),
    };
  }

  /// Renders the avatar into an SVG string.
  ///
  /// Loads required SVG asset fragments asynchronously via the provided
  /// [loadAsset] function.
  ///
  /// If [colorMapped] is true (the default), color placeholders are replaced
  /// with the avatar's configured colors. If false, the raw SVG is returned
  /// with sentinel hex values untouched.
  Future<String> toSvg({
    required AssetLoader loadAsset,
    bool colorMapped = true,
  }) async {
    var svgStr = await buildAvatarSvg(
      loadAsset: loadAsset,
      style: style,
      topType: topType,
      accessoriesType: accessoriesType,
      facialHairType: facialHairType,
      clotheType: clotheType,
      graphicType: graphicType,
      eyeType: eyeType,
      eyebrowType: eyebrowType,
      mouthType: mouthType,
    );

    if (!svgStr.contains('xmlns="http://www.w3.org/2000/svg"')) {
      svgStr = svgStr.replaceFirst(
        '<svg',
        '<svg xmlns="http://www.w3.org/2000/svg"',
      );
    }

    if (!colorMapped) return svgStr;

    final mapper = AvatarColorMapper(
      skinColor: skinColor,
      hairColor: hairColor,
      hatColor: hatColor,
      clotheColor: clotheColor,
      facialHairColor: facialHairColor,
    );

    return mapper.applyToString(svgStr);
  }

  /// Creates a copy with the given fields replaced.
  Avataaar copyWith({
    AvatarStyle? style,
    TopType? topType,
    AccessoriesType? accessoriesType,
    int? hairColor,
    int? hatColor,
    FacialHairType? facialHairType,
    int? facialHairColor,
    ClotheType? clotheType,
    int? clotheColor,
    GraphicType? graphicType,
    EyeType? eyeType,
    EyebrowType? eyebrowType,
    MouthType? mouthType,
    int? skinColor,
  }) {
    return Avataaar(
      style: style ?? this.style,
      topType: topType ?? this.topType,
      accessoriesType: accessoriesType ?? this.accessoriesType,
      hairColor: hairColor ?? this.hairColor,
      hatColor: hatColor ?? this.hatColor,
      facialHairType: facialHairType ?? this.facialHairType,
      facialHairColor: facialHairColor ?? this.facialHairColor,
      clotheType: clotheType ?? this.clotheType,
      clotheColor: clotheColor ?? this.clotheColor,
      graphicType: graphicType ?? this.graphicType,
      eyeType: eyeType ?? this.eyeType,
      eyebrowType: eyebrowType ?? this.eyebrowType,
      mouthType: mouthType ?? this.mouthType,
      skinColor: skinColor ?? this.skinColor,
    );
  }

  static String _argbToHex(int c) {
    final r = (c >> 16) & 0xFF;
    final g = (c >> 8) & 0xFF;
    final b = c & 0xFF;
    return '#${r.toRadixString(16).padLeft(2, '0')}'
            '${g.toRadixString(16).padLeft(2, '0')}'
            '${b.toRadixString(16).padLeft(2, '0')}'
        .toUpperCase();
  }

  static int _hexToArgb(String hex) {
    final value = int.parse(hex.substring(1), radix: 16);
    return 0xFF000000 | value;
  }
}
