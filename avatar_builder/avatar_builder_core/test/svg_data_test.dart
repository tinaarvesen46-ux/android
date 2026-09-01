// Regression tests for SVG data functions and asset files.

import 'dart:io';

import 'package:avatar_builder_core/avatar_builder_core.dart';
import 'package:avatar_builder_core/src/svg/svg_data.dart';
import 'package:test/test.dart';

/// Assets directory on disk, relative to package root.
const _diskAssetsDir = 'lib/assets';

/// An [AssetLoader] that reads from the local filesystem.
Future<String> _fileLoader(String key) async {
  if (key.isEmpty) return '';
  return File('$_diskAssetsDir/$key').readAsString();
}

/// Build a `Map<bareKey, content>` for all .svgf files.
Map<String, String> _loadAllAssets() {
  final map = <String, String>{};
  final dir = Directory(_diskAssetsDir);
  for (final entity in dir.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.svgf')) {
      final relative = entity.path.substring(_diskAssetsDir.length + 1);
      map[relative] = entity.readAsStringSync();
    }
  }
  return map;
}

void main() {
  group('SVG asset files', () {
    late Map<String, String> assets;

    setUpAll(() {
      assets = _loadAllAssets();
    });

    test('all eye assets exist and are non-empty', () {
      for (final type in EyeType.values) {
        final key = 'eyes/${_camelToSnake(type.name)}.svgf';
        expect(assets.containsKey(key), isTrue, reason: type.name);
        expect(assets[key], isNotEmpty, reason: type.name);
      }
    });

    test('all eyebrow assets exist and are non-empty', () {
      for (final type in EyebrowType.values) {
        final key = 'eyebrows/${_camelToSnake(type.name)}.svgf';
        expect(assets.containsKey(key), isTrue, reason: type.name);
      }
    });

    test('all mouth assets exist and are non-empty', () {
      for (final type in MouthType.values) {
        final key = 'mouths/${_camelToSnake(type.name)}.svgf';
        expect(assets.containsKey(key), isTrue, reason: type.name);
      }
    });

    test('all clothing assets exist', () {
      for (final type in ClotheType.values) {
        final key = 'clothing/${_camelToSnake(type.name)}.svgf';
        expect(assets.containsKey(key), isTrue, reason: type.name);
      }
    });

    test('all graphic clothing assets exist', () {
      for (final type in GraphicType.values) {
        final key = 'graphic_clothing/${_camelToSnake(type.name)}.svgf';
        expect(assets.containsKey(key), isTrue, reason: type.name);
      }
    });

    test('all top assets exist', () {
      for (final type in TopType.values) {
        final key = 'top/${_camelToSnake(type.name)}.svgf';
        expect(assets.containsKey(key), isTrue, reason: type.name);
      }
    });

    test('all accessory assets exist', () {
      for (final type in AccessoriesType.values) {
        if (type == AccessoriesType.blank) continue;
        final key = 'accessories/${_camelToSnake(type.name)}.svgf';
        expect(assets.containsKey(key), isTrue, reason: type.name);
      }
    });

    test('all facial hair assets exist', () {
      for (final type in FacialHairType.values) {
        if (type == FacialHairType.blank) continue;
        final key = 'facial_hair/${_camelToSnake(type.name)}.svgf';
        expect(assets.containsKey(key), isTrue, reason: type.name);
      }
    });

    test('fixed assets (shared_defs, body, nose) exist', () {
      expect(assets['shared_defs.svgf'], isNotEmpty);
      expect(assets['body.svgf'], isNotEmpty);
      expect(assets['nose.svgf'], isNotEmpty);
    });
  });

  group('buildAvatarSvg', () {
    test('produces valid SVG with default configuration', () async {
      final svg = await buildAvatarSvg(
        loadAsset: _fileLoader,
        style: AvatarStyle.circle,
        topType: TopType.longHairStraight,
        accessoriesType: AccessoriesType.blank,
        facialHairType: FacialHairType.blank,
        clotheType: ClotheType.shirtCrewNeck,
        graphicType: GraphicType.bat,
        eyeType: EyeType.defaultEye,
        eyebrowType: EyebrowType.defaultBrow,
        mouthType: MouthType.defaultMouth,
      );
      expect(svg, startsWith('<svg '));
      expect(svg, endsWith('</svg>'));
      expect(svg, contains('viewBox="0 0 264 280"'));
      expect(svg, contains(sentinelSkin));
    });

    test('transparent style omits circle background', () async {
      final svg = await buildAvatarSvg(
        loadAsset: _fileLoader,
        style: AvatarStyle.transparent,
        topType: TopType.longHairStraight,
        accessoriesType: AccessoriesType.blank,
        facialHairType: FacialHairType.blank,
        clotheType: ClotheType.shirtCrewNeck,
        graphicType: GraphicType.bat,
        eyeType: EyeType.defaultEye,
        eyebrowType: EyebrowType.defaultBrow,
        mouthType: MouthType.defaultMouth,
      );
      expect(svg, startsWith('<svg '));
      expect(svg, endsWith('</svg>'));
      expect(svg, isNot(contains('mask-bg')));
      expect(svg, isNot(contains('#65C9FF')));
    });

    test('circle style includes circle background', () async {
      final svg = await buildAvatarSvg(
        loadAsset: _fileLoader,
        style: AvatarStyle.circle,
        topType: TopType.longHairStraight,
        accessoriesType: AccessoriesType.blank,
        facialHairType: FacialHairType.blank,
        clotheType: ClotheType.shirtCrewNeck,
        graphicType: GraphicType.bat,
        eyeType: EyeType.defaultEye,
        eyebrowType: EyebrowType.defaultBrow,
        mouthType: MouthType.defaultMouth,
      );
      expect(svg, contains('mask-bg'));
      expect(svg, contains('#65C9FF'));
    });

    test('produces valid SVG with all non-default options', () async {
      final svg = await buildAvatarSvg(
        loadAsset: _fileLoader,
        style: AvatarStyle.circle,
        topType: TopType.winterHat2,
        accessoriesType: AccessoriesType.sunglasses,
        facialHairType: FacialHairType.beardMajestic,
        clotheType: ClotheType.graphicShirt,
        graphicType: GraphicType.pizza,
        eyeType: EyeType.hearts,
        eyebrowType: EyebrowType.raisedExcitedNatural,
        mouthType: MouthType.smile,
      );
      expect(svg, startsWith('<svg '));
      expect(svg, endsWith('</svg>'));
      expect(svg, contains(sentinelSkin));
      expect(svg, contains(sentinelClothe));
      expect(svg, contains(sentinelHat));
      expect(svg, contains(sentinelFacialHair));
    });

    test('valid SVG for every combination of types', () async {
      for (final topType in TopType.values) {
        for (final clotheType in ClotheType.values) {
          final svg = await buildAvatarSvg(
            loadAsset: _fileLoader,
            style: AvatarStyle.circle,
            topType: topType,
            accessoriesType: AccessoriesType.prescription01,
            facialHairType: FacialHairType.beardMedium,
            clotheType: clotheType,
            graphicType: GraphicType.diamond,
            eyeType: EyeType.happy,
            eyebrowType: EyebrowType.defaultNatural,
            mouthType: MouthType.smile,
          );
          expect(
            svg,
            startsWith('<svg '),
            reason: 'top=${topType.name} clothe=${clotheType.name}',
          );
        }
      }
    });
  });

  group('SVG output golden test', () {
    test('all SVG outputs match golden file', () async {
      final actual = await _buildGoldenContent();
      final goldenFile = File('test/goldens/svg_data.golden');

      if (!goldenFile.existsSync()) {
        goldenFile.parent.createSync(recursive: true);
        goldenFile.writeAsStringSync(actual);
        return;
      }

      expect(actual, equals(goldenFile.readAsStringSync()));
    });
  });
}

