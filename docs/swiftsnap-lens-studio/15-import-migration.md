# Import & Migration Center

`POST /api/v1/lens-studio/import` accepts a `multipart/form-data` upload
of a `.zip` (up to 100 MB) and returns a compatibility report. **No
external format is executed** — assets are extracted, classified,
imported into the creator's asset library where supported, and everything
else is honestly reported as `convertible` or `unsupported`.

## Response shape

```json
{
  "report": {
    "supported":   [{"file": "glasses.png", "kind": "texture", "asset_id": 42}],
    "convertible": [{"file": "material.mat", "reason": "requires manual conversion"}],
    "unsupported": [{"file": "script.js",   "reason": "scripting components are not supported by the SwiftSnap Lens Runtime"}]
  },
  "imported_asset_ids": [42, 43, 44],
  "external_manifest": { "...": "the external project.json we found, verbatim" }
}
```

## Rules

1. Never silently discard content. If a file is skipped, it appears in
   `unsupported` with a plain-English reason.
2. Never claim compatibility. Proprietary Lens Studio scripts, materials,
   and runtime components always end up in `unsupported`.
3. Never assume redistribution rights. The import path is asset-level.
   The creator must own or be licensed to use every imported asset.
4. Executable files (`.js`, `.script`, `.lsproj`, `.lsdata`, etc.) are
   never persisted.
5. Files above 20 MB are refused with a "please compress" message.

## Approved file classifications

| Extension | Kind | Handling |
|---|---|---|
| png, jpg, jpeg, webp, gif | texture | imported |
| svg | texture | imported |
| glb, gltf | model | imported, but only rendered when `threed_objects=true` |
| mp3, wav, ogg, m4a | audio | imported |
| ttf, otf | font | imported |
| json (`manifest.json` or `project.json`) | manifest | parsed and returned as `external_manifest` |
| lsproj, lsdata, js, script | executable | refused |
| other | convertible | shown to creator |

The creator can then open Lens Studio → Create Project → drop imported
assets onto the scene.
