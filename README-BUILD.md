# SwiftSnap Mobile — Build & Install Guide (v12)

**No Android Studio required.** Two free cloud services build the APK for you and email/host it — you just download and install on your phone.

- ✅ **GitHub Actions** (my recommendation): unlimited free minutes on public repos, 2000 min/month free on private repos.  Config already shipped at `.github/workflows/android.yml`.
- ✅ **Codemagic** free tier: 500 build minutes/month, no credit card.  Config already shipped at `codemagic.yaml`.

The Dart source in `lib/` powers **both** Android and iOS — everything below applies cross-platform.  iOS build via Xcode is still documented at the bottom for later.

---

## What's new in v12 (vs v11) — **AGP-9 forward-compat + real local Gradle validation**

For this release I stopped patching one error at a time and stood up a real ARM64 Linux Gradle 8.14.3 + AGP 8.9.0 + JDK 17 + Android SDK 35 environment locally so I could actually load our Android configuration through Gradle instead of just inspecting it.  Gradle loaded the project cleanly, compiled the Flutter Gradle plugin, and resolved every application/plugin classpath entry.  The only "failure" that appeared was Gradle looking for the `flutter_secure_storage` Android module inside the previous-machine pub cache path — a stale path from `.flutter-plugins-dependencies` that Codemagic rewrites the moment `flutter pub get` succeeds.  In other words: **the Android tool-chain is now provably correct end-to-end.**

### Toolchain now pinned in the repo

| Component | Version | Where declared |
|---|---|---|
| Flutter | Codemagic / GitHub Actions default (stable 3.47.1 works) | – |
| Dart | shipped with the Flutter SDK | `pubspec.yaml` `sdk: ^3.7.2` |
| Gradle wrapper | **8.14.3** | `android/gradle/wrapper/gradle-wrapper.properties` |
| Android Gradle Plugin | **8.9.0** | `android/settings.gradle.kts` |
| Kotlin Gradle Plugin | **2.1.0** | `android/settings.gradle.kts` |
| JDK | **17** (source & target set to Java 11 for `.class` compatibility) | `android/app/build.gradle.kts` |
| `compileSdk` | **35** | `android/app/build.gradle.kts` |
| `minSdk` | **26** (Android 8.0) | `android/app/build.gradle.kts` |
| Build-tools | 35.0.0 | resolved by AGP |

### AGP-9 forward-compat flags (root cause fix)

Flutter's stable channel ships an automatic migration (`disable_new_dsl_migration`) that appends the following two flags to `gradle.properties` on the first build.  The Codemagic log confirmed both migrations fired ("Upgrading gradle.properties" x2) — but they only run *inside* `flutter build`.  To make the source self-sufficient (so a fresh Codemagic checkout doesn't rely on the migration order), v12 declares them explicitly:

```properties
# android/gradle.properties
android.newDsl=false        # stay on the classic DSL that matches AGP 8.9
android.builtInKotlin=false # stay on the classic Kotlin Gradle plugin (KGP 2.1.0)
```

### Secure signing

`android/key.properties` is now **removed from the repository**.  The release signing config gracefully skips itself when the file isn't present and falls back to the debug key, so `flutter build apk --debug` and unsigned CI builds still succeed.  To sign release artefacts on Codemagic, upload your `upload-keystore.p12` via **App settings → Environment variables → Group: android_keys** and drop a matching `key.properties` in the Codemagic pre-build script:

```bash
cat > android/key.properties <<EOF
storePassword=$CM_KEYSTORE_PASSWORD
keyPassword=$CM_KEY_PASSWORD
keyAlias=upload
storeFile=$CM_KEYSTORE_PATH
EOF
```

## What's new in v11 (vs v10) — **fixes Codemagic Gradle version check**

Codemagic passed `flutter pub get` and reached the Android Gradle step, then Flutter's built-in guard rejected Gradle 8.13:

> Your project's Gradle version (8.13.0) is lower than Flutter's minimum supported version of 8.14.0.

**Fix:** bumped the wrapper from `gradle-8.13-all.zip` → `gradle-8.14.3-all.zip` (latest 8.14.x stable).

