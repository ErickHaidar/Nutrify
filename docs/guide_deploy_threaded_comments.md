# Guide Deploy — Threaded Comments (Twitter/X-style) ke Production

> **VPS:** `103.253.212.55` | **Path:** `/var/www/nutrify-app/backend/`
> **Tanggal:** 5 Mei 2026
> **Perubahan:** Nested replies, comment likes, clickable profiles on comments, comment detail screen

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
| `database/migrations/2026_05_05_000001_add_parent_id_to_comments_table.php` | **BARU** | Tambah kolom `parent_id` di tabel `comments` untuk nested replies |
| `database/migrations/2026_05_05_000002_create_comment_likes_table.php` | **BARU** | Tabel `comment_likes` untuk like komentar |
| `app/Models/CommentLike.php` | **BARU** | Model CommentLike dengan relationships |
| `app/Models/Comment.php` | **UPDATE** | +`parent_id` fillable, +relationships: replies(), parent(), likes(), +scope topLevel() |
| `app/Models/User.php` | **UPDATE** | +relationship commentLikes() |
| `app/Http/Controllers/Api/PostController.php` | **UPDATE** | +comment threading, +comment likes, +formatComment(), +toggleCommentLike(), +commentReplies() |
| `routes/api.php` | **UPDATE** | +2 route baru: `POST /comments/{id}/like`, `GET /comments/{id}/replies` |

### Ada Migration Baru (2 file)

Jalankan `php artisan migrate` setelah upload untuk:

**Alter tabel `comments`:**
| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `parent_id` | foreignId nullable | FK ke comments — `null` = top-level comment, `123` = reply ke comment ID 123 |

- Index: `parent_id`
- Foreign key: `comments.id` cascade on delete

**Tabel baru `comment_likes`:**
| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | bigIncrements | Primary key |
| `user_id` | foreignId | FK ke users |
| `comment_id` | foreignId | FK ke comments |
| `created_at`, `updated_at` | timestamps | Bawaan Laravel |

- Unique constraint: `[user_id, comment_id]`

### Endpoint Baru (2 route)

| Method | Path | Deskripsi |
|--------|------|-----------|
| `POST` | `/api/comments/{id}/like` | Toggle like/unlike komentar, return `{ liked, likes_count }` |
| `GET` | `/api/comments/{id}/replies?page=` | List balasan untuk komentar (paginated 20) |

### Response API yang Berubah

**`GET /api/posts/{id}/comments` — Comment response sekarang lebih lengkap:**
```json
{
  "id": 1,
  "content": "Komentar baru",
  "parent_id": null,
  "user": {
    "id": 5,
    "name": "Budi",
    "username": "budi123",
    "avatar_url": "https://nutrify-app.my.id/storage/avatars/..."
  },
  "likes_count": 3,
  "is_liked": false,
  "replies_count": 2,
  "replies": [
    {
      "id": 2,
      "content": "Balasan pertama",
      "parent_id": 1,
      "user": { "id": 3, "name": "Ibnu", "username": "ibnu", "avatar_url": "..." },
      "likes_count": 0,
      "is_liked": false,
      "created_at": "2026-05-05T10:00:00Z"
    }
  ],
  "created_at": "2026-05-05T09:00:00Z"
}
```

**`POST /api/posts/{id}/comments` — Sekarang bisa reply:**
```json
{
  "content": "Balasan saya",
  "parent_id": 1
}
```
Jika `parent_id` diisi, komentar menjadi reply. Semua reply (termasuk reply ke reply) otomatis di-flatten ke 1 level di bawah top-level comment.

**`POST /api/comments/{id}/like` — Toggle like komentar:**
```json
{
  "success": true,
  "liked": true,
  "likes_count": 4
}
```

**`GET /api/comments/{id}/replies` — List balasan:**
```json
{
  "success": true,
  "data": [
    {
      "id": 2,
      "content": "Balasan pertama",
      "parent_id": 1,
      "user": { "id": 3, "name": "Ibnu", "username": "ibnu", "avatar_url": "..." },
      "likes_count": 1,
      "is_liked": false,
      "created_at": "2026-05-05T10:00:00Z"
    }
  ]
}
```

