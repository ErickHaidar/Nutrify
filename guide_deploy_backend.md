# Guide Deploy Backend Nutrify — Dari Nol

> Untuk: Ibnu (Backend Developer)
> Server: VPS `103.253.212.55` (hostname: `server1`)
> Path project: `/var/www/nutrify-app-app/`
> OS: Linux (Ubuntu)
> Stack: PHP 8.2+, Nginx, PostgreSQL (Supabase), Laravel 12

---

## DAFTAR ISI

1. [Persiapan di Komputer Lokal](#1-persiapan-di-komputer-lokal)
2. [Login ke VPS via SSH](#2-login-ke-vps-via-ssh)
3. [Install Software di VPS](#3-install-software-di-vps)
4. [Setup Database](#4-setup-database)
5. [Clone & Setup Project](#5-clone--setup-project)
6. [Konfigurasi Environment](#6-konfigurasi-environment)
7. [Install Dependencies & Migration](#7-install-dependencies--migration)
8. [Setup Nginx](#8-setup-nginx)
9. [Setup SSL (HTTPS)](#9-setup-ssl-https)
10. [Verifikasi Deploy](#10-verifikasi-deploy)
11. [Troubleshooting](#11-troubleshooting)

---

## 1. Persiapan di Komputer Lokal

### Yang kamu butuhkan:
- **SSH client** — sudah ada di terminal (Git Bash / PowerShell)
- **Akses VPS** — IP `103.253.212.55` + username + password/SSH key
- **Kode project** — sudah ada di folder lokal kamu

### Cek koneksi ke VPS dari komputer lokal:
```bash
# Coba ping dulu
ping 103.253.212.55

# Coba SSH (ganti "root" dengan username VPS kamu)
ssh root@103.253.212.55
```

Kalau bisa masuk, berarti VPS aktif dan bisa diakses.

---

## 2. Login ke VPS via SSH

```bash
# Login sebagai root
ssh root@103.253.212.55

# Atau kalau pakai port khusus (misal 2222)
ssh -p 2222 root@103.253.212.55

# Atau kalau pakai SSH key
ssh -i ~/.ssh/id_rsa root@103.253.212.55
```

Masukkan password kalau diminta. Kalau berhasil, kamu akan masuk ke terminal VPS.

> **Tip:** Kalau sering disconnect, pakai `screen` atau `tmux` supaya proses tetap jalan:
> ```bash
> apt install screen -y
> screen -S deploy        # buat session baru
> screen -r deploy        # kembali ke session
> ```

---

## 3. Install Software di VPS

Jalankan perintah ini satu per satu di terminal VPS.

### 3.1 Update sistem
```bash
sudo apt update && sudo apt upgrade -y
```

### 3.2 Install PHP 8.2
```bash
# Tambah repository PHP
sudo apt install software-properties-common -y
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update

# Install PHP 8.2 + extension yang dibutuhkan Laravel
sudo apt install php8.2 php8.2-cli php8.2-fpm php8.2-pgsql php8.2-mbstring \
  php8.2-xml php8.2-curl php8.2-zip php8.2-bcmath php8.2-intl -y
```

### 3.3 Install Composer (PHP package manager)
```bash
cd ~
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
composer --version   # verifikasi: harus tampil versi composer
```

### 3.4 Install Nginx (web server)
```bash
sudo apt install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx
```

### 3.5 Install Git
```bash
sudo apt install git -y
git --version   # verifikasi
```

### 3.6 Cek PHP berjalan
```bash
php -v          # harus tampil PHP 8.2.x
php -m | grep pgsql   # harus tampil pdo_pgsql dan pgsql
```

---

## 4. Setup Database

Database Nutrify pakai **Supabase** (cloud), jadi **TIDAK PERLU** install PostgreSQL di VPS. Koneksi langsung ke Supabase via internet.

Yang perlu kamu pastikan:
- Supabase project aktif di `https://goifacmbmwmbwxgyqmtk.supabase.co`
- Credentials database ada (host, port, username, password, database name)

Database credentials akan di-set di file `.env` nanti.

---

## 5. Clone & Setup Project

### 5.1 Pindah ke direktori web
```bash
cd /var/www
```

### 5.2 Clone repository
```bash
# Kalau pakai Git (ganti URL dengan repo kamu)
sudo git clone <URL_REPO_KAMU> nutrify

# Contoh kalau pakai GitHub:
# sudo git clone https://github.com/username/nutrify.git nutrify
```

### 5.3 Masuk ke folder backend
```bash
cd /var/www/nutrify-app/backend
```

### 5.4 Set permission (supaya Nginx bisa baca/tulis)
```bash
sudo chown -R www-data:www-data /var/www/nutrify-app
sudo chmod -R 755 /var/www/nutrify-app
sudo chmod -R 775 /var/www/nutrify-app/backend/storage
sudo chmod -R 775 /var/www/nutrify-app/backend/bootstrap/cache
```

---

## 6. Konfigurasi Environment

### 6.1 Buat file .env
```bash
cd /var/www/nutrify-app/backend

# Copy dari .env.example kalau ada
cp .env.example .env

# Atau copy dari .env lokal yang sudah ada
# (lebih mudah: upload file .env dari komputer lokal via SCP)
```

### 6.2 Upload .env dari komputer lokal (cara mudah)

Di **komputer lokal** (bukan VPS), buka terminal baru:
```bash
# Upload file .env ke VPS
scp "C:\Users\Ibnu Habib\Documents\pdbl\baru\Nutrify\backend\.env" root@103.253.212.55:/var/www/nutrify-app/backend/.env
```

### 6.3 Edit .env di VPS
```bash
cd /var/www/nutrify-app/backend
nano .env
```

Ubah nilai-nilai berikut untuk **production**:

```env
# ============================================
# YANG HARUS DIUBAH UNTUK PRODUCTION
# ============================================

# Ganti ke production
APP_ENV=production
APP_DEBUG=false
APP_URL=https://nutrify-app.my.id

# Database (Supabase — pastikan ini benar)
DB_CONNECTION=pgsql
DB_HOST=aws-1-ap-southeast-1.pooler.supabase.com
DB_PORT=5432
DB_DATABASE=postgres
DB_USERNAME=postgres.goifacmbmwmbwxgyqmtk
DB_PASSWORD=<PASSWORD_SUPABASE_KAMU>
DB_SSLMODE=require

# Supabase
SUPABASE_URL=https://goifacmbmwmbwxgyqmtk.supabase.co
SUPABASE_ANON_KEY=<ANON_KEY_KAMU>
SUPABASE_JWT_SECRET=<JWT_SECRET_KAMU>

# ============================================
# YANG TIDAK PERLU DIUBAH
# ============================================
SESSION_DRIVER=database
QUEUE_CONNECTION=database
CACHE_STORE=database
```

Simpan dengan `Ctrl+X`, lalu `Y`, lalu `Enter`.

---

## 7. Install Dependencies & Migration

### 7.1 Install PHP packages
```bash
cd /var/www/nutrify-app/backend

# Install semua dependency dari composer.json
composer install --optimize-autoloader --no-dev
```

> Kalau error "memory limit", jalankan:
> ```bash
> php -d memory_limit=-1 /usr/local/bin/composer install --optimize-autoloader --no-dev
> ```

### 7.2 Generate application key
```bash
php artisan key:generate
```

### 7.3 Jalankan migration (buat tabel di database)
```bash
php artisan migrate
```

Ini akan membuat tabel-tabel berikut:
- `users`
- `profiles`
- `foods`
- `food_logs`
- `user_favorites` ← **BARU Sprint 2**
- `posts` ← **BARU Sprint 2**
- `post_likes` ← **BARU Sprint 2**
- `comments` ← **BARU Sprint 2**
- `cache`, `sessions`, `jobs`, dll

> Ketika ditanya "Do you really wish to run this command?", ketik `yes` dan Enter.

### 7.4 Import dataset makanan
```bash
# Import 1.651 makanan dari BPOM dataset
php artisan db:seed --class=FoodSeeder

# Import 201 makanan lokal Indonesia baru
php artisan db:seed --class=LocalFoodSeeder
```

### 7.5 Hapus duplikat makanan (kalau ada)
```bash
php artisan food:deduplicate
```

### 7.6 Buat storage link (untuk upload gambar komunitas)
```bash
php artisan storage:link
```

### 7.7 Optimize Laravel untuk production
```bash
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

---

## 8. Setup Nginx

### 8.1 Buat konfigurasi Nginx
```bash
sudo nano /etc/nginx/sites-available/nutrify
```

Copy-paste konfigurasi berikut:

```nginx
server {
    listen 80;
    server_name nutrify-app.my.id www.nutrify-app.my.id 103.253.212.55;
    root /var/www/nutrify-app/backend/public;

    index index.php index.html;
    charset utf-8;

    # Logging
    access_log /var/log/nginx/nutrify-access.log;
    error_log /var/log/nginx/nutrify-error.log;

    # Max upload size (untuk foto profil & post komunitas)
    client_max_body_size 5M;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass unix:/run/php/php8.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    # Cache static files
    location ~* \.(css|js|jpg|jpeg|png|gif|ico|svg|woff|woff2|ttf)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Block hidden files
    location ~ /\.(?!well-known).* {
        deny all;
    }
}
```

Simpan `Ctrl+X` → `Y` → `Enter`.

### 8.2 Aktifkan konfigurasi
```bash
# Buat symlink ke sites-enabled
sudo ln -s /etc/nginx/sites-available/nutrify /etc/nginx/sites-enabled/

# Hapus default config (opsional)
sudo rm -f /etc/nginx/sites-enabled/default

# Test konfigurasi
sudo nginx -t
```

Harus tampil: `syntax is ok` dan `test is successful`.

### 8.3 Restart Nginx
```bash
sudo systemctl restart nginx
sudo systemctl restart php8.2-fpm
```

---

## 9. Setup SSL (HTTPS)

Menggunakan **Let's Encrypt** (gratis).

```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx -y

# Generate SSL certificate
sudo certbot --nginx -d nutrify-app.my.id -d www.nutrify-app.my.id
```

Ikuti instruksi:
1. Masukkan email (untuk notifikasi expiry)
2. Setuju terms of service (Y)
3. Pilih redirect HTTP → HTTPS (2)

### Auto-renew SSL
```bash
# Test auto-renew
sudo certbot renew --dry-run

# Certbot sudah otomatis buat cron job untuk renew
```

---

## 10. Verifikasi Deploy

### 10.1 Cek di browser
Buka: `https://nutrify-app.my.id/api/foods?search=nasi`

Harusnya return JSON:
```json
{"success":true,"data":{...}}
```

### 10.2 Cek health endpoint
Buka: `https://nutrify-app.my.id/up`

Harus return status 200.

### 10.3 Cek di terminal VPS
```bash
# Cek Nginx status
sudo systemctl status nginx

# Cek PHP-FPM status
sudo systemctl status php8.2-fpm

# Cek Laravel bisa connect database
php artisan tinker --execute="echo DB::connection()->getPdo() ? 'DB OK' : 'DB FAIL';"

# Cek jumlah makanan di database
php artisan tinker --execute="echo 'Foods: ' . \App\Models\Food::count();"
```

### 10.4 Cek log kalau ada error
```bash
# Laravel log
tail -50 /var/www/nutrify-app/backend/storage/logs/laravel.log

# Nginx error log
tail -50 /var/log/nginx/nutrify-error.log
```

---

## 11. Troubleshooting

### Error: "500 Internal Server Error"
```bash
# Cek permission
sudo chmod -R 775 /var/www/nutrify-app/backend/storage
sudo chmod -R 775 /var/www/nutrify-app/backend/bootstrap/cache
sudo chown -R www-data:www-data /var/www/nutrify-app/backend

# Cek .env ada
ls -la /var/www/nutrify-app/backend/.env

# Cek log
tail -20 /var/www/nutrify-app/backend/storage/logs/laravel.log
```

### Error: "Connection refused" database
```bash
# Cek koneksi ke Supabase
php artisan tinker --execute="DB::connection()->getPdo();"
# Kalau error, cek DB_HOST, DB_PORT, DB_PASSWORD di .env
```

### Error: "Permission denied"
```bash
sudo chown -R www-data:www-data /var/www/nutrify-app
sudo chmod -R 755 /var/www/nutrify-app
sudo chmod -R 775 /var/www/nutrify-app/backend/storage
sudo chmod -R 775 /var/www/nutrify-app/backend/bootstrap/cache
```

### Error: "Class not found" / composer error
```bash
cd /var/www/nutrify-app/backend
composer install --optimize-autoloader --no-dev
php artisan config:cache
php artisan route:cache
```

### Error: "413 Request Entity Too Large" (upload gambar)
Edit nginx config, ubah `client_max_body_size`:
```bash
sudo nano /etc/nginx/sites-available/nutrify
# Ubah: client_max_body_size 10M;
sudo systemctl restart nginx
```

### Reset semua cache Laravel
```bash
cd /var/www/nutrify-app/backend
php artisan config:clear
php artisan route:clear
php artisan view:clear
php artisan cache:clear
php artisan config:cache
php artisan route:cache
```

---

## Cheat Sheet — Perintah yang Sering Dipakai

| Perintah | Fungsi |
|----------|--------|
| `ssh root@103.253.212.55` | Login ke VPS |
| `cd /var/www/nutrify-app/backend` | Masuk ke folder project |
| `php artisan migrate` | Jalankan migration baru |
| `php artisan db:seed --class=LocalFoodSeeder` | Import makanan lokal |
| `php artisan food:deduplicate` | Hapus duplikat makanan |
| `php artisan storage:link` | Buat symlink storage |
| `php artisan config:cache` | Cache konfigurasi |
| `tail -f storage/logs/laravel.log` | Monitor log real-time |
| `sudo systemctl restart nginx` | Restart web server |
| `sudo systemctl restart php8.2-fpm` | Restart PHP |
| `sudo nginx -t` | Test konfigurasi Nginx |
