# NUTRIFY — Guide Iterasi 1
### Panduan Setup Lengkap dari Nol + Backlog Sprint 1

> **Untuk siapa:** Developer yang baru clone repo dan belum melakukan apapun.
> **Asumsi:** Kamu sudah install Git dan sudah berhasil `git clone`. Itu saja.
> **Terakhir diperbarui:** 5 Maret 2026

---

## Daftar Isi

**BAGIAN A — INSTALL TOOLS** (lakukan sekali saja di device baru)
1. [Install PHP 8.2](#a1-install-php-82)
2. [Install Composer](#a2-install-composer)
3. [Install PostgreSQL + pgAdmin](#a3-install-postgresql--pgadmin)
4. [Install Flutter SDK](#a4-install-flutter-sdk)
5. [Install VS Code + Extensions](#a5-install-vs-code--extensions)

**BAGIAN B — SETUP PROYEK** (lakukan setiap clone repo baru)
6. [Setup Backend Laravel](#b1-setup-backend-laravel)
7. [Setup Database di pgAdmin](#b2-setup-database-di-pgadmin)
8. [Setup Supabase](#b3-setup-supabase)
9. [Setup Frontend Flutter](#b4-setup-frontend-flutter)
10. [Menjalankan Aplikasi](#b5-menjalankan-aplikasi)

**BAGIAN C — BACKLOG & STATUS**
11. [Status Kode Saat Ini](#c1-status-kode-saat-ini)
12. [Backlog To-Do — Berurutan](#c2-backlog-to-do--berurutan)

---

# BAGIAN A — INSTALL TOOLS

> Lewati bagian ini jika tool sudah terinstall. Cek dulu dengan perintah verifikasi di setiap bagian.

---

## A.1 Install PHP 8.2

**Cek apakah sudah ada:**
```
php -v
```
Jika muncul `PHP 8.2.x` atau lebih baru → lanjut ke A.2. Jika tidak, ikuti langkah di bawah.

**Windows:**
1. Buka https://windows.php.net/download/
2. Pilih **PHP 8.2** → kolom **VS17 x64 Non Thread Safe** → klik **Zip**
3. Ekstrak ke `C:\php`
4. Rename file `php.ini-development` menjadi `php.ini`
5. Buka `php.ini` dengan Notepad, cari dan hilangkan `;` (tanda titik koma) di depan baris-baris ini:
   ```
   extension=curl
   extension=fileinfo
   extension=mbstring
   extension=openssl
   extension=pdo_pgsql
   extension=pgsql
   extension=zip
   ```
6. Tambahkan PHP ke PATH:
   - Klik kanan **This PC** → **Properties** → **Advanced system settings**
   - Klik **Environment Variables**
   - Di bagian **System variables**, klik **Path** → **Edit** → **New**
   - Ketik `C:\php` → OK semua
7. Tutup dan buka ulang terminal, lalu cek:
   ```
   php -v
   ```
   Harus muncul: `PHP 8.2.x ...`

---

## A.2 Install Composer

**Cek apakah sudah ada:**
```
composer -V
```
Jika muncul `Composer version 2.x` → lanjut ke A.3.

**Windows:**
1. Buka https://getcomposer.org/Composer-Setup.exe
2. Jalankan installer → ikuti semua langkah default
3. Saat diminta **PHP executable**, arahkan ke `C:\php\php.exe`
4. Setelah selesai, buka terminal baru dan cek:
   ```
   composer -V
   ```
   Harus muncul: `Composer version 2.x.x`

---

## A.3 Install PostgreSQL + pgAdmin

**Cek apakah sudah ada:**
- Cek di Windows **Start Menu** → apakah ada **pgAdmin 4**

**Install:**
1. Buka https://www.postgresql.org/download/windows/
2. Klik **Download the installer** → pilih versi **17.x** → **Windows x86-64**
3. Jalankan installer:
   - Password untuk user `postgres`: **catat ini baik-baik**, akan dipakai di langkah B.1
   - Port: biarkan default **5432**
   - Locale: biarkan default
   - Centang semua komponen termasuk **pgAdmin 4**
4. Setelah selesai, buka **pgAdmin 4** dari Start Menu → masukkan password yang tadi dibuat

---

## A.4 Install Flutter SDK

**Cek apakah sudah ada:**
```
flutter --version
```
Jika muncul `Flutter 3.x.x` → lanjut ke A.5.

**Windows:**
1. Buka https://docs.flutter.dev/get-started/install/windows/mobile
2. Klik **Download Flutter SDK** → ekstrak zip ke `C:\flutter`
3. Tambahkan ke PATH (sama seperti PHP tadi):
   - **Environment Variables** → **Path** → **New** → ketik `C:\flutter\bin`
4. Buka terminal baru dan jalankan:
   ```
   flutter doctor
   ```
   Perintah ini akan menunjukkan apa yang masih kurang. Ikuti saran yang muncul.

5. **Install Android Studio** (jika belum):
   - Unduh dari https://developer.android.com/studio
   - Setelah install, buka Android Studio → **SDK Manager**
   - Install: **Android SDK**, **Android SDK Build-Tools**, **Android Emulator**

6. Jalankan lagi `flutter doctor` — idealnya semua centang hijau kecuali Xcode (itu untuk iOS/Mac).

---

## A.5 Install VS Code + Extensions

1. Unduh VS Code dari https://code.visualstudio.com/ → install
2. Buka VS Code → klik ikon Extensions di sidebar (atau `Ctrl+Shift+X`)
3. Install extension berikut satu per satu:

| Extension | Publisher | Fungsi |
|---|---|---|
| **Flutter** | Dart Code | Support Flutter di VS Code |
| **Dart** | Dart Code | Otomatis terpasang bersama Flutter |
| **PHP Intelephense** | Ben Mewburn | Autocomplete PHP |
| **Laravel Extra Intellisense** | amir | Autocomplete Laravel |
| **GitLens** | GitKraken | Visualisasi Git yang lebih baik |

---

# BAGIAN B — SETUP PROYEK

> Lakukan setiap kali clone repo ke device baru.

**Struktur folder repo:**
```
nutrify/           ← Root repo (kamu sekarang ada di sini setelah git clone)
├── backend/       ← Kode Laravel (PHP)
├── frontend/      ← Kode Flutter (Dart)
├── guide-1.md     ← File ini
└── nilai-gizi.csv ← Dataset makanan Indonesia (1000+ item)
```

---

## B.1 Setup Backend Laravel

Buka terminal, masuk ke folder backend:
```bash
cd C:\Users\...\nutrify\backend
```
> Sesuaikan path dengan lokasi folder kamu.

---

**Langkah 1 — Install dependencies PHP**
```bash
composer install
```
> Proses ini mengunduh semua library PHP yang dibutuhkan ke folder `vendor/`.
> Akan memakan waktu 2–5 menit pertama kali.
> Output normal: `Generating optimized autoload files`

---

**Langkah 2 — Install library JWT (dibutuhkan untuk Supabase auth)**
```bash
composer require firebase/php-jwt
```
> Output normal: `./composer.json has been updated`

---

**Langkah 3 — Buat file konfigurasi `.env`**
```bash
copy .env.example .env
```
> File `.env` adalah tempat menyimpan konfigurasi rahasia (password database, API key, dsb).
> File ini **tidak pernah di-commit ke Git** karena berisi data sensitif.

---

**Langkah 4 — Generate app key**
```bash
php artisan key:generate
```
> Output: `Application key set successfully.`
> Ini mengisi nilai `APP_KEY` di file `.env` kamu.

---

**Langkah 5 — Edit file `.env`**

Buka file `backend/.env` di VS Code. Cari bagian ini dan sesuaikan:

```env
DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=nutrify_db
DB_USERNAME=postgres
DB_PASSWORD=ISI_DENGAN_PASSWORD_POSTGRES_KAMU
```
> Isi `DB_PASSWORD` dengan password yang kamu buat saat install PostgreSQL (Langkah A.3).

Bagian Supabase (isi nanti setelah selesai B.3):
```env
SUPABASE_URL=https://xxxxxxxx.supabase.co
SUPABASE_ANON_KEY=eyJ...
SUPABASE_JWT_SECRET=xxxxxxx
```
> Biarkan dulu kosong, kita isi setelah setup Supabase di B.3.

---

**Langkah 6 — Buat database di pgAdmin (lanjut ke B.2, lalu kembali ke sini)**

Setelah database `nutrify_db` dibuat di B.2, jalankan:
```bash
php artisan migrate
```
> Perintah ini membuat semua tabel di database secara otomatis.
> Output normal:
> ```
> Running migrations...
>   2026_03_02_124124_create_personal_access_tokens_table ............. DONE
>   2026_03_02_125341_create_profiles_table ........................... DONE
>   2026_03_04_084150_create_foods_table .............................. DONE
>   2026_03_04_095600_create_food_logs_table .......................... DONE
>   2026_03_06_000001_add_supabase_id_to_users_table .................. DONE
> ```

---

**Langkah 7 — Jalankan server backend**
```bash
php artisan serve
```
> Output: `INFO  Server running on [http://127.0.0.1:8000].`
>
> Buka browser → http://localhost:8000/up
> Harus muncul teks: `{"status":"up",...}`
>
> Biarkan terminal ini tetap berjalan. Buka terminal baru untuk langkah berikutnya.

---

## B.2 Setup Database di pgAdmin

1. Buka **pgAdmin 4** dari Start Menu
2. Di panel kiri, klik kanan **Servers** → **Register** → **Server...**
3. Isi tab **General**:
   - Name: `Nutrify Local`
4. Klik tab **Connection**, isi:
   - Host: `127.0.0.1`
   - Port: `5432`
   - Username: `postgres`
   - Password: password PostgreSQL kamu
5. Klik **Save**
6. Di panel kiri: **Nutrify Local** → **Databases** → klik kanan → **Create** → **Database...**
7. Isi **Database name**: `nutrify_db`
8. Klik **Save**
9. Kembali ke terminal dan lanjutkan Langkah 6 di B.1 (`php artisan migrate`)

---

## B.3 Setup Supabase

Supabase adalah layanan autentikasi dan database cloud gratis yang kita gunakan untuk login.

---

**Langkah 1 — Buat akun Supabase**
1. Buka https://supabase.com → klik **Start your project**
2. Daftar dengan akun GitHub atau email
3. Klik **New project**:
   - Organization: pilih yang ada atau buat baru
   - Project name: `nutrify`
   - Database password: buat password yang kuat (**catat!**)  
   - Region: pilih **Southeast Asia (Singapore)**
4. Klik **Create new project** — tunggu ~2 menit

---

**Langkah 2 — Ambil konfigurasi API**

Setelah project siap:
1. Di sidebar Supabase, klik **Project Settings** (ikon gear)
2. Klik **API**
3. Salin nilai berikut ke file `backend/.env`:
   - **Project URL** → `SUPABASE_URL`
   - **anon / public** key → `SUPABASE_ANON_KEY`

---

**Langkah 3 — Ambil JWT Secret**
1. Masih di **Project Settings**
2. Klik **JWT Settings**  
   *(atau cari di URL: `project-ref.supabase.co/settings/jwt`)*
3. Salin **JWT Secret** → `SUPABASE_JWT_SECRET` di `.env`

---

**Langkah 4 — Aktifkan Email Auth**
1. Sidebar → **Authentication** → **Providers**
2. Pastikan **Email** sudah **Enabled**
3. Untuk sementara, aktifkan **"Confirm email"** = OFF (agar mudah testing tanpa cek email)

---

**Langkah 5 — Konfigurasi Redirect URL (untuk deep link Flutter nanti)**
1. Sidebar → **Authentication** → **URL Configuration**
2. **Site URL**: `nutrify://login-callback`
3. **Redirect URLs**, klik **Add URL**: `nutrify://login-callback`
4. Klik **Save**

> **Untuk Google/Apple OAuth:** diaktifkan nanti di tahap implementasi. Untuk sekarang cukup email saja.

---

**Langkah 6 — Setup Custom SMTP (Opsional tapi direkomendasikan)**

Supabase gratis hanya kirim 3 email/jam. Untuk testing yang lebih lancar, setup custom SMTP:

1. Daftar di https://resend.com (gratis 3.000 email/bulan)
2. Buat API key di Resend → **API Keys** → **Create API Key**
3. Kembali ke Supabase → **Project Settings** → **Auth** → **SMTP Settings**
4. Aktifkan **Enable Custom SMTP** → isi:
   - SMTP Host: `smtp.resend.com`
   - Port: `465`
   - Username: `resend`
   - Password: API key dari Resend
   - Sender email: email kamu (harus diverifikasi di Resend)
5. Klik **Save** → **Test SMTP Connection**

---

## B.4 Setup Frontend Flutter

Buka terminal baru, masuk ke folder frontend:
```bash
cd C:\Users\...\nutrify\frontend
```

---

**Langkah 1 — Install dependencies Flutter**
```bash
flutter pub get
```
> Mengunduh semua package Dart yang dibutuhkan.
> Output normal: `Got dependencies!`

---

**Langkah 2 — Cek konfigurasi URL backend**

Buka file `frontend/lib/data/network/constants/app_constants.dart` (atau file serupa di `lib/data/network/`).
Pastikan base URL mengarah ke backend lokal:
```dart
// Untuk Android Emulator:
static const String baseUrl = 'http://10.0.2.2:8000/api';

// Untuk iOS Simulator atau Web:
// static const String baseUrl = 'http://localhost:8000/api';
```
> `10.0.2.2` adalah alias `localhost` khusus untuk Android Emulator.

---

**Langkah 3 — Generate kode MobX**

Flutter di proyek ini menggunakan MobX (state management). Jalankan code generator:
```bash
dart run build_runner build --delete-conflicting-outputs
```
> Output normal: `[INFO] Succeeded after ...`

---

**Langkah 4 — Jalankan emulator**

Buka Android Studio → **Device Manager** → klik tombol **Play** di emulator yang ada.
Tunggu sampai emulator Android muncul di layar.

---

**Langkah 5 — Jalankan aplikasi Flutter**
```bash
flutter run
```
> Output normal: `Launching lib/main.dart on ... in debug mode.`
> App akan muncul di emulator.
>
> Jika ada pilihan device, ketik angka yang sesuai dengan emulator.

---

## B.5 Menjalankan Aplikasi

Setelah semua setup selesai, cara menjalankan tiap hari:

**Terminal 1 — Backend:**
```bash
cd C:\Users\...\nutrify\backend
php artisan serve
```

**Terminal 2 — Frontend:**
```bash
cd C:\Users\...\nutrify\frontend
flutter run
```

**Cek backend berjalan:** http://localhost:8000/up → harus muncul `{"status":"up"}`

---

# BAGIAN C — BACKLOG & STATUS

---

## C.1 Status Kode Saat Ini

### Apa yang sudah ada di kode (tapi belum tentu jalan)

| Komponen | Status | Keterangan |
|---|---|---|
| Database schema (tabel users, profiles, foods, food_logs) | ✅ Siap | Migration sudah ada, tinggal `php artisan migrate` |
| Foods schema (dengan sodium, fiber, serving_size) | ✅ Siap | Migration sudah diupdate |
| Kolom `supabase_id` di tabel users | ✅ Siap | Migration sudah ada |
| Kalkulasi BMI & TDEE (`GET /api/profile`) | ✅ Berjalan | ProfileController sudah ada |
| Simpan food log (`POST /api/food-logs`) | ⚠️ Sebagian | Ada bug `Auth::id() ?? 1` yang harus diperbaiki |
| Middleware `VerifySupabaseToken` | ✅ Kode ada | **Belum terhubung ke routes!** |
| Config Supabase (`config/supabase.php`) | ✅ Ada | Membaca dari `.env` |
| Package `firebase/php-jwt` | ❌ Belum install | Wajib: `composer require firebase/php-jwt` |
| Route `/api/register` & `/api/login-api` | ⚠️ Masih ada | Menggunakan Sanctum lama, harus dihapus setelah Supabase aktif |
| Route protected pakai `auth:sanctum` | ⚠️ Masih Sanctum | Harus diganti ke `VerifySupabaseToken` |
| Tabel `foods` | ❌ Kosong | Tidak ada data makanan sama sekali, FoodSeeder belum dibuat |
| Login Flutter | ❌ Stub | Hanya return `User()` dummy setelah 2 detik, tidak hit API |
| `supabase_flutter` di Flutter | ❌ Belum ada | Belum ditambahkan ke `pubspec.yaml` |
| Splash Screen | ❌ Belum ada | — |
| Register Screen | ❌ Belum ada | — |
| Onboarding Screen | ❌ Belum ada | — |

---

## C.2 Backlog To-Do — Berurutan

> Kerjakan **sesuai urutan**. Item di atas adalah prasyarat untuk item di bawahnya.

---

### 🔴 PRIORITAS 1 — Backend: Aktifkan Supabase Auth

#### TODO-BE-01 · Install `firebase/php-jwt`
```bash
cd backend
composer require firebase/php-jwt
```
- **Kenapa:** Middleware `VerifySupabaseToken` tidak bisa berjalan tanpa package ini.
- **Siapa:** Backend developer
- **File:** `composer.json` (otomatis terupdate)

---

#### TODO-BE-02 · Jalankan migration database
```bash
php artisan migrate
```
- **Kenapa:** Membuat tabel `supabase_id` di users dan mengaktifkan schema foods terbaru.
- **Syarat:** Database `nutrify_db` sudah dibuat di pgAdmin, `.env` sudah diisi.

---

#### TODO-BE-03 · Daftarkan middleware `VerifySupabaseToken` di `bootstrap/app.php`

Buka `backend/bootstrap/app.php`. Tambahkan alias middleware:
```php
// Di dalam ->withMiddleware(function (Middleware $middleware): void {
$middleware->alias([
    'verified'       => \App\Http\Middleware\EnsureEmailIsVerified::class,
    'supabase.auth'  => \App\Http\Middleware\VerifySupabaseToken::class,  // ← tambah ini
]);
```
- **Kenapa:** Agar bisa dipakai sebagai `middleware('supabase.auth')` di routes.
- **File:** `backend/bootstrap/app.php`

---

#### TODO-BE-04 · Update `routes/api.php` — ganti Sanctum → Supabase

Hapus route lama (`/register`, `/login-api`) dan ganti middleware protected routes:

```php
// HAPUS kedua route ini:
Route::post('/register', function ...);
Route::post('/login-api', function ...);

// GANTI middleware group ini:
// SEBELUM:
Route::middleware(['auth:sanctum'])->group(function () { ... });

// SESUDAH:
Route::middleware(['supabase.auth'])->group(function () { ... });
```
- **File:** `backend/routes/api.php`
- **Catatan:** Pastikan SUPABASE_JWT_SECRET sudah diisi di `.env` sebelum ini aktif.

---

#### TODO-BE-05 · Fix bug `Auth::id() ?? 1` di FoodLogController

Buka `backend/app/Http/Controllers/FoodLogController.php` baris ~26:
```php
// SEBELUM (berbahaya):
$validated['user_id'] = Auth::id() ?? 1;

// SESUDAH (aman):
$validated['user_id'] = Auth::id();
```
- **Kenapa:** Kalau tidak diperbaiki, food log bisa masuk ke user ID 1 jika token tidak valid.
- **File:** `backend/app/Http/Controllers/FoodLogController.php`

---

### 🔴 PRIORITAS 2 — Backend: Data Makanan

#### TODO-BE-06 · Buat `FoodSeeder` dari `nilai-gizi.csv`

Buat file `backend/database/seeders/FoodSeeder.php` yang membaca `nilai-gizi.csv` dan mengisi tabel `foods`.

Pemetaan kolom CSV → tabel:
| Kolom di CSV | Kolom di tabel |
|---|---|
| `name` | `name` |
| `serving_size` | `serving_size` |
| `energy_kcal` | `calories` |
| `protein_g` | `protein` |
| `carbohydrate_g` | `carbohydrates` |
| `fat_g` | `fat` |
| `sugar_g` | `sugar` |
| `sodium_mg` | `sodium` |
| `fiber_g` | `fiber` |

Setelah dibuat, daftarkan di `DatabaseSeeder.php` lalu jalankan:
```bash
php artisan db:seed --class=FoodSeeder
```
- **File baru:** `backend/database/seeders/FoodSeeder.php`
- **File diubah:** `backend/database/seeders/DatabaseSeeder.php`
- **Prioritas:** TINGGI — tanpa ini tidak ada data makanan sama sekali.

---

#### TODO-BE-07 · Buat `FoodController` + endpoint GET /api/foods

Buat controller baru `backend/app/Http/Controllers/Api/FoodController.php`:
```
GET /api/foods             → Daftar semua makanan (20 per halaman)
GET /api/foods?search=nasi → Cari makanan by nama
```
- **File baru:** `backend/app/Http/Controllers/Api/FoodController.php`
- **File diubah:** `backend/routes/api.php` (tambah route)

---

#### TODO-BE-08 · Buat endpoint GET /api/food-logs/summary

```
GET /api/food-logs/summary?date=2026-03-05
→ Return: total kalori + makro hari itu, dikategorikan per meal_time
```
- Dibutuhkan oleh Home Screen (dashboard kalori harian)

---

#### TODO-BE-09 · Buat endpoint GET /api/food-logs?date=

```
GET /api/food-logs?date=2026-03-05
→ Return: daftar makanan yang dimakan hari itu
```
- Dibutuhkan oleh History Screen

---

#### TODO-BE-10 · Buat endpoint DELETE /api/food-logs/{id}

```
DELETE /api/food-logs/{id}
→ Hapus satu log makanan
```

---

### 🟡 PRIORITAS 3 — Frontend: Supabase Auth

#### TODO-FE-01 · Tambah `supabase_flutter` dan package pendukung ke `pubspec.yaml`

Buka `frontend/pubspec.yaml`, tambahkan di bagian `dependencies`:
```yaml
supabase_flutter: ^2.9.0
google_sign_in: ^6.2.2
sign_in_with_apple: ^6.1.4
crypto: ^3.0.5
```
Lalu jalankan:
```bash
flutter pub get
```

---

#### TODO-FE-02 · Inisialisasi Supabase di `main.dart`

Buka `frontend/lib/main.dart`, tambahkan inisialisasi Supabase sebelum `runApp`:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://your-project-ref.supabase.co',  // dari B.3
    anonKey: 'your-anon-key',                      // dari B.3
  );
  ServiceLocator.configureDependencies();
  runApp(MyApp());
}
```
- **File:** `frontend/lib/main.dart`

---

#### TODO-FE-03 · Buat Splash Screen

- File baru: `frontend/lib/screens/splash_screen.dart`
- Logika: cek `Supabase.instance.client.auth.currentSession`
  - Jika ada session → ke Home
  - Jika tidak ada → ke Onboarding
- Set `SplashScreen` sebagai halaman awal di routing

---

#### TODO-FE-04 · Buat Onboarding Screen

- File baru: `frontend/lib/screens/onboarding_screen.dart`
- 3–4 halaman swipeable, tombol "Skip" dan "Mulai"
- Halaman terakhir: tombol **Mulai** → ke Login Screen

---

#### TODO-FE-05 · Buat Register Screen

- File baru: `frontend/lib/screens/register_screen.dart`
- Fields: Nama, Email, Password, Konfirmasi Password
- Panggil `Supabase.instance.client.auth.signUp(email, password, data: {name})`
- Setelah berhasil → arahkan ke halaman verifikasi email (atau langsung login jika confirm email dimatikan)

---

#### TODO-FE-06 · Implementasi Email Login via Supabase

Buka `frontend/lib/data/repository/user/user_repository_impl.dart`.

Saat ini isinya masih **stub palsu**:
```dart
// INI YANG HARUS DIGANTI:
Future.delayed(Duration(seconds: 2), () => User())
```

Ganti dengan implementasi nyata:
```dart
final response = await Supabase.instance.client.auth.signInWithPassword(
  email: params.username,
  password: params.password,
);
final jwt = response.session?.accessToken;
await _sharedPrefsHelper.saveAuthToken(jwt!);
await _sharedPrefsHelper.saveIsLoggedIn(true);
return User();
```
- **File:** `frontend/lib/data/repository/user/user_repository_impl.dart`

---

#### TODO-FE-07 · JWT Interceptor — Auto-attach token ke semua request Dio

Buat file baru: `frontend/lib/data/network/interceptors/auth_interceptor.dart`

```dart
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      options.headers['Authorization'] = 'Bearer ${session.accessToken}';
    }
    handler.next(options);
  }
}
```
Daftarkan interceptor ini ke `DioClient`.
- **Kenapa:** Tanpa ini semua endpoint Laravel yang butuh auth akan return `401 Unauthorized`

---

#### TODO-FE-08 · Forgot Password / Reset Password

```dart
// Kirim email reset password
await Supabase.instance.client.auth.resetPasswordForEmail(
  email,
  redirectTo: 'nutrify://reset-password-callback',
);
```
- Buat UI form "Lupa Password" → tambahkan link dari Login Screen

---

#### TODO-FE-09 · Google Login (Opsional Sprint 1)

```dart
await Supabase.instance.client.auth.signInWithOAuth(
  OAuthProvider.google,
  redirectTo: 'nutrify://login-callback',
);
```
- Prasyarat: Setup Google OAuth di Supabase Dashboard + SHA-1 fingerprint

---

#### TODO-FE-10 · Apple Login (Opsional Sprint 1)

- Prasyarat: Apple Developer Account ($99/tahun)
- Gunakan package `sign_in_with_apple`

---

### 🟡 PRIORITAS 4 — Frontend: Integrasi API

#### TODO-FE-11 · Hubungkan Profile ke API

Di `frontend/lib/services/profile_service.dart`, ganti semua operasi SharedPreferences lokal dengan panggilan ke `GET /api/profile` dan `POST /api/profile/store`.

#### TODO-FE-12 · Hubungkan Add Meal ke API

Di `frontend/lib/screens/add_meal_screen.dart`:
1. Tampilkan daftar makanan dari `GET /api/foods?search=query`
2. Saat simpan → kirim ke `POST /api/food-logs`

#### TODO-FE-13 · Hubungkan Dashboard ke API

Di `frontend/lib/screens/home_screen.dart` dan `tracking_kalori_screen.dart`:
- Ganti data lokal dengan `GET /api/food-logs/summary?date=today`

#### TODO-FE-14 · Hubungkan History ke API

Di `frontend/lib/screens/history_screen.dart`:
- Ambil data dari `GET /api/food-logs?date=YYYY-MM-DD`

---

### 🟢 PRIORITAS 5 — QA & Polish

#### TODO-QA-01 · Rename package Flutter dari `boilerplate` ke `nutrify`

Buka `frontend/pubspec.yaml` baris pertama:
```yaml
# SEBELUM:
name: boilerplate

# SESUDAH:
name: nutrify
```
Setelah rename, jalankan `flutter pub get` lagi.

#### TODO-QA-02 · PHPUnit Tests

Buat test di `backend/tests/Feature/`:
- `Auth/LoginTest.php`
- `ProfileTest.php`
- `FoodTest.php`
- `FoodLogTest.php`

#### TODO-QA-03 · User Research

Interview 20+ calon pengguna tentang kebiasaan pencatatan kalori.

---

## Ringkasan To-Do (Versi Singkat)

```
BACKEND (kerjakan dulu, blokir frontend)
─────────────────────────────────────────────────────
☐ TODO-BE-01  composer require firebase/php-jwt
☐ TODO-BE-02  php artisan migrate
☐ TODO-BE-03  Daftarkan alias 'supabase.auth' di bootstrap/app.php
☐ TODO-BE-04  Update routes/api.php — pakai supabase.auth, hapus Sanctum routes
☐ TODO-BE-05  Fix Auth::id() ?? 1 di FoodLogController
☐ TODO-BE-06  Buat FoodSeeder dari nilai-gizi.csv → php artisan db:seed
☐ TODO-BE-07  Buat GET /api/foods + search
☐ TODO-BE-08  Buat GET /api/food-logs/summary?date=
☐ TODO-BE-09  Buat GET /api/food-logs?date=
☐ TODO-BE-10  Buat DELETE /api/food-logs/{id}

FRONTEND (bisa mulai setelah TODO-BE-01 s/d BE-03 selesai)
─────────────────────────────────────────────────────
☐ TODO-FE-01  Tambah supabase_flutter + google_sign_in ke pubspec.yaml
☐ TODO-FE-02  Inisialisasi Supabase di main.dart
☐ TODO-FE-03  Buat Splash Screen
☐ TODO-FE-04  Buat Onboarding Screen
☐ TODO-FE-05  Buat Register Screen
☐ TODO-FE-06  Implementasi email login nyata (ganti stub)
☐ TODO-FE-07  JWT Interceptor di Dio
☐ TODO-FE-08  Forgot/Reset Password screen
☐ TODO-FE-09  Google Login (opsional)
☐ TODO-FE-10  Apple Login (opsional)
☐ TODO-FE-11  Integrasi Profile API
☐ TODO-FE-12  Integrasi Add Meal API
☐ TODO-FE-13  Integrasi Dashboard API
☐ TODO-FE-14  Integrasi History API

QA & POLISH
─────────────────────────────────────────────────────
☐ TODO-QA-01  Rename pubspec.yaml dari 'boilerplate' ke 'nutrify'
☐ TODO-QA-02  PHPUnit Feature Tests
☐ TODO-QA-03  User Research (20+ responden)
```

---

*Untuk panduan Git lengkap, lihat [git-command.md](git-command.md).*
*Untuk detail arsitektur dan API reference, lihat [NUTRIFY_GUIDE.md](NUTRIFY_GUIDE.md).*
*Untuk backlog lengkap dengan status, lihat [BACKLOG.md](BACKLOG.md).*
