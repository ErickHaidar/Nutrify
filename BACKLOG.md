# NUTRIFY — Backlog

> Semua item backlog dikelola di sini. Setiap item memiliki ID unik, role penanggung jawab, status, dan keterangan.
> Referensi Sprint 1 berasal dari `sprint_1.csv`.
> Terakhir diperbarui: 6 Maret 2026 (sesi 4)

---

## Legend Status

| Simbol | Arti |
|---|---|
| ✅ Done | Selesai dan sudah masuk ke `develop` |
| 🔄 In Progress | Sedang dikerjakan |
| ❌ Not Started | Belum dimulai |
| ⚠️ Partial | Ada implementasi awal tapi belum selesai / perlu perbaikan |
| 🔴 Blocked | Tergantung item lain yang belum selesai |

---

## SPRINT 1 — Backlog Items

> Sprint Goal: **Autentikasi user, Food Tracking, dan Dashboard kalori harian yang terhubung ke backend.**

### UI/UX

| Sprint ID | Internal ID | Backlog Item | Status | Catatan |
|---|---|---|---|---|
| S1-01 | UX-01 | Rancang User Flow, Wireframe & UI: Splashscreen, Onboarding, Login, Register | ❌ Not Started | User flow: App → Splash → Onboarding → Login/Register |
| S1-06 | UX-02 | Rancang UI/UX Setup Profile & Target (Cutting, Maintenance, Bulking) | ⚠️ Partial | Wireframe belum formal, tapi screen sudah di-slice |
| S1-09 | UX-03 | Rancang UI/UX Dashboard / Home (akumulasi kalori & makro vs target) | ✅ Done | Screen ada di `home_screen.dart` |
| S1-17 | UX-04 | UI/UX Riwayat Tracking Kalori (per tanggal harian) | ✅ Done | Screen ada di `history_screen.dart` |
| S1-18 | UX-05 | UI/UX Riwayat Makan berdasarkan waktu (Pagi/Siang/Malam/Cemilan) | ⚠️ Partial | History screen ada tapi data masih static/hardcoded |

---

### Backend

| Sprint ID | Internal ID | Backlog Item | Status | Endpoint / Lokasi | Catatan |
|---|---|---|---|---|---|
| S1-04 | BE-01 | Schema tabel riwayat makan per waktu (Breakfast/Lunch/Dinner/Snack) | ✅ Done | `migrations/create_food_logs_table.php` | FK ke users & foods |
| S1-05 | BE-02 | Setup Authentication: Login via Supabase (email, Google, Apple) + forgot/reset/change password | ✅ Done | `app/Http/Middleware/VerifySupabaseToken.php` | Middleware aktif, alias `supabase.auth` terdaftar, semua route protected. **Flutter belum diintegrasikan (TODO FE-05).** |
| S1-07 | BE-03 | Schema Database: User, Profile, Food Dataset, Tracking | ✅ Done | `migrations/` | Semua tabel ada + `supabase_id` di tabel users. 8 tabel total. |
| S1-08 | BE-04 | Setup & Integrasi Dataset Kalori Makanan (Kalori, Protein, Karbo, Gula, Sodium, Fiber) | ✅ Done | `database/seeders/FoodSeeder.php` | **1651 item** dari `nilai-gizi.csv` berhasil diimport ke tabel `foods` |
| S1-12 | BE-05 | CRUD Pencatatan Kalori Harian Manual | ✅ Done | `POST/GET/DELETE /api/food-logs` | Create ✅, Read by date ✅, Delete ✅. Update (PUT) ditunda ke post-sprint. |
| S1-13 | BE-06 | Business Logic Kalkulasi BMI dan TDEE | ✅ Done | `GET /api/profile` | Formula Mifflin-St Jeor di `ProfileController` |
| S1-14 | BE-07 | API Kalkulasi Akumulasi Kalori & Makronutrisi Harian | ✅ Done | `GET /api/food-logs/summary` | Agregasi per meal_time + total harian |
| — | BE-08 | Endpoint GET Daftar Makanan + Search by Name | ✅ Done | `GET /api/foods?search=` | Paginated 20/halaman, ILIKE search |
| — | BE-09 | Endpoint GET Riwayat Makan by Date | ✅ Done | `GET /api/food-logs?date=YYYY-MM-DD` | — |
| — | BE-10 | Endpoint DELETE Food Log | ✅ Done | `DELETE /api/food-logs/{id}` | Cek ownership sebelum delete |
| — | BE-11 | Hapus route Laravel Register & Login (diganti Supabase) | ✅ Done | `routes/api.php` | `POST /api/register` dan `POST /api/login-api` dihapus |
| — | BE-12 | Fix: Hapus fallback `Auth::id() ?? 1` di `FoodLogController` | ✅ Done | `FoodLogController.php` | Bug production dihapus |
| — | BE-13 | FoodSeeder: Import `nilai-gizi.csv` ke tabel `foods` | ✅ Done | `database/seeders/FoodSeeder.php` | 1651 item diimport |
| — | BE-14 | Form Request Validation Classes | ❌ Not Started | `app/Http/Requests/` | Low priority, validasi sudah inline |
| — | BE-15 | Install `firebase/php-jwt` via Composer | ✅ Done | `composer.json` | `firebase/php-jwt ^6.x` terinstall |
| — | BE-16 | Update tabel `users`: jalankan migration `supabase_id` | ✅ Done | `migrations/2026_03_06_000001_add_supabase_id_to_users_table.php` | `php artisan migrate` sudah dijalankan |
| — | BE-17 | Fix: CORS `allowed_origins_patterns` — tambah PHP PCRE delimiter | ✅ Done | `config/cors.php` | Regex tanpa delimiter `#...#` menyebabkan OPTIONS preflight HTTP 500. Semua pattern diperbaiki → preflight 204 (commit `f6c4de3`) |
| — | BE-18 | Fix: `VerifySupabaseToken` — ganti HS256 hardcoded → ES256 via JWKS | ✅ Done | `app/Http/Middleware/VerifySupabaseToken.php` | Supabase project pakai EC P-256 (asymmetric). Fetch JWKS → `JWK::parseKeySet()` → `JWT::decode()`. JWKS cached 1 jam (commit `d420622`) |
| — | BE-19 | Fix: `Food` model — tambah `$casts` float untuk 7 kolom numerik | ✅ Done | `app/Models/Food.php` | Tanpa cast, kolom nutrisi terserializasi sebagai string → `TypeError` di Flutter `FoodItem.fromJson`. Food search kosong meski 200 (commit `7aee353`) |

