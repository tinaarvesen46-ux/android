# Avatar Builder Core

A pure Dart library for building [avataaars](https://getavataaars.com/)-style cartoon avatars as SVG strings. No Flutter dependency — works on servers, CLI tools, and any Dart environment.

[![pub package](https://img.shields.io/pub/v/avatar_builder_core.svg)](https://pub.dev/packages/avatar_builder_core)

## Features

- **Pure Dart** — no Flutter or `dart:ui` dependency
- **140+ SVG fragments** composable into millions of unique avatars
- **Pluggable asset loading** via `AssetLoader` typedef — use the included `FileAssetLoader` for `dart:io`, or provide your own
- **Random avatar generation** via `Avataaar.random()`
- **JSON serialisation** with `toJson()` / `fromJson()`
- **Full customisation**: hair, eyes, eyebrows, mouth, facial hair, clothing, accessories, skin color

## Getting started

```yaml
dependencies:
  avatar_builder_core: ^0.3.0
```

## Usage

For programs with `dart:io` available (CLI tools, servers, scripts), import
`FileAssetLoader` to load the built-in SVG assets from disk automatically:

```dart
import 'package:avatar_builder_core/avatar_builder_core.dart';
import 'package:avatar_builder_core/file_asset_loader.dart';

void main() async {
  // Resolve the package's built-in asset directory automatically.
  final loader = await FileAssetLoader.defaultForPackage();

  // Create a specific avatar
  final avatar = Avataaar(
    topType: TopType.shortHairShortFlat,
    eyeType: EyeType.happy,
    mouthType: MouthType.smile,
    skinColor: SkinColor.light.color,
  );

  // Or generate a random one
  final random = Avataaar.random();

  // Render to SVG string
  final svg = await avatar.toSvg(loadAsset: loader.load);
  File('avatar.svg').writeAsStringSync(svg);

  // Serialise to/from JSON
  final json = avatar.toJson();
  final restored = Avataaar.fromJson(json);
}
```

You can also point `FileAssetLoader` at an explicit directory, or implement
your own `AssetLoader` function for custom sources (HTTP, in-memory, etc.):

```dart
final loader = FileAssetLoader('/path/to/assets');
final svg = await avatar.toSvg(loadAsset: loader.load);
```

> **For Flutter apps**, use the [`avatar_builder`](https://pub.dev/packages/avatar_builder) package which provides `AvatarWidget` and built-in asset loading via `SvgCache`.

## Customisation options

| Category | Enum | Options |
|----------|------|---------|
| Style | `AvatarStyle` | circle, transparent |
| Hair / Hat | `TopType` | 34 styles |
| Hair color | `HairColor` | 12 colors |
| Accessories | `AccessoriesType` | 7 types |
| Facial hair | `FacialHairType` | 6 types |
| Eyes | `EyeType` | 12 styles |
| Eyebrows | `EyebrowType` | 13 styles |
| Mouth | `MouthType` | 12 styles |
| Clothing | `ClotheType` | 9 types |
| Clothing color | `ClotheColor` | 15 colors |
| Graphic (on shirts) | `GraphicType` | 11 designs |
| Skin | `SkinColor` | 7 tones |

## License

BSD 2-Clause License — see [LICENSE](LICENSE) for details.
