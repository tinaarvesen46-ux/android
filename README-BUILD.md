# Building SwiftSnap on Codemagic

## Toolchain (pinned in-repo, do not downgrade)
- AGP 8.11.1 · Kotlin 2.2.20 · Gradle 8.14.3 · JDK 17 · compileSdk 36 · NDK 28.2.13676358
- Core library desugaring enabled (`desugar_jdk_libs:2.1.4`) for `awesome_notifications`.

## What `codemagic.yaml` does
Runs `flutter pub get`, then builds **both**:
- `build/app/outputs/flutter-apk/app-release.apk` — install directly on any Android device (no Play Store needed).
- `build/app/outputs/bundle/release/app-release.aab` — upload to Google Play.

Both artifacts are attached to the Codemagic build page after every run.

## Signing
Out of the box, the release build falls back to Android's **debug signing key** (no
`key.properties` needed) so the pipeline works immediately. This is fine for sideloading
the APK to test devices, but Google Play requires a real upload key.

To sign with a real key:
1. Generate a keystore: `keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`
2. In Codemagic → your app → **Environment variables**, create a group named `android_signing` with:
   - `CM_KEYSTORE` — the keystore file, base64-encoded (`base64 -i upload-keystore.jks`)
   - `CM_KEYSTORE_PASSWORD`, `CM_KEY_ALIAS`, `CM_KEY_PASSWORD`
3. Re-run the build — `codemagic.yaml` decodes the keystore and writes `android/key.properties` automatically, and the Gradle config picks it up instead of the debug fallback.

## Backend
The app talks to the real Laravel backend at `https://vexor.to/api/v1` (see `lib/services/api_service.dart`). No `.env` file or extra secrets are needed to build.
