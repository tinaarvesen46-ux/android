<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'uuid',
        'username',
        'last_username_update',
        'email',
        'phone',
        'phone_hash',
        'password',
        'email',
        'account_status',
        'staff_role',
        'privacy_level',
        'email_verified_at',
        'phone_verified_at',
        'two_factor_enabled',
        'two_factor_secret',
        'two_factor_recovery',
    ];

    protected $hidden = [
        'password',
        'email',
        'remember_token',
        'two_factor_secret',
        'two_factor_recovery',
        'login_attempts',
        'locked_until',
        'warning_count',
        'suspension_reason',
        'suspension_ends_at',
        'ban_reason',
        'banned_at',
        'phone_hash',
    ];

    protected $appends = [
        'is_swift_plus',
        'next_username_change_at',
        'username_locked',
        'username_cooldown_days',
        'display_name',
        'avatar_url',
        'bio',
        'friend_count',
        'is_verified',
        'role',
        'role_label',
    ];

    protected function casts(): array
    {
        return [
            'email_verified_at'    => 'datetime',
            'phone_verified_at'    => 'datetime',
            'last_username_update' => 'datetime',
            'password'             => 'hashed',
            'is_online'            => 'boolean',
            'two_factor_enabled'   => 'boolean',
            'two_factor_secret'    => 'encrypted',
            'two_factor_recovery'  => 'encrypted:array',
        ];
    }

    public function profile(): HasOne
    {
        return $this->hasOne(UserProfile::class);
    }

    public function settings(): HasOne
    {
        return $this->hasOne(UserSettings::class);
    }

    public function sessions(): HasMany
    {
        return $this->hasMany(UserSession::class);
    }

    public function subscriptions(): HasMany
    {
        return $this->hasMany(Subscription::class);
    }

    /** True if user has any staff-level role. */
    public function isStaff(): bool
    {
        return in_array($this->staff_role, ['support', 'moderator', 'administrator'], true);
    }

    public function isAdmin(): bool
    {
        return $this->staff_role === 'administrator';
    }

    /** True if this user currently has an active Swift+ subscription. */
    public function isSwiftPlus(): bool
    {
        return $this->subscriptions()
            ->whereIn('status', ['active', 'trialing'])
            ->where('current_period_end', '>=', now())
            ->exists();
    }

    /** Cooldown between username changes in whole days. */
    public function usernameCooldownDays(): int
    {
        return $this->isSwiftPlus() ? 30 : 365;
    }

    /** Timestamp when the user is next allowed to change their username. */
    public function nextUsernameChangeAt(): ?\Carbon\Carbon
    {
        if (! $this->last_username_update) {
            return null;
        }
        return $this->last_username_update->copy()->addDays($this->usernameCooldownDays());
    }

    // ── Appended attributes ────────────────────────────────────────────────

    public function getIsSwiftPlusAttribute(): bool
    {
        return $this->isSwiftPlus();
    }

    public function getUsernameCooldownDaysAttribute(): int
    {
        return $this->usernameCooldownDays();
    }

    public function getNextUsernameChangeAtAttribute(): ?string
    {
        return optional($this->nextUsernameChangeAt())->toIso8601String();
    }

    public function getUsernameLockedAttribute(): bool
    {
        $next = $this->nextUsernameChangeAt();
        return $next !== null && $next->isFuture();
    }

    /** Flat mobile-client fields — sourced from the profile relation so every
     *  endpoint that serializes a User already matches the SwiftSnap Flutter
     *  contract (display_name, avatar_url, bio, friend_count, is_verified). */
    public function getDisplayNameAttribute(): string
    {
        return $this->profile?->display_name ?: $this->username;
    }

    public function getAvatarUrlAttribute(): ?string
    {
        return $this->profile?->avatar_url;
    }

    public function getBioAttribute(): ?string
    {
        return $this->profile?->bio;
    }

    public function getFriendCountAttribute(): int
    {
        return \App\Models\Friendship::where('user_id', $this->id)->count();
    }

    public function getIsVerifiedAttribute(): bool
    {
        return in_array($this->account_status, ['verified', 'creator'], true);
    }

    /**
     * Real role/badge source of truth — derived only from `staff_role` and
     * `account_status`, never client-supplied. Staff roles take precedence
     * over the account-level creator/verified badge.
     */
    public function getRoleAttribute(): string
    {
        if (in_array($this->staff_role, ['administrator', 'moderator', 'support'], true)) {
            return $this->staff_role;
        }
        if ($this->account_status === 'creator') return 'creator';
        if ($this->account_status === 'verified') return 'verified';
        return 'user';
    }

    public function getRoleLabelAttribute(): string
    {
        return match ($this->role) {
            'administrator' => 'Administrator',
            'moderator'     => 'Moderator',
            'support'       => 'Support',
            'creator'       => 'Creator',
            'verified'      => 'Verified',
            default         => '',
        };
    }
    public function followers(): HasMany
    {
        return $this->hasMany(\App\Models\Follower::class, 'followee_id');
    }

    public function following(): HasMany
    {
        return $this->hasMany(\App\Models\Follower::class, 'follower_id');
    }

    public function isFollowing($otherId): bool
    {
        return $this->following()->where('followee_id', $otherId)->exists();
    }
}
