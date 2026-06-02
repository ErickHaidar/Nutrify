<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class WeightLog extends Model
{
    protected $fillable = ['user_id', 'weight'];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
