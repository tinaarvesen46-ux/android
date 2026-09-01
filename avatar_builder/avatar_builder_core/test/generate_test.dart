import 'dart:io';
import 'dart:math';

import 'package:avatar_builder_core/avatar_builder_core.dart';
import 'package:test/test.dart';

/// Assets directory on disk, relative to package root.
const _diskAssetsDir = 'lib/assets';

/// An [AssetLoader] that reads from the local filesystem.
Future<String> _fileLoader(String key) async {
  if (key.isEmpty) return '';
  return File('$_diskAssetsDir/$key').readAsString();
}

void main() {
  test('toSvg produces valid SVG document', () async {
    final avatar = Avataaar();
    final svg = await avatar.toSvg(loadAsset: _fileLoader);

    expect(svg, startsWith('<svg'));
    expect(svg, endsWith('</svg>'));
    expect(svg, contains('xmlns="http://www.w3.org/2000/svg"'));
    expect(svg, contains('xmlns:xlink="http://www.w3.org/1999/xlink"'));
    expect(svg, contains('viewBox="0 0 264 280"'));
  });

  test('toSvg with colorMapped: false retains sentinel colors', () async {
    final avatar = Avataaar();
    final svg = await avatar.toSvg(loadAsset: _fileLoader, colorMapped: false);

    expect(svg.toLowerCase(), contains('#ae5d29'));
  });

  test('toSvg applies color mapping by default', () async {
    final avatar = Avataaar(skinColor: SkinColor.pale.color);
    final svg = await avatar.toSvg(loadAsset: _fileLoader);

    expect(svg.toLowerCase(), isNot(contains('#ae5d29')));
    expect(svg, contains('#FFDBB4'));
  });

  test('random avatars with same seed are identical', () async {
    final a = Avataaar.random(Random(123));
    final b = Avataaar.random(Random(123));

    final svgA = await a.toSvg(loadAsset: _fileLoader);
    final svgB = await b.toSvg(loadAsset: _fileLoader);

    expect(svgA, equals(svgB));
  });

  test('random avatars with different seeds differ', () async {
    final a = Avataaar.random(Random(1));
    final b = Avataaar.random(Random(2));

    final svgA = await a.toSvg(loadAsset: _fileLoader);
    final svgB = await b.toSvg(loadAsset: _fileLoader);

    expect(svgA, isNot(equals(svgB)));
  });

  test('toSvg circle style includes background elements', () async {
    final avatar = Avataaar();
    final svg = await avatar.toSvg(loadAsset: _fileLoader);

    expect(svg, contains('mask-bg'));
    expect(svg, contains('#65C9FF'));
  });

  test('toSvg transparent style omits background elements', () async {
    final avatar = Avataaar(style: AvatarStyle.transparent);
    final svg = await avatar.toSvg(loadAsset: _fileLoader);

    expect(svg, isNot(contains('mask-bg')));
  });

  test('Avataaar.random() produces valid avatar', () {
    final avatar = Avataaar.random();
    expect(avatar.topType, isNotNull);
    expect(avatar.eyeType, isNotNull);
    expect(avatar.skinColor, isNotNull);
  });

  test('Avataaar.copyWith() preserves unchanged fields', () {
    final original = Avataaar();
    final modified = original.copyWith(eyeType: EyeType.hearts);
    expect(modified.eyeType, EyeType.hearts);
    expect(modified.topType, original.topType);
    expect(modified.skinColor, original.skinColor);
  });

  group('JSON serialisation', () {
    test('toJson produces expected keys', () {
      final avatar = Avataaar();
      final json = avatar.toJson();
      expect(json, containsPair('style', 'circle'));
      expect(json, containsPair('topType', 'longHairStraight'));
      expect(json, containsPair('accessoriesType', 'blank'));
      expect(json, contains('hairColor'));
      expect(json, contains('skinColor'));
    });

    test('roundtrip preserves all fields', () {
      final original = Avataaar(
        style: AvatarStyle.transparent,
        topType: TopType.winterHat2,
        accessoriesType: AccessoriesType.sunglasses,
        hairColor: HairColor.auburn.color,
        hatColor: HatColor.red.color,
        facialHairType: FacialHairType.beardMajestic,
        facialHairColor: FacialHairColor.blonde.color,
        clotheType: ClotheType.graphicShirt,
        clotheColor: ClotheColor.pink.color,
        graphicType: GraphicType.pizza,
        eyeType: EyeType.hearts,
        eyebrowType: EyebrowType.raisedExcitedNatural,
        mouthType: MouthType.smile,
        skinColor: SkinColor.tanned.color,
      );
      final json = original.toJson();
      final restored = Avataaar.fromJson(json);

      expect(restored.style, original.style);
      expect(restored.topType, original.topType);
      expect(restored.accessoriesType, original.accessoriesType);
      expect(restored.hairColor, original.hairColor);
      expect(restored.hatColor, original.hatColor);
      expect(restored.facialHairType, original.facialHairType);
      expect(restored.facialHairColor, original.facialHairColor);
      expect(restored.clotheType, original.clotheType);
      expect(restored.clotheColor, original.clotheColor);
      expect(restored.graphicType, original.graphicType);
      expect(restored.eyeType, original.eyeType);
      expect(restored.eyebrowType, original.eyebrowType);
      expect(restored.mouthType, original.mouthType);
      expect(restored.skinColor, original.skinColor);
    });

    test('roundtrip with custom colors', () {
      final original = Avataaar(
        hairColor: 0xFF123456,
        skinColor: 0xFFABCDEF,
      );
      final json = original.toJson();
      final restored = Avataaar.fromJson(json);
      expect(restored.hairColor, original.hairColor);
      expect(restored.skinColor, original.skinColor);
    });
  });
}
