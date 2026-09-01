<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Relations\BelongsTo;

class AiAgent extends BaseModel
{
    protected $table = 'ai_agents';

    protected $fillable = [
        'key',
        'user_id',
        'provider',
        'base_url',
        'model',
        'is_enabled',
        'metadata',
    ];

    protected $casts = [
        'is_enabled' => 'boolean',
        'metadata' => 'array',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
