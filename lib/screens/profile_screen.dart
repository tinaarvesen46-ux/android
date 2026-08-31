import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../models/user.dart';
import '../providers/social_provider.dart';
import '../theme/theme.dart';
import '../widgets/common/app_top_bar.dart';
import '../widgets/common/async_state_view.dart';
import '../widgets/common/snap_avatar.dart';
import '../widgets/common/snap_icon_button.dart';
import '../widgets/common/role_badge.dart';
import '../widgets/profile/profile_action_row.dart';
import '../widgets/profile/profile_stat.dart';

/// Profile hub. Reachable contextually from Chat, Map, Discover, Reels,
/// notifications and user cards — it is not a primary navigation tab.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<SocialProvider>().loadMe();
    });
  }

  String _profileUrl(User user) => 'https://vexor.to/u/${user.username}';

  void _shareProfile(User user) {
    SharePlus.instance.share(
      ShareParams(
        text: 'Add me on SwiftSnap: ${_profileUrl(user)}',
        subject: 'My SwiftSnap profile',
      ),
    );
  }

  void _showQrCode(User user) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingXl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('@${user.username}', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppTheme.spacingLg),
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingLg),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                ),
                child: QrImageView(data: _profileUrl(user), size: 220),
              ),
              const SizedBox(height: AppTheme.spacingLg),
              Text(
                'Scan to open ${user.displayName}\'s SwiftSnap profile',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final social = context.watch<SocialProvider>();

    return Scaffold(
      body: Column(
        children: [
          AppTopBar(
            showBack: true,
            title: 'Profile',
            actions: [
              if (social.me.data != null)
                SnapIconButton(
                  icon: Icons.qr_code_rounded,
                  onTap: () => _showQrCode(social.me.data!),
                ),
              SnapIconButton(
                icon: Icons.settings_outlined,
                onTap: () => context.push('/settings'),
              ),
            ],
          ),
          Expanded(
            child: AsyncStateView<User>(
              state: social.me,
              onRetry: social.loadMe,
              builder: (user) => ListView(
                children: [
                  const SizedBox(height: AppTheme.spacingLg),
                  Center(
                    child: SnapAvatar(
                      imageUrl: user.avatarUrl,
                      fallbackText: user.displayName,
                      size: AppTheme.avatarXl,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          user.displayName,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        RoleBadge(role: user.role, roleLabel: user.roleLabel),
                      ],
                    ),
                  ),
                  Center(
                    child: Text(
                      '@${user.username}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingXl),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ProfileStat(
                        value: '${user.friendCount}',
                        label: 'Friends',
                        onTap: () => context.push('/friends'),
                      ),
                      ProfileStat(
                        value: 'Open',
                        label: 'Memories',
                        onTap: () => context.push('/memories'),
                      ),
                      ProfileStat(
                        value: 'Open',
                        label: 'Awards',
                        onTap: () => context.push('/achievements'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingXl),
                  ProfileActionRow(
                    icon: Icons.edit_outlined,
                    label: 'Edit profile',
                    onTap: () => context.push('/profile/edit'),
                  ),
                  ProfileActionRow(
                    icon: Icons.face_retouching_natural_rounded,
                    label: 'Avatar studio',
                    onTap: () => context.push('/avatar'),
                  ),
                  ProfileActionRow(
                    icon: Icons.ios_share_rounded,
                    label: 'Share profile',
                    onTap: () => _shareProfile(user),
                  ),
                  ProfileActionRow(
                    icon: Icons.verified_user_outlined,
                    label: 'Account status',
                    onTap: () => context.push('/settings-account-status'),
                  ),
                  ProfileActionRow(
                    icon: Icons.person_search_rounded,
                    label: 'Find friends from contacts',
                    onTap: () => context.push('/find-friends'),
                  ),
                  ProfileActionRow(
                    icon: Icons.group_outlined,
                    label: 'Friends',
                    onTap: () => context.push('/friends'),
                  ),
                  ProfileActionRow(
                    icon: Icons.notifications_none_rounded,
                    label: 'Notifications',
                    onTap: () => context.push('/notifications'),
                  ),
                  ProfileActionRow(
                    icon: Icons.bookmark_border_rounded,
                    label: 'Memories',
                    onTap: () => context.push('/memories'),
                  ),
                  ProfileActionRow(
                    icon: Icons.workspace_premium_outlined,
                    label: 'Creator panel',
                    onTap: () => context.push('/creator'),
                  ),
                  ProfileActionRow(
                    icon: Icons.star_border_rounded,
                    label: 'Swift+',
                    onTap: () => context.push('/swiftplus'),
                  ),
                  ProfileActionRow(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    onTap: () => context.push('/settings'),
                  ),
                  const SizedBox(height: AppTheme.spacingHuge),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
