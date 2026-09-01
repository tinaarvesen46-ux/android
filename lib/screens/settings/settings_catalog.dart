import 'package:flutter/material.dart';

enum SettingsRowKind { toggle, choice, info, navigation }

class SettingsRowSpec {
  final SettingsRowKind kind;
  final String title;
  final String? subtitle;

  /// Persistence key. Namespaced by section, e.g. `privacy.contact_me`.
  final String? key;
  final bool defaultBool;
  final String defaultChoice;
  final List<String> options;
  final String? infoValue;
  final String? route;

  const SettingsRowSpec.toggle({
    required this.title,
    required this.key,
    this.subtitle,
    this.defaultBool = false,
  })  : kind = SettingsRowKind.toggle,
        defaultChoice = '',
        options = const [],
        infoValue = null,
        route = null;

  const SettingsRowSpec.choice({
    required this.title,
    required this.key,
    required this.options,
    required this.defaultChoice,
    this.subtitle,
  })  : kind = SettingsRowKind.choice,
        defaultBool = false,
        infoValue = null,
        route = null;

  const SettingsRowSpec.info({
    required this.title,
    required this.infoValue,
    this.subtitle,
  })  : kind = SettingsRowKind.info,
        key = null,
        defaultBool = false,
        defaultChoice = '',
        options = const [],
        route = null;

  const SettingsRowSpec.navigation({
    required this.title,
    required this.route,
    this.subtitle,
  })  : kind = SettingsRowKind.navigation,
        key = null,
        defaultBool = false,
        defaultChoice = '',
        options = const [],
        infoValue = null;
}

class SettingsGroupSpec {
  final String? title;
  final List<SettingsRowSpec> rows;

  const SettingsGroupSpec({this.title, required this.rows});
}

class SettingsSectionSpec {
  final String id;
  final String title;
  final IconData icon;
  final String? footer;
  final List<SettingsGroupSpec> groups;

  const SettingsSectionSpec({
    required this.id,
    required this.title,
    required this.icon,
    this.footer,
    required this.groups,
  });
}

class SettingsDirectoryEntry {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;

  const SettingsDirectoryEntry({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
  });
}

/// Single source of truth for the settings tree. Every toggle and choice is
/// persisted locally the moment it changes; the sections marked in their footer
/// additionally require a backend settings endpoint to sync across devices.
class SettingsCatalog {
  SettingsCatalog._();

  /// The landing-page directory. Keeping this separate from preference rows
  /// lets security screens remain real backend-backed pages while local
  /// presentation preferences continue to use the generic section renderer.
  static const List<SettingsDirectoryEntry> directory = [
    SettingsDirectoryEntry(id: 'account', title: 'Account', subtitle: 'Profile, security and subscriptions', icon: Icons.person_outline_rounded, route: '/settings/account'),
    SettingsDirectoryEntry(id: 'profile', title: 'Profile', subtitle: 'Edit your profile and public presence', icon: Icons.badge_outlined, route: '/settings/profile'),
    SettingsDirectoryEntry(id: 'privacy', title: 'Privacy controls', subtitle: 'Who can contact and view you', icon: Icons.lock_outline_rounded, route: '/settings-privacy'),
    SettingsDirectoryEntry(id: 'notifications', title: 'Notifications', subtitle: 'Push, email and activity alerts', icon: Icons.notifications_none_rounded, route: '/settings-notifications'),
    SettingsDirectoryEntry(id: 'location', title: 'Location & Map', subtitle: 'Ghost Mode and map visibility', icon: Icons.map_outlined, route: '/settings/location'),
    SettingsDirectoryEntry(id: 'memories', title: 'Memories', subtitle: 'Save and manage your memories', icon: Icons.bookmark_border_rounded, route: '/settings/memories'),
    SettingsDirectoryEntry(id: 'data-saver', title: 'Data Saver', subtitle: 'Control mobile data usage', icon: Icons.data_saver_on_outlined, route: '/settings/data-saver'),
    SettingsDirectoryEntry(id: 'personalization', title: 'Personalisation', subtitle: 'Appearance and recommendations', icon: Icons.tune_rounded, route: '/settings/personalization'),
    SettingsDirectoryEntry(id: 'music', title: 'Music & Now Playing', subtitle: 'Music sharing preferences', icon: Icons.music_note_rounded, route: '/settings/music'),
    SettingsDirectoryEntry(id: 'generative-ai', title: 'Generative AI', subtitle: 'My AI privacy and controls', icon: Icons.auto_awesome_outlined, route: '/settings/generative-ai'),
    SettingsDirectoryEntry(id: 'family-centre', title: 'Family Centre', subtitle: 'Family safety controls', icon: Icons.family_restroom_rounded, route: '/settings/family-centre'),
    SettingsDirectoryEntry(id: 'made-for-me', title: 'Made For Me', subtitle: 'Content and discovery preferences', icon: Icons.explore_outlined, route: '/settings/made-for-me'),
    SettingsDirectoryEntry(id: 'chat', title: 'Chat', subtitle: 'Messages, media and notifications', icon: Icons.chat_bubble_outline_rounded, route: '/settings/chat'),
    SettingsDirectoryEntry(id: 'story', title: 'Story', subtitle: 'Replies and story saving', icon: Icons.auto_stories_outlined, route: '/settings/story'),
    SettingsDirectoryEntry(id: 'camera', title: 'Camera', subtitle: 'Capture and quality preferences', icon: Icons.camera_alt_outlined, route: '/settings/camera'),
    SettingsDirectoryEntry(id: 'appearance', title: 'Appearance', subtitle: 'Motion and readability', icon: Icons.palette_outlined, route: '/settings/appearance'),
    SettingsDirectoryEntry(id: 'support', title: 'Support & Feedback', subtitle: 'Reports, safety and help', icon: Icons.help_outline_rounded, route: '/settings/support'),
    SettingsDirectoryEntry(id: 'legal', title: 'Legal', subtitle: 'Terms, privacy and acknowledgements', icon: Icons.gavel_outlined, route: '/settings/legal'),
    SettingsDirectoryEntry(id: 'account-actions', title: 'Account actions', subtitle: 'Export, sign out or delete', icon: Icons.manage_accounts_outlined, route: '/settings/account-actions'),
  ];

