# CARA PASANG — Panduan Lengkap Menjalankan Project Nutrify (Branch `sprint1-apps`)

> Dokumen ini ditujukan untuk anggota tim yang ingin menjalankan project **Nutrify** dari nol.
> Baca dari atas ke bawah. Jangan skip bagian Prasyarat.

---

## Daftar Isi

1. [Gambaran Arsitektur](#1-gambaran-arsitektur)
2. [Prasyarat Wajib](#2-prasyarat-wajib)
3. [Clone & Setup Repository](#3-clone--setup-repository)
4. [Setup Backend (Laravel 11)](#4-setup-backend-laravel-11)
5. [Setup Frontend (Flutter)](#5-setup-frontend-flutter)
6. [Menjalankan Keduanya Bersamaan](#6-menjalankan-keduanya-bersamaan)
7. [Struktur Folder Project](#7-struktur-folder-project)
8. [Troubleshooting](#8-troubleshooting)

---

## 1. Gambaran Arsitektur

```
nutrify/
├── backend/    ← Laravel 11 REST API (PHP)
│                  Berjalan di http://localhost:8000
│                  Auth: Supabase JWT (stateless)
│                  DB: PostgreSQL via Supabase
│
└── frontend/   ← Flutter App (Android/iOS)
                   Autentikasi: supabase_flutter
                   HTTP Client: Dio + AuthInterceptor
                   Terhubung ke backend via http://10.0.2.2:8000/api
                   (10.0.2.2 = localhost dari dalam Android Emulator)
```

**Supabase** dipakai untuk dua hal:
- Autentikasi (email/password login, register, reset password)
- Database PostgreSQL (semua data disimpan di sana)

---

## 2. Prasyarat Wajib

Pastikan semua software berikut sudah terinstall di komputer kamu sebelum mulai.

### 2.1 Untuk Semua (Backend + Frontend)

| Software | Versi Minimum | Download |
|---|---|---|
| **Git** | 2.x | https://git-scm.com/downloads |

Verifikasi: `git --version`

---

### 2.2 Untuk Backend (Laravel)

| Software | Versi Minimum | Download / Catatan |
|---|---|---|
| **PHP** | **8.2** | https://www.php.net/downloads (Windows: pakai XAMPP atau Laragon) |
| **Composer** | 2.x | https://getcomposer.org/download/ |
| **PostgreSQL** | 14+ | Tidak perlu install lokal — kita pakai Supabase (cloud) |
| **Ekstensi PHP** | — | `pdo_pgsql`, `openssl`, `mbstring`, `curl`, `tokenizer` |

**Cara cek ekstensi PHP aktif:**
```bash
php -m | findstr pdo_pgsql   # Windows
php -m | grep pdo_pgsql      # macOS/Linux
```

Jika belum aktif:
- XAMPP: buka `php.ini`, cari `;extension=pdo_pgsql`, hapus titik koma `;`
- Laragon: sudah aktif otomatis
- Restart server setelah edit `php.ini`

**Verifikasi:**
```bash
php --version        # harus menampilkan PHP 8.2.x atau lebih baru
composer --version   # harus menampilkan Composer 2.x
```

---

### 2.3 Untuk Frontend (Flutter)

| Software | Versi Minimum | Download / Catatan |
|---|---|---|
| **Flutter SDK** | **3.x** (stable) | https://docs.flutter.dev/get-started/install |
| **Dart SDK** | 3.8+ | Sudah included bersama Flutter SDK |
| **Android Studio** | 2023.x | https://developer.android.com/studio (wajib untuk Android emulator) |
| **Android SDK** | API 21+ | Install via Android Studio → SDK Manager |
| **Java JDK** | 17 | https://adoptium.net/ (atau pakai yang sudah terinstall bersama Android Studio) |

**Opsional (untuk run di perangkat fisik):**
- Aktifkan **Developer Options** + **USB Debugging** di HP
- Install **ADB** (sudah termasuk dalam Android SDK)

**Verifikasi:**
```bash
flutter --version        # harus menampilkan Flutter 3.x
flutter doctor           # harus semua ✓ atau ✗ hanya di platform yang tidak dipakai
```

Output `flutter doctor` yang normal untuk Android:
```
[✓] Flutter (Channel stable, 3.x.x)
[✓] Android toolchain
[✓] Android Studio
[✓] Connected device (1 available)
```

---

### 2.4 Akun & Konfigurasi Supabase

Project ini sudah dikonfigurasi menggunakan Supabase milik pemilik project. Kamu butuh:

1. Minta kepada pemilik project: **Supabase URL**, **Anon Key**, **JWT Secret**
2. Atau buat project Supabase sendiri di https://supabase.com (gratis):
   - Buat project baru
   - Buka **Project Settings → API**
   - Catat: `Project URL`, `anon public key`
   - Buka **Project Settings → JWT** → catat `JWT Secret`

---

## 3. Clone & Setup Repository

```bash
# 1. Clone repository
git clone https://github.com/prodhokter/nutrify.git
cd nutrify

# 2. Pindah ke branch yang benar
git checkout sprint1-apps

# 3. Verifikasi branch
git branch
# Output: * sprint1-apps
```

Setelah clone, struktur folder semestinya:
```
nutrify/
├── backend/
├── frontend/
├── BACKLOG.md
├── CARA_PASANG.md
├── CHANGELOG.md
└── planning.md
```

---

## 4. Setup Backend (Laravel 11)

### 4.1 Masuk ke folder backend

```bash
cd backend
```

### 4.2 Install dependencies PHP

```bash
composer install
```

> Proses ini bisa memakan waktu 1–3 menit tergantung koneksi internet.

### 4.3 Buat file konfigurasi `.env`

```bash
# Windows (PowerShell)
Copy-Item .env.example .env

# macOS / Linux
cp .env.example .env
```

### 4.4 Generate application key

```bash
php artisan key:generate
```

Output yang benar: `Application key set successfully.`

### 4.5 Konfigurasi `.env`

Buka file `backend/.env` dengan text editor, lalu isi bagian-bagian berikut:

#### Database (Supabase PostgreSQL)

```env
DB_CONNECTION=pgsql
DB_HOST=db.XXXXXXXXXXXX.supabase.co    ← ganti dengan host dari Supabase Dashboard → Settings → Database
DB_PORT=5432
DB_DATABASE=postgres
DB_USERNAME=postgres
DB_PASSWORD=your-supabase-db-password  ← password database dari Supabase
```

> **Cara cari DB_HOST:**
> Supabase Dashboard → Project kamu → Settings → Database → **Connection string**
> Ambil bagian `db.xxxx.supabase.co`

#### Supabase Auth

```env
SUPABASE_URL=https://XXXXXXXXXXXX.supabase.co   ← Project URL
SUPABASE_ANON_KEY=eyJhbGciOi...                 ← anon public key
SUPABASE_JWT_SECRET=your-jwt-secret             ← JWT Secret
```

> **Cara cari nilai ini:**
> - `SUPABASE_URL` & `SUPABASE_ANON_KEY`: Supabase Dashboard → Settings → **API**
> - `SUPABASE_JWT_SECRET`: Supabase Dashboard → Settings → **JWT** → JWT Secret

#### Contoh `.env` yang sudah diisi (backend)

```env
APP_NAME=Nutrify
APP_ENV=local
APP_KEY=base64:xxxxxxxxxxxxxxxxxxxx=
APP_DEBUG=true
APP_URL=http://localhost:8000

DB_CONNECTION=pgsql
DB_HOST=db.goifacmbmwmbwxgyqmtk.supabase.co
DB_PORT=5432
DB_DATABASE=postgres
DB_USERNAME=postgres
DB_PASSWORD=database_password_kamu

SUPABASE_URL=https://goifacmbmwmbwxgyqmtk.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_JWT_SECRET=jwt-secret-dari-supabase-dashboard
```

### 4.6 Jalankan migrasi database

```bash
php artisan migrate
```

> Ini akan membuat semua tabel di database Supabase kamu.
> Jika muncul error koneksi, periksa ulang `DB_HOST`, `DB_PASSWORD`, dan pastikan database Supabase aktif.

### 4.7 Seed data makanan (1651 item)

```bash
php artisan db:seed
```

> Proses ini mengimport **1651 item makanan** dari dataset nilai gizi.
> Bisa memakan waktu 1–5 menit. Tunggu sampai selesai.

### 4.8 Jalankan server backend

```bash
php artisan serve
```

Output yang benar:
```
INFO  Server running on [http://127.0.0.1:8000]
```

**Backend sudah berjalan!** Biarkan terminal ini tetap terbuka.

### 4.9 Verifikasi backend berjalan

Buka browser dan akses: `http://localhost:8000/api/foods?search=ayam`

Response yang benar (HTTP 401):
```json
{"message": "Unauthorized"}
```

> 401 normal karena endpoint ini butuh login JWT. Artinya server sudah berjalan dengan benar.

---

## 5. Setup Frontend (Flutter)

Buka **terminal baru** (jangan tutup terminal backend).

### 5.1 Masuk ke folder frontend

```bash
cd path/ke/nutrify/frontend
```

### 5.2 Install dependencies Flutter

```bash
flutter pub get
```

Output yang benar: `Got dependencies!`

### 5.3 Konfigurasi Supabase & URL Backend

Buka file:
```
frontend/lib/data/network/constants/endpoints.dart
```

Edit sesuai kebutuhan:

```dart
class Endpoints {
  // ── Supabase (sama dengan yang dipakai di backend .env) ──────────────────
  static const String supabaseUrl = 'https://XXXXXXXXXXXX.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOi...anon-key-kamu...';

  // ── URL Backend Laravel ──────────────────────────────────────────────────
  // Android Emulator (default):
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  
  // Perangkat fisik (HP nyata via USB/WiFi):
  // Cek IP lokal komputer kamu dulu: ipconfig (Windows) / ifconfig (Mac/Linux)
  // Contoh: static const String baseUrl = 'http://192.168.1.5:8000/api';

  // ... (sisanya jangan diubah)
}
```

> **Penting tentang IP:**
> - `10.0.2.2` adalah alamat khusus yang dari dalam Android Emulator merujuk ke `localhost` komputer kamu
> - Jika pakai HP fisik via USB: ganti dengan IP lokal komputer (cek dengan `ipconfig`)
> - Jika pakai HP via WiFi: HP dan laptop harus terhubung ke WiFi yang sama

### 5.4 Siapkan Android Emulator atau perangkat fisik

**Opsi A — Android Emulator (direkomendasikan untuk development):**
1. Buka Android Studio
2. Klik **Device Manager** (ikon HP di pojok kanan) atau Tools → Device Manager
3. Klik **+** → Create Virtual Device
4. Pilih perangkat (contoh: Pixel 6) → Next
5. Pilih sistem operasi (minimal **API 21**, rekomendasikan **API 33**) → Download jika belum ada
6. Finish, lalu klik tombol ▶ untuk menghidupkan emulator
7. Tunggu sampai emulator fully booted (muncul home screen Android)

**Opsi B — HP Fisik via USB:**
1. Di HP: Pengaturan → Tentang Ponsel → ketuk "Nomor Build" 7 kali
2. Pengaturan → Opsi Pengembang → aktifkan **USB Debugging**
3. Sambungkan HP ke laptop via kabel USB
4. Di laptop, jalankan:
   ```bash
   flutter devices
   # Harus muncul nama HP kamu
   ```

### 5.5 Verifikasi perangkat terdeteksi

```bash
flutter devices
```

Output yang benar (contoh emulator):
```
emulator-5554 • Android SDK built for x86 64 • android-x64 • Android 13 (API 33)
```

### 5.6 Jalankan aplikasi Flutter

```bash
flutter run
```

> Pertama kali build akan memakan waktu 3–5 menit karena kompilasi dari awal.
> Build berikutnya akan jauh lebih cepat.

Kalau ada lebih dari satu perangkat/emulator aktif:
```bash
flutter run -d emulator-5554   # ganti dengan device ID dari flutter devices
```

### 5.7 Verifikasi aplikasi berjalan

Aplikasi harus menampilkan **Splash Screen → Halaman Login**.

---

## 6. Menjalankan Keduanya Bersamaan

Ringkasan cepat setelah setup awal selesai:

**Terminal 1 — Backend:**
```bash
cd nutrify/backend
php artisan serve
```

**Terminal 2 — Frontend:**
```bash
cd nutrify/frontend
flutter run
```

---

## 7. Struktur Folder Project

```
nutrify/                        ← Root repository
├── CARA_PASANG.md              ← Dokumen ini
├── BACKLOG.md                  ← Daftar fitur & bug backlog
├── CHANGELOG.md                ← Riwayat perubahan per versi
├── planning.md                 ← Rencana sprint & roadmap
│
├── backend/                    ← Laravel 11 REST API
│   ├── app/
│   │   ├── Http/
│   │   │   ├── Controllers/Api/
│   │   │   │   ├── FoodController.php       ← GET /api/foods
│   │   │   │   ├── FoodLogController.php    ← POST/GET/DELETE /api/food-logs
│   │   │   │   └── ProfileController.php   ← GET/POST /api/profile
│   │   │   └── Middleware/
│   │   │       └── VerifySupabaseToken.php ← JWT auth middleware
│   │   └── Models/
│   ├── database/
│   │   ├── migrations/                      ← Skema tabel
│   │   └── seeders/                         ← 1651 data makanan
│   ├── routes/
│   │   └── api.php                          ← Definisi semua API route
│   └── .env                                 ← KAMU BUAT SENDIRI (lihat step 4.4)
│
└── frontend/                   ← Flutter App
    ├── lib/
    │   ├── data/
    │   │   ├── network/constants/endpoints.dart  ← URL backend & Supabase
    │   │   └── repository/user/                   ← Supabase auth impl
    │   ├── presentation/login/                     ← Login & register screen
    │   ├── screens/                                ← Semua halaman utama
    │   │   ├── home_screen.dart
    │   │   ├── add_meal_screen.dart
    │   │   ├── tracking_kalori_screen.dart
    │   │   ├── profile_screen.dart
    │   │   └── edit_profile_screen.dart
    │   ├── services/                               ← API service layer
    │   │   ├── food_api_service.dart
    │   │   ├── food_log_api_service.dart
    │   │   └── profile_api_service.dart
    │   └── main.dart
    └── pubspec.yaml
```

---

## 8. Troubleshooting

### Backend

#### ❌ Error: `could not find driver` / `PDO driver not found`
**Penyebab:** Ekstensi PHP `pdo_pgsql` belum aktif.
**Solusi:**
1. Buka `php.ini` (lokasi: jalankan `php --ini` untuk cari path-nya)
2. Cari `;extension=pdo_pgsql` dan hapus titik koma di depannya
3. Juga aktifkan `;extension=pgsql`
4. Restart terminal / server

---

#### ❌ Error: `SQLSTATE[08006] Connection refused`
**Penyebab:** Konfigurasi `DB_HOST` atau `DB_PASSWORD` salah.
**Solusi:**
1. Buka Supabase Dashboard → Settings → Database
2. Pastikan `DB_HOST` sesuai (format: `db.xxxx.supabase.co`)
3. Pastikan `DB_PASSWORD` sama dengan password yang dibuat saat setup Supabase
4. Coba port `6543` jika `5432` tidak berhasil (Supabase kadang pakai pooler)

---

#### ❌ Error pada migration: `42P01 - relation already exists`
**Penyebab:** Migration sudah pernah dijalankan sebelumnya.
**Solusi:**
```bash
php artisan migrate:fresh --seed   # ⚠️ INI HAPUS SEMUA DATA — hanya untuk dev
```

---

#### ❌ Error `Unauthorized` (401) dari Postman padahal sudah login
**Penyebab:** `SUPABASE_JWT_SECRET` salah atau tidak diset.
**Solusi:**
1. Buka Supabase Dashboard → Settings → JWT → salin JWT Secret
2. Paste ke `.env` di `SUPABASE_JWT_SECRET=...`
3. Jalankan `php artisan config:clear && php artisan serve`

---

### Frontend

#### ❌ `flutter: command not found`
**Penyebab:** Flutter SDK belum ditambahkan ke PATH.
**Solusi:**
- Windows: Tambahkan `C:\flutter\bin` ke Environment Variables → Path
- macOS/Linux: Tambahkan ke `~/.bashrc` atau `~/.zshrc`:
  ```bash
  export PATH="$PATH:/path/ke/flutter/bin"
  source ~/.bashrc
  ```

---

#### ❌ DioException 401 saat login berhasil tapi API merespons 401
**Penyebab:** Backend `.env` `SUPABASE_JWT_SECRET` tidak cocok dengan Supabase project yang dipakai frontend.
**Solusi:** Pastikan `SUPABASE_URL` dan kunci-kunci frontend (di `endpoints.dart`) mengarah ke project Supabase yang **sama** dengan di `backend/.env`.

---

#### ❌ Tidak bisa konek ke backend (`Connection refused` / `SocketException`)
**Penyebab:** Backend belum berjalan atau URL salah.
**Checklist:**
1. Pastikan `php artisan serve` sudah berjalan di terminal terpisah
2. Jika pakai **emulator Android**: pastikan `baseUrl = 'http://10.0.2.2:8000/api'`
3. Jika pakai **HP fisik**: ganti dengan IP lokal komputer (cek: `ipconfig` → IPv4 Address)
4. Jika HP fisik via WiFi: pastikan HP dan laptop terhubung ke jaringan WiFi yang sama

---

#### ❌ `Gradle build failed` saat `flutter run`
**Penyebab:** JDK versi incompatible atau Gradle belum di-cache.
**Solusi:**
```bash
cd android
./gradlew clean          # macOS/Linux
gradlew.bat clean        # Windows
cd ..
flutter run
```

---

#### ❌ Banyak warning `withOpacity is deprecated`
**Keterangan:** Ini hanya warning, bukan error. Aplikasi tetap bisa berjalan normal. Tidak perlu ditangani sekarang.

---

#### ❌ `flutter pub get` gagal / dependency conflict
**Solusi:**
```bash
flutter clean
flutter pub cache repair
flutter pub get
```

---

## Catatan Penting

- **Jangan commit file `.env`** ke repository. File ini sudah terdaftar di `.gitignore`.
- **JWT Secret bersifat rahasia** — jangan share di chat publik atau upload ke GitHub.
- Untuk menjalankan test backend: `php artisan test`
- Untuk format kode Flutter: `dart format lib/`

---

> Ditulis untuk branch `sprint1-apps` — Nutrify v0.6.0 (6 Maret 2026)
> Hubungi pemilik project jika ada pertanyaan mengenai kredensial Supabase.