---

### Frontend

| Sprint ID | Internal ID | Backlog Item | Status | Lokasi | Catatan |
|---|---|---|---|---|---|
| S1-03 | FE-01 | Slicing Splashscreen, Onboarding, Login, Register | ⚠️ Partial | `presentation/login/login.dart`, `screens/splash_screen.dart` | Splash ✅ Done, Login ✅ Done, Register (modal) ✅ Done, **Onboarding BELUM ADA** |
| S1-10 | FE-02 | Slicing Dashboard / Home | ✅ Done | `screens/home_screen.dart` | Data masih dari local storage |
| S1-15 | FE-03 | Bottom Navigation Bar & Komponen Reusable | ✅ Done | `screens/main_navigation_screen.dart`, `widgets/` | 3 tab: Home, History, Profile |
| S1-16 | FE-04 | Integrasi API ke Dashboard Home (kalori & makro real-time) | ✅ Done | `screens/home_screen.dart`, `screens/tracking_kalori_screen.dart` | HomeScreen load dari `GET /api/food-logs/summary`; TrackingKaloriScreen tampilkan kalori & makro (karbo/protein/lemak) nyata dari API |
| — | FE-05 | Integrasi Supabase Auth: Email Login via `supabase_flutter` | ✅ Done | `data/repository/user/user_repository_impl.dart` | `signInWithPassword()` aktif, JWT disimpan ke SharedPrefs |
| — | FE-06 | Buat Register Screen + Supabase `signUp()` | ✅ Done | `presentation/login/login.dart` → `_showSignUpModal()` | Modal bottom sheet nama/email/password, `signUp()` aktif |
| — | FE-07 | Buat Splash Screen | ✅ Done | `screens/splash_screen.dart` | Cek session Supabase → route ke home/login |
| — | FE-08 | Buat Onboarding Screen (Skip/Next) | ❌ Not Started | — | Post-sprint atau Sprint 2 |
| — | FE-09 | Google OAuth via Supabase + `google_sign_in` package | ❌ Not Started | — | Tombol ada tapi disabled ("Segera hadir"). Perlu SHA-1 fingerprint |
| — | FE-10 | Apple Sign In via Supabase + `sign_in_with_apple` package | ❌ Not Started | — | Tombol ada tapi disabled ("Segera hadir"). Perlu Apple Dev Account |
| — | FE-11 | Forgot Password / Reset Password via Supabase | ✅ Done | `presentation/login/login.dart`, `screens/reset_password_screen.dart` | Dialog email + `resetPasswordForEmail()`. Deep link `nutrify://` terdaftar. `ResetPasswordScreen` aktif via `passwordRecovery` event |
| — | FE-12 | JWT Interceptor: Auto-attach Supabase token ke semua request Dio | ✅ Done | `core/data/network/dio/interceptors/auth_interceptor.dart` | AuthInterceptor sudah ada & aktif — JWT disimpan saat login, dibaca otomatis setiap request |
| — | FE-13 | Integrasi Profile API: Ganti `ProfileService` lokal → `GET /api/profile` | ✅ Done | `services/profile_api_service.dart`, `screens/profile_screen.dart`, `screens/edit_profile_screen.dart` | `ProfileApiService` load & save via API; profile_screen tampil BMI + target_calories; edit_profile_screen dengan dropdown gender/goal/activity |
| — | FE-14 | Integrasi Food Log API: Kirim log ke `POST /api/food-logs` | ✅ Done | `services/food_log_api_service.dart`, `screens/add_meal_screen.dart` | `FoodLogApiService.logFood()` dipanggil dari AddMealScreen setelah user pilih makanan & isi porsi |
| — | FE-15 | Tampilkan daftar makanan dari `GET /api/foods?search=` di AddMealScreen | ✅ Done | `services/food_api_service.dart`, `screens/add_meal_screen.dart` | Debounced TextField 500ms, live search, pilih food → input jumlah porsi → kalori dihitung otomatis |
| — | FE-16 | Unifikasi: Rename `pubspec.yaml` dari `boilerplate` ke `nutrify` | ❌ Not Started | `pubspec.yaml` | Low priority |
| — | FE-17 | Fix: Error `_dependents.isEmpty` saat dismiss modal/dialog | ✅ Done | `presentation/login/login.dart` | Ganti `addPostFrameCallback` → `.then()` pada Future modal |
| — | FE-18 | Fix: Intent filter `nutrify://` di AndroidManifest | ✅ Done | `android/app/src/main/AndroidManifest.xml` | Deep link scheme terdaftar |
| — | FE-19 | Optimasi: `ProfileApiService` — static cache (60s TTL) + dedup concurrent requests | ✅ Done | `services/profile_api_service.dart` | `IndexedStack` mount 3 tab serentak → 3x GET `/api/profile`. Sekarang hanya 1 HTTP request; concurrent callers reuse Future yang sama. Cache invalidate otomatis setelah `saveProfile()` (commit `503b03b`) |
| — | FE-20 | Fix: `HomeScreen` — tambah guard `_isLoadingData` di `loadDailyData()` | ✅ Done | `screens/home_screen.dart` | Mencegah double-call `loadDailyData()` bersamaan (commit `503b03b`) |

