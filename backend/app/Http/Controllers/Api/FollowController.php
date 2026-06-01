<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Follow;
use App\Models\User;
use App\Models\Notification;
use App\Notifications\PushNotification;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class FollowController extends Controller
{
    public function toggleFollow(Request $request, $userId)
    {
        $currentUserId = Auth::id();

        if ($currentUserId == $userId) {
            return response()->json([
                'success' => false,
                'message' => 'Tidak dapat mengikuti diri sendiri.',
            ], 422);
        }

        $targetUser = User::find($userId);
        if (!$targetUser) {
            return response()->json([
                'success' => false,
                'message' => 'User tidak ditemukan.',
            ], 404);
        }

        $existing = Follow::where('follower_id', $currentUserId)
            ->where('following_id', $userId)
            ->first();

        // Case A: Existing record — unfollow or cancel request
        if ($existing) {
            $wasPending = $existing->status === 'pending';
            $existing->delete();

            Notification::where('user_id', $userId)
                ->where('actor_id', $currentUserId)
                ->whereIn('type', ['follow', 'follow_request'])
                ->delete();

            return response()->json([
                'success'         => true,
                'followed'        => false,
                'requested'       => false,
                'followers_count' => $targetUser->getFollowersCount(),
            ]);
        }

        // No existing record — determine status by account type
        $isPrivate = ($targetUser->account_type ?? 'public') === 'private';
        $status = $isPrivate ? 'pending' : 'accepted';

        Follow::create([
            'follower_id'  => $currentUserId,
            'following_id' => $userId,
            'status'       => $status,
        ]);

        $actor = User::find($currentUserId);

        if ($isPrivate) {
            // Follow request for private account
            Notification::updateOrCreate(
                [
                    'user_id'  => $userId,
                    'actor_id' => $currentUserId,
                    'type'     => 'follow_request',
                ],
                [
                    'title'   => 'Permintaan Ikuti',
                    'body'    => "{$actor->name} ingin mengikuti Anda",
                    'data'    => [
                        'actor_name' => $actor->name,
                        'actor_id'   => $actor->id,
                    ],
                    'read_at' => null,
                ]
            );

            $cacheKey = "follow_spam_{$currentUserId}_{$userId}";
            if (!\Illuminate\Support\Facades\Cache::has($cacheKey)) {
                if (!empty($targetUser->fcm_token)) {
                    $notification = new PushNotification(
                        'Permintaan Ikuti',
                        "{$actor->name} ingin mengikuti Anda",
                        'follow_request',
                        ['actor_id' => $currentUserId],
                        $actor,
                        null
                    );
                    $notification->send($targetUser);
                }
                \Illuminate\Support\Facades\Cache::put($cacheKey, true, now()->addHours(1));
            }

            return response()->json([
                'success'         => true,
                'followed'        => false,
                'requested'       => true,
                'followers_count' => $targetUser->getFollowersCount(),
            ]);
        }

        // Public account: instant follow
        Notification::updateOrCreate(
            [
                'user_id'  => $userId,
                'actor_id' => $currentUserId,
                'type'     => 'follow',
            ],
            [
                'title'   => 'Pengikut Baru',
                'body'    => "{$actor->name} mulai mengikuti Anda",
                'data'    => ['actor_name' => $actor->name, 'actor_id' => $actor->id],
                'read_at' => null,
            ]
        );

        $cacheKey = "follow_spam_{$currentUserId}_{$userId}";
        if (!\Illuminate\Support\Facades\Cache::has($cacheKey)) {
            if (!empty($targetUser->fcm_token)) {
                $notification = new PushNotification(
                    'Pengikut Baru',
                    "{$actor->name} mulai mengikuti Anda",
                    'follow',
                    ['actor_id' => $currentUserId],
                    $actor,
                    null
                );
                $notification->send($targetUser);
            }
            \Illuminate\Support\Facades\Cache::put($cacheKey, true, now()->addHours(1));
        }

        return response()->json([
            'success'         => true,
            'followed'        => true,
            'requested'       => false,
            'followers_count' => $targetUser->getFollowersCount(),
        ]);
    }

    public function approveFollow($userId)
    {
        $currentUserId = Auth::id();

        $follow = Follow::where('follower_id', $userId)
            ->where('following_id', $currentUserId)
            ->where('status', 'pending')
            ->first();

        if (!$follow) {
            return response()->json([
                'success' => false,
                'message' => 'Permintaan tidak ditemukan.',
            ], 404);
        }

        $follow->update(['status' => 'accepted']);

        $actor = User::find($userId);
        Notification::where('user_id', $currentUserId)
            ->where('actor_id', $userId)
            ->where('type', 'follow_request')
            ->update([
                'type'   => 'follow',
                'title'  => 'Pengikut Baru',
                'body'   => ($actor ? $actor->name : 'User') . ' mulai mengikuti Anda',
                'read_at' => now(),
            ]);

        return response()->json([
            'success' => true,
            'message' => 'Permintaan berhasil disetujui.',
        ]);
    }

    public function rejectFollow($userId)
    {
        $currentUserId = Auth::id();

        $follow = Follow::where('follower_id', $userId)
            ->where('following_id', $currentUserId)
            ->where('status', 'pending')
            ->first();

        if (!$follow) {
            return response()->json([
                'success' => false,
                'message' => 'Permintaan tidak ditemukan.',
            ], 404);
        }

        $follow->delete();

        Notification::where('user_id', $currentUserId)
            ->where('actor_id', $userId)
            ->where('type', 'follow_request')
            ->delete();

        return response()->json([
            'success' => true,
            'message' => 'Permintaan ditolak.',
        ]);
    }

    public function userProfile($userId)
    {
        $user = User::with('posts', 'posts.likes', 'posts.comments.user', 'profile')->find($userId);

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'User tidak ditemukan.',
            ], 404);
        }

        $currentUserId = Auth::id();
        $followRecord = Follow::where('follower_id', $currentUserId)
            ->where('following_id', $userId)
            ->first();
        $isFollowing = $followRecord && $followRecord->status === 'accepted';
        $isRequested = $followRecord && $followRecord->status === 'pending';

        $avatarUrl = null;
        if ($user->profile && $user->profile->photo) {
            $avatarUrl = url('storage/' . $user->profile->photo);
        }

        $postsCount = $user->posts()->count();

        $posts = $user->posts->map(function ($post) use ($currentUserId, $avatarUrl) {
            $post->loadCount(['likes', 'comments']);
            $isLiked = $post->likes->contains('user_id', $currentUserId);
            $followRec = Follow::where('follower_id', $currentUserId)
                ->where('following_id', $post->user_id)
                ->first();
            $isFollowed = $followRec && $followRec->status === 'accepted';

            return [
                'id'             => $post->id,
                'content'        => $post->content,
                'image_url'      => $post->image_url,
                'created_at'     => $post->created_at,
                'user'           => [
                    'id'          => $post->user->id,
                    'name'        => $post->user->name,
                    'supabase_id' => $post->user->supabase_id,
                    'username'    => $post->user->username,
                    'avatar_url'  => $avatarUrl,
                ],
                'is_liked'       => $isLiked,
                'is_pinned'      => $post->is_pinned,
                'pinned_at'      => $post->pinned_at,
                'is_followed'    => $isFollowed,
                'likes_count'    => $post->likes_count,
                'comments_count' => $post->comments_count,
            ];
        });

        return response()->json([
            'success' => true,
            'data'    => [
                'id'              => $user->id,
                'name'            => $user->name,
                'username'        => $user->username,
                'avatar_url'      => $avatarUrl,
                'account_type'    => $user->account_type ?? 'public',
                'is_private'      => ($user->account_type ?? 'public') === 'private',
                'is_following'    => $isFollowing,
                'is_requested'    => $isRequested,
                'followers_count' => $user->getFollowersCount(),
                'followings_count' => $user->getFollowingsCount(),
                'posts_count'     => $postsCount,
                'posts'           => $posts,
            ],
        ]);
    }

    public function searchUsers(Request $request)
    {
        $request->validate([
            'q' => 'required|string|min:2|max:50',
        ]);

        $query = $request->input('q');
        $currentUserId = Auth::id();

        $users = User::where('id', '!=', $currentUserId)
            ->where(function ($q) use ($query) {
                $q->where('name', 'LIKE', "%{$query}%")
                  ->orWhere('username', 'LIKE', "%{$query}%");
            })
            ->limit(20)
            ->get()
            ->map(function ($user) use ($currentUserId) {
                $followRec = Follow::where('follower_id', $currentUserId)
                    ->where('following_id', $user->id)
                    ->first();
                $isFollowing = $followRec && $followRec->status === 'accepted';
                $isRequested = $followRec && $followRec->status === 'pending';

                return [
                    'id'              => $user->id,
                    'name'            => $user->name,
                    'username'        => $user->username,
                    'avatar_url'      => $user->avatar_url,
                    'is_following'    => $isFollowing,
                    'is_requested'    => $isRequested,
                    'followers_count' => $user->getFollowersCount(),
                ];
            });

        return response()->json([
            'success' => true,
            'data'    => $users,
        ]);
    }

    public function updateUsername(Request $request)
    {
        $request->validate([
            'username' => 'required|string|min:3|max:20|regex:/^[a-zA-Z0-9_]+$/|unique:users,username,' . Auth::id(),
        ], [
            'username.required' => 'Username wajib diisi.',
            'username.min' => 'Username minimal 3 karakter.',
            'username.max' => 'Username maksimal 20 karakter.',
            'username.regex' => 'Username hanya boleh berisi huruf, angka, dan underscore (_).',
            'username.unique' => 'Username sudah digunakan oleh orang lain.',
        ]);

        $user = User::find(Auth::id());
        $newUsername = strtolower($request->username);

        if ($newUsername !== $user->username) {
            if (!$this->checkUsernameRateLimit($user->id)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Anda telah mencapai batas maksimum perubahan username (3 kali per 24 jam).',
                ], 429);
            }

            $user->username = $newUsername;
            $user->save();

            $this->recordUsernameChange($user->id);
        }

        return response()->json([
            'success'  => true,
            'message'  => 'Username berhasil diperbarui.',
            'username' => $user->username,
        ]);
    }

    public function updateAccountType(Request $request)
    {
        $request->validate([
            'account_type' => 'required|in:public,private',
        ]);

        $user = User::find(Auth::id());
        $user->account_type = $request->account_type;
        $user->save();

        // When switching to public, auto-accept all pending follow requests
        if ($request->account_type === 'public') {
            Follow::where('following_id', Auth::id())
                ->where('status', 'pending')
                ->update(['status' => 'accepted']);
        }

        return response()->json([
            'success'      => true,
            'message'      => 'Tipe akun berhasil diperbarui.',
            'account_type' => $user->account_type,
        ]);
    }

    public function getMe()
    {
        $user = User::with('profile', 'posts')->find(Auth::id());

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'User tidak ditemukan.',
            ], 404);
        }

        $avatarUrl = null;
        if ($user->profile && $user->profile->photo) {
            $avatarUrl = url('storage/' . $user->profile->photo);
        }

        return response()->json([
            'success' => true,
            'data'    => [
                'id'               => $user->id,
                'name'             => $user->name,
                'username'         => $user->username,
                'email'            => $user->email,
                'avatar_url'       => $avatarUrl,
                'account_type'     => $user->account_type ?? 'public',
                'is_private'       => ($user->account_type ?? 'public') === 'private',
                'followers_count'  => $user->getFollowersCount(),
                'followings_count' => $user->getFollowingsCount(),
                'posts_count'      => $user->posts()->count(),
            ],
        ]);
    }

    public function updateProfile(Request $request)
    {
        $request->validate([
            'name'          => 'sometimes|nullable|string|min:1|max:50',
            'username'      => 'sometimes|nullable|string|min:3|max:20|regex:/^[a-zA-Z0-9_]+$/|unique:users,username,' . Auth::id(),
            'account_type'  => 'sometimes|nullable|in:public,private',
        ], [
            'username.min' => 'Username minimal 3 karakter.',
            'username.max' => 'Username maksimal 20 karakter.',
            'username.regex' => 'Username hanya boleh berisi huruf, angka, dan underscore (_).',
            'username.unique' => 'Username sudah digunakan oleh orang lain.',
        ]);

        $user = User::find(Auth::id());
        $usernameChanged = false;

        if ($request->has('name')) {
            $user->name = $request->name;
        }
        if ($request->has('username')) {
            $newUsername = strtolower($request->username);
            if ($newUsername !== $user->username) {
                if (!$this->checkUsernameRateLimit($user->id)) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Anda telah mencapai batas maksimum perubahan username (3 kali per 24 jam).',
                    ], 429);
                }
                $user->username = $newUsername;
                $usernameChanged = true;
            }
        }
        if ($request->has('account_type')) {
            $user->account_type = $request->account_type;
        }

        $user->save();

        if ($usernameChanged) {
            $this->recordUsernameChange($user->id);
        }

        return response()->json([
            'success' => true,
            'message' => 'Profil berhasil diperbarui.',
            'data'    => [
                'name'         => $user->name,
                'username'     => $user->username,
                'account_type' => $user->account_type,
            ],
        ]);
    }

    private function checkUsernameRateLimit($userId)
    {
        $cacheKey = "username_changes_{$userId}";
        $changes = \Illuminate\Support\Facades\Cache::get($cacheKey, []);

        $now = time();
        // Keep only changes within the last 24 hours
        $changes = array_filter($changes, function ($timestamp) use ($now) {
            return ($now - $timestamp) < 24 * 3600;
        });

        if (count($changes) >= 3) {
            return false;
        }

        return true;
    }

    private function recordUsernameChange($userId)
    {
        $cacheKey = "username_changes_{$userId}";
        $changes = \Illuminate\Support\Facades\Cache::get($cacheKey, []);

        $now = time();
        $changes = array_filter($changes, function ($timestamp) use ($now) {
            return ($now - $timestamp) < 24 * 3600;
        });

        $changes[] = $now;
        \Illuminate\Support\Facades\Cache::put($cacheKey, $changes, now()->addDays(1));
    }
}
