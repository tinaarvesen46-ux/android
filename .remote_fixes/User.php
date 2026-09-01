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

    // ... existing properties omitted for brevity - we only patch methods at the end

    public function followers()
    {
        return $this->hasMany(\App\Models\Follower::class, 'followee_id');
    }

    public function following()
    {
        return $this->hasMany(\App\Models\Follower::class, 'follower_id');
    }

    public function isFollowing($otherId): bool
    {
        return $this->following()->where('followee_id', $otherId)->exists();
    }
}
