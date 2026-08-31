import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/discover_item.dart';
import '../models/media.dart';
import '../models/story.dart';
import '../screens/achievements_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/avatar_studio_screen.dart';
import '../screens/camera_screen.dart';
import '../screens/creator_panel_screen.dart';
import '../screens/capture_preview_screen.dart';
import '../screens/chat_detail_screen.dart';
import '../screens/chats_screen.dart';
import '../screens/discover_detail_screen.dart';
import '../screens/discover_screen.dart';
import '../screens/edit_profile_screen.dart';
import '../screens/friends_screen.dart';
import '../screens/home_shell.dart';
import '../screens/map_screen.dart';
import '../screens/memories_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/reels_screen.dart';
import '../screens/search_screen.dart';
import '../screens/settings/about_screen.dart';
import '../screens/settings/blocked_users_screen.dart';
import '../screens/settings/permissions_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/settings_section_screen.dart';
import '../screens/story_viewer_screen.dart';
import '../screens/swift_plus_screen.dart';
import '../screens/user_profile_screen.dart';

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
        path: '/user/:id',
        builder: (context, state) => UserProfileScreen(
          userId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
        routes: [
          GoRoute(
            path: 'edit',
            builder: (context, state) => const EditProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/friends',
        builder: (context, state) => const FriendsScreen(),
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
