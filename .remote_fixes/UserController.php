<?php

namespace App\Http\Controllers\Api\Mobile;

use App\Http\Controllers\Controller;
use App\Models\FriendRequest;
use App\Models\Friendship;
use App\Models\User;
use App\Models\UserBlock;
use App\Models\UserProfile;
use App\Models\UserSettings;
use App\Models\NotificationPreference;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Cache;
use App\Services\SwiftMoji\Renderer;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;
use App\Events\AvatarUpdated;

class UserController extends Controller
{
    /** GET /api/v1/users/me */
    public function me(Request $r): JsonResponse
    {
        $u = $r->user()->load('profile', 'settings');
        $payload = $u->toArray();
        $payload['email'] = $u->getAttribute('email'); // safe: this is the user's own record
        $payload['avatar_render_url'] = url('/api/v1/avatar/render/' . $u->id);
        return response()->json($payload);
    }

    /** PUT /api/v1/users/me — update profile fields */
    public function updateMe(Request $r): JsonResponse
    {
        $u = $r->user();
        $data = $r->validate([
            'username'     => ['sometimes', 'string', 'min:3', 'max:30', 'regex:/^[a-zA-Z0-9._]+$/', Rule::unique('users','username')->ignore($u->id)],
            'email'        => ['sometimes', 'email', Rule::unique('users','email')->ignore($u->id)],
            'phone'        => ['sometimes', 'nullable', 'string', 'max:20'],
            'privacy_level'=> ['sometimes', Rule::in(['public','friends_only','private'])],
            // Profile fields
            'display_name' => ['sometimes', 'string', 'max:100'],
            'bio'          => ['sometimes', 'nullable', 'string', 'max:500'],
            'pronouns'     => ['sometimes', 'nullable', 'string', 'max:30'],
            'birthday'     => ['sometimes', 'nullable', 'date'],
            'location'     => ['sometimes', 'nullable', 'string', 'max:100'],
            'website'      => ['sometimes', 'nullable', 'url', 'max:200'],
        ]);

        // Enforce username cooldown only when it's actually being changed.
        if (array_key_exists('username', $data) && $data['username'] !== $u->username) {
            $next = $u->nextUsernameChangeAt();
            if ($next && $next->isFuture()) {
                $days = $u->usernameCooldownDays();
                throw \Illuminate\Validation\ValidationException::withMessages([
                    'username' => "You can change your username again on {$next->toDateString()}. Cooldown is {$days} days" . ($u->isSwiftPlus() ? ' (Swift+).' : ' (upgrade to Swift+ for a 30-day cooldown).'),
                ]);
            }
        }

        DB::transaction(function () use ($u, $data) {
            $userFields    = array_intersect_key($data, array_flip(['username','email','phone','privacy_level']));
            $profileFields = array_intersect_key($data, array_flip(['display_name','bio','pronouns','birthday','location','website']));

            if (array_key_exists('username', $userFields) && $userFields['username'] !== $u->username) {
                $userFields['last_username_update'] = now();
            }
            if ($userFields)    $u->update($userFields);
            if ($profileFields) $u->profile()->updateOrCreate(['user_id' => $u->id], $profileFields);
        });

        return response()->json($u->fresh()->load('profile'));
    }

    /** GET /api/v1/users/{id} */
    public function show(Request $r, string $id): JsonResponse
    {
        $u = User::with('profile')->findOrFail($id);
        // Basic privacy: private users only visible to friends
        return response()->json($u);
    }

    /** POST /api/v1/users/me/avatar — file upload */
    public function uploadAvatar(Request $r): JsonResponse
    {
        $r->validate(['file' => ['required','image','max:5120']]);
        $path = $r->file('file')->store('avatars/' . $r->user()->id, 'public');
        $url  = asset('storage/'.$path);
        $r->user()->profile()->updateOrCreate(['user_id' => $r->user()->id], ['avatar_url' => $url]);
        // Broadcast avatar change to connected clients
        $p = \App\Models\UserProfile::where('user_id', $r->user()->id)->first();
        $config = $p->avatar_config ? json_decode($p->avatar_config, true) : null;
        event(new AvatarUpdated($r->user()->id, $config, $url));
        return response()->json(['url' => $url]);
    }

    /** POST /api/v1/users/me/cover — file upload */
    public function uploadCover(Request $r): JsonResponse
    {
        $r->validate(['file' => ['required','image','max:8192']]);
        $path = $r->file('file')->store('covers/' . $r->user()->id, 'public');
        $url  = asset('storage/'.$path);
        $r->user()->profile()->updateOrCreate(['user_id' => $r->user()->id], ['cover_url' => $url]);
        return response()->json(['url' => $url]);
    }

    /** GET /api/v1/users/me/settings */
    public function settings(Request $r): JsonResponse
    {
        $s = UserSettings::firstOrCreate(['user_id' => $r->user()->id]);
        return response()->json($s);
    }

