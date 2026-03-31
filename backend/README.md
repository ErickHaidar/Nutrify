# Nutrify  Backend (Laravel 11)

REST API untuk aplikasi pencatat kalori Nutrify. Dibangun dengan Laravel 11, PostgreSQL via Supabase, dan autentikasi berbasis JWT Supabase.

---

## Tech Stack

| Teknologi | Keterangan |
|---|---|
| Laravel 11 | PHP framework (API-only, tanpa session/blade) |
| PostgreSQL | Database via Supabase |
| Supabase JWT | Autentikasi stateless  verify Bearer token dari frontend |
| `firebase/php-jwt` | Library decode JWT Supabase |
| Eloquent ORM | Query builder & model |

---

## Prasyarat

- PHP 8.2+
- Composer
- PostgreSQL (atau akun Supabase)
- Ekstensi PHP: `pdo_pgsql`, `openssl`, `mbstring`

---

## Setup & Instalasi

1. **Masuk ke direktori backend:**
   ```bash
   cd backend
   ```

2. **Install dependencies:**
   ```bash
   composer install
   ```

3. **Salin file environment:**
   ```bash
   cp .env.example .env
   php artisan key:generate
   ```

4. **Konfigurasi `.env`:**
   ```env
   DB_CONNECTION=pgsql
   DB_HOST=db.YOUR_PROJECT.supabase.co
   DB_PORT=5432
   DB_DATABASE=postgres
   DB_USERNAME=postgres
   DB_PASSWORD=YOUR_DB_PASSWORD

   SUPABASE_URL=https://YOUR_PROJECT.supabase.co
   SUPABASE_ANON_KEY=YOUR_ANON_KEY
   SUPABASE_JWT_SECRET=YOUR_JWT_SECRET
   ```

5. **Jalankan migrasi + seeder:**
   ```bash
   php artisan migrate --seed
   ```
   > Seeder akan mengimport **1651 item makanan** dari `database/seeders/FoodSeeder.php`

6. **Jalankan server lokal:**
   ```bash
   php artisan serve
   #  http://localhost:8000
   ```
   > Dari Android emulator gunakan `http://10.0.2.2:8000`

---

## Database

### Tabel Utama

| Tabel | Deskripsi |
|---|---|
| `users` | User dari Supabase  kolom `supabase_id` (UUID) |
| `profiles` | Data fisik user: tinggi, berat, usia, gender, goal, activity |
| `foods` | 1651 item makanan dari dataset nilai gizi BPOM |
| `food_logs` | Log makanan harian user (food_id, serving_multiplier, meal_time, logged_at) |

### Migrasi

```
migrations/
 0001_01_01_000000_create_users_table.php
 2026_03_02_124124_create_personal_access_tokens_table.php
 2026_03_02_125341_create_profiles_table.php
 2026_03_04_084150_create_foods_table.php
 2026_03_04_095600_create_food_logs_table.php
```

---

## API Endpoints

Semua endpoint menggunakan prefix `/api` dan memerlukan header:
```
Authorization: Bearer <supabase_jwt_token>
Content-Type: application/json
```

### Foods

| Method | Endpoint | Deskripsi |
|---|---|---|
| `GET` | `/api/foods` | Cari makanan  query params: `search` (string), `page` (int) |

**Response GET /api/foods:**
```json
{
  "success": true,
  "data": {
    "data": [
      {
        "id": 1,
        "name": "Ayam Goreng",
        "serving_size": 100,
        "calories": 250,
        "protein": 27.0,
        "carbohydrates": 0.0,
        "fat": 15.0,
        "sugar": 0.0,
        "sodium": 80.0,
        "fiber": 0.0
      }
    ],
    "meta": { "current_page": 1, "last_page": 83, "per_page": 20, "total": 1651 }
  }
}
```

### Food Logs

