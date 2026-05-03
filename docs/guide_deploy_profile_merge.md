# Guide Deploy: Merged Profile + Post Management (Edit/Delete/Pin)

> Fitur: Merge profil umum + sosial (TabBar), edit post (< 1 jam), delete, pin (max 3)
> VPS: `103.253.212.55`
> Path: `/var/www/nutrify-app/backend/`
> Tanggal: 4 Mei 2026

---

## Yang Berubah

### Backend (4 file)
| File | Perubahan |
|------|-----------|
| `database/migrations/2026_05_04_100000_add_pinned_to_posts_table.php` | **BARU** — tambah kolom `is_pinned` boolean + `pinned_at` timestamp ke tabel `posts` |
| `app/Models/Post.php` | Tambah `is_pinned`, `pinned_at` ke `$fillable` + `$casts` |
| `app/Http/Controllers/Api/PostController.php` | +3 method: `update()` (edit < 1 jam), `togglePin()` (max 3 FIFO), update `index()` sort pinned first, `formatPost()` tambah `is_pinned`/`pinned_at` |
| `routes/api.php` | +2 endpoint: `PUT /posts/{id}`, `POST /posts/{id}/pin` |

### Frontend (sudah di-push, tinggal rebuild APK)
- ProfileScreen — rewrite total dengan TabBar "Umum"|"Sosial"
- KomunitasScreen — hapus profil button dari AppBar
- PostDetailScreen — hapus navigasi ke MyProfileScreen
- MainNavigationScreen — callback switch to profile tab
- MyProfileScreen — **dihapus** (merged ke ProfileScreen)
- CommunityPost — field `createdAt`, `isPinned`, `pinnedAt`, `canEdit`
- CommunityPostApiService — `updatePost()`, `togglePin()`

---

## STEP 1 — Upload Backend ke VPS (SCP)

Buka **terminal lokal** (Git Bash), copy-paste satu blok ini:

```bash
LOCAL="C:/Users/Ibnu Habib/Documents/pdbl/baru/Nutrify/backend"
VPS=root@103.253.212.55:/var/www/nutrify-app/backend

scp "$LOCAL/database/migrations/2026_05_04_100000_add_pinned_to_posts_table.php" $VPS/database/migrations/ && \
scp "$LOCAL/app/Models/Post.php" $VPS/app/Models/ && \
scp "$LOCAL/app/Http/Controllers/Api/PostController.php" $VPS/app/Http/Controllers/Api/ && \
scp "$LOCAL/routes/api.php" $VPS/routes/ && \
echo "UPLOAD SELESAI!"
```

Atau satu per satu:

```bash
LOCAL="C:/Users/Ibnu Habib/Documents/pdbl/baru/Nutrify/backend"
VPS=root@103.253.212.55:/var/www/nutrify-app/backend

# 1. Migration baru
scp "$LOCAL/database/migrations/2026_05_04_100000_add_pinned_to_posts_table.php" $VPS/database/migrations/

# 2. Post Model
scp "$LOCAL/app/Models/Post.php" $VPS/app/Models/

# 3. PostController
scp "$LOCAL/app/Http/Controllers/Api/PostController.php" $VPS/app/Http/Controllers/Api/

# 4. Routes
scp "$LOCAL/routes/api.php" $VPS/routes/
```

---

## STEP 2 — SSH ke VPS & Jalankan Migration

```bash
ssh root@103.253.212.55
cd /var/www/nutrify-app/backend

# Jalankan migration
php artisan migrate
```

Output yang diharapkan:
```
INFO  Running migrations.

  2026_05_04_100000_add_pinned_to_posts_table ........ 20ms DONE
```

---

## STEP 3 — Cache & Restart

```bash
cd /var/www/nutrify-app/backend
php artisan config:cache
php artisan route:cache
sudo systemctl restart php8.2-fpm
sudo systemctl reload nginx
```

---

## STEP 4 — Verifikasi

```bash
# Cek kolom is_pinned ada
cd /var/www/nutrify-app/backend
php artisan tinker --execute="echo Schema::hasColumn('posts', 'is_pinned') ? 'OK' : 'MISSING';"

# Cek kolom pinned_at ada
php artisan tinker --execute="echo Schema::hasColumn('posts', 'pinned_at') ? 'OK' : 'MISSING';"

# Cek endpoint baru terdaftar (harus 401 = butuh token)
curl -s -o /dev/null -w "%{http_code}" -X PUT https://nutrify-app.my.id/api/posts/1
# Expected: 401

curl -s -o /dev/null -w "%{http_code}" -X POST https://nutrify-app.my.id/api/posts/1/pin
# Expected: 401

# Cek log tidak ada error
tail -10 /var/www/nutrify-app/backend/storage/logs/laravel.log
```

---

## STEP 5 — Test di Flutter App

1. **Tab Profil** — buka tab profil, cek ada 2 tab: "Umum" dan "Sosial"
2. **Tab Umum** — body stats, edit profil, notifikasi toggle, bahasa, keluar
3. **Tab Sosial** — avatar, stats (postingan/pengikut/mengikuti), edit profil dialog, toggle public/private
4. **Komunitas** — profile button di AppBar sudah tidak ada
5. **Three-dot menu** — di tab Sosial, klik titik tiga di postingan
   - **Edit**: muncul hanya jika postingan < 1 jam, ubah konten, simpan
   - **Pin**: sematkan postingan (muncul pin icon + "Disematkan"), max 3
   - **Unpin**: lepas sematan
   - **Delete**: hapus postingan
6. **Pin FIFO** — pin 4 post, post paling lama auto-unpin
7. **Edit > 1 jam** — edit option tidak muncul di menu

---

## Cheat Sheet (satu blok)

```bash
# ===== DEPLOY MERGED PROFILE + POST MANAGEMENT =====

# --- Lokal: Upload via SCP ---
LOCAL="C:/Users/Ibnu Habib/Documents/pdbl/baru/Nutrify/backend"
VPS=root@103.253.212.55:/var/www/nutrify-app/backend

scp "$LOCAL/database/migrations/2026_05_04_100000_add_pinned_to_posts_table.php" $VPS/database/migrations/ && \
scp "$LOCAL/app/Models/Post.php" $VPS/app/Models/ && \
scp "$LOCAL/app/Http/Controllers/Api/PostController.php" $VPS/app/Http/Controllers/Api/ && \
scp "$LOCAL/routes/api.php" $VPS/routes/ && \
echo "UPLOAD SELESAI!"

# --- VPS: Migration + Cache + Restart ---
ssh root@103.253.212.55
cd /var/www/nutrify-app/backend && \
php artisan migrate && \
php artisan config:cache && \
php artisan route:cache && \
sudo systemctl restart php8.2-fpm && \
sudo systemctl reload nginx && \
echo "DEPLOY SELESAI!"
```

---

## Rollback (jika ada masalah)

```bash
cd /var/www/nutrify-app/backend

# Undo migration
php artisan migrate:rollback --step=1

# Cek log error
tail -50 storage/logs/laravel.log
```

---

## API Endpoint Baru

| Endpoint | Method | Body | Response |
|----------|--------|------|----------|
| `/api/posts/{id}` | PUT | `{ content: string }` | `{ success: true, data: { ...post } }` |
| `/api/posts/{id}/pin` | POST | (kosong) | `{ success: true, is_pinned: bool, message: string }` |

**Error responses:**
- Edit post > 1 jam: `403 { message: "Postingan hanya bisa diedit dalam 1 jam setelah dibuat." }`
- Bukan pemilik: `404 { message: "Post tidak ditemukan atau bukan milik Anda." }`
