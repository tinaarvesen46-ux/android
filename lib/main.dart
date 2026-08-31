import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'providers/account_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/chats_provider.dart';
import 'providers/feed_provider.dart';
import 'providers/map_provider.dart';
import 'providers/memories_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/social_provider.dart';
import 'repositories/account_repository.dart';
import 'repositories/chat_repository.dart';
import 'repositories/feed_repository.dart';
import 'repositories/map_repository.dart';
import 'repositories/media_repository.dart';
import 'repositories/social_repository.dart';
import 'router/app_router.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/realtime_service.dart';
import 'services/settings_service.dart';
import 'theme/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  final settingsService = await SettingsService.create();
  runApp(SwiftSnapApp(settingsService: settingsService));
}

class SwiftSnapApp extends StatelessWidget {
  final SettingsService settingsService;

  const SwiftSnapApp({super.key, required this.settingsService});

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();
    final realtimeService = RealtimeService(api: apiService);

    return MultiProvider(
      providers: [
        Provider<ApiService>.value(value: apiService),
        Provider<RealtimeService>.value(value: realtimeService),
        Provider<AuthService>(create: (_) => AuthService(api: apiService)),
        Provider<SocialRepository>(
          create: (_) => SocialRepository(api: apiService),
        ),
        Provider<ChatRepository>(
          create: (_) => ChatRepository(api: apiService),
        ),
        Provider<FeedRepository>(
          create: (_) => FeedRepository(api: apiService),
        ),
        Provider<MediaRepository>(
          create: (_) => MediaRepository(api: apiService),
        ),
        Provider<MapRepository>(create: (_) => MapRepository(api: apiService)),
        Provider<AccountRepository>(
          create: (_) => AccountRepository(api: apiService),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (ctx) => AuthProvider(
            authService: ctx.read<AuthService>(),
            realtimeService: ctx.read<RealtimeService>(),
            socialRepository: ctx.read<SocialRepository>(),
          ),
        ),
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) => SettingsProvider(service: settingsService),
        ),
        ChangeNotifierProvider<SocialProvider>(
          create: (ctx) =>
              SocialProvider(socialRepository: ctx.read<SocialRepository>()),
        ),
        ChangeNotifierProvider<ChatsProvider>(
          create: (ctx) => ChatsProvider(
            chatRepository: ctx.read<ChatRepository>(),
            feedRepository: ctx.read<FeedRepository>(),
            realtimeService: ctx.read<RealtimeService>(),
          ),
        ),
        ChangeNotifierProvider<FeedProvider>(
          create: (ctx) =>
              FeedProvider(feedRepository: ctx.read<FeedRepository>()),
        ),
        ChangeNotifierProvider<MapProvider>(
          create: (ctx) => MapProvider(mapRepository: ctx.read<MapRepository>()),
        ),
        ChangeNotifierProvider<MemoriesProvider>(
          create: (ctx) =>
              MemoriesProvider(mediaRepository: ctx.read<MediaRepository>()),
        ),
        ChangeNotifierProvider<AccountProvider>(
          create: (ctx) =>
              AccountProvider(accountRepository: ctx.read<AccountRepository>()),
        ),
      ],
      child: MaterialApp.router(
        title: 'SwiftSnap',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}