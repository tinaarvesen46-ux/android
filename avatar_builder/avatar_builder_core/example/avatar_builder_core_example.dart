// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:math';

import 'package:avatar_builder_core/avatar_builder_core.dart';
import 'package:avatar_builder_core/file_asset_loader.dart';

Future<void> main() async {
  // Resolve the package's built-in asset directory automatically.
  final loader = await FileAssetLoader.defaultForPackage();

  // Create a specific avatar.
  final avatar = Avataaar(
    style: AvatarStyle.circle,
    topType: TopType.shortHairShortFlat,
    accessoriesType: AccessoriesType.prescription01,
    hairColor: HairColor.brown.color,
    facialHairType: FacialHairType.blank,
    clotheType: ClotheType.hoodie,
    clotheColor: ClotheColor.blue01.color,
    eyeType: EyeType.happy,
    eyebrowType: EyebrowType.defaultBrow,
    mouthType: MouthType.smile,
    skinColor: SkinColor.light.color,
  );

  // Render to SVG and save.
  final svg = await avatar.toSvg(loadAsset: loader.load);
  File('avatar.svg').writeAsStringSync(svg);
  print('Saved avatar.svg');

  // Generate a random avatar.
  final random = Avataaar.random(Random(42));
  final randomSvg = await random.toSvg(loadAsset: loader.load);
  File('random_avatar.svg').writeAsStringSync(randomSvg);
  print('Saved random_avatar.svg');

  // Serialise to JSON and back.
  final json = avatar.toJson();
  print('JSON: $json');

  final restored = Avataaar.fromJson(json);
  print('Restored eye type: ${restored.eyeType}');
}
