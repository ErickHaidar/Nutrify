<?php

namespace App\Http\Controllers\Api;

use App\Models\Conversation;
use App\Models\Message;
use App\Models\Notification;
use App\Models\User;
use App\Notifications\PushNotification;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class ChatController
{
    // GET /chat/conversations?filter=&search=&page=
    public function index(Request $request)
    {
        $userId = Auth::id();
        $filter = $request->query('filter', 'all');
        $search = $request->query('search', '');
        $page = (int) $request->query('page', 1);

        $query = Conversation::with(['user1', 'user2', 'lastMessage'])
            ->forUser($userId)
            ->orderBy('last_message_at', 'desc');

        $conversations = $query->paginate(30, ['*'], 'page', $page);

        $formatted = $conversations->through(function ($conv) use ($userId, $search) {
            $other = $conv->getOtherUser($userId);

            if ($search && !str_contains(strtolower($other->name), strtolower($search))
                && !str_contains(strtolower($other->username ?? ''), strtolower($search))) {
                return null;
            }

            $unread = $conv->getUnreadCountFor($userId);
            $lastMsg = $conv->lastMessage;

            return [
                'id' => $conv->id,
                'other_user_id' => $other->id,
                'other_user_name' => $other->name,
                'other_username' => $other->username,
                'other_user_avatar_url' => $other->avatar
                    ? 'https://nutrify-app.my.id/storage/' . $other->avatar
                    : null,
                'last_message' => $lastMsg ? [
                    'content' => $lastMsg->content,
                    'image_url' => $lastMsg->image_url
                        ? 'https://nutrify-app.my.id/storage/' . $lastMsg->image_url
                        : null,
                    'created_at' => $lastMsg->created_at->toIso8601String(),
                ] : null,
                'unread_count' => $unread,
                'created_at' => $conv->created_at->toIso8601String(),
            ];
        })->filter()->values();

        return response()->json([
            'success' => true,
            'data' => $formatted,
            'current_page' => $conversations->currentPage(),
            'last_page' => $conversations->lastPage(),
        ]);
    }

    // POST /chat/conversations  { user_id }
    public function store(Request $request)
    {
        $request->validate([
            'user_id' => 'required|integer|exists:users,id',
        ]);

        $otherUserId = $request->user_id;
        $userId = Auth::id();

        if ($otherUserId === $userId) {
            return response()->json([
                'success' => false,
                'message' => 'Tidak dapat mengirim pesan ke diri sendiri.',
            ], 422);
        }

        $user1Id = min($userId, $otherUserId);
        $user2Id = max($userId, $otherUserId);

        $conversation = Conversation::firstOrCreate(
            ['user1_id' => $user1Id, 'user2_id' => $user2Id],
            ['last_message_at' => now()]
        );

        $other = $conversation->getOtherUser($userId);

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $conversation->id,
                'other_user_id' => $other->id,
                'other_user_name' => $other->name,
                'other_username' => $other->username,
                'other_user_avatar_url' => $other->avatar
                    ? 'https://nutrify-app.my.id/storage/' . $other->avatar
                    : null,
                'created_at' => $conversation->created_at->toIso8601String(),
            ],
        ]);
    }

    // GET /chat/conversations/{id}/messages?page=
    public function messages(Request $request, $id)
    {
        $conversation = Conversation::find($id);
        if (!$conversation) {
            return response()->json(['success' => false, 'message' => 'Percakapan tidak ditemukan.'], 404);
        }

        $userId = Auth::id();
        if ($conversation->user1_id !== $userId && $conversation->user2_id !== $userId) {
            return response()->json(['success' => false, 'message' => 'Akses ditolak.'], 403);
        }

        $messages = Message::where('conversation_id', $id)
            ->orderBy('created_at', 'asc')
            ->paginate(30);

        $formatted = $messages->through(fn($msg) => [
            'id' => $msg->id,
            'sender_id' => $msg->sender_id,
            'content' => $msg->content,
            'image_url' => $msg->image_url
                ? 'https://nutrify-app.my.id/storage/' . $msg->image_url
                : null,
            'is_read' => $msg->is_read,
            'created_at' => $msg->created_at->toIso8601String(),
        ]);

        return response()->json([
            'success' => true,
            'data' => $formatted,
        ]);
    }

    // POST /chat/conversations/{id}/messages  { content?, image? }
    public function sendMessage(Request $request, $id)
    {
        $conversation = Conversation::find($id);
        if (!$conversation) {
            return response()->json(['success' => false, 'message' => 'Percakapan tidak ditemukan.'], 404);
        }

        $userId = Auth::id();
        if ($conversation->user1_id !== $userId && $conversation->user2_id !== $userId) {
            return response()->json(['success' => false, 'message' => 'Akses ditolak.'], 403);
        }

        $request->validate([
            'content' => 'nullable|string|max:1000',
            'image' => 'nullable|image|mimes:jpg,jpeg,png,webp|max:10240',
        ]);

        if (!$request->filled('content') && !$request->hasFile('image')) {
            return response()->json([
                'success' => false,
                'message' => 'Pesan harus berisi teks atau gambar.',
            ], 422);
        }

        $imageUrl = null;
        if ($request->hasFile('image')) {
            $file = $request->file('image');
            $filename = $userId . '_' . time() . '.' . $file->getClientOriginalExtension();
            $imageUrl = $file->storeAs('chat_images', $filename, 'public');
        }

        $message = Message::create([
            'conversation_id' => $id,
            'sender_id' => $userId,
            'content' => $request->content,
            'image_url' => $imageUrl,
            'is_read' => false,
        ]);

        $conversation->update(['last_message_at' => now()]);

        // Mark all unread messages from other user as read
        Message::where('conversation_id', $id)
            ->where('sender_id', '!=', $userId)
            ->where('is_read', false)
            ->update(['is_read' => true]);

        // Send notification to the other user
        $recipient = $conversation->getOtherUser($userId);
        $actor = User::find($userId);

        $preview = $message->content
            ? Str::limit($message->content, 50)
            : '[Gambar]';

        Notification::updateOrCreate(
            [
                'user_id' => $recipient->id,
                'actor_id' => $userId,
                'type' => 'message',
            ],
            [
                'title' => 'Pesan Baru',
                'body' => "{$actor->name}: {$preview}",
                'data' => json_encode([
                    'conversation_id' => $conversation->id,
                    'actor_name' => $actor->name,
                    'actor_id' => $actor->id,
                ]),
                'read_at' => null,
            ]
        );

        if (!empty($recipient->fcm_token)) {
            $pushNotif = new PushNotification(
                'Pesan Baru',
                "{$actor->name}: {$preview}",
                'message',
                ['conversation_id' => $conversation->id],
                $actor,
                null
            );
            $pushNotif->send($recipient);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $message->id,
                'sender_id' => $message->sender_id,
                'content' => $message->content,
                'image_url' => $message->image_url
                    ? 'https://nutrify-app.my.id/storage/' . $message->image_url
                    : null,
                'is_read' => $message->is_read,
                'created_at' => $message->created_at->toIso8601String(),
            ],
        ], 201);
    }

    // PUT /chat/conversations/{id}/read
    public function markAsRead($id)
    {
        $conversation = Conversation::find($id);
        if (!$conversation) {
            return response()->json(['success' => false, 'message' => 'Percakapan tidak ditemukan.'], 404);
        }

        $userId = Auth::id();
        if ($conversation->user1_id !== $userId && $conversation->user2_id !== $userId) {
            return response()->json(['success' => false, 'message' => 'Akses ditolak.'], 403);
        }

        $count = Message::where('conversation_id', $id)
            ->where('sender_id', '!=', $userId)
            ->where('is_read', false)
            ->update(['is_read' => true]);

        return response()->json([
            'success' => true,
            'marked_count' => $count,
        ]);
    }

    // GET /chat/unread-count
    public function unreadCount()
    {
        $userId = Auth::id();

        $conversationIds = Conversation::forUser($userId)->pluck('id');

        $count = Message::whereIn('conversation_id', $conversationIds)
            ->where('sender_id', '!=', $userId)
            ->where('is_read', false)
            ->count();

        return response()->json([
            'success' => true,
            'unread_count' => $count,
        ]);
    }

    // POST /chat/mark-all-read
    public function markAllRead()
    {
        $userId = Auth::id();
        $conversationIds = Conversation::forUser($userId)->pluck('id');

        $count = Message::whereIn('conversation_id', $conversationIds)
            ->where('sender_id', '!=', $userId)
            ->where('is_read', false)
            ->update(['is_read' => true]);

        return response()->json([
            'success' => true,
            'marked_count' => $count,
        ]);
    }
}