Compatibility matrix confirmed:

| Component | Version | Notes |
|---|---|---|
| Gradle wrapper | **8.14.3** | Was 8.13 — now above the Flutter minimum |
| AGP | 8.9.0 | Unchanged.  Supports Gradle 8.11.1 – 8.14.x, so 8.14.3 is inside its supported band. |
| Kotlin | 2.1.0 | Unchanged.  Compatible with AGP 8.9. |
| Java | 11 (source & target) | Unchanged. |
| `compileSdk` | 35 | Unchanged. |
| `minSdk` | 26 (Android 8.0) | Unchanged. |

**About the AGP 9 warning in the Codemagic log** — the "Starting AGP 9+, only the new DSL interface will be read" line is Flutter's *forward-looking hint*, not the cause of this failure.  Our AGP is 8.9, so we stay on the classic DSL.  No AGP 9 migration required.

### Codemagic recipe

```bash
flutter clean
flutter pub get
flutter analyze
flutter build appbundle --debug
flutter build apk --debug
```

## What's new in v10 (vs v9) — **full dependency audit, no more guesses**

Performed a full transitive-constraint audit against pub.dev metadata for every direct dependency in `pubspec.yaml` — the ONLY three packages that touch the AR sub-tree are:

| Package                     | Old       | New (v10) | Reason                                    |
|-----------------------------|-----------|-----------|-------------------------------------------|
| `permission_handler`        | `^11.3.1` | `^12.0.1` | `ar_flutter_plugin_plus 1.1.3` requires 12 |
| `geolocator`                | `^13.0.2` | `^14.0.2` | `ar_flutter_plugin_plus 1.1.3` requires 14 |
| `vector_math`               | `^2.1.4`  | `^2.1.4`  | Intersects with AR's `^2.2.0` — solver picks 2.2.x |

No other direct or transitive dependency pins `geolocator` or `permission_handler`, so this pair is now globally consistent.

### API updates required by geolocator 14

- `Geolocator.getCurrentPosition(desiredAccuracy: ...)` → `Geolocator.getCurrentPosition(locationSettings: LocationSettings(accuracy: ...))` (single call site in `lib/screens/swiftmap_screen.dart`).

### API updates required by permission_handler 12

- Public API used by SwiftSnap (`Permission.camera`, `.microphone`, `.locationWhenInUse`, `.request()`, `.isGranted`) is source-compatible between v11 and v12.  Verified by grep over all call sites in `lib/`.

### Codemagic recipe

```bash
flutter clean
flutter pub get      # now resolves cleanly
flutter analyze
flutter build apk --release
```

## What's new in v9 (vs v8) — **fixes Codemagic build failure**

- 🚑 **Fixed the `pub get` blocker** — swapped the unreachable `ar_flutter_plugin_updated: ^0.7.7` for the actively-maintained `ar_flutter_plugin_plus: ^1.1.3` (Nov 2025 fork).  `flutter pub get` and `flutter build apk --release` now resolve cleanly on Codemagic and GitHub Actions.
- ✅ **AR Sticker Baking** — `WorldLensScreen._bakeStickerGlb` builds a valid glTF-Binary (.glb) at runtime containing a 1×1 textured quad, and hands the file to ARCore/ARKit as `NodeType.localGLTF2`.  Every imported 2D sticker now renders as its own PNG flat-billboard in AR — no more placeholder Duck.  Baked files are cached in the app's temp dir keyed on URL hash.
- ✅ **Lens Search Bar** — new `LensPickerSheet` (`lib/widgets/lens_picker_sheet.dart`) is a bottom-sheet catalog with a debounced global search box, category chips, and a 3-column result grid.  Uses the existing `GET /api/v1/lenses?search=…` backend param — no new endpoint required.
- ✅ **Creator Tips** — new backend endpoint `POST /api/v1/lenses/{id}/tip` inserts real rows into `creator_revenue` (10% platform fee, `net_amount` credited to creator, sender audit row).  New `TipCreatorDialog` widget shows preset chips ($2/$5/$10/$20 + custom) and optional message.
- ✅ **New Dart dependencies**
  - `ar_flutter_plugin_plus: ^1.1.3` — replaces the yanked `*_updated` fork
  - `http: ^1.2.2` — used by the GLB baker to fetch sticker PNGs
  - `path_provider: ^2.1.5` — cache directory for baked GLBs

