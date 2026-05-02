# Guide Update Backend di VPS 103.253.212.55

> Untuk: Ibnu (Backend Developer)
> VPS: `103.253.212.55` (hostname: `server1`)
> Path project di VPS: `/var/www/nutrify-app/`
> Tujuan: Deploy perubahan Sprint 2 ke production
> Terakhir diperbarui: 2 Mei 2026

---

## Struktur VPS Saat Ini

Berikut kondisi VPS yang sudah terverifikasi:

```
/var/www/nutrify-app/
├── backend/           ← Laravel API (sudah running)
├── frontend/          ← Flutter app
├── nilai-gizi.csv     ← Dataset makanan BPOM (1.651 item)
├── BACKLOG.md
├── CARA_PASANG.md
├── CHANGELOG.md
├── context.md
├── git-command.md
├── guide-1.md
├── NUTRIFY_GUIDE.md
├── planning.md
├── README.md
└── sprint_1.csv
```

> **Yang perlu ditambahkan:** `makanan-lokal.csv` (201 makanan lokal baru)

---

## DAFTAR ISI

1. [Apa yang Berubah di Sprint 2](#1-apa-yang-berubah-di-sprint-2)
2. [Langkah Update (Step by Step)](#2-langkah-update-step-by-step)
3. [Verifikasi Setelah Update](#3-verifikasi-setelah-update)
4. [Rollback Kalau Ada Masalah](#4-rollback-kalau-ada-masalah)
5. [Cheat Sheet Update](#5-cheat-sheet-update)

---

## 1. Apa yang Berubah di Sprint 2

Perubahan yang perlu di-deploy:

| Perubahan | Detail |
|-----------|--------|
| 4 migration baru | Tabel `user_favorites`, `posts`, `post_likes`, `comments` |
| 4 model baru | UserFavorite, Post, PostLike, Comment |
| 2 controller baru | FavoriteController, PostController |
| 1 command baru | `food:deduplicate` |
| 1 seeder baru | LocalFoodSeeder + makanan-lokal.csv (201 item) |
| Model diubah | User.php, Food.php (tambah relasi) |
| Routes diubah | +10 endpoint baru |
| FoodController diubah | Tambah `recommendations()` |

---

## 2. Langkah Update (Step by Step)

### STEP 1 — Login ke VPS

Di komputer lokal, buka terminal (Git Bash / PowerShell):

```bash
ssh root@103.253.212.55
```

Masukkan password kalau diminta.

> **Kalau lupa password VPS**, cek di panel hosting / cloud provider kamu.
> **Kalau pakai SSH key**, pastikan key sudah di `~/.ssh/` komputer kamu.

---

### STEP 2 — Masuk ke folder project

```bash
cd /var/www/nutrify-app
```

Cek isi folder:
```bash
ls -la
```

Harus terlihat: `backend/`, `frontend/`, `nilai-gizi.csv`, dll.

---

### STEP 3 — Cek status git saat ini

```bash
cd /var/www/nutrify-app
git status
git log --oneline -5
```

**CATAT commit hash terakhir** — ini untuk referensi kalau perlu rollback.

Contoh output:
```
248eb81 edit photo before upload and preview photo before done edit
acb162b Fix zayn malik dan upload pada komunitas
5e2574a Fix Calendar
```

Simpan hash `248eb81` sebagai titik aman.

---

### STEP 4 — Backup database sebelum update

```bash
# Karena pakai Supabase, backup lewat Supabase Dashboard:
# 1. Buka https://supabase.com/dashboard
# 2. Pilih project Nutrify (goifacmbmwmbwxgyqmtk)
# 3. Klik "Database" → "Backups" → "Create backup"
```

> **PENTING:** Selalu backup sebelum migration. Kalau migration gagal atau merusak data, bisa restore dari backup.

---

### STEP 5 — Upload file baru dari komputer lokal ke VPS

Buka **terminal baru di komputer lokal** (jangan di VPS), jalankan:

#### 5a. Upload file `makanan-lokal.csv`
```bash
scp "C:\Users\Ibnu Habib\Documents\pdbl\baru\Nutrify\makanan-lokal.csv" root@103.253.212.55:/var/www/nutrify-app/
```

#### 5b. Upload folder `app/` (model + controller + command baru)
```bash
scp -r "C:\Users\Ibnu Habib\Documents\pdbl\baru\Nutrify\backend\app" root@103.253.212.55:/var/www/nutrify-app/backend/
```

#### 5c. Upload folder `database/` (migration + seeder baru)
```bash
scp -r "C:\Users\Ibnu Habib\Documents\pdbl\baru\Nutrify\backend\database" root@103.253.212.55:/var/www/nutrify-app/backend/
```

#### 5d. Upload file `routes/api.php` (route baru)
```bash
scp "C:\Users\Ibnu Habib\Documents\pdbl\baru\Nutrify\backend\routes\api.php" root@103.253.212.55:/var/www/nutrify-app/backend/routes/
```

#### 5e. Upload dokumentasi yang diupdate
```bash
scp "C:\Users\Ibnu Habib\Documents\pdbl\baru\Nutrify\CHANGELOG.md" root@103.253.212.55:/var/www/nutrify-app/
scp "C:\Users\Ibnu Habib\Documents\pdbl\baru\Nutrify\BACKLOG.md" root@103.253.212.55:/var/www/nutrify-app/
scp "C:\Users\Ibnu Habib\Documents\pdbl\baru\Nutrify\sprint2_backend_report.md" root@103.253.212.55:/var/www/nutrify-app/
```

> **Alternatif kalau mau sekali upload semua:**
> ```bash
> # Upload seluruh folder backend sekaligus (hati-hati, overwrite semua)
> scp -r "C:\Users\Ibnu Habib\Documents\pdbl\baru\Nutrify\backend\app" root@103.253.212.55:/var/www/nutrify-app/backend/
> scp -r "C:\Users\Ibnu Habib\Documents\pdbl\baru\Nutrify\backend\database" root@103.253.212.55:/var/www/nutrify-app/backend/
> scp "C:\Users\Ibnu Habib\Documents\pdbl\baru\Nutrify\backend\routes\api.php" root@103.253.212.55:/var/www/nutrify-app/backend/routes/
> scp "C:\Users\Ibnu Habib\Documents\pdbl\baru\Nutrify\makanan-lokal.csv" root@103.253.212.55:/var/www/nutrify-app/
> ```

---

### STEP 6 — Verifikasi file sudah terupload

Kembali ke **terminal VPS**:

```bash
cd /var/www/nutrify-app

# Cek makanan-lokal.csv ada
ls -la makanan-lokal.csv

# Cek migration baru ada
ls backend/database/migrations/ | grep 2026_05

# Cek controller baru ada
ls backend/app/Http/Controllers/Api/

# Cek model baru ada
ls backend/app/Models/

# Cek command baru ada
ls backend/app/Console/Commands/
```

**Yang harus terlihat:**
- `makanan-lokal.csv` → ada
- `2026_05_02_000001_create_user_favorites_table.php` → ada
- `2026_05_02_000002_create_posts_table.php` → ada
- `2026_05_02_000003_create_post_likes_table.php` → ada
- `2026_05_02_000004_create_comments_table.php` → ada
- `FavoriteController.php` → ada
- `PostController.php` → ada
- `UserFavorite.php`, `Post.php`, `PostLike.php`, `Comment.php` → ada
- `DeduplicateFoods.php` → ada

---

### STEP 7 — Install/update PHP dependencies

```bash
cd /var/www/nutrify-app/backend
composer install --optimize-autoloader --no-dev
```

> Kalau error memory limit:
> ```bash
> php -d memory_limit=-1 $(which composer) install --optimize-autoloader --no-dev
> ```

---

### STEP 8 — Jalankan migration baru (4 tabel baru)

```bash
cd /var/www/nutrify-app/backend
php artisan migrate
```

Output yang diharapkan:
```
INFO  Running migrations.

  2026_05_02_000001_create_user_favorites_table ...................... 39ms DONE
  2026_05_02_000002_create_posts_table ............................... 22ms DONE
  2026_05_02_000003_create_post_likes_table .......................... 18ms DONE
  2026_05_02_000004_create_comments_table ............................ 15ms DONE
```

> **Kalau diminta konfirmasi** "Do you really wish to run this command?", ketik `yes` dan Enter.
>
> **Kalau error** "table already exists", berarti migration sudah pernah dijalankan. Aman untuk skip.

---

### STEP 9 — Import 201 makanan lokal baru

```bash
cd /var/www/nutrify-app/backend
php artisan db:seed --class=LocalFoodSeeder
```

Output yang diharapkan:
```
LocalFoodSeeder: Inserted 201 new foods, skipped 0 duplicates.
```

> **Kalau error "CSV not found"**, cek file ada di path yang benar:
> ```bash
> ls -la /var/www/nutrify-app/makanan-lokal.csv
> ```
> File harus ada di `/var/www/nutrify-app/makanan-lokal.csv` (parent directory dari `backend/`).

---

### STEP 10 — Jalankan deduplikasi makanan

```bash
cd /var/www/nutrify-app/backend
php artisan food:deduplicate
```

Jika ada duplikat, akan muncul preview:
```
Checking for duplicate foods...
Found X groups of duplicates:

  - "nama makanan" (2 copies)

Delete X duplicate entries? (yes/no) [yes]:
```

Ketik `yes` dan Enter.

---

### STEP 11 — Buat storage link (untuk upload gambar komunitas)

```bash
cd /var/www/nutrify-app/backend
php artisan storage:link
```

> Kalau sudah pernah dijalankan, akan tampil: `The [public/storage] link already exists.`

---

### STEP 12 — Set permission

```bash
sudo chown -R www-data:www-data /var/www/nutrify-app
sudo chmod -R 755 /var/www/nutrify-app
sudo chmod -R 775 /var/www/nutrify-app/backend/storage
sudo chmod -R 775 /var/www/nutrify-app/backend/bootstrap/cache
```

---

### STEP 13 — Optimize & cache

```bash
cd /var/www/nutrify-app/backend
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

---

### STEP 14 — Restart services

```bash
sudo systemctl restart php8.2-fpm
sudo systemctl reload nginx
```

> Kalau error "Failed to restart php8.2-fpm", cek versi PHP yang terinstall:
> ```bash
> php -v
> ```
> Lalu sesuaikan, misalnya kalau PHP 8.1: `sudo systemctl restart php8.1-fpm`

---

## 3. Verifikasi Setelah Update

Jalankan pengecekan ini di **terminal VPS**:

### Cek endpoint yang sudah ada (harus tetap jalan)
```bash
curl -s https://nutrify-app.my.id/api/foods?search=nasi | head -c 200
```
Harus return JSON dengan `"success":true`.

### Cek endpoint baru — Favorit
```bash
curl -s https://nutrify-app.my.id/api/food/favorites
```
Harus return **401 Unauthorized** — ini NORMAL, berarti route sudah terdaftar dan butuh token Supabase.

### Cek endpoint baru — Rekomendasi
```bash
curl -s https://nutrify-app.my.id/api/food/recommendations
```
Harus return **401 Unauthorized**.

### Cek endpoint baru — Komunitas
```bash
curl -s https://nutrify-app.my.id/api/posts
```
Harus return **401 Unauthorized**.

### Cek jumlah makanan di database
```bash
cd /var/www/nutrify-app/backend
php artisan tinker --execute="echo 'Total foods: ' . App\Models\Food::count();"
```
Harus sekitar **1.852 item** (1.651 + 201).

### Cek tabel baru ada
```bash
cd /var/www/nutrify-app/backend
php artisan tinker --execute="
  echo 'user_favorites: ' . (Schema::hasTable('user_favorites') ? 'OK' : 'MISSING') . PHP_EOL;
  echo 'posts: ' . (Schema::hasTable('posts') ? 'OK' : 'MISSING') . PHP_EOL;
  echo 'post_likes: ' . (Schema::hasTable('post_likes') ? 'OK' : 'MISSING') . PHP_EOL;
  echo 'comments: ' . (Schema::hasTable('comments') ? 'OK' : 'MISSING') . PHP_EOL;
"
```

Harus semua **OK**.

### Cek dari Flutter app di HP
1. Buka app Nutrify
2. Login
3. Cari makanan **"Rendang"** — harus muncul hasil dari data baru
4. Cari **"Bakpia"** — harus muncul
5. Cari **"Es Teh Manis"** — harus muncul

### Cek log (pastikan tidak ada error baru)
```bash
tail -20 /var/www/nutrify-app/backend/storage/logs/laravel.log
```

---

## 4. Rollback Kalau Ada Masalah

Kalau sesuatu berubah dan perlu kembali ke versi sebelumnya:

### Rollback migration
```bash
cd /var/www/nutrify-app/backend

# Undo 4 migration terakhir
php artisan migrate:rollback --step=4
```

### Rollback kode ke commit sebelumnya
```bash
cd /var/www/nutrify-app

# Lihat daftar commit
git log --oneline -10

# Kembali ke commit terakhir sebelum update
git checkout <commit-hash-yang-dicatat-di-step-3>
```

### Rollback database dari Supabase backup
1. Buka https://supabase.com/dashboard
2. Pilih project Nutrify
3. Database → Backups
4. Pilih backup yang dibuat sebelum update
5. Klik "Restore"

---

## 5. Cheat Sheet Update

Salin-tempel blok ini setiap kali mau update:

```bash
# ===== QUICK UPDATE SPRINT 2 =====

# --- Di komputer lokal (Git Bash) ---
scp "C:\Users\Ibnu Habib\Documents\pddl\baru\Nutrify\makanan-lokal.csv" root@103.253.212.55:/var/www/nutrify-app/
scp -r "C:\Users\Ibnu Habib\Documents\pdbl\baru\Nutrify\backend\app" root@103.253.212.55:/var/www/nutrify-app/backend/
scp -r "C:\Users\Ibnu Habib\Documents\pdbl\baru\Nutrify\backend\database" root@103.253.212.55:/var/www/nutrify-app/backend/
scp "C:\Users\Ibnu Habib\Documents\pdbl\baru\Nutrify\backend\routes\api.php" root@103.253.212.55:/var/www/nutrify-app/backend/routes/

# --- Di VPS (SSH) ---
ssh root@103.253.212.55
cd /var/www/nutrify-app/backend
composer install --optimize-autoloader --no-dev
php artisan migrate
php artisan db:seed --class=LocalFoodSeeder
php artisan food:deduplicate <<< "yes"
php artisan storage:link
sudo chown -R www-data:www-data /var/www/nutrify-app
sudo chmod -R 775 /var/www/nutrify-app/backend/storage
php artisan config:cache && php artisan route:cache
sudo systemctl restart php8.2-fpm && sudo systemctl reload nginx
curl -s https://nutrify-app.my.id/api/foods?search=rendang | head -c 100
```

---

## Catatan Penting

1. **Selalu backup database** di Supabase Dashboard sebelum migration
2. **Catat commit hash** sebelum update (`git log --oneline -1`) untuk referensi rollback
3. **Jangan edit file langsung di VPS** — edit di lokal, upload via SCP
4. **Kalau ada error**, cek log pertama: `tail -50 /var/www/nutrify-app/backend/storage/logs/laravel.log`
5. **PHP version** — cek dengan `php -v`, sesuaikan service name (`php8.2-fpm` atau `php8.1-fpm`)

---

## Update CORS untuk Production

Kalau perlu update CORS (misal domain frontend berubah):

```bash
nano /var/www/nutrify-app/backend/config/cors.php
```

Pastikan domain production ada di `allowed_origins_patterns`:
```php
'allowed_origins_patterns' => [
    '#^https?://localhost(:\d+)?$#',
    '#^http://10\.0\.2\.2(:\d+)?$#',
    '#^http://127\.0\.0\.1(:\d+)?$#',
    '#^https://nutrify-app\.my\.id$#',
    '#^https?://103\.253\.212\.55(:\d+)?$#',
],
```

Lalu cache ulang:
```bash
cd /var/www/nutrify-app/backend
php artisan config:cache
```
