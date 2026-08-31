import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/common/snap_bottom_nav.dart';

/// Persistent application shell hosting the five primary destinations.
/// Branch state is preserved by [StatefulNavigationShell].
class HomeShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const HomeShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: SnapBottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}
