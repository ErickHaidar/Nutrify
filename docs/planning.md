# NUTRIFY — Planning & Roadmap

> Dokumen ini berisi rencana pengerjaan Sprint 1 yang belum selesai, urutan prioritas, dan saran ke depan.
> Terakhir diperbarui: 6 Maret 2026 (sesi 4)

## Kondisi Saat Ini (Snapshot 6 Maret 2026 — Sesi 4)

### ✅ Yang Sudah Selesai (Sesi 4 — Bug Fix & Performance)
- Backend: **Fix CORS** — `config/cors.php` PCRE delimiter diperbaiki; preflight 204 ✅ (commit `f6c4de3`)
- Backend: **Fix JWT** — `VerifySupabaseToken` ganti HS256 → ES256 via JWKS Supabase; cache JWKS 1 jam ✅ (commit `d420622`)
- Backend: **Fix Food model** — `$casts` float untuk 7 kolom numerik; food search tidak lagi kosong ✅ (commit `7aee353`)
- Frontend: **`ProfileApiService` cache** — static in-memory cache 60s TTL + dedup concurrent requests; 3x parallel GET `/api/profile` → 1 request ✅ (commit `503b03b`)
- Frontend: **`HomeScreen` guard** — flag `_isLoadingData` mencegah double-call `loadDailyData()` ✅ (commit `503b03b`)

---

## Kondisi Saat Ini (Snapshot 6 Maret 2026 — Sesi 3)

### ✅ Yang Sudah Selesai
- Backend: Semua **skema database** (users + supabase_id, profiles, foods, food_logs) — 8 tabel
- Backend: `firebase/php-jwt` terinstall, `VerifySupabaseToken` middleware aktif
- Backend: Supabase credentials di `.env` (URL, ANON_KEY, JWT_SECRET) ✅
- Backend: Store & Get Profile + Kalkulasi BMI/TDEE
- Backend: **Semua endpoint lengkap** — POST/GET/DELETE food-logs, GET foods+search, GET summary harian
- Backend: **1651 item makanan** dari `nilai-gizi.csv` sudah ada di tabel `foods`
- Backend: Route Sanctum dihapus, semua route protected dengan `supabase.auth`
- Frontend: Semua **UI screens** sudah di-slice (10 screens)
- Frontend: Bottom navigation, reusable widgets, tema warna
- Frontend: **`supabase_flutter: ^2.9.0`** terinstall ✅
- Frontend: **Login** via Supabase `signInWithPassword()` aktif ✅
- Frontend: **Register** (modal bottom sheet) via `signUp()` aktif ✅
- Frontend: **Forgot Password** dialog + `resetPasswordForEmail()` aktif ✅
- Frontend: **Reset Password Screen** — user buka link email → `updateUser(password)` ✅
- Frontend: **Splash Screen** — cek session Supabase, auto-route ke home/login ✅
- Frontend: **JWT Auto-attach** via AuthInterceptor yang sudah ada → Dio otomatis kirim Bearer token ✅
- Frontend: **Auth state listener** di MyApp — handle signedOut, tokenRefreshed, passwordRecovery ✅
- Frontend: **Deep link `nutrify://`** terdaftar di AndroidManifest ✅
- Frontend: **Error flushbar timing** diperbaiki (`.then()` pattern) ✅
- Frontend: **`FoodApiService`** — cari makanan dari API (`GET /api/foods?search=`) ✅
- Frontend: **`FoodLogApiService`** — catat + ambil summary log harian (`POST/GET /api/food-logs`) ✅
- Frontend: **`ProfileApiService`** — load + simpan profil via API (`GET/POST /api/profile`) ✅
- Frontend: **AddMealScreen** (full rewrite) — debounced search, pilih makanan, input porsi, kirim log ✅
- Frontend: **HomeScreen** — kalori harian dari `GET /api/food-logs/summary` ✅
- Frontend: **TrackingKaloriScreen** — makro (karbo/protein/lemak) nyata dari summary API ✅
- Frontend: **ProfileScreen** — tampilkan profil dari API + BMI + target kalori ✅
- Frontend: **EditProfileScreen** (full rewrite) — dropdown gender/goal/activity, simpan via API ✅

