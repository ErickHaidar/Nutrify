<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Food extends Model
{
    protected $table = 'foods';

    protected $fillable = [
        'name',
        'serving_size',
        'calories',
        'protein',
        'carbohydrates',
        'fat',
        'sugar',
        'sodium',
        'fiber',
    ];

    protected $casts = [
        'calories'      => 'float',
        'protein'       => 'float',
        'carbohydrates' => 'float',
        'fat'           => 'float',
        'sugar'         => 'float',
        'sodium'        => 'float',
        'fiber'         => 'float',
    ];

    public function favorites(): HasMany
    {
        return $this->hasMany(UserFavorite::class);
    }

    public function foodLogs(): HasMany
    {
        return $this->hasMany(FoodLog::class);
    }
}
