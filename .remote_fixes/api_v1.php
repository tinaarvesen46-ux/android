<?php

/**
 * Mobile v1 API — matches the Flutter app's api_config.dart endpoint paths.
 * All routes mounted under /api/v1 by the parent api.php file.
 */

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\Mobile\AdminController      as MobileAdmin;
use App\Http\Controllers\Api\Mobile\AuthController        as MobileAuth;
use App\Http\Controllers\Api\Mobile\ChatController;
use App\Http\Controllers\Api\Mobile\ConversationController;
use App\Http\Controllers\Api\Mobile\FriendController;
use App\Http\Controllers\Api\Mobile\MediaController;
use App\Http\Controllers\Api\Mobile\NotificationController as MobileNotif;
use App\Http\Controllers\Api\Mobile\ReportController;
use App\Http\Controllers\Api\Mobile\SearchController;
use App\Http\Controllers\Api\Mobile\SecurityController;
use App\Http\Controllers\Api\Mobile\StoryController;
use App\Http\Controllers\Api\Mobile\SubscriptionController;
use App\Http\Controllers\Api\Mobile\UserController        as MobileUser;
use App\Http\Controllers\Api\Mobile\AvatarController;
use App\Http\Controllers\Api\Mobile\MyAiController;
use App\Http\Controllers\Api\Mobile\AiConversationController;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function () {

    // ── AUTH (public) — current SwiftSnap client: identifier+token contract ─
    Route::middleware('throttle:10,1')->post('auth/login',               [MobileAuth::class, 'login']);
    Route::middleware('throttle:5,1')->post('auth/register',            [MobileAuth::class, 'register']);
    Route::middleware('throttle:10,1')->post('auth/2fa/verify-login',   [MobileAuth::class, 'verifyTwoFactorLogin']);
    Route::middleware('throttle:10,1')->post('auth/verify-email',        [AuthController::class, 'verifyOtp']);
    Route::middleware('throttle:5,1')->post('auth/forgot-password',     [AuthController::class, 'forgotPassword']);
    Route::middleware('throttle:5,1')->post('auth/reset-password',      [AuthController::class, 'resetPassword']);
    Route::middleware('throttle:5,1')->post('auth/resend-verification', [AuthController::class, 'register']); // reuses issueOtp path

    // Public media endpoints: profile avatars, header scenes, and catalog
    // thumbnails are intentionally readable by profile viewers. Mutations
    // remain inside the authenticated group below.
    Route::get('avatar/catalog', [\App\Http\Controllers\Api\Mobile\AvatarController::class, 'catalogList']);
    Route::get('avatar/asset/{category}/{id}/thumb', [\App\Http\Controllers\Api\Mobile\AvatarController::class, 'assetThumbnail']);
    Route::get('avatar/render/{id}', [\App\Http\Controllers\Api\Mobile\AvatarController::class, 'render']);
    Route::get('avatar/header/{id}', [\App\Http\Controllers\Api\Mobile\AvatarController::class, 'renderHeader']);

    Route::middleware('auth:sanctum')->group(function () {

        // ── BROADCASTING AUTH (token-based, for Reverb private/presence channels) ─
        Route::post('broadcasting/auth', function (\Illuminate\Http\Request $r) {
            return \Illuminate\Support\Facades\Broadcast::auth($r);
        });

        // ── AUTH (private) ───────────────────────────────────────────
        Route::post('auth/logout',   [AuthController::class, 'logout']);
        Route::post('auth/refresh',  [AuthController::class, 'logout']); // client re-issues via login

        // ── USERS ────────────────────────────────────────────────────
        Route::get   ('users/me',            [MobileUser::class, 'me']);
        Route::put   ('users/me',            [MobileUser::class, 'updateMe']);
        Route::post  ('users/me/avatar',     [MobileUser::class, 'uploadAvatar']);
        Route::post  ('users/me/cover',      [MobileUser::class, 'uploadCover']);
        Route::get   ('users/me/settings',   [MobileUser::class, 'settings']);
        Route::put   ('users/me/settings',   [MobileUser::class, 'updateSettings']);
        Route::get   ('users/blocked',       [MobileUser::class, 'blockedList']);
        Route::get   ('users/search',        [SearchController::class, 'users']);
        Route::post  ('users/{id}/block',    [MobileUser::class, 'block']);
        Route::post  ('users/{id}/unblock',  [MobileUser::class, 'unblock']);
        Route::get   ('users/{id}',          [MobileUser::class, 'showProfile']);

        // ── SwiftSnap current client — flat aliases (social_repository.dart) ──
        Route::get   ('me',               [MobileUser::class, 'me']);
        Route::put   ('me',               [MobileUser::class, 'updateMe']);
        Route::post  ('me/avatar-config', [MobileUser::class, 'avatarConfig']);
        Route::post  ('me/delete',        [MobileUser::class, 'deleteAccount']);
        Route::get   ('blocks',           [MobileUser::class, 'blockedList']);
        Route::post  ('blocks',           [MobileUser::class, 'blockByBody']);
        Route::delete('blocks/{id}',      [MobileUser::class, 'unblock']);
        Route::post  ('reports',          [ReportController::class, 'report']);

        Route::get('realtime/config', function () {
            return response()->json([
                'key'    => config('broadcasting.connections.reverb.key'),
                'host'   => env('REVERB_HOST'),
                'port'   => (int) env('REVERB_PORT', 443),
                'scheme' => env('REVERB_SCHEME', 'https'),
            ]);
        });

        // Snapshot reconciliation after a websocket gap. The endpoint returns
        // current state as replayable events; it never exposes another user's data.
        Route::get('realtime/missed', function (\Illuminate\Http\Request $r) {
            $since = (int) $r->query('since', 0);
            $uid = (int) $r->user()->id;
            $events = [];
            $profile = \Illuminate\Support\Facades\DB::table('user_profiles')->where('user_id', $uid)->first();
            if ($profile && $profile->updated_at && strtotime($profile->updated_at) > $since) {
                $events[] = [
                    'channel' => 'private-user.' . $uid,
                    'event' => 'AvatarUpdated',
                    'timestamp' => strtotime($profile->updated_at),
                    'data' => [
                        'user_id' => $uid,
                        'config' => $profile->avatar_config ? json_decode($profile->avatar_config, true) : null,
                        'avatar_url' => $profile->avatar_url,
                    ],
                ];
            }
            $header = \Illuminate\Support\Facades\DB::table('profile_header_configs')->where('user_id', $uid)->first();
            if ($header && $header->updated_at && strtotime($header->updated_at) > $since) {
                $events[] = [
                    'channel' => 'private-user.' . $uid,
                    'event' => 'ProfileHeaderUpdated',
                    'timestamp' => strtotime($header->updated_at),
                    'data' => ['user_id' => $uid, 'config' => json_decode($header->config, true)],
                ];
            }
            return response()->json($events);
        });

        // ── CHATS & MESSAGES ─────────────────────────────────────────
        Route::get   ('chats',                     [ChatController::class, 'index']);
        Route::post  ('chats',                     [ChatController::class, 'store']);
        Route::get   ('chats/{id}',                [ChatController::class, 'show']);
        Route::get   ('chats/{id}/messages',       [ChatController::class, 'messages']);
        Route::post  ('chats/{id}/messages',       [ChatController::class, 'sendMessage']);
        Route::post  ('chats/{id}/read',           [ChatController::class, 'markRead']);
        Route::post  ('chats/{id}/screenshot',     [ChatController::class, 'screenshot']);
        Route::put   ('chats/{id}',                       [ChatController::class, 'updateGroup']);
        Route::get   ('chats/{id}/participants',          [ChatController::class, 'participants']);
        Route::post  ('chats/{id}/participants',          [ChatController::class, 'addParticipant']);
        Route::delete('chats/{id}/participants/{userId}', [ChatController::class, 'removeParticipant']);
        Route::delete('messages/{id}',             [ChatController::class, 'deleteMessage']);

        // Presence + heartbeat
        Route::post('presence/heartbeat', [\App\Http\Controllers\Api\Mobile\PresenceController::class, 'heartbeat']);
        Route::post('presence/offline',   [\App\Http\Controllers\Api\Mobile\PresenceController::class, 'offline']);
        Route::get ('presence',           [\App\Http\Controllers\Api\Mobile\PresenceController::class, 'bulk']);

        // Per-conversation prefs (mute, sound, pin) — Snapchat-style
        Route::get   ('chats/{id}/settings', [\App\Http\Controllers\Api\Mobile\ChatSettingsController::class, 'show']);
        Route::put   ('chats/{id}/settings', [\App\Http\Controllers\Api\Mobile\ChatSettingsController::class, 'update']);
        Route::post  ('chats/{id}/pin',      [\App\Http\Controllers\Api\Mobile\ChatSettingsController::class, 'pin']);
        Route::delete('chats/{id}/pin',      [\App\Http\Controllers\Api\Mobile\ChatSettingsController::class, 'unpin']);

        Route::put   ('messages/{id}',             [ChatController::class, 'editMessage']);
        Route::post  ('messages/{id}/react',       [ChatController::class, 'react']);

        // ── STORIES ──────────────────────────────────────────────────
        Route::get   ('stories',                [StoryController::class, 'index']);
        Route::get   ('stories/public',         [StoryController::class, 'publicStories']);
        Route::post  ('stories',                [StoryController::class, 'store']);
        Route::post  ('stories/{id}/screenshot',[StoryController::class, 'screenshot']);
        Route::get   ('stories/{id}',           [StoryController::class, 'show']);
        Route::delete('stories/{id}',           [StoryController::class, 'destroy']);
        Route::post  ('stories/{id}/view',      [StoryController::class, 'markViewed']);
        Route::get   ('stories/{id}/viewers',   [StoryController::class, 'viewers']);
        Route::post  ('stories/{id}/reply',     [StoryController::class, 'reply']);
        Route::get   ('stories/{id}/replies',   [StoryController::class, 'replies']);
        Route::get   ('stories/{id}/reactions', [StoryController::class, 'reactions']);
        Route::post  ('stories/{id}/reaction',  [StoryController::class, 'react']);
        Route::delete('stories/{id}/reaction',  [StoryController::class, 'removeReaction']);

        // Follow / Followers
        Route::post  ('users/{id}/follow',      [MobileUser::class, 'follow']);
        Route::post  ('users/{id}/unfollow',    [MobileUser::class, 'unfollow']);
        Route::get   ('users/{id}/followers',   [MobileUser::class, 'followers']);
        Route::get   ('users/{id}/following',   [MobileUser::class, 'followingList']);

        // Public profiles
        Route::get   ('public-profiles/{username}', [\App\Http\Controllers\Api\Mobile\PublicProfileController::class, 'show']);
        Route::post  ('public-profiles',               [\App\Http\Controllers\Api\Mobile\PublicProfileController::class, 'store']);
        Route::put   ('public-profiles',               [\App\Http\Controllers\Api\Mobile\PublicProfileController::class, 'update']);
        Route::delete('public-profiles',               [\App\Http\Controllers\Api\Mobile\PublicProfileController::class, 'destroy']);

        // Profile header / Avatar scene editor
        Route::get   ('me/profile-header',             [\App\Http\Controllers\Api\Mobile\ProfileHeaderController::class, 'show']);
        Route::put   ('me/profile-header',             [\App\Http\Controllers\Api\Mobile\ProfileHeaderController::class, 'update']);
        Route::post  ('me/profile-header/reset',       [\App\Http\Controllers\Api\Mobile\ProfileHeaderController::class, 'reset']);

        // ── SwiftSnap current client — Spotlight/Reels ──
        Route::get   ('spotlight',              [\App\Http\Controllers\Api\Mobile\SpotlightController::class, 'index']);
        Route::post  ('spotlight',              [\App\Http\Controllers\Api\Mobile\SpotlightController::class, 'store']);
        Route::post  ('spotlight/{id}/like',    [\App\Http\Controllers\Api\Mobile\SpotlightController::class, 'like']);
        Route::post  ('spotlight/{id}/save',    [\App\Http\Controllers\Api\Mobile\SpotlightController::class, 'save']);

        // ── SwiftSnap current client — Discover (real, admin-curated content) ──
        Route::get   ('discover/categories',    [\App\Http\Controllers\Api\Mobile\DiscoverController::class, 'categories']);
        Route::get   ('discover',               [\App\Http\Controllers\Api\Mobile\DiscoverController::class, 'index']);

        // ── SwiftSnap current client — Memories ──
        Route::get   ('memories',                [\App\Http\Controllers\Api\Mobile\MemoryController::class, 'index']);
        Route::post  ('memories',                [\App\Http\Controllers\Api\Mobile\MemoryController::class, 'store']);
        Route::delete('memories/{id}',           [\App\Http\Controllers\Api\Mobile\MemoryController::class, 'destroy']);
        Route::post  ('memories/{id}/favorite',  [\App\Http\Controllers\Api\Mobile\MemoryController::class, 'toggleFavorite']);

        // ── FRIENDS ──────────────────────────────────────────────────
        Route::get   ('friends',                              [FriendController::class, 'index']);
        Route::get   ('friends/recent-partners',             [FriendController::class, 'recentPartners']);
        Route::delete('friends/{userId}',                     [FriendController::class, 'unfriend']);
        Route::get   ('friend-requests',                      [FriendController::class, 'requests']);
        Route::post  ('friend-requests',                      [FriendController::class, 'sendRequestBody']);
        Route::post  ('friend-requests/send/{userId}',        [FriendController::class, 'sendRequest']);
        Route::post  ('friend-requests/{id}/accept',          [FriendController::class, 'accept']);
        Route::post  ('friend-requests/{id}/reject',          [FriendController::class, 'reject']);
        Route::post  ('friend-requests/{id}/decline',         [FriendController::class, 'reject']);
        Route::post  ('friend-requests/{id}/cancel',          [FriendController::class, 'cancel']);
        Route::delete('friend-requests/{id}',                 [FriendController::class, 'cancel']);

        // ── SwiftSnap current client — conversations (1:1-first chat) ──
        Route::get   ('conversations',               [AiConversationController::class, 'index']);
        Route::post  ('conversations',               [ConversationController::class, 'store']);
        Route::get   ('conversations/{id}/messages', [ConversationController::class, 'messages']);
        Route::post  ('conversations/{id}/messages', [ConversationController::class, 'sendMessage']);
        Route::post  ('conversations/{id}/read',     [ConversationController::class, 'markRead']);
        Route::post  ('conversations/{id}/mute',     [ConversationController::class, 'setMuted']);
        Route::post  ('conversations/{id}/typing',   [ConversationController::class, 'typing']);
        Route::delete('conversations/{id}',          [ConversationController::class, 'destroy']);
        Route::get   ('my-ai/messages',              [MyAiController::class, 'index']);
        Route::post  ('my-ai/messages',              [MyAiController::class, 'message'])->middleware('throttle:20,1');

        // ── SEARCH ───────────────────────────────────────────────────
        Route::get   ('search/users',    [SearchController::class, 'users']);
        Route::get   ('search/messages', [SearchController::class, 'messages']);
        Route::get   ('search/discover', [SearchController::class, 'discover']);

        // ── NOTIFICATIONS ────────────────────────────────────────────
        Route::get   ('notifications',                     [MobileNotif::class, 'index']);
        Route::post  ('notifications/read-all',            [MobileNotif::class, 'markAllRead']);
        Route::post  ('notifications/{id}/read',           [MobileNotif::class, 'markRead']);
        Route::get   ('notifications/settings',            [MobileNotif::class, 'preferences']);
        Route::put   ('notifications/settings',            [MobileNotif::class, 'updatePreferences']);

        // ── SETTINGS (aliases to users/settings + password/2fa) ──────
        Route::get   ('settings/privacy',      [MobileUser::class, 'settings']);
        Route::put   ('settings/privacy',      [MobileUser::class, 'updateSettings']);
        Route::get   ('settings/notifications',[MobileNotif::class, 'preferences']);
        Route::put   ('settings/notifications',[MobileNotif::class, 'updatePreferences']);
        Route::get   ('settings/security',     [SecurityController::class, 'sessions']);
        Route::get   ('settings/appearance',   [MobileUser::class, 'settings']);
        Route::put   ('settings/appearance',   [MobileUser::class, 'updateSettings']);
        Route::post  ('settings/password',     [MobileUser::class, 'changePassword']);
        Route::post  ('settings/2fa/enable',   [SecurityController::class, 'enable2fa']);
        Route::post  ('settings/2fa/disable',  [SecurityController::class, 'disable2fa']);
        Route::post  ('settings/2fa/verify',   [SecurityController::class, 'verify2fa']);

        // ── PHONE VERIFICATION (real Twilio SMS; 503 until configured) ──
        Route::middleware('throttle:5,1')->post('phone/send-code',   [\App\Http\Controllers\Api\Mobile\PhoneController::class, 'sendCode']);
        Route::middleware('throttle:10,1')->post('phone/verify-code', [\App\Http\Controllers\Api\Mobile\PhoneController::class, 'verifyCode']);

        // ── CONTACT DISCOVERY (hashed phone numbers only) ────────────
        Route::post  ('contacts/discover', [\App\Http\Controllers\Api\Mobile\ContactController::class, 'discover']);

        // ── ACCOUNT STATUS ────────────────────────────────────────────
        Route::get   ('account/status', [SecurityController::class, 'accountStatus']);

        // ── MEDIA ────────────────────────────────────────────────────
        Route::post  ('media',           [MediaController::class, 'uploadFlat']);
        Route::post  ('media/upload',    [MediaController::class, 'upload']);
        Route::get   ('media/{id}',      [MediaController::class, 'show']);
        Route::get   ('media/message/{uuid}', [MediaController::class, 'streamMessageMedia']);
        Route::delete('media/{id}',      [MediaController::class, 'destroy']);

        // ── REPORTS ──────────────────────────────────────────────────
        Route::post  ('reports/user',    [ReportController::class, 'reportUser']);
        Route::post  ('reports/content', [ReportController::class, 'reportContent']);
        Route::get   ('reports/me',      [ReportController::class, 'myReports']);

        // ── SUBSCRIPTION ─────────────────────────────────────────────
        Route::get   ('subscription/plans',     [SubscriptionController::class, 'plans']);
        Route::post  ('subscription/subscribe', [SubscriptionController::class, 'subscribe']);
        Route::post  ('subscription/cancel',    [SubscriptionController::class, 'cancel']);
        Route::get   ('subscription/status',    [SubscriptionController::class, 'status']);

        // ── SECURITY ─────────────────────────────────────────────────
        Route::get   ('security/login-history',       [SecurityController::class, 'loginHistory']);
        Route::get   ('security/sessions',            [SecurityController::class, 'sessions']);
        Route::delete('security/sessions/{id}',       [SecurityController::class, 'revokeSession']);
        Route::get   ('security/suspicious-activity', [SecurityController::class, 'suspicious']);
        Route::post  ('security/export-data',         [SecurityController::class, 'exportData']);
        Route::get   ('security/export-data/{token}', [SecurityController::class, 'downloadExport']);
        Route::post  ('security/delete-account',      [SecurityController::class, 'deleteAccount']);

        // ── ADMIN ────────────────────────────────────────────────────
        Route::get   ('admin/users',        [MobileAdmin::class, 'users']);
        Route::get   ('admin/tickets',      [MobileAdmin::class, 'tickets']);
        Route::get   ('admin/reports',      [MobileAdmin::class, 'reports']);
        Route::get   ('admin/analytics',    [MobileAdmin::class, 'analytics']);
        Route::get   ('admin/campaigns',    [MobileAdmin::class, 'campaigns']);
        Route::get   ('admin/email-templates',[MobileAdmin::class, 'templates']);
        Route::get   ('admin/settings',     [MobileAdmin::class, 'settings']);
        Route::get   ('admin/audit-logs',   [MobileAdmin::class, 'auditLogs']);
        Route::get   ('admin/dashboard',    [MobileAdmin::class, 'dashboard']);
    


        // ── SwiftSnap Creator earnings (real, read from creator_revenue) ──
        Route::get   ('creator/earnings',              [\App\Http\Controllers\Api\Mobile\CreatorController::class, 'earnings']);
        Route::get   ('creator/earnings/transactions', [\App\Http\Controllers\Api\Mobile\CreatorController::class, 'transactions']);

        // ── SwiftSnap Devices (push token registration) + Achievements ──
        Route::post  ('devices/register',   [\App\Http\Controllers\Api\Mobile\DeviceController::class, 'register']);
        Route::post  ('devices/unregister', [\App\Http\Controllers\Api\Mobile\DeviceController::class, 'unregister']);
        Route::get   ('devices',            [\App\Http\Controllers\Api\Mobile\DeviceController::class, 'index']);
        Route::get   ('achievements',       [\App\Http\Controllers\Api\Mobile\AchievementController::class, 'index']);

        // ── SwiftSnap Avatar (Bitmoji-style, validated catalog) ──
        Route::get   ('avatar',        [\App\Http\Controllers\Api\Mobile\AvatarController::class, 'show']);
        Route::put   ('avatar',        [\App\Http\Controllers\Api\Mobile\AvatarController::class, 'update']);
        Route::post  ('avatar/reset',  [\App\Http\Controllers\Api\Mobile\AvatarController::class, 'reset']);

        // ── SwiftSnap Calling (self-hosted WebRTC signalling over Reverb + coturn) ──
        Route::get   ('calls/ice-servers',      [\App\Http\Controllers\Api\Mobile\CallController::class, 'iceServers']);
        Route::get   ('calls',                  [\App\Http\Controllers\Api\Mobile\CallController::class, 'history']);
        Route::post  ('calls',                  [\App\Http\Controllers\Api\Mobile\CallController::class, 'initiate']);
        Route::post  ('calls/{uuid}/accept',    [\App\Http\Controllers\Api\Mobile\CallController::class, 'accept']);
        Route::post  ('calls/{uuid}/decline',   [\App\Http\Controllers\Api\Mobile\CallController::class, 'decline']);
        Route::post  ('calls/{uuid}/end',       [\App\Http\Controllers\Api\Mobile\CallController::class, 'end']);
        Route::post  ('calls/{uuid}/signal',    [\App\Http\Controllers\Api\Mobile\CallController::class, 'signal']);

        // ── SwiftSnap Lens catalog ──
        Route::get   ('lenses',                   [\App\Http\Controllers\Api\Mobile\LensController::class, 'index']);
        Route::get   ('lenses/categories',        [\App\Http\Controllers\Api\Mobile\LensController::class, 'categories']);
        Route::get   ('lenses/my',                [\App\Http\Controllers\Api\Mobile\LensController::class, 'mine']);
        Route::get   ('lenses/beauty-presets',    [\App\Http\Controllers\Api\Mobile\LensController::class, 'beautyPresetsIndex']);
        Route::put   ('lenses/beauty-settings',   [\App\Http\Controllers\Api\Mobile\LensController::class, 'saveBeautySettings']);
        Route::get   ('lenses/{id}',              [\App\Http\Controllers\Api\Mobile\LensController::class, 'show']);
        Route::post  ('lenses',                   [\App\Http\Controllers\Api\Mobile\LensController::class, 'store']);
        Route::delete('lenses/{id}',              [\App\Http\Controllers\Api\Mobile\LensController::class, 'destroy']);
        Route::post  ('lenses/{id}/favorite',     [\App\Http\Controllers\Api\Mobile\LensController::class, 'favorite']);
        Route::delete('lenses/{id}/favorite',     [\App\Http\Controllers\Api\Mobile\LensController::class, 'unfavorite']);
        Route::post  ('lenses/{id}/use',          [\App\Http\Controllers\Api\Mobile\LensController::class, 'use']);
        Route::post  ('lenses/{id}/report',       [\App\Http\Controllers\Api\Mobile\LensController::class, 'report']);
        Route::post  ('lenses/{id}/tip',          [\App\Http\Controllers\Api\Mobile\LensController::class, 'tip']);

        // ── SwiftMap (location) ──
        Route::middleware('throttle:60,1')->group(function () {
            Route::post  ('location/update',   [\App\Http\Controllers\Api\Mobile\LocationController::class, 'update']);
        });
        Route::post  ('location/stop',       [\App\Http\Controllers\Api\Mobile\LocationController::class, 'stop']);
        Route::get   ('location/settings',   [\App\Http\Controllers\Api\Mobile\LocationController::class, 'showSettings']);
        Route::put   ('location/settings',   [\App\Http\Controllers\Api\Mobile\LocationController::class, 'updateSettings']);
        Route::get   ('location/friends',    [\App\Http\Controllers\Api\Mobile\LocationController::class, 'friends']);

        // ── SwiftSnap current client — /map/* flat contract ──
        Route::get   ('map/friends',      [\App\Http\Controllers\Api\Mobile\LocationController::class, 'friendsFlat']);
        Route::middleware('throttle:60,1')->post('map/location', [\App\Http\Controllers\Api\Mobile\LocationController::class, 'updateFlat']);
        Route::post  ('map/ghost-mode',   [\App\Http\Controllers\Api\Mobile\LocationController::class, 'ghostMode']);

        

        // ── SwiftSnap Lens Studio (creator + import) ──
        Route::get   ('lens-studio/templates',                  [\App\Http\Controllers\Api\Mobile\LensStudioController::class, 'templates']);
        Route::get   ('lens-studio/capabilities',               [\App\Http\Controllers\Api\Mobile\LensStudioController::class, 'capabilities']);
        Route::post  ('lens-studio/projects',                   [\App\Http\Controllers\Api\Mobile\LensStudioController::class, 'createProject']);
        Route::put   ('lens-studio/projects/{id}',              [\App\Http\Controllers\Api\Mobile\LensStudioController::class, 'saveProject']);
        Route::post  ('lens-studio/projects/{id}/submit',       [\App\Http\Controllers\Api\Mobile\LensStudioController::class, 'submit']);
        Route::post  ('lens-studio/projects/{id}/duplicate',    [\App\Http\Controllers\Api\Mobile\LensStudioController::class, 'duplicate']);
        Route::get   ('lens-studio/assets',                     [\App\Http\Controllers\Api\Mobile\LensStudioController::class, 'listAssets']);
        Route::get   ('lens-studio/assets/{id}/raw',            [\App\Http\Controllers\Api\Mobile\LensStudioController::class, 'serveAsset']);
        Route::get   ('lens-studio/analytics',                  [\App\Http\Controllers\Api\Mobile\LensStudioController::class, 'analytics']);
        Route::post  ('lens-studio/assets',                     [\App\Http\Controllers\Api\Mobile\LensStudioController::class, 'uploadAsset']);
        Route::delete('lens-studio/assets/{id}',                [\App\Http\Controllers\Api\Mobile\LensStudioController::class, 'deleteAsset']);
        Route::post  ('lens-studio/import',                     [\App\Http\Controllers\Api\Mobile\LensStudioController::class, 'import']);

        // ── Streak Restore (Swift+) ──
        Route::get ('streaks/expiring',            [\App\Http\Controllers\Api\Mobile\StreakRestoreController::class, 'expiring']);
        Route::get ('streaks/restore/eligibility', [\App\Http\Controllers\Api\Mobile\StreakRestoreController::class, 'eligibility']);
        Route::post('streaks/restore',             [\App\Http\Controllers\Api\Mobile\StreakRestoreController::class, 'restore']);

    });
});