### Logika Penting

1. **1-level nesting** — Semua reply (termasuk reply ke reply) di-flatten ke bawah top-level comment. `parent_id` selalu mengarah ke comment paling atas.
2. **Comment response** — Hanya top-level comments yang di-fetch di `GET /comments`. Masing-masing include 2 preview replies + replies_count.
3. **Comment likes** — Sama seperti post likes, toggle on/off. Mengirim notifikasi type `comment_like`.
4. **Reply notifications** — Type `reply` (berbeda dari `comment`). Dikirim ke pemilik komentar induk, bukan pemilik postingan.
5. **Comment avatar** — Avatar URL dari profile photo atau user avatar, full URL prefix.

---

## 2. Deploy via SCP

### Step 1: Buka Git Bash di laptop, jalankan:

```bash
LOCAL="C:/Users/Ibnu Habib/Documents/pdbl/baru/Nutrify/backend"
VPS="root@103.253.212.55:/var/www/nutrify-app/backend"

# ── Migrations (2 file baru) ──
scp "$LOCAL/database/migrations/2026_05_05_000001_add_parent_id_to_comments_table.php" "$VPS/database/migrations/"
scp "$LOCAL/database/migrations/2026_05_05_000002_create_comment_likes_table.php" "$VPS/database/migrations/"

# ── Models (1 baru + 2 update) ──
scp "$LOCAL/app/Models/CommentLike.php" "$VPS/app/Models/"
scp "$LOCAL/app/Models/Comment.php" "$VPS/app/Models/"
scp "$LOCAL/app/Models/User.php" "$VPS/app/Models/"

# ── Controller (1 update) ──
scp "$LOCAL/app/Http/Controllers/Api/PostController.php" "$VPS/app/Http/Controllers/Api/"

# ── Routes (1 update) ──
scp "$LOCAL/routes/api.php" "$VPS/routes/"

echo "✅ Upload selesai!"
```

### Step 2: SSH ke VPS, jalankan migration + cache clear + restart

```bash
ssh root@103.253.212.55

cd /var/www/nutrify-app/backend

# Jalankan migration (alter comments + buat comment_likes)
php artisan migrate --force

# Cache config & routes
php artisan config:cache
php artisan route:cache

# Permission (jika perlu)
sudo chown -R www-data:www-data /var/www/nutrify-app
sudo chmod -R 775 /var/www/nutrify-app/backend/storage

# Restart services
sudo systemctl restart php8.2-fpm && sudo systemctl reload nginx
```

> **Catatan:** Kalau `php8.2-fpm` gagal, cek versi PHP di VPS dengan `php -v` lalu sesuaikan (misal: `php8.1-fpm`).

---

## 3. Verifikasi Setelah Deploy

### Cek migration berhasil

```bash
ssh root@103.253.212.55 "cd /var/www/nutrify-app/backend && php artisan migrate:status" | grep -E "parent_id|comment_likes"
```

Harus muncul kedua migration dengan status **"Ran"**.

### Cek kolom parent_id di tabel comments

```bash
ssh root@103.253.212.55 "cd /var/www/nutrify-app/backend && php artisan tinker --execute=\"echo collect(Schema::getColumnListing('comments'))->join(', ');\""
```

Output harus mengandung `parent_id`.

### Cek tabel comment_likes terbuat

```bash
ssh root@103.253.212.55 "cd /var/www/nutrify-app/backend && php artisan tinker --execute=\"echo 'comment_likes exists: ' . (Schema::hasTable('comment_likes') ? 'yes' : 'no');\""
```

### Cek route terdaftar

```bash
ssh root@103.253.212.55 "cd /var/www/nutrify-app/backend && php artisan route:list --path=comments"
```

