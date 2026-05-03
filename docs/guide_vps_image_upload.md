# Guide Fix VPS — Image Upload Error (413 Payload Too Large)

> **VPS:** `103.253.212.55` | **Path:** `/var/www/nutrify-app/backend/`
> **Masalah:** Upload gambar besar gagal dengan error DioException / 413
> **Penyebab:** nginx dan PHP punya limit upload default 1-2MB

---

## Step 1: SSH ke VPS

```bash
ssh root@103.253.212.55
```

## Step 2: Fix nginx — Tambah client_max_body_size

Cek config nginx yang aktif:

```bash
cat /etc/nginx/sites-available/nutrify-app.my.id
```

Cari apakah ada `client_max_body_size`. Kalau tidak ada, tambahkan:

```bash
nano /etc/nginx/sites-available/nutrify-app.my.id
```

Tambahkan di dalam `server { ... }` atau `location { ... }`:

```nginx
client_max_body_size 10M;
```

Contoh posisi yang benar:

```nginx
server {
    listen 80;
    server_name nutrify-app.my.id;

    client_max_body_size 10M;  # ← Tambahan ini

    location / {
        proxy_pass http://127.0.0.1:8000;
        # ...
    }
}
```

## Step 3: Fix PHP — Tambah upload_max_filesize

Cek PHP version dulu:

```bash
php -v
```

Edit php.ini (sesuaikan versi PHP, misal 8.2):

```bash
nano /etc/php/8.2/fpm/php.ini
```

Cari dan ubah value berikut:

```ini
upload_max_filesize = 10M
post_max_size = 12M
max_execution_time = 60
memory_limit = 128M
```

> **Catatan:** `post_max_size` harus lebih besar dari `upload_max_filesize`

## Step 4: Restart services

```bash
sudo systemctl restart php8.2-fpm
sudo systemctl reload nginx
```

## Step 5: Verifikasi

Test upload dari app. Atau test via curl:

```bash
# Test dengan file dummy 5MB
dd if=/dev/zero of=/tmp/test.jpg bs=1M count=5

curl -s -X POST https://nutrify-app.my.id/api/posts \
  -H "Authorization: Bearer <token>" \
  -F "content=Test upload" \
  -F "image=@/tmp/test.jpg" | head -c 300

rm /tmp/test.jpg
```

Kalau return `{"success":true}` berarti fix sudah berhasil.

## Step 6: Cek log kalau masih error

```bash
tail -20 /var/www/nutrify-app/backend/storage/logs/laravel.log
tail -5 /var/log/nginx/error.log
```

---

## Troubleshooting

| Error | Penyebab | Solusi |
|-------|----------|--------|
| `413 Request Entity Too Large` | nginx limit | Tambah `client_max_body_size 10M;` di nginx config |
| `422 Validation Error` | Laravel limit | Cek `PostController.php` validation `max:10240` |
| `500 Server Error` | PHP limit | Ubah `upload_max_filesize` dan `post_max_size` di php.ini |
| `Connection timeout` | Upload terlalu lama | Tambah `max_execution_time = 60` di php.ini |

---

*Dokumen ini dibuat pada 3 Mei 2026.*
