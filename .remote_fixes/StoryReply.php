<?php

namespace App\Models;

use App\Models\BaseModel;

class StoryReply extends BaseModel
{
    protected $table = 'story_replies';

    protected $fillable = [
        'story_id',
        'message_id',
        'user_id',
        'content',
    ];

    protected $casts = [
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];
}
