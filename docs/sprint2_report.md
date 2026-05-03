# Sprint 2 — Laporan Lengkap (Semua Role)

> Tanggal: 3 Mei 2026 (update terakhir)
> Sprint Goal: Memperbaiki inkonsistensi UI/UX & bug autentikasi, memperluas dataset makanan, menambah fitur Rekomendasi/Favorit, serta fitur Komunitas

---

## Ringkasan Status per Role

| Role | Total Task | Done | Partial | Not Done | Persentase |
|------|-----------|------|---------|----------|------------|
| **UI/UX** | 8 | 8 | 0 | 0 | **100%** |
| **Frontend** | 10 | 10 | 0 | 0 | **100%** |
| **Backend** | 7 | 5 | 1 | 1 | **71%** |
| **TOTAL** | 25 | 23 | 1 | 1 | **92%** |

---

## Detail Status per Task

### LEGEND
- ✅ **DONE** — Fully implemented & verified di codebase
- ⚠️ **PARTIAL** — Ada implementasi tapi belum lengkap
- ❌ **NOT DONE** — Belum ada implementasi
- 🔄 **IN PROGRESS** — Sedang dikerjakan (UI/UX desain di Figma)

---

## A. UI/UX (Eksekutor: Erik & Tara)

> **Status: 8/8 DONE (100%)**

| ID | Backlog Item | Eksekutor | Status | Evidence |
|----|-------------|-----------|--------|----------|
| 1 | Redesign tombol Google Sign-In | Erik | ✅ DONE | Desain di Figma sudah diimplementasi di frontend |
| 3 | Audit & standardisasi konsistensi bahasa (Bahasa Indonesia) | Tara | ✅ DONE | Semua teks UI sudah menggunakan sistem lokalitas terpusat `AppStrings` |
| 7 | Redesign Home: hapus profil & ganti dropdown ke Help Info | Erik | ✅ DONE | Profil sudah dihapus dari Home, tombol info ada |
| 11 | Desain UI/UX fitur Rekomendasi & Favorit | Tara | ✅ DONE | Desain section favorit & rekomendasi sudah di Figma |
| 15 | Change Goal dipindah ke Edit Profile | Erik | ✅ DONE | Goal selection sudah ada di halaman Edit Profile |
| 18 | Desain fitur komunitas | Erik | ✅ DONE | UI komunitas sudah diimplementasi di `komunitas_screen.dart` |
| 21 | Desain fitur notifikasi | Tara | ✅ DONE | Notifikasi sudah terintegrasi dengan FCM + local notifications |
| 24 | Ubah UI/UX color combination (base putih) | Erik | ✅ DONE | Skema warna baru cream/peach/navy diterapkan |

---

## B. Frontend (Eksekutor: Hamas, Rizqi, Farid)

> **Status: 10/10 DONE (100%)**

### ✅ DONE (10 task)