### ⏳ Yang Belum Selesai (Sprint 1 — Post-Core)
- **QA-02**: Testing Sprint 1 menyeluruh (Auth, Profile, Food Log, Dashboard)
- **QA-03**: PHPUnit Feature Tests untuk semua API endpoint
- **FE-08**: Onboarding screen (opsional Sprint 1)
- **FE-16**: Rename package dari `boilerplate` → `nutrify` di `pubspec.yaml`

---

## Sprint 1 — Sisa Pekerjaan & Urutan Eksekusi

> Terakhir diperbarui: 6 Maret 2026

---

### ✅ FASE 1 — Backend Fundamental — SELESAI

Semua pekerjaan backend Sprint 1 sudah selesai per 6 Maret 2026:

| Item | Status | Keterangan |
|---|---|---|
| BE-15, BE-16: `firebase/php-jwt` + migration `supabase_id` | ✅ Done | 8 tabel berjalan |
| BE-13: FoodSeeder dari `nilai-gizi.csv` | ✅ Done | **1651 item** diimport |
| BE-08: `GET /api/foods?search=` | ✅ Done | Paginated 20/hal, ILIKE |
| BE-07: `GET /api/food-logs/summary?date=` | ✅ Done | Agregasi per meal_time |
| BE-09: `GET /api/food-logs?date=` | ✅ Done | — |
| BE-10: `DELETE /api/food-logs/{id}` | ✅ Done | Cek ownership |
| BE-12: Fix `Auth::id() ?? 1` | ✅ Done | Bug production dihapus |
| BE-11: Hapus route Sanctum | ✅ Done | `supabase.auth` aktif |

**Endpoint lengkap (7 route):**
```
POST   /api/food-logs             → Catat makan baru
GET    /api/food-logs?date=       → Riwayat per tanggal
GET    /api/food-logs/summary     → Ringkasan kalori harian
DELETE /api/food-logs/{id}        → Hapus log
GET    /api/foods?search=&page=   → Cari makanan
GET    /api/profile               → Profile + BMI/TDEE
POST   /api/profile/store         → Simpan profile
```

---

### 🔄 FASE 2 — Supabase Auth di Flutter — SELANJUTNYA (NEXT)

> ⚠️ **Backend sudah siap menerima JWT Supabase.** Flutter-lah yang belum kirim token.

#### 2.1 — Tambah `supabase_flutter` ke pubspec.yaml [FE-setup]

**MULAI DARI SINI.** Tambahkan ke `frontend/pubspec.yaml`:

```yaml
dependencies:
  supabase_flutter: ^2.9.0
```

Jalankan:

```bash
flutter pub get
```