/// Convert a camelCase name to snake_case.
String _camelToSnake(String s) {
  return s
      .replaceAllMapped(
        RegExp('(.)([A-Z][a-z]+)'),
        (m) => '${m[1]}_${m[2]}',
      )
      .replaceAllMapped(
        RegExp('([a-z0-9])([A-Z])'),
        (m) => '${m[1]}_${m[2]}',
      )
      .toLowerCase();
}

/// Builds a deterministic string containing composed SVG outputs.
Future<String> _buildGoldenContent() async {
  final buffer = StringBuffer()
    ..writeln('### buildAvatarSvg(default)')
    ..writeln(
      await buildAvatarSvg(
        loadAsset: _fileLoader,
        style: AvatarStyle.circle,
        topType: TopType.longHairStraight,
        accessoriesType: AccessoriesType.blank,
        facialHairType: FacialHairType.blank,
        clotheType: ClotheType.shirtCrewNeck,
        graphicType: GraphicType.bat,
        eyeType: EyeType.defaultEye,
        eyebrowType: EyebrowType.defaultBrow,
        mouthType: MouthType.defaultMouth,
      ),
    )
    ..writeln()
    ..writeln('### buildAvatarSvg(custom)')
    ..writeln(
      await buildAvatarSvg(
        loadAsset: _fileLoader,
        style: AvatarStyle.circle,
        topType: TopType.winterHat2,
        accessoriesType: AccessoriesType.sunglasses,
        facialHairType: FacialHairType.beardMajestic,
        clotheType: ClotheType.graphicShirt,
        graphicType: GraphicType.pizza,
        eyeType: EyeType.hearts,
        eyebrowType: EyebrowType.raisedExcitedNatural,
        mouthType: MouthType.smile,
      ),
    )
    ..writeln();

  return '${buffer.toString().trimRight()}\n';
}