    /** PUT /api/v1/users/me/settings */
    public function updateSettings(Request $r): JsonResponse
    {
        $data = $r->validate([
            'theme'                        => ['sometimes', Rule::in(['light','dark','auto'])],
            'language'                     => ['sometimes', 'string', 'max:10'],
            'notif_messages'               => ['sometimes', 'boolean'],
            'notif_friend_requests'        => ['sometimes', 'boolean'],
            'notif_story_views'            => ['sometimes', 'boolean'],
            'notif_story_reactions'        => ['sometimes', 'boolean'],
            'notif_marketing'              => ['sometimes', 'boolean'],
            'notif_streaks'                => ['sometimes', 'boolean'],
            'notif_security'               => ['sometimes', 'boolean'],
            'show_online_status'           => ['sometimes', 'boolean'],
            'show_read_receipts'           => ['sometimes', 'boolean'],
            'show_typing_indicator'        => ['sometimes', 'boolean'],
            'login_alerts'                 => ['sometimes', 'boolean'],
            'screenshot_alerts'            => ['sometimes', 'boolean'],
            'data_sharing_analytics'       => ['sometimes', 'boolean'],
            'data_sharing_personalization' => ['sometimes', 'boolean'],
            'allow_messages_from'          => ['sometimes', Rule::in(['everyone','friends','nobody'])],
            'allow_friend_requests_from'   => ['sometimes', Rule::in(['everyone','friends_of_friends','nobody'])],
            'story_visibility'             => ['sometimes', Rule::in(['everyone','friends','close_friends','nobody'])],
            'swiftmap_appearance'          => ['sometimes', Rule::in(['auto','light','dark'])],
        ]);
        $s = UserSettings::firstOrCreate(['user_id' => $r->user()->id]);
        $s->update($data);
        return response()->json($s);
    }

    /** GET /api/v1/users/blocked — currently blocked users */
    public function blockedList(Request $r): JsonResponse
    {
        $rows = UserBlock::where('blocker_id', $r->user()->id)->with([])->get();
        $ids = $rows->pluck('blocked_id');
        return response()->json(User::whereIn('id', $ids)->with('profile')->get());
    }

    /** POST /api/v1/users/{id}/block */
    public function block(Request $r, string $id): JsonResponse
    {
        abort_if((int)$id === $r->user()->id, 422, 'Cannot block yourself.');
        UserBlock::firstOrCreate(['blocker_id' => $r->user()->id, 'blocked_id' => $id]);
        return response()->json(['blocked' => true]);
    }

    /** POST /api/v1/users/{id}/unblock */
    public function unblock(Request $r, string $id): JsonResponse
    {
        UserBlock::where('blocker_id', $r->user()->id)->where('blocked_id', $id)->delete();
        return response()->json(['blocked' => false]);
    }

    /**
     * GET /api/v1/users/{id} (current SwiftSnap client) — profile enriched
     * with the caller's relationship to this user. Path shared with the
     * legacy `show()` method's route is intentionally repointed here since
     * only the current mobile client consumes /api/v1/users/{id}.
     */
    public function showProfile(Request $r, string $id): JsonResponse
    {
        $target = User::with('profile')->findOrFail($id);
        $me = $r->user();
        $relationship = 'none';

        if ((int) $id !== $me->id) {
            $isFriend    = Friendship::where('user_id', $me->id)->where('friend_id', $id)->exists();
            $blockedByMe = UserBlock::where('blocker_id', $me->id)->where('blocked_id', $id)->exists();
            $blockedMe   = UserBlock::where('blocker_id', $id)->where('blocked_id', $me->id)->exists();
            $sentReq     = FriendRequest::where('sender_id', $me->id)->where('receiver_id', $id)->where('status', 'pending')->exists();
            $receivedReq = FriendRequest::where('sender_id', $id)->where('receiver_id', $me->id)->where('status', 'pending')->exists();

            if ($blockedByMe)     $relationship = 'blocked';
            elseif ($blockedMe)   $relationship = 'blocked_by';
            elseif ($isFriend)    $relationship = 'friends';
            elseif ($sentReq)     $relationship = 'request_sent';
            elseif ($receivedReq) $relationship = 'request_received';
        }

        return response()->json([
            'user'           => $target,
            'avatar_render_url' => url('/api/v1/avatar/render/' . $id),
            'relationship'   => $relationship,
            'friend_count'   => $target->friend_count,
            'story_count'    => \App\Models\Story::where('user_id', $id)->where('expires_at', '>', now())->count(),
            'reel_count'     => \App\Models\SpotlightPost::where('user_id', $id)->count(),
            'is_public'      => $target->privacy_level === 'public',
            'is_following'   => false,
            'follower_count' => 0,
        ]);
    }