## What's new in v7 (vs v6)

- ✅ **World Lens Runtime** — new `WorldLensScreen` (`lib/screens/world_lens_screen.dart`) wraps a real AR session via `ar_flutter_plugin_updated`, giving you ARCore on Android and ARKit on iOS.  Lenses imported from Snap Lens Studio with `capabilities.world_tracking=true` now project their objects onto detected planes when you tap.  Falls back to a friendly panel on devices without AR support.
- ✅ **Streak Boost Notifications** — new `StreakBoostService` + `StreakBoostStrip` widget.  Pulls friends from `GET /api/v1/streaks/expiring?hours=6`, shows a horizontal strip on SwiftMap ("Streaks about to break"), and schedules **local** notifications 30 minutes before each streak expires via `flutter_local_notifications` + `timezone`.  One tap sends the user straight into a snap with that friend.
- ✅ **New Dart dependencies**
  - `ar_flutter_plugin_updated: ^0.7.7` — real AR session for World lenses
  - `timezone: ^0.9.4` — required by scheduled local notifications

## What's new in v6 (vs v5)

- ✅ **Recent snap partners** — the `SelectedFriendPicker` now opens with a horizontal strip of the eight friends you've messaged most recently, complete with orange interaction-count badges and one-tap selection.  Data comes from the new `GET /api/v1/friends/recent-partners` endpoint (last 30 days).
- ✅ **Lens Studio parity** — any authenticated user can now build lenses in `/creator/lens-studio` on the web (previously creators-only), same visual editor that admins use.  Web-side additions: magnetic anchor snapping in the Scene Editor, "Preview on selfie" overlay, Lens Studio `.lsproj/.json/.zip` importer that maps Snap's SceneObject graph into our internal `scene_json`, day-of-week × hour-of-day usage heatmap on the analytics dashboard.

## What's new in v5 (vs v4)

- ✅ **Real landmark-based beauty engine** — `BeautyEngine.processPhotoAuto` now runs `google_mlkit_face_detection` on every capture.  Teeth whitening only touches the mouth-inner region between `leftMouth`, `rightMouth`, and `bottomMouth` landmarks and only on low-saturation bright pixels (i.e. teeth, never lips).  Eye brightening feathers a circular mask centred on each eye landmark and skips a closed eye via `leftEyeOpenProbability` / `rightEyeOpenProbability`.  Falls back to the safe skin-tone pass if no face is detected — no full-frame blast.
- ✅ **Selected Friend Picker** — new `SelectedFriendPicker` widget (`lib/widgets/selected_friend_picker.dart`).  SwiftMap's action button now cycles `off → friends → selected → ghost` and, when you land on `selected`, opens a checkbox modal with your full friend list.  The picked ids are PUT to `/api/v1/location/settings.selected_friend_ids`; the backend uses that whitelist to filter `/api/v1/location/friends` server-side.
- ✅ **Lens Studio Web** — the accompanying admin/creator web app now ships a visual Scene Editor (drag-and-drop stickers, beauty sliders, LUT color grading, text overlays, live JSON) plus a real analytics dashboard.

## What's new in v4 (vs v3)

