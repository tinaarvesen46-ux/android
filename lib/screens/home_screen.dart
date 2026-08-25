import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../theme/theme.dart';
import '../providers/app_provider.dart';
import '../models/user_model.dart';
import 'chats_screen.dart';
import 'stories_screen.dart';
import 'camera_screen.dart';
import 'discover_screen.dart';
import 'profile_screen.dart';
import 'admin/admin_panel_screen.dart';
import 'admin/support_dashboard_screen.dart';
import 'admin/moderator_dashboard_screen.dart';
import 'creator_dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _fabAnimationController;
  late final Animation<double> _fabScaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fabScaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeInOut),
    );
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }
  
  bool _isStaff(AppProvider provider) {
    final role = provider.currentUser?.staffRole;
    return role != null && role != StaffRole.none;
  }

  bool _isCreator(AppProvider provider) {
    return provider.currentUser?.accountStatus == AccountStatus.creator;
  }

  bool _hasSpecialTab(AppProvider provider) {
    return _isStaff(provider) || _isCreator(provider);
  }

  Widget _buildSpecialTabScreen(AppProvider provider) {
    final role = provider.currentUser?.staffRole;
    if (role == StaffRole.administrator) return const AdminPanelScreen();
    if (role == StaffRole.moderator) return const ModeratorDashboardScreen();
    if (role == StaffRole.support) return const SupportDashboardScreen();
    if (_isCreator(provider)) return const CreatorDashboardScreen();
    return const AdminPanelScreen();
  }

  IconData _specialTabIcon(AppProvider provider) {
    final role = provider.currentUser?.staffRole;
    if (role == StaffRole.administrator) return Icons.admin_panel_settings_rounded;
    if (role == StaffRole.moderator) return Icons.shield_rounded;
    if (role == StaffRole.support) return Icons.headset_mic_rounded;
    if (_isCreator(provider)) return Icons.stars_rounded;
    return Icons.admin_panel_settings_rounded;
  }

  String _specialTabLabel(AppProvider provider) {
    final role = provider.currentUser?.staffRole;
    if (role == StaffRole.administrator) return 'Admin';
    if (role == StaffRole.moderator) return 'Mod';
    if (role == StaffRole.support) return 'Support';
    if (_isCreator(provider)) return 'Creator';
    return 'Admin';
  }

  LinearGradient _specialTabGradient(AppProvider provider) {
    final role = provider.currentUser?.staffRole;
    if (role == StaffRole.moderator) {
      return const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)]);
    }
    if (role == StaffRole.support) {
      return const LinearGradient(colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)]);
    }
    if (_isCreator(provider)) {
      return const LinearGradient(colors: [Color(0xFFFBBF24), Color(0xFFF97316)]);
    }
    return const LinearGradient(colors: [Color(0xFFEC4899), Color(0xFF8B5CF6)]);
  }

  Color _specialTabIdleColor(AppProvider provider) {
    final role = provider.currentUser?.staffRole;
    if (role == StaffRole.support) return const Color(0xFF06B6D4);
    if (_isCreator(provider)) return const Color(0xFFFBBF24);
    return SwiftSnapTheme.primaryPink;
  }

  void _onNavTap(int index, AppProvider provider) {
    if (index == 2) {
      _openCamera();
      return;
    }
    // Nav layout (no special tab): 0=Chats, 1=Stories, 2=Camera(FAB), 3=Discover, 4=Profile
    // Nav layout (with special tab): 0=Chats, 1=Stories, 2=Camera(FAB), 3=Discover, 4=Profile, 5=Dashboard
    // Page indices: 0=Chats, 1=Stories, 2=Discover, 3=Profile, [4=Dashboard if special]
    int actualIndex;
    if (_hasSpecialTab(provider) && index == 5) {
      actualIndex = 4;
    } else {
      actualIndex = index > 2 ? index - 1 : index;
    }
    provider.setCurrentIndex(actualIndex);
    _pageController.animateToPage(
      actualIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
    HapticFeedback.lightImpact();
  }
  
  void _openCamera() {
    HapticFeedback.mediumImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const CameraScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final hasSpecial = _hasSpecialTab(provider);
        return Scaffold(
          extendBody: true,
          body: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              const ChatsScreen(),
              const StoriesScreen(),
              const DiscoverScreen(),
              const ProfileScreen(),
              if (hasSpecial) _buildSpecialTabScreen(provider),
            ],
          ),
          bottomNavigationBar: _buildBottomNavBar(provider),
          floatingActionButton: _buildCameraFAB(),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        );
      },
    );
  }
  
  Widget _buildBottomNavBar(AppProvider provider) {
    final hasSpecial = _hasSpecialTab(provider);
    // Page indices: 0=Chats,1=Stories,2=Discover,3=Profile,[4=Dashboard]
    // Nav indices:  0=Chats,1=Stories,2=Camera,3=Discover,4=Profile,[5=Dashboard]
    final navIndex = provider.currentIndex >= 2
        ? provider.currentIndex + 1
        : provider.currentIndex;

    return Container(
      decoration: BoxDecoration(
        color: SwiftSnapTheme.backgroundCard.withOpacity(0.9),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.08),
            width: 1,
          ),
        ),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    icon: Icons.chat_bubble_rounded,
                    label: 'Chats',
                    index: 0,
                    navIndex: navIndex,
                    provider: provider,
                    badgeCount: provider.chats
                        .where((c) => c.unreadCount > 0)
                        .fold(0, (sum, c) => sum + c.unreadCount),
                  ),
                  _buildNavItem(
                    icon: Icons.amp_stories_rounded,
                    label: 'Stories',
                    index: 1,
                    navIndex: navIndex,
                    provider: provider,
                    hasNewStory: provider.stories.any((s) => s.hasUnviewed),
                  ),
                  const SizedBox(width: 72),
                  _buildNavItem(
                    icon: Icons.explore_rounded,
                    label: 'Discover',
                    index: 3,
                    navIndex: navIndex,
                    provider: provider,
                  ),
                  _buildNavItem(
                    icon: Icons.person_rounded,
                    label: 'Profile',
                    index: 4,
                    navIndex: navIndex,
                    provider: provider,
                  ),
                  if (hasSpecial)
                    _buildNavItem(
                      icon: _specialTabIcon(provider),
                      label: _specialTabLabel(provider),
                      index: 5,
                      navIndex: navIndex,
                      provider: provider,
                      isAdminTab: true,
                      specialGradient: _specialTabGradient(provider),
                      specialIdleColor: _specialTabIdleColor(provider),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required int navIndex,
    required AppProvider provider,
    int badgeCount = 0,
    bool hasNewStory = false,
    bool isAdminTab = false,
    LinearGradient? specialGradient,
    Color? specialIdleColor,
  }) {
    final isSelected = navIndex == index;
    final activeGradient = isAdminTab
        ? (specialGradient ?? const LinearGradient(colors: [Color(0xFFEC4899), Color(0xFF8B5CF6)]))
        : SwiftSnapTheme.primaryGradient;
    final idleColor = isAdminTab
        ? (specialIdleColor ?? SwiftSnapTheme.primaryPink).withOpacity(0.5)
        : SwiftSnapTheme.textMuted;
    final selectedTextColor = isAdminTab
        ? (specialIdleColor ?? SwiftSnapTheme.primaryPink)
        : SwiftSnapTheme.textPrimary;

    return GestureDetector(
      onTap: () => _onNavTap(index, provider),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: isSelected ? activeGradient : null,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? Colors.white : idleColor,
                    size: 24,
                  ),
                ),
                if (badgeCount > 0)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        gradient: SwiftSnapTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: SwiftSnapTheme.glowShadow(
                          SwiftSnapTheme.primaryPink,
                          intensity: 0.4,
                        ),
                      ),
                      child: Text(
                        badgeCount > 99 ? '99+' : badgeCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                if (hasNewStory && badgeCount == 0)
                  Positioned(
                    right: 2,
                    top: 2,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        gradient: SwiftSnapTheme.storyGradient,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: SwiftSnapTheme.backgroundCard,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: isSelected
                    ? selectedTextColor
                    : (isAdminTab
                        ? idleColor
                        : SwiftSnapTheme.textMuted),
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCameraFAB() {
    return GestureDetector(
      onTapDown: (_) => _fabAnimationController.forward(),
      onTapUp: (_) {
        _fabAnimationController.reverse();
        _openCamera();
      },
      onTapCancel: () => _fabAnimationController.reverse(),
      child: AnimatedBuilder(
        animation: _fabScaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _fabScaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: SwiftSnapTheme.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: SwiftSnapTheme.primaryPurple.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: SwiftSnapTheme.primaryPink.withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.camera_alt_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}