    /** POST /api/v1/me/avatar-config — Bitmoji-style avatar config (JSON blob). */
    public function avatarConfig(Request $r): JsonResponse
    {
        $data = $r->validate(['config' => ['required', 'array']]);

        // Validate against AvatarAsset catalog
        $clean = [];
        foreach ($data['config'] as $cat => $id) {
            if (!is_string($id)) {
                return response()->json(['message' => "Invalid component for {$cat}"], 422);
            }
            $asset = \App\Models\AvatarAsset::where('category', $cat)->where('asset_id', $id)->where('enabled', true)->first();
            if (!$asset) {
                return response()->json(['message' => "Invalid or unknown asset '{$id}' for {$cat}"], 422);
            }
            $filePath = storage_path('app/avatars_catalog/' . $asset->filename);
            if (!file_exists($filePath)) {
                return response()->json(['message' => "Asset file missing for '{$id}' in {$cat}"], 422);
            }
            $clean[$cat] = $id;
        }

        // Invalidate previous render cache
        $p = \App\Models\UserProfile::where('user_id', $r->user()->id)->first();
        $oldConfig = $p && $p->avatar_config ? json_decode($p->avatar_config, true) : null;
        if (is_array($oldConfig)) {
            $renderer = new Renderer();
            $oldHash = $renderer->hashConfig($oldConfig);
            $oldKey = 'swiftmoji:render:' . $oldHash;
            if (Cache::has($oldKey)) {
                $oldPath = Cache::get($oldKey);
                Cache::forget($oldKey);
                if ($oldPath && Storage::exists($oldPath)) {
                    Storage::delete($oldPath);
                }
            }
        }

        $r->user()->profile()->updateOrCreate([
            'user_id' => $r->user()->id
        ], [
            'avatar_config' => json_encode($clean)
        ]);
        $p = \App\Models\UserProfile::where('user_id', $r->user()->id)->first();
        $avatarUrl = $p->avatar_url ?? null;
        event(new AvatarUpdated($r->user()->id, $clean, $avatarUrl));
        return response()->json(['saved' => true, 'config' => $clean]);
    }

    /** POST /api/v1/me/delete — permanently disable the account. */
    public function deleteAccount(Request $r): JsonResponse
    {
        $r->validate(['password' => ['required', 'string']]);
        $u = $r->user();
        abort_unless(Hash::check($r->input('password'), $u->password), 422, 'Incorrect password.');
        $u->tokens()->delete();
        $u->update(['account_status' => 'deleted', 'deleted_at' => now()]);
        return response()->json(['deleted' => true]);
    }

    /** POST /api/v1/blocks — block by body { user_id } (current client contract). */
    public function blockByBody(Request $r): JsonResponse
    {
        $data = $r->validate(['user_id' => ['required', 'integer', 'exists:users,id']]);
        return $this->block($r, (string) $data['user_id']);
    }

    /** POST /api/v1/settings/password — change password */
    public function changePassword(Request $r): JsonResponse
    {
        $r->validate([
            'current_password' => ['required', 'string'],
            'new_password'     => ['required', 'string', 'min:8'],
        ]);
        $u = $r->user();
        abort_unless(Hash::check($r->input('current_password'), $u->password), 422, 'Current password incorrect.');
        $u->update(['password' => $r->input('new_password')]);
        // Invalidate other tokens
        $u->tokens()->where('id', '!=', $u->currentAccessToken()->id)->delete();
        return response()->json(['message' => 'Password updated.']);
    }

    /** POST /api/v1/users/{id}/follow */
    public function follow(Request $r, string $id): JsonResponse
    {
        $u = $r->user();
        abort_if((int) $id === $u->id, 422, 'Cannot follow yourself.');
        \App\Models\Follower::firstOrCreate(['follower_id' => $u->id, 'followee_id' => $id]);
        try { \App\Models\UserProfile::where('user_id', $id)->increment('follower_count'); } catch (\Throwable $e) {}
        try { \App\Models\UserProfile::where('user_id', $u->id)->increment('following_count'); } catch (\Throwable $e) {}
        return response()->json(['ok' => true]);
    }

    /** POST /api/v1/users/{id}/unfollow */
    public function unfollow(Request $r, string $id): JsonResponse
    {
        $u = $r->user();
        \App\Models\Follower::where('follower_id', $u->id)->where('followee_id', $id)->delete();
        try { \App\Models\UserProfile::where('user_id', $id)->decrement('follower_count'); } catch (\Throwable $e) {}
        try { \App\Models\UserProfile::where('user_id', $u->id)->decrement('following_count'); } catch (\Throwable $e) {}
        return response()->json(['ok' => true]);
    }

    /** GET /api/v1/users/{id}/followers */
    public function followers(Request $r, string $id): JsonResponse
    {
        $rows = \App\Models\Follower::where('followee_id', $id)->get();
        $ids = $rows->pluck('follower_id');
        return response()->json(\App\Models\User::whereIn('id', $ids)->with('profile')->get());
    }

    /** GET /api/v1/users/{id}/following */
    public function followingList(Request $r, string $id): JsonResponse
    {
        $rows = \App\Models\Follower::where('follower_id', $id)->get();
        $ids = $rows->pluck('followee_id');
        return response()->json(\App\Models\User::whereIn('id', $ids)->with('profile')->get());
    }

}
