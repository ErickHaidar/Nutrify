<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Profile extends Model
{
    protected $fillable = [
    'user_id',
    'age',
    'weight',
    'height',
    'gender',
    'goal',
    'activity_level',
    'target_weight',
    'photo'
];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