  static const List<SettingsSectionSpec> sections = [
    SettingsSectionSpec(
      id: 'account',
      title: 'Account',
      icon: Icons.person_outline_rounded,
      groups: [
        SettingsGroupSpec(rows: [
          SettingsRowSpec.navigation(title: 'Edit profile', subtitle: 'Name, username, birthday and profile details', route: '/profile/edit'),
          SettingsRowSpec.navigation(title: 'Avatar Studio', subtitle: 'Change your SwiftMoji avatar', route: '/avatar'),
          SettingsRowSpec.navigation(title: 'Password', route: '/settings-password'),
          SettingsRowSpec.navigation(title: 'Two-factor authentication', route: '/settings-2fa'),
          SettingsRowSpec.navigation(title: 'Mobile number', route: '/settings-phone'),
          SettingsRowSpec.navigation(title: 'Sessions', route: '/settings-sessions'),
          SettingsRowSpec.navigation(title: 'Subscriptions', route: '/swiftplus'),
          SettingsRowSpec.navigation(title: 'Account status', route: '/settings-account-status'),
        ]),
      ],
    ),
    SettingsSectionSpec(
      id: 'profile',
      title: 'Profile',
      icon: Icons.badge_outlined,
      groups: [
        SettingsGroupSpec(rows: [
          SettingsRowSpec.navigation(title: 'Edit profile', route: '/profile/edit'),
          SettingsRowSpec.navigation(title: 'Profile header', subtitle: 'Background, pose and avatar position', route: '/profile/header'),
          SettingsRowSpec.navigation(title: 'Public Profile', subtitle: 'Create or edit your public profile', route: '/profile/public/edit'),
          SettingsRowSpec.navigation(title: 'Friends', route: '/friends'),
          SettingsRowSpec.navigation(title: 'Find friends', route: '/find-friends'),
        ]),
      ],
    ),
    SettingsSectionSpec(
      id: 'privacy',
      title: 'Privacy controls',
      icon: Icons.lock_outline_rounded,
      groups: [
        SettingsGroupSpec(rows: [
          SettingsRowSpec.navigation(title: 'Detailed privacy controls', route: '/settings-privacy'),
          SettingsRowSpec.navigation(title: 'Blocked accounts', route: '/settings-blocked'),
          SettingsRowSpec.navigation(title: 'My Data', route: '/settings-my-data'),
        ]),
      ],
    ),
    SettingsSectionSpec(
      id: 'chat',
      title: 'Chat',
      icon: Icons.chat_bubble_outline_rounded,
      groups: [
        SettingsGroupSpec(
          rows: [
            SettingsRowSpec.choice(
              title: 'Delete messages',
              key: 'chat.retention',
              options: ['After viewing', '24 hours', 'Never'],
              defaultChoice: 'After viewing',
            ),
            SettingsRowSpec.toggle(
              title: 'Enter key sends message',
              key: 'chat.enter_sends',
              defaultBool: true,
            ),
            SettingsRowSpec.toggle(
              title: 'Save media automatically',
              key: 'chat.autosave_media',
            ),
            SettingsRowSpec.toggle(
              title: 'Notification sound',
              key: 'chat.notif_sound',
              defaultBool: true,
            ),
            SettingsRowSpec.toggle(
              title: 'Notification vibration',
              key: 'chat.notif_vibration',
              defaultBool: true,
            ),
          ],
        ),
      ],
    ),
    SettingsSectionSpec(
      id: 'story',
      title: 'Story',
      icon: Icons.auto_stories_outlined,
      groups: [
        SettingsGroupSpec(
          rows: [
            SettingsRowSpec.toggle(
              title: 'Allow story replies',
              key: 'story.allow_replies',
              defaultBool: true,
            ),
            SettingsRowSpec.toggle(
              title: 'Save my story to Memories',
              key: 'story.autosave',
              defaultBool: true,
            ),
          ],
        ),
      ],
    ),
    SettingsSectionSpec(
      id: 'camera',
      title: 'Camera',
      icon: Icons.camera_alt_outlined,
      groups: [
        SettingsGroupSpec(
          rows: [
            SettingsRowSpec.toggle(
              title: 'Front camera mirroring',
              key: 'camera.mirror_front',
              defaultBool: true,
            ),
            SettingsRowSpec.toggle(
              title: 'Save captures to device',
              key: 'camera.save_to_device',
            ),
            SettingsRowSpec.choice(
              title: 'Capture quality',
              key: 'camera.quality',
              options: ['Standard', 'High'],
              defaultChoice: 'High',
            ),
          ],
        ),
      ],
    ),
    SettingsSectionSpec(
      id: 'memories',
      title: 'Memories',
      icon: Icons.bookmark_border_rounded,
      groups: [
        SettingsGroupSpec(
          rows: [
            SettingsRowSpec.toggle(
              title: 'Auto-save snaps to Memories',
              key: 'memories.autosave',
            ),
            SettingsRowSpec.toggle(
              title: 'Show memories over mobile data',
              key: 'memories.mobile_data',
              defaultBool: true,
            ),
          ],
        ),
      ],
    ),
    SettingsSectionSpec(
      id: 'location',
      title: 'Location',
      icon: Icons.map_outlined,
      footer:
          'Ghost Mode also stops your position being sent to the SwiftSnap backend.',
      groups: [
        SettingsGroupSpec(
          rows: [
            SettingsRowSpec.toggle(
              title: 'Ghost Mode',
              subtitle: 'Hide your position on the map',
              key: 'map.ghost_mode',
            ),
            SettingsRowSpec.choice(
              title: 'Who can see my location',
              key: 'map.audience',
              options: ['Friends', 'Selected friends', 'Nobody'],
              defaultChoice: 'Friends',
            ),
          ],
        ),
      ],
    ),
    SettingsSectionSpec(
      id: 'appearance',
      title: 'Appearance',
      icon: Icons.palette_outlined,
      footer: 'SwiftSnap uses a dark, camera-first interface on every screen.',
      groups: [
        SettingsGroupSpec(
          rows: [
            SettingsRowSpec.toggle(
              title: 'Reduce motion',
              key: 'appearance.reduce_motion',
            ),
            SettingsRowSpec.toggle(
              title: 'Larger chat text',
              key: 'appearance.large_text',
            ),
          ],
        ),
      ],
    ),
    SettingsSectionSpec(
      id: 'data-saver',
      title: 'Data Saver',
      icon: Icons.data_saver_on_outlined,
      footer: 'These preferences are stored on this device and reduce automatic media loading.',
      groups: [
        SettingsGroupSpec(rows: [
          SettingsRowSpec.toggle(title: 'Data Saver', subtitle: 'Reduce automatic media loading', key: 'data_saver.enabled'),
          SettingsRowSpec.toggle(title: 'Use mobile data for Memories', key: 'data_saver.memories_mobile', defaultBool: true),
          SettingsRowSpec.toggle(title: 'Use mobile data for stories', key: 'data_saver.stories_mobile', defaultBool: true),
        ]),
      ],
    ),
    SettingsSectionSpec(
      id: 'personalization',
      title: 'Personalisation',
      icon: Icons.tune_rounded,
      groups: [
        SettingsGroupSpec(rows: [
          SettingsRowSpec.toggle(title: 'Personalised recommendations', key: 'personalization.recommendations', defaultBool: true),
          SettingsRowSpec.toggle(title: 'Personalised ads', key: 'personalization.ads', defaultBool: true),
          SettingsRowSpec.navigation(title: 'App language', route: '/settings-language'),
          SettingsRowSpec.navigation(title: 'Appearance', route: '/settings/appearance'),
        ]),
      ],
    ),
    SettingsSectionSpec(
      id: 'music',
      title: 'Music & Now Playing',
      icon: Icons.music_note_rounded,
      footer: 'Music integrations are enabled only when a supported provider is configured.',
      groups: [
        SettingsGroupSpec(rows: [
          SettingsRowSpec.toggle(title: 'Show Now Playing on my profile', key: 'music.show_now_playing'),
          SettingsRowSpec.toggle(title: 'Share music in stories', key: 'music.share_to_stories'),
          SettingsRowSpec.info(title: 'Connected music service', infoValue: 'Not connected'),
        ]),
      ],
    ),
    SettingsSectionSpec(
      id: 'generative-ai',
      title: 'Generative AI',
      icon: Icons.auto_awesome_outlined,
      footer: 'My AI never runs arbitrary device commands. Provider availability is shown in the My AI chat.',
      groups: [
        SettingsGroupSpec(rows: [
          SettingsRowSpec.toggle(title: 'My AI personalisation', key: 'ai.personalization', defaultBool: true),
          SettingsRowSpec.toggle(title: 'Save My AI conversations', key: 'ai.save_conversations', defaultBool: true),
          SettingsRowSpec.navigation(title: 'Open My AI', route: '/my-ai'),
        ]),
      ],
    ),
    SettingsSectionSpec(
      id: 'family-centre',
      title: 'Family Centre',
      icon: Icons.family_restroom_rounded,
      footer: 'Family Centre controls require an account relationship. No relationship is created by this screen.',
      groups: [
        SettingsGroupSpec(rows: [
          SettingsRowSpec.info(title: 'Supervision status', infoValue: 'Not configured'),
          SettingsRowSpec.toggle(title: 'Safety notifications', key: 'family.safety_notifications', defaultBool: true),
        ]),
      ],
    ),
    SettingsSectionSpec(
      id: 'made-for-me',
      title: 'Made For Me',
      icon: Icons.explore_outlined,
      groups: [
        SettingsGroupSpec(rows: [
          SettingsRowSpec.toggle(title: 'Show recommended creators', key: 'made_for_me.creators', defaultBool: true),
          SettingsRowSpec.toggle(title: 'Show recommended Spotlight posts', key: 'made_for_me.spotlight', defaultBool: true),
          SettingsRowSpec.toggle(title: 'Use watch history for recommendations', key: 'made_for_me.watch_history', defaultBool: true),
        ]),
      ],
    ),
    SettingsSectionSpec(
      id: 'support',
      title: 'Support & Feedback',
      icon: Icons.help_outline_rounded,
      groups: [
        SettingsGroupSpec(rows: [
          SettingsRowSpec.navigation(title: 'My Reports', route: '/settings-my-reports'),
          SettingsRowSpec.navigation(title: 'Safety and privacy', route: '/settings-privacy'),
          SettingsRowSpec.navigation(title: 'Help with my account', route: '/settings-account-status'),
          SettingsRowSpec.navigation(title: 'About SwiftSnap', route: '/settings-about'),
        ]),
      ],
    ),
    SettingsSectionSpec(
      id: 'legal',
      title: 'Legal',
      icon: Icons.gavel_outlined,
      footer: 'SwiftSnap is independent and is not affiliated with Snap Inc.',
      groups: [
        SettingsGroupSpec(rows: [
          SettingsRowSpec.info(title: 'Terms of service', infoValue: 'Available on the SwiftSnap website'),
          SettingsRowSpec.info(title: 'Privacy policy', infoValue: 'Available on the SwiftSnap website'),
          SettingsRowSpec.navigation(title: 'Acknowledgements', route: '/settings-about'),
        ]),
      ],
    ),
    SettingsSectionSpec(
      id: 'account-actions',
      title: 'Account actions',
      icon: Icons.manage_accounts_outlined,
      groups: [
        SettingsGroupSpec(rows: [
          SettingsRowSpec.navigation(title: 'Export my data', route: '/settings-my-data'),
          SettingsRowSpec.navigation(title: 'Delete account', route: '/settings-delete-account'),
          SettingsRowSpec.info(title: 'Log out', infoValue: 'Available from Settings'),
        ]),
      ],
    ),
  ];

  static SettingsSectionSpec? byId(String id) {
    for (final section in sections) {
      if (section.id == id) return section;
    }
    return null;
  }
}
