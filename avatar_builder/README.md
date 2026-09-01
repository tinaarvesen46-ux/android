# Avatar Builder

A Flutter widget that renders customizable [avataaars](https://getavataaars.com/)-style cartoon avatars. Choose from 34 hairstyles, 12 eye styles, 13 eyebrow styles, 12 mouth styles, 9 clothing options, and more — or generate a random avatar with a single line of code.

[![pub package](https://img.shields.io/pub/v/avatar_builder.svg)](https://pub.dev/packages/avatar_builder)
[![Pub publisher](https://img.shields.io/pub/publisher/svg_path_transform.svg)](https://pub.dev/publishers/bramp.net/packages)
[![Dart Analysis](https://github.com/bramp/svg_path/actions/workflows/dart.yml/badge.svg)](https://github.com/bramp/avatar_builder/actions/workflows/test.yml)
[![License](https://img.shields.io/github/license/bramp/avatar_builder)](https://github.com/bramp/avatar_builder/blob/main/LICENSE)

<table>
  <tr>
    <td><img src="https://raw.githubusercontent.com/bramp/avatar_builder/main/assets/samples/sample_1.svg" alt="avatar 1" width="120"></td>
    <td><img src="https://raw.githubusercontent.com/bramp/avatar_builder/main/assets/samples/sample_2.svg" alt="avatar 2" width="120"></td>
    <td><img src="https://raw.githubusercontent.com/bramp/avatar_builder/main/assets/samples/sample_3.svg" alt="avatar 3" width="120"></td>
    <td><img src="https://raw.githubusercontent.com/bramp/avatar_builder/main/assets/samples/sample_4.svg" alt="avatar 4" width="120"></td>
    <td><img src="https://raw.githubusercontent.com/bramp/avatar_builder/main/assets/samples/sample_5.svg" alt="avatar 5" width="120"></td>
  </tr>
  <tr>
    <td><img src="https://raw.githubusercontent.com/bramp/avatar_builder/main/assets/samples/sample_6.svg" alt="avatar 6" width="120"></td>
    <td><img src="https://raw.githubusercontent.com/bramp/avatar_builder/main/assets/samples/sample_7.svg" alt="avatar 7" width="120"></td>
    <td><img src="https://raw.githubusercontent.com/bramp/avatar_builder/main/assets/samples/sample_8.svg" alt="avatar 8" width="120"></td>
    <td><img src="https://raw.githubusercontent.com/bramp/avatar_builder/main/assets/samples/sample_9.svg" alt="avatar 9" width="120"></td>
    <td><img src="https://raw.githubusercontent.com/bramp/avatar_builder/main/assets/samples/sample_10.svg" alt="avatar 10" width="120"></td>
  </tr>
</table>

**[Live Demo](https://bramp.github.io/avatar_builder/)** · **[API Reference](https://pub.dev/documentation/avatar_builder/latest/)**

## Features

- **140+ SVG fragments** composable into millions of unique avatars
- **Fully customizable**: hair, eyes, eyebrows, mouth, facial hair, clothing, accessories, skin color
- **Random avatar generation** via `Avataaar.random()`
- **Lightweight**: optimized SVG assets (~194 KB total)
- **Built-in LRU cache** for fast rendering
- **Circle or transparent** background styles
- **Pixel-perfect fidelity** to the original [avataaars](https://github.com/fangpenlin/avataaars) React library

## Getting started

Add `avatar_builder` to your `pubspec.yaml`:

```yaml
dependencies:
  avatar_builder: ^0.3.1
```

Then run:

```bash
flutter pub get
```

## Usage

Import the package:

```dart
import 'package:avatar_builder/avatar_builder.dart';
```

### Display a random avatar

```dart
AvatarWidget(avatar: Avataaar.random())
```

### Display a specific avatar

```dart
AvatarWidget(
  avatar: Avataaar(
    topType: TopType.shortHairShortFlat,
    accessoriesType: AccessoriesType.prescription01,
    hairColor: HairColor.brown.color,
    facialHairType: FacialHairType.blank,
    clotheType: ClotheType.hoodie,
    clotheColor: ClotheColor.blue01.color,
    eyeType: EyeType.defaultEye,
    eyebrowType: EyebrowType.defaultBrow,
    mouthType: MouthType.smile,
    skinColor: SkinColor.light.color,
  ),
)
```

### Customize the size

```dart
AvatarWidget(
  avatar: Avataaar.random(),
  size: 200,
)
```

### Use a shared cache

`AvatarWidget` uses `SvgCache.instance` by default to cache loaded SVG fragments in memory. You can also provide your own cache:

```dart
final cache = SvgCache(maxEntries: 256);

AvatarWidget(
  avatar: Avataaar.random(),
  cache: cache,
)
```

### Extract the SVG string

Use `toSvg()` to get the composed SVG markup directly — useful for exporting, saving to a file, or server-side use:

```dart
final avatar = Avataaar(
  topType: TopType.shortHairShortFlat,
  eyeType: EyeType.happy,
  mouthType: MouthType.smile,
  skinColor: SkinColor.light.color,
);

final svgString = await avatar.toSvg(loadAsset: SvgCache.instance.load);
// svgString contains a complete <svg>...</svg> document
// with all colors applied.
```

> **For pure-Dart** (non-Flutter) use, see [`avatar_builder_core`](https://pub.dev/packages/avatar_builder_core) which includes a `FileAssetLoader` for `dart:io` environments.

## Customization options

| Category | Enum | Options |
|----------|------|---------|
| Style | [`AvatarStyle`](https://pub.dev/documentation/avatar_builder/latest/avatar_builder/AvatarStyle.html) | circle, transparent |
| Hair / Hat | [`TopType`](https://pub.dev/documentation/avatar_builder/latest/avatar_builder/TopType.html) | 34 styles (long hair, short hair, hats, turbans, hijab, etc.) |
| Hair color | [`HairColor`](https://pub.dev/documentation/avatar_builder/latest/avatar_builder/HairColor.html) | 12 colors |
| Accessories | [`AccessoriesType`](https://pub.dev/documentation/avatar_builder/latest/avatar_builder/AccessoriesType.html) | 7 types (glasses, sunglasses, etc.) |
| Facial hair | [`FacialHairType`](https://pub.dev/documentation/avatar_builder/latest/avatar_builder/FacialHairType.html) | 6 types |
| Eyes | [`EyeType`](https://pub.dev/documentation/avatar_builder/latest/avatar_builder/EyeType.html) | 12 styles |
| Eyebrows | [`EyebrowType`](https://pub.dev/documentation/avatar_builder/latest/avatar_builder/EyebrowType.html) | 13 styles |
| Mouth | [`MouthType`](https://pub.dev/documentation/avatar_builder/latest/avatar_builder/MouthType.html) | 12 styles |
| Clothing | [`ClotheType`](https://pub.dev/documentation/avatar_builder/latest/avatar_builder/ClotheType.html) | 9 types |
| Clothing color | [`ClotheColor`](https://pub.dev/documentation/avatar_builder/latest/avatar_builder/ClotheColor.html) | 15 colors |
| Graphic (on shirts) | [`GraphicType`](https://pub.dev/documentation/avatar_builder/latest/avatar_builder/GraphicType.html) | 11 designs |
| Skin | [`SkinColor`](https://pub.dev/documentation/avatar_builder/latest/avatar_builder/SkinColor.html) | 7 tones |

## Example app

A full interactive example is available in the [`example/`](example/) directory and deployed as a **[live demo](https://bramp.github.io/avatar_builder/)**.

To run it locally:

```bash
cd example
flutter run -d chrome
```

## Contributing

Contributions are welcome! See [DEVELOPMENT.md](DEVELOPMENT.md) for how the SVG data is generated and how to work on the package.

## Credits

Based on [avataaars-generator](https://github.com/fangpenlin/avataaars-generator) by [Fang-Pen Lin](https://github.com/fangpenlin), using avatar artwork by [Pablo Stanley](https://getavataaars.com/).

## License

BSD 2-Clause License — see [LICENSE](LICENSE) for details.
