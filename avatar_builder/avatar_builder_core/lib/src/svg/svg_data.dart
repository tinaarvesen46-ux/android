// GENERATED FILE - DO NOT EDIT
// Generated from avataaars SVG components via React SSR extraction.
// SVG fragments are stored as asset files under lib/assets/.

import 'package:avatar_builder_core/src/models/avatar_style.dart';
import 'package:avatar_builder_core/src/svg/asset_loader.dart';

// Sentinel hex values baked into SVG fragments during extraction.
// These are the colors produced by rendering avataaars with specific options
// (DarkBrown skin, SilverGray hair, Red hat, Pink clothe, Auburn facial hair).
// At runtime, AvatarColorMapper substitutes the user's actual colors.
const String sentinelSkin = '#ae5d29';
const String sentinelHair = '#e8e1e1';
const String sentinelHairShadow = '#ccb55a';
const String sentinelHat = '#ff5c5c';
const String sentinelClothe = '#ff488e';
const String sentinelFacialHair = '#a55728';

String _eyeAsset(EyeType type) {
  switch (type) {
    case EyeType.close:
      return 'eyes/close.svgf';
    case EyeType.cry:
      return 'eyes/cry.svgf';
    case EyeType.defaultEye:
      return 'eyes/default_eye.svgf';
    case EyeType.dizzy:
      return 'eyes/dizzy.svgf';
    case EyeType.eyeRoll:
      return 'eyes/eye_roll.svgf';
    case EyeType.happy:
      return 'eyes/happy.svgf';
    case EyeType.hearts:
      return 'eyes/hearts.svgf';
    case EyeType.side:
      return 'eyes/side.svgf';
    case EyeType.squint:
      return 'eyes/squint.svgf';
    case EyeType.surprised:
      return 'eyes/surprised.svgf';
    case EyeType.wink:
      return 'eyes/wink.svgf';
    case EyeType.winkWacky:
      return 'eyes/wink_wacky.svgf';
  }
}

String _eyebrowAsset(EyebrowType type) {
  switch (type) {
    case EyebrowType.angry:
      return 'eyebrows/angry.svgf';
    case EyebrowType.angryNatural:
      return 'eyebrows/angry_natural.svgf';
    case EyebrowType.defaultBrow:
      return 'eyebrows/default_brow.svgf';
    case EyebrowType.defaultNatural:
      return 'eyebrows/default_natural.svgf';
    case EyebrowType.flatNatural:
      return 'eyebrows/flat_natural.svgf';
    case EyebrowType.raisedExcited:
      return 'eyebrows/raised_excited.svgf';
    case EyebrowType.raisedExcitedNatural:
      return 'eyebrows/raised_excited_natural.svgf';
    case EyebrowType.sadConcerned:
      return 'eyebrows/sad_concerned.svgf';
    case EyebrowType.sadConcernedNatural:
      return 'eyebrows/sad_concerned_natural.svgf';
    case EyebrowType.unibrowNatural:
      return 'eyebrows/unibrow_natural.svgf';
    case EyebrowType.upDown:
      return 'eyebrows/up_down.svgf';
    case EyebrowType.upDownNatural:
      return 'eyebrows/up_down_natural.svgf';
    case EyebrowType.frownNatural:
      return 'eyebrows/frown_natural.svgf';
  }
}

String _mouthAsset(MouthType type) {
  switch (type) {
    case MouthType.concerned:
      return 'mouths/concerned.svgf';
    case MouthType.defaultMouth:
      return 'mouths/default_mouth.svgf';
    case MouthType.disbelief:
      return 'mouths/disbelief.svgf';
    case MouthType.eating:
      return 'mouths/eating.svgf';
    case MouthType.grimace:
      return 'mouths/grimace.svgf';
    case MouthType.sad:
      return 'mouths/sad.svgf';
    case MouthType.screamOpen:
      return 'mouths/scream_open.svgf';
    case MouthType.serious:
      return 'mouths/serious.svgf';
    case MouthType.smile:
      return 'mouths/smile.svgf';
    case MouthType.tongue:
      return 'mouths/tongue.svgf';
    case MouthType.twinkle:
      return 'mouths/twinkle.svgf';
    case MouthType.vomit:
      return 'mouths/vomit.svgf';
  }
}

String _clothingAsset(ClotheType type) {
  switch (type) {
    case ClotheType.blazerShirt:
      return 'clothing/blazer_shirt.svgf';
    case ClotheType.blazerSweater:
      return 'clothing/blazer_sweater.svgf';
    case ClotheType.collarSweater:
      return 'clothing/collar_sweater.svgf';
    case ClotheType.graphicShirt:
      return 'clothing/graphic_shirt.svgf';
    case ClotheType.hoodie:
      return 'clothing/hoodie.svgf';
    case ClotheType.overall:
      return 'clothing/overall.svgf';
    case ClotheType.shirtCrewNeck:
      return 'clothing/shirt_crew_neck.svgf';
    case ClotheType.shirtScoopNeck:
      return 'clothing/shirt_scoop_neck.svgf';
    case ClotheType.shirtVNeck:
      return 'clothing/shirt_v_neck.svgf';
  }
}

