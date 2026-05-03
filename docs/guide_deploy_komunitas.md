# Guide Deploy Update Backend — Komunitas & Follow System

> **VPS:** `103.253.212.55` | **Path:** `/var/www/nutrify-app/backend/`
> **Tanggal:** 2 Mei 2026
> **Perubahan:** Community enhancements, follow system, username, account type, upload limit

---

## DAFTAR ISI

1. [Apa yang Berubah](#1-apa-yang-berubah)
2. [Quick Deploy (Cheat Sheet)](#2-quick-deploy-cheat-sheet)
3. [Step-by-Step Detail](#3-step-by-step-detail)
4. [Verifikasi Setelah Deploy](#4-verifikasi-setelah-deploy)
5. [Rollback](#5-rollback)

---

## 1. Apa yang Berubah

### File Backend yang Berubah

| File | Aksi | Keterangan |
|------|------|------------|
| `database/migrations/2026_05_02_000006_add_community_fields_to_users_table.php` | NEW | Tambah kolom: username, avatar, fcm_token, account_type ke tabel users |
| `database/migrations/2026_05_02_000007_create_follows_table.php` | NEW | Tabel follows (follower_id, following_id) |
| `app/Models/Follow.php` | NEW | Model Follow |
| `app/Models/User.php` | UPDATED | Tambah fillable (username, avatar, fcm_token, account_type), relasi followers/followings |
| `app/Http/Controllers/Api/FollowController.php` | NEW | Toggle follow, user profile, search users, update username, update account type |
| `app/Http/Controllers/Api/PostController.php` | UPDATED | formatPost: +supabase_id, username, avatar_url, is_followed. Upload limit 10MB |
| `routes/api.php` | UPDATED | +5 route baru (follow, user profile, search, username, account type) |

### Endpoint Baru

| Method | Path | Keterangan |
|--------|------|------------|
| POST | `/api/users/{id}/follow` | Follow/unfollow user |
| GET | `/api/users/{id}/profile` | Profil user + posts + follow status |
| GET | `/api/users/search?q=` | Cari user by nama/username |
| PUT | `/api/username` | Set/update username |
| PUT | `/api/account-type` | Set public/private |

### Endpoint yang Berubah

| Method | Path | Perubahan |
|--------|------|-----------|
| GET | `/api/posts` | Response sekarang include: `supabase_id`, `username`, `avatar_url`, `is_followed` |
| GET | `/api/posts/{id}/comments` | Response include: `supabase_id` |
| POST | `/api/posts` | Upload limit: 2MB → **10MB**. Format: +webp |

### Migration Baru (2)

```
2026_05_02_000006_add_community_fields_to_users_table
  → users: +username (unique, nullable), +avatar (nullable), +fcm_token (nullable), +account_type (enum: public/private, default: public)

2026_05_02_000007_create_follows_table
  → follows: id, follower_id (FK users), following_id (FK users), timestamps
  → unique constraint: (follower_id, following_id)
```

---

## 2. Quick Deploy (Cheat Sheet)

Salin-tempel blok ini. Jalankan dari komputer lokal (Git Bash / PowerShell):

```bash
# ===== DEPLOY: Komunitas Enhancement & Follow System =====
LOCAL="C:/Users/Ibnu Habib/Documents/pdbl/baru/Nutrify/backend"
VPS="root@103.253.212.55:/var/www/nutrify-app/backend"

# STEP 1 — Upload semua file yang berubah
scp "$LOCAL/database/migrations/2026_05_02_000006_add_community_fields_to_users_table.php" "$VPS/database/migrations/"
scp "$LOCAL/database/migrations/2026_05_02_000007_create_follows_table.php" "$VPS/database/migrations/"
scp "$LOCAL/database/migrations/2026_05_03_000001_add_photo_to_profiles_table.php" "$VPS/database/migrations/"
scp "$LOCAL/app/Models/Follow.php" "$VPS/app/Models/"
scp "$LOCAL/app/Models/User.php" "$VPS/app/Models/"
scp "$LOCAL/app/Models/Profile.php" "$VPS/app/Models/"
scp "$LOCAL/app/Http/Controllers/Api/FollowController.php" "$VPS/app/Http/Controllers/Api/"
scp "$LOCAL/app/Http/Controllers/Api/PostController.php" "$VPS/app/Http/Controllers/Api/"
scp "$LOCAL/app/Http/Controllers/Api/ProfileController.php" "$VPS/app/Http/Controllers/Api/"
scp "$LOCAL/routes/api.php" "$VPS/routes/"

echo "Upload selesai!"
```

Lalu SSH ke VPS:

```bash
ssh root@103.253.212.55

# STEP 2 — Backup database di Supabase Dashboard dulu!
# → https://supabase.com/dashboard → project Nutrify → Database → Backups → Create backup

# STEP 3 — Jalankan migration
cd /var/www/nutrify-app/backend
php artisan migrate

# STEP 4 — Update dependencies (jika ada)
composer install --optimize-autoloader --no-dev

# STEP 5 — Permission & cache
sudo chown -R www-data:www-data /var/www/nutrify-app
sudo chmod -R 775 /var/www/nutrify-app/backend/storage
php artisan config:cache && php artisan route:cache

# STEP 6 — Restart services
sudo systemctl restart php8.2-fpm && sudo systemctl reload nginx

# STEP 7 — Verifikasi
curl -s https://nutrify-app.my.id/api/posts | head -c 300
```

---

## 3. Step-by-Step Detail

### STEP 1 — Backup Database

**WAJIB sebelum migration!**

1. Buka https://supabase.com/dashboard
2. Pilih project **Nutrify** (`goifacmbmwmbwxgyqmtk`)
3. Klik **Database** → **Backups** → **Create backup**

---

### STEP 2 — Upload File ke VPS

Buka terminal di komputer lokal (Git Bash):

```bash
LOCAL="C:/Users/Ibnu Habib/Documents/pdbl/baru/Nutrify/backend"
VPS="root@103.253.212.55:/var/www/nutrify-app/backend"

# Migration baru (2 file)
scp "$LOCAL/database/migrations/2026_05_02_000006_add_community_fields_to_users_table.php" "$VPS/database/migrations/"
scp "$LOCAL/database/migrations/2026_05_02_000007_create_follows_table.php" "$VPS/database/migrations/"

# Model baru + update
scp "$LOCAL/app/Models/Follow.php" "$VPS/app/Models/"
scp "$LOCAL/app/Models/User.php" "$VPS/app/Models/"

# Controller baru + update
scp "$LOCAL/app/Http/Controllers/Api/FollowController.php" "$VPS/app/Http/Controllers/Api/"
scp "$LOCAL/app/Http/Controllers/Api/PostController.php" "$VPS/app/Http/Controllers/Api/"

# Routes
scp "$LOCAL/routes/api.php" "$VPS/routes/"
```

> **Kalau mau upload semua sekaligus (overwrite seluruh folder):**
> ```bash
scp -r "$LOCAL/app" "$VPS/"
scp -r "$LOCAL/database" "$VPS/"
scp "$LOCAL/routes/api.php" "$VPS/routes/"
> ```



---

### STEP 3 — Verifikasi File di VPS

SSH ke VPS dan cek:

```bash
ssh root@103.253.212.55
cd /var/www/nutrify-app/backend

# Cek migration baru
ls database/migrations/ | grep "000006\|000007"
# Harus ada:
#   2026_05_02_000006_add_community_fields_to_users_table.php
#   2026_05_02_000007_create_follows_table.php

# Cek model baru
ls app/Models/Follow.php
# Harus ada

# Cek controller baru
ls app/Http/Controllers/Api/FollowController.php
# Harus ada

# Cek routes (grep follow)
grep -c "follow\|Follow\|search\|username\|account" routes/api.php
# Harus > 0
```

---

### STEP 4 — Jalankan Migration

```bash
cd /var/www/nutrify-app/backend
php artisan migrate
```

Output yang diharapkan:
```
INFO  Running migrations.

  2026_05_02_000006_add_community_fields_to_users_table ... 45ms DONE
  2026_05_02_000007_create_follows_table ................ 22ms DONE
```

> Kalau diminta "Do you really wish to run this command?", ketik `yes`.
>
> Kalau error "column already exists", kemungkinan sudah pernah dijalankan. Cek:
> ```bash
> php artisan tinker --execute="echo Schema::hasColumn('users', 'username') ? 'OK' : 'MISSING';"
> ```

---

### STEP 5 — Install Dependencies

```bash
cd /var/www/nutrify-app/backend
composer install --optimize-autoloader --no-dev
```

> Kalau error memory limit:
> ```bash
> php -d memory_limit=-1 $(which composer) install --optimize-autoloader --no-dev
> ```

---

### STEP 6 — Permission & Cache

```bash
# Permission
sudo chown -R www-data:www-data /var/www/nutrify-app
sudo chmod -R 755 /var/www/nutrify-app
sudo chmod -R 775 /var/www/nutrify-app/backend/storage
sudo chmod -R 775 /var/www/nutrify-app/backend/bootstrap/cache

# Cache
cd /var/www/nutrify-app/backend
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

---

### STEP 7 — Restart Services

```bash
sudo systemctl restart php8.2-fpm
sudo systemctl reload nginx
```

> Kalau error, cek versi PHP: `php -v`
> Lalu sesuaikan: `sudo systemctl restart php8.1-fpm` atau `sudo systemctl restart php8.3-fpm`

---

## 4. Verifikasi Setelah Deploy

### Cek endpoint lama masih jalan

```bash
curl -s https://nutrify-app.my.id/api/foods?search=nasi | head -c 200
```
Harus return JSON dengan `"success":true`.

### Cek endpoint baru — Follow

```bash
curl -s https://nutrify-app.my.id/api/users/1/follow
```
Harus return **401 Unauthorized** atau **405 Method Not Allowed** (karena harus POST dengan token).

### Cek endpoint baru — Search users

```bash
curl -s https://nutrify-app.my.id/api/users/search
```
Harus return **401** atau **422** (butuh parameter `q`).

### Cek kolom baru di database

```bash
cd /var/www/nutrify-app/backend
php artisan tinker --execute="
  echo 'username column: ' . (Schema::hasColumn('users', 'username') ? 'OK' : 'MISSING') . PHP_EOL;
  echo 'avatar column: ' . (Schema::hasColumn('users', 'avatar') ? 'OK' : 'MISSING') . PHP_EOL;
  echo 'fcm_token column: ' . (Schema::hasColumn('users', 'fcm_token') ? 'OK' : 'MISSING') . PHP_EOL;
  echo 'account_type column: ' . (Schema::hasColumn('users', 'account_type') ? 'OK' : 'MISSING') . PHP_EOL;
  echo 'follows table: ' . (Schema::hasTable('follows') ? 'OK' : 'MISSING') . PHP_EOL;
"
```

Harus semua **OK**.

### Cek log (tidak ada error)

```bash
tail -20 /var/www/nutrify-app/backend/storage/logs/laravel.log
```

### Cek dari Flutter app

1. Login ke app Nutrify
2. Buka tab Komunitas
3. Buat post → harus berhasil (upload gambar sampai 10MB)
4. Tap nama user lain → buka profil user (dengan follow button)
5. Tap ikon follow → harus tersimpan (cek lagi setelah keluar-masuk)
6. Tap profil sendiri → harus buka halaman profil (bukan user profile)

---

## 5. Rollback

Kalau ada masalah setelah deploy:

### Rollback Migration

```bash
cd /var/www/nutrify-app/backend

# Undo 2 migration terakhir
php artisan migrate:rollback --step=2
```

### Restore Database dari Supabase Backup

1. Buka https://supabase.com/dashboard
2. Project Nutrify → Database → Backups
3. Pilih backup yang dibuat sebelum deploy
4. Klik **Restore**

### Cek Error Log

```bash
tail -50 /var/www/nutrify-app/backend/storage/logs/laravel.log
```

---

## Catatan Penting

1. **Selalu backup database** sebelum migration
2. **Upload limit** sekarang **10MB** (dari 2MB) untuk gambar post
3. **Format gambar** yang diterima: jpeg, png, jpg, webp
4. **Username** bersifat unique — kalau ada yang sudah pakai, user harus pilih yang lain
5. **Account type default** adalah `public` — user bisa ubah ke `private` via API
6. **Follow system** mencegah self-follow (backend return 422 kalau follow diri sendiri)

---

*Dokumen ini dibuat pada 2 Mei 2026.*
g