| ID | Backlog Item | Eksekutor | Lokasi | Detail Implementasi |
|----|-------------|-----------|--------|---------------------|
| 2 | Implementasi tombol Google Sign-In | Hamas | `presentation/login/login.dart:410-454` | Tombol putih, icon G, "Masuk dengan Google", panggil `_userStore.signInWithGoogle()` |
| 4 | Perbaikan teks & konsistensi bahasa | Rizqi | `utils/locale/app_strings.dart` | Sistem lokalitas terpusat, Bahasa Indonesia sebagai default, support English |
| 6 | Halaman OTP Verification | Farid | `screens/otp_verification_screen.dart` | 6 input box auto-focus, countdown timer 60s, tombol resend, verify via Supabase `verifyOTP()`. Termasuk update: `UserRepository`, `UserRepositoryImpl`, `UserStore`, `login.dart` (navigate to OTP after signUp), `routes.dart`, `my_app.dart` (auth state handler) |
| 8 | Help Info Page | Rizqi | `screens/help_screen.dart` | Halaman bantuan dengan About, cara tracking kalori, cara set goals, FAQ ExpansionTiles. Tombol help di home header. |
| 12 | Slicing Rekomendasi & Favorit di pencarian makanan | Hamas | `screens/add_meal_screen.dart`, `services/favorite_api_service.dart` | Filter chips (Semua/Favorit/Rekomendasi), ikon heart toggle favorit, integrasi API `GET/POST/DELETE /api/food/favorites` dan `GET /api/food/recommendations`, kategori makanan (Nasi/Roti/Daging/Buah/Sayuran/Minuman), tutorial overlay "Panduan Menambah Makanan" |
| 14 | Implementasi ganti foto profil | Rizqi | `screens/edit_profile_screen.dart:151-184` | Image picker galeri/kamera, preview sebelum upload, upload via API |
| 16 | Dropdown aktivitas konsisten & Edit Profile + goal | Farid | `screens/edit_profile_screen.dart`, `widgets/activity_tile.dart` | ActivitySelectionTile reusable, goal selection (Cutting/Maintenance/Bulking) di Edit Profile |
| 19 | Implementasi & integrasi API fitur komunitas | Rizqi | `screens/komunitas_screen.dart`, `screens/add_post_screen.dart`, `services/community_post_api_service.dart`, `domain/entity/post/community_post.dart` | UI lengkap: post feed, like, comment, follow tabs. **Sudah terhubung ke API** via `CommunityPostApiService`: GET/POST/DELETE `/api/posts`, POST like, GET/POST comments. Add post screen pakai real API upload. |
| 22 | Implementasi fitur notifikasi | Farid | `services/notification_service.dart` | FCM push notification + local meal reminders (sarapan 07:00, siang 12:00, malam 18:00), permission handling |
| 25 | Implementasi UI/UX dan warna baru + Redesign sesuai desain UI/UX | Farid | `constants/colors.dart`, `presentation/login/login.dart`, `screens/add_meal_screen.dart` | Skema baru: cream `#FAF1E8`, peach `#FFD1A6`, navy `#322E53`, amber `#F1C28E`. Redesign pixel-perfect: Login (Masuk, ATAU), Sign Up (Daftar), Forgot Password, Add Meal (kategori row, checkbox, search placeholder), Komunitas (Suka/Komentar format, Diikuti tab), Add Post, Tutorial overlay. |

---

### Frontend — Detail Implementasi

#### ID 6: OTP Verification Page
**File yang dibuat:**
| File | Deskripsi |
|------|-----------|
| `screens/otp_verification_screen.dart` | **BARU** — 6 digit OTP input, auto-focus, countdown 60s, resend, verify via Supabase |

**File yang diubah:**
| File | Perubahan |
|------|-----------|
| `domain/repository/user/user_repository.dart` | +2 method abstract: `verifyEmail()`, `resendOtp()` |
| `data/repository/user/user_repository_impl.dart` | +2 method: `verifyEmail()` via `Supabase.verifyOTP()`, `resendOtp()` via `Supabase.resend()` |
| `presentation/login/store/login_store.dart` | +2 MobX action: `verifyEmail()`, `resendOtp()` |
| `presentation/login/login.dart` | Navigate to OTP screen after signUp (instead of showing snackbar) |
| `utils/routes/routes.dart` | +1 route: `/otp` |
| `presentation/my_app.dart` | +1 auth state handler: `signedIn` event for email confirmation |
| `utils/locale/app_strings.dart` | +8 OTP localization strings |

#### ID 8: Help Info Page
**File yang dibuat:**
| File | Deskripsi |
|------|-----------|
| `screens/help_screen.dart` | **BARU** — Help page: About Nutrify, 3 steps tracking, goal cards (Cutting/Maintain/Bulking), 5 FAQ ExpansionTiles, version info |

**File yang diubah:**
| File | Perubahan |
|------|-----------|
| `screens/home_screen.dart` | +1 help button (Icons.help_outline) di header |
| `utils/locale/app_strings.dart` | +30+ localization strings untuk Help Screen |

#### ID 12: Favorit & Rekomendasi UI
**File yang dibuat:**
| File | Deskripsi |
|------|-----------|
| `services/favorite_api_service.dart` | **BARU** — Service: `getFavorites()`, `addFavorite()`, `removeFavorite()`, `getRecommendations()` |

