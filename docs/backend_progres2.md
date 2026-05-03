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
| ✅ Done | 8 task | BE-S2-01 s/d BE-S2-07, BE-S2-09 |
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
| BE-S2-09 | Backend Notifikasi | FCM token storage + database notifications + FCM push | ✅ Done (3 Mei — Notification system complete) |

### ❌ BELUM DIKERJAKAN

| ID | Task | Deskripsi | Frontend Siap? | Status |
|----|------|-----------|----------------|--------|
| BE-S2-08 | Validasi Batas Wajar Input | Min/max untuk age, weight, height di `ProfileController@store` | ✅ Frontend sudah kirim data | ❌ Not Started |

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

### BE-S2-09: Backend Notifikasi — ✅ DONE (3 Mei)

**Task ini sudah diimplementasikan sepenuhnya pada 3 Mei 2026.**

#### Sub-task A: FCM Token Storage

| Komponen | Status | Detail |
|----------|--------|--------|
| Migration: tambah `fcm_token` ke users | ✅ Done | `2026_05_02_000006_add_community_fields_to_users_table.php` — `string('fcm_token')->nullable()` |
| Endpoint: `POST /api/profile` terima `fcm_token` | ✅ Done | `ProfileController@store` — validation `'fcm_token' => 'nullable|string'` |
| Simpan token ke database | ✅ Done | Update user dengan `fcm_token` |

**Implementation:**
```php
// ProfileController.php - validation
$request->validate([
    // ... other fields
    'fcm_token' => 'nullable|string',
]);

// Update fcm_token logic
if ($request->has('fcm_token')) {
    $user = User::find(Auth::id());
    if ($user) {
        $user->update(['fcm_token' => $request->fcm_token]);
    }
}
```

#### Sub-task B: Database Tabel Notifications

| Komponen | Status | Detail |
|----------|--------|--------|
| Migration `notifications` table | ✅ Done | `2026_05_03_034954_create_notifications_table.php` — complete structure |
| Model `Notification` | ✅ Done | Relasi ke User (penerima & actor), Post. Scopes: unread(), latest(). Accessor: isRead |
| Controller `NotificationController` | ✅ Done | index(), markAsRead(), markAllAsRead(), unreadCount() |
| Routes | ✅ Done | 4 notification routes ditambahkan |

**Implementation:**
```php
// Migration structure
$table->id();
$table->foreignId('user_id')->constrained()->onDelete('cascade'); // penerima
$table->foreignId('actor_id')->nullable()->constrained('users')->onDelete('cascade'); // pengirim
$table->string('type'); // 'like', 'comment', 'follow'
$table->foreignId('post_id')->nullable()->constrained()->onDelete('cascade');
$table->string('title');
$table->text('body');
$table->json('data')->nullable();
$table->timestamp('read_at')->nullable();
$table->timestamps();

// Routes
Route::get('/notifications', [NotificationController::class, 'index']);
Route::put('/notifications/read-all', [NotificationController::class, 'markAllAsRead']);
Route::put('/notifications/{id}/read', [NotificationController::class, 'markAsRead']);
Route::get('/notifications/unread-count', [NotificationController::class, 'unreadCount']);
```

#### Sub-task C: Push Notification via FCM

| Komponen | Status | Detail |
|----------|--------|--------|
| FCM Package/Service | ✅ Done | Manual implementation - `FCMService.php` (tanpa package untuk Laravel 12 compatibility) |
| Firebase service account JSON | ✅ Done | Setup via `.env` — `FIREBASE_CREDENTIALS_PATH=storage/app/firebase-credentials.json.json` |
| `.env` config | ✅ Done | Firebase credentials path ditambahkan |
| Notification class | ✅ Done | `PushNotification.php` — wrapper untuk FCMService |
| Trigger saat like | ✅ Done | `PostController@toggleLike` — kirim notif ke pemilik post |
| Trigger saat comment | ✅ Done | `PostController@storeComment` — kirim notif ke pemilik post |
| Trigger saat follow | ✅ Done | `FollowController@toggleFollow` — kirim notif ke user yang di-follow |

**Implementation:**
```php
// Trigger like - PostController.php
if ($liked && $post->user_id !== Auth::id()) {
    $actor = User::find(Auth::id());

    // Simpan ke database
    Notification::create([
        'user_id' => $post->user_id,
        'actor_id' => Auth::id(),
        'type' => 'like',
        'post_id' => $id,
        'title' => 'Suka Baru',
        'body' => "{$actor->name} menyukai postingan Anda",
        'data' => [
            'actor_name' => $actor->name,
            'actor_id' => $actor->id,
        ],
    ]);

    // Kirim FCM push notification
    $postOwner = User::find($post->user_id);
    if ($postOwner && !empty($postOwner->fcm_token)) {
        $notification = new PushNotification(
            'Suka Baru',
            "{$actor->name} menyukai postingan Anda",
            'like',
            ['post_id' => $id],
            $actor,
            $post
        );
        $notification->send($postOwner);
    }
}
```

**FCMService Manual Implementation:**
- Class `FCMService` di `app/Services/FCMService.php`
- Menggunakan Firebase FCM API v1
- Manual OAuth 2.0 authentication dengan JWT
- Tidak perlu package eksternal (Laravel 12 compatible)

**Event Triggers:**

