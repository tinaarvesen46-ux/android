# Development

## Regenerating SVG Data

The SVG fragments in `lib/assets/` are generated from the original React avataaars library. To regenerate after changes:

### Prerequisites

- Node.js
- Python 3
- The `avataaars-generator` submodule checked out

### Steps

```bash
# 1. Clone with submodules (if not already done)
git submodule update --init

# 2. Install dependencies in the React project
cd avataaars-generator
npm install
npm install cheerio --no-save --legacy-peer-deps

# 3. Extract SVG fragments from the React components
NODE_PATH=./node_modules node ../tools/extract_svg_fragments.js

# 4. Generate the Dart file from the extracted fragments
cd ..
python3 tools/generate_svg_data.py
```

This produces the `.svgf` asset files under `lib/assets/` and `lib/src/svg/svg_data.dart` containing asset path lookups, color mappings, and the `buildAvatarSvg()` function.

### How it works

1. **`tools/extract_svg_fragments.js`** — Uses `ReactDOMServer.renderToStaticMarkup()` to render each avatar variant, then parses the SVG with `cheerio` to extract individual component groups (eyes, mouths, hair, etc.). Sentinel hex colors are baked in as placeholders for runtime substitution. Output: `tools/svg_fragments.json`.

2. **`tools/generate_svg_data.py`** — Reads the JSON fragments, optimizes each one through [SVGO](https://github.com/svg/svgo) (with `cleanupIds` disabled to preserve cross-fragment ID references), and writes them as individual `.svgf` asset files under `lib/assets/`. It also generates `lib/src/svg/svg_data.dart` with asset path lookups, color mappings, and an async `buildAvatarSvg()` function that loads and composes fragments on demand.

   SVGO reduces the 107 SVG fragments from **348 KB → 194 KB (44% smaller)**.

3. **`lib/src/svg/svg_cache.dart`** — An LRU cache (`SvgCache`) that loads fragments from `rootBundle` on first access and keeps them in memory. The widget uses `FutureBuilder` to render once assets are ready.

## Testing

```bash
flutter test
```

See [TESTING_STRATEGY.md](TESTING_STRATEGY.md) for details on the testing approach including golden tests.