String _topAsset(TopType type) {
  switch (type) {
    case TopType.noHair:
      return 'top/no_hair.svgf';
    case TopType.eyepatch:
      return 'top/eyepatch.svgf';
    case TopType.hat:
      return 'top/hat.svgf';
    case TopType.hijab:
      return 'top/hijab.svgf';
    case TopType.turban:
      return 'top/turban.svgf';
    case TopType.winterHat1:
      return 'top/winter_hat1.svgf';
    case TopType.winterHat2:
      return 'top/winter_hat2.svgf';
    case TopType.winterHat3:
      return 'top/winter_hat3.svgf';
    case TopType.winterHat4:
      return 'top/winter_hat4.svgf';
    case TopType.longHairBigHair:
      return 'top/long_hair_big_hair.svgf';
    case TopType.longHairBob:
      return 'top/long_hair_bob.svgf';
    case TopType.longHairBun:
      return 'top/long_hair_bun.svgf';
    case TopType.longHairCurly:
      return 'top/long_hair_curly.svgf';
    case TopType.longHairCurvy:
      return 'top/long_hair_curvy.svgf';
    case TopType.longHairDreads:
      return 'top/long_hair_dreads.svgf';
    case TopType.longHairFrida:
      return 'top/long_hair_frida.svgf';
    case TopType.longHairFro:
      return 'top/long_hair_fro.svgf';
    case TopType.longHairFroBand:
      return 'top/long_hair_fro_band.svgf';
    case TopType.longHairMiaWallace:
      return 'top/long_hair_mia_wallace.svgf';
    case TopType.longHairNotTooLong:
      return 'top/long_hair_not_too_long.svgf';
    case TopType.longHairShavedSides:
      return 'top/long_hair_shaved_sides.svgf';
    case TopType.longHairStraight:
      return 'top/long_hair_straight.svgf';
    case TopType.longHairStraight2:
      return 'top/long_hair_straight2.svgf';
    case TopType.longHairStraightStrand:
      return 'top/long_hair_straight_strand.svgf';
    case TopType.shortHairDreads01:
      return 'top/short_hair_dreads01.svgf';
    case TopType.shortHairDreads02:
      return 'top/short_hair_dreads02.svgf';
    case TopType.shortHairFrizzle:
      return 'top/short_hair_frizzle.svgf';
    case TopType.shortHairShaggyMullet:
      return 'top/short_hair_shaggy_mullet.svgf';
    case TopType.shortHairShortCurly:
      return 'top/short_hair_short_curly.svgf';
    case TopType.shortHairShortFlat:
      return 'top/short_hair_short_flat.svgf';
    case TopType.shortHairShortRound:
      return 'top/short_hair_short_round.svgf';
    case TopType.shortHairShortWaved:
      return 'top/short_hair_short_waved.svgf';
    case TopType.shortHairSides:
      return 'top/short_hair_sides.svgf';
    case TopType.shortHairTheCaesar:
      return 'top/short_hair_the_caesar.svgf';
    case TopType.shortHairTheCaesarSidePart:
      return 'top/short_hair_the_caesar_side_part.svgf';
    case TopType.shortHairShaggy:
      return 'top/short_hair_shaggy.svgf';
  }
}

String _accessoryAsset(AccessoriesType type) {
  switch (type) {
    case AccessoriesType.blank:
      return '';
    case AccessoriesType.kurt:
      return 'accessories/kurt.svgf';
    case AccessoriesType.prescription01:
      return 'accessories/prescription01.svgf';
    case AccessoriesType.prescription02:
      return 'accessories/prescription02.svgf';
    case AccessoriesType.round:
      return 'accessories/round.svgf';
    case AccessoriesType.sunglasses:
      return 'accessories/sunglasses.svgf';
    case AccessoriesType.wayfarers:
      return 'accessories/wayfarers.svgf';
  }
}

String _facialHairAsset(FacialHairType type) {
  switch (type) {
    case FacialHairType.blank:
      return '';
    case FacialHairType.beardMedium:
      return 'facial_hair/beard_medium.svgf';
    case FacialHairType.beardLight:
      return 'facial_hair/beard_light.svgf';
    case FacialHairType.beardMajestic:
      return 'facial_hair/beard_majestic.svgf';
    case FacialHairType.moustacheFancy:
      return 'facial_hair/moustache_fancy.svgf';
    case FacialHairType.moustacheMagnum:
      return 'facial_hair/moustache_magnum.svgf';
  }
}