**File yang diubah:**
| File | Perubahan |
|------|-----------|
| `screens/add_meal_screen.dart` | +filter chips (Semua/Favorit/Rekomendasi), +heart toggle favorit, +kategori row (6 kategori), +tutorial overlay dialog, +search "Cari Makanan atau Minuman" |
| `data/network/constants/endpoints.dart` | +3 endpoint: `foodFavorites`, `foodRecommendations`, `posts` |
| `utils/locale/app_strings.dart` | +strings untuk favorit, rekomendasi, tutorial |

#### ID 19: Komunitas API Integration
**File yang dibuat:**
| File | Deskripsi |
|------|-----------|
| `services/community_post_api_service.dart` | **BARU** — Service: `getPosts()`, `createPost()`, `deletePost()`, `toggleLike()`, `getComments()`, `addComment()` |

**File yang diubah:**
| File | Perubahan |
|------|-----------|
| `screens/komunitas_screen.dart` | **REWRITE** — Ganti mock data → API call via `CommunityPostApiService`. Optimistic like toggle, pull-to-refresh, loading state, Image.network/file |
| `domain/entity/post/community_post.dart` | **REWRITE** — +`fromJson` factory, +`authorId`, parse `likes_count`, `comments_count`, `is_liked`, `image_url`, `_formatTimeAgo()` |
| `screens/add_post_screen.dart` | Ganti simulated upload → real API call `createPost()` |

---

## C. Backend (Eksekutor: Ibnu, Adit)

> **Status: 5/7 DONE (71%)** — Update 3 Mei: BE-S2-07 selesai oleh Adit, follow system & community enhancement diimplementasikan Ibnu

### ✅ DONE — Ibnu (4 task)

#### Task 0 (ID 5): Backend Verifikasi Email OTP

**File yang dibuat:**

| File | Aksi | Deskripsi |
|------|------|-----------|
| `database/migrations/2026_05_02_000005_create_otps_table.php` | **BARU** | Tabel `otps`: `email`, `code` (hashed), `expires_at`, `verified_at` |
| `app/Models/Otp.php` | **BARU** | Model dengan helper `isExpired()`, `isVerified()` |
| `app/Http/Controllers/Api/OtpController.php` | **BARU** | Controller: `send()` dan `verify()` dengan rate limiting |
| `app/Mail/OtpMail.php` | **BARU** | Mailable class untuk OTP email |
| `resources/views/emails/otp.blade.php` | **BARU** | Email template Nutrify-themed |

**File yang diubah:**

| File | Perubahan |
|------|-----------|
| `routes/api.php` | +2 public route: `POST /api/auth/send-otp`, `POST /api/auth/verify-otp` |

**Endpoint API:**

| Method | Endpoint | Deskripsi | Detail |
|--------|----------|-----------|--------|
| `POST` | `/api/auth/send-otp` | Kirim OTP ke email | Rate limit 1/menit, OTP 6 digit, expiry 5 menit, hashed storage |
| `POST` | `/api/auth/verify-otp` | Verifikasi OTP | Rate limit 5/menit, return `{verified: true}` |

**Frontend OTP Enhancement:**

| File | Perubahan |
|------|-----------|
| `presentation/my_app.dart` | Fix OTP bypass: `signedIn` handler sekarang cek `emailConfirmedAt` — skip auto-navigate jika email belum diverifikasi |
| `screens/otp_verification_screen.dart` | Fix back button: tambah `PopScope` + dialog konfirmasi, sign out dari Supabase jika user keluar tanpa verifikasi |
| `screens/splash_screen.dart` | Fix session recovery: jika session ada tapi `emailConfirmedAt == null`, sign out & redirect ke login |
| `core/data/network/dio/interceptors/auth_interceptor.dart` | Enhancement: handle 401 response → auto sign out jika session expired |
| `data/repository/user/user_repository_impl.dart` | Cleanup: hapus debug print statements dari Google Sign-In flow |

**Catatan:** Frontend tetap menggunakan Supabase built-in OTP (`verifyOTP()`, `resend()`) karena sudah terintegrasi sempurna. Backend OTP endpoints tersedia sebagai alternatif/fallback.

---

#### Task 1 (ID 9): Deduplikasi & Perluasan Dataset Makanan

