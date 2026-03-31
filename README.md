# Nutrify 🥗

Aplikasi mobile untuk melacak asupan kalori dan makronutrisi harian secara personal berdasarkan target *body goals* masing-masing.

---

## Tech Stack

| Layer | Teknologi |
|---|---|
| Mobile App | Flutter (Dart SDK ≥ 3.8.0) |
| State Management | MobX + flutter_mobx |
| HTTP Client | Dio |
| REST API | Laravel 12 (PHP ≥ 8.2) |
| Authentication | Supabase Auth (JWT) — login/register via `supabase_flutter`, verifikasi token di backend via `firebase/php-jwt` |
| Database | **PostgreSQL Lokal** (localhost) |
| Tunneling | Ngrok — agar HP fisik bisa akses backend yang jalan di laptop |

---

## Struktur Folder Project

```
nutrify-sprint1-apps/
│
├── backend/                        ← Laravel 12 REST API
│   ├── app/
│   │   ├── Http/
│   │   │   ├── Controllers/
│   │   │   │   ├── Api/
│   │   │   │   │   ├── FoodController.php        ← GET /api/foods
│   │   │   │   │   └── ProfileController.php     ← GET/POST /api/profile
│   │   │   │   └── FoodLogController.php         ← CRUD /api/food-logs
│   │   │   └── Middleware/
│   │   │       └── VerifySupabaseToken.php       ← Verifikasi JWT dari Supabase
│   │   └── Models/
│   │       ├── User.php
│   │       ├── Food.php
│   │       ├── FoodLog.php
│   │       └── Profile.php
│   ├── database/
│   │   ├── migrations/                           ← Skema tabel
│   │   └── seeders/
│   │       └── FoodSeeder.php                    ← Import 1651 data makanan Indonesia
│   ├── routes/
│   │   └── api.php                               ← Semua API route
│   ├── .env.example                              ← Template konfigurasi (COPY jadi .env)
│   └── composer.json
│
├── frontend/                       ← Flutter Mobile App
│   ├── lib/
│   │   ├── data/network/constants/
│   │   │   └── endpoints.dart                    ← URL backend & Supabase config
│   │   ├── screens/                              ← Semua halaman utama
│   │   ├── services/                             ← API service layer (Dio)
│   │   └── main.dart
│   └── pubspec.yaml
│
├── BACKLOG.md          ← Semua backlog item & status
├── CARA_PASANG.md      ← Panduan lengkap (versi detail)
├── CHANGELOG.md        ← Histori perubahan per versi
├── NUTRIFY_GUIDE.md    ← Panduan arsitektur & onboarding
├── planning.md         ← Rencana sprint & saran teknis
├── context.md          ← Konteks project
├── git-command.md      ← Panduan perintah Git
├── guide-1.md          ← Panduan tambahan
├── nilai-gizi.csv      ← Dataset makanan Indonesia (sumber FoodSeeder)
└── sprint_1.csv        ← Data sprint 1
```

---

## Prasyarat (Install Dulu Sebelum Mulai)

### Untuk Backend

| Software | Versi | Download |
|---|---|---|
| PHP | ≥ 8.2 | https://www.php.net (atau pakai XAMPP / Laragon) |
| Composer | 2.x | https://getcomposer.org |
| PostgreSQL | ≥ 14 | https://www.postgresql.org/download/ |

**Ekstensi PHP yang harus aktif:** `pdo_pgsql`, `pgsql`, `openssl`, `mbstring`, `curl`, `tokenizer`

> Jika pakai XAMPP: buka `php.ini`, cari `;extension=pdo_pgsql` dan `;extension=pgsql`, hapus tanda `;` di depannya. Restart XAMPP.
>
> Jika pakai Laragon: biasanya sudah aktif otomatis.

Cara cek:
```bash
php -m | findstr pdo_pgsql
```

### Untuk Frontend

| Software | Versi | Download |
|---|---|---|
| Flutter SDK | ≥ 3.x (stable) | https://docs.flutter.dev/get-started/install |
| Android Studio | 2023.x+ | https://developer.android.com/studio |
| Java JDK | 17 | https://adoptium.net (atau bawaan Android Studio) |

Cara cek:
```bash
flutter doctor
```

### Opsional

| Software | Kegunaan |
|---|---|
| Ngrok | Tunnel localhost agar bisa diakses dari HP fisik |
| Git | Version control (biasanya sudah ada) |

