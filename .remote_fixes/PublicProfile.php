<?php

namespace App\Models;

use App\Models\BaseModel;

class PublicProfile extends BaseModel
{
    protected $table = 'public_profiles';

    protected $fillable = [
        'user_id',
        'display_name',
        'username',
        'bio',
        'is_enabled',
    ];

    protected $casts = [
        'is_enabled' => 'boolean',
    ];

    public function user() { return $this->belongsTo('App\\Models\\User','user_id'); }
}
