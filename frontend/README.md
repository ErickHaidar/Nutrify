# Nutrify  Frontend (Flutter)

Aplikasi mobile pencatat kalori harian berbasis Flutter. Terhubung ke backend Laravel via REST API dengan autentikasi Supabase JWT.

---

## Tech Stack

| Teknologi | Versi | Fungsi |
|---|---|---|
| Flutter |  3.x | Cross-platform UI framework |
| Dart |  3.x | Bahasa pemrograman |
| supabase_flutter | ^2.9.0 | Auth (sign-in, sign-up, JWT token) |
| dio |  | HTTP client + interceptor |
| get_it |  | Service locator / dependency injection |
| mobx + flutter_mobx |  | State management |
| google_fonts |  | Custom typography |
| another_flushbar |  | Notifikasi in-app |

---

## Prasyarat

- Flutter SDK  3.0 ([instalasi](https://docs.flutter.dev/get-started/install))
- Android Studio / VS Code dengan Flutter extension
- Backend Nutrify berjalan (lihat `../backend/README.md`)
- Akun & project Supabase (untuk URL + Anon Key)

---

## Setup & Instalasi

1. **Masuk ke direktori frontend:**
   ```bash
   cd frontend
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Konfigurasi koneksi:**

   Edit `lib/constants/endpoints.dart`:
   ```dart
   class Endpoints {
     static const String baseUrl = 'http://10.0.2.2:8000/api'; // Android emulator
     // static const String baseUrl = 'http://localhost:8000/api'; // iOS simulator
   }
   ```

   Edit `lib/main.dart`  isi Supabase credentials:
   ```dart
   await Supabase.initialize(
     url: 'https://YOUR_PROJECT.supabase.co',
     anonKey: 'YOUR_ANON_KEY',
   );
   ```

4. **Jalankan aplikasi:**
   ```bash
   flutter run
   ```

---

## Arsitektur

Menggunakan **Layered Architecture** (Clean-ish):

```
lib/
 constants/          # Konfigurasi global (warna, ukuran, endpoint API)
 data/
    network/        # DioClient + AuthInterceptor (JWT auto-attach)
    repository/     # UserRepository (Supabase auth)
 screens/            # Semua halaman aplikasi
 services/           # Service layer untuk API calls
    food_api_service.dart       # GET /api/foods
    food_log_api_service.dart   # POST/GET/DELETE /api/food-logs
    profile_api_service.dart    # GET/POST /api/profile
 widgets/            # Reusable UI components
 routes.dart         # Named route definitions
 main.dart           # Entry point + Supabase init + GetIt setup
```

---

## Screens

| Screen | Route | Deskripsi |
|---|---|---|
| `SplashScreen` | `/splash` | Cek Supabase session  auto-route ke home/login |
| `LoginScreen` | `/login` | Email + password login via Supabase |
| `RegisterScreen` | (modal) | Modal bottom sheet register baru |
| `ResetPasswordScreen` | `/reset-password` | Update password setelah klik link email |
| `HomeScreen` | `/home` | Kalori harian + ringkasan per meal, dari API summary |
| `AddMealScreen` | `/add-meal` | Cari makanan dari API, input porsi, catat log |
| `TrackingKaloriScreen` | `/tracking` | Makro (karbo/protein/lemak) real dari API |
| `ProfileScreen` | `/profile` | Data profil + BMI + target kalori dari API |
| `EditProfileScreen` | `/edit-profile` | Edit tinggi/berat/usia/gender/goal/aktivitas |

---

## Autentikasi

- **Login / Register / Forgot Password / Reset Password**  semua via `supabase_flutter`
- **JWT Auto-attach**  `AuthInterceptor` di `DioClient` secara otomatis menambahkan header:
  ```
  Authorization: Bearer <supabase_access_token>
  ```
- **Auth State Listener**  `MyApp` mendengarkan `onAuthStateChange` untuk handle:
  - `signedOut`  redirect ke login
  - `passwordRecovery`  redirect ke reset-password screen
  - `tokenRefreshed`  token Dio diperbarui otomatis
- **Deep Link**  scheme `nutrify://` terdaftar di `AndroidManifest.xml` untuk handle email link reset password

---

## API Integration (Fase 3)

### Food Search
```dart
final foods = await FoodApiService().searchFoods('ayam goreng');
//  GET /api/foods?search=ayam+goreng
```

### Catat Makan
```dart
await FoodLogApiService().logFood(
  foodId: 42,
  servingMultiplier: 1.5,
  mealTime: 'Lunch',
);
//  POST /api/food-logs
```

### Summary Harian
```dart
final summary = await FoodLogApiService().getSummary();
//  GET /api/food-logs/summary
// summary.totals.calories, .protein, .carbohydrates, .fat
```

### Profile
```dart
final profile = await ProfileApiService().getProfile();
//  GET /api/profile
// profile.bmi, .bmiStatus, .targetCalories
```

---

## Meal Time Mapping

| Tampilan UI | Nilai API |
|---|---|
| Makan Pagi | `Breakfast` |
| Makan Siang | `Lunch` |
| Makan Malam | `Dinner` |
| Cemilan | `Snack` |

---

## Catatan Pengembangan

- **Build flavor belum dikonfigurasi**  dev/staging/prod menggunakan `Endpoints.dart` manual
- **Package name** masih `com.example.boilerplate`  rename ke `com.example.nutrify` di Sprint 2
- **Test**: Belum ada widget/integration test  dijadwalkan QA-02 Sprint 1

---

## Changelog Singkat

| Versi | Tanggal | Keterangan |
|---|---|---|
| Fase 3 (v0.6.0) | 6 Mar 2026 | API integration: food search, food log, profile via API |
| Fase 2 (v0.5.0) | 6 Mar 2026 | Supabase auth: login, register, forgot/reset password, splash |
| Fase 1 (v0.2.0) | 6 Mar 2026 | UI screens, routing, reusable widgets, tema warna |

Lihat `../CHANGELOG.md` untuk detail lengkap.