Harus muncul:
```
POST   api/comments/{id}/like
GET    api/comments/{id}/replies
```

### Cek endpoint — POST /comments/{id}/like

```bash
curl -s -X POST https://nutrify-app.my.id/api/comments/1/like \
  -H "Authorization: Bearer <TOKEN_KAMU>" \
  -H "Accept: application/json" | head -c 300
```

Harus return:
```json
{"success":true,"liked":true,"likes_count":1}
```

Panggil lagi harus toggle:
```json
{"success":true,"liked":false,"likes_count":0}
```

### Cek endpoint — GET /comments/{id}/replies

```bash
curl -s https://nutrify-app.my.id/api/comments/1/replies \
  -H "Authorization: Bearer <TOKEN_KAMU>" \
  -H "Accept: application/json" | head -c 300
```

### Cek comments response punya field baru

```bash
curl -s https://nutrify-app.my.id/api/posts/1/comments \
  -H "Authorization: Bearer <TOKEN_KAMU>" \
  -H "Accept: application/json" | head -c 500
```

Harus ada `parent_id`, `likes_count`, `is_liked`, `replies_count`, `replies`, dan `avatar_url` di user object.

### Cek log (tidak ada error)

```bash
ssh root@103.253.212.55 "tail -20 /var/www/nutrify-app/backend/storage/logs/laravel.log"
```

---

## 4. Rollback

Kalau ada masalah setelah deploy:

### Rollback Migration

```bash
ssh root@103.253.212.55 "cd /var/www/nutrify-app/backend && php artisan migrate:rollback --step=2 --force"
```

Ini akan menghapus tabel `comment_likes` dan kolom `parent_id` dari `comments`.

### Rollback File — Upload versi lama

```bash
LOCAL="C:/Users/Ibnu Habib/Documents/pdbl/baru/Nutrify/backend"
VPS="root@103.253.212.55:/var/www/nutrify-app/backend"

# Hapus file baru yang tidak ada di versi sebelumnya
ssh root@103.253.212.55 << 'ENDSSH'
cd /var/www/nutrify-app/backend
rm -f app/Models/CommentLike.php
rm -f database/migrations/2026_05_05_000001_add_parent_id_to_comments_table.php
rm -f database/migrations/2026_05_05_000002_create_comment_likes_table.php
ENDSSH

# Upload versi lama dari git
cd "C:/Users/Ibnu Habib/Documents/pdbl/baru/Nutrify"
git stash
git show HEAD~1:backend/app/Models/Comment.php > /tmp/Comment_old.php
git show HEAD~1:backend/app/Models/User.php > /tmp/User_old.php
git show HEAD~1:backend/app/Http/Controllers/Api/PostController.php > /tmp/PostController_old.php
git show HEAD~1:backend/routes/api.php > /tmp/api_old.php
scp /tmp/Comment_old.php "$VPS/app/Models/Comment.php"
scp /tmp/User_old.php "$VPS/app/Models/User.php"
scp /tmp/PostController_old.php "$VPS/app/Http/Controllers/Api/PostController.php"
scp /tmp/api_old.php "$VPS/routes/api.php"
git stash pop

# Restart
ssh root@103.253.212.55 "cd /var/www/nutrify-app/backend && php artisan config:cache && php artisan route:cache && sudo systemctl restart php8.2-fpm && sudo systemctl reload nginx"
```

---

## Catatan

1. **Ada 2 migration baru** — upload dulu semua file, lalu `php artisan migrate --force` di VPS
2. **Kolom `parent_id` nullable** — komentar lama tetap berfungsi (parent_id = null = top-level)
3. **PHP version**: kalau `php8.2-fpm` gagal, cek `php -v` lalu sesuaikan
4. **Frontend tidak perlu deploy ke VPS** — cukup build APK baru dari laptop (`flutter build apk`)
5. **Notifikasi baru**: type `reply` dan `comment_like` ditambahkan — pastikan notification system mendukung

---

*Dokumen ini dibuat pada 5 Mei 2026.*
