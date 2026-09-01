import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Integration test that verifies SVG fragment assets can be loaded at runtime.
///
/// Run on macOS (or any non-web platform):
///   cd example && flutter test integration_test/asset_loading_test.dart -d macos
///
/// On web, empty asset files (0 bytes) crash the dev server's shelf handler
/// because it calls `file.openRead(0, 0).first` to sniff the MIME type, and
/// `.first` on an empty stream throws "Bad state: No element".
/// See: https://github.com/flutter/flutter/issues/XXXXX
///
/// To reproduce on web:
///   cd example && flutter run -d chrome
///   # The app will crash trying to load blank.svg assets.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const prefix = 'packages/avatar_builder_core/lib/assets';

  testWidgets('can load SVG fragment assets from bundle', (tester) async {
    // These are the three fixed fragments that every avatar needs.
    final paths = [
      '$prefix/shared_defs.svgf',
      '$prefix/body.svgf',
      '$prefix/nose.svgf',
      // One from each subdirectory to cover the full asset tree.
      '$prefix/eyes/default_eye.svgf',
      '$prefix/eyebrows/default_brow.svgf',
      '$prefix/mouths/default_mouth.svgf',
      '$prefix/clothing/blazer_shirt.svgf',
      '$prefix/top/no_hair.svgf',
      '$prefix/accessories/kurt.svgf',
      '$prefix/facial_hair/beard_medium.svgf',
    ];

    for (final path in paths) {
      final content = await rootBundle.loadString(path);
      expect(content, isNotEmpty, reason: 'Asset was empty: $path');
    }
  });
}
