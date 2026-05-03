# NUTRIFY — Backend Progress Sprint 2

> **Dibuat oleh:** Ibnu Habib (Backend Developer)
> **Tanggal:** 3 Mei 2026 (update terakhir)
> **Untuk:** Backend Developer
> **Sprint:** Sprint 2

---

## DAFTAR ISI

1. [Ringkasan Status Backend Sprint 2](#1-ringkasan-status-backend-sprint-2)
2. [Tabel Task — Sudah vs Belum Dikerjakan](#2-tabel-task--sudah-vs-belum-dikerjakan)
3. [Detail Komponen & Status per Task](#3-detail-komponen--status-per-task)
4. [AI Agent Prompt](#4-ai-agent-prompt)

---

## 1. Ringkasan Status Backend Sprint 2

### Total Task Backend Sprint 2

| Status | Jumlah | Task ID |
|--------|--------|---------|
| ✅ Done | 7 task | BE-S2-01 s/d BE-S2-07 |
| ⚠️ Partial | 1 task | BE-S2-09 (fcm_token field done, notification triggers not done) |
| ❌ Not Started | 1 task | BE-S2-08 |


---

## 2. Tabel Task — Sudah vs Belum Dikerjakan

### ✅ SUDAH DIKERJAKAN

| ID | Task | File | Status |
|----|------|------|--------|
| BE-S2-01 | Setup project Laravel + Supabase Auth | Middleware, config, routes | ✅ Done |
| BE-S2-02 | API Profile (store + show + BMI/TDEE) | `ProfileController.php`, `Profile.php` | ✅ Done |
| BE-S2-03 | API Food & Food Log CRUD | `FoodController.php`, `FoodLogController.php` | ✅ Done |
| BE-S2-04 | API Community Posts + Likes + Comments | `PostController.php`, `Post.php`, `Comment.php` | ✅ Done |
| BE-S2-05 | API Food Favorites | `FavoriteController.php`, `UserFavorite.php` | ✅ Done |
| BE-S2-06 | Backend OTP (send + verify) | `OtpController.php`, `Otp.php`, `OtpMail.php` | ✅ Done |
| BE-S2-07 | API Upload Foto Profil | `ProfileController@photo`, migration, route | ✅ Done (3 Mei — Adit) |

### ❌ BELUM DIKERJAKAN / ⚠️ PARTIAL

| ID | Task | Deskripsi | Frontend Siap? | Status |
|----|------|-----------|----------------|--------|
| BE-S2-08 | Validasi Batas Wajar Input | Min/max untuk age, weight, height di `ProfileController@store` | ✅ Frontend sudah kirim data | ❌ Not Started |
| BE-S2-09 | Backend Notifikasi | FCM token storage + push notification saat like/comment/follow | ⚠️ Frontend kirim token | ⚠️ Partial — fcm_token field sudah ada di users via migration 000006 |

### ✅ TAMBAHAN (beyond original backlog)

| Task | File | Status |
|------|------|--------|
| Follow System (migration + model + controller + routes) | `FollowController.php`, `Follow.php`, 2 migrations, 5 routes | ✅ Done (3 Mei) |
| User Fields (username, avatar, fcm_token, account_type) | `2026_05_02_000006` migration, User model update | ✅ Done (3 Mei) |
| PostController Enhanced (supabase_id, username, avatar_url, is_followed, 10MB) | `PostController.php` | ✅ Done (3 Mei) |

---

## 3. Detail Komponen & Status per Task

### BE-S2-07: API Upload Foto Profil — ✅ DONE (3 Mei)

**Endpoint:** `PUT /api/profile/photo`

**Diimplementasikan oleh Adit**

**Komponen yang sudah dibuat:**

| Komponen | Status | Detail |
|----------|--------|--------|
| Route `PUT /profile/photo` | ✅ Done | Ditambah di `routes/api.php` dalam middleware group |
| Controller method `ProfileController@photo` | ✅ Done | Terima `photo` file, validate image max 10MB, store ke `profile-photos/`, hapus foto lama |
| File storage | ✅ Done | Simpan ke `storage/app/public/profile-photos/` |
| Return JSON `{ photo_url }` | ✅ Done | Return full URL `https://nutrify-app.my.id/storage/profile-photos/{filename}` |
| Migration `photo` column di profiles | ✅ Done | `2026_05_03_000001_add_photo_to_profiles_table.php` |
| Profile model `$fillable` | ✅ Done | Tambah `'photo'` |
| `ProfileController@show` response | ✅ Done | Include `photo_url` di response JSON (full URL jika photo ada, null jika tidak) |
| Frontend integration | ✅ Done | `uploadProfilePhoto()` non-blocking, profile photo shown in ProfileScreen & Komunitas |

**Frontend mengirim:**
```dart
Future<void> uploadProfilePhoto(File image) async {
  final fileName = image.path.split('/').last;
  final formData = FormData.fromMap({
    'photo': await MultipartFile.fromFile(image.path, filename: fileName),
  });
  await _dio.dio.put(Endpoints.profilePhoto, data: formData);
}
```

---

### BE-S2-08: Validasi Batas Wajar Input

**Endpoint yang perlu di-update:** `POST /api/profile/store`

**Validasi saat ini (TIDAK ada batas wajar):**
```php
// app/Http/Controllers/Api/ProfileController.php:16-23
$request->validate([
    'age' => 'required|integer',           // ❌ Tidak ada min/max
    'weight' => 'required|numeric',         // ❌ Tidak ada min/max
    'height' => 'required|numeric',         // ❌ Tidak ada min/max
    'gender' => 'required|in:male,female',  // ✅ OK
    'activity_level' => 'required|in:sedentary,light,moderate,active,very_active', // ✅ OK
    'goal' => 'required|in:cutting,maintenance,bulking', // ✅ OK
]);
```

**Validasi yang dibutuhkan:**

| Field | Tipe | Min | Max | Satuan | Alasan |
|-------|------|-----|-----|--------|--------|
| `age` | integer | 10 | 120 | tahun | Anak <10 tidak relevan, >120 tidak wajar |
| `weight` | numeric | 20 | 300 | kg | BMI calculation tidak akurat di luar range |
| `height` | numeric | 50 | 250 | cm | Tidak wajar di luar range ini |

**Yang perlu diubah:**

| Komponen | Status | Detail |
|----------|--------|--------|
| Update validation rules | ❌ | Tambah `min:` dan `max:` ke age, weight, height |
| Custom error messages (Bahasa Indonesia) | ❌ | "Berat badan harus antara 20-300 kg" dll |
| Return 422 dengan pesan jelas | ❌ | Frontend menampilkan error message dari response |

**Contoh validasi yang diharapkan:**
```php
$request->validate([
    'age' => 'required|integer|min:10|max:120',
    'weight' => 'required|numeric|min:20|max:300',
    'height' => 'required|numeric|min:50|max:250',
    'gender' => 'required|in:male,female',
    'activity_level' => 'required|in:sedentary,light,moderate,active,very_active',
    'goal' => 'required|in:cutting,maintenance,bulking',
], [
    'age.min' => 'Usia minimal 10 tahun',
    'age.max' => 'Usia maksimal 120 tahun',
    'weight.min' => 'Berat badan minimal 20 kg',
    'weight.max' => 'Berat badan maksimal 300 kg',
    'height.min' => 'Tinggi badan minimal 50 cm',
    'height.max' => 'Tinggi badan maksimal 250 cm',
]);
```

---

### BE-S2-09: Backend Notifikasi

**Ini task yang paling kompleks. Ada 3 sub-komponen:**

#### Sub-task A: FCM Token Storage

| Komponen | Status | Detail |
|----------|--------|--------|
| Migration: tambah `fcm_token` ke users | ✅ Done | `2026_05_02_000006_add_community_fields_to_users_table.php` — `string('fcm_token')->nullable()` |
| Endpoint: `POST /api/profile` terima `fcm_token` | ❌ | Frontend sudah kirim via `updateFcmToken()` tapi backend belum terima |
| Simpan token ke database | ❌ | Update model + controller |

**Frontend mengirim:**
```dart
// lib/services/profile_api_service.dart:164-172
Future<void> updateFcmToken(String token) async {
  await _dio.dio.post(
    Endpoints.profile,  // POST /api/profile
    data: {'fcm_token': token},
  );
}
```

> ⚠️ **Catatan:** Frontend mengirim `fcm_token` ke `POST /api/profile`, tapi saat ini `ProfileController@store` tidak punya field `fcm_token` di validation. Perlu ditambahkan atau buat endpoint terpisah.

#### Sub-task B: Database Tabel Notifications

| Komponen | Status | Detail |
|----------|--------|--------|
| Migration `notifications` table | ❌ | id, user_id (penerima), type, title, body, data (json), read_at, created_at |
| Model `Notification` | ❌ | Relasi ke User |
| Controller `NotificationController` | ❌ | index, markAsRead, markAllAsRead |
| Routes | ❌ | `GET /notifications`, `PUT /notifications/{id}/read`, `PUT /notifications/read-all` |

**Struktur tabel notifications yang disarankan:**
```
notifications:
  - id (bigint, PK)
  - user_id (bigint, FK ke users) — penerima notifikasi
  - actor_id (bigint, FK ke users) — yang melakukan aksi
  - type (string) — 'like', 'comment', 'follow'
  - post_id (bigint, nullable, FK ke posts) — untuk like/comment
  - title (string)
  - body (text)
  - data (json, nullable) — payload tambahan
  - read_at (timestamp, nullable)
  - created_at, updated_at
```

#### Sub-task C: Push Notification via FCM

| Komponen | Status | Detail |
|----------|--------|--------|
| Install FCM package | ❌ | `composer require laravel-notification-channels/fcm` |
| Firebase service account JSON | ❌ | Taruh di `storage/app/firebase-credentials.json` |
| `.env` config | ❌ | `FIREBASE_CREDENTIALS_PATH`, `FIREBASE_PROJECT_ID` |
| Notification class (FcmChannel) | ❌ | Laravel Notification via FCM |
| Trigger saat like | ❌ | Di `PostController@toggleLike` — kirim notif ke pemilik post |
| Trigger saat comment | ❌ | Di `PostController@storeComment` — kirim notif ke pemilik post |
| Trigger saat follow | ❌ | (jika ada follow endpoint) — kirim notif ke user yang di-follow |

**Event triggers:**

| Event | Trigger di | Penerima | Pesan |
|-------|-----------|----------|-------|
| Someone likes your post | `PostController@toggleLike` | Post owner | "{user} menyukai postingan Anda" |
| Someone comments on your post | `PostController@storeComment` | Post owner | "{user} mengomentari postingan Anda" |
| Someone follows you | Follow endpoint | Followed user | "{user} mulai mengikuti Anda" |

**Jangan kirim notifikasi ke diri sendiri!** Cek `if ($actor_id !== $post->user_id)` sebelum kirim.

#### Ringkasan BE-S2-09:

| Sub-task | Pekerjaan | Estimasi |
|----------|-----------|----------|
| A. FCM Token Storage | 1 migration + update controller | Kecil |
| B. Notification CRUD | 1 migration + 1 model + 1 controller + routes | Sedang |
| C. FCM Push + Triggers | Install package + config + 3 trigger points | Besar |

---

## 4. AI Agent Prompt
Copy-paste prompt di bawah ke AI agent (Claude Code / Cursor / dll) untuk memudahkan implementasi. Satu prompt per task.

---

### Prompt BE-S2-07: Upload Foto Profil — ✅ SUDAH DONE

> Task ini sudah diimplementasikan pada 3 Mei 2026 oleh Adit. Tidak perlu dikerjakan lagi.

---

### Prompt BE-S2-08: Validasi Batas Wajar Input

```
Saya mengerjakan backend Laravel untuk aplikasi Nutrify. Saya perlu menambahkan validasi batas wajar untuk input profil pengguna.

## Konteks Project
- Laravel 12, PHP 8.2
- File: `app/Http/Controllers/Api/ProfileController.php`
- Method: `store(Request $request)` — baris 14-35

## Validasi saat ini
```php
$request->validate([
    'age' => 'required|integer',
    'weight' => 'required|numeric',
    'height' => 'required|numeric',
    'gender' => 'required|in:male,female',
    'activity_level' => 'required|in:sedentary,light,moderate,active,very_active',
    'goal' => 'required|in:cutting,maintenance,bulking',
]);
```

## Apa yang perlu diubah

Update validation rules untuk age, weight, height dengan batas wajar:

| Field | Tipe | Min | Max | Alasan |
|-------|------|-----|-----|--------|
| age | integer | 10 | 120 | tahun — anak <10 tidak relevan |
| weight | numeric | 20 | 300 | kg — BMI tidak akurat di luar range |
| height | numeric | 50 | 250 | cm — tidak wajar di luar range |

## Contoh hasil yang diharapkan
```php
$request->validate([
    'age' => 'required|integer|min:10|max:120',
    'weight' => 'required|numeric|min:20|max:300',
    'height' => 'required|numeric|min:50|max:250',
    'gender' => 'required|in:male,female',
    'activity_level' => 'required|in:sedentary,light,moderate,active,very_active',
    'goal' => 'required|in:cutting,maintenance,bulking',
], [
    'age.min' => 'Usia minimal 10 tahun',
    'age.max' => 'Usia maksimal 120 tahun',
    'weight.min' => 'Berat badan minimal 20 kg',
    'weight.max' => 'Berat badan maksimal 300 kg',
    'height.min' => 'Tinggi badan minimal 50 cm',
    'height.max' => 'Tinggi badan maksimal 250 cm',
]);
```

Tolong update `ProfileController@store` dengan validasi di atas. Jangan ubah logic lainnya.
```

---

### Prompt BE-S2-09: Backend Notifikasi (Full)

```
Saya mengerjakan backend Laravel untuk aplikasi Nutrify. Saya perlu mengimplementasikan sistem notifikasi lengkap (database + FCM push notification).

## Konteks Project
- Laravel 12, PHP 8.2
- Auth: Supabase JWT (middleware `supabase.auth`, guard menggunakan `Auth::id()` untuk user ID)
- Database: PostgreSQL (Supabase)
- Model User sudah ada di `app/Models/User.php` ( menggunakan trait `Notifiable`)
- Model Profile di `app/Models/Profile.php` (fillable: user_id, age, weight, height, gender, goal, activity_level)
- PostController di `app/Http/Controllers/Api/PostController.php` sudah ada methods: toggleLike, comments, storeComment
- Routes di `routes/api.php`

## Struktur database yang sudah ada
- `users` table: id, name, email, password, supabase_id, timestamps
- `profiles` table: id, user_id, age, weight, height, gender, goal, activity_level, timestamps
- `posts` table: id, user_id, content, image, timestamps
- `post_likes` table: id, user_id, post_id, timestamps
- `comments` table: id, user_id, post_id, content, timestamps

## Apa yang perlu dibuat (3 bagian)

### Bagian A: FCM Token Storage

1. **Migration** — tambah `fcm_token` (string, nullable) ke tabel `users` ATAU `profiles` (pilih yang lebih cocok)
2. **Update model** — tambah ke fillable
3. **Update `ProfileController@store`** — accept `fcm_token` sebagai optional field, simpan ke user/profile
   ATAU buat endpoint terpisah `POST /api/profile/fcm-token`

   Frontend mengirim:
   ```dart
   await _dio.dio.post(
     '/profile',  // POST /api/profile
     data: {'fcm_token': token},
   );
   ```
   Jadi field `fcm_token` harus diterima di ProfileController (optional, jangan required).

### Bagian B: Database Notifications

1. **Migration `create_notifications_table`**:
   ```php
   $table->id();
   $table->foreignId('user_id')->constrained()->onDelete('cascade'); // penerima
   $table->foreignId('actor_id')->constrained('users')->onDelete('cascade'); // pengirim
   $table->string('type'); // 'like', 'comment', 'follow'
   $table->foreignId('post_id')->nullable()->constrained()->onDelete('cascade');
   $table->string('title');
   $table->text('body');
   $table->json('data')->nullable();
   $table->timestamp('read_at')->nullable();
   $table->timestamps();
   ```

2. **Model `Notification`** (`app/Models/Notification.php`):
   - Relasi: belongsTo User (penerima via user_id), belongsTo User (actor via actor_id), belongsTo Post (nullable)
   - Scope: `unread()`, `latest()`
   - Accessor: `isRead`

3. **Controller `NotificationController`** (`app/Http/Controllers/Api/NotificationController.php`):
   - `index()` — GET /notifications — list notifikasi user login (paginated, eager load actor)
   - `markAsRead($id)` — PUT /notifications/{id}/read
   - `markAllAsRead()` — PUT /notifications/read-all
   - `unreadCount()` — GET /notifications/unread-count

4. **Routes** (dalam middleware group):
   ```php
   Route::get('/notifications', [NotificationController::class, 'index']);
   Route::put('/notifications/read-all', [NotificationController::class, 'markAllAsRead']);
   Route::put('/notifications/{id}/read', [NotificationController::class, 'markAsRead']);
   Route::get('/notifications/unread-count', [NotificationController::class, 'unreadCount']);
   ```

### Bagian C: FCM Push Notification + Triggers

1. **Install package**:
   ```bash
   composer require laravel-notification-channels/fcm
   ```

2. **Konfigurasi**:
   - Taruh Firebase service account JSON di `storage/app/firebase-credentials.json`
   - Tambah di `.env`: `FIREBASE_CREDENTIALS_PATH=storage/app/firebase-credentials.json`

3. **Buat Notification class** (`app/Notifications/PushNotification.php`):
   - Via FcmChannel
   - Title, body, data payload
   - Support untuk like, comment, follow type

4. **Tambah trigger di PostController**:

   a. Di `toggleLike()` — SETELAH like berhasil (bukan unlike):
   ```php
   // Cek jika ini like (bukan unlike) DAN bukan post sendiri
   if ($liked && $post->user_id !== Auth::id()) {
       // Simpan ke notifications table
       // Kirim FCM push ke post owner
   }
   ```

   b. Di `storeComment()` — SETELAH comment tersimpan:
   ```php
   // Jika bukan komentar di post sendiri
   if ($post->user_id !== Auth::id()) {
       // Simpan ke notifications table
       // Kirim FCM push ke post owner
   }
   ```

   c. (Jika ada follow endpoint) — SETELAH follow berhasil:
   ```php
   // Simpan ke notifications table
   // Kirim FCM push ke user yang di-follow
   ```

## PENTING
- **JANGAN kirim notifikasi ke diri sendiri!** Selalu cek `$post->user_id !== Auth::id()`
- **JANGAN kirim notifikasi untuk UNLIKE** — hanya saat like
- Untuk FCM: jika user tidak punya fcm_token, tetap simpan ke database tapi skip push
- Response notification harus include actor name dan photo (jika ada) untuk ditampilkan di frontend

## Response format yang diharapkan

GET /notifications:
```json
{
  "data": [
    {
      "id": 1,
      "type": "like",
      "title": "Suka baru",
      "body": "John menyukai postingan Anda",
      "actor": {
        "id": 2,
        "name": "John"
      },
      "post_id": 5,
      "read_at": null,
      "created_at": "2026-05-02T10:00:00Z"
    }
  ]
}
```

Tolong implementasikan ketiga bagian (A, B, C) secara lengkap. Buat semua migration, model, controller, notification class, update routes, dan tambah trigger di PostController.
```

---

## Referensi Cepat

### Struktur File Backend Saat Ini

```
backend/
├── app/
│   ├── Http/
│   │   ├── Controllers/
│   │   │   ├── Api/
│   │   │   │   ├── ProfileController.php    ✅ DONE (BE-S2-07 photo + photo_url, BE-S2-08 still TODO)
│   │   │   │   ├── PostController.php       ✅ DONE (enhanced formatPost + 10MB limit, BE-S2-09C triggers TODO)
│   │   │   │   ├── FollowController.php     ✅ DONE (follow, profile, search, username, account-type)
│   │   │   │   ├── FoodController.php       ✅
│   │   │   │   ├── FavoriteController.php   ✅
│   │   │   │   └── OtpController.php        ✅
│   │   │   └── Controller.php
│   │   └── Middleware/
│   │       └── VerifySupabaseToken.php       ✅
│   ├── Models/
│   │   ├── User.php                          ✅ DONE (+username, avatar, fcm_token, account_type, follow relations)
│   │   ├── Profile.php                       ✅ DONE (+'photo')
│   │   ├── Follow.php                        ✅ DONE (NEW)
│   │   ├── Post.php                          ✅
│   │   ├── PostLike.php                      ✅
│   │   ├── Comment.php                       ✅
│   │   ├── UserFavorite.php                  ✅
│   │   ├── Food.php                          ✅
│   │   ├── FoodLog.php                       ✅
│   │   └── Otp.php                           ✅
│   ├── Mail/
│   │   └── OtpMail.php                       ✅
│   └── Notifications/                        ← NEW (BE-S2-09C, belum dibuat)
│       └── PushNotification.php
├── database/migrations/
│   ├── ... (15 existing + 2 new Sprint 2)    ✅
│   ├── 2026_05_02_000006_add_community_fields ✅ DONE
│   ├── 2026_05_02_000007_create_follows      ✅ DONE
│   ├── 2026_05_03_000001_add_photo_profiles  ✅ DONE
│   └── xxxx_create_notifications_table.php   ← NEW (BE-S2-09B, belum dibuat)
├── routes/
│   └── api.php                               ✅ DONE (+18 route baru)
└── storage/
    └── app/
        ├── public/profile-photos/            ✅ DONE
        └── firebase-credentials.json         ← NEW (BE-S2-09C, belum dibuat)
```

### Endpoint yang Sudah Ditambahkan ✅

| Method | Path | Task ID | Keterangan |
|--------|------|---------|------------|
| PUT | `/api/profile/photo` | BE-S2-07 | ✅ Upload foto profil |
| POST | `/api/users/{id}/follow` | Follow | ✅ Follow/unfollow |
| GET | `/api/users/{id}/profile` | Follow | ✅ Profil user + posts |
| GET | `/api/users/search?q=` | Follow | ✅ Cari user |
| PUT | `/api/username` | Follow | ✅ Set/update username |
| PUT | `/api/account-type` | Follow | ✅ Set public/private |

### Endpoint yang Masih Perlu Ditambahkan

| Method | Path | Task ID | Keterangan |
|--------|------|---------|------------|
| GET | `/api/notifications` | BE-S2-09 | List notifikasi |
| PUT | `/api/notifications/read-all` | BE-S2-09 | Tandai semua dibaca |
| PUT | `/api/notifications/{id}/read` | BE-S2-09 | Tandai satu dibaca |
| GET | `/api/notifications/unread-count` | BE-S2-09 | Hitung belum dibaca |

### Endpoint yang Masih Perlu Diupdate

| Method | Path | Task ID | Perubahan |
|--------|------|---------|-----------|
| POST | `/api/profile/store` | BE-S2-08 | Tambah validation min/max |
| POST | `/api/posts/{id}/like` | BE-S2-09C | Trigger notifikasi like |
| POST | `/api/posts/{id}/comments` | BE-S2-09C | Trigger notifikasi comment |

---

*Dokumen ini dibuat pada 2 Mei 2026 oleh Ibnu Habib sebagai panduan Backend Developer.*
