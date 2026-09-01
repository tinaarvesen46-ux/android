# SwiftMoji / Profile / Camera Completion Checklist

This is the current evidence-based status. `[V]` means implemented and verified; `[~]` means implemented but requiring device/native or end-to-end verification; `[B]` means the required local tool/dependency is unavailable.

## SwiftMoji backend and deployment

- [V] `avatar_assets` migration and model are present locally and deployed.
- [V] `profile_header_configs` migration, model, controller, and event are present locally and deployed.
- [V] Local and VPS hashes match for the profile-header controller/model/event, avatar controller, renderer, importer, migration, and route file.
- [V] Importer accepts the local `avatar_builder` directory, `.svg`, `.svgf`, and raster assets, and does not fetch external Bitmoji URLs.
- [V] Exactly 286 real local asset files were imported and registered; VPS `avatar_assets` count is exactly 286.
- [V] Manifest exists at `storage/app/avatars_catalog/manifest.json`, parses successfully, and contains 286 entries in 13 categories.
- [V] VPS catalog storage contains 456 files including the manifest; it contains 107 `.svgf` files and 338 PNG files.
- [V] VPS thumbnail storage contains exactly 169 PNG thumbnails under `storage/app/avatars_catalog/thumbnails/`.
- [V] Renderer composes the imported `.svgf` fragments, applies default imported components, and supports header position/scale/rotation.
- [V] Render cache uses Redis keys `swiftmoji:render:{hash}` and writes SVG files under `storage/app/avatars_cache`.
- [V] Avatar update/reset validates enabled DB assets, persists config, invalidates old cache, and broadcasts `AvatarUpdated`.
- [V] `GET /api/v1/avatar/catalog`, thumbnail, avatar-render, and header-render endpoints return successful live responses.
- [V] Cached profile-header SVG passed PHP DOM XML validation.
- [V] `php artisan migrate --force` reports no pending migrations; both relevant migrations are `Ran`.

## Profile UX

- [V] Header-first profile hierarchy is implemented: hero/background, centered avatar identity, role/verification, back/notifications/share/QR/settings, account pills, stats, SwiftSnap+, Family Centre capability state, Stories, Memories, Spotlight, Post to, Friends, Snap Map, Favourites, and Public Profile.
- [V] Profile sections use real provider/API data where available, expose all backend story groups, and route publishing through the existing Camera → destination flow without fabricated content.
- [V] Deep settings remain in the dedicated Settings architecture and existing settings routes are preserved.
- [V] Profile hero action pills use equal-width responsive sizing to avoid small-screen overflow.
- [~] Final visual layout and navigation need Android/iOS device verification; Flutter SDK is not installed in this workspace.

## Camera → Memories

- [V] Camera preview uses one scale recognizer: one-pointer vertical movement drives the interactive Memories panel; two pointers drive zoom; taps remain focus gestures.
- [V] Upward threshold/velocity opens the panel, downward threshold/velocity closes it, and the panel follows the finger.
- [V] Preview pause/resume is guarded for lifecycle changes, controller replacement, animation races, and disposal.
- [~] Hardware tuning of camera gesture thresholds and platform camera behavior remains unverified without a device.

## Profile Header Editor

- [V] GET/PUT/reset endpoints, validation, persistence, realtime event, and server-rendered header route are deployed and route-listed.
- [V] Editor has loading, error/retry, empty catalog, preview, background/pose selectors, drag/pinch positioning, reset position, cancel, save, and reset flows.
- [V] Editor selectors only allow catalog items reported `available: true` and resolve media URLs correctly.
- [~] Final gesture feel and visual preview require device verification.

## AvatarStudio

- [V] Catalog navigation, paged loading through all server entries, category tabs, thumbnails, selected state, unavailable metadata state, preview dialog, save, reset, loading, empty, and error/retry states are implemented.
- [V] Avatar save/reset now use the validated `/avatar` backend contract; only `available: true` entries are selectable.
- [V] Live catalog response and thumbnail endpoint were verified against the 286 imported assets.
- [~] Final device visual verification remains pending because Flutter tooling is unavailable.

