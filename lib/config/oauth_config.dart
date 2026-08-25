/// ================================================================
/// SwiftSnap — OAuth & Social Sign-In Configuration
/// ================================================================
///
/// HOW TO CONFIGURE:
///
/// ─── GOOGLE SIGN-IN ──────────────────────────────────────────────
/// 1. Go to: https://console.cloud.google.com/
/// 2. Create a project (or select SwiftSnap project)
/// 3. Enable "Google Sign-In API" under APIs & Services
/// 4. Go to Credentials → Create Credentials → OAuth 2.0 Client IDs
///
///    Android Client:
///      - Application type: Android
///      - Package name: com.darvin.swiftsnap
///      - SHA-1 fingerprint:
///          Debug:   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
///          Release: keytool -list -v -keystore your-release-keystore.jks -alias your-key-alias
///
///    iOS Client:
///      - Application type: iOS
///      - Bundle ID: com.darvin.swiftsnap
///
///    Web Client (also needed for Flutter Web + token exchange):
///      - Application type: Web application
///      - Authorized redirect URIs: https://swiftsnap.app/auth/google/callback
///
/// 5. Download the google-services.json → place in android/app/
/// 6. Download the GoogleService-Info.plist → place in ios/Runner/
/// 7. Paste the client IDs below.
///
/// ─── APPLE SIGN-IN ────────────────────────────────────────────────
/// 1. Go to: https://developer.apple.com/account/
/// 2. Go to Certificates, IDs & Profiles → Identifiers
/// 3. Select your App ID (com.darvin.swiftsnap)
/// 4. Enable "Sign In with Apple" capability
/// 5. Create a Service ID (for web/Android):
///    - Identifier: com.darvin.swiftsnap.siwa
///    - Enable Sign In with Apple
///    - Configure domains & return URL: https://swiftsnap.app/auth/apple/callback
/// 6. Create a Key:
///    - Enable "Sign In with Apple"
///    - Download the .p8 private key file (save it — cannot re-download!)
///    - Note the Key ID shown after creation
///
/// ─── FLUTTER PACKAGES NEEDED ──────────────────────────────────────
/// Add to pubspec.yaml when you're ready to implement:
///
///   google_sign_in: ^6.2.1          # Google OAuth
///   sign_in_with_apple: ^6.1.4      # Apple Sign-In
///   flutter_facebook_auth: ^7.0.1   # Facebook (optional)
///
/// AndroidManifest.xml — add inside <application> for Google:
///   <meta-data
///     android:name="com.google.android.gms.version"
///     android:value="@integer/google_play_services_version" />
///
/// ios/Runner/Info.plist — add for Apple Sign-In (iOS 13+):
///   (Sign In with Apple entitlement is added automatically by Xcode
///    when you enable the capability — no plist key needed)
///
/// ios/Runner/Runner.entitlements — add:
///   <key>com.apple.developer.applesignin</key>
///   <array><string>Default</string></array>
///
/// ─────────────────────────────────────────────────────────────────

class OAuthConfig {
  OAuthConfig._(); // prevent instantiation

  // ── GOOGLE ──────────────────────────────────────────────────────
  /// Web/Android client ID from Google Cloud Console.
  /// Used by google_sign_in on Android and as the serverClientId on iOS.
  /// Format: XXXXXXXXXX-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.apps.googleusercontent.com
  static const String googleWebClientId =
      'YOUR_GOOGLE_WEB_CLIENT_ID.apps.googleusercontent.com';

  /// iOS client ID from GoogleService-Info.plist (CLIENT_ID field).
  static const String googleIosClientId =
      'YOUR_GOOGLE_IOS_CLIENT_ID.apps.googleusercontent.com';

  // ── APPLE ────────────────────────────────────────────────────────
  /// Service ID used for Apple Sign-In on Android / web.
  /// This is the "Services ID" identifier you created in Apple Developer portal.
  static const String appleServiceId = 'com.darvin.swiftsnap.siwa';

  /// Your backend URL that handles the Apple Sign-In callback redirect.
  static const String appleRedirectUri =
      'https://swiftsnap.app/auth/apple/callback';

  /// Apple Team ID — 10-character ID visible in Apple Developer portal top-right.
  static const String appleTeamId = 'YOUR_APPLE_TEAM_ID';

  /// Apple Key ID — shown when you created the .p8 key.
  static const String appleKeyId = 'YOUR_APPLE_KEY_ID';

  // ── FACEBOOK (optional) ──────────────────────────────────────────
  /// From: https://developers.facebook.com/ → Your App → Settings → Basic
  static const String facebookAppId = 'YOUR_FACEBOOK_APP_ID';
  static const String facebookClientToken = 'YOUR_FACEBOOK_CLIENT_TOKEN';

  // ── BACKEND OAUTH ENDPOINTS ──────────────────────────────────────
  // After Google/Apple returns a credential, send it to your backend
  // for verification and JWT token exchange:
  //
  //   POST /api/v1/auth/google   { id_token: "..." }
  //   POST /api/v1/auth/apple    { code: "...", id_token: "..." }
  //
  // Backend verifies the token with Google/Apple, creates or finds the
  // user in your database, and returns your own access_token.
}
