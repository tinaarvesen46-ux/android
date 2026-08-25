# Capability Manifest

`GET /api/v1/lens-studio/capabilities` returns the current SwiftSnap Lens
Runtime capability matrix. **The values are truthful** — a `false` means
the runtime does not implement the capability, not that it will one day.

```json
{
  "face_tracking":     true,     // via google_mlkit_face_detection (mobile)
  "face_landmarks":    true,
  "face_mesh":         false,
  "face_anchors":      true,
  "skin_segmentation": true,     // YCbCr heuristic
  "beauty_effects":    true,
  "twod_objects":      true,
  "threed_objects":    false,
  "particles":         false,
  "world_tracking":    false,
  "hand_tracking":     false,
  "interactions":      ["tap", "smile", "blink", "mouth_open"],
  "anchors_supported": ["face", "eyes", "nose", "mouth", "face_region", "head", "screen"],
  "formats_supported": ["png", "jpg", "jpeg", "webp", "gif", "svg",
                         "gltf", "glb", "mp3", "wav", "ogg", "m4a",
                         "ttf", "otf"],
  "manifest_version":  "1.0.0"
}
```

## Blocked by external SDK

| Capability | Blocker |
|---|---|
| face_mesh (dense mesh) | Requires DeepAR / Banuba / Snap Camera Kit |
| threed_objects (advanced) | Requires a commercial AR engine |
| particles (GPU) | Requires OpenGL/Metal integration |
| world_tracking | Requires ARCore/ARKit binding |
| hand_tracking | Requires MediaPipe Hands binding |

The base runtime is designed so any of these can be plugged in later
without rebuilding the creator studio, catalog, or moderation surface —
only the render layer needs the new SDK.