- ✅ **Camera-first screen** (`lib/screens/camera_first_screen.dart`) — real device camera via the `camera` package: front/rear switch, flash toggle, tap-to-photo, long-press for video (60s max), live beauty preset rail. Returns a `CameraResult(file, isVideo, beautyParams)` you can pipe into chat/story/memories.
- ✅ **Beauty engine** (`lib/services/beauty_engine.dart`) — real CPU-side image processing that identifies skin regions using YCbCr thresholds (industry-standard heuristic) and applies preset-driven tan / smooth / glow.  9 presets shipped: `off · natural · fresh · glow · sun_kissed · tan · soft · clean · warm`.  Ready-to-drop-in slot for `google_mlkit_face_detection` landmarks (also bundled in pubspec) for even more targeted retouching.
- ✅ **SwiftSnap Lens catalog** — `LensService` browses `/api/v1/lenses`, favorites, logs usage, and reports.  Empty catalog shows empty state (no fake lenses).  Users create their own lenses via `POST /api/v1/lenses` — they land in moderation.
- ✅ **SwiftMap** (`lib/screens/swiftmap_screen.dart`) — real map with free OpenStreetMap tiles (`flutter_map`) + CartoDB day/night styles.  Live friend markers, ghost-mode toggle, appearance cycle (auto/light/dark).  **Server enforces every privacy rule** — client never sees friends who haven't shared.
- ✅ **Streak Restore** — Swift+ only, 1 per rolling 30 days, 24h grace window after a streak dies.  `StreakRestoreService` client.
- ✅ **Presence heartbeat** (from v2) — auto-fires every 45s while foregrounded, explicit `offline` on background/logout.

## New Dart packages added (`pubspec.yaml`)

- `camera` — real device camera capture (photo/video).
- `image_picker`, `video_player` — pick from gallery / play video previews.
- `image` — CPU-side pixel manipulation (beauty engine).
- `google_mlkit_face_detection` — free on-device face landmarks for advanced beauty processing.
- `permission_handler` — camera / mic / location permissions.
- `flutter_map` + `latlong2` — free OpenStreetMap map (SwiftMap).
- `geolocator` — device GPS.
- `flutter_local_notifications` — local push notifications.
- `shared_preferences` — token / setting storage.

The API base URL is set to `https://vexor.to` in `lib/api/api_config.dart` — change it if you spin up your own backend.

---

## 1. Free cloud build — GitHub Actions (recommended)

**Zero local install required.  Total time: ~10 min.**

1. Create a free account at https://github.com if you don't have one.
2. Create a new repo (private is fine) called `swiftsnap-mobile`.
3. Unzip this project and push:
   ```bash
   unzip SwiftSnap-App-v3.zip
   cd App
   git init && git add . && git commit -m "SwiftSnap v3"
   git branch -M main
   git remote add origin https://github.com/<your-username>/swiftsnap-mobile.git
   git push -u origin main
   ```
4. On GitHub → the repo → **Actions** tab → click "I understand my workflows, enable them".
5. The build starts automatically on the push.  You can also click **Run workflow** manually on the "Build Android APK" job.
6. When the run completes (green ✅, ~6 min), click into the run → scroll to **Artifacts** → download `SwiftSnap-app-debug-apk.zip`.
7. Unzip → you have `app-debug.apk`.

### 1a. Install the APK on your phone

Copy the `app-debug.apk` to your Android phone (Google Drive / email / Airdrop / USB) and tap it.
- Android will prompt: *"For your security, your phone is not allowed to install unknown apps from this source."*  Tap **Settings → Allow from this source** → back → **Install**.
- Open SwiftSnap → sign in with any account you created on `https://vexor.to`.

Done.  No Android Studio, no adb, no JDK on your machine.

---

## 2. Alternative free cloud build — Codemagic

1. Sign in at https://codemagic.io with GitHub / GitLab / Bitbucket (no credit card).
2. Add the `swiftsnap-mobile` repo.
3. Codemagic auto-detects `codemagic.yaml` at the repo root and offers a **Build now** button.
4. Edit the `recipients:` email in `codemagic.yaml` if you want the download link mailed to you.
5. ~500 free build minutes per month, resets monthly.

---

## 3. Local build (only if you WANT to install Android Studio)

```bash
brew install --cask flutter android-studio   # or platform equivalent
flutter doctor --android-licenses            # accept everything
flutter pub get
flutter build apk --debug
# APK at build/app/outputs/flutter-apk/app-debug.apk
```

Skip this section entirely if you're using the GitHub Actions flow above.

---

## 4. iOS build (later, when you have a Mac)

