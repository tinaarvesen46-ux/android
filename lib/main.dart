import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'theme/theme.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'providers/app_provider.dart';
import 'api/services/presence_heartbeat.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0A0A0F),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const SwiftSnapApp());
}

class SwiftSnapApp extends StatelessWidget {
  const SwiftSnapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: PresenceHeartbeat(
        enabled: true,
        child: MaterialApp(
          title: 'SwiftSnap',
          debugShowCheckedModeBanner: false,
          theme: SwiftSnapTheme.darkTheme,
          home: const AuthGate(),
        ),
      ),
    );
  }
}

/// Listens to AppProvider.isLoggedIn and routes to Login or Home accordingly.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<AppProvider>().isLoggedIn;
    return isLoggedIn ? const HomeScreen() : const LoginScreen();
  }
}