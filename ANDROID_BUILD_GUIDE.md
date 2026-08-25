# SwiftSnap — Android Build Guide (No Local Setup Needed)

You have three **free** options to build the Android APK from this source without installing Android Studio locally.

---

## Option 1 — Codemagic (RECOMMENDED, Free tier: 500 min/month)

**Easiest, fastest, cleanest.**

1. Push this `App/` folder to a GitHub repo (make one at github.com if you don't have it)
2. Go to **https://codemagic.io/signup** → sign in with GitHub
3. **Add application** → pick your repo
4. Select **Flutter App** → **Android** target
5. First build starts automatically. Download `.apk` from the artifacts tab in ~10 min

Free tier: 500 build-minutes/month = ~40 Android builds. More than enough.

---

## Option 2 — GitHub Actions (100% Free, unlimited)

1. Push to a GitHub repo (public repo = free unlimited, private = 2000 min/month)
2. This project already includes `.github/workflows/android-build.yml` (see below — copy it if missing)
3. Push to main branch → build triggers → APK appears in **Actions → Artifacts**

The workflow file (already added to this zip):

```yaml
# .github/workflows/android-build.yml
name: Android APK Build
on:
  push:
    branches: [ main, master ]
  workflow_dispatch:
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with:
          distribution: 'zulu'
          java-version: '17'
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
          channel: 'stable'
      - run: flutter pub get
      - run: flutter build apk --release
      - uses: actions/upload-artifact@v4
        with:
          name: SwiftSnap-release.apk
          path: build/app/outputs/flutter-apk/app-release.apk
```

Download the APK from GitHub → your repo → **Actions** tab → latest run → **Artifacts**.

---

## Option 3 — Appetize.io (test WITHOUT installing on your phone)

1. Build an APK via Option 1 or 2
2. Go to **https://appetize.io** → upload APK → get a shareable link
3. Test on a virtual Android device in your browser

Free tier: 100 minutes/month.

---

## Once you have the APK

**Install on your Android phone (side-load):**
1. Copy the `.apk` file to your phone (USB, Google Drive, email attachment)
2. On the phone: **Settings → Security → Install unknown apps** → allow your file manager
3. Tap the APK → Install
4. Open the app → point to `https://vexor.to` should already be baked in

---

## First-time troubleshooting

**"App won't install" error:**
- Older Android may need `--target-platform=android-arm64` — edit the workflow's build line to `flutter build apk --release --target-platform android-arm64`

**"Network error" on register/login:**
- Confirm the API URL: open `lib/api/api_config.dart` — line should read `BASE_URL = 'https://vexor.to'`. It's already set.

**"OTP never arrives":**
- Check spam folder. SMTP is live on the backend but sometimes carrier delays 1–2 minutes.
- OTP codes are also visible to admin via `mysql> SELECT code FROM otp_verifications ORDER BY id DESC LIMIT 1;` from cPanel Terminal.

---

## What's baked in

- ✅ BASE_URL: `https://vexor.to`
- ✅ API_VERSION: `v1`
- ✅ App name: SwiftSnap (all Dart, Kotlin, iOS metadata)
- ✅ Package name: `com.darvin.swiftsnap`
- ✅ Auth: register/login/verify-email/forgot-password/reset-password/logout
- ✅ 90+ endpoints wired
- ✅ Stripe Swift+ subscription checkout (test mode)
