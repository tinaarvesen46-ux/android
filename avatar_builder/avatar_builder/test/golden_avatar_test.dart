@Tags(['golden', 'mac'])
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:avatar_builder/avatar_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Read all SVG asset files from disk and return an [SvgCache] populated
/// with pairs of (bare asset key -> file content).
SvgCache _loadCacheFromDisk() {
  const diskPrefix = '../avatar_builder_core/lib/assets';
  final map = <String, String>{};

  final dir = Directory(diskPrefix);
  for (final entity in dir.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.svgf')) {
      final relative = entity.path.substring(diskPrefix.length + 1);
      map[relative] = entity.readAsStringSync();
    }
  }
  return SvgCache.fromMap(map);
}

/// A default avatar used as the base for all golden tests.
/// Each test varies one attribute from this baseline.
final _base = Avataaar(
  topType: TopType.shortHairShortFlat,
  clotheColor: ClotheColor.heather.color,
);

/// Pump an [AvatarWidget] and match against a golden file.
Future<void> _goldenTest(
  WidgetTester tester,
  SvgCache cache,
  Avataaar avatar,
  String name,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: RepaintBoundary(
            child: AvatarWidget(avatar: avatar, cache: cache),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  await expectLater(
    find.byType(AvatarWidget),
    matchesGoldenFile('goldens/avatars/$name.png'),
  );
}

/// A [LocalFileComparator] that tolerates small pixel differences.
class _TolerantComparator extends LocalFileComparator {
  _TolerantComparator(super.testFile);

  static const double _kTolerance = 0.01;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );
    if (!result.passed && result.diffPercent <= _kTolerance) {
      return true;
    }
    if (!result.passed) {
      final error = await generateFailureOutput(result, golden, basedir);
      throw FlutterError(error);
    }
    return result.passed;
  }
}

void main() {
  late SvgCache cache;

  setUpAll(() {
    cache = _loadCacheFromDisk();

    goldenFileComparator = _TolerantComparator(
      Uri.parse('test/golden_avatar_test.dart'),
    );
  });

  group('TopType', () {
    for (final value in TopType.values) {
      testWidgets(value.name, (tester) async {
        await _goldenTest(
          tester,
          cache,
          _base.copyWith(topType: value),
          'top_${value.name}',
        );
      });
    }
  });

  group('AccessoriesType', () {
    for (final value in AccessoriesType.values) {
      testWidgets(value.name, (tester) async {
        await _goldenTest(
          tester,
          cache,
          _base.copyWith(accessoriesType: value),
          'accessories_${value.name}',
        );
      });
    }
  });

  group('HairColor', () {
    for (final value in HairColor.values) {
      testWidgets(value.name, (tester) async {
        await _goldenTest(
          tester,
          cache,
          _base.copyWith(
            topType: TopType.longHairStraight,
            hairColor: value.color,
          ),
          'hair_color_${value.name}',
        );
      });
    }
  });

  group('HatColor', () {
    for (final value in HatColor.values) {
      testWidgets(value.name, (tester) async {
        await _goldenTest(
          tester,
          cache,
          _base.copyWith(topType: TopType.winterHat1, hatColor: value.color),
          'hat_color_${value.name}',
        );
      });
    }
  });

  group('FacialHairType', () {
    for (final value in FacialHairType.values) {
      testWidgets(value.name, (tester) async {
        await _goldenTest(
          tester,
          cache,
          _base.copyWith(facialHairType: value),
          'facial_hair_${value.name}',
        );
      });
    }
  });

  group('FacialHairColor', () {
    for (final value in FacialHairColor.values) {
      testWidgets(value.name, (tester) async {
        await _goldenTest(
          tester,
          cache,
          _base.copyWith(
            facialHairType: FacialHairType.beardMajestic,
            facialHairColor: value.color,
          ),
          'facial_hair_color_${value.name}',
        );
      });
    }
  });

  group('ClotheType', () {
    for (final value in ClotheType.values) {
      testWidgets(value.name, (tester) async {
        await _goldenTest(
          tester,
          cache,
          _base.copyWith(clotheType: value),
          'clothe_${value.name}',
        );
      });
    }
  });

  group('ClotheColor', () {
    for (final value in ClotheColor.values) {
      testWidgets(value.name, (tester) async {
        await _goldenTest(
          tester,
          cache,
          _base.copyWith(clotheColor: value.color),
          'clothe_color_${value.name}',
        );
      });
    }
  });

  group('GraphicType', () {
    for (final value in GraphicType.values) {
      testWidgets(value.name, (tester) async {
        await _goldenTest(
          tester,
          cache,
          _base.copyWith(
            clotheType: ClotheType.graphicShirt,
            graphicType: value,
          ),
          'graphic_${value.name}',
        );
      });
    }
  });

  group('EyeType', () {
    for (final value in EyeType.values) {
      testWidgets(value.name, (tester) async {
        await _goldenTest(
          tester,
          cache,
          _base.copyWith(eyeType: value),
          'eye_${value.name}',
        );
      });
    }
  });

  group('EyebrowType', () {
    for (final value in EyebrowType.values) {
      testWidgets(value.name, (tester) async {
        await _goldenTest(
          tester,
          cache,
          _base.copyWith(eyebrowType: value),
          'eyebrow_${value.name}',
        );
      });
    }
  });

  group('MouthType', () {
    for (final value in MouthType.values) {
      testWidgets(value.name, (tester) async {
        await _goldenTest(
          tester,
          cache,
          _base.copyWith(mouthType: value),
          'mouth_${value.name}',
        );
      });
    }
  });

  group('SkinColor', () {
    for (final value in SkinColor.values) {
      testWidgets(value.name, (tester) async {
        await _goldenTest(
          tester,
          cache,
          _base.copyWith(skinColor: value.color),
          'skin_${value.name}',
        );
      });
    }
  });

  group('AvatarStyle', () {
    for (final value in AvatarStyle.values) {
      testWidgets(value.name, (tester) async {
        await _goldenTest(
          tester,
          cache,
          _base.copyWith(style: value),
          'style_${value.name}',
        );
      });
    }
  });
}
