# SwiftSnap Mobile App — Backend Migration Notes

## What changed
1. **BASE_URL** updated from `https://api.vibechat.one` → `https://vexor.to`
2. **App name** rebranded VibeChat → SwiftSnap in all Dart, Kotlin, Info.plist, AndroidManifest, and pubspec files
3. **WebSocket URL** updated from `wss://api.vibechat.one/ws` → `wss://vexor.to/ws` (WS not yet implemented server-side)

## API endpoints available on the backend (as of this build)
- ✅ Auth: `/api/v1/auth/{login,register,verify-email,forgot-password,reset-password,logout,refresh,resend-verification}`
- ✅ Users: `/api/v1/users/{me,me/avatar,me/cover,me/settings,blocked,{id}/block,{id}/unblock,{id}}`
- ✅ Friends: `/api/v1/friends`, `/api/v1/friend-requests/{send,accept,reject,cancel}`
- ✅ Chats: `/api/v1/chats`, `/api/v1/chats/{id}/{messages,read}`, `/api/v1/messages/{id}` (edit/delete/react)
- ✅ Stories: `/api/v1/stories`, `/api/v1/stories/{id}/{view,viewers}`
- ✅ Search: `/api/v1/search/{users,messages,discover}`
- ✅ Notifications: `/api/v1/notifications`, `/api/v1/notifications/{settings,read-all,{id}/read}`
- ✅ Settings: `/api/v1/settings/{privacy,security,notifications,appearance,password}` + 2FA
- ✅ Media: `/api/v1/media/{upload,{id}}` (stored on cPanel local disk under `~/swiftsnap/storage/app/public/`)
- ✅ Reports: `/api/v1/reports/{user,content,me}`
- ✅ Subscription: `/api/v1/subscription/{plans,subscribe,cancel,status}`
- ✅ Security: `/api/v1/security/{login-history,sessions,{id},suspicious-activity,export-data,delete-account}` + 2FA
- ✅ Admin: `/api/v1/admin/{users,tickets,reports,analytics,campaigns,email-templates,settings,audit-logs,dashboard}` (admin role only)

## Auth header
Bearer token from `POST /api/v1/auth/login` → `Authorization: Bearer <access_token>`

## Known limitations
- Real-time messaging is REST-only (no WebSocket server on shared hosting)
- OAuth (Google/Apple) endpoints NOT wired — configure `oauth_config.dart` when ready
- Push tokens accepted but no server-side FCM/APNS dispatch yet
- Subscription is intent-recorded only (no real payment processor wired)
- 2FA endpoints return placeholder responses (real TOTP verification is a TODO)

## To build the mobile app
```bash
cd App
flutter pub get
flutter build apk   # Android
flutter build ios   # iOS (requires macOS + Xcode)
```
