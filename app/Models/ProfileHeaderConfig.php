<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ProfileHeaderConfig extends Model
{
    use HasFactory;

    protected $table = 'profile_header_configs';
    protected $fillable = ['user_id','config','config_hash'];
    protected $casts = ['config' => 'array'];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
