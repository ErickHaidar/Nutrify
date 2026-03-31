<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class FoodLog extends Model
{
    // Nama tabel di database
    protected $table = 'food_logs';

    // Kolom yang boleh diisi (Mass Assignment)
    protected $fillable = [
        'user_id',
        'food_id',
        'serving_multiplier',
        'unit',
        'meal_time',
        'created_at'
    ];

    /**
     * Relasi ke User (Siapa yang makan)
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Relasi ke Food (Makanan apa yang dimakan)
     */
    public function food(): BelongsTo
    {
        return $this->belongsTo(Food::class);
    }
}
