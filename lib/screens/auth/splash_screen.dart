import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../providers/auth_provider.dart';
import '../../theme/theme.dart';

/// Decides where the app starts: the camera when a session token exists,
/// otherwise the login screen.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolve());
  }

  Future<void> _resolve() async {
    final authenticated =
        await context.read<AuthService>().isAuthenticated();
    if (authenticated) {
      await context.read<AuthProvider>().hydrateFromExistingSession();
    }
    if (!mounted) return;
    context.go(authenticated ? '/camera' : '/login');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              child: Image.asset(
                'assets/icons/app_icon.png',
                width: AppTheme.avatarXl,
                height: AppTheme.avatarXl,
              ),
            ),
            const SizedBox(height: AppTheme.spacingXl),
            Text('SwiftSnap', style: theme.textTheme.headlineMedium),
            const SizedBox(height: AppTheme.spacingXl),
            const SizedBox(
              width: AppTheme.iconMd,
              height: AppTheme.iconMd,
              child:
                  CircularProgressIndicator(strokeWidth: AppTheme.borderThick),
            ),
          ],
        ),
      ),
    );
  }
}
