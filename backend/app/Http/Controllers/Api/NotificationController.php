<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Notification;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class NotificationController extends Controller
{
    /**
     * GET /notifications
     * List notifikasi user login (paginated, eager load actor)
     */
    public function index(Request $request)
    {
        $notifications = Notification::where('user_id', Auth::id())
            ->with('actor:id,name', 'post')
            ->latest()
            ->paginate($request->get('per_page', 20));

        return response()->json([
            'data' => $notifications->items(),
            'pagination' => [
                'current_page' => $notifications->currentPage(),
                'last_page' => $notifications->lastPage(),
                'per_page' => $notifications->perPage(),
                'total' => $notifications->total(),
            ],
        ]);
    }

    /**
     * PUT /notifications/{id}/read
     * Tandai notifikasi sebagai sudah dibaca
     */
    public function markAsRead($id)
    {
        $notification = Notification::where('id', $id)
            ->where('user_id', Auth::id())
            ->firstOrFail();

        $notification->update([
            'read_at' => now(),
        ]);

        return response()->json([
            'message' => 'Notification marked as read',
            'data' => $notification,
        ]);
    }

    /**
     * PUT /notifications/read-all
     * Tandai semua notifikasi user sebagai sudah dibaca
     */
    public function markAllAsRead()
    {
        $updated = Notification::where('user_id', Auth::id())
            ->whereNull('read_at')
            ->update([
                'read_at' => now(),
            ]);

        return response()->json([
            'message' => 'All notifications marked as read',
            'updated_count' => $updated,
        ]);
    }

    /**
     * GET /notifications/unread-count
     * Jumlah notifikasi belum dibaca
     */
    public function unreadCount()
    {
        $count = Notification::where('user_id', Auth::id())
            ->unread()
            ->count();

        return response()->json([
            'unread_count' => $count,
        ]);
    }
}