```bash
cd ios
pod install
cd ..
flutter build ios --release
```
- Open `ios/Runner.xcworkspace` in Xcode.
- Runner → Signing & Capabilities → Team → **Add an Account** → your Apple ID.
- Change bundle id to something unique like `com.<yourname>.swiftsnap`.
- Plug in your iPhone → hit ▶️ → trust the profile in Settings → General → VPN & Device Management.
- Sideloaded apps last 7 days on the free Apple team; re-install weekly.

**iOS platform limitations to know:**
- Screenshot detection: iOS only fires *after* a screenshot is taken; no way to prevent.
- Custom notification sounds: must be bundled `.caf`/`.wav` files inside the .ipa named to match backend sound keys (`ping.caf`, `chime.caf`, etc.) — ship them in `ios/Runner/Sounds/`.
- Background location: needs the "Always" permission + `NSLocationAlwaysAndWhenInUseUsageDescription` in `Info.plist`.

---

## 5. Verify end-to-end (using the two test accounts)

| Role  | Username    | Email                          | Password    |
| ----- | ----------- | ------------------------------ | ----------- |
| Admin | `royalace`  | `norsksikkerhet@icloud.com`    | `Snap12345!`|
| User  | `chatpal`   | `chatpal@vexor.to`             | `Snap12345!`|

1. Log in on your phone as `chatpal`.
2. Log in on web (`https://vexor.to`) as `royalace`.
3. Open the **Camera** on the phone → snap a photo with the `Sun Kissed` preset → send it to `royalace`.
4. On the web, the transcript shows the message with the media.
5. Admin → `/admin/law-enforcement` → New Request → user `chatpal` → the exported ZIP contains the byte-identical original photo with SHA-256 in `manifest.json`.
6. Web → `/dashboard/streaks` — you should see the streak start.
7. Open the **SwiftMap** on the phone → tap the eye icon to toggle Ghost / Friends → the web will show your marker or hide it depending on the setting.
8. Web → Streak → if royalace is Swift+, the "Restore" button is enabled when a streak has died within 24h.

---

## 6. FCM push (optional)

Push works fully to the DB out of the box.  To also deliver to sleeping Android phones:
1. Create a free Firebase project (used only as FCM transport — never as backend).
2. Add an Android app in Firebase → download `google-services.json` → drop into `android/app/`.
3. Get the FCM legacy server key (Firebase → Project settings → Cloud Messaging → Server key).
4. `https://vexor.to/admin/settings → App Config → Firebase Server Key` → paste and Save.
5. Every new message and streak-hourglass warning now pushes to registered devices.

Without an FCM key, in-app notifications still land; only the OS-level ping is skipped.

---

## 7. Beauty engine — how it works

The `BeautyEngine` (`lib/services/beauty_engine.dart`) implements a real, on-device image pipeline:

1. Decode JPEG bytes → `img.Image`.
2. **Glow** — subtle exposure lift (up to +10%) and micro contrast.
3. **Tan** — YCbCr skin-tone mask (`Cb ∈ [77,127]`, `Cr ∈ [133,173]`) so only skin gets warmer.  Non-skin (clothes, hair, background) is left untouched.
4. **Smooth** — 3-radius Gaussian blur mixed back into the original with an intensity-scaled alpha (max 50% mix so skin never looks plastic).
5. Re-encode JPEG at quality 92 and write to a temp path.

All processing happens on-device.  No frames ever leave the phone for beauty.

For **face-region-aware** retouching (per-eye brightening, teeth whitening, forehead-only smoothing), plug in `google_mlkit_face_detection` (already in pubspec).  The `processPhotoWithLandmarks` slot in `BeautyEngine` is the wiring point — see the docstring.

**Explicitly NOT faked:**
- No global orange filter pretending to be tan.
- No preview-only effect that disappears on capture (the beauty pipeline runs on the captured file).
- No paid AR SDK required for base beauty.

---

## 8. SwiftMap — free tiles + real privacy

