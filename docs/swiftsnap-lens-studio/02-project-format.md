# SwiftSnap Lens Project Format (`.swiftsnaplens`)

A `.swiftsnaplens` is a ZIP archive containing:

```
project/
├── manifest.json     # required
├── scene.json        # required
├── assets/           # textures / models / audio / fonts
└── thumbnails/       # preview images
```

## manifest.json

```json
{
  "swiftsnap_lens_version": "1.0.0",
  "uuid": "b1c9...",
  "name": "Summer Glow",
  "description": "...",
  "category": "beauty",
  "capabilities_used": {
    "face_tracking": false,
    "beauty": true,
    "2d": true,
    "3d": false,
    "particles": false
  }
}
```

## scene.json

Describes the object hierarchy plus effect chain. Declarative — no code
execution is ever performed by the Runtime.

```json
{
  "engine": "native",
  "scene": {
    "objects": [
      {
        "type": "overlay",
        "anchor": "eyes",
        "texture": "sunglasses.png",
        "transform": { "x": 0, "y": 0, "scale": 1.0, "rotation": 0 }
      }
    ]
  },
  "effects": [
    { "type": "beauty",
      "params": { "smooth": 20, "tan": 15, "glow": 25, "teeth": 10, "eye": 10 }
    }
  ],
  "interactions": [
    { "trigger": "smile", "action": "activate_object", "object_id": "conf_particles" }
  ]
}
```

## Server representation

The database stores `scene.json` inline in `lenses.config` (JSON column)
plus `capabilities_used` (JSON) so the Runtime can quickly decide whether
a given lens is loadable on the current device. Assets live in
`lens_assets` and are streamed via authorized endpoints.