| Event | Trigger di | Penerima | Pesan |
|-------|-----------|----------|-------|
| Someone likes your post | `PostController@toggleLike` | Post owner | "{name} menyukai postingan Anda" |
| Someone comments on your post | `PostController@storeComment` | Post owner | "{name} mengomentari postingan Anda" |
| Someone follows you | `FollowController@toggleFollow` | Followed user | "{name} mulai mengikuti Anda" |

**Security:**
- ✅ Tidak kirim notifikasi ke diri sendiri (`if ($post->user_id !== Auth::id())`)
- ✅ Tidak kirim notifikasi untuk unlike (hanya saat like)
- ✅ Skip FCM push jika user tidak punya fcm_token
- ✅ Firebase credentials dilindungi di `.gitignore`

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

### Prompt BE-S2-09: Backend Notifikasi — ✅ SUDAH DONE

> Task ini sudah diimplementasikan sepenuhnya pada 3 Mei 2026. Tidak perlu dikerjakan lagi.

**Yang sudah diimplementasikan:**
- ✅ FCM Token Storage (fcm_token field di users table + ProfileController handling)
- ✅ Database Notifications (migration, model, controller, routes)
- ✅ FCM Push Notification (manual FCMService, PushNotification class)
- ✅ Notification Triggers (like, comment, follow)

**Files yang sudah dibuat:**
- `app/Models/Notification.php`
- `app/Http/Controllers/Api/NotificationController.php`
- `app/Services/FCMService.php`
- `app/Notifications/PushNotification.php`
- `database/migrations/2026_05_03_034954_create_notifications_table.php`

**Yang perlu dilakukan di VPS:**
- Setup Firebase credentials (download dari Firebase Console, upload ke VPS)
- Update `.env` dengan `FIREBASE_CREDENTIALS_PATH`
- Jalankan migration `notifications` table

---

## Referensi Cepat

### Struktur File Backend Saat Ini

```
backend/
├── app/
│   ├── Http/
│   │   ├── Controllers/
│   │   │   ├── Api/
│   │   │   │   ├── ProfileController.php    ✅ DONE (BE-S2-07 photo + photo_url, BE-S2-08 still TODO, BE-S2-09 fcm_token)
│   │   │   │   ├── PostController.php       ✅ DONE (enhanced formatPost + 10MB limit, BE-S2-09 triggers done)
│   │   │   │   ├── FollowController.php     ✅ DONE (follow, profile, search, username, account-type, BE-S2-09 triggers)
│   │   │   │   ├── NotificationController.php ✅ DONE (BE-S2-09) — NEW
│   │   │   │   ├── FoodController.php       ✅
│   │   │   │   ├── FavoriteController.php   ✅
│   │   │   │   └── OtpController.php        ✅
│   │   │   └── Controller.php
│   │   └── Middleware/
│   │       └── VerifySupabaseToken.php       ✅
│   ├── Models/
│   │   ├── User.php                          ✅ DONE (+username, avatar, fcm_token, account_type, follow relations)
│   │   ├── Profile.php                       ✅ DONE (+'photo', 'target_weight')
│   │   ├── Follow.php                        ✅ DONE (NEW)
│   │   ├── Notification.php                  ✅ DONE (BE-S2-09) — NEW
│   │   ├── Post.php                          ✅
│   │   ├── PostLike.php                      ✅
│   │   ├── Comment.php                       ✅
│   │   ├── UserFavorite.php                  ✅
│   │   ├── Food.php                          ✅
│   │   ├── FoodLog.php                       ✅
│   │   └── Otp.php                           ✅
│   ├── Services/
│   │   └── FCMService.php                    ✅ DONE (BE-S2-09) — NEW
│   ├── Notifications/
│   │   └── PushNotification.php              ✅ DONE (BE-S2-09) — NEW
│   └── Mail/
│       └── OtpMail.php                       ✅
├── database/migrations/
│   ├── ... (15 existing + 5 new Sprint 2)    ✅
│   ├── 2026_05_02_000006_add_community_fields ✅ DONE
│   ├── 2026_05_02_000007_create_follows      ✅ DONE
│   ├── 2026_05_03_000001_add_photo_profiles  ✅ DONE
│   ├── 2026_05_03_020508_add_target_weight   ✅ DONE
│   └── 2026_05_03_034954_create_notifications ✅ DONE (BE-S2-09) — NEW
├── routes/
│   └── api.php                               ✅ DONE (+22 route baru)
└── storage/
    └── app/
        ├── public/profile-photos/            ✅ DONE
        └── firebase-credentials.json.json    ⚠️ Setup di VPS (BE-S2-09)
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
| GET | `/api/notifications` | BE-S2-09 | ✅ List notifikasi (paginated) |
| PUT | `/api/notifications/read-all` | BE-S2-09 | ✅ Tandai semua dibaca |
| PUT | `/api/notifications/{id}/read` | BE-S2-09 | ✅ Tandai satu dibaca |
| GET | `/api/notifications/unread-count` | BE-S2-09 | ✅ Hitung belum dibaca |

### Endpoint yang Masih Perlu Diupdate

| Method | Path | Task ID | Perubahan |
|--------|------|---------|-----------|
| POST | `/api/profile/store` | BE-S2-08 | Tambah validation min/max |

---

*Dokumen ini dibuat pada 2 Mei 2026 oleh Ibnu Habib sebagai panduan Backend Developer.*
