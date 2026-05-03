<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\ProfileController;
use App\Http\Controllers\Api\FoodController;
use App\Http\Controllers\Api\FavoriteController;
use App\Http\Controllers\Api\PostController;
use App\Http\Controllers\Api\OtpController;
use App\Http\Controllers\Api\FollowController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\ChatController;
use App\Http\Controllers\FoodLogController;

// OTP Verification (public, no auth required)
Route::post('/auth/send-otp', [OtpController::class, 'send']);
Route::post('/auth/verify-otp', [OtpController::class, 'verify']);

Route::middleware(['supabase.auth'])->group(function () {

    // Profile
    Route::post('/profile/store', [ProfileController::class, 'store']);
    Route::get('/profile', [ProfileController::class, 'show']);
    Route::post('/profile/fcm-token', [ProfileController::class, 'updateFcmToken']);
    Route::put('/profile/photo', [ProfileController::class, 'photo']);

    //Photo
    Route::post('/profile/photo', [ProfileController::class, 'photo']);

    // Foods — GET /api/foods?search=&page=
    Route::get('/foods', [FoodController::class, 'index']);
    Route::get('/food/recommendations', [FoodController::class, 'recommendations']);

    // Favorites
    Route::get('/food/favorites', [FavoriteController::class, 'index']);
    Route::post('/food/favorites', [FavoriteController::class, 'store']);
    Route::delete('/food/favorites/{food_id}', [FavoriteController::class, 'destroy']);

    // Food Logs
    Route::post('/food-logs', [FoodLogController::class, 'store']);
    Route::get('/food-logs/summary', [FoodLogController::class, 'summary']);
    Route::get('/food-logs', [FoodLogController::class, 'index']);
    Route::get('/food-logs/{id}', [FoodLogController::class, 'show']);
    Route::put('/food-logs/{id}', [FoodLogController::class, 'update']);
    Route::delete('/food-logs/{id}', [FoodLogController::class, 'destroy']);

    // Community Posts
    Route::get('/posts', [PostController::class, 'index']);
    Route::post('/posts', [PostController::class, 'store']);
    Route::put('/posts/{id}', [PostController::class, 'update']);
    Route::delete('/posts/{id}', [PostController::class, 'destroy']);
    Route::post('/posts/{id}/pin', [PostController::class, 'togglePin']);
    Route::post('/posts/{id}/like', [PostController::class, 'toggleLike']);
    Route::get('/posts/{id}/comments', [PostController::class, 'comments']);
    Route::post('/posts/{id}/comments', [PostController::class, 'storeComment']);

    // Follow System
    Route::post('/users/{id}/follow', [FollowController::class, 'toggleFollow']);
    Route::post('/follow-requests/{id}/approve', [FollowController::class, 'approveFollow']);
    Route::post('/follow-requests/{id}/reject', [FollowController::class, 'rejectFollow']);
    Route::get('/users/{id}/profile', [FollowController::class, 'userProfile']);
    Route::get('/users/search', [FollowController::class, 'searchUsers']);
    Route::put('/username', [FollowController::class, 'updateUsername']);
    Route::put('/account-type', [FollowController::class, 'updateAccountType']);

    // My Profile
    Route::get('/users/me', [FollowController::class, 'getMe']);
    Route::put('/users/profile', [FollowController::class, 'updateProfile']);

    // Notifications
    Route::get('/notifications', [NotificationController::class, 'index']);
    Route::put('/notifications/read-all', [NotificationController::class, 'markAllAsRead']);
    Route::put('/notifications/{id}/read', [NotificationController::class, 'markAsRead']);
    Route::get('/notifications/unread-count', [NotificationController::class, 'unreadCount']);

    // Chat / Direct Messages
    Route::get('/chat/conversations', [ChatController::class, 'index']);
    Route::post('/chat/conversations', [ChatController::class, 'store']);
    Route::get('/chat/conversations/{id}/messages', [ChatController::class, 'messages']);
    Route::post('/chat/conversations/{id}/messages', [ChatController::class, 'sendMessage']);
    Route::put('/chat/conversations/{id}/read', [ChatController::class, 'markAsRead']);
    Route::get('/chat/unread-count', [ChatController::class, 'unreadCount']);
    Route::post('/chat/mark-all-read', [ChatController::class, 'markAllRead']);
});
