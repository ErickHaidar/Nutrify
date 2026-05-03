<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Post;
use App\Models\PostLike;
use App\Models\Comment;
use App\Models\Follow;
use App\Models\Notification;
use App\Notifications\PushNotification;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;

class PostController extends Controller
{
    public function index(Request $request)
    {
        $userId = Auth::id();

        // Get IDs of users that the authenticated user follows
        $followingIds = Follow::where('follower_id', $userId)
            ->where('status', 'accepted')
            ->pluck('following_id')
            ->toArray();

        $posts = Post::with(['user.profile', 'likes', 'comments.user'])
            ->withCount(['likes', 'comments'])
            ->where(function ($query) use ($userId, $followingIds) {
                $query->where('user_id', $userId) // Own posts
                    ->orWhereHas('user', function ($q) {
                        $q->where('account_type', 'public'); // Public accounts
                    })
                    ->orWhereIn('user_id', $followingIds); // Followed users (any account type)
            })
            ->orderByRaw('is_pinned DESC, pinned_at DESC NULLS LAST, created_at DESC')
            ->paginate(15);

        $data = $posts->through(function ($post) use ($userId) {
            return $this->formatPost($post, $userId);
        });

        return response()->json(['success' => true, 'data' => $data]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'content' => 'required|string|max:1000',
            'image'   => 'nullable|image|mimes:jpeg,png,jpg,webp|max:10240',
        ]);

        $imageUrl = null;

        if ($request->hasFile('image')) {
            $path = $request->file('image')->store('posts', 'public');
            $imageUrl = Storage::url($path);
        }

        $post = Post::create([
            'user_id'   => Auth::id(),
            'content'   => $request->content,
            'image_url' => $imageUrl,
        ]);

        $post->load(['user.profile', 'likes', 'comments.user']);
        $post->loadCount(['likes', 'comments']);

