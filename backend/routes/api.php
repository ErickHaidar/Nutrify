<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\ProfileController;
use App\Http\Controllers\Api\FoodController;
use App\Http\Controllers\FoodLogController;

Route::middleware(['supabase.auth'])->group(function () {

    // Profile
    Route::post('/profile/store', [ProfileController::class, 'store']);
    Route::get('/profile', [ProfileController::class, 'show']);

    // Foods — GET /api/foods?search=&page=
    Route::get('/foods', [FoodController::class, 'index']);

    // Food Logs
    Route::post('/food-logs', [FoodLogController::class, 'store']);
    Route::get('/food-logs/summary', [FoodLogController::class, 'summary']);
    Route::get('/food-logs', [FoodLogController::class, 'index']);
    Route::get('/food-logs/{id}', [FoodLogController::class, 'show']);
    Route::put('/food-logs/{id}', [FoodLogController::class, 'update']);
    Route::delete('/food-logs/{id}', [FoodLogController::class, 'destroy']);
});
