<?php

namespace App\Notifications;

use App\Services\FCMService;
use App\Models\User;
use Illuminate\Bus\Queueable;

class PushNotification
{
    use Queueable;

    private $title;
    private $body;
    private $type;
    private $data;
    private $actor;
    private $post;

    public function __construct($title, $body, $type, $data = [], $actor = null, $post = null)
    {
        $this->title = $title;
        $this->body = $body;
        $this->type = $type; // 'like', 'comment', 'follow'
        $this->data = $data;
        $this->actor = $actor;
        $this->post = $post;
    }

    /**
     * Kirim push notification ke user
     */
    public function send(User $user)
    {
        // Kalau user tidak punya fcm_token, skip
        if (empty($user->fcm_token)) {
            return false;
        }

        $fcmService = new FCMService();

        // Data tambahan untuk notifikasi
        $notificationData = array_merge($this->data, [
            'type' => $this->type,
            'click_action' => 'FLUTTER_NOTIFICATION_CLICK',
            'sound' => 'default',
        ]);

        // Tambah actor info jika ada
        if ($this->actor) {
            $notificationData['actor_id'] = $this->actor->id;
            $notificationData['actor_name'] = $this->actor->name;
            $notificationData['actor_avatar'] = $this->actor->avatar_url ?? null;
        }

        // Tambah post info jika ada
        if ($this->post) {
            $notificationData['post_id'] = $this->post->id;
        }

        return $fcmService->sendNotification(
            $user->fcm_token,
            $this->title,
            $this->body,
            $notificationData
        );
    }
}
