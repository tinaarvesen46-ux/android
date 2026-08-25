-- ============================================================
--  VibeChat - Complete MySQL Database Schema
--  Nexa-Group | VibeChat Platform
--  Version: 3.0.0
--  Generated: June 2026
-- ============================================================
-- 
--  TABLE INDEX:
--   1.  users
--   2.  user_profiles
--   3.  user_settings
--   4.  user_devices
--   5.  user_sessions
--   6.  user_blocks
--   7.  user_reports
--   8.  friendships
--   9.  friend_requests
--   10. conversations
--   11. conversation_participants
--   12. messages
--   13. message_media
--   14. message_reactions
--   15. stories
--   16. story_media
--   17. story_views
--   18. story_reactions
--   19. notifications
--   20. notification_preferences
--   21. push_tokens
--   22. support_tickets
--   23. ticket_replies
--   24. content_reports
--   25. admin_audit_logs
--   26. email_templates
--   27. email_campaigns
--   28. campaign_recipients
--   29. system_settings
--   30. creator_analytics
--   31. creator_revenue
--   32. subscriptions
--   33. subscription_plans
--   34. verification_requests
--   35. app_versions
--   36. media_uploads
--   37. streaks
--   38. achievements
--   39. user_achievements
--   40. user_warnings
--   41. group_chats
--   42. group_chat_members
--   43. otp_verifications
--   44. help_categories
--   45. kb_articles
--   46. kb_article_feedback
--   47. help_search_logs
--   48. reaction_types
-- ============================================================

SET FOREIGN_KEY_CHECKS = 0;
SET SQL_MODE = 'NO_AUTO_VALUE_ON_ZERO';
SET NAMES utf8mb4;
SET time_zone = '+00:00';