| Method | Endpoint | Deskripsi |
|---|---|---|
| `POST` | `/api/food-logs` | Catat log makanan baru |
| `GET` | `/api/food-logs` | Riwayat log per tanggal  query param: `date` (YYYY-MM-DD) |
| `GET` | `/api/food-logs/summary` | Ringkasan kalori + makro harian |
| `DELETE` | `/api/food-logs/{id}` | Hapus log (hanya milik user sendiri) |

**POST /api/food-logs body:**
```json
{
  "food_id": 42,
  "serving_multiplier": 1.5,
  "meal_time": "Breakfast"
}
```
> `meal_time` values: `Breakfast` | `Lunch` | `Dinner` | `Snack`

**GET /api/food-logs/summary response:**
```json
{
  "success": true,
  "date": "2026-03-06",
  "by_meal": {
    "Breakfast": { "total_calories": 350, "total_protein": 20, "total_carbohydrates": 40, "total_fat": 8 },
    "Lunch": { "total_calories": 600, "total_protein": 35, "total_carbohydrates": 80, "total_fat": 15 }
  },
  "totals": { "total_calories": 950, "total_protein": 55, "total_carbohydrates": 120, "total_fat": 23 }
}
```

### Profile

| Method | Endpoint | Deskripsi |
|---|---|---|
| `GET` | `/api/profile` | Ambil profil + BMI + target kalori |
| `POST` | `/api/profile/store` | Simpan/update profil |

**GET /api/profile response (ringkas):**
```json
{
  "status": "success",
  "user": { "id": 1, "email": "user@example.com" },
  "profile": { "age": 25, "weight": 70, "height": 175, "gender": "male", "goal": "cutting", "activity_level": "moderate" },
  "bmi": 22.9,
  "bmi_status": "Normal",
  "target_calories": 1850,
  "maintenance_calories": 2300
}
```

**POST /api/profile/store body:**
```json
{
  "age": 25,
  "weight": 70,
  "height": 175,
  "gender": "male",
  "goal": "cutting",
  "activity_level": "moderate"
}
```
> `gender`: `male` | `female`
> `goal`: `cutting` | `maintenance` | `bulking`
> `activity_level`: `sedentary` | `light` | `moderate` | `active` | `very_active`

---

## Autentikasi

Middleware `VerifySupabaseToken` (di `app/Http/Middleware/`) memverifikasi setiap request:

1. Ambil header `Authorization: Bearer <token>`
2. Decode JWT menggunakan `SUPABASE_JWT_SECRET`
3. Cari atau buat user di tabel `users` berdasarkan `sub` (UUID Supabase)
4. Set `Auth::setUser($user)` untuk semua controller

Tidak ada cookie, session, atau Sanctum  pure stateless JWT.

---

## Kalkulasi Nutrisi

Menggunakan formula **Mifflin-St Jeor** untuk BMR, dikali Activity Multiplier  TDEE:

| Activity Level | Multiplier |
|---|---|
| sedentary | 1.2 |
| light | 1.375 |
| moderate | 1.55 |
| active | 1.725 |
| very_active | 1.9 |

Target kalori dihitung berdasarkan goal:
- `cutting`: TDEE  500 kcal
- `maintenance`: TDEE
- `bulking`: TDEE + 500 kcal

---

## Testing

```bash
php artisan test
```

> PHPUnit Feature Tests (QA-03) dijadwalkan untuk Sprint 1 QA phase.

---

## Changelog Singkat

| Versi | Tanggal | Keterangan |
|---|---|---|
| v0.6.0 | 6 Mar 2026 | ProfileController: tambah profile raw + BMI + target_calories ke response |
| v0.4.0 | 6 Mar 2026 | Semua 7 endpoint + 1651 foods + Supabase JWT auth selesai |
| v0.2.0 | 6 Mar 2026 | Skema database, migrasi, Supabase middleware pertama |

Lihat `../CHANGELOG.md` untuk detail lengkap.
