#!/usr/bin/env python3
"""Generate SVGO-optimized SVG asset files and Dart lookup code.

Pipeline:
  1. extract_svg_fragments.js  → tools/svg_fragments.json
  2. This script               → lib/assets/*.svgf         (optimized fragments)
                               → lib/src/svg/svg_data.dart (color lookups + builder)

Prerequisites:
  - Run extract_svg_fragments.js first to produce tools/svg_fragments.json.
  - svgo must be on PATH (brew install svgo).

Usage (from flutter_avataaars/):
  python3 tools/generate_svg_data.py
"""
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile

script_dir = os.path.dirname(os.path.abspath(__file__))
json_path = os.path.join(script_dir, 'svg_fragments.json')
assets_dir = os.path.join(script_dir, '..', 'avatar_builder_core', 'lib', 'assets')
output_path = os.path.join(script_dir, '..', 'avatar_builder_core', 'lib', 'src', 'svg', 'svg_data.dart')

with open(json_path, 'r') as f:
    data = json.load(f)


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def dart_string(s):
    """Escape a string for a Dart single-quoted string literal."""
    if not s:
        return "''"
    escaped = s.replace('\\', '\\\\').replace("'", "\\'").replace('$', '\\$')
    return "'" + escaped + "'"


def camel_to_snake(name):
    """Convert camelCase to snake_case."""
    s1 = re.sub('(.)([A-Z][a-z]+)', r'\1_\2', name)
    return re.sub('([a-z0-9])([A-Z])', r'\1_\2', s1).lower()


SVG_WRAP_OPEN = '<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">'
SVG_WRAP_CLOSE = '</svg>'


def svgo_optimize(fragment):
    """Run SVGO on a fragment string, return optimized fragment."""
    if not fragment:
        return fragment

    wrapped = SVG_WRAP_OPEN + fragment + SVG_WRAP_CLOSE
    with tempfile.NamedTemporaryFile(mode='w', suffix='.svg', delete=False) as tmp_in:
        tmp_in.write(wrapped)
        tmp_in_path = tmp_in.name

    tmp_out_path = tmp_in_path + '.opt.svg'
    try:
        config_path = os.path.join(os.path.dirname(__file__), 'svgo.config.mjs')
        subprocess.run(
            ['svgo', tmp_in_path, '-o', tmp_out_path, '--quiet',
             '--config', config_path],
            check=True, capture_output=True, text=True,
        )
        with open(tmp_out_path) as f:
            optimized = f.read()
    finally:
        os.unlink(tmp_in_path)
        if os.path.exists(tmp_out_path):
            os.unlink(tmp_out_path)

    start = optimized.find('>') + 1  # end of opening <svg ...>
    end = optimized.rfind('</svg>')
    if start > 0 and end > start:
        optimized = optimized[start:end]

    # TODO: Add filters back when they are supported by flutter_svg.
    # Blocked on https://github.com/flutter/flutter/issues/158592
    # Strip <filter> tags and filter="..." attributes as they log unhandled elements
    optimized = re.sub(r'<filter.*?</filter>', '', optimized)
    optimized = re.sub(r'\s*filter="[^"]*"', '', optimized)

    return optimized


def write_asset(subdir, filename, content):
    """Write an optimized SVG fragment to the assets directory."""
    dirpath = os.path.join(assets_dir, subdir) if subdir else assets_dir
    os.makedirs(dirpath, exist_ok=True)
    filepath = os.path.join(dirpath, filename)
    with open(filepath, 'w') as f:
        f.write(content)
    return filepath


# ---------------------------------------------------------------------------
# Mapping from avataaars variant names to Dart enum value names
# ---------------------------------------------------------------------------