**File yang dibuat:**

| File | Aksi | Deskripsi |
|------|------|-----------|
| `app/Console/Commands/DeduplicateFoods.php` | **BARU** | Artisan command `food:deduplicate` — hapus duplikat makanan (case-insensitive) |
| `makanan-lokal.csv` | **BARU** | 201 data makanan lokal Indonesia (khas daerah, jajanan, minuman, snack, jus) |
| `database/seeders/LocalFoodSeeder.php` | **BARU** | Import CSV dengan unique check, skip jika sudah ada |

**Kategori makanan yang ditambahkan:**
- Makanan khas daerah (45+): Rendang, Gudeg, Soto Betawi, Rawon, Pempek, Bakso, Sate Madura, dll
- Jajanan pasar & kue (30+): Bakpia, Onde-onde, Lemper, Klepon, Serabi, Nastar, Kastengel, dll
- Minuman tradisional (20+): Es Teh Manis, Wedang Jahe, Bajigur, Es Cendol, Bandrek, dll
- Snack & street food (25+): Cireng, Cilok, Batagor, Kerak Telor, Martabak, Tempe Mendoan, dll
- Makanan berat (35+): Mie Ayam, Nasi Goreng variant, Ayam Geprek, Gulai, Kari, dll
- Jus & minuman segar (15+): Jus Alpukat, Jus Mangga, Es Kelapa Muda, dll
- Lauk pauk (20+): Ikan Bakar, Udang Goreng, Tempe/Tahu Goreng, dll
- Sup & sayur (10+): Sup Ayam, Capcay, Sayur Asem, dll

---

#### Task 2 (ID 10): API Rekomendasi & Favorit

**File yang dibuat/diubah:**

| File | Aksi | Deskripsi |
|------|------|-----------|
| `database/migrations/2026_05_02_000001_create_user_favorites_table.php` | **BARU** | Tabel `user_favorites` dengan unique `(user_id, food_id)` |
| `app/Models/UserFavorite.php` | **BARU** | Model dengan relasi ke User & Food |
| `app/Http/Controllers/Api/FavoriteController.php` | **BARU** | Controller: index, store, destroy |
| `app/Http/Controllers/Api/FoodController.php` | **DIUBAH** | Tambah method `recommendations()` |
| `app/Models/User.php` | **DIUBAH** | Tambah relasi `favorites()`, `foodLogs()`, `posts()`, `postLikes()`, `comments()` |
| `app/Models/Food.php` | **DIUBAH** | Tambah relasi `favorites()`, `foodLogs()` |
| `routes/api.php` | **DIUBAH** | Tambah 4 route favorit/rekomendasi + 6 route komunitas |

**Endpoint API:**

| Method | Endpoint | Deskripsi | Response Codes |
|--------|----------|-----------|----------------|
| `GET` | `/api/food/favorites` | List favorit user (paginated 20) | 200 |
| `POST` | `/api/food/favorites` | Tambah favorit (body: `{food_id}`) | 201 Created / 409 Duplikat |
| `DELETE` | `/api/food/favorites/{food_id}` | Hapus favorit | 200 OK / 404 Not found |
| `GET` | `/api/food/recommendations?limit=10` | Rekomendasi dari riwayat makan | 200 (empty array jika belum ada log) |

---

#### Task 3 (ID 20): Backend & API Fitur Komunitas

**File yang dibuat:**

| File | Aksi | Deskripsi |
|------|------|-----------|
| `database/migrations/2026_05_02_000002_create_posts_table.php` | **BARU** | Tabel `posts`: `user_id`, `content`, `image_url` |
| `database/migrations/2026_05_02_000003_create_post_likes_table.php` | **BARU** | Tabel `post_likes`: unique `(user_id, post_id)` |
| `database/migrations/2026_05_02_000004_create_comments_table.php` | **BARU** | Tabel `comments`: `user_id`, `post_id`, `content` |
| `app/Models/Post.php` | **BARU** | Relasi ke User, PostLike, Comment |
| `app/Models/PostLike.php` | **BARU** | Relasi ke User, Post |
| `app/Models/Comment.php` | **BARU** | Relasi ke User, Post |
| `app/Http/Controllers/Api/PostController.php` | **BARU** | Controller lengkap: CRUD + like + comment |