---

## Cara Setup Project (Step by Step)

### Step 1 — Clone Repository

```bash
git clone https://github.com/ErickHaidar/Nutrify.git nutrify-sprint1-apps
cd nutrify-sprint1-apps
```

Verifikasi:
```bash
git branch
# Output: * main
```

---

### Step 2 — Setup PostgreSQL Lokal

1. Buka **pgAdmin** atau terminal `psql`
2. Pastikan PostgreSQL sudah jalan (service running)
3. Catat **username** dan **password** PostgreSQL kamu (default biasanya `postgres` / password yang kamu set saat install)
4. Database `postgres` sudah ada secara default — kita pakai itu

> ⚠️ Project ini pakai **PostgreSQL lokal**, BUKAN database cloud Supabase. Supabase hanya dipakai untuk autentikasi (login/register).

---

### Step 3 — Setup Backend

```bash
cd backend
```

#### 3.1 Install dependencies

```bash
composer install
```

#### 3.2 Buat file `.env`

```bash
# Windows (PowerShell)
Copy-Item .env.example .env

# macOS / Linux
cp .env.example .env
```

#### 3.3 Generate application key

```bash
php artisan key:generate
```

#### 3.4 Edit file `.env`

Buka file `backend/.env` dengan text editor (VS Code, Notepad++, dll).

**Bagian Database — sesuaikan dengan PostgreSQL lokal kamu:**

```env
DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=postgres
DB_USERNAME=postgres
DB_PASSWORD=password_postgresql_kamu    ← GANTI dengan password PostgreSQL kamu
```

**Bagian Supabase Auth — minta kredensial ke pemilik project:**

```env
SUPABASE_URL=https://eilxtehpxdnwfxgdgtps.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOi...    ← minta ke pemilik project
SUPABASE_JWT_SECRET=xxx...         ← minta ke pemilik project
```

> Kredensial Supabase ini dipakai untuk **verifikasi JWT token** saat user login dari app Flutter. Tanpa ini, semua API akan return 401 Unauthorized.

#### 3.5 Jalankan migrasi database

```bash
php artisan migrate
```

Ini akan membuat tabel-tabel berikut di PostgreSQL lokal kamu:
- `users` — data user
- `profiles` — profil & body goals user
- `foods` — database makanan Indonesia
- `food_logs` — catatan makanan harian user
- `personal_access_tokens`, `cache`, `jobs`, dll (kebutuhan Laravel)

#### 3.6 Seed data makanan

```bash
php artisan db:seed
```

> Proses ini mengimport **1651 item makanan Indonesia** dari dataset `nilai-gizi.csv` ke tabel `foods`. Tunggu sampai selesai (bisa 1-5 menit).

#### 3.7 Jalankan server backend

```bash
php artisan serve
```

Output yang benar:
```
INFO  Server running on [http://127.0.0.1:8000]
```

✅ **Backend sudah jalan!** Biarkan terminal ini tetap terbuka.

---

### Step 4 — Setup Ngrok (Jika Pakai HP Fisik)

> Skip step ini jika kamu pakai **Android Emulator** saja.

Buka **terminal baru**, lalu:

```bash
ngrok http 8000
```

Akan muncul URL seperti:
```
Forwarding  https://xxxx-xxxx.ngrok-free.dev -> http://localhost:8000
```

Catat URL tersebut (contoh: `https://xxxx-xxxx.ngrok-free.dev`), kamu akan butuh di step selanjutnya.

Lalu update `APP_URL` di `backend/.env`:
```env
APP_URL=https://xxxx-xxxx.ngrok-free.dev
```

---

### Step 5 — Setup Frontend

Buka **terminal baru** (jangan tutup terminal backend & ngrok).

```bash
cd frontend
flutter pub get
```

#### 5.1 Konfigurasi endpoint

Edit file `frontend/lib/data/network/constants/endpoints.dart`:

**Jika pakai Android Emulator:**
```dart
static const String baseUrl = 'http://10.0.2.2:8000/api';
```

> `10.0.2.2` adalah alias khusus dari dalam Android Emulator yang merujuk ke `localhost` komputer kamu.

**Jika pakai HP fisik via Ngrok:**
```dart
static const String baseUrl = 'https://xxxx-xxxx.ngrok-free.dev/api';
```

