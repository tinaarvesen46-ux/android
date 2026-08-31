# SwiftSnap

## Overview
SwiftSnap is a camera-first social communication app: real device camera, chat, stories, a vertical Reels feed, Discover, and a friend map. It is the Flutter client for an existing Laravel + MariaDB + Redis + Reverb backend hosted on the owner's VPS. The client never invents data — every list is backed by a real endpoint and shows loading, empty, error and retry states.

## Tech Stack & Key Decisions
- `camera` package drives a real sensor preview; the preview is cover-scaled to the sensor aspect ratio so framing matches the captured file
- `flutter_map` + OpenStreetMap tiles because the map must work without the user supplying any API key; geocoding is deliberately left to a backend proxy
- `geolocator` for position, `permission_handler` for camera/mic/photos/notification states with a real "open settings" recovery path
- `go_router` with `StatefulShellRoute.indexedStack` so the five primary tabs keep their state
- Dio + FlutterSecureStorage for bearer auth; a 401 clears the token
- Dark-only theme — a camera-first app needs media to dominate

## Architecture
- UI → Provider → Repository → ApiService → Laravel. Widgets never make HTTP calls
- `lib/core/` holds `LoadState` (idle/loading/success/empty/error) and `ApiFailure`; `guardApi` converts every Dio failure into a user-safe message
- `lib/core/json_mappers.dart` centralises defensive JSON→model mapping and tolerates both bare arrays and Laravel paginator envelopes
- Repositories are the only place backend contracts appear in executable code
- Each repository carries its endpoint contract as a class-level doc comment (method, path, payload) — that is the single source of truth for the Laravel integration
- Settings persist through SharedPreferences today; server-side sync is an open backend gap

## Conventions
- Bottom nav is fixed: MAP · CHAT · CAMERA · DISCOVER · REELS, camera centred inside the nav container and never a floating button
- Profile is not a tab — it is reached contextually from chat, map, discover, reels, search, friends, notifications and user cards
- Providers expose `LoadState<T>` plus `load()`/`retry()`; mutating methods return `String?` (null on success, user-facing message on failure)
- Screens render async data through `AsyncStateView`; partial failures use `InlineErrorBar`
- All colours come from `colorScheme` or `AppColorsExtension`; content over media uses `onMedia` on a `mediaScrim`
- Spacing, radii, icon sizes, opacities and borders come from `AppTheme` constants

## Key Patterns & Gotchas
- Nothing is published from the camera automatically: capture → preview → explicit destination → upload → publish. A success message appears only after a 2xx
- Capture publishing is refused on web on purpose — the browser path is an object URL, not a multipart file
- Front-camera stills are un-mirrored in the preview so the result matches what the user framed
- The backend base URL is live but most endpoints may not exist yet; that is why every screen must keep a working error + retry path
- Realtime (Reverb), WebRTC calling and push transport are not wired yet; the expected channel and event names are noted in the relevant repository doc comments

## Design System
- True black background with `#1C1C1E` cards and a darker nav bar, tuned for OLED
- SwiftSnap yellow is an accent only: the camera button and premium surfaces, never a background
- Inter throughout; compact Snapchat-like density rather than dashboard density
- Media surfaces (camera, reels, map, story viewer) use scrim + `onMedia` instead of solid chrome
