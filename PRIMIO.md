# VibeChat

## Overview
VibeChat is a premium social messaging platform (Snapchat competitor) owned by Nexa-Group. It features ephemeral stories, real-time chat, a creator economy, staff role-based dashboards, and a full admin panel — all in a dark-mode Flutter app with purple gradient glassmorphism design.

## Tech Stack & Key Decisions
- **State:** `Provider` + `AppProvider` as single hub — all mock data lives in `_initializeMockData()`; replace with real API calls via `lib/api/services/`
- **Auth routing:** `AuthGate` widget in `main.dart` watches `AppProvider.isLoggedIn`; login calls `provider.login(user)`, logout calls `provider.logout()` — no Navigator pushes needed
- **Navigation:** Named `Navigator.push` throughout (no GoRouter); camera opens as modal overlay via `_openCamera()`, not a PageView page
- **API layer:** Dio with Bearer token interceptor in `lib/api/api_client.dart`; all endpoints defined in `lib/api/api_config.dart`; 6 service classes + `admin_service.dart` ready for backend wiring
- **Theme:** `VibeChatTheme` class in `lib/theme/theme.dart` — NOT `AppTheme`; all screens must import this
- **Role-based 5th tab:** Home screen detects `StaffRole` (administrator/moderator/support) and `AccountStatus.creator` to show the correct dashboard as the 5th nav tab
- **OAuth/SMTP config:** `lib/config/oauth_config.dart` holds all social sign-in key constants; `lib/config/smtp_config.dart` holds email display config — both are documentation + placeholder files until keys are filled

## Architecture
- **Screens:** 60+ screens across `lib/screens/` and `lib/screens/admin/`
- **Role dashboards:** AdminPanelScreen (administrator), ModeratorDashboardScreen (moderator), SupportDashboardScreen (support), CreatorDashboardScreen (creator)
- **Admin user edit:** `EditUserScreen` in `lib/screens/admin/edit_user_screen.dart` — full edit of all user fields; opened from UserDetailScreen's "Edit User Profile" button; calls `AppProvider.adminUpdateUser()` on save
- **Data flow:** UI reads `AppProvider` → provider calls mock data or API services → services call `ApiClient` → Laravel backend
- **Documents folder:** `/documents/` contains 9 files (SQL schema, Laravel API docs, API integration guide, backend setup guide v4.0, deployment checklist v4.0, email templates JSON, database schema overview, React website guide, Integration-Keys-Guide.txt)
- **Database:** 48 MySQL tables documented in `documents/Database-mysql.sql` v3.0

## Conventions
- All theme colors/styles via `VibeChatTheme.*` — never `AppTheme.*` (doesn't exist in this project)
- New screens navigate via `Navigator.push(context, MaterialPageRoute(...))` with `SlideTransition` 300ms
- Admin screens live in `lib/screens/admin/`; import `admin_models.dart` for all admin data types
- `StaffRole` and `AccountStatus` enums defined in `lib/models/user_model.dart`
- `TicketStatus`, `TicketPriority`, `TicketCategory`, `ReportReason`, `ReportStatus`, `ContentType` enums defined in `lib/models/admin_models.dart`

## Key Patterns & Gotchas
- **Camera tab is NOT in PageView** — it is nav index 2 which calls `_openCamera()` (modal push), not a page. PageView has 4 pages (Chats=0, Stories=1, Discover=2, Profile=3, Dashboard=4 if special tab)
- **Duplicate getter bug fixed:** `moderator_dashboard_screen.dart` had a duplicate `actionsToday` public getter shadowing the private `_actionsToday` — removed in v3.0 audit
- **`api_usage_examples.dart`** is a documentation/demo file with intentional unused variables — not a production file, warnings are expected and harmless
- **Mock login:** `_handleLogin()` in `login_screen.dart` always logs in as `StaffRole.administrator` + `AccountStatus.creator` so all dashboards are immediately visible during development
- **Google/Apple sign-in:** Buttons are present in `register_screen.dart` but show a SnackBar until keys are filled in `lib/config/oauth_config.dart` and packages (`google_sign_in`, `sign_in_with_apple`) are added to pubspec.yaml
- **ToS and Privacy Policy links in register** use `WidgetSpan` inside `RichText` — this is intentional since `GestureDetector` cannot be used directly as a `TextSpan` recognizer with underline styling

## Design System
- Dark background: `VibeChatTheme.backgroundDark` (#0A0A0F), card: `VibeChatTheme.backgroundCard`
- Primary gradient: purple `#8B5CF6` → pink `#EC4899`; accent cyan: `#06B6D4`
- Glassmorphism: `BackdropFilter(ImageFilter.blur)` + `Colors.white.withOpacity(0.05-0.1)` containers
- Role accent colors: Admin=pink→purple, Moderator=purple→pink, Support=cyan→blue, Creator=yellow→orange
- All screens use `CustomScrollView` + `SliverAppBar` with `expandedHeight: 160` for consistent header pattern