## Realtime, settings, localization, push, and WebRTC

- [V] `AvatarUpdated` and `ProfileHeaderUpdated` broadcast on private `user.{id}`; both include explicit event names and timestamps.
- [V] Reverb config, token-based broadcasting auth, private-channel authorization, client subscription, reconnect/backoff, heartbeat, and `/realtime/missed` snapshot reconciliation are present and route-verified.
- [~] Live Reverb delivery and client state reconciliation require a running mobile/client session and are not claimed as end-to-end verified.
- [V] Dedicated Settings routes and runtime locale propagation with supported-locale fallback are wired.
- [~] Full on-device locale rendering and complete translation coverage are not verified; feature copy remains partly literal.
- [V] Push device registration client paths match deployed `/devices/register` and `/devices/unregister` contracts.
- [~] FCM/APNs token acquisition, native permissions, credentials, and terminated-app delivery require unavailable project credentials/native environment.
- [V] WebRTC client signaling scaffolding matches deployed call routes (`accept`, `decline`, `end`, `signal`, and `ice-servers`).
- [B] Functional WebRTC calling remains blocked because native `flutter_webrtc` media tracks and calling UI are not present; no native runtime is available for end-to-end verification.

## Final checks

- [V] PHP lint passes for all changed PHP files, including routes.
- [V] VPS Laravel route list contains profile-header, catalog, thumbnail, render, header-render, and missed-reconciliation routes.
- [V] VPS test directory was checked; no Laravel test suite is present.
- [B] `flutter analyze`, `dart analyze`, and `dart format` cannot run because Flutter/Dart are not installed on this machine.

## Release preparation

- [V] Android package ID `com.primio.swiftsnap.pkvtsv`, version `1.0.0+8`, release permissions, and release signing configuration were inspected; the local upload keystore is configured.
- [V] iOS bundle ID `com.primio.swiftsnap.pkvtsv`, version `1.0.0+8`, usage descriptions, deployment target, Release scheme, and Flutter release configuration were inspected.
- [B] Android APK/AAB release builds cannot run here because Flutter, Dart, Java, and Gradle are unavailable, and the project has no Gradle wrapper executable.
- [B] iOS archive/release signing cannot run here because this is Windows without Xcode/macOS; the project also has no configured Apple development team or provisioning identity.

Safety: no external Bitmoji asset fetcher was run and no external avatar URLs were introduced.

## Settings / Chat / My AI continuation

- [V] Settings landing now has a real search field and a complete directory for Account, Profile, Privacy, Notifications, Location & Map, Memories, Data Saver, Personalisation, Music, Generative AI, Family Centre, Made For Me, Chat, Story, Camera, Appearance, Support, Legal, and Account actions.
- [V] Settings hierarchy routes each directory entry to an existing backend-backed screen or a persisted local preference screen; existing password, 2FA, phone, sessions, privacy, reports, data, permissions, language, delete, and logout routes remain available.
- [V] Local preference rows persist through SharedPreferences, while privacy, notification, account, report, export, and security mutations continue using their existing API repositories.
- [V] Chats loads one stable pinned first-class My AI conversation from the normal conversation/participant graph, with a single local UI fallback only when the conversation API is unavailable.
- [V] My AI has a dedicated responsive conversation screen with suggestions, composer, loading, error, retry, and server-only provider boundary. Normal chat headers now show story-aware avatars and audio/video call request controls tied to the existing call signaling service.
- [V] VPS has the My AI endpoint, provider service, route, and safe conversation-type migration deployed; PHP lint, migration, route registration, and deployed-file hash checks passed.
- [B] A real My AI answer cannot be verified because the production VPS has no configured `AI_PROVIDER`, `AI_BASE_URL`, or `AI_MODEL`; no model was installed on the 4-vCPU/7.8-GiB/no-GPU production host.
- [~] Settings/chat visual fidelity and native call/device behavior remain subject to the user's physical-device verification.