**Endpoint API:**

| Method | Endpoint | Deskripsi | Detail |
|--------|----------|-----------|--------|
| `GET` | `/api/posts` | Feed post | Paginated 15, append `is_liked`, `likes_count`, `comments_count` |
| `POST` | `/api/posts` | Buat post | Content max 1000 char, image opsional (JPG/PNG max 2MB) |
| `DELETE` | `/api/posts/{id}` | Hapus post | Hanya pemilik, auto-hapus gambar |
| `POST` | `/api/posts/{id}/like` | Toggle like/unlike | Return `{liked, likes_count}` |
| `GET` | `/api/posts/{id}/comments` | List komentar | Paginated 20, eager load user |
| `POST` | `/api/posts/{id}/comments` | Tambah komentar | Content max 500 char |

---

### ✅ DONE — Adit (1 task)

#### Task 4 (ID 13): API Upload Foto Profil (BE-S2-07)

**File yang dibuat:**

| File | Aksi | Deskripsi |
|------|------|-----------|
| `database/migrations/2026_05_03_000001_add_photo_to_profiles_table.php` | **BARU** | Tambah kolom `photo` (string, nullable) ke tabel `profiles` |

**File yang diubah:**

| File | Perubahan |
|------|-----------|
| `app/Models/Profile.php` | Tambah `'photo'` ke `$fillable` |
| `app/Http/Controllers/Api/ProfileController.php` | Tambah method `photo()` — validate image max 10MB, store ke `profile-photos/`, hapus foto lama, return `photo_url`. Update `show()` — include `photo_url` dari profile.photo |
| `routes/api.php` | +1 route: `PUT /api/profile/photo` |

**Frontend integration:**

| File | Perubahan |
|------|-----------|
| `lib/services/profile_api_service.dart` | `ApiProfileData` +field `photoUrl`. `_doFetch()` parse `data['photo_url']` |
| `lib/screens/profile_screen.dart` | `_buildProfileImageProvider()` — priority: API photoUrl > local file > null |
| `lib/screens/edit_profile_screen.dart` | Non-blocking photo upload — profile data saves first, photo failure shows SnackBar |

---

### ✅ DONE — Ibnu (Tambahan)

#### Task 5 (NEW): Follow System + Community Enhancement

> Diimplementasikan di atas Sprint 2 backlog — fitur tambahan untuk meningkatkan UX komunitas.

**File yang dibuat:**

| File | Aksi | Deskripsi |
|------|------|-----------|
| `database/migrations/2026_05_02_000006_add_community_fields_to_users_table.php` | **BARU** | Tambah kolom: `username` (unique nullable), `avatar` (nullable), `fcm_token` (nullable), `account_type` (enum public/private, default public) ke tabel users |
| `database/migrations/2026_05_02_000007_create_follows_table.php` | **BARU** | Tabel `follows` — follower_id, following_id, unique constraint |
| `app/Models/Follow.php` | **BARU** | Model Follow dengan relasi follower/following |

**File yang diubah:**

| File | Perubahan |
|------|-----------|
| `app/Models/User.php` | +fillable: username, avatar, fcm_token, account_type. +relations: followers, followings, getFollowersCount, getFollowingsCount, getAvatarUrlAttribute |
| `app/Http/Controllers/Api/FollowController.php` | **BARU** — toggleFollow (422 untuk self-follow), userProfile, searchUsers, updateUsername, updateAccountType |
| `app/Http/Controllers/Api/PostController.php` | Enhanced `formatPost()`: +supabase_id, username, avatar_url (from profile.photo), is_followed. Upload limit 2MB → 10MB, added webp |
| `routes/api.php` | +5 route: follow, user profile, search, username, account type |

**Endpoint API Baru:**

