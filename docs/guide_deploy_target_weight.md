# Guide Deploy — target_weight + photo_url ke Production

> **VPS:** `103.253.212.55` | **Path:** `/var/www/nutrify-app/backend/`
> **Tanggal:** 3 Mei 2026
> **Perubahan:** target_weight, photo upload, follow system, community fields

---

## Daftar Isi

1. [Apa yang Berubah](#1-apa-yang-berubah)
2. [Opsi A: Deploy via Git Pull (Rekomendasi)](#2-opsi-a-deploy-via-git-pull-rekomendasi)
3. [Opsi B: Deploy via SCP](#3-opsi-b-deploy-via-scp)
4. [Verifikasi Setelah Deploy](#4-verifikasi-setelah-deploy)
5. [Rollback](#5-rollback)

---

## 1. Apa yang Berubah

### File Backend yang Perlu Diupdate

| File | Perubahan |
|------|-----------|
| `app/Models/Profile.php` | +`target_weight`, +`photo` di `$fillable` |
| `app/Http/Controllers/Api/ProfileController.php` | +`target_weight` validation, +photo upload di `store()`, +method `photo()`, +`photo_url` + `target_weight` di `show()` response |
| `app/Models/User.php` | +fillable: username, avatar, fcm_token, account_type. +relasi followers/followings |
| `app/Http/Controllers/Api/FollowController.php` | **BARU** — toggle follow, user profile, search users, update username, update account type |
| `app/Http/Controllers/Api/PostController.php` | +supabase_id, +username, +avatar_url, +is_followed di formatPost. Upload limit 10MB |
| `app/Models/Follow.php` | **BARU** — Model Follow |
| `routes/api.php` | +6 route baru (follow, profile, search, username, account-type, profile photo) |

### Migration Baru

| File | Perubahan |
|------|-----------|
| `2026_05_02_000006_add_community_fields_to_users_table.php` | users: +username, +avatar, +fcm_token, +account_type |
| `2026_05_02_000007_create_follows_table.php` | tabel follows: follower_id, following_id |
| `2026_05_03_000001_add_photo_to_profiles_table.php` | profiles: +photo |
| `2026_05_03_020508_add_target_weight_to_profiles_table.php` | profiles: +target_weight |

### Response API yang Berubah

**Sebelum deploy (production sekarang):**
```json
{
  "profile": {
    "age": 22,
    "weight": 70,
    "height": 175,
    "gender": "male",
    "goal": "bulking",
    "activity_level": "active"
  }
}
```

**Setelah deploy:**
```json
{
  "photo_url": "https://nutrify-app.my.id/storage/profile-photos/1_1746268800.jpg",
  "profile": {
    "age": 22,
    "weight": 70,
    "height": 175,
    "gender": "male",
    "goal": "bulking",
    "activity_level": "active",
    "target_weight": 80,
    "photo_url": "https://nutrify-app.my.id/storage/profile-photos/1_1746268800.jpg"
  }
}
```

---

## 2. Opsi A: Deploy via Git Pull (Rekomendasi)

Langsung dari VPS, pull semua perubahan terbaru dari GitHub.

### Step 1: SSH ke VPS

```bash
ssh root@103.253.212.55
cd /var/www/nutrify-app/backend
```

### Step 2: Backup database (WAJIB)

Buka https://supabase.com/dashboard → project Nutrify → Database → Backups → **Create backup**

### Step 3: Pull code terbaru

```bash
git pull origin main
```

### Step 4: Jalankan migration

```bash
php artisan migrate
```

Output yang diharapkan:
```
INFO  Running migrations.

  2026_05_02_000006_add_community_fields_to_users_table ... DONE
  2026_05_02_000007_create_follows_table ................ DONE
  2026_05_03_000001_add_photo_to_profiles_table ......... DONE
  2026_05_03_020508_add_target_weight_to_profiles_table . DONE
```

> Kalau diminta "Do you really wish to run this command?", ketik `yes`.

### Step 5: Cache & permission

```bash
sudo chown -R www-data:www-data /var/www/nutrify-app
sudo chmod -R 775 /var/www/nutrify-app/backend/storage
php artisan config:cache
php artisan route:cache
```

### Step 6: Restart services

```bash
sudo systemctl restart php8.2-fpm && sudo systemctl reload nginx
```

### Step 7: Verifikasi

Lihat [Section 4](#4-verifikasi-setelah-deploy)

---

## 3. Opsi B: Deploy via SCP

Kalau VPS tidak bisa `git pull` (misal tidak ada git config), upload file manual via SCP dari laptop.

### Step 3A: Upload semua file (Copy-Paste ke terminal lokal)

Buka **Git Bash** atau **PowerShell** di laptop, jalankan:

```bash
LOCAL="C:/Users/Ibnu Habib/Documents/pdbl/baru/Nutrify/backend"
VPS="root@103.253.212.55:/var/www/nutrify-app/backend"

# Migration baru
scp "$LOCAL/database/migrations/2026_05_02_000006_add_community_fields_to_users_table.php" "$VPS/database/migrations/"
scp "$LOCAL/database/migrations/2026_05_02_000007_create_follows_table.php" "$VPS/database/migrations/"
scp "$LOCAL/database/migrations/2026_05_03_000001_add_photo_to_profiles_table.php" "$VPS/database/migrations/"
scp "$LOCAL/database/migrations/2026_05_03_020508_add_target_weight_to_profiles_table.php" "$VPS/database/migrations/"

# Model
scp "$LOCAL/app/Models/Profile.php" "$VPS/app/Models/"
scp "$LOCAL/app/Models/User.php" "$VPS/app/Models/"
scp "$LOCAL/app/Models/Follow.php" "$VPS/app/Models/"

# Controller
scp "$LOCAL/app/Http/Controllers/Api/ProfileController.php" "$VPS/app/Http/Controllers/Api/"
scp "$LOCAL/app/Http/Controllers/Api/FollowController.php" "$VPS/app/Http/Controllers/Api/"
scp "$LOCAL/app/Http/Controllers/Api/PostController.php" "$VPS/app/Http/Controllers/Api/"

# Routes
scp "$LOCAL/routes/api.php" "$VPS/routes/"

echo "Upload selesai!"
```

### Step 3B: SSH ke VPS, jalankan migration + restart

```bash
ssh root@103.253.212.55

cd /var/www/nutrify-app/backend

# Jalankan migration
php artisan migrate

# Permission
sudo chown -R www-data:www-data /var/www/nutrify-app
sudo chmod -R 775 /var/www/nutrify-app/backend/storage

# Cache
php artisan config:cache
php artisan route:cache

# Restart
sudo systemctl restart php8.2-fpm && sudo systemctl reload nginx
```

---

## 4. Verifikasi Setelah Deploy

### Cek endpoint lama masih jalan

```bash
curl -s https://nutrify-app.my.id/api/foods?search=nasi | head -c 200
```

Harus return JSON dengan `"success":true`.

### Cek profile response punya target_weight + photo_url

```bash
curl -s https://nutrify-app.my.id/api/profile \
  -H "Authorization: Bearer <token>" \
  -H "Accept: application/json" | head -c 500
```

Harus ada `target_weight` dan `photo_url` di dalam `profile`.

### Cek endpoint baru — Follow

```bash
curl -s https://nutrify-app.my.id/api/users/1/follow
```

Harus return **401 Unauthorized** atau **405 Method Not Allowed** (karena harus POST dengan token).

### Cek endpoint baru — Search users

```bash
curl -s "https://nutrify-app.my.id/api/users/search?q=test"
```

Harus return **401** atau **422** (butuh parameter `q` dan auth).

### Cek kolom baru di database

```bash
cd /var/www/nutrify-app/backend
php artisan tinker --execute="
  echo 'target_weight: ' . (Schema::hasColumn('profiles', 'target_weight') ? 'OK' : 'MISSING') . PHP_EOL;
  echo 'photo: ' . (Schema::hasColumn('profiles', 'photo') ? 'OK' : 'MISSING') . PHP_EOL;
  echo 'username: ' . (Schema::hasColumn('users', 'username') ? 'OK' : 'MISSING') . PHP_EOL;
  echo 'account_type: ' . (Schema::hasColumn('users', 'account_type') ? 'OK' : 'MISSING') . PHP_EOL;
  echo 'follows table: ' . (Schema::hasTable('follows') ? 'OK' : 'MISSING') . PHP_EOL;
"
```

Harus semua **OK**.

### Cek log (tidak ada error)

```bash
tail -20 /var/www/nutrify-app/backend/storage/logs/laravel.log
```

---

## 5. Rollback

Kalau ada masalah setelah deploy:

### Rollback Migration

```bash
cd /var/www/nutrify-app/backend
php artisan migrate:rollback --step=4
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
2. Kalau menggunakan **Opsi B (SCP)**, pastikan semua file berhasil diupload sebelum jalankan migration
3. **PHP version**: kalau `php8.2-fpm` gagal, cek `php -v` lalu sesuaikan (misal `php8.1-fpm` atau `php8.3-fpm`)
4. **Storage link**: kalau foto profil tidak muncul, jalankan `php artisan storage:link`

---

*Dokumen ini dibuat pada 3 Mei 2026.*
