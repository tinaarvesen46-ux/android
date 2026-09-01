// ignore_for_file: avoid_print // We use print for simple CLI output.
//
// Pure Dart CLI tool for generating random avatar SVGs.
// Uses avatar_builder_core — no Flutter dependency.

import 'dart:io';
import 'dart:math';

import 'package:avatar_builder_core/avatar_builder_core.dart';

/// Assets directory relative to where this tool is run.
const String _assetsDir = 'avatar_builder_core/lib/assets';

/// An [AssetLoader] that reads from the local filesystem.
Future<String> _fileAssetLoader(String key) async {
  if (key.isEmpty) return '';
  return File('$_assetsDir/$key').readAsString();
}

void _printUsage() {
  print('Usage: dart run bin/generate.dart [options]');
  print('');
  print('Generate random avatar SVGs.');
  print('');
  print('Options:');
  print('  -o, --output <path>   Output file path (default: avatar.svg)');
  print('                        Use {n} placeholder for count > 1');
  print('  -n, --count <int>     Number of avatars to generate (default: 1)');
  print('  -s, --seed <int>      Random seed for reproducibility');
  print('      --circle          Use circle background (default is random)');
  print('      --transparent     Use transparent background (no circle)');
  print('  -h, --help            Show this help message');
}

Future<void> main(List<String> arguments) async {
  String output = 'avatar.svg';
  int count = 1;
  int? seed;
  AvatarStyle? styleOverride;

  for (var i = 0; i < arguments.length; i++) {
    switch (arguments[i]) {
      case '-o' || '--output':
        if (++i < arguments.length) output = arguments[i];
      case '-n' || '--count':
        if (++i < arguments.length) count = int.parse(arguments[i]);
      case '-s' || '--seed':
        if (++i < arguments.length) seed = int.parse(arguments[i]);
      case '--circle':
        styleOverride = AvatarStyle.circle;
      case '--transparent':
        styleOverride = AvatarStyle.transparent;
      case '-h' || '--help':
        _printUsage();
        return;
      default:
        stderr.writeln('Unknown option: ${arguments[i]}');
        _printUsage();
        exitCode = 1;
        return;
    }
  }

  if (!Directory(_assetsDir).existsSync()) {
    stderr.writeln('Error: $_assetsDir not found.');
    stderr.writeln('Run this tool from the workspace root directory.');
    exitCode = 1;
    return;
  }

  // When generating multiple avatars, inject {n} if not present.
  if (count > 1 && !output.contains('{n}')) {
    final dot = output.lastIndexOf('.');
    if (dot >= 0) {
      output = '${output.substring(0, dot)}_{n}${output.substring(dot)}';
    } else {
      output = '${output}_{n}';
    }
  }

  final rng = Random(seed);

  for (var n = 1; n <= count; n++) {
    final avatar = Avataaar.random(rng);
    if (styleOverride != null) {
      avatar.style = styleOverride;
    }

    final svg = await avatar.toSvg(loadAsset: _fileAssetLoader);
    final path = output.replaceAll('{n}', '$n');
    File(path).writeAsStringSync(svg);
    print('Generated $path');
  }
}
