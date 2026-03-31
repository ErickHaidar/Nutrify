# NUTRIFY — Panduan Lengkap Proyek

> Dokumen resmi untuk semua anggota tim pengembang Nutrify.
> Wajib dibaca sebelum mulai berkontribusi ke repo ini.
> Terakhir diperbarui: 5 Maret 2026

---

## Daftar Isi

1. [Gambaran Umum Proyek](#1-gambaran-umum-proyek)
2. [Struktur Repositori](#2-struktur-repositori)
3. [Tech Stack](#3-tech-stack)
4. [Setup Environment (Onboarding)](#4-setup-environment-onboarding)
   - [4a. Backend — Laravel](#4a-backend--laravel)
   - [4b. Frontend — Flutter](#4b-frontend--flutter)
5. [Arsitektur Backend](#5-arsitektur-backend)
6. [Arsitektur Frontend](#6-arsitektur-frontend)
7. [API Reference](#7-api-reference)
8. [Masalah Kritikal yang Harus Segera Diselesaikan](#8-masalah-kritikal-yang-harus-segera-diselesaikan)
9. [Aturan & Konvensi Tim](#9-aturan--konvensi-tim)
10. [Panduan Git & Branching](#10-panduan-git--branching)
11. [Troubleshooting](#11-troubleshooting)

> Untuk backlog, changelog, dan planning, lihat file terpisah:
> - [BACKLOG.md](BACKLOG.md)
> - [CHANGELOG.md](CHANGELOG.md)
> - [planning.md](planning.md)

---

## 1. Gambaran Umum Proyek

**Nutrify** adalah aplikasi mobile berbasis Flutter untuk pelacakan nutrisi dan kalori harian secara personal. Pengguna memilih target *body goal* (Cutting / Maintenance / Bulking) lalu sistem secara otomatis menghitung kebutuhan kalori harian berdasarkan profil fisik mereka.

**Fitur utama Sprint 1:**
- Onboarding → Register / Login dengan email & password
- Setup profil fisik (BB, TB, usia, gender, tingkat aktivitas, goal)
- Kalkulasi BMI, BMR, dan TDEE otomatis (formula Mifflin-St Jeor)
- Pencatatan makanan per waktu makan (Breakfast, Lunch, Dinner, Snack) dari database makanan Indonesia
- Dashboard kalori harian (progress vs target) dengan breakdown makronutrisi
- Riwayat konsumsi per tanggal

Backend bertindak sebagai REST API (Laravel 12 + Sanctum) yang dikonsumsi aplikasi Flutter.

---

## 2. Struktur Repositori

```
nutrify/                        ← Root repo (satu git repo)
├── backend/                    ← Laravel 12 REST API
│   ├── app/
│   │   ├── Http/
│   │   │   ├── Controllers/
│   │   │   │   ├── Api/
│   │   │   │   │   └── ProfileController.php
│   │   │   │   ├── Auth/        ← Breeze auth controllers
│   │   │   │   └── FoodLogController.php
│   │   │   ├── Middleware/
│   │   │   └── Requests/
│   │   ├── Models/
│   │   │   ├── User.php
│   │   │   ├── Profile.php
│   │   │   ├── Food.php
│   │   │   └── FoodLog.php
│   │   └── Providers/
│   ├── database/
│   │   └── migrations/
│   ├── routes/
│   │   ├── api.php              ← Semua endpoint REST API
│   │   └── auth.php
│   ├── .env                     ← JANGAN di-commit
│   └── .env.example             ← Template env wajib di-commit
│
└── frontend/
    └── nutrify/                ← Flutter app
        ├── lib/
        │   ├── main.dart
        │   ├── screens/         ← UI Screens
        │   ├── services/        ← Local data services (SharedPreferences)
        │   ├── constants/       ← Theme, colors, assets
        │   ├── data/            ← Network layer (Dio, REST client)
        │   ├── domain/          ← Entities, use cases, repository interface
        │   ├── presentation/    ← MobX stores, bindings
        │   └── widgets/         ← Reusable UI components
        └── pubspec.yaml
```

> **Catatan:** `backend/.env` wajib ada di `.gitignore`. Setiap developer membuat `.env` sendiri dari `.env.example`.

---

## 3. Tech Stack

| Layer | Teknologi | Versi |
|---|---|---|
| Mobile App | Flutter + Dart | SDK ≥ 3.0.0 |
| State Management | MobX + flutter_mobx | ^2.1.4 |
| Dependency Injection | get_it | ^9.2.1 |
| HTTP Client (Flutter) | Dio | ^5.1.1 |
| Local Storage (Flutter) | SharedPreferences + Sembast | ^2.1.0 |
| REST API | Laravel | ^12.0 |
| Auth | Supabase Auth | cloud |
| JWT Verification | firebase/php-jwt | ^6.0 |
| Flutter Auth SDK | supabase_flutter | ^2.x |
| Database | PostgreSQL | ≥ 14 |
| PHP | PHP | ^8.2 |
| Package Manager (BE) | Composer | ≥ 2.x |

---

## 4. Setup Environment (Onboarding)

### Prasyarat Global

Pastikan semua tools berikut sudah terinstall di device sebelum mulai:

| Tool | Cek |
|---|---|
| PHP 8.2+ | `php -v` |
| Composer | `composer -v` |
| PostgreSQL (pgAdmin/DBeaver) | Service running |
| Flutter SDK | `flutter --version` |
| Git | `git --version` |

---

### 4a. Backend — Laravel

**Langkah 1 — Masuk ke folder backend**
```bash
cd backend
```

**Langkah 2 — Install dependencies PHP**
```bash
composer install
```

**Langkah 3 — Buat file `.env`**
```bash
cp .env.example .env
php artisan key:generate
```

**Langkah 4 — Sesuaikan konfigurasi database di `.env`**

Buka file `backend/.env`, sesuaikan bagian ini dengan kredensial PostgreSQL lokal kamu:
```env
DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=nutrify_db
DB_USERNAME=postgres
DB_PASSWORD=password_kamu_di_sini
```

**Langkah 4b — Isi konfigurasi Supabase di `.env`**

Dapatkan nilai dari [Supabase Dashboard](https://supabase.com/dashboard) → Project → Settings → API:
```env
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=eyJ...           # Project API Keys → anon/public
SUPABASE_JWT_SECRET=your-secret    # Settings → JWT → JWT Secret
```

**Langkah 5 — Buat database di PostgreSQL**

Buka pgAdmin4 atau DBeaver, jalankan:
```sql
CREATE DATABASE nutrify_db;
```

**Langkah 6 — Jalankan migration**
```bash
php artisan migrate
```

Tabel yang akan dibuat otomatis:
- `users` — data akun (dengan kolom `supabase_id` untuk sinkronisasi Supabase)
- `profiles` — data fisik pengguna (BB, TB, usia, goal)
- `foods` — database makanan beserta info nutrisi lengkap
- `food_logs` — riwayat konsumsi makanan per user
- `sessions`, `cache`, `jobs` — sistem Laravel

**Langkah 6b — Install package firebase/php-jwt**
```bash
composer require firebase/php-jwt
```
Package ini dibutuhkan oleh `VerifySupabaseToken` middleware untuk memvalidasi JWT dari Supabase.

**Langkah 7 — Jalankan server**
```bash
php artisan serve
```

API berjalan di: `http://localhost:8000`

---

### 4b. Frontend — Flutter

**Langkah 1 — Masuk ke folder frontend**
```bash
cd frontend/nutrify
```

**Langkah 2 — Install dependencies Dart**
```bash
flutter pub get
```

**Langkah 3 — Sesuaikan base URL API**

Cek file network constants di `lib/data/network/constants/` dan pastikan base URL mengarah ke backend lokal:
```dart
// Contoh
static const String baseUrl = 'http://10.0.2.2:8000/api'; // Android Emulator
// static const String baseUrl = 'http://localhost:8000/api'; // iOS/Web
```

> Untuk Android Emulator, gunakan `10.0.2.2` bukan `localhost` karena emulator memiliki network interface berbeda.

**Langkah 4 — Jalankan aplikasi**
```bash
flutter run
```

---

## 5. Arsitektur Backend

Backend menggunakan **Laravel 12** dengan pola **MVC** sederhana + REST API.

### Database Schema

```
users
├── id (PK)
├── supabase_id (string, unique, nullable) ← UUID dari Supabase Auth
├── name
├── email (unique)
├── password (hashed, acak — login via Supabase)
└── timestamps

profiles
├── id (PK)
├── user_id (FK → users.id, cascade delete)
├── age (integer)
├── weight (integer, kg)
├── height (integer, cm)
├── gender (enum: male, female)
├── goal (enum: cutting, maintenance, bulking)
├── activity_level (enum: sedentary, light, moderate, active, very_active)
└── timestamps

foods
├── id (PK)
├── name (string)
├── serving_size (string, nullable)        ← e.g. "100g", "1 porsi"
├── calories (float, default 0)            ← energy_kcal
├── protein (float, default 0)             ← protein_g
├── carbohydrates (float, default 0)       ← carbohydrate_g
├── fat (float, default 0)                 ← fat_g
├── sugar (float, default 0)               ← sugar_g
├── sodium (float, default 0)              ← sodium_mg
├── fiber (float, default 0)               ← fiber_g
└── timestamps

food_logs
├── id (PK)
├── user_id (FK → users.id, cascade delete)
├── food_id (FK → foods.id, cascade delete)
├── serving_multiplier (float, default 1)
├── meal_time (string: Breakfast/Lunch/Dinner/Snack)
└── timestamps
```

### Relasi Antar Model

```
User ──(has one)──► Profile
User ──(has many)──► FoodLog
Food ──(has many)──► FoodLog
FoodLog ──(belongs to)──► User
FoodLog ──(belongs to)──► Food
```

### Kalkulasi Nutrisi di Backend

`ProfileController@show` melakukan kalkulasi:

1. **BMI** = `weight / (height/100)²`
2. **BMR** (Mifflin-St Jeor):
   - Pria: `(10 × weight) + (6.25 × height) − (5 × age) + 5`
   - Wanita: `(10 × weight) + (6.25 × height) − (5 × age) − 161`
3. **TDEE** = `BMR × activity_factor`
4. **Target Kalori**:
   - Cutting: `TDEE − 500`
   - Bulking: `TDEE + 500`
   - Maintenance: `TDEE`

---

## 6. Arsitektur Frontend

Frontend menggunakan **Flutter** dengan arsitektur berlapis:

```
Presentation Layer  ←→  Domain Layer  ←→  Data Layer
(MobX Stores, UI)       (Entities,         (Dio HTTP,
                         UseCases,          SharedPreferences,
                         Repo Interface)    Sembast DB)
```

### Screens yang Sudah Ada

| Screen | File | Deskripsi |
|---|---|---|
| Home | `home_screen.dart` | Dashboard kalori harian |
| Add Meal | `add_meal_screen.dart` | Input makanan manual |
| Body Data | `body_data_screen.dart` | Input data fisik |
| Body Data + Goals | `body_data_goals_screen.dart` | Setup goal |
| Profile | `profile_screen.dart` | Profil user |
| Edit Profile | `edit_profile_screen.dart` | Edit data profil |
| Change Goal | `change_goal_screen.dart` | Ubah target kalori |
| History | `history_screen.dart` | Riwayat konsumsi per tanggal |
| Calorie Tracking | `tracking_kalori_screen.dart` | Tracking detail kalori |
| Main Navigation | `main_navigation_screen.dart` | Bottom navigation wrapper |

### Arsitektur Frontend — Dua Layer (Penting!)

Frontend memiliki **dua lapisan arsitektur** yang perlu dipahami:

#### Layer 1 — Boilerplate Architecture (MobX + Clean Architecture)
Digunakan untuk fitur auth. Terletak di:
```
lib/presentation/login/        ← Login screen (ada, tapi masih stub)
lib/domain/                    ← Entities, UseCases, Repository interfaces
lib/data/repository/           ← Implementasi repository
lib/data/network/              ← Dio client, REST client, interceptors
lib/data/sharedpref/           ← Token storage (SharedPreferenceHelper)
lib/di/                        ← Dependency Injection via get_it
```
⚠️ **Masalah:** `UserRepositoryImpl.login()` masih stub — hanya mengembalikan `User()` dummy setelah 2 detik delay, **belum memanggil API sama sekali**.

#### Layer 2 — Nutrify Screens (Direct Services)
Digunakan untuk fitur tracking. Terletak di:
```
lib/screens/                   ← Semua UI screens Nutrify
lib/services/                  ← MealService, ProfileService (local storage only)
lib/widgets/                   ← Reusable components
lib/constants/                 ← Theme, colors, assets
```
⚠️ **Masalah:** `MealService` dan `ProfileService` menyimpan data ke **SharedPreferences lokal device**, belum terhubung ke backend API sama sekali.

#### Screens yang Sudah Ada

| Screen | File | Status |
|---|---|---|
| Login | `presentation/login/login.dart` | UI ada, API stub |
| Home / Dashboard | `screens/home_screen.dart` | UI ada, data lokal |
| Add Meal | `screens/add_meal_screen.dart` | Input manual, tanpa Food API |
| Body Data | `screens/body_data_screen.dart` | UI static |
| Body Data + Goals | `screens/body_data_goals_screen.dart` | Tersimpan lokal |
| Profile | `screens/profile_screen.dart` | Data lokal |
| Edit Profile | `screens/edit_profile_screen.dart` | Tersimpan lokal |
| Change Goal | `screens/change_goal_screen.dart` | Tersimpan lokal |
| History | `screens/history_screen.dart` | Data lokal |
| Calorie Tracking | `screens/tracking_kalori_screen.dart` | Data lokal |
| Main Navigation | `screens/main_navigation_screen.dart` | Bottom nav 3 tab |
| Splash / Onboarding | — | **BELUM ADA** |
| Register | — | **BELUM ADA** |

---

## 7. API Reference

Base URL: `http://localhost:8000/api`

### Arsitektur Auth (Supabase)

```
┌─────────────┐   1. Login (email/Google/Apple)   ┌────────────────┐
│ Flutter App │ ────────────────────────────────► │ Supabase Auth  │
│             │ ◄──────────────────────────────── │                │
│             │   2. JWT access_token              └────────────────┘
│             │
│             │   3. HTTP request + JWT token
│             │   Authorization: Bearer {jwt}      ┌────────────────┐
│             │ ────────────────────────────────► │ Laravel API    │
│             │ ◄──────────────────────────────── │ (VerifySupabase│
└─────────────┘   4. Response data (JSON)          │  Token MW)     │
                                                   └────────────────┘
```

**Alur Auth:**
1. Flutter memanggil Supabase Auth (bukan Laravel) untuk login/register
2. Supabase mengembalikan JWT access token
3. Flutter menyimpan JWT dan mengirimkannya ke Laravel via header `Authorization: Bearer`
4. Middleware `VerifySupabaseToken` di Laravel memvalidasi JWT menggunakan `SUPABASE_JWT_SECRET`
5. Jika valid, user di-sync otomatis ke tabel `users` Laravel (berdasarkan `supabase_id`)

> **⚠️ Catatan:** Endpoint `POST /api/register` dan `POST /api/login-api` di Laravel **tidak lagi digunakan** untuk auth. Semua proses auth (register, login, forgot password) dilakukan via Supabase Auth SDK langsung dari Flutter.

### Protected Endpoints (Butuh Header Auth)

Tambahkan header berikut di **setiap request** ke Laravel:
```
Authorization: Bearer {supabase_jwt_token}
```

---

#### POST `/api/profile/store`
Menyimpan atau update data fisik user.

**Request Body:**
```json
{
  "age": 25,
  "weight": 70,
  "height": 175,
  "gender": "male",
  "activity_level": "moderate",
  "goal": "maintenance"
}
```
**Nilai yang Valid:**
- `gender`: `male` | `female`
- `activity_level`: `sedentary` | `light` | `moderate` | `active` | `very_active`
- `goal`: `cutting` | `maintenance` | `bulking`

---

#### GET `/api/profile`
Mengambil data profil beserta kalkulasi BMI, BMR, TDEE, dan target kalori.

**Response 200:**
```json
{
  "status": "success",
  "user": "Nama User",
  "physical_data": {
    "age": 25,
    "weight": "70 kg",
    "height": "175 cm",
    "gender": "male",
    "bmi": 22.86,
    "bmr": 1724,
    "tdee": 2672,
    "target_calories": 2672,
    "goal": "maintenance"
  }
}
```

---

#### POST `/api/food-logs`
Mencatat makanan yang dikonsumsi.

**Request Body:**
```json
{
  "food_id": 1,
  "serving_multiplier": 1.5,
  "meal_time": "Breakfast"
}
```
**Nilai yang Valid untuk `meal_time`:** `Breakfast` | `Lunch` | `Dinner` | `Snack`

**Response 201:**
```json
{
  "success": true,
  "message": "Makanan berhasil dicatat!",
  "data": {
    "log": { ... },
    "calories_consumed": 337.5
  }
}
```

---

#### POST `/api/logout`
Menghapus token saat ini (logout).

**Response 200:**
```json
{
  "message": "Berhasil logout dan token dihapus"
}
```

---

## 8. Masalah Kritikal yang Harus Segera Diselesaikan

> Temuan dari analisis codebase per 5 Maret 2026. Diupdate 6 Maret 2026 (Supabase auth + foods schema).

### 🔴 KRITIKAL — Backend

| # | Masalah | Lokasi | Dampak |
|---|---|---|---|
| 1 | **Dataset `nilai-gizi.csv` TIDAK ADA di backend.** Tabel `foods` kosong — tidak ada seeder, tidak ada import data. | `database/seeders/` | Food tracking tidak bisa berjalan |
| 2 | Register & Login Laravel (`POST /api/register`, `POST /api/login-api`) masih di closure `routes/api.php` — **tidak lagi dipakai** tapi belum dihapus/diarsipkan | `routes/api.php` | Membingungkan — perlu dihapus atau dikomen |
| 3 | `FoodLogController` masih ada fallback `Auth::id() ?? 1` | `FoodLogController.php:26` | Bug production — data masuk ke user ID 1 jika token tidak ada |
| 4 | Tidak ada endpoint `GET /api/foods` — frontend tidak bisa ambil daftar makanan | — | Food tracking tidak bisa berjalan |
| 5 | Tidak ada endpoint `GET /api/food-logs?date=` — tidak ada API untuk riwayat | — | History screen tidak bisa terhubung |
| 6 | Package `firebase/php-jwt` belum diinstall | `composer.json` | `VerifySupabaseToken` middleware tidak bisa berjalan |

### 🔴 KRITIKAL — Frontend

| # | Masalah | Lokasi | Dampak |
|---|---|---|---|
| 1 | **Tidak ada integrasi Supabase Auth** — `supabase_flutter` belum ada di `pubspec.yaml` | `pubspec.yaml` | Login tidak bisa berjalan sama sekali |
| 2 | **Tidak ada screen Splash, Onboarding, dan Register** | `presentation/my_app.dart` | User tidak bisa buat akun baru dari app |
| 3 | Semua data profil & meal tersimpan di SharedPreferences lokal, bukan API | `services/` | Data hanya ada di device |
| 4 | Supabase JWT tidak di-attach ke request Dio/HTTP | `data/network/` | Semua protected endpoint return 401 |

### 🟡 PERLU PERBAIKAN

| # | Masalah | Lokasi |
|---|---|---|
| 1 | CORS `allowed_origins` hanya `localhost:3000` — Flutter mobile tidak butuh CORS, tapi perlu dikonfigurasi jika ada Flutter Web | `config/cors.php` |
| 2 | `.env` memiliki duplikat `FRONTEND_URL=http://localhost:3000` (dua baris sama) | `backend/.env` |
| 3 | Arsitektur frontend terpecah dua (boilerplate MobX vs direct services) — perlu unifikasi | `lib/` |
| 4 | `pubspec.yaml` masih menggunakan nama package `boilerplate` bukan `nutrify` | `pubspec.yaml` |

### Aturan Umum

1. **JANGAN commit file `.env`** ke repo. Selalu gunakan `.env.example` sebagai template.
2. **Selalu buat branch baru** sebelum mengerjakan fitur. Jangan langsung push ke `main` atau `develop`.
3. **Satu PR = satu fitur atau satu bugfix.** Jangan campur banyak perubahan tidak berkaitan dalam satu PR.
4. **Code review wajib** sebelum merge ke `develop`. Minimal 1 approval dari anggota tim lain.
5. **Update `CHANGELOG.md`** (bagian ini) setiap kali push fitur selesai ke `develop`.

### Konvensi Penamaan

#### Backend (PHP / Laravel)
| Konteks | Format | Contoh |
|---|---|---|
| Controller | PascalCase + `Controller` | `FoodLogController` |
| Model | PascalCase singular | `FoodLog` |
| Migration | snake_case + timestamp | `2026_03_04_create_foods_table` |
| Route | kebab-case, plural | `/api/food-logs` |
| Variable | camelCase | `$targetCalories` |

#### Frontend (Dart / Flutter)
| Konteks | Format | Contoh |
|---|---|---|
| File | snake_case | `home_screen.dart` |
| Class | PascalCase | `HomeScreen` |
| Variable / function | camelCase | `loadDailyData()` |
| Konstanta | SCREAMING_SNAKE | `BASE_URL` |
| Widget | PascalCase | `CalorieCard` |

### Kode yang Harus Dihindari

- Jangan hardcode URL, password, atau API key di kode sumber.
- Jangan gunakan `Auth::id() ?? 1` di production (ini hanya untuk development/testing sementara di `FoodLogController`).
- Jangan commit `console.log`, `dd()`, atau `dump()` ke production branch.

---

## 10. Panduan Git & Branching

### Struktur Branch

```
main           ← Kode stabil, siap production (protected)
│
develop        ← Integrasi harian, kode QA
│
├── feature/be-07-food-list-api     ← Fitur backend
├── feature/fe-10-auth-integration  ← Fitur frontend
├── fix/be-food-log-validation      ← Bugfix
└── chore/update-env-example        ← Non-fitur (config, docs)
```

### Aturan Branch

| Branch | Dibuat dari | Merge ke | Siapa |
|---|---|---|---|
| `feature/*` | `develop` | `develop` via PR | Developer |
| `fix/*` | `develop` | `develop` via PR | Developer |
| `hotfix/*` | `main` | `main` + `develop` | Lead |
| `develop` | — | `main` via PR | Lead |

### Alur Kerja Sehari-hari

```bash
# 1. Ambil perubahan terbaru
git pull origin develop

# 2. Buat branch baru berdasarkan task
git checkout -b feature/fe-10-auth-integration

# 3. Kerjakan fitur...

# 4. Commit dengan format yang benar
git add .
git commit -m "feat(frontend): tambah login screen dengan auth API"

# 5. Push branch kamu
git push origin feature/fe-10-auth-integration

# 6. Buka Pull Request ke develop di GitHub
```

### Format Commit Message

Gunakan format **Conventional Commits**:

```
<type>(<scope>): <deskripsi singkat dalam bahasa Indonesia>

type:
  feat     → fitur baru
  fix      → perbaikan bug
  refactor → refaktor kode tanpa fitur/bug
  chore    → update config, dependencies, docs
  test     → penambahan / perbaikan test
  style    → formatting, whitespace

scope:
  backend  → perubahan di folder backend/
  frontend → perubahan di folder frontend/
  db       → migration / seeder
  api      → route / controller
```

**Contoh:**
```
feat(backend): tambah endpoint GET /api/foods dengan fitur search
fix(frontend): perbaiki kalkulasi kalori yang salah di home screen
chore(db): tambah seeder untuk data makanan awal
refactor(api): pindahkan register/login ke AuthController
```

---

## 11. Troubleshooting

### Backend

**`php artisan migrate` gagal dengan error koneksi**
- Pastikan service PostgreSQL sedang berjalan di pgAdmin / DBeaver
- Periksa kembali `DB_PASSWORD` di `.env`, sesuaikan dengan password PostgreSQL lokal

**`Class "App\Models\Profile" not found`**
```bash
php artisan config:clear
composer dump-autoload
```

**`php artisan serve` port sudah dipakai**
```bash
php artisan serve --port=8001
```

**Token Sanctum tidak valid (401)**
- Auth Sanctum sudah tidak digunakan — gunakan JWT Supabase
- Pastikan header `Authorization: Bearer {supabase_jwt}` dikirim dengan benar

---

### Frontend

**`flutter pub get` gagal**
- Cek versi Flutter: `flutter --version` (butuh ≥ SDK 3.0.0)
- Jalankan `flutter clean` lalu `flutter pub get` ulang

**Android Emulator tidak bisa akses API**
- Ganti `localhost` dengan `10.0.2.2` di base URL API
- Pastikan `php artisan serve` berjalan di mesin yang sama

**Error `MissingPluginException` saat run**
```bash
flutter clean
flutter pub get
flutter run
```

---

### Supabase Auth

**JWT expired → 401 dari Laravel**
- `supabase_flutter` otomatis me-refresh token. Pastikan kamu menggunakan `supabase.auth.currentSession?.accessToken` yang terbaru, bukan token yang di-cache manual.

**Google Sign-In tidak muncul di Android**
- Pastikan `SHA-1` fingerprint app sudah terdaftar di Google Cloud Console project yang terhubung ke Supabase.
- Jalankan `./gradlew signingReport` di folder `android/` untuk mendapatkan SHA-1.

**Supabase email tidak masuk**
- Cek Supabase Dashboard → Authentication → Logs untuk melihat status pengiriman email.
- Pastikan custom SMTP sudah dikonfigurasi di Dashboard → Project Settings → Auth → SMTP Settings.
- Batas gratis Supabase: 3 email/jam — gunakan custom SMTP untuk production.

**`SUPABASE_JWT_SECRET` tidak cocok**
- Pastikan nilai di `.env` sama persis dengan nilai di Supabase Dashboard → Settings → JWT → JWT Secret (bukan anon key!).

---

## 12. Panduan Setup Supabase

### 12.1 Buat Project Supabase

1. Daftar/login di [supabase.com](https://supabase.com)
2. Klik **New Project** → isi nama, password database, pilih region terdekat (Singapore)
3. Tunggu provisioning (~2 menit)
4. Buka **Settings → API**:
   - Salin **Project URL** → `SUPABASE_URL`
   - Salin **anon/public key** → `SUPABASE_ANON_KEY`
5. Buka **Settings → JWT** → salin **JWT Secret** → `SUPABASE_JWT_SECRET`

---

### 12.2 Aktifkan Provider OAuth

#### Google (Gmail) Login
1. Supabase Dashboard → **Authentication → Providers → Google**
2. Klik **Enable**
3. Buka [Google Cloud Console](https://console.cloud.google.com) → Credentials → Create OAuth 2.0 Client ID
   - Application type: **Web application**
   - Authorized redirect URI: `https://your-project-ref.supabase.co/auth/v1/callback`
4. Salin **Client ID** dan **Client Secret** ke Supabase Google provider settings
5. Untuk Android: tambahkan SHA-1 fingerprint di Google Console → OAuth Client (Android)

#### Apple Login
1. Supabase Dashboard → **Authentication → Providers → Apple**
2. Klik **Enable**
3. Diperlukan: **Apple Developer Account** (berbayar $99/tahun)
4. Buat **App ID** dengan Sign in with Apple capability di [developer.apple.com](https://developer.apple.com)
5. Buat **Service ID** → konfigurasi domain dan redirect URL: `https://your-project-ref.supabase.co/auth/v1/callback`
6. Buat **Key** dengan Sign in with Apple enabled → download `.p8` file
7. Isi **Team ID**, **Key ID**, dan upload file `.p8` ke Supabase Apple provider settings

---

### 12.3 Konfigurasi Custom SMTP (Emailing)

Supabase hanya mengirim 3 email/jam di plan gratis. Untuk production, gunakan **custom SMTP**.

**Provider yang direkomendasikan:** [Resend](https://resend.com) (free tier: 3000 email/bulan) atau [Brevo](https://brevo.com) (free tier: 300 email/hari).

**Langkah setup di Supabase:**
1. Supabase Dashboard → **Project Settings → Auth → SMTP Settings**
2. Aktifkan **Enable Custom SMTP**
3. Isi konfigurasi:
   ```
   Host:        smtp.resend.com (atau smtp-relay.brevo.com)
   Port:        465 (SSL) atau 587 (TLS)
   User:        apikey (untuk Resend) / email kamu (Brevo)
   Password:    API key dari provider
   Sender Name: Nutrify
   Sender Email: noreply@domain-kamu.com
   ```
4. Klik **Save** → **Test SMTP Connection** untuk verifikasi

**Template email yang bisa dikustomisasi** (Dashboard → Auth → Email Templates):
- **Confirm signup** — email konfirmasi akun baru
- **Reset password** — link reset password (berlaku 1 jam)
- **Magic Link** — login tanpa password
- **Change email** — konfirmasi perubahan email
- **Invite user** — undangan oleh admin

---

### 12.4 Konfigurasi redirect URL (Deep Link)

Agar Supabase bisa redirect kembali ke app Flutter setelah OAuth atau email link:

1. Supabase Dashboard → **Authentication → URL Configuration**
2. **Site URL**: `nutrify://login-callback` (scheme deep link Flutter)
3. **Redirect URLs**: tambahkan `nutrify://login-callback`

Di Flutter, tambahkan intent filter di `AndroidManifest.xml` dan iOS URL scheme:
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="nutrify" />
</intent-filter>
```

---

*Dokumen ini dikelola bersama. Update bagian yang relevan setiap kali ada perubahan signifikan di proyek.*
*Untuk detail backlog, changelog, dan rencana sprint, lihat [BACKLOG.md](BACKLOG.md), [CHANGELOG.md](CHANGELOG.md), dan [planning.md](planning.md).*
