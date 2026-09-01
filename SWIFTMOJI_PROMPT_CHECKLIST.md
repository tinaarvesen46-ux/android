# SwiftMoji & Profile Implementation Checklist — Synchronized Status

This file is synchronized with `SWIFTMOJI_CHECKLIST.md` and `FINISHED_SWIFTMOJI_STATUS.md`.

## Verified implementation

- [V] Local/VPS deployment gap fixed for profile-header controller, model, event, renderer, avatar controller, importer, migration, and routes.
- [V] `profile_header_configs` and `avatar_assets` migrations are applied on the VPS.
- [V] VPS has exactly 286 `avatar_assets` rows and a valid 286-entry manifest across 13 categories.
- [V] Catalog storage is `storage/app/avatars_catalog`; render cache is `storage/app/avatars_cache`; 169 thumbnails exist.
- [V] `.svgf` fragment rendering and header composition are live and XML-valid.
- [V] Public catalog, thumbnail, avatar-render, and profile-header-render HTTP endpoints return successful responses.
- [V] Profile screen is header-first with centered hero composition, notification/share/QR/settings controls, primary pills, compact stats, SwiftSnap+, Family Centre capability state, content sections, Friends/Map/Favourites/Public Profile entries, and deep settings moved behind Settings.
- [V] Profile story rows and counters use real provider/API data; publishing actions use the existing Camera destination flow and no unsupported fake story data.
- [V] Camera Memories interaction uses one-pointer vertical drag and two-pointer zoom without competing drag layers.
- [V] Profile Header Editor has backend persistence, validation, preview, selectors, gestures, loading/error/empty states, cancel, save, and reset.
- [V] AvatarStudio loads all paginated catalog entries, displays unavailable metadata safely, and saves/resets through validated avatar endpoints.
- [V] Realtime event classes, private channel authorization, Reverb config, reconnect handling, and missed-state endpoint are present.
- [V] Push registration paths and WebRTC signaling scaffolding match the deployed backend contracts.

## Remaining honest status

- [~] Android/iOS visual and gesture verification is pending because the Flutter SDK and devices are unavailable here.
- [~] Reverb delivery and missed-event reconciliation are not claimed end-to-end without a running client session.
- [~] Full locale rendering/translation coverage is not claimed; locale propagation and supported-locale fallback are wired.
- [~] FCM/APNs native acquisition and terminated-app delivery require project credentials and native provisioning.
- [B] Functional WebRTC calling remains blocked because native `flutter_webrtc` media tracks and calling UI are not present; no native runtime is available for end-to-end verification.
- [B] Flutter/Dart static analysis cannot run because those executables are unavailable in the workspace environment.

## Release preparation

- [V] Android package ID `com.primio.swiftsnap.pkvtsv`, version `1.0.0+8`, release permissions, and release signing configuration were inspected; the local upload keystore is configured.
- [V] iOS bundle ID `com.primio.swiftsnap.pkvtsv`, version `1.0.0+8`, usage descriptions, deployment target, Release scheme, and Flutter release configuration were inspected.
- [B] Android APK/AAB release builds cannot run here because Flutter, Dart, Java, and Gradle are unavailable, and the project has no Gradle wrapper executable.
- [B] iOS archive/release signing cannot run here because this is Windows without Xcode/macOS; the project also has no configured Apple development team or provisioning identity.

No approved-asset blocker remains: the provided local `avatar_builder` assets were imported and verified without external URLs.

## Settings / Chat / My AI continuation

- [V] Settings search and complete navigable hierarchy are implemented without removing existing security, privacy, data, language, report, or account-action routes.
- [V] Local settings persistence and existing API-backed settings flows remain wired.
- [V] Chats has one pinned first-class My AI conversation from the normal conversation/participant/message graph, a dedicated responsive screen with real loading/error/retry handling, and normal chat story-aware header/call controls.
- [V] My AI Laravel provider boundary, authenticated routes, dedicated `ai_agents` identity/config table, system user, persistence migration, and safe conversation-type migration are deployed and verified.
- [B] Actual My AI inference is unavailable because no provider/model is configured on the production VPS; no unsafe model install was attempted.
- [~] Physical-device visual, native call, and configured-provider verification remains pending.
