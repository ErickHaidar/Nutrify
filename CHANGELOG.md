# NUTRIFY — Changelog

> Format mengikuti [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) dan [Conventional Commits](https://www.conventionalcommits.org/).
> Setiap kali fitur selesai di-merge ke `develop`, tambahkan entri di sini.

---

## [0.7.0] — 6 Maret 2026

### Fixed — Backend
- **`config/cors.php`**: Perbaiki PCRE delimiter yang hilang pada semua `allowed_origins_patterns`. Sebelumnya pola regex tanpa delimiter (`/.../ ` atau `#...#`) menyebabkan OPTIONS preflight return HTTP 500. Sekarang semua pattern menggunakan `#^...$#` — preflight 204 berjalan normal (commit `f6c4de3`)
- **`VerifySupabaseToken` middleware**: Ganti verifikasi JWT dari HS256 hardcoded secret → ES256 via endpoint JWKS Supabase (`/auth/v1/.well-known/jwks.json`). Root cause: project Supabase menggunakan kunci EC P-256 (asymmetric), bukan HMAC-SHA256. Implementasi: `getKeySet()` fetch JWKS → `JWK::parseKeySet()` → `JWT::decode($token, $keySet)` (auto-match `kid`). JWKS di-cache 1 jam via `Cache::remember('supabase_jwks', 3600, ...)` (commit `d420622`)
- **`Food` model**: Tambah `$casts` untuk 7 kolom numerik (`calories`, `protein`, `carbohydrates`, `fat`, `sugar`, `sodium`, `fiber`) sebagai `float`. Sebelumnya nilai terserializasi sebagai string dari PostgreSQL, menyebabkan `TypeError` di Flutter `FoodItem.fromJson` saat cast `as num` — food search tampil kosong meski response 200 (commit `7aee353`)

### Performance — Frontend
- **`ProfileApiService`**: Implementasi static in-memory cache (60s TTL) dengan deduplication concurrent requests. `IndexedStack` me-mount semua 3 tab (Home/Profile/EditProfile) serentak → sebelumnya terjadi 3 HTTP `GET /api/profile` paralel. Sekarang hanya 1 request nyata yang dijalankan; 2 caller berikutnya mendapat `Future` yang sama. Cache di-invalidate otomatis setelah `saveProfile()` berhasil. Tambah parameter `forceRefresh` untuk invalidate manual (commit `503b03b`)
- **`HomeScreen`**: Tambah flag `bool _isLoadingData = false;` + guard di awal `loadDailyData()` (`if (_isLoadingData) return;`) untuk mencegah double-call bersamaan (commit `503b03b`)

---

## [0.5.0] — 6 Maret 2026

### Added — Frontend
- **`supabase_flutter: ^2.9.0`** ditambahkan ke `pubspec.yaml`
- **`Supabase.initialize()`** di `main.dart` sebelum ServiceLocator
- **`SplashScreen`** (`screens/splash_screen.dart`): Cek `currentSession` Supabase saat startup, simpan JWT ke SharedPrefs, route ke Home atau Login
- **`ResetPasswordScreen`** (`screens/reset_password_screen.dart`): Form password baru + konfirmasi, `supabase.auth.updateUser()`, redirect ke Login setelah berhasil
- **Endpoints** di `endpoints.dart`: `supabaseUrl`, `supabaseAnonKey`, dan semua path API relatif (`/profile`, `/profile/store`, `/foods`, `/food-logs`, `/food-logs/summary`)
- **Register modal** di `login.dart` (`_showSignUpModal()`): Bottom sheet StatefulBuilder dengan field nama/email/password, password visibility toggle, loading state, inline error, `supabase.auth.signUp()`
- **Forgot Password dialog** di `login.dart` (`_showForgotPasswordDialog()`): AlertDialog dengan email field, `resetPasswordForEmail()` dengan redirect `nutrify://reset-password-callback`
- **Intent filter** di `AndroidManifest.xml`: Skema `nutrify://` terdaftar agar OS bisa buka app dari link email reset password
- **`AuthChangeEvent.passwordRecovery` handler** di `MyApp`: Ketika user membuka link reset password → navigate langsung ke `ResetPasswordScreen`
- **Auth state listener** di `MyApp` (StatefulWidget): `signedOut` → clear session + navigate ke Login; `tokenRefreshed` → update SharedPrefs; `passwordRecovery` → navigate ke ResetPasswordScreen
- **`GlobalKey<NavigatorState>`** di `MyApp` untuk navigasi dari luar widget tree
- **Rute `/reset-password`** ditambahkan ke `Routes`

### Changed — Frontend
- **`UserRepositoryImpl`** (full rewrite): Login menggunakan `signInWithPassword()`, register `signUp()`, forgotPassword `resetPasswordForEmail()`, logout `signOut()` + clear SharedPrefs
- **`UserStore` / `login_store.dart`** (major update): Tambah actions `register()`, `forgotPassword()`, `logout()`, `clearSession()`; `isLoggedIn` dibuat `@observable`; error parsing Supabase ke pesan Indonesia
- **`store_module.dart`**: `UserRepository` diinjeksikan sebagai parameter ke `UserStore`
- **`UserRepository` interface**: Tambah abstract method `register()`, `forgotPassword()`, `logout()`
- **`MyApp`**: Diubah dari `StatelessWidget` → `StatefulWidget`
- **`login.dart`**: Password visibility toggle aktif; Observer menampilkan error dari `_userStore.errorStore` (bukan hanya `_formStore`); social buttons menampilkan snackbar "Segera hadir"
- **`login_store.g.dart`**: Diregenerasi oleh `build_runner` setelah perubahan store

### Fixed — Frontend
- **Error `_dependents.isEmpty is not true`**: Terjadi saat `FlushbarHelper.show()` dipanggil selama animasi dismiss modal/dialog. Fix: menggunakan `.then()` pada `showModalBottomSheet<bool>` dan `showDialog<String>` sehingga flushbar hanya tampil setelah animasi selesai
- **Conflict git di `analysis_options.yaml`**: Merge conflict `<<<<<<< HEAD` dihapus

---

## [0.4.0] — 6 Maret 2026

### Added — Backend
- **`FoodController@index`:** Endpoint `GET /api/foods?search=&page=` — daftar makanan paginated 20/halaman, pencarian ILIKE by name
- **`FoodSeeder`:** Import semua 1651 item dari `nilai-gizi.csv` ke tabel `foods` (batch insert 100/query)
- **`FoodLogController@index`:** Endpoint `GET /api/food-logs?date=YYYY-MM-DD` — riwayat makan per tanggal
- **`FoodLogController@summary`:** Endpoint `GET /api/food-logs/summary?date=YYYY-MM-DD` — agregasi kalori & makro per meal_time + total harian
- **`FoodLogController@destroy`:** Endpoint `DELETE /api/food-logs/{id}` — hapus log dengan validasi ownership
- **Middleware `supabase.auth`:** Alias terdaftar di `bootstrap/app.php`, semua route API protected
- **Registrasi FoodSeeder** di `DatabaseSeeder`

### Changed — Backend
- **`routes/api.php`:** Hapus `POST /api/register`, `POST /api/login-api`, `POST /api/logout` (Sanctum). Ganti `auth:sanctum` → `supabase.auth`. Hapus import `Hash` dan `User` yang tidak dipakai
- **`bootstrap/app.php`:** Hapus `EnsureFrontendRequestsAreStateful` (Sanctum), tambah alias `supabase.auth`

### Fixed — Backend
- **`FoodLogController`:** Hapus bug production `Auth::id() ?? 1` → `Auth::id()`

### Added — Frontend
- **`json_annotation: ^4.11.0`** ditambahkan ke `pubspec.yaml`
- **SDK constraint** diupdate ke `>=3.8.0 <4.0.0`
- **`dart run build_runner build`** selesai tanpa warning

---

## [Unreleased] — In Development

### Backend (NEXT — Sprint 1 QA)
- QA-02: Testing Sprint 1 menyeluruh (Auth, Profile, Manual Tracking, Dashboard)
- QA-03: PHPUnit Feature Test untuk semua API endpoint
- FE-16: Rename package dari `boilerplate` → `nutrify` di `pubspec.yaml`

---

## [0.6.0] — 6 Maret 2026

### Added — Frontend (Fase 3: API Integration)
- **`FoodApiService`** (`services/food_api_service.dart`): Wrapper `GET /api/foods?search=&page=` → `List<FoodItem>` (id, name, servingSize, calories, protein, carbohydrates, fat)
- **`FoodLogApiService`** (`services/food_log_api_service.dart`): `logFood()` → POST /api/food-logs; `getSummary(date)` → GET /api/food-logs/summary returns `DailySummary` dengan `MealNutrition` per meal + totals
- **`ProfileApiService`** (`services/profile_api_service.dart`): `getProfile()` → `ApiProfileData` (name, email, height, weight, age, gender, goal, activityLevel, bmi, bmiStatus, targetCalories); `saveProfile()` → POST /api/profile/store

### Changed — Frontend (Fase 3: API Integration)
- **`add_meal_screen.dart`** (full rewrite): Debounced food search (500ms) dari API, pilih item dari list, input jumlah porsi, preview kalori otomatis dihitung, kirim `POST /api/food-logs` — menggantikan form manual nama+kalori dengan `MealService` lokal
- **`home_screen.dart`**: Ganti `MealService`/`ProfileService` lokal → `FoodLogApiService.getSummary()` + `ProfileApiService.getProfile()`; kalori per meal-type diambil dari summary API; `_navigateToAddMeal` handle `result == true` (bukan `Map`)
- **`tracking_kalori_screen.dart`**: Tampilkan protein/karbohidrat/lemak nyata dari totals summary API; ganti nutrient cards dari 4 (termasuk gula hardcoded `0g`) → 3 (karbo/protein/lemak); layout `crossAxisCount: 3`
- **`profile_screen.dart`**: Ganti `ProfileService` → `ProfileApiService.getProfile()`; info grid diperluas menampilkan BMI score, BMI status, dan target kalori; hapus `FileImage` dari local storage
- **`edit_profile_screen.dart`** (rewrite): Ganti `ProfileService` lokal + `image_picker` → `ProfileApiService`; hapus field nama/email (read-only dari Supabase); gender menggunakan `DropdownButton` (male/female); tambah dropdown Goal (cutting/maintenance/bulking) dan Activity Level (sedentary→very_active); kalori preview dihitung live dari input; simpan via `POST /api/profile/store`

### Changed — Backend
- **`ProfileController::show()`**: Tambah field `profile` (raw data untuk editing), `bmi`, `bmi_status`, `target_calories`, `maintenance_calories` langsung di root response JSON (selain `physical_data` dan `nutrition_plan` yang tetap ada untuk backward compat)

### Meal Time Mapping (Frontend ↔ Backend)
| Tampilan UI | API value |
|---|---|
| Makan Pagi | `Breakfast` |
| Makan Siang | `Lunch` |
| Makan Malam | `Dinner` |
| Cemilan | `Snack` |

---

## [0.2.0] — 5 Maret 2026

### Changed — Infrastruktur & Struktur Repo
- **Restrukturisasi monorepo:** Folder `backend/` (Laravel) dan `frontend/` (Flutter) kini dipisahkan dalam subfolder di dalam satu repository
- **Frontend diclone:** Flutter project dari [prodhokter/nutrify](https://github.com/prodhokter/nutrify) ditempatkan di `frontend/nutrify/`
- Dibuat dokumen panduan `NUTRIFY_GUIDE.md`, `BACKLOG.md`, `CHANGELOG.md`, dan `planning.md`

---

## [0.1.2] — 4 Maret 2026

### Added — Backend
- **Migration `create_food_logs_table`:** Tabel `food_logs` dengan kolom `user_id` (FK), `food_id` (FK), `serving_multiplier` (float), `meal_time` (string: Breakfast/Lunch/Dinner/Snack)
- **Model `FoodLog`:** Relasi `belongsTo` ke `User` dan `Food`, mass-assignable fields
- **`FoodLogController@store`:** Endpoint `POST /api/food-logs` — validasi input, simpan log, return total kalori dikonsumsi
- **Migration `create_foods_table`:** Tabel `foods` dengan kolom `name`, `calories`, `protein`, `carbohydrates`, `fat`, `sugar`
- **Model `Food`:** Mass-assignable, koneksi ke tabel `foods`

### Notes
- ⚠️ Tabel `foods` **masih kosong** — tidak ada seeder atau import dataset `nilai-gizi.csv`
- ⚠️ `FoodLogController` memiliki fallback `Auth::id() ?? 1` untuk keperluan testing sementara

---

## [0.1.1] — 2 Maret 2026

### Added — Backend
- **`ProfileController@show`:** Kalkulasi BMI (weight/(height/100)²) dan TDEE via formula Mifflin-St Jeor
  - Faktor aktivitas: sedentary (1.2), light (1.375), moderate (1.55), active (1.725), very_active (1.9)
  - Penyesuaian goal: cutting (-500 kcal), bulking (+500 kcal)
  - BMI status: Underweight / Normal / Overweight / Obese
- **Endpoint `GET /api/profile`:** Return data profil + hasil kalkulasi lengkap
- **`ProfileController@store`:** `updateOrCreate` profil berdasarkan `user_id` yang login

---

## [0.1.0] — 2 Maret 2026

### Added — Backend
- **Inisialisasi Laravel 12** dengan PHP 8.2
- **Konfigurasi PostgreSQL** di `.env` (DB: `nutrify_db`, port: `5432`)
- **Laravel Sanctum** untuk token-based API authentication
- **Laravel Breeze** untuk auth controllers (RegisteredUserController, AuthenticatedSessionController, dll)
- **Migration `create_personal_access_tokens_table`:** Tabel untuk token Sanctum
- **Migration `create_profiles_table`:** Tabel `profiles` dengan kolom `user_id` (FK), `age`, `weight`, `height`, `gender` (enum), `goal` (enum), `activity_level` (enum)
- **Model `Profile`:** Fillable fields, relasi `belongsTo User`
- **Model `User`:** Tambah `HasApiTokens` trait, relasi `hasOne Profile`
- **Endpoint `POST /api/register`:** Validasi email unik, hash password, return Sanctum token
- **Endpoint `POST /api/login-api`:** Verifikasi kredensial, return Sanctum token
- **Endpoint `POST /api/logout`:** Hapus token aktif user saat ini
- **Middleware `auth:sanctum`** pada group route protected
- **CORS config** di `config/cors.php`: semua path (`*`), semua method (`*`)

### Added — Frontend
- **Inisialisasi Flutter project** dari boilerplate MobX + Provider
- **Screens:** HomeScreen, AddMealScreen, BodyDataScreen, BodyDataGoalsScreen, ProfileScreen, EditProfileScreen, ChangeGoalScreen, HistoryScreen, TrackingKaloriScreen, MainNavigationScreen
- **Services:** `MealService` (simpan/baca meal di SharedPreferences), `ProfileService` (simpan/baca profil di SharedPreferences)
- **State management:** MobX stores untuk login (`UserStore`), form validation (`FormStore`)
- **Domain layer:** `LoginUseCase`, `IsLoggedInUseCase`, `SaveLoginStatusUseCase`, `UserRepository` interface
- **Data layer:** `DioClient`, `RestClient`, `UserRepositoryImpl` (stub — belum hit API)
- **Shared Preferences Helper** untuk token dan login status
- **Reusable widgets:** `CustomInputField`, `ActivitySelectionTile`, `GoalSelector`, `ProfileMenuItem`
- **Theme & Colors:** `NutrifyTheme` dengan palette ungu/orange khas Nutrify
- **Bottom Navigation:** 3 tab (Home, History, Profile)
- **Kalkulasi kalori lokal** di `ProfileData.calculateTargetCalories()` (BMR/TDEE di device)

---

## Cara Update Changelog Ini

Saat PR kamu di-merge ke `develop`, tambahkan entry di bagian `[Unreleased]` dengan format:

```markdown
### Added
- feat(backend): deskripsi singkat perubahan

### Changed
- refactor(frontend): deskripsi perubahan yang sudah ada

### Fixed
- fix(backend): deskripsi bug yang diperbaiki

### Removed
- chore: deskripsi yang dihapus
```

Saat release ke `main`, ubah `[Unreleased]` menjadi `[x.y.z] — Tanggal`.