ENUM_MAP = {
    'eyes': {
        'Close': 'close', 'Cry': 'cry', 'Default': 'defaultEye',
        'Dizzy': 'dizzy', 'EyeRoll': 'eyeRoll', 'Happy': 'happy',
        'Hearts': 'hearts', 'Side': 'side', 'Squint': 'squint',
        'Surprised': 'surprised', 'Wink': 'wink', 'WinkWacky': 'winkWacky',
    },
    'eyebrows': {
        'Angry': 'angry', 'AngryNatural': 'angryNatural', 'Default': 'defaultBrow',
        'DefaultNatural': 'defaultNatural', 'FlatNatural': 'flatNatural',
        'FrownNatural': 'frownNatural', 'RaisedExcited': 'raisedExcited',
        'RaisedExcitedNatural': 'raisedExcitedNatural', 'SadConcerned': 'sadConcerned',
        'SadConcernedNatural': 'sadConcernedNatural', 'UnibrowNatural': 'unibrowNatural',
        'UpDown': 'upDown', 'UpDownNatural': 'upDownNatural',
    },
    'mouths': {
        'Concerned': 'concerned', 'Default': 'defaultMouth', 'Disbelief': 'disbelief',
        'Eating': 'eating', 'Grimace': 'grimace', 'Sad': 'sad',
        'ScreamOpen': 'screamOpen', 'Serious': 'serious', 'Smile': 'smile',
        'Tongue': 'tongue', 'Twinkle': 'twinkle', 'Vomit': 'vomit',
    },
    'clothing': {
        'BlazerShirt': 'blazerShirt', 'BlazerSweater': 'blazerSweater',
        'CollarSweater': 'collarSweater', 'GraphicShirt': 'graphicShirt',
        'Hoodie': 'hoodie', 'Overall': 'overall', 'ShirtCrewNeck': 'shirtCrewNeck',
        'ShirtScoopNeck': 'shirtScoopNeck', 'ShirtVNeck': 'shirtVNeck',
    },
    'top': {
        'NoHair': 'noHair', 'Eyepatch': 'eyepatch', 'Hat': 'hat',
        'Hijab': 'hijab', 'Turban': 'turban', 'WinterHat1': 'winterHat1',
        'WinterHat2': 'winterHat2', 'WinterHat3': 'winterHat3',
        'WinterHat4': 'winterHat4', 'LongHairBigHair': 'longHairBigHair',
        'LongHairBob': 'longHairBob', 'LongHairBun': 'longHairBun',
        'LongHairCurly': 'longHairCurly', 'LongHairCurvy': 'longHairCurvy',
        'LongHairDreads': 'longHairDreads', 'LongHairFrida': 'longHairFrida',
        'LongHairFro': 'longHairFro', 'LongHairFroBand': 'longHairFroBand',
        'LongHairMiaWallace': 'longHairMiaWallace',
        'LongHairNotTooLong': 'longHairNotTooLong',
        'LongHairShavedSides': 'longHairShavedSides',
        'LongHairStraight': 'longHairStraight',
        'LongHairStraight2': 'longHairStraight2',
        'LongHairStraightStrand': 'longHairStraightStrand',
        'ShortHairDreads01': 'shortHairDreads01',
        'ShortHairDreads02': 'shortHairDreads02',
        'ShortHairFrizzle': 'shortHairFrizzle',
        'ShortHairShaggyMullet': 'shortHairShaggyMullet',
        'ShortHairShortCurly': 'shortHairShortCurly',
        'ShortHairShortFlat': 'shortHairShortFlat',
        'ShortHairShortRound': 'shortHairShortRound',
        'ShortHairShortWaved': 'shortHairShortWaved',
        'ShortHairSides': 'shortHairSides',
        'ShortHairTheCaesar': 'shortHairTheCaesar',
        'ShortHairTheCaesarSidePart': 'shortHairTheCaesarSidePart',
        'ShortHairShaggy': 'shortHairShaggy',
    },
    'accessories': {
        'Blank': 'blank', 'Kurt': 'kurt', 'Prescription01': 'prescription01',
        'Prescription02': 'prescription02', 'Round': 'round',
        'Sunglasses': 'sunglasses', 'Wayfarers': 'wayfarers',
    },
    'facialHair': {
        'Blank': 'blank', 'BeardMedium': 'beardMedium', 'BeardLight': 'beardLight',
        'BeardMajestic': 'beardMajestic', 'MoustacheFancy': 'moustacheFancy',
        'MoustacheMagnum': 'moustacheMagnum',
    },
    'graphicClothing': {
        'Bat': 'bat', 'Cumbia': 'cumbia', 'Deer': 'deer',
        'Diamond': 'diamond', 'Hola': 'hola', 'Pizza': 'pizza',
        'Resist': 'resist', 'Selena': 'selena', 'Bear': 'bear',
        'SkullOutline': 'skullOutline', 'Skull': 'skull',
    },
}

