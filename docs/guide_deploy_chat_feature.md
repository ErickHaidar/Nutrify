# Guide Deploy — Chat / Direct Message (DM) Feature ke Production

> **VPS:** `103.253.212.55` | **Path:** `/var/www/nutrify-app/backend/`
> **Tanggal:** 4 Mei 2026
> **Perubahan:** Fitur chat antar user (DM) — conversations table, messages table, ChatController, 7 endpoint baru

---

## Daftar Isi

1. [Apa yang Berubah](#1-apa-yang-berubah)
2. [Deploy via SCP](#2-deploy-via-scp)
3. [Verifikasi Setelah Deploy](#3-verifikasi-setelah-deploy)
4. [Rollback](#4-rollback)

---

## 1. Apa yang Berubah

### File Backend yang Perlu Diupload

| File | Status | Perubahan |
|------|--------|-----------|
| `database/migrations/2026_05_04_200001_create_conversations_table.php` | **BARU** | Tabel `conversations` — menyimpan pasangan chat 2 user |
| `database/migrations/2026_05_04_200002_create_messages_table.php` | **BARU** | Tabel `messages` — menyimpan isi pesan (teks/gambar) |
| `app/Models/Conversation.php` | **BARU** | Model Conversation dengan relationships, scopes, helper methods |
| `app/Models/Message.php` | **BARU** | Model Message dengan relationships |
| `app/Models/User.php` | **UPDATE** | +relationship `conversations()` |
| `app/Http/Controllers/Api/ChatController.php` | **BARU** | Controller dengan 7 method (index, store, messages, sendMessage, markAsRead, unreadCount, markAllRead) |
| `routes/api.php` | **UPDATE** | +7 route baru untuk chat |

### Ada Migration Baru (2 file)

Jalankan `php artisan migrate` setelah upload untuk membuat 2 tabel baru:

**Tabel `conversations`:**
| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigIncrements | Primary key |
| `user1_id` | foreignId | FK ke users (selalu ID terkecil) |
| `user2_id` | foreignId | FK ke users (selalu ID terbesar) |
| `last_message_at` | timestamp nullable | Waktu pesan terakhir |
| `created_at`, `updated_at` | timestamps | Bawaan Laravel |

- Unique constraint: `[user1_id, user2_id]` — mencegah duplikasi percakapan
- Index: `[user1_id, last_message_at]`, `[user2_id, last_message_at]`

**Tabel `messages`:**
| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigIncrements | Primary key |
| `conversation_id` | foreignId | FK ke conversations |
| `sender_id` | foreignId | FK ke users |
| `content` | text nullable | Isi pesan teks |
| `image_url` | string nullable | Path gambar di storage |
| `is_read` | boolean default false | Status dibaca |
| `created_at`, `updated_at` | timestamps | Bawaan Laravel |

- Index: `[conversation_id, created_at]`, `[sender_id, is_read]`

### Endpoint Baru (7 route)

| Method | Path | Deskripsi |
|--------|------|-----------|
| `GET` | `/api/chat/conversations?filter=&search=&page=` | List percakapan user, eager load other user + last message + unread count |
| `POST` | `/api/chat/conversations` | Buat percakapan baru / ambil yang sudah ada — body: `{ user_id }` |
| `GET` | `/api/chat/conversations/{id}/messages?page=` | List pesan dalam percakapan (paginated 30), hanya bisa diakses peserta |
| `POST` | `/api/chat/conversations/{id}/messages` | Kirim pesan — body: `{ content? }` + `image? (file)` |
| `PUT` | `/api/chat/conversations/{id}/read` | Tandai semua pesan dari lawan chat sebagai dibaca |
| `GET` | `/api/chat/unread-count` | Total pesan belum dibaca dari semua percakapan |
| `POST` | `/api/chat/mark-all-read` | Tandai semua pesan dari semua percakapan sebagai dibaca |

### Response API

**`POST /api/chat/conversations` — Buat/ambil percakapan:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "other_user_id": 5,
    "other_user_name": "Budi",
    "other_username": "budi123",
    "other_user_avatar_url": "https://nutrify-app.my.id/storage/avatars/...",
    "created_at": "2026-05-04T10:00:00Z"
  }
}
```

**`GET /api/chat/conversations` — List percakapan:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "other_user_id": 5,
      "other_user_name": "Budi",
      "other_username": "budi123",
      "other_user_avatar_url": "https://...",
      "last_message": {
        "content": "Halo!",
        "image_url": null,
        "created_at": "2026-05-04T10:05:00Z"
      },
      "unread_count": 3,
      "created_at": "2026-05-04T10:00:00Z"
    }
  ],
  "current_page": 1,
  "last_page": 1
}
```

**`GET /api/chat/conversations/{id}/messages` — List pesan:**
```json
{
  "success": true,
  "data": {
    "data": [
      {
        "id": 1,
        "sender_id": 3,
        "content": "Halo!",
        "image_url": null,
        "is_read": true,
        "created_at": "2026-05-04T10:05:00Z"
      }
    ],
    "current_page": 1,
    "last_page": 1
  }
}
```

**`GET /api/chat/unread-count`:**
```json
{
  "success": true,
  "unread_count": 5
}
```

### Logika Penting

1. **Normalisasi user ID** — `store()` selalu menyimpan `user1_id = min(id1, id2)` dan `user2_id = max(id1, id2)` agar percakapan unik
2. **Authorisasi** — `messages()`, `sendMessage()`, `markAsRead()` memverifikasi user adalah peserta percakapan
3. **Auto mark read** — Saat `sendMessage()`, semua pesan dari lawan chat otomatis ditandai dibaca
4. **Notifikasi** — `sendMessage()` membuat record `Notification` + mengirim FCM push notification ke lawan chat
5. **Image upload** — Gambar disimpan di `storage/app/public/chat_images/` dengan format `{userId}_{timestamp}.{ext}`

---

## 2. Deploy via SCP

### Step 1: Buka Git Bash di laptop, jalankan:

```bash
LOCAL="C:/Users/Ibnu Habib/Documents/pdbl/baru/Nutrify/backend"
VPS="root@103.253.212.55:/var/www/nutrify-app/backend"

# ── Migrations (2 file baru) ──
scp "$LOCAL/database/migrations/2026_05_04_200001_create_conversations_table.php" "$VPS/database/migrations/"
scp "$LOCAL/database/migrations/2026_05_04_200002_create_messages_table.php" "$VPS/database/migrations/"

# ── Models (2 file baru + 1 update) ──
scp "$LOCAL/app/Models/Conversation.php" "$VPS/app/Models/"
scp "$LOCAL/app/Models/Message.php" "$VPS/app/Models/"
scp "$LOCAL/app/Models/User.php" "$VPS/app/Models/"

# ── Controller (1 file baru) ──
scp "$LOCAL/app/Http/Controllers/Api/ChatController.php" "$VPS/app/Http/Controllers/Api/"

# ── Routes (1 file update) ──
scp "$LOCAL/routes/api.php" "$VPS/routes/"

echo "✅ Upload selesai!"
```

### Step 2: SSH ke VPS, jalankan migration + cache clear + permission

```bash
ssh root@103.253.212.55

cd /var/www/nutrify-app/backend

# Jalankan migration (membuat tabel conversations & messages)
php artisan migrate --force

# Cache config & routes
php artisan config:cache
php artisan route:cache

# Pastikan folder storage bisa ditulis (untuk upload gambar chat)
sudo chown -R www-data:www-data /var/www/nutrify-app
sudo chmod -R 775 /var/www/nutrify-app/backend/storage
sudo chmod -R 775 /var/www/nutrify-app/backend/bootstrap/cache

# Buat folder chat_images kalau belum ada
sudo mkdir -p /var/www/nutrify-app/backend/storage/app/public/chat_images
sudo chown www-data:www-data /var/www/nutrify-app/backend/storage/app/public/chat_images

# Pastikan symbolic link storage ke public
php artisan storage:link

# Restart services
sudo systemctl restart php8.2-fpm && sudo systemctl reload nginx
```

> **Catatan:** Kalau `php8.2-fpm` gagal, cek versi PHP di VPS dengan `php -v` lalu sesuaikan (misal: `php8.1-fpm`).

---

## 3. Verifikasi Setelah Deploy

### Cek migration berhasil

```bash
ssh root@103.253.212.55 "cd /var/www/nutrify-app/backend && php artisan migrate:status" | grep -E "conversations|messages"
```

Harus muncul kedua migration dengan status **"Ran"**.

### Cek tabel terbuat

```bash
ssh root@103.253.212.55 "cd /var/www/nutrify-app/backend && php artisan tinker --execute=\"echo 'conversations: ' . Schema::hasTable('conversations') . ', messages: ' . Schema::hasTable('messages');\""
```

Output: `conversations: 1, messages: 1`

### Cek endpoint — GET /chat/conversations (harus return empty list)

```bash
curl -s https://nutrify-app.my.id/api/chat/conversations \
  -H "Authorization: Bearer <TOKEN_KAMU>" \
  -H "Accept: application/json" | head -c 300
```

Harus return:
```json
{"success":true,"data":[],"current_page":1,"last_page":1}
```

### Cek endpoint — POST /chat/conversations (buat percakapan)

```bash
curl -s -X POST https://nutrify-app.my.id/api/chat/conversations \
  -H "Authorization: Bearer <TOKEN_KAMU>" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{"user_id": 2}' | head -c 400
```

Harus return conversation data dengan `other_user_name`, `other_user_avatar_url`, dll.

### Cek endpoint — Kirim pesan

```bash
curl -s -X POST https://nutrify-app.my.id/api/chat/conversations/1/messages \
  -H "Authorization: Bearer <TOKEN_KAMU>" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{"content": "Halo test dari API!"}' | head -c 400
```

Harus return message data dengan `id`, `sender_id`, `content`, `is_read: false`.

### Cek endpoint — Unread count

```bash
curl -s https://nutrify-app.my.id/api/chat/unread-count \
  -H "Authorization: Bearer <TOKEN_KAMU>" \
  -H "Accept: application/json"
```

### Cek route terdaftar

```bash
ssh root@103.253.212.55 "cd /var/www/nutrify-app/backend && php artisan route:list --path=chat"
```

Harus muncul 7 route:
```
GET    api/chat/conversations
POST   api/chat/conversations
GET    api/chat/conversations/{id}/messages
POST   api/chat/conversations/{id}/messages
PUT    api/chat/conversations/{id}/read
GET    api/chat/unread-count
POST   api/chat/mark-all-read
```

### Cek folder chat_images ada

```bash
ssh root@103.253.212.55 "ls -la /var/www/nutrify-app/backend/storage/app/public/ | grep chat_images"
```

Harus muncul folder `chat_images` dengan owner `www-data`.

### Cek log (tidak ada error)

```bash
ssh root@103.253.212.55 "tail -20 /var/www/nutrify-app/backend/storage/logs/laravel.log"
```

---

## 4. Rollback

Kalau ada masalah setelah deploy:

### Rollback Migration (hapus tabel chat)

```bash
ssh root@103.253.212.55 "cd /var/www/nutrify-app/backend && php artisan migrate:rollback --step=2 --force"
```

Ini akan menghapus tabel `messages` dan `conversations`.

### Rollback File — Upload versi lama

```bash
LOCAL="C:/Users/Ibnu Habib/Documents/pdbl/baru/Nutrify/backend"
VPS="root@103.253.212.55:/var/www/nutrify-app/backend"

# Hapus file baru yang tidak ada di versi sebelumnya
ssh root@103.253.212.55 << 'ENDSSH'
cd /var/www/nutrify-app/backend
rm -f app/Models/Conversation.php
rm -f app/Models/Message.php
rm -f app/Http/Controllers/Api/ChatController.php
rm -f database/migrations/2026_05_04_200001_create_conversations_table.php
rm -f database/migrations/2026_05_04_200002_create_messages_table.php
ENDSSH

# Upload versi lama User.php dan api.php dari git
cd "C:/Users/Ibnu Habib/Documents/pdbl/baru/Nutrify"
git stash
git show HEAD~1:backend/app/Models/User.php > /tmp/User_old.php
git show HEAD~1:backend/routes/api.php > /tmp/api_old.php
scp /tmp/User_old.php "$VPS/app/Models/User.php"
scp /tmp/api_old.php "$VPS/routes/api.php"
git stash pop

# Restart
ssh root@103.253.212.55 "cd /var/www/nutrify-app/backend && php artisan config:cache && php artisan route:cache && sudo systemctl restart php8.2-fpm && sudo systemctl reload nginx"
```

---

## Catatan

1. **Ada 2 migration baru** — upload dulu semua file, lalu `php artisan migrate --force` di VPS
2. **Folder `chat_images`** — harus dibuat manual dan di-set permission, karena upload gambar chat akan disimpan di sini
3. **Storage link** — pastikan `php artisan storage:link` sudah dijalankan agar gambar bisa diakses via URL
4. **PHP version**: kalau `php8.2-fpm` gagal, cek `php -v` lalu sesuaikan
5. **Frontend tidak perlu deploy ke VPS** — cukup build APK baru dari laptop (`flutter build apk`)
6. **Notifikasi push** — pastikan `fcm_token` user tersimpan di tabel `users`, jika tidak push notification tidak terkirim (tapi in-app notification tetap tersimpan)

---

*Dokumen ini dibuat pada 4 Mei 2026.*