-- ============================================================
-- 1. USERS
-- Core user accounts table
-- ============================================================
CREATE TABLE `users` (
  `id`                  BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `uuid`                CHAR(36) NOT NULL UNIQUE DEFAULT (UUID()),
  `username`            VARCHAR(30) NOT NULL UNIQUE,
  `email`               VARCHAR(255) NOT NULL UNIQUE,
  `email_verified_at`   TIMESTAMP NULL DEFAULT NULL,
  `phone`               VARCHAR(20) NULL UNIQUE,
  `phone_verified_at`   TIMESTAMP NULL DEFAULT NULL,
  `password`            VARCHAR(255) NOT NULL,
  `remember_token`      VARCHAR(100) NULL,
  `account_status`      ENUM('normal','verified','creator','suspended','banned','deleted') NOT NULL DEFAULT 'normal',
  `staff_role`          ENUM('none','support','moderator','administrator') NOT NULL DEFAULT 'none',
  `privacy_level`       ENUM('public','friends_only','private') NOT NULL DEFAULT 'public',
  `is_online`           TINYINT(1) NOT NULL DEFAULT 0,
  `last_seen_at`        TIMESTAMP NULL DEFAULT NULL,
  `streak_days`         INT UNSIGNED NOT NULL DEFAULT 0,
  `streak_last_activity` DATE NULL DEFAULT NULL,
  `two_factor_enabled`  TINYINT(1) NOT NULL DEFAULT 0,
  `two_factor_secret`   VARCHAR(255) NULL,
  `two_factor_recovery` TEXT NULL,
  `login_attempts`      TINYINT UNSIGNED NOT NULL DEFAULT 0,
  `locked_until`        TIMESTAMP NULL DEFAULT NULL,
  `warning_count`       TINYINT UNSIGNED NOT NULL DEFAULT 0,
  `suspension_reason`   TEXT NULL,
  `suspension_ends_at`  TIMESTAMP NULL DEFAULT NULL,
  `banned_at`           TIMESTAMP NULL DEFAULT NULL,
  `ban_reason`          TEXT NULL,
  `deleted_at`          TIMESTAMP NULL DEFAULT NULL,
  `created_at`          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_users_uuid` (`uuid`),
  INDEX `idx_users_username` (`username`),
  INDEX `idx_users_email` (`email`),
  INDEX `idx_users_staff_role` (`staff_role`),
  INDEX `idx_users_account_status` (`account_status`),
  INDEX `idx_users_is_online` (`is_online`),
  INDEX `idx_users_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 2. USER PROFILES
-- Extended profile information
-- ============================================================
CREATE TABLE `user_profiles` (
  `id`              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id`         BIGINT UNSIGNED NOT NULL UNIQUE,
  `display_name`    VARCHAR(50) NOT NULL,
  `avatar_url`      VARCHAR(500) NULL,
  `cover_url`       VARCHAR(500) NULL,
  `bio`             TEXT NULL,
  `pronouns`        VARCHAR(30) NULL,
  `location`        VARCHAR(100) NULL,
  `website`         VARCHAR(255) NULL,
  `birthday`        DATE NULL,
  `friend_count`    INT UNSIGNED NOT NULL DEFAULT 0,
  `follower_count`  INT UNSIGNED NOT NULL DEFAULT 0,
  `following_count` INT UNSIGNED NOT NULL DEFAULT 0,
  `story_count`     INT UNSIGNED NOT NULL DEFAULT 0,
  `snap_score`      BIGINT UNSIGNED NOT NULL DEFAULT 0,
  `theme_preference` VARCHAR(50) NOT NULL DEFAULT 'classic_purple',
  `language`        VARCHAR(10) NOT NULL DEFAULT 'en',
  `created_at`      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_profiles_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 3. USER SETTINGS
-- Per-user app configuration
-- ============================================================
CREATE TABLE `user_settings` (
  `id`                              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id`                         BIGINT UNSIGNED NOT NULL UNIQUE,
  -- Notification preferences
  `notif_messages`                  TINYINT(1) NOT NULL DEFAULT 1,
  `notif_friend_requests`           TINYINT(1) NOT NULL DEFAULT 1,
  `notif_story_views`               TINYINT(1) NOT NULL DEFAULT 1,
  `notif_story_reactions`           TINYINT(1) NOT NULL DEFAULT 1,
  `notif_marketing`                 TINYINT(1) NOT NULL DEFAULT 0,
  `notif_streaks`                   TINYINT(1) NOT NULL DEFAULT 1,
  `notif_security`                  TINYINT(1) NOT NULL DEFAULT 1,
  -- Privacy preferences
  `show_online_status`              TINYINT(1) NOT NULL DEFAULT 1,
  `show_read_receipts`              TINYINT(1) NOT NULL DEFAULT 1,
  `show_typing_indicator`           TINYINT(1) NOT NULL DEFAULT 1,
  `allow_friend_requests_from`      ENUM('everyone','friends_of_friends','nobody') NOT NULL DEFAULT 'everyone',
  `allow_messages_from`             ENUM('everyone','friends','nobody') NOT NULL DEFAULT 'friends',
  `story_visibility`                ENUM('everyone','friends','close_friends','nobody') NOT NULL DEFAULT 'friends',
  -- Security
  `login_alerts`                    TINYINT(1) NOT NULL DEFAULT 1,
  `screenshot_alerts`               TINYINT(1) NOT NULL DEFAULT 1,
  `data_sharing_analytics`          TINYINT(1) NOT NULL DEFAULT 1,
  `data_sharing_personalization`    TINYINT(1) NOT NULL DEFAULT 1,
  `created_at`                      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`                      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_settings_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 4. USER DEVICES
-- Registered devices for push notifications & session management
-- ============================================================
CREATE TABLE `user_devices` (
  `id`              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id`         BIGINT UNSIGNED NOT NULL,
  `device_id`       VARCHAR(255) NOT NULL,
  `device_name`     VARCHAR(100) NULL,
  `device_type`     ENUM('ios','android','web','desktop') NOT NULL DEFAULT 'android',
  `os_version`      VARCHAR(50) NULL,
  `app_version`     VARCHAR(20) NULL,
  `push_token`      VARCHAR(500) NULL,
  `push_provider`   ENUM('fcm','apns','web_push') NULL,
  `ip_address`      VARCHAR(45) NULL,
  `location`        VARCHAR(100) NULL,
  `is_trusted`      TINYINT(1) NOT NULL DEFAULT 0,
  `last_active_at`  TIMESTAMP NULL DEFAULT NULL,
  `created_at`      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_device_user` (`user_id`, `device_id`),
  INDEX `idx_devices_user` (`user_id`),
  INDEX `idx_devices_push_token` (`push_token`(191)),
  CONSTRAINT `fk_devices_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 5. USER SESSIONS
-- Login history & active sessions
-- ============================================================
CREATE TABLE `user_sessions` (
  `id`              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id`         BIGINT UNSIGNED NOT NULL,
  `session_token`   VARCHAR(255) NOT NULL UNIQUE,
  `refresh_token`   VARCHAR(255) NULL UNIQUE,
  `device_id`       VARCHAR(255) NULL,
  `device_name`     VARCHAR(100) NULL,
  `ip_address`      VARCHAR(45) NULL,
  `location`        VARCHAR(100) NULL,
  `user_agent`      VARCHAR(500) NULL,
  `login_method`    ENUM('password','google','apple','facebook','magic_link') NOT NULL DEFAULT 'password',
  `is_active`       TINYINT(1) NOT NULL DEFAULT 1,
  `expires_at`      TIMESTAMP NOT NULL,
  `refresh_expires_at` TIMESTAMP NULL,
  `last_used_at`    TIMESTAMP NULL DEFAULT NULL,
  `revoked_at`      TIMESTAMP NULL DEFAULT NULL,
  `revoke_reason`   VARCHAR(100) NULL,
  `created_at`      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_sessions_user` (`user_id`),
  INDEX `idx_sessions_token` (`session_token`),
  INDEX `idx_sessions_active` (`is_active`, `expires_at`),
  CONSTRAINT `fk_sessions_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 6. USER BLOCKS
-- Blocked users tracking
-- ============================================================
CREATE TABLE `user_blocks` (
  `id`            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `blocker_id`    BIGINT UNSIGNED NOT NULL,
  `blocked_id`    BIGINT UNSIGNED NOT NULL,
  `reason`        VARCHAR(255) NULL,
  `created_at`    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_block` (`blocker_id`, `blocked_id`),
  INDEX `idx_blocks_blocker` (`blocker_id`),
  INDEX `idx_blocks_blocked` (`blocked_id`),
  CONSTRAINT `fk_blocks_blocker` FOREIGN KEY (`blocker_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_blocks_blocked` FOREIGN KEY (`blocked_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 7. USER REPORTS
-- User-to-user reports (not moderation team reports)
-- ============================================================
CREATE TABLE `user_reports` (
  `id`                  BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `reporter_id`         BIGINT UNSIGNED NOT NULL,
  `reported_user_id`    BIGINT UNSIGNED NOT NULL,
  `content_type`        ENUM('profile','message','story','comment') NOT NULL,
  `content_id`          BIGINT UNSIGNED NULL,
  `reason`              ENUM('spam','harassment','hate_speech','violence','misinformation','nudity','copyright','other') NOT NULL,
  `description`         TEXT NULL,
  `status`              ENUM('pending','reviewed','actioned','dismissed') NOT NULL DEFAULT 'pending',
  `reviewed_by`         BIGINT UNSIGNED NULL,
  `reviewed_at`         TIMESTAMP NULL,
  `action_taken`        VARCHAR(255) NULL,
  `created_at`          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_reports_reporter` (`reporter_id`),
  INDEX `idx_reports_reported` (`reported_user_id`),
  INDEX `idx_reports_status` (`status`),
  CONSTRAINT `fk_reports_reporter` FOREIGN KEY (`reporter_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_reports_reported` FOREIGN KEY (`reported_user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_reports_reviewer` FOREIGN KEY (`reviewed_by`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 8. FRIENDSHIPS
-- Accepted friend relationships (bidirectional)
-- ============================================================
CREATE TABLE `friendships` (
  `id`            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id`       BIGINT UNSIGNED NOT NULL,
  `friend_id`     BIGINT UNSIGNED NOT NULL,
  `is_favorite`   TINYINT(1) NOT NULL DEFAULT 0,
  `is_close`      TINYINT(1) NOT NULL DEFAULT 0,
  `created_at`    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_friendship` (`user_id`, `friend_id`),
  INDEX `idx_friendships_user` (`user_id`),
  INDEX `idx_friendships_friend` (`friend_id`),
  CONSTRAINT `fk_friendships_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_friendships_friend` FOREIGN KEY (`friend_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 9. FRIEND REQUESTS
-- Pending friendship invitations
-- ============================================================
CREATE TABLE `friend_requests` (
  `id`            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `sender_id`     BIGINT UNSIGNED NOT NULL,
  `receiver_id`   BIGINT UNSIGNED NOT NULL,
  `message`       VARCHAR(255) NULL,
  `status`        ENUM('pending','accepted','rejected','cancelled') NOT NULL DEFAULT 'pending',
  `responded_at`  TIMESTAMP NULL DEFAULT NULL,
  `created_at`    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_friend_request` (`sender_id`, `receiver_id`),
  INDEX `idx_freq_sender` (`sender_id`),
  INDEX `idx_freq_receiver` (`receiver_id`),
  INDEX `idx_freq_status` (`status`),
  CONSTRAINT `fk_freq_sender` FOREIGN KEY (`sender_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_freq_receiver` FOREIGN KEY (`receiver_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 10. CONVERSATIONS
-- Chat conversations (direct messages & group chats)
-- ============================================================
CREATE TABLE `conversations` (
  `id`                BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `uuid`              CHAR(36) NOT NULL UNIQUE DEFAULT (UUID()),
  `type`              ENUM('direct','group') NOT NULL DEFAULT 'direct',
  `name`              VARCHAR(100) NULL,
  `avatar_url`        VARCHAR(500) NULL,
  `description`       TEXT NULL,
  `created_by`        BIGINT UNSIGNED NOT NULL,
  `last_message_id`   BIGINT UNSIGNED NULL,
  `last_activity_at`  TIMESTAMP NULL DEFAULT NULL,
  `is_encrypted`      TINYINT(1) NOT NULL DEFAULT 0,
  `max_participants`  INT UNSIGNED NOT NULL DEFAULT 2,
  `created_at`        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_conv_uuid` (`uuid`),
  INDEX `idx_conv_type` (`type`),
  INDEX `idx_conv_created_by` (`created_by`),
  INDEX `idx_conv_last_activity` (`last_activity_at`),
  CONSTRAINT `fk_conv_creator` FOREIGN KEY (`created_by`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 11. CONVERSATION PARTICIPANTS
-- Users in each conversation
-- ============================================================
CREATE TABLE `conversation_participants` (
  `id`              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `conversation_id` BIGINT UNSIGNED NOT NULL,
  `user_id`         BIGINT UNSIGNED NOT NULL,
  `role`            ENUM('member','admin','owner') NOT NULL DEFAULT 'member',
  `is_pinned`       TINYINT(1) NOT NULL DEFAULT 0,
  `is_muted`        TINYINT(1) NOT NULL DEFAULT 0,
  `muted_until`     TIMESTAMP NULL DEFAULT NULL,
  `unread_count`    INT UNSIGNED NOT NULL DEFAULT 0,
  `last_read_at`    TIMESTAMP NULL DEFAULT NULL,
  `joined_at`       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `left_at`         TIMESTAMP NULL DEFAULT NULL,
  `is_active`       TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_participant` (`conversation_id`, `user_id`),
  INDEX `idx_cp_conv` (`conversation_id`),
  INDEX `idx_cp_user` (`user_id`),
  CONSTRAINT `fk_cp_conv` FOREIGN KEY (`conversation_id`) REFERENCES `conversations`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_cp_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 12. MESSAGES
-- Individual messages within conversations
-- ============================================================
CREATE TABLE `messages` (
  `id`                BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `uuid`              CHAR(36) NOT NULL UNIQUE DEFAULT (UUID()),
  `conversation_id`   BIGINT UNSIGNED NOT NULL,
  `sender_id`         BIGINT UNSIGNED NOT NULL,
  `type`              ENUM('text','image','video','audio','file','sticker','gif','location','call','system') NOT NULL DEFAULT 'text',
  `content`           TEXT NULL,
  `metadata`          JSON NULL,
  `reply_to_id`       BIGINT UNSIGNED NULL,
  `is_ephemeral`      TINYINT(1) NOT NULL DEFAULT 0,
  `expires_at`        TIMESTAMP NULL DEFAULT NULL,
  `is_edited`         TINYINT(1) NOT NULL DEFAULT 0,
  `edited_at`         TIMESTAMP NULL DEFAULT NULL,
  `is_deleted`        TINYINT(1) NOT NULL DEFAULT 0,
  `deleted_at`        TIMESTAMP NULL DEFAULT NULL,
  `deleted_for`       ENUM('sender','everyone') NULL,
  `status`            ENUM('sending','sent','delivered','read','failed') NOT NULL DEFAULT 'sent',
  `created_at`        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_msg_conv` (`conversation_id`, `created_at`),
  INDEX `idx_msg_sender` (`sender_id`),
  INDEX `idx_msg_uuid` (`uuid`),
  INDEX `idx_msg_reply` (`reply_to_id`),
  CONSTRAINT `fk_msg_conv` FOREIGN KEY (`conversation_id`) REFERENCES `conversations`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_msg_sender` FOREIGN KEY (`sender_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_msg_reply` FOREIGN KEY (`reply_to_id`) REFERENCES `messages`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 13. MESSAGE MEDIA
-- Files & media attachments on messages
-- ============================================================
CREATE TABLE `message_media` (
  `id`            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `message_id`    BIGINT UNSIGNED NOT NULL,
  `type`          ENUM('image','video','audio','file','sticker','gif') NOT NULL,
  `url`           VARCHAR(500) NOT NULL,
  `thumbnail_url` VARCHAR(500) NULL,
  `file_name`     VARCHAR(255) NULL,
  `file_size`     INT UNSIGNED NULL COMMENT 'Size in bytes',
  `mime_type`     VARCHAR(100) NULL,
  `width`         INT NULL,
  `height`        INT NULL,
  `duration`      INT NULL COMMENT 'Duration in seconds for audio/video',
  `created_at`    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_media_msg` (`message_id`),
  CONSTRAINT `fk_media_msg` FOREIGN KEY (`message_id`) REFERENCES `messages`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 14. MESSAGE REACTIONS
-- Emoji reactions on messages
-- ============================================================
CREATE TABLE `message_reactions` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `message_id`  BIGINT UNSIGNED NOT NULL,
  `user_id`     BIGINT UNSIGNED NOT NULL,
  `emoji`       VARCHAR(10) NOT NULL,
  `created_at`  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_reaction` (`message_id`, `user_id`),
  INDEX `idx_reactions_msg` (`message_id`),
  CONSTRAINT `fk_reactions_msg` FOREIGN KEY (`message_id`) REFERENCES `messages`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_reactions_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 15. STORIES
-- Ephemeral story posts
-- ============================================================
CREATE TABLE `stories` (
  `id`              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `uuid`            CHAR(36) NOT NULL UNIQUE DEFAULT (UUID()),
  `user_id`         BIGINT UNSIGNED NOT NULL,
  `caption`         TEXT NULL,
  `location`        VARCHAR(100) NULL,
  `music_track`     VARCHAR(255) NULL,
  `view_count`      INT UNSIGNED NOT NULL DEFAULT 0,
  `reaction_count`  INT UNSIGNED NOT NULL DEFAULT 0,
  `visibility`      ENUM('everyone','friends','close_friends','custom') NOT NULL DEFAULT 'friends',
  `is_archived`     TINYINT(1) NOT NULL DEFAULT 0,
  `allow_replies`   TINYINT(1) NOT NULL DEFAULT 1,
  `expires_at`      TIMESTAMP NOT NULL,
  `created_at`      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_stories_user` (`user_id`),
  INDEX `idx_stories_expires` (`expires_at`),
  INDEX `idx_stories_created` (`created_at`),
  CONSTRAINT `fk_stories_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 16. STORY MEDIA
-- Media items within a story
-- ============================================================
CREATE TABLE `story_media` (
  `id`            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `story_id`      BIGINT UNSIGNED NOT NULL,
  `type`          ENUM('photo','video','boomerang','text') NOT NULL DEFAULT 'photo',
  `url`           VARCHAR(500) NOT NULL,
  `thumbnail_url` VARCHAR(500) NULL,
  `duration`      INT NULL DEFAULT 5 COMMENT 'Display duration in seconds',
  `width`         INT NULL,
  `height`        INT NULL,
  `file_size`     INT UNSIGNED NULL,
  `filters`       JSON NULL COMMENT 'Applied filters/overlays',
  `sort_order`    TINYINT UNSIGNED NOT NULL DEFAULT 0,
  `created_at`    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_story_media_story` (`story_id`),
  CONSTRAINT `fk_story_media_story` FOREIGN KEY (`story_id`) REFERENCES `stories`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 17. STORY VIEWS
-- Tracks who viewed a story
-- ============================================================
CREATE TABLE `story_views` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `story_id`    BIGINT UNSIGNED NOT NULL,
  `viewer_id`   BIGINT UNSIGNED NOT NULL,
  `viewed_at`   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_story_view` (`story_id`, `viewer_id`),
  INDEX `idx_sviews_story` (`story_id`),
  INDEX `idx_sviews_viewer` (`viewer_id`),
  CONSTRAINT `fk_sviews_story` FOREIGN KEY (`story_id`) REFERENCES `stories`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_sviews_viewer` FOREIGN KEY (`viewer_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 18. STORY REACTIONS
-- Emoji reactions on stories
-- ============================================================
CREATE TABLE `story_reactions` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `story_id`    BIGINT UNSIGNED NOT NULL,
  `user_id`     BIGINT UNSIGNED NOT NULL,
  `emoji`       VARCHAR(10) NOT NULL,
  `created_at`  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_story_reaction` (`story_id`, `user_id`),
  INDEX `idx_sreact_story` (`story_id`),
  CONSTRAINT `fk_sreact_story` FOREIGN KEY (`story_id`) REFERENCES `stories`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_sreact_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 19. NOTIFICATIONS
-- In-app notifications
-- ============================================================
CREATE TABLE `notifications` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `uuid`        CHAR(36) NOT NULL UNIQUE DEFAULT (UUID()),
  `user_id`     BIGINT UNSIGNED NOT NULL,
  `type`        ENUM(
                  'friend_request','friend_accepted',
                  'message','group_message',
                  'story_view','story_reaction','story_reply',
                  'streak_reminder','streak_milestone',
                  'subscription_expiring','subscription_renewed',
                  'admin_warning','admin_suspension',
                  'system','marketing'
                ) NOT NULL,
  `title`       VARCHAR(255) NOT NULL,
  `body`        TEXT NOT NULL,
  `data`        JSON NULL COMMENT 'Extra payload for deep linking',
  `actor_id`    BIGINT UNSIGNED NULL COMMENT 'User who triggered the notification',
  `is_read`     TINYINT(1) NOT NULL DEFAULT 0,
  `read_at`     TIMESTAMP NULL DEFAULT NULL,
  `sent_at`     TIMESTAMP NULL DEFAULT NULL,
  `expires_at`  TIMESTAMP NULL DEFAULT NULL,
  `created_at`  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_notif_user` (`user_id`, `is_read`),
  INDEX `idx_notif_type` (`type`),
  INDEX `idx_notif_created` (`created_at`),
  CONSTRAINT `fk_notif_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_notif_actor` FOREIGN KEY (`actor_id`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 20. PUSH TOKENS
-- FCM / APNS push notification tokens
-- ============================================================
CREATE TABLE `push_tokens` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id`     BIGINT UNSIGNED NOT NULL,
  `device_id`   VARCHAR(255) NOT NULL,
  `token`       VARCHAR(500) NOT NULL,
  `platform`    ENUM('fcm','apns','web_push') NOT NULL,
  `is_active`   TINYINT(1) NOT NULL DEFAULT 1,
  `created_at`  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_push_device` (`user_id`, `device_id`),
  INDEX `idx_push_user` (`user_id`),
  INDEX `idx_push_token` (`token`(191)),
  CONSTRAINT `fk_push_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 21. SUPPORT TICKETS
-- Customer support tickets
-- ============================================================
CREATE TABLE `support_tickets` (
  `id`                BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `ticket_number`     VARCHAR(20) NOT NULL UNIQUE,
  `user_id`           BIGINT UNSIGNED NOT NULL,
  `assigned_to`       BIGINT UNSIGNED NULL COMMENT 'Staff member handling this ticket',
  `subject`           VARCHAR(255) NOT NULL,
  `description`       TEXT NOT NULL,
  `status`            ENUM('open','in_progress','waiting_user','resolved','closed') NOT NULL DEFAULT 'open',
  `priority`          ENUM('low','medium','high','urgent') NOT NULL DEFAULT 'medium',
  `category`          ENUM('account','technical','billing','safety','abuse','feature_request','other') NOT NULL DEFAULT 'other',
  `resolution`        TEXT NULL,
  `resolved_at`       TIMESTAMP NULL DEFAULT NULL,
  `closed_at`         TIMESTAMP NULL DEFAULT NULL,
  `satisfaction_rating` TINYINT UNSIGNED NULL COMMENT '1-5 star rating',
  `created_at`        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_tickets_user` (`user_id`),
  INDEX `idx_tickets_assigned` (`assigned_to`),
  INDEX `idx_tickets_status` (`status`),
  INDEX `idx_tickets_priority` (`priority`),
  INDEX `idx_tickets_created` (`created_at`),
  CONSTRAINT `fk_tickets_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_tickets_assigned` FOREIGN KEY (`assigned_to`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 22. TICKET REPLIES
-- Messages within a support ticket thread
-- ============================================================
CREATE TABLE `ticket_replies` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `ticket_id`   BIGINT UNSIGNED NOT NULL,
  `author_id`   BIGINT UNSIGNED NOT NULL,
  `is_staff`    TINYINT(1) NOT NULL DEFAULT 0,
  `content`     TEXT NOT NULL,
  `attachments` JSON NULL,
  `is_internal` TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'Internal staff note, not visible to user',
  `created_at`  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_ticket_replies_ticket` (`ticket_id`),
  INDEX `idx_ticket_replies_author` (`author_id`),
  CONSTRAINT `fk_ticket_replies_ticket` FOREIGN KEY (`ticket_id`) REFERENCES `support_tickets`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_ticket_replies_author` FOREIGN KEY (`author_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 23. CONTENT REPORTS
-- Moderation team content reports
-- ============================================================
CREATE TABLE `content_reports` (
  `id`                  BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `report_number`       VARCHAR(20) NOT NULL UNIQUE,
  `reporter_id`         BIGINT UNSIGNED NOT NULL,
  `reported_user_id`    BIGINT UNSIGNED NOT NULL,
  `content_type`        ENUM('message','story','profile','comment','group') NOT NULL,
  `content_id`          BIGINT UNSIGNED NULL,
  `content_preview`     TEXT NULL,
  `reason`              ENUM('spam','harassment','hate_speech','violence','nudity','misinformation','copyright','self_harm','terrorism','other') NOT NULL,
  `additional_info`     TEXT NULL,
  `status`              ENUM('pending','reviewing','actioned','dismissed','escalated') NOT NULL DEFAULT 'pending',
  `reviewed_by`         BIGINT UNSIGNED NULL,
  `reviewed_at`         TIMESTAMP NULL,
  `action_taken`        ENUM('none','warning','content_removed','account_suspended','account_banned') NULL,
  `action_notes`        TEXT NULL,
  `created_at`          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_creports_reporter` (`reporter_id`),
  INDEX `idx_creports_reported` (`reported_user_id`),
  INDEX `idx_creports_status` (`status`),
  INDEX `idx_creports_created` (`created_at`),
  CONSTRAINT `fk_creports_reporter` FOREIGN KEY (`reporter_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_creports_reported` FOREIGN KEY (`reported_user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_creports_reviewer` FOREIGN KEY (`reviewed_by`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 24. ADMIN AUDIT LOGS
-- Complete history of all admin actions
-- ============================================================
CREATE TABLE `admin_audit_logs` (
  `id`              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `admin_id`        BIGINT UNSIGNED NOT NULL,
  `action`          VARCHAR(100) NOT NULL,
  `target_type`     ENUM('user','ticket','report','campaign','system','email_template','subscription') NULL,
  `target_id`       BIGINT UNSIGNED NULL,
  `description`     TEXT NOT NULL,
  `old_values`      JSON NULL,
  `new_values`      JSON NULL,
  `ip_address`      VARCHAR(45) NULL,
  `user_agent`      VARCHAR(500) NULL,
  `severity`        ENUM('info','warning','critical') NOT NULL DEFAULT 'info',
  `created_at`      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_audit_admin` (`admin_id`),
  INDEX `idx_audit_action` (`action`),
  INDEX `idx_audit_target` (`target_type`, `target_id`),
  INDEX `idx_audit_created` (`created_at`),
  CONSTRAINT `fk_audit_admin` FOREIGN KEY (`admin_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 25. EMAIL TEMPLATES
-- Pre-designed transactional & marketing email templates
-- ============================================================
CREATE TABLE `email_templates` (
  `id`              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `slug`            VARCHAR(100) NOT NULL UNIQUE,
  `name`            VARCHAR(255) NOT NULL,
  `category`        ENUM('transactional','marketing','notification','system') NOT NULL DEFAULT 'transactional',
  `subject`         VARCHAR(255) NOT NULL,
  `html_body`       LONGTEXT NOT NULL,
  `text_body`       TEXT NULL,
  `variables`       JSON NULL COMMENT 'Available {{variables}} list',
  `is_active`       TINYINT(1) NOT NULL DEFAULT 1,
  `is_system`       TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'System templates cannot be deleted',
  `created_by`      BIGINT UNSIGNED NULL,
  `last_edited_by`  BIGINT UNSIGNED NULL,
  `preview_text`    VARCHAR(255) NULL,
  `created_at`      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_templates_category` (`category`),
  INDEX `idx_templates_active` (`is_active`),
  CONSTRAINT `fk_templates_creator` FOREIGN KEY (`created_by`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_templates_editor` FOREIGN KEY (`last_edited_by`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 26. EMAIL CAMPAIGNS
-- Bulk email campaigns
-- ============================================================
CREATE TABLE `email_campaigns` (
  `id`                BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name`              VARCHAR(255) NOT NULL,
  `template_id`       BIGINT UNSIGNED NOT NULL,
  `subject_override`  VARCHAR(255) NULL,
  `created_by`        BIGINT UNSIGNED NOT NULL,
  `audience`          ENUM('all_users','active_30d','inactive_30d','premium','new_users','staff_only','custom') NOT NULL DEFAULT 'all_users',
  `custom_filter`     JSON NULL COMMENT 'Custom audience filter criteria',
  `recipient_count`   INT UNSIGNED NOT NULL DEFAULT 0,
  `status`            ENUM('draft','scheduled','sending','sent','paused','cancelled','failed') NOT NULL DEFAULT 'draft',
  `scheduled_at`      TIMESTAMP NULL DEFAULT NULL,
  `started_at`        TIMESTAMP NULL DEFAULT NULL,
  `completed_at`      TIMESTAMP NULL DEFAULT NULL,
  `sent_count`        INT UNSIGNED NOT NULL DEFAULT 0,
  `delivered_count`   INT UNSIGNED NOT NULL DEFAULT 0,
  `open_count`        INT UNSIGNED NOT NULL DEFAULT 0,
  `click_count`       INT UNSIGNED NOT NULL DEFAULT 0,
  `bounce_count`      INT UNSIGNED NOT NULL DEFAULT 0,
  `unsubscribe_count` INT UNSIGNED NOT NULL DEFAULT 0,
  `failure_reason`    TEXT NULL,
  `created_at`        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_campaigns_status` (`status`),
  INDEX `idx_campaigns_scheduled` (`scheduled_at`),
  INDEX `idx_campaigns_created_by` (`created_by`),
  CONSTRAINT `fk_campaigns_template` FOREIGN KEY (`template_id`) REFERENCES `email_templates`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_campaigns_creator` FOREIGN KEY (`created_by`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 27. CAMPAIGN RECIPIENTS
-- Individual recipient tracking per campaign
-- ============================================================
CREATE TABLE `campaign_recipients` (
  `id`            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `campaign_id`   BIGINT UNSIGNED NOT NULL,
  `user_id`       BIGINT UNSIGNED NOT NULL,
  `email`         VARCHAR(255) NOT NULL,
  `status`        ENUM('queued','sent','delivered','opened','clicked','bounced','unsubscribed','failed') NOT NULL DEFAULT 'queued',
  `sent_at`       TIMESTAMP NULL,
  `opened_at`     TIMESTAMP NULL,
  `clicked_at`    TIMESTAMP NULL,
  `bounce_reason` VARCHAR(255) NULL,
  `open_count`    TINYINT UNSIGNED NOT NULL DEFAULT 0,
  `click_count`   TINYINT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_campaign_recipient` (`campaign_id`, `user_id`),
  INDEX `idx_cr_campaign` (`campaign_id`),
  INDEX `idx_cr_user` (`user_id`),
  INDEX `idx_cr_status` (`status`),
  CONSTRAINT `fk_cr_campaign` FOREIGN KEY (`campaign_id`) REFERENCES `email_campaigns`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_cr_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 28. SYSTEM SETTINGS
-- Global platform configuration key-value store
-- ============================================================
CREATE TABLE `system_settings` (
  `id`            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `key`           VARCHAR(100) NOT NULL UNIQUE,
  `value`         TEXT NOT NULL,
  `type`          ENUM('string','integer','boolean','json','float') NOT NULL DEFAULT 'string',
  `group`         VARCHAR(50) NOT NULL DEFAULT 'general',
  `label`         VARCHAR(255) NOT NULL,
  `description`   TEXT NULL,
  `is_public`     TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'Exposed in public config API',
  `updated_by`    BIGINT UNSIGNED NULL,
  `created_at`    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_settings_group` (`group`),
  INDEX `idx_settings_key` (`key`),
  CONSTRAINT `fk_settings_updater` FOREIGN KEY (`updated_by`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 29. CREATOR ANALYTICS
-- Daily analytics snapshots for creator accounts
-- ============================================================
CREATE TABLE `creator_analytics` (
  `id`                BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id`           BIGINT UNSIGNED NOT NULL,
  `date`              DATE NOT NULL,
  `story_views`       INT UNSIGNED NOT NULL DEFAULT 0,
  `story_reactions`   INT UNSIGNED NOT NULL DEFAULT 0,
  `story_replies`     INT UNSIGNED NOT NULL DEFAULT 0,
  `profile_visits`    INT UNSIGNED NOT NULL DEFAULT 0,
  `new_followers`     INT UNSIGNED NOT NULL DEFAULT 0,
  `lost_followers`    INT UNSIGNED NOT NULL DEFAULT 0,
  `total_followers`   INT UNSIGNED NOT NULL DEFAULT 0,
  `messages_received` INT UNSIGNED NOT NULL DEFAULT 0,
  `link_clicks`       INT UNSIGNED NOT NULL DEFAULT 0,
  `reach`             INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Unique accounts that saw content',
  `impressions`       INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Total content views including repeats',
  `engagement_rate`   DECIMAL(5,2) NOT NULL DEFAULT 0.00,
  `created_at`        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_creator_analytics` (`user_id`, `date`),
  INDEX `idx_ca_user` (`user_id`),
  INDEX `idx_ca_date` (`date`),
  CONSTRAINT `fk_ca_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 30. CREATOR REVENUE
-- Monetization revenue tracking for creators
-- ============================================================
CREATE TABLE `creator_revenue` (
  `id`              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id`         BIGINT UNSIGNED NOT NULL,
  `type`            ENUM('tips','subscription','brand_deal','ad_revenue','merchandise') NOT NULL,
  `amount`          DECIMAL(10,2) NOT NULL,
  `currency`        CHAR(3) NOT NULL DEFAULT 'USD',
  `platform_fee`    DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  `net_amount`      DECIMAL(10,2) NOT NULL,
  `status`          ENUM('pending','processed','paid','refunded','disputed') NOT NULL DEFAULT 'pending',
  `description`     VARCHAR(255) NULL,
  `reference_id`    VARCHAR(255) NULL COMMENT 'Payment provider reference',
  `paid_at`         TIMESTAMP NULL DEFAULT NULL,
  `created_at`      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_revenue_user` (`user_id`),
  INDEX `idx_revenue_type` (`type`),
  INDEX `idx_revenue_status` (`status`),
  CONSTRAINT `fk_revenue_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 31. SUBSCRIPTIONS
-- Active user subscription records
-- ============================================================
CREATE TABLE `subscriptions` (
  `id`                BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id`           BIGINT UNSIGNED NOT NULL,
  `plan_id`           BIGINT UNSIGNED NOT NULL,
  `status`            ENUM('active','trialing','past_due','cancelled','expired','paused') NOT NULL DEFAULT 'active',
  `billing_cycle`     ENUM('monthly','annual') NOT NULL DEFAULT 'monthly',
  `amount`            DECIMAL(10,2) NOT NULL,
  `currency`          CHAR(3) NOT NULL DEFAULT 'USD',
  `payment_provider`  ENUM('stripe','apple_iap','google_play','paypal') NULL,
  `provider_sub_id`   VARCHAR(255) NULL COMMENT 'Provider subscription ID',
  `trial_ends_at`     TIMESTAMP NULL DEFAULT NULL,
  `current_period_start` TIMESTAMP NOT NULL,
  `current_period_end`   TIMESTAMP NOT NULL,
  `cancelled_at`      TIMESTAMP NULL DEFAULT NULL,
  `cancel_reason`     VARCHAR(255) NULL,
  `created_at`        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_subs_user` (`user_id`),
  INDEX `idx_subs_status` (`status`),
  INDEX `idx_subs_period_end` (`current_period_end`),
  CONSTRAINT `fk_subs_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 32. SUBSCRIPTION PLANS
-- Available subscription tiers
-- ============================================================
CREATE TABLE `subscription_plans` (
  `id`              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `slug`            VARCHAR(50) NOT NULL UNIQUE,
  `name`            VARCHAR(100) NOT NULL,
  `description`     TEXT NULL,
  `price_monthly`   DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  `price_annual`    DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  `currency`        CHAR(3) NOT NULL DEFAULT 'USD',
  `features`        JSON NOT NULL COMMENT 'Array of feature strings',
  `badge_color`     VARCHAR(7) NULL COMMENT 'Hex color for badge',
  `is_active`       TINYINT(1) NOT NULL DEFAULT 1,
  `sort_order`      TINYINT UNSIGNED NOT NULL DEFAULT 0,
  `created_at`      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_plans_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 33. VERIFICATION REQUESTS
-- Requests for account verification / creator status
-- ============================================================
CREATE TABLE `verification_requests` (
  `id`            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id`       BIGINT UNSIGNED NOT NULL,
  `type`          ENUM('verified','creator') NOT NULL,
  `reason`        TEXT NOT NULL,
  `website_url`   VARCHAR(500) NULL,
  `social_links`  JSON NULL,
  `documents`     JSON NULL COMMENT 'Uploaded document URLs',
  `status`        ENUM('pending','reviewing','approved','rejected') NOT NULL DEFAULT 'pending',
  `reviewed_by`   BIGINT UNSIGNED NULL,
  `reviewed_at`   TIMESTAMP NULL DEFAULT NULL,
  `rejection_reason` TEXT NULL,
  `created_at`    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_verif_user` (`user_id`),
  INDEX `idx_verif_status` (`status`),
  CONSTRAINT `fk_verif_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_verif_reviewer` FOREIGN KEY (`reviewed_by`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 34. APP VERSIONS
-- App version release management
-- ============================================================
CREATE TABLE `app_versions` (
  `id`                BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `version`           VARCHAR(20) NOT NULL UNIQUE,
  `build_number`      INT UNSIGNED NOT NULL,
  `platform`          ENUM('ios','android','both') NOT NULL DEFAULT 'both',
  `release_type`      ENUM('stable','beta','alpha','hotfix') NOT NULL DEFAULT 'stable',
  `release_notes`     TEXT NULL,
  `force_update`      TINYINT(1) NOT NULL DEFAULT 0,
  `minimum_version`   VARCHAR(20) NULL COMMENT 'Oldest version allowed to run',
  `download_url_ios`  VARCHAR(500) NULL,
  `download_url_android` VARCHAR(500) NULL,
  `is_active`         TINYINT(1) NOT NULL DEFAULT 1,
  `released_at`       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_versions_platform` (`platform`),
  INDEX `idx_versions_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 35. MEDIA UPLOADS
-- Central media file registry
-- ============================================================
CREATE TABLE `media_uploads` (
  `id`            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `uuid`          CHAR(36) NOT NULL UNIQUE DEFAULT (UUID()),
  `uploader_id`   BIGINT UNSIGNED NOT NULL,
  `context`       ENUM('avatar','cover','message','story','email_template','support_attachment','other') NOT NULL,
  `file_name`     VARCHAR(255) NOT NULL,
  `file_path`     VARCHAR(500) NOT NULL,
  `url`           VARCHAR(500) NOT NULL,
  `thumbnail_url` VARCHAR(500) NULL,
  `mime_type`     VARCHAR(100) NOT NULL,
  `file_size`     INT UNSIGNED NOT NULL COMMENT 'Size in bytes',
  `width`         INT NULL,
  `height`        INT NULL,
  `duration`      INT NULL,
  `is_public`     TINYINT(1) NOT NULL DEFAULT 1,
  `storage_disk`  VARCHAR(50) NOT NULL DEFAULT 'public',
  `created_at`    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_media_uploader` (`uploader_id`),
  INDEX `idx_media_context` (`context`),
  INDEX `idx_media_uuid` (`uuid`),
  CONSTRAINT `fk_media_uploader` FOREIGN KEY (`uploader_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 37. STREAKS
-- Daily streak tracking per friendship pair
-- ============================================================
CREATE TABLE `streaks` (
  `id`              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id`         BIGINT UNSIGNED NOT NULL,
  `friend_id`       BIGINT UNSIGNED NOT NULL,
  `streak_days`     INT UNSIGNED NOT NULL DEFAULT 1,
  `last_snap_at`    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `expires_at`      TIMESTAMP NOT NULL,
  `fire_emoji_sent` TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'Whether the fire emoji warning was sent',
  `created_at`      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_streaks_pair` (`user_id`, `friend_id`),
  INDEX `idx_streaks_user` (`user_id`),
  INDEX `idx_streaks_expires` (`expires_at`),
  CONSTRAINT `fk_streaks_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_streaks_friend` FOREIGN KEY (`friend_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 38. ACHIEVEMENTS
-- Platform achievement/badge definitions
-- ============================================================
CREATE TABLE `achievements` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `slug`        VARCHAR(100) NOT NULL UNIQUE,
  `name`        VARCHAR(100) NOT NULL,
  `description` TEXT NOT NULL,
  `icon`        VARCHAR(10) NOT NULL COMMENT 'Emoji icon',
  `category`    ENUM('streak','social','creator','engagement','special') NOT NULL DEFAULT 'engagement',
  `threshold`   INT UNSIGNED NOT NULL DEFAULT 1 COMMENT 'Numeric value required to earn this achievement',
  `badge_color` VARCHAR(7) NULL,
  `is_active`   TINYINT(1) NOT NULL DEFAULT 1,
  `created_at`  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_achievements_category` (`category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 39. USER ACHIEVEMENTS
-- Achievement records earned by users
-- ============================================================
CREATE TABLE `user_achievements` (
  `id`             BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id`        BIGINT UNSIGNED NOT NULL,
  `achievement_id` BIGINT UNSIGNED NOT NULL,
  `earned_at`      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `notified_at`    TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_achievement` (`user_id`, `achievement_id`),
  INDEX `idx_user_achievements_user` (`user_id`),
  CONSTRAINT `fk_user_achievements_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_user_achievements_ach` FOREIGN KEY (`achievement_id`) REFERENCES `achievements`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 40. USER WARNINGS
-- Moderation warnings issued to users
-- ============================================================
CREATE TABLE `user_warnings` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id`     BIGINT UNSIGNED NOT NULL,
  `issued_by`   BIGINT UNSIGNED NOT NULL COMMENT 'Staff member who issued the warning',
  `reason`      VARCHAR(255) NOT NULL,
  `details`     TEXT NULL,
  `report_id`   BIGINT UNSIGNED NULL COMMENT 'Related content report if any',
  `expires_at`  TIMESTAMP NULL DEFAULT NULL COMMENT 'NULL = permanent warning on record',
  `is_active`   TINYINT(1) NOT NULL DEFAULT 1,
  `created_at`  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_warnings_user` (`user_id`),
  INDEX `idx_warnings_issued_by` (`issued_by`),
  CONSTRAINT `fk_warnings_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_warnings_staff` FOREIGN KEY (`issued_by`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_warnings_report` FOREIGN KEY (`report_id`) REFERENCES `content_reports`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 41. GROUP CHATS
-- Group conversation metadata
-- ============================================================
CREATE TABLE `group_chats` (
  `id`            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `uuid`          CHAR(36) NOT NULL UNIQUE DEFAULT (UUID()),
  `name`          VARCHAR(100) NOT NULL,
  `description`   TEXT NULL,
  `avatar_url`    VARCHAR(500) NULL,
  `created_by`    BIGINT UNSIGNED NOT NULL,
  `is_public`     TINYINT(1) NOT NULL DEFAULT 0,
  `invite_link`   VARCHAR(100) NULL UNIQUE,
  `max_members`   INT UNSIGNED NOT NULL DEFAULT 50,
  `member_count`  INT UNSIGNED NOT NULL DEFAULT 1,
  `last_message_at` TIMESTAMP NULL DEFAULT NULL,
  `created_at`    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_groups_created_by` (`created_by`),
  INDEX `idx_groups_last_message` (`last_message_at`),
  CONSTRAINT `fk_groups_creator` FOREIGN KEY (`created_by`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 42. GROUP CHAT MEMBERS
-- Members within a group chat
-- ============================================================
CREATE TABLE `group_chat_members` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `group_id`    BIGINT UNSIGNED NOT NULL,
  `user_id`     BIGINT UNSIGNED NOT NULL,
  `role`        ENUM('member','admin','owner') NOT NULL DEFAULT 'member',
  `muted_until` TIMESTAMP NULL DEFAULT NULL,
  `joined_at`   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `left_at`     TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_group_member` (`group_id`, `user_id`),
  INDEX `idx_group_members_user` (`user_id`),
  CONSTRAINT `fk_group_members_group` FOREIGN KEY (`group_id`) REFERENCES `group_chats`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_group_members_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 43. OTP VERIFICATIONS
-- One-time password codes for auth flows
-- ============================================================
CREATE TABLE `otp_verifications` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `identifier`  VARCHAR(255) NOT NULL COMMENT 'Email or phone number',
  `type`        ENUM('email','phone') NOT NULL DEFAULT 'email',
  `purpose`     ENUM('register','login','password_reset','change_email','change_phone') NOT NULL,
  `code`        VARCHAR(10) NOT NULL,
  `attempts`    TINYINT UNSIGNED NOT NULL DEFAULT 0,
  `is_used`     TINYINT(1) NOT NULL DEFAULT 0,
  `expires_at`  TIMESTAMP NOT NULL,
  `created_at`  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_otp_identifier` (`identifier`),
  INDEX `idx_otp_expires` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 44. HELP CATEGORIES
-- Support / help centre category tree
-- ============================================================
CREATE TABLE `help_categories` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `slug`        VARCHAR(100) NOT NULL UNIQUE,
  `name`        VARCHAR(100) NOT NULL,
  `description` TEXT NULL,
  `icon`        VARCHAR(10) NULL,
  `parent_id`   BIGINT UNSIGNED NULL COMMENT 'NULL = top-level category',
  `sort_order`  TINYINT UNSIGNED NOT NULL DEFAULT 0,
  `is_active`   TINYINT(1) NOT NULL DEFAULT 1,
  `created_at`  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_help_cats_parent` (`parent_id`),
  CONSTRAINT `fk_help_cats_parent` FOREIGN KEY (`parent_id`) REFERENCES `help_categories`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 45. KNOWLEDGE BASE ARTICLES
-- Help centre knowledge base content
-- ============================================================
CREATE TABLE `kb_articles` (
  `id`            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `category_id`   BIGINT UNSIGNED NOT NULL,
  `slug`          VARCHAR(255) NOT NULL UNIQUE,
  `title`         VARCHAR(255) NOT NULL,
  `content`       LONGTEXT NOT NULL COMMENT 'Markdown content',
  `excerpt`       VARCHAR(500) NULL,
  `status`        ENUM('draft','published','archived') NOT NULL DEFAULT 'draft',
  `is_featured`   TINYINT(1) NOT NULL DEFAULT 0,
  `view_count`    INT UNSIGNED NOT NULL DEFAULT 0,
  `helpful_yes`   INT UNSIGNED NOT NULL DEFAULT 0,
  `helpful_no`    INT UNSIGNED NOT NULL DEFAULT 0,
  `author_id`     BIGINT UNSIGNED NULL,
  `created_at`    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_kb_category` (`category_id`),
  INDEX `idx_kb_status` (`status`),
  INDEX `idx_kb_featured` (`is_featured`),
  FULLTEXT INDEX `ft_kb_title_content` (`title`, `content`),
  CONSTRAINT `fk_kb_category` FOREIGN KEY (`category_id`) REFERENCES `help_categories`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_kb_author` FOREIGN KEY (`author_id`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 46. KB ARTICLE FEEDBACK
-- User helpful/not helpful votes on articles
-- ============================================================
CREATE TABLE `kb_article_feedback` (
  `id`         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `article_id` BIGINT UNSIGNED NOT NULL,
  `user_id`    BIGINT UNSIGNED NULL COMMENT 'NULL = anonymous',
  `is_helpful` TINYINT(1) NOT NULL,
  `comment`    TEXT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_kb_feedback_article` (`article_id`),
  CONSTRAINT `fk_kb_feedback_article` FOREIGN KEY (`article_id`) REFERENCES `kb_articles`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 47. HELP SEARCH LOGS
-- Analytics on help centre search queries
-- ============================================================
CREATE TABLE `help_search_logs` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id`     BIGINT UNSIGNED NULL COMMENT 'NULL = unauthenticated',
  `query`       VARCHAR(500) NOT NULL,
  `results`     TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Number of results returned',
  `clicked_id`  BIGINT UNSIGNED NULL COMMENT 'Article clicked from results',
  `created_at`  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_help_search_user` (`user_id`),
  INDEX `idx_help_search_query` (`query`(100))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 48. REACTION TYPES
-- Configurable message/story reaction emoji registry
-- ============================================================
CREATE TABLE `reaction_types` (
  `id`         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `slug`       VARCHAR(50) NOT NULL UNIQUE,
  `emoji`      VARCHAR(10) NOT NULL,
  `label`      VARCHAR(50) NOT NULL,
  `sort_order` TINYINT UNSIGNED NOT NULL DEFAULT 0,
  `is_active`  TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 20-B. NOTIFICATION PREFERENCES
-- Per-user notification toggle settings
-- ============================================================
CREATE TABLE `notification_preferences` (
  `id`                       BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id`                  BIGINT UNSIGNED NOT NULL UNIQUE,
  `new_message`              TINYINT(1) NOT NULL DEFAULT 1,
  `friend_request`           TINYINT(1) NOT NULL DEFAULT 1,
  `friend_accepted`          TINYINT(1) NOT NULL DEFAULT 1,
  `story_view`               TINYINT(1) NOT NULL DEFAULT 1,
  `story_reaction`           TINYINT(1) NOT NULL DEFAULT 1,
  `streak_reminder`          TINYINT(1) NOT NULL DEFAULT 1,
  `streak_achievement`       TINYINT(1) NOT NULL DEFAULT 1,
  `mention`                  TINYINT(1) NOT NULL DEFAULT 1,
  `group_invite`             TINYINT(1) NOT NULL DEFAULT 1,
  `marketing_emails`         TINYINT(1) NOT NULL DEFAULT 1,
  `security_alerts`          TINYINT(1) NOT NULL DEFAULT 1,
  `vibechat_plus_offers`     TINYINT(1) NOT NULL DEFAULT 1,
  `push_enabled`             TINYINT(1) NOT NULL DEFAULT 1,
  `email_enabled`            TINYINT(1) NOT NULL DEFAULT 1,
  `sms_enabled`              TINYINT(1) NOT NULL DEFAULT 0,
  `quiet_hours_start`        TIME NULL DEFAULT NULL,
  `quiet_hours_end`          TIME NULL DEFAULT NULL,
  `updated_at`               TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_notif_prefs_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- DEFAULT SEED DATA
-- ============================================================

-- Default subscription plans
INSERT INTO `subscription_plans` (`slug`, `name`, `description`, `price_monthly`, `price_annual`, `features`, `badge_color`, `sort_order`) VALUES
('free',      'VibeChat Free',    'Core messaging features',              0.00,   0.00,    '["Unlimited messaging","Stories (24h)","5 Premium sticker packs","Basic camera filters","Friend limit: 1000"]', NULL,      0),
('plus',      'VibeChat+',        'Premium social features',              4.99,   47.99,   '["Everything in Free","Custom chat themes","Exclusive sticker packs","HD photo/video sharing","VibeChat+ badge","No ads","Priority support"]', '#8B5CF6', 1),
('creator',   'VibeChat Creator', 'Full creator monetization toolkit',    9.99,   95.99,   '["Everything in VibeChat+","Creator analytics dashboard","Revenue monetization","Verified creator badge","Custom link in bio","Priority discovery","Dedicated support"]', '#EC4899', 2),
('business',  'VibeChat Business','Enterprise team & brand accounts',     29.99,  287.99,  '["Everything in Creator","Team accounts (up to 10)","Brand dashboard","API access","Custom integrations","SLA support","Dedicated account manager"]', '#06B6D4', 3);

-- Default system settings
INSERT INTO `system_settings` (`key`, `value`, `type`, `group`, `label`, `description`, `is_public`) VALUES
('maintenance_mode',           'false',  'boolean', 'general',  'Maintenance Mode',               'Put the app in maintenance mode',                                   0),
('registration_enabled',       'true',   'boolean', 'general',  'New User Registration',          'Allow new users to register',                                       1),
('max_story_duration_seconds', '15',     'integer', 'content',  'Max Story Duration',             'Maximum story video duration in seconds',                           0),
('max_group_members',          '50',     'integer', 'messaging','Max Group Members',              'Maximum participants in a group chat',                               1),
('media_max_size_mb',          '100',    'integer', 'content',  'Max Upload Size (MB)',           'Maximum file upload size in megabytes',                             1),
('story_expiry_hours',         '24',     'integer', 'content',  'Story Expiry Hours',             'How long stories last before auto-deletion',                        1),
('streak_reminder_hours',      '20',     'integer', 'features', 'Streak Reminder Hours',          'Send streak reminder after X hours of inactivity',                  0),
('platform_fee_percent',       '20',     'float',   'revenue',  'Platform Revenue Fee %',         'Percentage fee taken from creator revenue',                         0),
('free_chat_limit_daily',      '0',      'integer', 'messaging','Daily Message Limit (Free)',     'Message limit for free users. 0 = unlimited',                       0),
('ads_enabled',                'true',   'boolean', 'monetization', 'Enable Ads',               'Show ads to free tier users',                                       0),
('creator_applications_open',  'true',   'boolean', 'features', 'Creator Applications Open',     'Allow users to apply for creator status',                           1),
('min_app_version_ios',        '1.0.0',  'string',  'versioning','Min iOS App Version',           'Minimum iOS version allowed to connect',                            1),
('min_app_version_android',    '1.0.0',  'string',  'versioning','Min Android App Version',       'Minimum Android version allowed to connect',                        1);

-- ============================================================
-- 36. OTP VERIFICATIONS
-- Stores email/phone OTP codes for registration and password reset
-- ============================================================
CREATE TABLE `otp_verifications` (
  `id`            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `identifier`    VARCHAR(255) NOT NULL COMMENT 'email address or phone number',
  `type`          ENUM('email','phone') NOT NULL DEFAULT 'email',
  `purpose`       ENUM('registration','password_reset','login_2fa','phone_change','email_change') NOT NULL,
  `code`          VARCHAR(10) NOT NULL,
  `attempts`      TINYINT UNSIGNED NOT NULL DEFAULT 0,
  `max_attempts`  TINYINT UNSIGNED NOT NULL DEFAULT 5,
  `expires_at`    TIMESTAMP NOT NULL,
  `verified_at`   TIMESTAMP NULL DEFAULT NULL,
  `ip_address`    VARCHAR(45) NULL,
  `created_at`    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_otp_identifier` (`identifier`),
  INDEX `idx_otp_expires` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 37. HELP CENTER CATEGORIES
-- Top-level categories for the help center
-- ============================================================
CREATE TABLE `help_categories` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `slug`        VARCHAR(100) NOT NULL UNIQUE,
  `name`        VARCHAR(100) NOT NULL,
  `description` TEXT NULL,
  `icon`        VARCHAR(50) NULL COMMENT 'Material icon name',
  `color`       VARCHAR(20) NULL COMMENT 'Hex color',
  `sort_order`  INT UNSIGNED NOT NULL DEFAULT 0,
  `is_active`   TINYINT(1) NOT NULL DEFAULT 1,
  `article_count` INT UNSIGNED NOT NULL DEFAULT 0,
  `created_at`  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 38. KNOWLEDGE BASE ARTICLES
-- Help center articles and FAQs
-- ============================================================
CREATE TABLE `kb_articles` (
  `id`            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `category_id`   BIGINT UNSIGNED NOT NULL,
  `author_id`     BIGINT UNSIGNED NULL COMMENT 'Staff user who wrote the article',
  `slug`          VARCHAR(200) NOT NULL UNIQUE,
  `title`         VARCHAR(300) NOT NULL,
  `content`       LONGTEXT NOT NULL COMMENT 'Markdown or HTML content',
  `excerpt`       TEXT NULL,
  `status`        ENUM('draft','published','archived') NOT NULL DEFAULT 'draft',
  `is_featured`   TINYINT(1) NOT NULL DEFAULT 0,
  `view_count`    INT UNSIGNED NOT NULL DEFAULT 0,
  `helpful_count` INT UNSIGNED NOT NULL DEFAULT 0,
  `not_helpful_count` INT UNSIGNED NOT NULL DEFAULT 0,
  `tags`          JSON NULL,
  `meta_title`    VARCHAR(255) NULL,
  `meta_description` VARCHAR(500) NULL,
  `published_at`  TIMESTAMP NULL DEFAULT NULL,
  `created_at`    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_kb_category` (`category_id`),
  INDEX `idx_kb_status` (`status`),
  INDEX `idx_kb_featured` (`is_featured`),
  FULLTEXT INDEX `ft_kb_search` (`title`, `content`, `excerpt`),
  CONSTRAINT `fk_kb_category` FOREIGN KEY (`category_id`) REFERENCES `help_categories`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_kb_author` FOREIGN KEY (`author_id`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 39. KB ARTICLE FEEDBACK
-- User feedback on help articles (helpful / not helpful)
-- ============================================================
CREATE TABLE `kb_article_feedback` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `article_id`  BIGINT UNSIGNED NOT NULL,
  `user_id`     BIGINT UNSIGNED NULL,
  `ip_address`  VARCHAR(45) NULL,
  `is_helpful`  TINYINT(1) NOT NULL,
  `comment`     TEXT NULL,
  `created_at`  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_article_feedback` (`article_id`, `user_id`),
  CONSTRAINT `fk_feedback_article` FOREIGN KEY (`article_id`) REFERENCES `kb_articles`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 40. HELP CENTER SEARCH LOGS
-- Logs what users search for — useful for identifying content gaps
-- ============================================================
CREATE TABLE `help_search_logs` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id`     BIGINT UNSIGNED NULL,
  `query`       VARCHAR(500) NOT NULL,
  `results_count` INT UNSIGNED NOT NULL DEFAULT 0,
  `clicked_article_id` BIGINT UNSIGNED NULL,
  `created_at`  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_search_query` (`query`(191)),
  INDEX `idx_search_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- SEED DATA — Help Center Categories
-- ============================================================
INSERT INTO `help_categories` (`slug`, `name`, `description`, `icon`, `color`, `sort_order`) VALUES
('getting-started',   'Getting Started',       'New to VibeChat? Start here.',                         'rocket_launch',        '#8B5CF6', 0),
('account-settings',  'Account & Settings',    'Manage your profile, privacy, and security.',          'manage_accounts',      '#06B6D4', 1),
('messaging',         'Messaging & Chats',     'Everything about sending messages and group chats.',   'chat_bubble',          '#10B981', 2),
('stories',           'Stories & Camera',      'How to create, share, and view stories.',              'auto_stories',         '#F59E0B', 3),
('friends',           'Friends & Connections', 'Adding friends, streaks, and managing connections.',   'people',               '#EC4899', 4),
('subscription',      'VibeChat+ & Plans',     'VibeChat+ features, billing, and upgrades.',           'workspace_premium',    '#8B5CF6', 5),
('safety',            'Safety & Privacy',      'Blocking, reporting, and staying safe online.',        'shield',               '#EF4444', 6),
('creator',           'Creator Tools',         'Monetization, analytics, and creator dashboard.',      'stars',                '#F59E0B', 7),
('technical',         'Technical & Bugs',      'App performance, bugs, and device compatibility.',     'bug_report',           '#6B7280', 8),
('billing',           'Billing & Payments',    'Subscription charges, refunds, and payment methods.',  'credit_card',          '#10B981', 9);


-- ============================================================
-- SEED DATA — Knowledge Base Articles
-- ============================================================
INSERT INTO `kb_articles` (`category_id`, `slug`, `title`, `content`, `excerpt`, `status`, `is_featured`) VALUES
(1, 'what-is-vibechat',
 'What is VibeChat?',
 '# What is VibeChat?\n\nVibeChat is a premium social messaging platform designed for real connections. Share ephemeral stories, send snaps, maintain streaks with friends, and discover creators all in one place.\n\n## Key Features\n- **Real-time Messaging** — Send messages, photos, and videos instantly\n- **Stories** — Share moments that disappear after 24 hours\n- **Streaks** — Keep your daily streak alive with friends\n- **Creator Platform** — Follow and support your favourite creators\n- **VibeChat+** — Premium features for power users\n\n## Getting Started\n1. Download VibeChat from the App Store or Google Play\n2. Create your account\n3. Add friends using their username\n4. Start vibing!',
 'Learn what VibeChat is and what makes it special.',
 'published', 1),

(1, 'how-to-create-account',
 'How to Create a VibeChat Account',
 '# Creating Your Account\n\nSign up is quick and takes less than 2 minutes.\n\n## Steps\n1. Open the VibeChat app\n2. Tap **Sign Up**\n3. Enter your name, birthday, and choose a username\n4. Create a secure password (min. 8 characters)\n5. Verify your email or phone number\n6. You''re in!\n\n## Tips\n- Your username is unique — choose one you''ll love\n- You can change your display name anytime\n- Use a strong password with letters, numbers, and symbols',
 'Step-by-step guide to creating your VibeChat account.',
 'published', 1),

(2, 'change-username',
 'How to Change Your Username',
 '# Changing Your Username\n\nYou can change your username once every 30 days.\n\n## Steps\n1. Go to your **Profile** tab\n2. Tap **Edit Profile**\n3. Tap on your username\n4. Enter your new username\n5. Tap **Save**\n\n## Rules\n- Usernames must be 3–30 characters\n- Only letters, numbers, periods, and underscores are allowed\n- Usernames are not case-sensitive',
 'Learn how to change your VibeChat username.',
 'published', 0),

(2, 'enable-two-factor-auth',
 'How to Enable Two-Factor Authentication',
 '# Two-Factor Authentication (2FA)\n\nAdding 2FA makes your account significantly more secure.\n\n## How to Enable\n1. Go to **Profile** → **Settings** → **Security**\n2. Tap **Two-Factor Authentication**\n3. Choose **SMS** or **Authenticator App**\n4. Follow the setup steps\n5. Save your recovery codes in a safe place\n\n## Why Use 2FA?\n- Protects your account even if your password is compromised\n- Required for VibeChat+ and Creator accounts\n- Adds a second verification step on new device logins',
 'Protect your account with two-factor authentication.',
 'published', 1),

(3, 'how-to-send-message',
 'How to Send a Message',
 '# Sending Messages\n\nSending a message on VibeChat is simple.\n\n## Direct Message\n1. Tap the **Chats** tab\n2. Tap the **compose** icon (top right)\n3. Search for a friend\n4. Type your message and tap send\n\n## Supported Content\n- Text messages\n- Photos and videos\n- Voice messages\n- Stickers and GIFs\n- Location sharing',
 'Learn how to send messages and share media on VibeChat.',
 'published', 0),

(4, 'how-to-post-story',
 'How to Post a Story',
 '# Posting a Story\n\nStories are visible to your friends for 24 hours.\n\n## Steps\n1. Tap the **camera** button (centre FAB)\n2. Take a photo or video, or upload from gallery\n3. Add filters, stickers, or text\n4. Tap **Post to My Story**\n\n## Story Types\n- **Photo** — Standard photo story\n- **Video** — Up to 15 seconds\n- **Text** — Text on a colour background\n\n## Privacy\nYou can control who sees your stories in **Settings → Privacy → Story Visibility**.',
 'Learn how to create and share stories on VibeChat.',
 'published', 0),

(5, 'how-to-add-friends',
 'How to Add Friends',
 '# Adding Friends\n\nConnect with people you know on VibeChat.\n\n## Methods\n1. **Username Search** — Search their exact username in the Discover tab\n2. **QR Code** — Scan their VibeChat QR code\n3. **Suggested Friends** — Based on mutual connections\n\n## After Sending a Request\nThe person receives a notification. Once they accept, you become friends and can message each other.',
 'Different ways to find and add friends on VibeChat.',
 'published', 0),

(6, 'what-is-vibechat-plus',
 'What is VibeChat+?',
 '# VibeChat+\n\nVibeChat+ is our premium subscription with exclusive features.\n\n## What You Get\n- Custom chat themes\n- Exclusive sticker packs\n- HD photo and video sharing\n- VibeChat+ badge on your profile\n- No ads\n- Priority customer support\n\n## Pricing\n- Monthly: $4.99/month\n- Annual: $47.99/year (save 20%)\n\n## How to Subscribe\n1. Go to **Profile** → **VibeChat+**\n2. Choose your plan\n3. Complete payment\n4. Enjoy your perks!',
 'Everything you need to know about VibeChat+ subscription.',
 'published', 1),

(7, 'how-to-block-someone',
 'How to Block Someone',
 '# Blocking a User\n\nBlocking prevents someone from contacting you or seeing your content.\n\n## Steps\n1. Go to their profile\n2. Tap the **three dots** (⋮) in the top right\n3. Tap **Block [Username]**\n4. Confirm\n\n## What Happens When You Block Someone\n- They cannot send you messages\n- They cannot see your stories\n- You disappear from their friends list\n- They are not notified that you blocked them',
 'Learn how to block users on VibeChat.',
 'published', 0),

(9, 'app-not-loading',
 'App Not Loading or Crashing',
 '# App Not Loading\n\nIf VibeChat is not loading or keeps crashing, try these steps:\n\n## Quick Fixes\n1. **Force close** the app and reopen it\n2. **Check your internet connection** — try switching between WiFi and mobile data\n3. **Restart your device**\n4. **Update the app** — make sure you have the latest version\n5. **Clear app cache** (Android: Settings → Apps → VibeChat → Clear Cache)\n\n## Still Not Working?\nContact our support team via **Profile → Settings → Help & Support** and describe the issue.',
 'Troubleshoot VibeChat loading and crashing issues.',
 'published', 0);


-- ============================================================
-- SEED DATA — Email Campaigns (preset campaigns)
-- ============================================================
INSERT INTO `email_campaigns` (`template_id`, `name`, `subject`, `audience`, `status`, `scheduled_at`, `sent_at`, `total_recipients`, `delivered_count`, `opened_count`, `clicked_count`) VALUES
(1,  'Welcome Series — Day 1',               'Welcome to VibeChat! 🎉',                    'new_users',        'sent',      NULL,                      '2026-01-01 09:00:00', 48302,  47891,  31248,  14203),
(1,  'Welcome Series — Day 3',               'Your VibeChat journey starts now ✨',         'new_users',        'sent',      NULL,                      '2026-01-03 09:00:00', 45820,  45301,  28473,  12103),
(2,  'Email Verification Reminder',           'Please verify your email address',           'unverified',       'sent',      NULL,                      '2026-01-15 10:00:00', 12048,  11987,   8732,   5420),
(4,  'New Friend Request Digest',             'You have new friend requests! 👋',           'active_30d',       'sent',      NULL,                      '2026-02-01 12:00:00', 89432,  88201,  41023,  22840),
(5,  'VibeChat+ Spring Sale',                 '50% off VibeChat+ — Today Only! 🌸',         'free_users',       'sent',      NULL,                      '2026-03-20 08:00:00', 201034, 198430,  91023,  48302),
(5,  'VibeChat+ Summer Launch',               'Summer is here — upgrade your vibe ☀️',      'free_users',       'sent',      NULL,                      '2026-06-01 09:00:00', 218903, 216420, 102034,  51230),
(6,  'Win-Back — 30 Day Inactive Users',      'We miss you! Come back to VibeChat 💜',      'inactive_30d',     'sent',      NULL,                      '2026-02-15 10:00:00', 34021,  33102,  12034,   4302),
(6,  'Win-Back — 60 Day Inactive Users',      'It''s been a while... your streak awaits!',  'inactive_30d',     'sent',      NULL,                      '2026-04-01 10:00:00', 18420,  17903,   5420,   1840),
(7,  'App Version 2.0 Announcement',          'VibeChat 2.0 is here — new features inside!','all_users',        'sent',      NULL,                      '2026-05-01 08:00:00', 312048, 308431, 198032,  89043),
(8,  'Streak Achievement — 100 Days',         '100 day streak! You''re on fire 🔥',         'active_30d',       'sent',      NULL,                      '2026-03-10 12:00:00', 8420,    8301,   7203,   4102),
(8,  'Streak Achievement — 365 Days',         '365 days! Legendary streaker 🏆',            'active_30d',       'sent',      NULL,                      '2026-01-20 12:00:00',  1203,   1198,   1150,    892),
(5,  'Creator Plan Launch',                   'Introducing VibeChat Creator — Monetize now!','free_users',      'sent',      NULL,                      '2026-04-15 09:00:00', 180302, 178420,  84032,  39403),
(1,  'Q2 Newsletter — Platform Updates',      'What''s new at VibeChat this quarter',       'all_users',        'sent',      NULL,                      '2026-04-01 10:00:00', 320104, 316892, 142034,  62304),
(5,  'VibeChat+ July Promo',                  'July Special: Get VibeChat+ for $2.99/mo!',  'free_users',       'scheduled', '2026-07-01 08:00:00',     NULL,                  0,       0,       0,       0),
(6,  'Summer Re-engagement Campaign',         'Summer plans? Make memories on VibeChat 🌊', 'inactive_30d',     'scheduled', '2026-07-10 10:00:00',     NULL,                  0,       0,       0,       0),
(7,  'App Version 2.1 Update',                'VibeChat 2.1: Performance & new features',   'all_users',        'draft',     NULL,                      NULL,                  0,       0,       0,       0);


-- Default reaction types
INSERT INTO `reaction_types` (`slug`, `emoji`, `label`, `sort_order`) VALUES
('love',      '❤️',  'Love',      0),
('fire',      '🔥',  'Fire',      1),
('laugh',     '😂',  'Laugh',     2),
('wow',       '😮',  'Wow',       3),
('sad',       '😢',  'Sad',       4),
('vibe',      '✨',  'Vibe',      5),
('hype',      '🙌',  'Hype',      6),
('broken',    '💔',  'Broken',    7);

-- Default achievements
INSERT INTO `achievements` (`slug`, `name`, `description`, `icon`, `category`, `threshold`, `badge_color`) VALUES
('first_message',       'First Message',          'Sent your first message',                           '💬', 'engagement', 1,    '#8B5CF6'),
('streak_7',            '7-Day Streak',           'Maintained a 7-day streak with a friend',           '🔥', 'streak',     7,    '#F97316'),
('streak_30',           '30-Day Streak',          'Maintained a 30-day streak with a friend',          '🔥', 'streak',     30,   '#EF4444'),
('streak_100',          '100-Day Streak',         'A 100-day streak — you''re dedicated!',             '💯', 'streak',     100,  '#EC4899'),
('streak_365',          'Legendary Streaker',     '365 days in a row — absolutely legendary',          '🏆', 'streak',     365,  '#F59E0B'),
('first_story',         'Storyteller',            'Posted your first story',                           '📸', 'engagement', 1,    '#06B6D4'),
('friends_10',          'Social Butterfly',       'Made 10 friends on VibeChat',                      '🦋', 'social',     10,   '#10B981'),
('friends_50',          'Connector',              'Made 50 friends on VibeChat',                      '🌐', 'social',     50,   '#8B5CF6'),
('friends_100',         'Community Builder',      'Made 100 friends on VibeChat',                     '🏙️', 'social',     100,  '#EC4899'),
('creator_1k_views',    'Rising Creator',         'Reached 1,000 story views',                        '⭐', 'creator',    1000, '#F59E0B'),
('creator_10k_views',   'Popular Creator',        'Reached 10,000 story views',                       '🌟', 'creator',    10000,'#EC4899'),
('creator_100k_views',  'Viral Creator',          'Reached 100,000 story views',                      '🚀', 'creator',    100000,'#EF4444'),
('first_reaction',      'Spread the Vibes',       'Reacted to someone''s story for the first time',   '✨', 'engagement', 1,    '#8B5CF6'),
('verified_badge',      'Verified',               'Received the VibeChat verified badge',              '✅', 'special',    1,    '#06B6D4'),
('vibechat_plus',       'VibeChat+ Member',       'Subscribed to VibeChat+',                          '💜', 'special',    1,    '#8B5CF6'),
('early_adopter',       'Early Adopter',          'Joined VibeChat in its first year',                 '🎖️', 'special',    1,    '#F59E0B');

-- Default help categories
INSERT INTO `help_categories` (`slug`, `name`, `description`, `icon`, `sort_order`) VALUES
('getting-started',   'Getting Started',       'New to VibeChat? Start here',                    '🚀', 0),
('account',           'Account & Profile',     'Managing your account, username, and profile',   '👤', 1),
('messaging',         'Messaging & Chats',     'Sending messages, media, and managing chats',    '💬', 2),
('stories',           'Stories',               'Creating, sharing, and managing your stories',   '📸', 3),
('friends',           'Friends & Social',      'Adding friends, blocking, and privacy controls', '👥', 4),
('subscriptions',     'VibeChat+ & Billing',   'Subscriptions, payments, and billing support',   '💳', 5),
('security',          'Safety & Security',     '2FA, suspicious activity, and account security', '🔒', 6),
('creators',          'Creator Tools',         'Monetisation, analytics, and creator features',  '⭐', 7),
('technical',         'Technical Support',     'App issues, bugs, and troubleshooting',          '🔧', 8),
('privacy',           'Privacy & Safety',      'Reporting, privacy settings, and data controls', '🛡️', 9);

-- Default knowledge base articles
INSERT INTO `kb_articles` (`category_id`, `slug`, `title`, `content`, `excerpt`, `status`, `is_featured`) VALUES
(1, 'how-to-change-username',
 'Changing Your Username',
 '# Changing Your Username\n\nYou can change your username once every 30 days.\n\n## Steps\n1. Go to your **Profile** tab\n2. Tap **Edit Profile**\n3. Tap on your username\n4. Enter your new username\n5. Tap **Save**\n\n## Rules\n- Usernames must be 3–30 characters\n- Only letters, numbers, periods, and underscores are allowed\n- Usernames are not case-sensitive',
 'Learn how to change your VibeChat username.',
 'published', 0),

(6, 'enable-two-factor-auth',
 'How to Enable Two-Factor Authentication',
 '# Two-Factor Authentication (2FA)\n\nAdding 2FA makes your account significantly more secure.\n\n## How to Enable\n1. Go to **Profile** → **Settings** → **Security**\n2. Tap **Two-Factor Authentication**\n3. Choose **SMS** or **Authenticator App**\n4. Follow the setup steps\n5. Save your recovery codes in a safe place',
 'Protect your account with two-factor authentication.',
 'published', 1),

(2, 'how-to-send-message',
 'How to Send a Message',
 '# Sending Messages\n\nSending a message on VibeChat is simple.\n\n## Direct Message\n1. Tap the **Chats** tab\n2. Tap the **compose** icon\n3. Search for a friend\n4. Type your message and tap send',
 'Learn how to send messages and share media on VibeChat.',
 'published', 0),

(3, 'how-to-post-story',
 'How to Post a Story',
 '# Posting a Story\n\nStories are visible to your friends for 24 hours.\n\n## Steps\n1. Tap the **camera** FAB button\n2. Take a photo or record a video\n3. Add filters, stickers, or text\n4. Tap **Post to My Story**',
 'Learn how to create and share stories on VibeChat.',
 'published', 0),

(4, 'how-to-add-friends',
 'How to Add Friends',
 '# Adding Friends\n\n## Methods\n1. **Username Search** — Search in the Discover tab\n2. **QR Code** — Scan their VibeChat QR code\n3. **Suggested Friends** — Based on mutual connections',
 'Different ways to find and add friends on VibeChat.',
 'published', 0),

(5, 'what-is-vibechat-plus',
 'What is VibeChat+?',
 '# VibeChat+\n\nVibeChat+ is our premium subscription.\n\n## What You Get\n- Custom chat themes\n- Exclusive sticker packs\n- HD photo and video sharing\n- VibeChat+ badge\n- No ads\n- Priority support\n\n## Pricing\n- Monthly: $4.99/month\n- Annual: $47.99/year',
 'Everything you need to know about VibeChat+ subscription.',
 'published', 1),

(4, 'how-to-block-someone',
 'How to Block Someone',
 '# Blocking a User\n\nBlocking prevents someone from contacting you.\n\n## Steps\n1. Go to their profile\n2. Tap ⋮ → Block\n3. Confirm',
 'Learn how to block users on VibeChat.',
 'published', 0),

(8, 'app-not-loading',
 'App Not Loading or Crashing',
 '# App Not Loading\n\n## Quick Fixes\n1. Force close and reopen the app\n2. Check your internet connection\n3. Restart your device\n4. Update the app\n5. Clear app cache (Android)',
 'Troubleshoot VibeChat loading and crashing issues.',
 'published', 0),

(1, 'getting-started-guide',
 'Getting Started with VibeChat',
 '# Welcome to VibeChat!\n\nHere is everything you need to get started.\n\n## Step 1 — Set Up Your Profile\n- Add a profile photo\n- Write a bio\n- Set your privacy level\n\n## Step 2 — Add Friends\n- Use the Discover tab to find friends\n- Share your QR code\n\n## Step 3 — Start Chatting\n- Send messages, photos, and videos\n- Post your first Story',
 'Complete beginner guide to using VibeChat.',
 'published', 1),

(7, 'how-to-monetize-as-creator',
 'How to Monetize as a Creator',
 '# Creator Monetization\n\n## Requirements\n- Creator account status\n- VibeChat Creator subscription\n- At least 1,000 followers\n\n## Revenue Sources\n- **Tips** — Fans can send you tips directly\n- **Subscriptions** — Fans pay monthly for exclusive content\n- **Ad Revenue** — Earn from ads shown on your content\n\n## Getting Paid\nPayouts are processed monthly to your linked bank account or PayPal.',
 'Learn how to earn money as a VibeChat creator.',
 'published', 1);


SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
-- END OF SCHEMA
-- VibeChat | Nexa-Group
-- Tables: 48 | Version: 3.0
-- ============================================================
