import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/discover_item.dart';
import '../models/media.dart';
import '../models/story.dart';
import '../providers/auth_provider.dart';
import '../providers/social_provider.dart';
import '../screens/achievements_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/auth/two_factor_login_screen.dart';
import '../screens/avatar_studio_screen.dart';
import '../screens/profile_header_editor_screen.dart';
import '../screens/camera_screen.dart';
import '../screens/creator_panel_screen.dart';
import '../screens/capture_preview_screen.dart';
import '../screens/chat_detail_screen.dart';
import '../screens/chats_screen.dart';
import '../screens/discover_detail_screen.dart';
import '../screens/discover_screen.dart';
import '../screens/edit_profile_screen.dart';
import '../screens/find_friends_screen.dart';
import '../screens/friends_screen.dart';
import '../screens/home_shell.dart';
import '../screens/map_screen.dart';
import '../screens/memories_screen.dart';
import '../screens/my_ai_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/reels_screen.dart';
import '../screens/search_screen.dart';
import '../screens/settings/about_screen.dart';
import '../screens/settings/account_status_screen.dart';
import '../screens/settings/blocked_users_screen.dart';
import '../screens/settings/delete_account_screen.dart';
import '../screens/settings/my_data_screen.dart';
import '../screens/settings/my_reports_screen.dart';
import '../screens/settings/notification_settings_screen.dart';
import '../screens/settings/password_screen.dart';
import '../screens/settings/permissions_screen.dart';
import '../screens/settings/phone_number_screen.dart';
import '../screens/settings/privacy_controls_screen.dart';
import '../screens/settings/app_language_screen.dart';
import '../screens/settings/sessions_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/settings_section_screen.dart';
import '../screens/settings/two_factor_screen.dart';
import '../screens/story_viewer_screen.dart';
import '../screens/swift_plus_screen.dart';
import '../screens/user_profile_screen.dart';
import '../screens/public/public_profile_create_screen.dart';
import '../screens/public/public_profile_edit_screen.dart';
import '../screens/public/followers_screen.dart';
import '../screens/public/following_screen.dart';

/// Navigation map.
///
/// Primary shell tabs: /map, /chats, /camera, /discover, /reels.
/// Profile is intentionally NOT a tab — it is reached contextually from chat,
/// map, discover, reels, search, friends, notifications and user cards.
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/2fa-login',
        builder: (context, state) => const TwoFactorLoginScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            HomeShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/map',
              builder: (context, state) => const MapScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/chats',
              builder: (context, state) => const ChatsScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/camera',
              builder: (context, state) => const CameraScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/discover',
              builder: (context, state) => const DiscoverScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/reels',
              builder: (context, state) => const ReelsScreen(),
            ),
          ]),
        ],
      ),
      GoRoute(
        path: '/capture',
        builder: (context, state) =>
            CapturePreviewScreen(draft: state.extra as CaptureDraft),
      ),
      GoRoute(
        path: '/story',
        builder: (context, state) =>
            StoryViewerScreen(story: state.extra as Story),
      ),
      GoRoute(
        path: '/article/:id',
        builder: (context, state) =>
            DiscoverDetailScreen(item: state.extra as DiscoverItem),
      ),
      GoRoute(
        path: '/chat/:id',
        builder: (context, state) => ChatDetailScreen(
          conversationId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/my-ai',
        builder: (context, state) => const MyAiScreen(),
      ),
      GoRoute(
        path: '/user/:id',
        builder: (context, state) => UserProfileScreen(
          userId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/user/:id/followers',
        builder: (context, state) => FollowersScreen(userId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/user/:id/following',
        builder: (context, state) => FollowingScreen(userId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/profile/public/create',
        builder: (context, state) => const PublicProfileCreateScreen(),
      ),
      GoRoute(
        path: '/profile/public/edit',
        builder: (context, state) => const PublicProfileEditScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
        routes: [
          GoRoute(
            path: 'edit',
            builder: (context, state) => const EditProfileScreen(),
          ),
          GoRoute(
            path: 'header',
            builder: (context, state) => const ProfileHeaderEditorScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/friends',
        builder: (context, state) => const FriendsScreen(),
      ),
      GoRoute(
        path: '/find-friends',
        builder: (context, state) => const FindFriendsScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/memories',
        builder: (context, state) => const MemoriesScreen(),
      ),
      GoRoute(
        path: '/achievements',
        builder: (context, state) => const AchievementsScreen(),
      ),
      GoRoute(
        path: '/swiftplus',
        builder: (context, state) => const SwiftPlusScreen(),
      ),
      GoRoute(
        path: '/avatar',
        builder: (context, state) => const AvatarStudioScreen(),
      ),
      GoRoute(
        path: '/creator',
        builder: (context, state) => const CreatorPanelScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: ':section',
            builder: (context, state) => SettingsSectionScreen(
              sectionId: state.pathParameters['section']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/settings-blocked',
        builder: (context, state) => const BlockedUsersScreen(),
      ),
      GoRoute(
        path: '/settings-permissions',
        builder: (context, state) => const PermissionsScreen(),
      ),
      GoRoute(
        path: '/settings-about',
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: '/settings-password',
        builder: (context, state) => const PasswordScreen(),
      ),
      GoRoute(
        path: '/settings-2fa',
        builder: (context, state) => TwoFactorScreen(
          initiallyEnabled:
              context.read<AuthProvider>().currentUser?.twoFactorEnabled ??
                  false,
        ),
      ),
      GoRoute(
        path: '/settings-sessions',
        builder: (context, state) => const SessionsScreen(),
      ),
      GoRoute(
        path: '/settings-privacy',
        builder: (context, state) => const PrivacyControlsScreen(),
      ),
      GoRoute(
        path: '/settings-notifications',
        builder: (context, state) => const NotificationSettingsScreen(),
      ),
      GoRoute(
        path: '/settings-language',
        builder: (context, state) => const AppLanguageScreen(),
      ),
      GoRoute(
        path: '/settings-account-status',
        builder: (context, state) => const AccountStatusScreen(),
      ),
      GoRoute(
        path: '/settings-delete-account',
        builder: (context, state) => const DeleteAccountScreen(),
      ),
      GoRoute(
        path: '/settings-my-data',
        builder: (context, state) => const MyDataScreen(),
      ),
      GoRoute(
        path: '/settings-my-reports',
        builder: (context, state) => const MyReportsScreen(),
      ),
      GoRoute(
        path: '/settings-phone',
        builder: (context, state) => const PhoneNumberScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'This screen could not be opened.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
  );
}