# Sentinel hex colors (lowercase — SVGO normalizes hex to lowercase)
SENTINEL_SKIN = '#ae5d29'
SENTINEL_HAIR = '#e8e1e1'
SENTINEL_HAIR_SHADOW = '#ccb55a'
SENTINEL_HAT = '#ff5c5c'
SENTINEL_CLOTHE = '#ff488e'
SENTINEL_FACIAL_HAIR = '#a55728'

# Category mapping: (json_key, asset_dir_name)
ASSET_CATEGORIES = [
    ('eyes', 'eyes'),
    ('eyebrows', 'eyebrows'),
    ('mouths', 'mouths'),
    ('clothing', 'clothing'),
    ('graphicClothing', 'graphic_clothing'),
    ('top', 'top'),
    ('accessories', 'accessories'),
    ('facialHair', 'facial_hair'),
]

# ---------------------------------------------------------------------------
# Phase 1: Write SVGO-optimized SVG fragment asset files
# ---------------------------------------------------------------------------

print("Optimizing and writing SVG asset files...")

# Clean the assets directory
if os.path.exists(assets_dir):
    shutil.rmtree(assets_dir)
os.makedirs(assets_dir)

total_before = 0
total_after = 0
file_count = 0


def optimize_and_write(subdir, filename, fragment):
    """Optimize a fragment with SVGO and write to assets/. Returns (before, after) sizes.

    Empty fragments are skipped — no file is written.
    """
    global total_before, total_after, file_count
    before = len(fragment.encode('utf-8')) if fragment else 0
    optimized = svgo_optimize(fragment) if fragment else ''
    after = len(optimized.encode('utf-8'))
    if optimized:
        write_asset(subdir, filename, optimized)
    total_before += before
    total_after += after
    file_count += 1
    return before, after


# Fixed fragments
for name, key in [('shared_defs', 'sharedDefs'), ('body', 'body'), ('nose', 'nose')]:
    b, a = optimize_and_write('', f'{name}.svgf', data[key])
    if b:
        print(f"  {name}.svgf: {b:,} -> {a:,} bytes ({100*a/b:.0f}%)")
    else:
        print(f"  {name}.svgf: empty")

# Variable fragments by category
for json_key, dir_name in ASSET_CATEGORIES:
    cat_before = 0
    cat_after = 0
    count = 0
    fragments = data.get(json_key, {})
    enum_map = ENUM_MAP.get(json_key, {})
    for variant_name, svg in fragments.items():
        dart_name = enum_map.get(variant_name)
        if dart_name is None:
            continue
        filename = f'{camel_to_snake(dart_name)}.svgf'
        b, a = optimize_and_write(dir_name, filename, svg)
        cat_before += b
        cat_after += a
        count += 1
    pct = f"{100*cat_after/cat_before:.0f}%" if cat_before else "n/a"
    print(f"  {dir_name}/: {cat_before:,} -> {cat_after:,} bytes ({pct}), {count} files")

# Handle fallbacks: write missing variants that point to existing ones
if 'FrownNatural' not in data.get('eyebrows', {}):
    optimize_and_write('eyebrows', 'frown_natural.svgf', data['eyebrows'].get('Default', ''))
if 'ShortHairShaggy' not in data.get('top', {}):
    optimize_and_write('top', 'short_hair_shaggy.svgf', data['top'].get('ShortHairShaggyMullet', ''))

print(f"\nTotal: {total_before:,} -> {total_after:,} bytes ({100*total_after/total_before:.0f}%), {file_count} files")

# ---------------------------------------------------------------------------
# Phase 2: Generate svg_data.dart (color lookups + asset paths + cache + builder)
# ---------------------------------------------------------------------------

print("\nGenerating svg_data.dart...")
lines = []

# Asset path prefix for Flutter's package asset resolution.
_ASSET_PREFIX = 'packages/avatar_builder/lib/assets'

# Header
lines.append("// GENERATED FILE - DO NOT EDIT")
lines.append("// Generated from avataaars SVG components via React SSR extraction.")
lines.append("// SVG fragments are stored as asset files under lib/assets/.")
lines.append("")
lines.append("import 'package:avatar_builder/src/models/avatar_style.dart';")
lines.append("import 'package:avatar_builder/src/svg/svg_cache.dart';")
lines.append("")

