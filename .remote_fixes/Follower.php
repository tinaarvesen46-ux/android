<?php

namespace App\Models;

use App\Models\BaseModel;

class Follower extends BaseModel
{
    protected $table = 'followers';

    protected $fillable = [
        'follower_id',
        'followee_id',
    ];
}