| Method | Endpoint | Deskripsi | Detail |
|--------|----------|-----------|--------|
| `POST` | `/api/users/{id}/follow` | Follow/unfollow user | Toggle, 422 untuk self-follow |
| `GET` | `/api/users/{id}/profile` | Profil user + posts + follow status | Include avatar, followers/followings count |
| `GET` | `/api/users/search?q=` | Cari user by nama/username | LIKE query, limit 20 |
| `PUT` | `/api/username` | Set/update username | Unique, min 3 max 30, alpha_num |
| `PUT` | `/api/account-type` | Set public/private | Enum: public, private |

**Frontend — New Screens:**

| File | Deskripsi |
|------|-----------|
| `lib/screens/post_detail_screen.dart` | **BARU** — Twitter/Threads style: full post detail, inline comments, like/comment action bar, delete own posts, fixed bottom comment input |
| `lib/screens/user_profile_screen.dart` | **BARU** — User profile: avatar, name, username (@handle), stats (posts/following/followers), follow button, user's posts |

**Frontend — Enhanced:**

| File | Perubahan |
|------|-----------|
| `lib/screens/komunitas_screen.dart` | +search users modal, +navigate to UserProfileScreen/ProfileScreen, +toggle follow via API |
| `lib/screens/add_post_screen.dart` | +camera option (gallery/camera bottom sheet), +character limit 1000 |
| `lib/domain/entity/post/community_post.dart` | +authorUsername, authorSupabaseId, isOwnPost (UUID comparison) |
| `lib/services/community_post_api_service.dart` | +toggleFollow(), +getUserProfile(), +searchUsers() |
| `lib/screens/edit_profile_screen.dart` | Birth date fix (SharedPreferences), save button fix (_isPhotoChanged) |

---

### ❌ NOT DONE / ⚠️ PARTIAL — Adit → Ibnu (2 task)

| ID | Backlog Item | Status | Detail yang Belum Ada |
|----|-------------|--------|----------------------|
| 13 | API upload foto profil (`PUT /profile/photo`) | ✅ DONE (Adit) | Sudah diimplementasikan Adit pada 3 Mei — migration, controller, storage, route |
| 17 | Validasi batas wajar input (tinggi, berat, umur) | ❌ NOT DONE | Validasi hanya `required|integer/numeric`, tanpa min/max bounds |
| 23 | Backend notifikasi (edge function/socket) | ⚠️ PARTIAL | FCM token field sudah ada di users table (via migration 000006). Tapi: belum ada tabel notifications, belum ada notification controller, belum ada FCM push trigger |

---

## D. QA

| ID | Backlog Item | Status | Catatan |
|----|-------------|--------|---------|
| 25 | Testing Sprint 2 | 🔄 ONGOING | Testing menyeluruh semua fitur Sprint 2 |

---

## Dependency Map — Apa yang Memblokir Apa

```
BACKEND — SISA (1 ❌ + 1 ⚠️):
├── ID 17 (Validasi input) ────► ❌ Tidak memblokir frontend langsung, tapi risiko data tidak valid
└── ID 23 (Notifikasi backend) ► ⚠️ PARTIAL — fcm_token field ada, tapi tidak ada notification table/triggers/push

BACKEND — ADIT (1/3) — SELESAI:
└── ID 13 (Upload foto profil) ─► ✅ DONE — migration + ProfileController@photo + route + frontend integration

BACKEND — IBNU (4/4 + extra) — SELESAI & TERINTEGRASI:
├── ID 5  (OTP API) ───────────► Frontend ID 6 ✅ DONE — backend OTP tersedia, frontend pakai Supabase built-in
├── ID 10 (Favorit/Rekomendasi) ► Frontend ID 12 ✅ DONE — backend + frontend integrasi selesai
├── ID 20 (Komunitas API) ──────► Frontend ID 19 ✅ DONE — mock data diganti API call
└── EXTRA: Follow System ───────► ✅ DONE — FollowController + search + username + account_type + frontend

FRONTEND (10/10) — SELESAI:
├── ID 2  (Google Sign-In) ──────► ✅ DONE
├── ID 4  (Konsistensi bahasa) ───► ✅ DONE
├── ID 6  (OTP Verification) ────► ✅ DONE — otp_verification_screen.dart + Supabase verifyOTP
├── ID 8  (Help Info Page) ──────► ✅ DONE — help_screen.dart + tutorial overlay
├── ID 12 (Favorit/Rekomendasi) ─► ✅ DONE — favorite_api_service.dart + add_meal_screen.dart
├── ID 14 (Ganti foto profil) ───► ✅ DONE
├── ID 16 (Dropdown aktivitas) ──► ✅ DONE
├── ID 19 (Komunitas API) ───────► ✅ DONE — community_post_api_service.dart + komunitas_screen.dart
├── ID 22 (Notifikasi) ──────────► ✅ DONE
└── ID 25 (UI/UX & warna baru) ──► ✅ DONE
```