# Sentinel constants
lines.append("// Sentinel hex values baked into SVG fragments during extraction.")
lines.append("// These are the colors produced by rendering avataaars with specific options")
lines.append("// (DarkBrown skin, SilverGray hair, Red hat, Pink clothe, Auburn facial hair).")
lines.append("// At runtime, AvatarColorMapper substitutes the user's actual colors.")
lines.append(f"const String sentinelSkin = '{SENTINEL_SKIN}';")
lines.append(f"const String sentinelHair = '{SENTINEL_HAIR}';")
lines.append(f"const String sentinelHairShadow = '{SENTINEL_HAIR_SHADOW}';")
lines.append(f"const String sentinelHat = '{SENTINEL_HAT}';")
lines.append(f"const String sentinelClothe = '{SENTINEL_CLOTHE}';")
lines.append(f"const String sentinelFacialHair = '{SENTINEL_FACIAL_HAIR}';")
lines.append("")

# Asset path constant
lines.append(f"const String _assetPrefix = '{_ASSET_PREFIX}';")
lines.append("")

# Asset path lookup functions
def gen_asset_path_switch(func_name, enum_type, category, dir_name, fallbacks=None):
    """Generate a switch function that returns the asset path for a given enum value."""
    lines.append(f"String {func_name}({enum_type} type) {{")
    lines.append("  switch (type) {")
    enum_map = ENUM_MAP[category]
    fragments = data.get(category, {})
    for variant_name in fragments:
        dart_name = enum_map.get(variant_name)
        if dart_name is None:
            continue
        svg = fragments[variant_name]
        lines.append(f"    case {enum_type}.{dart_name}:")
        if not svg:
            # Empty fragment — no asset file exists.
            lines.append("      return '';")
        else:
            filename = camel_to_snake(dart_name)
            lines.append(f"      return '$_assetPrefix/{dir_name}/{filename}.svgf';")
    if fallbacks:
        for dart_name, filename in fallbacks.items():
            lines.append(f"    case {enum_type}.{dart_name}:")
            lines.append(f"      return '$_assetPrefix/{dir_name}/{filename}.svgf';")
    lines.append("  }")
    lines.append("}")
    lines.append("")


eyebrow_fb = {'frownNatural': 'frown_natural'} if 'FrownNatural' not in data.get('eyebrows', {}) else None
top_fb = {'shortHairShaggy': 'short_hair_shaggy'} if 'ShortHairShaggy' not in data.get('top', {}) else None

gen_asset_path_switch("_eyeAsset", "EyeType", "eyes", "eyes")
gen_asset_path_switch("_eyebrowAsset", "EyebrowType", "eyebrows", "eyebrows", eyebrow_fb)
gen_asset_path_switch("_mouthAsset", "MouthType", "mouths", "mouths")
gen_asset_path_switch("_clothingAsset", "ClotheType", "clothing", "clothing")
gen_asset_path_switch("_topAsset", "TopType", "top", "top", top_fb)
gen_asset_path_switch("_accessoryAsset", "AccessoriesType", "accessories", "accessories")
gen_asset_path_switch("_facialHairAsset", "FacialHairType", "facialHair", "facial_hair")
gen_asset_path_switch("_graphicClothingAsset", "GraphicType", "graphicClothing", "graphic_clothing")


# ---------------------------------------------------------------------------
# Builder function
# ---------------------------------------------------------------------------