Inisialisasi di `frontend/lib/main.dart`:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'SUPABASE_URL_KAMU',
    anonKey: 'SUPABASE_ANON_KEY_KAMU',
  );
  // ... ServiceLocator.configureDependencies();
  runApp(MyApp());
}
```

---

#### 2.2 — JWT Interceptor: Auto-attach Supabase Token ke Dio [FE-12]

**PALING PENTING** — tanpa ini semua `/api/*` endpoint akan return 401.

Buat `frontend/lib/data/network/interceptors/auth_interceptor.dart`:
```dart
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      options.headers['Authorization'] = 'Bearer ${session.accessToken}';
    }
    handler.next(options);
  }
}
```

Daftarkan ke `DioClient` di `service_locator.dart`.

---

#### 2.3 — Implementasi Email Login [FE-05]

Ganti stub di `frontend/lib/data/repository/user/user_repository_impl.dart`:

```dart
@override
Future<User?> login(LoginParams params) async {
  final response = await Supabase.instance.client.auth.signInWithPassword(
    email: params.username,
    password: params.password,
  );
  final jwt = response.session?.accessToken;
  if (jwt == null) throw Exception('Login gagal');
  await _sharedPrefsHelper.saveAuthToken(jwt);
  await _sharedPrefsHelper.saveIsLoggedIn(true);
  return User();
}
```

---

#### 2.4 — Buat Register Screen + `signUp()` [FE-06]

```dart
await Supabase.instance.client.auth.signUp(
  email: email,
  password: password,
  data: {'full_name': name},
);
// Supabase kirim email konfirmasi via custom SMTP
```

---

#### 2.5 — Forgot Password / Reset Password [FE-11]

```dart
// Forgot Password
await Supabase.instance.client.auth.resetPasswordForEmail(
  email,
  redirectTo: 'nutrify://reset-password-callback',
);

// Change Password (user sudah login)
await Supabase.instance.client.auth.updateUser(
  UserAttributes(password: newPassword),
);
```

---

#### 2.6 — Buat Splash Screen + Auth State Listener [FE-07]

```dart
void _checkAuth() async {
  await Future.delayed(const Duration(milliseconds: 1500));
  final session = Supabase.instance.client.auth.currentSession;
  if (session != null) {
    Navigator.pushReplacementNamed(context, '/home');
  } else {
    Navigator.pushReplacementNamed(context, '/onboarding');
  }
}
```

---

#### 2.7 — Onboarding Screen (Skip/Next) [FE-08]

---

### ✅ FASE 3 — Integrasi API ke Frontend Screens — SELESAI (6 Maret 2026)

| Item | Status | Keterangan |
|---|---|---|
| FE-13: GET Profile API | ✅ Done | `ProfileApiService.getProfile()` + `saveProfile()` |
| FE-14: POST Food Log | ✅ Done | `FoodLogApiService.logFood()` dari AddMealScreen |
| FE-15: GET Foods (search) | ✅ Done | Debounced search, `FoodApiService.searchFoods()` |
| FE-04: Dashboard Real-time | ✅ Done | `getSummary()` di HomeScreen + TrackingKaloriScreen |
| BE-17/18/19: Bug fixes (CORS, JWT ES256, Food cast) | ✅ Done | Sesi 4 — lihat CHANGELOG `[0.7.0]` |
| FE-19/20: Profile cache + HomeScreen guard | ✅ Done | Sesi 4 — lihat CHANGELOG `[0.7.0]` |

> Lihat CHANGELOG.md → `[0.6.0]` dan `[0.7.0]` untuk detail lengkap perubahan Fase 3 + Bug Fix.

---

### FASE 4 — QA & Testing

#### 4.1 — PHPUnit Feature Tests [QA-03]

```
tests/Feature/
├── Auth/
├── ProfileTest.php
├── FoodTest.php
└── FoodLogTest.php
```

#### 4.2 — User Research [QA-01]

20+ responden, fokus: pain point pencatatan kalori, fitur prioritas.

---

## Timeline Rekomendasi Sprint 1 (Sisa)

> Asumsi: 1 sprint = 2 minggu, tim ~4 orang (1 BE, 1 FE, 1 UX, 1 QA)

| Minggu | Backend | Frontend | UX | QA |
|---|---|---|---|---|
| **Minggu 1** | ✅ Selesai | FASE 2: `supabase_flutter` setup (2.1–2.3), JWT interceptor (2.2), Splash & Onboarding (2.6–2.7) | Finalisasi wireframe Login/Register/Onboarding | User Research |
| **Minggu 2** | Review & fix bug dari FE | FASE 2: Register+forgot password (2.4–2.5) + FASE 3 penuh (3.1–3.4) | Review & polish UI | Testing Sprint 1 (QA-02) |

---

## Saran ke Depan

### Teknis

1. **Gunakan Laravel API Resources** seperti `FoodResource`, `FoodLogResource`, `ProfileResource` untuk standarisasi format response JSON.

2. **Tambah Form Request Validation classes** (BE-14) untuk separasi logika validasi dari controller.

---

### ARSIP — FASE 1 Detail

> Semua item FASE 1 sudah dikerjakan dan di-push ke `sprint1-apps` pada 6 Maret 2026.
> Lihat CHANGELOG.md → `[0.4.0]` untuk detail perubahan.