---

### QA

| Sprint ID | Internal ID | Backlog Item | Status | Catatan |
|---|---|---|---|---|
| S1-02 | QA-01 | User Research / Interview (20+ responden) | ❌ Not Started | Pain points pencatatan kalori & target goals |
| S1-11 | QA-02 | Testing Sprint 1 (Auth, Profile, Manual Tracking, Dashboard) | ❌ Not Started | Test case untuk semua fitur Sprint 1 |
| — | QA-03 | PHPUnit Feature Test untuk semua API endpoint | ❌ Not Started | Endpoint register, login, profile, food-logs |

---

## BACKLOG POST-SPRINT 1 (Future Sprint)

| ID | Role | Backlog Item | Prioritas |
|---|---|---|---|
| FS-01 | Backend | Update Food Log (PUT endpoint) | Medium |
| FS-02 | Backend | Statistik mingguan / bulanan kalori | Low |
| FS-03 | Frontend | Push Notification pengingat makan | Low |
| FS-04 | Frontend | Upload foto makanan | Low |
| FS-05 | Frontend | Statistik chart mingguan/bulanan | Medium |
| FS-06 | Backend | Rate limiting pada endpoint auth | Medium |
| FS-07 | Backend | Email verification | Low |
| FS-08 | Frontend | Dark/Light mode toggle | Low |
| FS-09 | UI/UX | Onboarding dengan brand mascot / ilustrasi | Low |
| FS-10 | Backend | Export data kalori ke PDF/CSV | Low |

---

## Dependensi Antar Item

```
[SEMUA BE SELESAI] ✅

FE-05 (Supabase email login)
  └─► FE-12 (JWT Interceptor Dio)
        ├─► FE-04 (Dashboard real-time dari API)
        ├─► FE-13 (Integrasi Profile API)
        ├─► FE-14 (Kirim food log ke API)
        └─► FE-15 (Tampil daftar makanan dari API)
FE-05 → FE-06 (Register) → FE-07 (Splash) → FE-08 (Onboarding)
FE-09 (Google OAuth) → FE-10 (Apple Sign In)  ← post-sprint
  └─► FE-12 (JWT Interceptor untuk Dio)
        └─► FE-13 (Integrasi Profile API)
        └─► FE-14 (Integrasi Food Log API)
        └─► FE-04 (Dashboard real-time)

BE-07 (API Summary Harian)
  └─► FE-04 (Dashboard real-time)
```
