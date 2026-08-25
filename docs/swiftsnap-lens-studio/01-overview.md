# SwiftSnap Lens Studio — Overview

SwiftSnap Lens Studio is SwiftSnap's original creator ecosystem for building
camera effects. It is inspired by public Lens creation ecosystems but does
not depend on, copy, or reverse-engineer any proprietary Lens Studio
software, runtime, or format.

## Three components
1. **Web Creator Studio** (`/creator/lens-studio` on the React site) —
   project management, asset library, template picker, import center,
   analytics.
2. **Mobile Preview** — inside the Flutter app; the same Lens Runtime used
   by end users renders the creator's project against the real device
   camera.
3. **Mobile Lens Runtime** — bundled with SwiftSnap; downloads published
   lenses, validates the manifest, loads assets, renders supported
   effects, records usage.

## Data flow

```
Creator → Studio → Project → API → DB
                       ↓
                    Admin moderation
                       ↓
                    Approved
                       ↓
                    API discovery
                       ↓
                    Mobile Runtime
                       ↓
                    User camera
```

## Repository layout

- `app/Http/Controllers/Api/Mobile/LensController.php` — user-facing
  browsing / favoriting / reporting / usage.
- `app/Http/Controllers/Api/Mobile/LensStudioController.php` — creator +
  admin surface (create, save, submit, upload asset, import, moderate).
- `database/migrations/*_snapchat_parity_tables.php` — lenses tables.
- `database/migrations/*_lens_studio_tables.php` — lens_assets, templates,
  capability columns.
- `resources/js/pages/admin/AdminLenses.jsx` — admin/creator moderation
  console.
- `resources/js/pages/creator/LensStudio.jsx` — web editor.

## External reference

The official public repository at
<https://github.com/Snapchat/lens-studio-templates> is used **only as
architectural reference** for how a professional Lens ecosystem is
structured. No proprietary code, format, or template is copied into
SwiftSnap. Every SwiftSnap template is an original SwiftSnap Lens Project.
