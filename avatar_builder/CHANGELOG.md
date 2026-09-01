# Changelog

## 0.3.1

- Correct `--base-href` in GitHub deployment workflow to `/avatar_builder/`.
- Fix SVG sample images not rendering in README on GitHub.

## 0.3.0

- Add `FileAssetLoader` to `avatar_builder_core` for easy asset loading in
  `dart:io` environments. Available via a separate import:
  `import 'package:avatar_builder_core/file_asset_loader.dart'`.
- Update READMEs with improved usage examples.

## 0.2.0

- **Breaking**: Split into `avatar_builder_core` (pure Dart, no Flutter dependency) and `avatar_builder` (Flutter widgets) packages in a Dart workspace monorepo.
- Color fields on `Avataaar` now use `int` ARGB values instead of `dart:ui` `Color`, with reverse-lookup getters for palette enums.
- Add `toJson()` / `fromJson()` serialisation on `Avataaar`.
- Simplify `Avataaar.random()` with declarative weight maps for more readable and tunable random avatar generation.
- Add `--circle` flag to `generate.dart` CLI tool.
- Strip `<filter>` elements from SVG fragments for cleaner output.
- Add 10 sample avatar SVGs.

## 0.1.1

- Fix `.pubignore` excluding SVG asset files from the published package.

## 0.1.0

- Initial release.
- `AvatarWidget` for rendering avataaars-style cartoon avatars.
- `Avataaar` model with full customization of hair, eyes, eyebrows, mouth, facial hair, clothing, accessories, and skin color.
- `Avataaar.random()` factory for generating random avatars.
- `SvgCache` for efficient LRU caching of SVG asset fragments.
- 140+ optimized SVG fragments covering all avatar component variations.
- Circle and transparent background styles via `AvatarStyle`.
