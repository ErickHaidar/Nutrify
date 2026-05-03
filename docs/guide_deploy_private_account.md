# Guide Deploy: Private Account Follow Request

> Fitur: Akun privat Instagram-style (follow request + approve/reject)
> VPS: `103.253.212.55`
> Path: `/var/www/nutrify-app/backend/`
> Tanggal: 3 Mei 2026

---

## Yang Berubah

### Backend (6 file)
| File | Perubahan |
|------|-----------|
| `database/migrations/2026_05_03_100000_add_status_to_follows_table.php` | **BARU** — tambah kolom `status` enum('pending','accepted') ke tabel `follows` |
| `app/Models/Follow.php` | Tambah `'status'` ke `$fillable` |
| `app/Models/User.php` | `getFollowersCount()` & `getFollowingsCount()` filter by `status='accepted'` |
| `app/Http/Controllers/Api/FollowController.php` | **REWRITE** — 3-state follow, approve/reject, is_requested, auto-accept saat switch ke public |
| `app/Http/Controllers/Api/PostController.php` | Feed filter `status='accepted'`, formatPost return `is_requested` |
| `routes/api.php` | +2 endpoint: `POST follow-requests/{id}/approve`, `POST follow-requests/{id}/reject` |

### Frontend (sudah di-push, tinggal rebuild APK)
- `community_post.dart` — field `isRequested`
- `community_post_api_service.dart` — `approveFollowRequest`, `rejectFollowRequest`
- `komunitas_screen.dart` — 3-state follow button + search sheet 3-state
- `user_profile_screen.dart` — 3-state follow button + `_isRequested`
- `notification_modal.dart` — inline approve/reject buttons untuk follow_request
- `notification_api_service.dart` — icon `follow_request`

---

## STEP 1 — Upload Backend ke VPS (SCP)

Buka **terminal lokal** (Git Bash), jalankan:

```bash
LOCAL="C:/Users/Ibnu Habib/Documents/pdbl/baru/Nutrify/backend"
VPS=root@103.253.212.55:/var/www/nutrify-app/backend

# 1. Migration baru
scp "$LOCAL/database/migrations/2026_05_03_100000_add_status_to_follows_table.php" $VPS/database/migrations/

# 2. Models
scp "$LOCAL/app/Models/Follow.php" $VPS/app/Models/
scp "$LOCAL/app/Models/User.php" $VPS/app/Models/

# 3. Controllers
scp "$LOCAL/app/Http/Controllers/Api/FollowController.php" $VPS/app/Http/Controllers/Api/
scp "$LOCAL/app/Http/Controllers/Api/PostController.php" $VPS/app/Http/Controllers/Api/

# 4. Routes
scp "$LOCAL/routes/api.php" $VPS/routes/
```

### Atau satu blok copy-paste:

```bash
LOCAL="C:/Users/Ibnu Habib/Documents/pdbl/baru/Nutrify/backend"
VPS=root@103.253.212.55:/var/www/nutrify-app/backend

scp "$LOCAL/database/migrations/2026_05_03_100000_add_status_to_follows_table.php" $VPS/database/migrations/ && \
scp "$LOCAL/app/Models/Follow.php" $VPS/app/Models/ && \
scp "$LOCAL/app/Models/User.php" $VPS/app/Models/ && \
scp "$LOCAL/app/Http/Controllers/Api/FollowController.php" $VPS/app/Http/Controllers/Api/ && \
scp "$LOCAL/app/Http/Controllers/Api/PostController.php" $VPS/app/Http/Controllers/Api/ && \
scp "$LOCAL/routes/api.php" $VPS/routes/ && \
echo "UPLOAD SELESAI!"
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

  2026_05_03_100000_add_status_to_follows_table ........ 25ms DONE
```

> Jika diminta konfirmasi, ketik `yes`.

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
# Cek kolom status sudah ada di tabel follows
php artisan tinker --execute="echo Schema::hasColumn('follows', 'status') ? 'OK' : 'MISSING';"

# Cek endpoint baru terdaftar (harus 401 = butuh token)
curl -s -o /dev/null -w "%{http_code}" https://nutrify-app.my.id/api/follow-requests/1/approve
# Expected: 401 atau 405

# Cek log tidak ada error
tail -10 /var/www/nutrify-app/backend/storage/logs/laravel.log
```

---

## STEP 5 — Test di Flutter App

1. **Akun Public** — klik Ikuti → langsung "Diikuti" (tanpa approval)
2. **Akun Private** — klik Ikuti → berubah "Diminta"
3. **Notifikasi** — owner akun privat akan terima notifikasi "Permintaan Ikuti" dengan tombol **Terima** / **Tolak**
4. **Terima** → follow diterima, requester bisa lihat postingan
5. **Tolak** → follow request dihapus
6. **Cancel request** — klik "Diminta" lagi → request dibatalkan
7. **Switch ke public** — semua pending request otomatis di-accept

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

## Cheat Sheet (satu blok)

```bash
# ===== DEPLOY PRIVATE ACCOUNT FOLLOW REQUEST =====

# --- Lokal: Upload via SCP ---
LOCAL="C:/Users/Ibnu Habib/Documents/pdbl/baru/Nutrify/backend"
VPS=root@103.253.212.55:/var/www/nutrify-app/backend

scp "$LOCAL/database/migrations/2026_05_03_100000_add_status_to_follows_table.php" $VPS/database/migrations/ && \
scp "$LOCAL/app/Models/Follow.php" $VPS/app/Models/ && \
scp "$LOCAL/app/Models/User.php" $VPS/app/Models/ && \
scp "$LOCAL/app/Http/Controllers/Api/FollowController.php" $VPS/app/Http/Controllers/Api/ && \
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
