import 'dart:io';

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

void main() {
  testWidgets('AvatarWidget renders', (tester) async {
    final cache = _loadCacheFromDisk();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AvatarWidget(avatar: Avataaar(), cache: cache),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(AvatarWidget), findsOneWidget);
  });
}
