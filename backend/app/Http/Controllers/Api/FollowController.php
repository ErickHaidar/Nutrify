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

        if ($existing) {
            $existing->delete();
            $followed = false;
        } else {
            Follow::create([
                'follower_id' => $currentUserId,
                'following_id' => $userId,
            ]);
            $followed = true;

            // TRIGGER NOTIFIKASI: Kirim ke user yang di-follow
            $actor = User::find($currentUserId);

            // Simpan ke database
            Notification::create([
                'user_id' => $userId,
                'actor_id' => $currentUserId,
                'type' => 'follow',
                'title' => 'Pengikut Baru',
                'body' => "{$actor->name} mulai mengikuti Anda",
                'data' => [
                    'actor_name' => $actor->name,
                    'actor_id' => $actor->id,
                ],
            ]);

            // Kirim FCM push notification
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
        }

        return response()->json([
            'success'       => true,
            'followed'      => $followed,
            'followers_count' => $targetUser->getFollowersCount(),
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
        $isFollowing = Follow::where('follower_id', $currentUserId)
            ->where('following_id', $userId)
            ->exists();

        $avatarUrl = null;
        if ($user->profile && $user->profile->photo) {
            $avatarUrl = url('storage/' . $user->profile->photo);
        }

        $postsCount = $user->posts()->count();

        $posts = $user->posts->map(function ($post) use ($currentUserId, $avatarUrl) {
            $post->loadCount(['likes', 'comments']);
            $isLiked = $post->likes->contains('user_id', $currentUserId);
            $isFollowed = Follow::where('follower_id', $currentUserId)
                ->where('following_id', $post->user_id)
                ->exists();

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
                $isFollowing = Follow::where('follower_id', $currentUserId)
                    ->where('following_id', $user->id)
                    ->exists();

                return [
                    'id'              => $user->id,
                    'name'            => $user->name,
                    'username'        => $user->username,
                    'avatar_url'      => $user->avatar_url,
                    'is_following'    => $isFollowing,
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
            'username' => 'required|string|min:3|max:30|alpha_num|unique:users,username,' . Auth::id(),
        ]);

        $user = User::find(Auth::id());
        $user->username = strtolower($request->username);
        $user->save();

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
            'name'          => 'nullable|string|min:2|max:50',
            'username'      => 'nullable|string|min:3|max:30|alpha_num|unique:users,username,' . Auth::id(),
            'account_type'  => 'nullable|in:public,private',
        ]);

        $user = User::find(Auth::id());

        if ($request->has('name')) {
            $user->name = $request->name;
        }
        if ($request->has('username')) {
            $user->username = strtolower($request->username);
        }
        if ($request->has('account_type')) {
            $user->account_type = $request->account_type;
        }

        $user->save();

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
}