**Supabase config** (di file yang sama — biasanya sudah terisi, tapi pastikan sama):
```dart
static const String supabaseUrl = 'https://eilxtehpxdnwfxgdgtps.supabase.co';
static const String supabaseAnonKey = 'eyJhbGciOi...';
```

#### 5.2 Jalankan aplikasi

```bash
flutter run
```

> Build pertama kali bisa 3-5 menit. Build berikutnya lebih cepat.

Jika ada lebih dari satu device:
```bash
flutter devices                     # lihat daftar device
flutter run -d emulator-5554       # pilih device yang diinginkan
```

✅ **Aplikasi harus menampilkan Splash Screen → Halaman Login.**

---

## Ringkasan: Menjalankan Sehari-hari

Setelah setup awal selesai, setiap kali mau kerja:

| Terminal | Perintah | Keterangan |
|---|---|---|
| 1 | `cd backend && php artisan serve` | Jalankan API server |
| 2 | `ngrok http 8000` | Tunnel (hanya jika pakai HP fisik) |
| 3 | `cd frontend && flutter run` | Jalankan app Flutter |

---

## API Endpoints

Semua endpoint dilindungi oleh Supabase JWT auth (`Authorization: Bearer <token>`).

| Method | Endpoint | Fungsi |
|---|---|---|
| `GET` | `/api/foods?search=` | Cari makanan dari database |
| `POST` | `/api/profile/store` | Simpan/update profil & body goals |
| `GET` | `/api/profile` | Lihat profil user |
| `POST` | `/api/food-logs` | Catat makanan yang dimakan |
| `GET` | `/api/food-logs` | Lihat daftar food log |
| `GET` | `/api/food-logs/summary` | Ringkasan kalori & nutrisi harian |
| `GET` | `/api/food-logs/{id}` | Detail satu food log |
| `PUT` | `/api/food-logs/{id}` | Update food log |
| `DELETE` | `/api/food-logs/{id}` | Hapus food log |

---

## Troubleshooting

### ❌ `could not find driver` / `PDO driver not found`
**Solusi:** Aktifkan ekstensi `pdo_pgsql` dan `pgsql` di `php.ini`, lalu restart terminal.

### ❌ `SQLSTATE[08006] Connection refused`
**Solusi:** Cek apakah PostgreSQL sudah jalan, dan cek ulang `DB_HOST`, `DB_PORT`, `DB_PASSWORD` di `.env`.

### ❌ `Unauthorized` (401) dari semua API
**Solusi:** Pastikan `SUPABASE_URL`, `SUPABASE_ANON_KEY`, dan `SUPABASE_JWT_SECRET` di `.env` sudah benar. Jalankan `php artisan config:clear` lalu restart server.

### ❌ `SocketException` / `Connection refused` dari Flutter
**Checklist:**
1. Backend sudah jalan? (`php artisan serve`)
2. Emulator? → `baseUrl = 'http://10.0.2.2:8000/api'`
3. HP fisik? → Pastikan ngrok jalan & `baseUrl` pakai URL ngrok
4. HP fisik via WiFi? → HP & laptop harus di WiFi yang sama

### ❌ `flutter pub get` gagal
```bash
flutter clean
flutter pub cache repair
flutter pub get
```

### ❌ Gradle build failed
```bash
cd frontend/android
gradlew.bat clean        # Windows
./gradlew clean          # macOS/Linux
cd ..
flutter run
```

---

## Dokumentasi Lainnya

| Dokumen | Isi |
|---|---|
| [CARA_PASANG.md](CARA_PASANG.md) | Panduan setup versi sangat detail |
| [NUTRIFY_GUIDE.md](NUTRIFY_GUIDE.md) | Arsitektur, API reference, aturan tim |
| [BACKLOG.md](BACKLOG.md) | Semua backlog Sprint 1 + status |
| [CHANGELOG.md](CHANGELOG.md) | Histori perubahan tiap versi |
| [planning.md](planning.md) | Rencana sprint & roadmap |
| [git-command.md](git-command.md) | Panduan perintah Git |

---

## Kontribusi

1. Baca [NUTRIFY_GUIDE.md](NUTRIFY_GUIDE.md) terlebih dahulu
2. Buat branch dari `develop`: `git checkout -b feature/nama-fitur`
3. Commit dengan format: `feat(backend): deskripsi` / `fix(frontend): deskripsi`
4. Buka Pull Request ke `develop`

---

## Tim

> Tambahkan nama anggota tim di sini.
