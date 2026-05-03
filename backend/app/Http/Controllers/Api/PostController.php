<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Post;
use App\Models\PostLike;
use App\Models\Comment;
use App\Models\Follow;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;

class PostController extends Controller
{
    public function index(Request $request)
    {
        $posts = Post::with(['user.profile', 'likes', 'comments.user'])
            ->withCount(['likes', 'comments'])
            ->orderBy('created_at', 'desc')
            ->paginate(15);

        $userId = Auth::id();

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
        } else {
            PostLike::create([
                'user_id' => $userId,
                'post_id' => $id,
            ]);
            $liked = true;
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

    private function formatPost($post, $userId)
    {
        $isLiked = $post->likes->contains('user_id', $userId);
        $isFollowed = Follow::where('follower_id', $userId)
            ->where('following_id', $post->user_id)
            ->exists();

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
    }
}
