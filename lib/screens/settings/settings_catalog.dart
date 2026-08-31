import 'package:flutter/material.dart';

enum SettingsRowKind { toggle, choice, info }

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

  const SettingsRowSpec.toggle({
    required this.title,
    required this.key,
    this.subtitle,
    this.defaultBool = false,
  })  : kind = SettingsRowKind.toggle,
        defaultChoice = '',
        options = const [],
        infoValue = null;

  const SettingsRowSpec.choice({
    required this.title,
    required this.key,
    required this.options,
    required this.defaultChoice,
    this.subtitle,
  })  : kind = SettingsRowKind.choice,
        defaultBool = false,
        infoValue = null;

  const SettingsRowSpec.info({
    required this.title,
    required this.infoValue,
    this.subtitle,
  })  : kind = SettingsRowKind.info,
        key = null,
        defaultBool = false,
        defaultChoice = '',
        options = const [];
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

/// Single source of truth for the settings tree. Every toggle and choice is
/// persisted locally the moment it changes; the sections marked in their footer
/// additionally require a backend settings endpoint to sync across devices.
class SettingsCatalog {
  SettingsCatalog._();

  static const List<SettingsSectionSpec> sections = [
    SettingsSectionSpec(
      id: 'account',
      title: 'Account',
      icon: Icons.person_outline_rounded,
      footer:
          'Account details are stored on the SwiftSnap backend and sync across devices.',
      groups: [
        SettingsGroupSpec(
          title: 'Security',
          rows: [
            SettingsRowSpec.toggle(
              title: 'Require confirmation on new logins',
              key: 'account.login_confirmation',
              defaultBool: true,
            ),
            SettingsRowSpec.toggle(
              title: 'Remember this device',
              key: 'account.remember_device',
              defaultBool: true,
            ),
          ],
        ),
      ],
    ),
    SettingsSectionSpec(
      id: 'privacy',
      title: 'Privacy',
      icon: Icons.lock_outline_rounded,
      groups: [
        SettingsGroupSpec(
          title: 'Who can',
          rows: [
            SettingsRowSpec.choice(
              title: 'Contact me',
              key: 'privacy.contact_me',
              options: ['Friends', 'Everyone'],
              defaultChoice: 'Friends',
            ),
            SettingsRowSpec.choice(
              title: 'View my story',
              key: 'privacy.view_story',
              options: ['Friends', 'Everyone', 'Custom'],
              defaultChoice: 'Friends',
            ),
            SettingsRowSpec.choice(
              title: 'See me in Quick Add',
              key: 'privacy.quick_add',
              options: ['Friends of friends', 'Nobody'],
              defaultChoice: 'Friends of friends',
            ),
          ],
        ),
        SettingsGroupSpec(
          title: 'Activity',
          rows: [
            SettingsRowSpec.toggle(
              title: 'Show my online status',
              key: 'privacy.online_status',
              defaultBool: true,
            ),
            SettingsRowSpec.toggle(
              title: 'Send read receipts',
              key: 'privacy.read_receipts',
              defaultBool: true,
            ),
          ],
        ),
      ],
    ),
    SettingsSectionSpec(
      id: 'notifications',
      title: 'Notifications',
      icon: Icons.notifications_none_rounded,
      footer:
          'Delivery to a locked or closed app additionally requires push credentials on the backend.',
      groups: [
        SettingsGroupSpec(
          rows: [
            SettingsRowSpec.toggle(
              title: 'Messages',
              key: 'notifications.messages',
              defaultBool: true,
            ),
            SettingsRowSpec.toggle(
              title: 'Friend requests',
              key: 'notifications.friend_requests',
              defaultBool: true,
            ),
            SettingsRowSpec.toggle(
              title: 'Story updates',
              key: 'notifications.stories',
              defaultBool: true,
            ),
            SettingsRowSpec.toggle(
              title: 'Reel activity',
              key: 'notifications.reels',
            ),
            SettingsRowSpec.toggle(
              title: 'Sound',
              key: 'notifications.sound',
              defaultBool: true,
            ),
            SettingsRowSpec.toggle(
              title: 'Vibration',
              key: 'notifications.vibration',
              defaultBool: true,
            ),
          ],
        ),
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
  ];

  static SettingsSectionSpec? byId(String id) {
    for (final section in sections) {
      if (section.id == id) return section;
    }
    return null;
  }
}