---

## Statistik Implementasi

### File yang Dibuat (Sprint 2 Backend)

| Kategori | Jumlah |
|----------|--------|
| Migration baru | 9 |
| Model baru | 6 (UserFavorite, Post, PostLike, Comment, Otp, Follow) |
| Controller baru | 4 (FavoriteController, PostController, OtpController, FollowController) |
| Artisan Command | 1 (DeduplicateFoods) |
| Seeder baru | 1 (LocalFoodSeeder) |
| CSV data baru | 1 (makanan-lokal.csv — 201 item) |
| Mailable baru | 1 (OtpMail) |
| Email template baru | 1 (emails/otp.blade.php) |
| **Total file baru** | **24** |

### File yang Diubah

| File | Perubahan |
|------|-----------|
| `app/Models/User.php` | +fillables (username, avatar, fcm_token, account_type), +7 relasi, +follow helpers |
| `app/Models/Profile.php` | +'photo' ke fillable |
| `app/Models/Food.php` | +2 relasi (favorites, foodLogs) |
| `app/Http/Controllers/Api/ProfileController.php` | +method photo(), +photo_url di show() |
| `app/Http/Controllers/Api/PostController.php` | +enhanced formatPost (supabase_id, username, avatar_url, is_followed), upload limit 10MB |
| `app/Http/Controllers/Api/FoodController.php` | +1 method (recommendations) |
| `routes/api.php` | +18 route baru |

### Endpoint Baru

| Kategori | Jumlah Endpoint |
|----------|----------------|
| OTP | 2 (POST send, POST verify) |
| Favorit | 3 (GET, POST, DELETE) |
| Rekomendasi | 1 (GET) |
| Komunitas | 6 (CRUD posts + like + comments) |
| Follow System | 5 (follow, profile, search, username, account-type) |
| Profile Photo | 1 (PUT /profile/photo) |
| **Total** | **18** |

### Data Baru

| Sumber | Jumlah |
|--------|--------|
| Makanan lokal Indonesia | 201 item |
| Total foods setelah import | ~1.852 item |

---

## Langkah Selanjutnya (Prioritas)

### 1. Backend — Tersisa (2 task)
- [ ] Validasi input (ID 17) → quick win, 15 menit kerjaan
- [x] Upload foto profil API (ID 13) → ✅ DONE (3 Mei, Adit)
- [ ] Notification backend (ID 23) → ⚠️ PARTIAL (fcm_token field sudah ada, butuh notification table + triggers + FCM push)

### 2. Deploy Backend ke VPS
- [x] Jalankan migration baru (Sprint 2 awal)
- [x] Jalankan deduplikasi + seeder makanan lokal
- [x] Setup storage link untuk upload gambar komunitas
- [x] Update CORS untuk production domain
- [x] Deploy update komunitas + follow system + profile photo (3 Mei)

### 3. QA Testing
- [ ] Testing menyeluruh semua fitur Sprint 2 (ID 25)
- [ ] Verifikasi pixel-perfect sesuai desain UI/UX di semua screen

### 4. Frontend UI/UX Redesign — Sudah selesai
- [x] Login screen: "Masuk", "ATAU", placeholder Indonesia
- [x] Sign Up: "Daftar", label Indonesia, error styling
- [x] Add Meal: kategori row, checkbox, search placeholder "Cari Makanan atau Minuman"
- [x] Komunitas: format "Suka"/"Komentar", tab "Untuk Anda"/"Diikuti"
- [x] Tutorial overlay: dark purple, numbered steps, "Mengerti" button
- [x] OTP Verification: 6 digit input, countdown, resend