        return response()->json([
            'success' => true,
            'message' => 'Post berhasil dibuat.',
            'data'    => $this->formatPost($post, Auth::id()),
        ], 201);
    }

    public function destroy($id)
    {
        $post = Post::where('user_id', Auth::id())->find($id);

        if (!$post) {
            return response()->json([
                'success' => false,
                'message' => 'Post tidak ditemukan atau bukan milik Anda.',
            ], 404);
        }

        if ($post->image_url) {
            $relativePath = str_replace('/storage/', '', $post->image_url);
            Storage::disk('public')->delete($relativePath);
        }

        $post->delete();

        return response()->json([
            'success' => true,
            'message' => 'Post berhasil dihapus.',
        ]);
    }

    public function toggleLike($id)
    {
        $post = Post::find($id);

        if (!$post) {
            return response()->json([
                'success' => false,
                'message' => 'Post tidak ditemukan.',
            ], 404);
        }

        $userId = Auth::id();
        $existing = PostLike::where('user_id', $userId)
            ->where('post_id', $id)
            ->first();

        if ($existing) {
            $existing->delete();
            $liked = false;

            // Hapus notifikasi like yang belum dibaca dari user ini
            Notification::where('user_id', $post->user_id)
                ->where('actor_id', $userId)
                ->where('type', 'like')
                ->where('post_id', $id)
                ->whereNull('read_at')
                ->delete();
        } else {
            PostLike::create([
                'user_id' => $userId,
                'post_id' => $id,
            ]);
            $liked = true;

            // TRIGGER NOTIFIKASI: Jika like post orang lain
            if ($post->user_id !== $userId) {
                $actor = User::find($userId);

                // Update atau buat notifikasi (hindari duplikat)
                Notification::updateOrCreate(
                    [
                        'user_id' => $post->user_id,
                        'actor_id' => $userId,
                        'type' => 'like',
                        'post_id' => $id,
                    ],
                    [
                        'title' => 'Suka Baru',
                        'body' => "{$actor->name} menyukai postingan Anda",
                        'data' => [
                            'actor_name' => $actor->name,
                            'actor_id' => $actor->id,
                        ],
                        'read_at' => null,
                    ]
                );

                // Kirim FCM push notification
                $postOwner = User::find($post->user_id);
                if ($postOwner && !empty($postOwner->fcm_token)) {
                    $notification = new PushNotification(
                        'Suka Baru',
                        "{$actor->name} menyukai postingan Anda",
                        'like',
                        ['post_id' => $id],
                        $actor,
                        $post
                    );

                    $notification->send($postOwner);
                }
            }
        }

        $post->loadCount('likes');

        return response()->json([
            'success' => true,
            'liked'   => $liked,
            'likes_count' => $post->likes_count,
        ]);
    }

    public function comments($id)
    {
        $post = Post::find($id);

        if (!$post) {
            return response()->json([
                'success' => false,
                'message' => 'Post tidak ditemukan.',
            ], 404);
        }

        $comments = Comment::where('post_id', $id)
            ->with('user')
            ->orderBy('created_at', 'asc')
            ->paginate(20);

        $data = $comments->through(function ($comment) {
            return [
                'id'         => $comment->id,
                'content'    => $comment->content,
                'user'       => [
                    'id'         => $comment->user->id,
                    'name'       => $comment->user->name,
                    'supabase_id' => $comment->user->supabase_id,
                ],
                'created_at' => $comment->created_at,
            ];
        });

        return response()->json(['success' => true, 'data' => $data]);
    }

    public function storeComment(Request $request, $id)
    {
        $post = Post::find($id);

        if (!$post) {
            return response()->json([
                'success' => false,
                'message' => 'Post tidak ditemukan.',
            ], 404);
        }

        $request->validate([
            'content' => 'required|string|max:500',
        ]);

        $comment = Comment::create([
            'user_id' => Auth::id(),
            'post_id' => $id,
            'content' => $request->content,
        ]);

        $comment->load('user');

        // TRIGGER NOTIFIKASI: Jika komentar di post orang lain
        if ($post->user_id !== Auth::id()) {
            $actor = User::find(Auth::id());

            // Simpan ke database
            Notification::create([
                'user_id' => $post->user_id,
                'actor_id' => Auth::id(),
                'type' => 'comment',
                'post_id' => $id,
                'title' => 'Komentar Baru',
                'body' => "{$actor->name} mengomentari postingan Anda",
                'data' => [
                    'actor_name' => $actor->name,
                    'actor_id' => $actor->id,
                    'comment_content' => $comment->content,
                ],
            ]);

            // Kirim FCM push notification
            $postOwner = User::find($post->user_id);
            if ($postOwner && !empty($postOwner->fcm_token)) {
                $notification = new PushNotification(
                    'Komentar Baru',
                    "{$actor->name} mengomentari postingan Anda",
                    'comment',
                    [
                        'post_id' => $id,
                        'comment_id' => $comment->id,
                        'comment_content' => $comment->content,
                    ],
                    $actor,
                    $post
                );

                $notification->send($postOwner);
            }
        }

        return response()->json([
            'success' => true,
            'message' => 'Komentar berhasil ditambahkan.',
            'data'    => [
                'id'         => $comment->id,
                'content'    => $comment->content,
                'user'       => [
                    'id'         => $comment->user->id,
                    'name'       => $comment->user->name,
                    'supabase_id' => $comment->user->supabase_id,
                ],
                'created_at' => $comment->created_at,
            ],
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $post = Post::where('user_id', Auth::id())->find($id);

        if (!$post) {
            return response()->json([
                'success' => false,
                'message' => 'Post tidak ditemukan atau bukan milik Anda.',
            ], 404);
        }

        if ($post->created_at->diffInHours(now()) >= 1) {
            return response()->json([
                'success' => false,
                'message' => 'Postingan hanya bisa diedit dalam 1 jam setelah dibuat.',
            ], 403);
        }

        $request->validate([
            'content' => 'required|string|max:1000',
        ]);

        $post->update(['content' => $request->content]);

        $post->load(['user.profile', 'likes', 'comments.user']);
        $post->loadCount(['likes', 'comments']);

        return response()->json([
            'success' => true,
            'message' => 'Postingan berhasil diperbarui.',
            'data'    => $this->formatPost($post, Auth::id()),
        ]);
    }

    public function togglePin($id)
    {
        $post = Post::where('user_id', Auth::id())->find($id);

        if (!$post) {
            return response()->json([
                'success' => false,
                'message' => 'Post tidak ditemukan atau bukan milik Anda.',
            ], 404);
        }

        if ($post->is_pinned) {
            $post->update(['is_pinned' => false, 'pinned_at' => null]);
            return response()->json([
                'success'   => true,
                'is_pinned' => false,
                'message'   => 'Sematan dilepas.',
            ]);
        }

        $pinnedCount = Post::where('user_id', Auth::id())->where('is_pinned', true)->count();

        if ($pinnedCount >= 3) {
            $oldest = Post::where('user_id', Auth::id())
                ->where('is_pinned', true)
                ->orderBy('pinned_at', 'asc')
                ->first();
            if ($oldest) {
                $oldest->update(['is_pinned' => false, 'pinned_at' => null]);
            }
        }

        $post->update(['is_pinned' => true, 'pinned_at' => now()]);

        return response()->json([
            'success'   => true,
            'is_pinned' => true,
            'message'   => 'Postingan disematkan.',
        ]);
    }

    private function formatPost($post, $userId)
    {
        $isLiked = $post->likes->contains('user_id', $userId);
        $followRecord = Follow::where('follower_id', $userId)
            ->where('following_id', $post->user_id)
            ->first();
        $isFollowed = $followRecord && $followRecord->status === 'accepted';
        $isRequested = $followRecord && $followRecord->status === 'pending';

        $avatarUrl = null;
        if ($post->user->profile && $post->user->profile->photo) {
            $avatarUrl = url('storage/' . $post->user->profile->photo);
        } elseif ($post->user->avatar) {
            $avatarUrl = url('storage/' . $post->user->avatar);
        }

        return [
            'id'            => $post->id,
            'content'       => $post->content,
            'image_url'     => $post->image_url,
            'created_at'    => $post->created_at,
            'user'          => [
                'id'                => $post->user->id,
                'name'              => $post->user->name,
                'supabase_id'       => $post->user->supabase_id,
                'username'          => $post->user->username,
                'avatar_url'        => $avatarUrl,
                'account_type'      => $post->user->account_type ?? 'public',
            ],
            'is_liked'       => $isLiked,
            'is_pinned'      => $post->is_pinned,
            'pinned_at'      => $post->pinned_at,
            'is_followed'    => $isFollowed,
            'is_requested'   => $isRequested,
            'likes_count'    => $post->likes_count,
            'comments_count' => $post->comments_count,
        ];
    }
}