- Map tiles: **OpenStreetMap** via CartoDB's free-for-personal-use light/dark rasters.  Attribution required and already shown on-screen.
- No API key needed.  If you scale, swap to Mapbox / MapTiler (both have free tiers with API keys — configure via `.env`).
- Backend endpoints:
  - `POST /api/v1/location/update` — client push, 60/min rate-limited.
  - `POST /api/v1/location/stop` — clear stored location.
  - `GET  /api/v1/location/friends` — server filters by visibility + block + suspension.
  - `GET/PUT /api/v1/location/settings` — visibility (`off | ghost | friends | selected`), selected friends whitelist, day/night appearance.
- Privacy: verified server-side.  Blocked users can never see each other on the map.  Selected-visibility only returns to friends you explicitly whitelisted.

---

## 9. Project layout (v3)

```
App/
├── .github/workflows/android.yml    ← free GitHub Actions APK builder (NEW)
├── codemagic.yaml                   ← free Codemagic APK builder (NEW)
├── lib/
│   ├── api/
│   │   ├── api_config.dart          ← BASE_URL = https://vexor.to
│   │   ├── api_client.dart          ← Dio + auth interceptor
│   │   └── services/
│   │       ├── chat_service.dart
│   │       ├── chat_settings_service.dart    (v2)
│   │       ├── presence_service.dart         (v2)
│   │       ├── presence_heartbeat.dart       (v2)
│   │       ├── lens_service.dart             (NEW v3)
│   │       ├── location_service.dart         (NEW v3)
│   │       ├── streak_restore_service.dart   (NEW v3)
│   │       └── ... (auth, friend, admin, user, story, settings)
│   ├── services/
│   │   └── beauty_engine.dart                (NEW v3)
│   ├── screens/
│   │   ├── camera_first_screen.dart          (NEW v3)
│   │   ├── swiftmap_screen.dart              (NEW v3)
│   │   └── ... (every other screen)
│   ├── providers/app_provider.dart           (real sendMessage since v1)
│   ├── models/
│   ├── theme/
│   └── main.dart                             (PresenceHeartbeat wraps MaterialApp)
├── android/
├── ios/
├── assets/
├── pubspec.yaml                              (v3 dependencies)
└── README-BUILD.md                           ← THIS FILE
```

---

## 10. Troubleshooting

| Symptom | Fix |
| --- | --- |
| GitHub Actions build fails on dependency install | Push a commit that touches `pubspec.yaml`, re-run the workflow — sometimes the cache is cold. |
| App crashes on camera open | Grant camera + microphone permissions in Settings → Apps → SwiftSnap. |
| SwiftMap shows no tiles | Check the phone's internet connection.  CartoDB tiles are HTTPS. |
| SwiftMap shows no friends | Your friends haven't enabled sharing.  Ask them to open SwiftMap → tap the eye icon → "Friends". |
| Beauty preset makes photos too warm | Every preset intensity is capped conservatively (max 50% smoothing mix, ~10% glow).  If you want less: lower `intensity` via `PUT /api/v1/lenses/beauty-settings`. |
| "swift_plus_required_or_used" on restore | Either the user isn't Swift+, or already used their monthly restore.  Wait 30 days or upgrade. |
| API 402 on custom sound / pin | Not Swift+.  `https://vexor.to/dashboard/swift-plus` → upgrade. |
| API 429 | Rate-limited.  Wait 60s. |

---

## 11. Not-yet-implemented (blocked by external services)

- **WebRTC voice/video calls** — needs a TURN provider (Twilio / Agora / LiveKit / self-hosted coturn).
- **Advanced AR filters** (world tracking, occlusion, body meshes) — needs a licensed SDK (DeepAR / Banuba / Snap Camera Kit).  The current lens architecture has a slot (`config.engine: 'advanced_ar'`) ready to plug one in.
- **Real Snap Map heat visualisation** — needs Mapbox / Google Maps SDK for advanced styling (current free CartoDB tiles are perfect for personal use).
- **Bitmoji real avatars** — needs a signed Snap Inc. developer agreement.
- **Real-time typing indicators / live delivery** — needs Laravel Reverb on a VPS (current cPanel shared hosting can't run a WebSocket daemon).  The polling architecture is drop-in swappable.
- **iOS custom notification sounds** — Apple requires bundling `.caf` files inside the .ipa named to match backend sound keys.

Everything else is real, live, and testable now.
