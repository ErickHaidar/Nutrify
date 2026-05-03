# Guide Deploy — Community Feature Enhancement ke Production

> **VPS:** `103.253.212.55` | **Path:** `/var/www/nutrify-app/backend/`
> **Tanggal:** 3 Mei 2026
> **Perubahan:** Private account filtering, new endpoints (users/me, users/profile), follow status improvements

---

## Daftar Isi

1. [Apa yang Berubah](#1-apa-yang-berubah)
2. [Deploy via SCP](#2-deploy-via-scp)
3. [Verifikasi Setelah Deploy](#3-verifikasi-setelah-deploy)
4. [Rollback](#4-rollback)

---

## 1. Apa yang Berubah

### File Backend yang Perlu Diupdate

| File | Perubahan |
|------|-----------|
| `app/Http/Controllers/Api/PostController.php` | +private account filtering di `index()`, +`account_type` di `formatPost()` response |
| `app/Http/Controllers/Api/FollowController.php` | +`is_private` & `posts_count` di `userProfile()`, +fix `$avatarUrl` closure, +method baru `getMe()`, +method baru `updateProfile()` |
| `routes/api.php` | +2 route baru: `GET /users/me`, `PUT /users/profile` |

### Tidak Ada Migration Baru
Perubahan ini hanya mengubah controller dan routes. Tidak ada migration baru yang perlu dijalankan.

### Endpoint Baru

| Method | Path | Deskripsi |
|--------|------|-----------|
| `GET` | `/api/users/me` | Get profil user yang login (name, username, avatar, account_type, followers/following/posts count) |
| `PUT` | `/api/users/profile` | Update name, username, account_type |

### Response API yang Berubah

**`GET /api/posts` — Post response sekarang punya `account_type`:**
```json
{
  "user": {
    "id": 1,
    "name": "Ibnu",
    "supabase_id": "uuid",
    "username": "ibnu",
    "avatar_url": "https://...",
    "account_type": "public"
  }
}
```

**`GET /api/users/{id}/profile` — User profile sekarang punya `is_private` & `posts_count`:**
```json
{
  "account_type": "private",
  "is_private": true,
  "is_following": false,
  "followers_count": 5,
  "followings_count": 3,
  "posts_count": 12,
  "posts": [...]
}
```

**`GET /api/posts` — Feed sekarang memfilter akun privat:**
- Post dari akun **private** hanya muncul jika user mengikuti author
- Post dari akun **public** tetap muncul untuk semua

---

## 2. Deploy via SCP

### Step 1: Buka Git Bash / PowerShell di laptop, jalankan:

```bash
LOCAL="C:/Users/Ibnu Habib/Documents/pdbl/baru/Nutrify/backend"
VPS="root@103.253.212.55:/var/www/nutrify-app/backend"

# Controller yang berubah
scp "$LOCAL/app/Http/Controllers/Api/PostController.php" "$VPS/app/Http/Controllers/Api/"
scp "$LOCAL/app/Http/Controllers/Api/FollowController.php" "$VPS/app/Http/Controllers/Api/"

# Routes yang berubah
scp "$LOCAL/routes/api.php" "$VPS/routes/"

echo "Upload selesai!"
```

### Step 2: SSH ke VPS, jalankan cache clear + restart

```bash
ssh root@103.253.212.55

cd /var/www/nutrify-app/backend

# Clear cache
php artisan config:cache
php artisan route:cache

# Permission (jika perlu)
sudo chown -R www-data:www-data /var/www/nutrify-app
sudo chmod -R 775 /var/www/nutrify-app/backend/storage

# Restart services
sudo systemctl restart php8.2-fpm && sudo systemctl reload nginx
```

---

## 3. Verifikasi Setelah Deploy

### Cek endpoint baru — GET /users/me

```bash
curl -s https://nutrify-app.my.id/api/users/me \
  -H "Authorization: Bearer <token>" \
  -H "Accept: application/json" | head -c 500
```

Harus return JSON dengan `name`, `username`, `followers_count`, `followings_count`, `posts_count`.

### Cek endpoint baru — PUT /users/profile

```bash
curl -s -X PUT https://nutrify-app.my.id/api/users/profile \
  -H "Authorization: Bearer <token>" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{"name": "Test Name"}' | head -c 300
```

Harus return `{"success": true, "message": "Profil berhasil diperbarui."}`.

### Cek post response punya account_type

```bash
curl -s https://nutrify-app.my.id/api/posts \
  -H "Authorization: Bearer <token>" \
  -H "Accept: application/json" | head -c 500
```

Harus ada `account_type` di dalam object `user` setiap post.

### Cek private filtering berjalan

```bash
# Set user jadi private dulu
curl -s -X PUT https://nutrify-app.my.id/api/users/profile \
  -H "Authorization: Bearer <token_A>" \
  -H "Content-Type: application/json" \
  -d '{"account_type": "private"}'

# Cek dari akun lain — post user private TIDAK boleh muncul
curl -s https://nutrify-app.my.id/api/posts \
  -H "Authorization: Bearer <token_B>" | head -c 500
```

### Cek log (tidak ada error)

```bash
tail -20 /var/www/nutrify-app/backend/storage/logs/laravel.log
```

---

## 4. Rollback

Kalau ada masalah setelah deploy:

### Rollback File

Upload versi lama dari git (sebelum commit `cf7bfd1`):

```bash
LOCAL="C:/Users/Ibnu Habib/Documents/pdbl/baru/Nutrify/backend"
VPS="root@103.253.212.55:/var/www/nutrify-app/backend"

# Checkout versi sebelum perubahan
cd "C:/Users/Ibnu Habib/Documents/pdbl/baru/Nutrify"
git stash  # simpan perubahan lokal

# Upload file lama
scp "$LOCAL/app/Http/Controllers/Api/PostController.php" "$VPS/app/Http/Controllers/Api/"
scp "$LOCAL/app/Http/Controllers/Api/FollowController.php" "$VPS/app/Http/Controllers/Api/"
scp "$LOCAL/routes/api.php" "$VPS/routes/"

git stash pop  # kembalikan perubahan lokal

# Di VPS: restart
ssh root@103.253.212.55 "cd /var/www/nutrify-app/backend && php artisan config:cache && php artisan route:cache && sudo systemctl restart php8.2-fpm && sudo systemctl reload nginx"
```

---

## Catatan

1. **Tidak ada migration** — cukup upload file + clear cache + restart
2. **PHP version**: kalau `php8.2-fpm` gagal, cek `php -v` lalu sesuaikan
3. **Frontend juga berubah** — tapi frontend tidak perlu di-deploy ke VPS, cukup build APK baru

---

*Dokumen ini dibuat pada 3 Mei 2026.*
