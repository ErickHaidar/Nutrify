# Guide Deploy — FCM Fix + Notification API

> **VPS:** `103.253.212.55` | **Path:** `/var/www/nutrify-app/backend/`
> **Perubahan:**
> 1. FCM data payload — semua value di-cast ke string
> 2. Notification API (sudah di-deploy sebelumnya, verifikasi saja)

---

## Step 1: SCP file yang berubah ke VPS

### FCMService Fix
```bash
scp "C:\Users\Ibnu Habib\Documents\pdbl\baru\Nutrify\backend\app\Services\FCMService.php" root@103.253.212.55:/var/www/nutrify-app/backend/app/Services/FCMService.php
```

### ProfileController (WHO BMI + Macronutrien + FCM endpoint)
```bash
scp "C:\Users\Ibnu Habib\Documents\pdbl\baru\Nutrify\backend\app\Http\Controllers\Api\ProfileController.php" root@103.253.212.55:/var/www/nutrify-app/backend/app/Http/Controllers/Api/ProfileController.php
```

## Step 2: SSH ke VPS

```bash
ssh root@103.253.212.55
```

## Step 3: Clear cache Laravel

```bash
cd /var/www/nutrify-app/backend
php artisan config:clear
php artisan cache:clear
```

## Step 4: Verifikasi Notification API

Cek bahwa notification endpoints sudah ada di routes:

```bash
php artisan route:list | grep notification
```

Harusnya muncul 4 route:
```
GET  api/notifications
PUT  api/notifications/read-all
PUT  api/notifications/{id}/read
GET  api/notifications/unread-count
```

## Step 5: Verifikasi FCM Fix

Cek bahwa FCMService sudah benar:

```bash
grep "array_map" /var/www/nutrify-app/backend/app/Services/FCMService.php
```

Harusnya output:
```
'data' => array_map('strval', array_filter($data, fn($v) => $v !== null)),
```

## Step 6: Test push notification (opsional)

Trigger test dari app:
1. User A follow User B → User B harus terima push notification
2. User A like post User B → User B harus terima push notification
3. User A comment di post User B → User B harus terima push notification

## Step 7: Cek log kalau masih error

```bash
tail -20 /var/www/nutrify-app/backend/storage/logs/laravel.log
```

---

## Troubleshooting

| Error | Penyebab | Solusi |
|-------|----------|--------|
| `Invalid value at 'message.data[0].value' (TYPE_STRING)` | FCM data berisi integer | Pastikan `FCMService.php` sudah di-update dengan `array_map('strval', ...)` |
| `Firebase credentials not found` | File JSON salah nama | Cek `storage/app/firebase-credentials.json.json` |
| `Failed to get Firebase access token` | Service account salah | Verifikasi `firebase-credentials.json.json` berisi `client_email` dan `private_key` yang valid |
| Notification tidak masuk ke DB | Event listener tidak jalan | Cek `PostController.php` ada `PushNotification` call di `toggleLike` dan `storeComment` |
| FCM token kosong | Frontend belum kirim token | Pastikan user sudah enable notification di profile, cek `fcm_token` di tabel `users` |

---

*Dibuat pada 3 Mei 2026.*