String _graphicClothingAsset(GraphicType type) {
  switch (type) {
    case GraphicType.bat:
      return 'graphic_clothing/bat.svgf';
    case GraphicType.cumbia:
      return 'graphic_clothing/cumbia.svgf';
    case GraphicType.deer:
      return 'graphic_clothing/deer.svgf';
    case GraphicType.diamond:
      return 'graphic_clothing/diamond.svgf';
    case GraphicType.hola:
      return 'graphic_clothing/hola.svgf';
    case GraphicType.pizza:
      return 'graphic_clothing/pizza.svgf';
    case GraphicType.resist:
      return 'graphic_clothing/resist.svgf';
    case GraphicType.selena:
      return 'graphic_clothing/selena.svgf';
    case GraphicType.bear:
      return 'graphic_clothing/bear.svgf';
    case GraphicType.skullOutline:
      return 'graphic_clothing/skull_outline.svgf';
    case GraphicType.skull:
      return 'graphic_clothing/skull.svgf';
  }
}

/// Build a complete avatar SVG string from asset fragments.
///
/// The [loadAsset] function is called with bare asset keys (e.g.
/// `eyes/close.svgf`) and must return the SVG fragment content.
///
/// The returned SVG uses sentinel colors for skin, hair, hat, clothing,
/// and facial hair. Use [AvatarColorMapper.applyToString] to substitute
/// the actual colors.
Future<String> buildAvatarSvg({
  required AssetLoader loadAsset,
  required AvatarStyle style,
  required TopType topType,
  required AccessoriesType accessoriesType,
  required FacialHairType facialHairType,
  required ClotheType clotheType,
  required GraphicType graphicType,
  required EyeType eyeType,
  required EyebrowType eyebrowType,
  required MouthType mouthType,
}) async {
  final clothingPath = clotheType == ClotheType.graphicShirt
      ? _graphicClothingAsset(graphicType)
      : _clothingAsset(clotheType);
  final results = await Future.wait([
    loadAsset('shared_defs.svgf'),
    loadAsset('body.svgf'),
    loadAsset('nose.svgf'),
    loadAsset(_eyeAsset(eyeType)),
    loadAsset(_eyebrowAsset(eyebrowType)),
    loadAsset(_mouthAsset(mouthType)),
    loadAsset(clothingPath),
    loadAsset(_topAsset(topType)),
    loadAsset(_accessoryAsset(accessoriesType)),
    loadAsset(_facialHairAsset(facialHairType)),
  ]);
  final sharedDefs = results[0];
  final bodyGroup = results[1];
  final noseGroup = results[2];
  final eyeSvg = results[3];
  final eyebrowSvg = results[4];
  final mouthSvg = results[5];
  final clothingSvg = results[6];
  var topSvg = results[7];
  final accSvg = results[8];
  final fhSvg = results[9];

  // Insert accessories and facial hair before the last </g> of top
  if (accSvg.isNotEmpty || fhSvg.isNotEmpty) {
    final lastClose = topSvg.lastIndexOf('</g>');
    if (lastClose >= 0) {
      topSvg =
          '${topSvg.substring(0, lastClose)}$accSvg$fhSvg${topSvg.substring(lastClose)}';
    }
  }

  final circle = style == AvatarStyle.circle;

  final circleBackground = circle
      ? '<g transform="translate(12, 40)">'
            '<mask id="mask-bg" fill="white"><use xlink:href="#shared-path-1"/></mask>'
            '<use fill="#E6E6E6" xlink:href="#shared-path-1"/>'
            '<g mask="url(#mask-bg)" fill="#65C9FF"><rect x="0" y="0" width="240" height="240"/></g>'
            '</g>'
      : '';

  final clipMask = circle
      ? '<mask id="mask-clip" fill="white"><use xlink:href="#shared-path-2"/></mask>'
      : '';

  final clipMaskRef = circle ? ' mask="url(#mask-clip)"' : '';

  return '<svg viewBox="0 0 264 280" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">'
      '<defs>$sharedDefs</defs>'
      '<g id="Avataaar" stroke="none" stroke-width="1" fill="none" fill-rule="evenodd">'
      '<g transform="translate(0, 0)">'
      '$circleBackground'
      '$clipMask'
      '<g$clipMaskRef>'
      '$bodyGroup'
      '$clothingSvg'
      '<g transform="translate(76, 82)" fill="#000000">'
      '$mouthSvg'
      '$noseGroup'
      '$eyeSvg'
      '$eyebrowSvg'
      '</g>'
      '$topSvg'
      '</g>'
      '</g>'
      '</g>'
      '</svg>';
}