lines.append("/// Build a complete avatar SVG string from cached asset fragments.")
lines.append("///")
lines.append("/// The returned SVG uses sentinel colors for skin, hair, hat, clothing,")
lines.append("/// and facial hair. Use [AvatarColorMapper] with [SvgStringLoader] to")
lines.append("/// substitute the actual colors at render time.")
lines.append("///")
lines.append("/// Assets are loaded on demand (and cached for future calls).")
lines.append("Future<String> buildAvatarSvg({")
lines.append("  SvgCache? cache,")
lines.append("  required AvatarStyle style,")
lines.append("  required TopType topType,")
lines.append("  required AccessoriesType accessoriesType,")
lines.append("  required FacialHairType facialHairType,")
lines.append("  required ClotheType clotheType,")
lines.append("  required GraphicType graphicType,")
lines.append("  required EyeType eyeType,")
lines.append("  required EyebrowType eyebrowType,")
lines.append("  required MouthType mouthType,")
lines.append("}) async {")
lines.append("  final c = cache ?? SvgCache.instance;")
lines.append("  final clothingPath = clotheType == ClotheType.graphicShirt")
lines.append("      ? _graphicClothingAsset(graphicType)")
lines.append("      : _clothingAsset(clotheType);")
lines.append("  final results = await Future.wait([")
lines.append("    c.load('$_assetPrefix/shared_defs.svgf'),")
lines.append("    c.load('$_assetPrefix/body.svgf'),")
lines.append("    c.load('$_assetPrefix/nose.svgf'),")
lines.append("    c.load(_eyeAsset(eyeType)),")
lines.append("    c.load(_eyebrowAsset(eyebrowType)),")
lines.append("    c.load(_mouthAsset(mouthType)),")
lines.append("    c.load(clothingPath),")
lines.append("    c.load(_topAsset(topType)),")
lines.append("    c.load(_accessoryAsset(accessoriesType)),")
lines.append("    c.load(_facialHairAsset(facialHairType)),")
lines.append("  ]);")
lines.append("  final sharedDefs = results[0];")
lines.append("  final bodyGroup = results[1];")
lines.append("  final noseGroup = results[2];")
lines.append("  final eyeSvg = results[3];")
lines.append("  final eyebrowSvg = results[4];")
lines.append("  final mouthSvg = results[5];")
lines.append("  final clothingSvg = results[6];")
lines.append("  var topSvg = results[7];")
lines.append("  final accSvg = results[8];")
lines.append("  final fhSvg = results[9];")
lines.append("")
lines.append("  // Insert accessories and facial hair before the last </g> of top")
lines.append("  if (accSvg.isNotEmpty || fhSvg.isNotEmpty) {")
lines.append("    final lastClose = topSvg.lastIndexOf('</g>');")
lines.append("    if (lastClose >= 0) {")
lines.append("      topSvg = '${topSvg.substring(0, lastClose)}$accSvg$fhSvg${topSvg.substring(lastClose)}';")
lines.append("    }")
lines.append("  }")
lines.append("")
lines.append("  final circle = style == AvatarStyle.circle;")
lines.append("")
lines.append("  final circleBackground = circle")
lines.append("      ? '<g transform=\"translate(12, 40)\">'")
lines.append("            '<mask id=\"mask-bg\" fill=\"white\"><use xlink:href=\"#shared-path-1\"/></mask>'")
lines.append("            '<use fill=\"#E6E6E6\" xlink:href=\"#shared-path-1\"/>'")
lines.append("            '<g mask=\"url(#mask-bg)\" fill=\"#65C9FF\"><rect x=\"0\" y=\"0\" width=\"240\" height=\"240\"/></g>'")
lines.append("            '</g>'")
lines.append("      : '';")
lines.append("")
lines.append("  final clipMask = circle")
lines.append("      ? '<mask id=\"mask-clip\" fill=\"white\"><use xlink:href=\"#shared-path-2\"/></mask>'")
lines.append("      : '';")
lines.append("")
lines.append("  final clipMaskRef = circle ? ' mask=\"url(#mask-clip)\"' : '';")
lines.append("")
lines.append("  return '<svg viewBox=\"0 0 264 280\" xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\">'")
lines.append("    '<defs>$sharedDefs</defs>'")
lines.append("    '<g id=\"Avataaar\" stroke=\"none\" stroke-width=\"1\" fill=\"none\" fill-rule=\"evenodd\">'")
lines.append("    '<g transform=\"translate(0, 0)\">'")
lines.append("    '$circleBackground'")
lines.append("    '$clipMask'")
lines.append("    '<g$clipMaskRef>'")
lines.append("    '$bodyGroup'")
lines.append("    '$clothingSvg'")
lines.append("    '<g transform=\"translate(76, 82)\" fill=\"#000000\">'")
lines.append("    '$mouthSvg'")
lines.append("    '$noseGroup'")
lines.append("    '$eyeSvg'")
lines.append("    '$eyebrowSvg'")
lines.append("    '</g>'")
lines.append("    '$topSvg'")
lines.append("    '</g>'")
lines.append("    '</g>'")
lines.append("    '</g>'")
lines.append("    '</svg>';")
lines.append("}")

output = '\n'.join(lines) + '\n'
with open(output_path, 'w') as f:
    f.write(output)

print(f"Generated {output_path} ({len(output):,} bytes, {len(lines)} lines)")
