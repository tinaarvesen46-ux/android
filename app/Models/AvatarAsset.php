<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AvatarAsset extends Model
{
    use HasFactory;

    protected $table = 'avatar_assets';
    protected $fillable = ['asset_id','category','filename','mime','meta','enabled'];
    protected $casts = ['meta' => 'array', 'enabled' => 'boolean'];
}
