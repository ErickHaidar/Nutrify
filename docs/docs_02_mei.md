# NUTRIFY — Dokumentasi Sprint 2 (2–3 Mei 2026)

> **Penanggung jawab:** Ibnu Habib (Backend Developer)
> **Tanggal:** 3 Mei 2026
> **Versi:** 0.10.0

---

## DAFTAR ISI

1. [Ringkasan Hari Ini](#1-ringkasan-hari-ini)
2. [Detail Pekerjaan yang Diselesaikan](#2-detail-pekerjaan-yang-diselesaikan)
3. [Update Backlog Sprint 2](#3-update-backlog-sprint-2)
4. [Changelog v0.9.0](#4-changelog-v090)
5. [Status Infrastruktur & Konfigurasi](#5-status-infrastruktur--konfigurasi)
6. [File yang Diubah/Hari Ini](#6-file-yang-diubahhari-ini)
7. [Yang Masih Perlu Dikerjakan](#7-yang-masih-perlu-dikerjakan)

---

## 1. Ringkasan Hari Ini

Hari ini (2 Mei 2026) Ibnu menyelesaikan **18 task** mencakup backend, frontend, infrastruktur email, dan bug fixing. Pada 3 Mei dilanjutkan dengan **6 task tambahan** (follow system + community enhancements + bug fixes), dan Adit menyelesaikan **1 task** (BE-S2-07 upload foto profil):

| Kategori | Jumlah | Detail |
|----------|--------|--------|
| Backend API | 5 task | OTP endpoint, migration, model, mailable, routes |
| Backend Tambahan (3 Mei) | 2 task | Follow system, user fields migration |
| Backend Adit (3 Mei) | 1 task | Upload foto profil (BE-S2-07) |
| Frontend Fix & Enhancement | 11 task | OTP UI, calendar, edit profile, history, komunitas, notifikasi |
| Frontend Tambahan (3 Mei) | 4 task | Post detail screen, user profile, search users, profile photo from API |
| Infrastruktur Email | 2 task | Brevo → Resend SMTP, email templates |
| Bug Fix | 5 task | OTP bypass, save button, self-follow, auto-refresh, Google login |
| Bug Fix Tambahan (3 Mei) | 3 task | Birth date save, save button after photo, photo upload non-blocking |

**Progress Sprint 2 Backend Ibnu: 5/7 (71%) + extra follow system**

---

## 2. Detail Pekerjaan yang Diselesaikan

### 2.1 Backend — Verifikasi Email OTP (BE-S2-06)

> Sebelumnya ditugaskan ke Adit, Ibnu ambil alih karena prioritas.

| Komponen | File | Keterangan |
|----------|------|------------|
| Migration `otps` | `database/migrations/2026_05_02_000005_create_otps_table.php` | Tabel `otps` dengan kolom: id, email, code (hashed), expires_at, verified_at, timestamps |
| Model `Otp` | `app/Models/Otp.php` | Helper `isExpired()`, `isVerified()` |
| Controller `OtpController` | `app/Http/Controllers/Api/OtpController.php` | `send()` + `verify()` dengan rate limiting (1 send/menit, 5 verify/menit per email) |
| Mailable `OtpMail` | `app/Mail/OtpMail.php` | Email template class untuk OTP |
| Blade Template | `resources/views/emails/otp.blade.php` | Email HTML dengan branding Nutrify |
| Routes | `routes/api.php` | `POST /api/auth/send-otp` dan `POST /api/auth/verify-otp` (PUBLIC, tanpa auth middleware) |

**Catatan:** Frontend tetap menggunakan Supabase built-in OTP (`verifyOTP()` dengan `OtpType.signup`). Backend OTP endpoint tersedia sebagai alternatif jika diperlukan di masa depan.

---

### 2.2 Infrastruktur Email — Supabase SMTP

**Masalah awal:** Supabase free tier hanya mengirim 3 email/jam. OTP signup gagal dikirim.

**Solusi yang diimplementasikan:**

| Langkah | Provider | Hasil |
|---------|----------|-------|
| Coba Brevo SMTP | smtp-relay.brevo.com | Gagal — 525 Unauthorized IP dari Supabase AWS |
| Coba Resend SMTP | smtp.resend.com | Berhasil — email terkirim dan masuk inbox |
| Buat email templates | — | 6 template HTML custom dengan branding Nutrify |

**File pendukung yang dibuat:**

| File | Keterangan |
|------|------------|
| `guide_brevo_smtp.md` | Guide lengkap setup Brevo SMTP (arsip, tidak dipakai) |
| `templates.md` | 6 email template HTML (Confirm Sign Up, Invite User, Magic Link, Change Email, Reset Password, Reauthentication) |

**Template email features:**
- Logo Nutrify dari `https://nutrify-app.my.id/logo.png`
- Branding gradient purple (#4A446F → #6B6594)
- Warm Bahasa Indonesia copy
- OTP code dalam card peach (Confirm Sign Up & Reauthentication)
- CTA buttons (Invite, Magic Link, Reset Password, Change Email)
- Security warning boxes
- Responsive HTML table-based layout

**Konfigurasi aktif di Supabase:**
- Custom SMTP: Resend (`smtp.resend.com`, port 587)
- Email Templates: Custom HTML (6 templates)
- Confirm email: ENABLED

---

### 2.3 Frontend — OTP Verification Screen

**Masalah:** Saat daftar, user klik back dari OTP screen → langsung masuk app tanpa verifikasi.

**Solusi (3 layer protection):**

| Layer | File | Perubahan |
|-------|------|-----------|
| Auth listener | `lib/presentation/my_app.dart` | Cek `emailConfirmedAt == null` pada `signedIn` event — skip auto-navigate jika email belum verified |
| OTP screen | `lib/screens/otp_verification_screen.dart` | `PopScope(canPop: false)` + dialog konfirmasi + `signOut()` jika user pilih keluar |
| Splash screen | `lib/screens/splash_screen.dart` | Cek `emailConfirmedAt == null` saat session recovery → signOut + redirect ke login |

**OTP UI features:**
- 6 digit input boxes (sesuai Supabase default)
- Auto-paste support: paste 6 digit di kotak pertama → otomatis terisi semua
- `FilteringTextInputFormatter.digitsOnly` — hanya angka
- Countdown timer 60 detik untuk resend
- Error parsing (invalid/expired/rate limit)

---

### 2.4 Frontend — Notification Button Repositioned

**Sebelum:** Notification button di tengah header home
**Sesudah:** Notification button di pojok kanan atas, sebelah kanan help button

| File | Perubahan |
|------|-----------|
| `lib/screens/home_screen.dart` | Reorder header Row: logo+kiri → [help, notification] (kanan) |

---

### 2.5 Frontend — Calendar Fix (Riwayat)

**Masalah:** Calendar picker mulai dari mode Year (harus klik Year → Month → Day).

**Solusi:**

| File | Perubahan |
|------|-----------|
| `lib/widgets/nutrify_calendar_picker.dart` | Tambah parameter `startMode` (default: `year`). Enum `SelectionMode` dibuat public. `initState` override `_mode` dari `widget.startMode` |
| `lib/screens/history_screen.dart` | Panggil `showNutrifyDatePicker()` dengan `startMode: SelectionMode.day` — langsung tampil mode hari |

**Perilaku baru:**
- Buka kalender di Riwayat → langsung tampil mode Hari
- Default bulan = bulan saat ini
- Selected date = tanggal hari ini
- Tetap bisa navigasi ke mode Bulan/Tahun via tap header

---

### 2.6 Frontend — Edit Profile Fixes

#### 2.6.1 Date of Birth Calendar Year Range

**Sebelum:** Range 1900 — sekarang (tidak relevan untuk umur)
**Sesudah:** Range (sekarang - 80) — (sekarang - 10)

```dart
firstDate: DateTime(now.year - 80),
lastDate: DateTime(now.year - 10),
```

#### 2.6.2 Save Button Disabled After Changing Birth Date

**Masalah:** `_hasChanges` tidak mengecek perubahan `_birthDate`.

**Solusi:** Tambah tracking `_initialBirthDate` dan pengecekan di `_hasChanges`:

```dart
(_birthDate != null && _initialBirthDate != null && _birthDate != _initialBirthDate) ||
(_birthDate != null && _initialBirthDate == null)
```

#### 2.6.3 Target Weight Tidak Bisa Diedit

**Masalah:** Field target weight menggunakan `CustomInputField` statis (`initialValue: '80 Kg'`, `onTap: () {}`).

**Solusi:** Ganti ke `ProfileInput` dengan `TextEditingController`:
- Tambah `_targetWeightController`
- Default value dari `profile.weight`
- Tracking `_initialTargetWeight` untuk `_hasChanges`
- Keyboard type: number

---

### 2.7 Frontend — Auto-Refresh History After Adding Food

**Masalah:** Setelah tambah makanan dari Home, buka tab Riwayat → data tidak update. Perlu manual pull-to-refresh.

**Solusi:**

| File | Perubahan |
|------|-----------|
| `lib/screens/history_screen.dart` | Rename state class ke `HistoryScreenState` (public). Tambah `refreshData()` method. Tambah `WidgetsBindingObserver` untuk refresh saat app resume |
| `lib/screens/main_navigation_screen.dart` | Tambah `_historyKey` (GlobalKey). Panggil `_historyKey.currentState?.refreshData()` saat tab riwayat dipilih |

---

### 2.8 Frontend — Comment pada Komunitas

**Masalah:** Tap ikon komentar tidak melakukan apa-apa.

**Solusi:** Tambah `_showComments()` method di `komunitas_screen.dart`:
- Bottom sheet dengan daftar komentar (FutureBuilder → `getComments()`)
- Input field + send button → `addComment()`
- Comment count update otomatis setelah kirim
- Avatar initial + username + content per komentar

---

### 2.9 Frontend — Self-Follow Fix

**Masalah:** User bisa mengikuti dirinya sendiri di komunitas.

**Solusi:**

| File | Perubahan |
|------|-----------|
| `lib/domain/entity/post/community_post.dart` | Tambah getter `isOwnPost` — membandingkan `authorId` dengan `Supabase.instance.client.auth.currentUser?.id` |
| `lib/screens/komunitas_screen.dart` | Wrap follow button dengan `if (!post.isOwnPost)` — sembunyikan untuk post sendiri |

---

### 2.10 Frontend — Community Notification

**Masalah:** Tombol notifikasi di AppBar komunitas (`onPressed: () {}`) tidak melakukan apa-apa.

**Solusi:** Hubungkan ke `NotificationModal` yang sama dengan Home screen:
```dart
onPressed: () {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => const NotificationModal(),
  );
},
```

---

### 2.11 Frontend — Push Notification Enhancement

**Perubahan:**

| File | Perubahan |
|------|-----------|
| `lib/services/notification_service.dart` | Fix timezone: tambah `tz.setLocalLocation(tz.getLocation('Asia/Jakarta'))` setelah `tz.initializeTimeZones()` |
| `lib/presentation/my_app.dart` | Auto-schedule meal reminders saat user berhasil login (jika notifikasi enabled di SharedPreferences) |

**Sistem notifikasi yang sudah berjalan:**
- Firebase Cloud Messaging (FCM) untuk push notification
- `flutter_local_notifications` untuk local scheduled notifications
- Meal reminders: Breakfast (07:00), Lunch (12:00), Dinner (18:00)
- Dynamic content: reminder menampilkan menu yang sudah di-log
- Toggle on/off dari Profile screen
- FCM token registration ke backend

---

### 2.12 Frontend — Auth Interceptor 401 Handling

| File | Perubahan |
|------|-----------|
| `lib/core/data/network/dio/interceptors/auth_interceptor.dart` | Tambah handler `onError`: jika response 401, auto-signOut dari Supabase |

---

### 2.13 Google Sign-In Fix

**Masalah:** `AuthApiException: Unacceptable audience in id_token`

**Root cause:** Google Web Client ID di `.env` harus sama dengan yang terdaftar di Supabase Google Provider settings.

**Solusi:** Verifikasi dan sinkronisasi Client ID antara:
1. `.env` → `GOOGLE_WEB_CLIENT_ID`
2. Supabase Dashboard → Authentication → Providers → Google → Client ID
3. Google Cloud Console → Credentials → Web Client → Authorized redirect URIs

---

## 3. Update Backlog Sprint 2

### Status sebelum update (awal 2 Mei):

| Role | Selesai | Total | Persentase |
|------|---------|-------|------------|
| UI/UX | 8 | 8 | 100% |
| Backend (Ibnu) | 4 | 7 | 57% |
| Frontend | 10 | 10 | 100% |

### Status setelah update 3 Mei:

| Role | Selesai | Total | Persentase |
|------|---------|-------|------------|
| UI/UX | 8 | 8 | 100% |
| Backend (Ibnu+Adit) | 5 | 7 | 71% |
| Frontend | 10 | 10 | 100% |

### Item yang berubah status (2 Mei):

| ID | Backlog Item | Status Lama | Status Baru | Keterangan |
|----|-------------|-------------|-------------|------------|
| BE-S2-06 | Verifikasi Email OTP | ❌ Not Started | ✅ Done | Backend OTP diimplementasikan Ibnu. Frontend pakai Supabase built-in OTP |
| FE-S2-03 | Halaman OTP Verification | ❌ Not Started | ✅ Done | 6 digit, auto-paste, PopScope protection, countdown resend |
| FE-S2-04 | Help Information page | ❌ Not Started | ⚠️ Partial | Help button ada di Home, navigasi ke HelpScreen. Redesign sesuai desain masih pending |
| FE-S2-08 | Komunitas frontend | ⚠️ Mock Data | ✅ Done | Integrasi API lengkap: posts, likes, comments, follow. Bottom sheet komentar |
| — | OTP Bypass Bug | — | ✅ Fixed | 3 layer protection: my_app, otp_screen, splash_screen |
| — | Calendar riwayat | — | ✅ Fixed | Start mode Day, default bulan & hari ini |
| — | Edit profile fixes | — | ✅ Fixed | Save button, target weight, DOB range |
| — | History auto-refresh | — | ✅ Fixed | Refresh on tab switch + app resume |
| — | Self-follow bug | — | ✅ Fixed | `isOwnPost` check, hide follow button |
| — | Community notification | — | ✅ Fixed | Terhubung ke NotificationModal |
| — | Push notification | — | ✅ Enhanced | Timezone fix, auto-schedule on login |

### Item yang berubah status (3 Mei):

| ID | Backlog Item | Status Lama | Status Baru | Keterangan |
|----|-------------|-------------|-------------|------------|
| BE-S2-07 | API Upload Foto Profil | ❌ Not Started | ✅ Done | Adit: migration, ProfileController@photo, storage, route |
| — | Follow System | — | ✅ Done | FollowController + follows table + user fields migration + 5 routes |
| — | Post Detail Screen | — | ✅ Done | Twitter/Threads style post detail dengan inline comments |
| — | User Profile Screen | — | ✅ Done | Profil user lain dengan follow button dan post list |
| — | User Search | — | ✅ Done | Search modal di komunitas, cari by nama/username |
| — | PostController Enhanced | — | ✅ Done | +supabase_id, +username, +avatar_url, +is_followed, upload 10MB |
| — | Birth Date Fix | — | ✅ Fixed | SharedPreferences persistence (backend hanya simpan age integer) |
| — | Save Button After Photo | — | ✅ Fixed | _hasChanges includes _isPhotoChanged |
| — | Photo Upload Non-blocking | — | ✅ Fixed | Profile data saves first, photo failure shows SnackBar |
| — | Character Limit Posts | — | ✅ Done | maxLength 1000 pada post TextField |
| — | Camera Option | — | ✅ Done | Gallery/Camera bottom sheet di add_post_screen |

### Backlog tersisa:

| ID | Backlog Item | Status |
|----|-------------|--------|
| BE-S2-08 | Validasi batas wajar input (tinggi, berat, umur) | ❌ Not Started |
| BE-S2-09 | Backend notifikasi (edge function/socket) | ⚠️ Partial — fcm_token field sudah ada |

---

## 4. Changelog v0.10.0

### Added — Backend (3 Mei)
- **Migration `add_photo_to_profiles_table`**: Kolom `photo` (string, nullable) di tabel profiles
- **`ProfileController@photo`**: Upload foto profil — validate image max 10MB, store ke `profile-photos/`, hapus foto lama
- **Route `PUT /api/profile/photo`**: Endpoint upload foto profil
- **Migration `add_community_fields_to_users_table`**: Kolom username (unique), avatar, fcm_token, account_type (enum public/private)
- **Migration `create_follows_table`**: Tabel follows dengan follower_id, following_id, unique constraint
- **Model `Follow`**: Relasi follower/following
- **`FollowController`**: toggleFollow (422 self-follow), userProfile, searchUsers, updateUsername, updateAccountType
- **PostController enhanced**: formatPost sekarang include supabase_id, username, avatar_url, is_followed
- **Upload limit**: 2MB → 10MB untuk gambar post, format ditambah webp
- **Routes**: +5 route baru (follow, user profile, search, username, account-type)

### Added — Frontend (3 Mei)
- **`post_detail_screen.dart`**: Twitter/Threads style — full post detail, inline comments, like/comment bar, delete own posts, fixed bottom input
- **`user_profile_screen.dart`**: Profil user lain — avatar, name, @username, stats, follow button, post list
- **Search users modal**: Bottom sheet di komunitas, search by nama/username, follow button, navigate to profile
- **Camera option**: Gallery/Camera bottom sheet di add_post_screen
- **Character limit**: maxLength 1000 pada post TextField dengan counter
- **Profile photo from API**: `_buildProfileImageProvider()` priority: API photoUrl > local file > null
- **Community enhancements**: `isOwnPost` UUID comparison, follow via API, navigate to user profile

### Added — Backend (2 Mei)
- **Migration `create_otps_table`**: Tabel `otps` dengan kolom id, email, code (hashed), expires_at, verified_at, timestamps
- **Model `Otp`**: Dengan helper `isExpired()` dan `isVerified()`
- **`OtpController`**: `send()` dan `verify()` dengan rate limiting (1 send/menit, 5 verify/menit per email)
- **`OtpMail` mailable**: Email template untuk OTP code
- **Blade template `emails/otp`**: HTML email dengan branding Nutrify
- **Routes**: `POST /api/auth/send-otp` dan `POST /api/auth/verify-otp` (public)

### Added — Frontend (2 Mei)
- **OTP auto-paste**: User bisa paste 6 digit OTP langsung ke field pertama → otomatis terisi semua
- **Comment bottom sheet**: User bisa lihat dan tulis komentar di post komunitas
- **Community notification**: Tombol notifikasi komunitas terhubung ke NotificationModal
- **Auto-schedule meal reminders**: Notifikasi makan dijadwalkan otomatis saat login
- **Email templates**: 6 template HTML custom (Confirm Sign Up, Invite, Magic Link, Change Email, Reset Password, Reauthentication)

### Changed — Frontend
- **OTP screen**: 6 digit input (dari 8), `PopScope` + konfirmasi dialog + signOut saat back
- **Auth listener**: Skip auto-navigate jika `emailConfirmedAt == null`
- **Splash screen**: SignOut user dengan email belum verified
- **Home header**: Notification button dipindah ke sebelah help button (pojok kanan atas)
- **Calendar picker**: Tambah `startMode` parameter, `SelectionMode` jadi public enum
- **History screen**: Refresh otomatis saat buka tab + app resume
- **Edit profile**: Target weight sekarang editable (TextEditingController), DOB range (now-80 s/d now-10), save button aktif saat birthDate/targetWeight berubah. Birth date disimpan via SharedPreferences. Photo upload non-blocking.
- **Komunitas**: Follow button disembunyikan untuk post sendiri (`isOwnPost` check). Search users modal. Navigate to post detail & user profile.

### Changed — Infrastructure
- **SMTP**: Dari Supabase default (3/jam) → Resend SMTP (100/hari gratis)
- **Email templates**: Dari default Supabase → Custom HTML dengan branding Nutrify + logo

### Fixed — Frontend (2 Mei)
- **OTP bypass bug**: User bisa masuk app tanpa verifikasi email (3 layer fix)
- **Save button disabled**: Setelah ganti tanggal lahir di edit profile
- **Target weight readonly**: Field sekarang bisa diedit
- **History stale data**: Data tidak refresh setelah tambah makanan
- **Self-follow**: User bisa follow diri sendiri di komunitas
- **Community notification**: Tombol notifikasi tidak melakukan apa-apa
- **Timezone notification**: Meal reminders tidak muncul karena timezone belum di-set (Asia/Jakarta)
- **Auth interceptor 401**: Session expired tidak handle signOut
- **Google Sign-In**: `Unacceptable audience in id_token` — sinkronisasi Client ID

### Fixed — Frontend (3 Mei)
- **Birth date always saves as Jan 1, year+1**: Backend only stores age (integer). Fixed by persisting actual birthDate in SharedPreferences as ISO8601 string
- **Save button disabled after photo change**: `_hasChanges` getter now includes `|| _isPhotoChanged`
- **Photo upload 404 blocking save**: Photo upload wrapped in separate try/catch — profile data saves first, photo failure shows specific SnackBar

---

## 5. Status Infrastruktur & Konfigurasi

### VPS
- **Host:** `103.253.212.55`
- **Path:** `/var/www/nutrify-app/`
- **Backend:** Laravel (PHP 8.2, Nginx, PostgreSQL via Supabase)
- **Domain:** `nutrify-app.my.id` + `nutrify-app.web.id`

### Supabase
- **Project:** `goifacmbmwmbwxgyqmtk`
- **Auth providers:** Email (OTP), Google OAuth
- **Custom SMTP:** Resend (`smtp.resend.com:587`)
- **Email templates:** 6 custom HTML templates
- **Confirm email:** ENABLED

### Resend
- **Domain:** `nutrify-app.web.id` (verified)
- **DNS records:** SPF, DKIM, DMARC — perlu dicek semua ✅
- **Free tier:** 100 email/hari

### Google OAuth
- **Web Client ID:** `764028839897-vmbicv6s24itto9pblpi5bi5dm2jt7bv.apps.googleusercontent.com`
- **Configured in:** Supabase Google Provider + Flutter `.env`

### Email Template Logo
- **URL:** `https://nutrify-app.my.id/logo.png`
- **Source:** `frontend/assets/images/nutrify-logo.png`
- **Upload:** SCP ke `/var/www/nutrify-app/backend/public/logo.png`

---

## 6. File yang Diubah Hari Ini

### Backend (Laravel)
| File | Aksi | Keterangan |
|------|------|------------|
| `database/migrations/2026_05_02_000005_create_otps_table.php` | NEW | Migration tabel otps |
| `database/migrations/2026_05_02_000006_add_community_fields_to_users_table.php` | NEW | +username, avatar, fcm_token, account_type ke users |
| `database/migrations/2026_05_02_000007_create_follows_table.php` | NEW | Tabel follows (follower_id, following_id) |
| `database/migrations/2026_05_03_000001_add_photo_to_profiles_table.php` | NEW | +photo column ke profiles |
| `app/Models/Otp.php` | NEW | Model Otp |
| `app/Models/Follow.php` | NEW | Model Follow |
| `app/Http/Controllers/Api/OtpController.php` | NEW | Controller send/verify OTP |
| `app/Http/Controllers/Api/FollowController.php` | NEW | Controller follow system |
| `app/Models/User.php` | MODIFIED | +fillables, +relations, +follow helpers |
| `app/Models/Profile.php` | MODIFIED | +'photo' ke fillable |
| `app/Http/Controllers/Api/ProfileController.php` | MODIFIED | +photo() method, +photo_url di show() |
| `app/Http/Controllers/Api/PostController.php` | MODIFIED | Enhanced formatPost, upload limit 10MB |
| `app/Mail/OtpMail.php` | NEW | Mailable class |
| `resources/views/emails/otp.blade.php` | NEW | Blade template email OTP |
| `routes/api.php` | MODIFIED | +8 route baru (OTP, follow, profile photo, username, account-type) |

### Frontend (Flutter)
| File | Aksi | Keterangan |
|------|------|------------|
| `lib/screens/post_detail_screen.dart` | NEW | Twitter/Threads style post detail |
| `lib/screens/user_profile_screen.dart` | NEW | User profile dengan follow button |
| `lib/screens/otp_verification_screen.dart` | MODIFIED | 6 digit, auto-paste, PopScope protection |
| `lib/presentation/my_app.dart` | MODIFIED | OTP bypass fix, auto-schedule notifications |
| `lib/screens/splash_screen.dart` | MODIFIED | Email confirmation check |
| `lib/screens/home_screen.dart` | MODIFIED | Notification button repositioned |
| `lib/screens/history_screen.dart` | MODIFIED | Auto-refresh, SelectionMode import |
| `lib/screens/edit_profile_screen.dart` | MODIFIED | Birth date fix, save button fix, non-blocking photo upload |
| `lib/screens/komunitas_screen.dart` | MODIFIED | Search users, user profile nav, follow via API, post detail nav |
| `lib/screens/add_post_screen.dart` | MODIFIED | Camera option, character limit 1000 |
| `lib/screens/profile_screen.dart` | MODIFIED | Profile photo from API (photoUrl) |
| `lib/screens/main_navigation_screen.dart` | MODIFIED | History auto-refresh on tab switch |
| `lib/domain/entity/post/community_post.dart` | MODIFIED | +authorUsername, +authorSupabaseId, isOwnPost UUID comparison |
| `lib/services/community_post_api_service.dart` | MODIFIED | +toggleFollow, +getUserProfile, +searchUsers |
| `lib/services/profile_api_service.dart` | MODIFIED | +photoUrl field, parse from API |
| `lib/widgets/nutrify_calendar_picker.dart` | MODIFIED | `startMode` param, `SelectionMode` public |
| `lib/core/data/network/dio/interceptors/auth_interceptor.dart` | MODIFIED | 401 signOut handling |
| `lib/services/notification_service.dart` | MODIFIED | Timezone fix (Asia/Jakarta) |
| `lib/data/repository/user/user_repository_impl.dart` | MODIFIED | Debug prints cleanup |

### Dokumentasi & Config
| File | Aksi | Keterangan |
|------|------|------------|
| `templates.md` | NEW | 6 email template HTML |
| `guide_brevo_smtp.md` | NEW | Guide Brevo SMTP (arsip) |
| `guide_update_vps.md` | MODIFIED | Update dengan OTP + resources SCP |
| `guide_deploy_komunitas.md` | NEW | Guide deploy komunitas + follow + profile photo |
| `sprint2_report.md` | MODIFIED | Update progress |
| `docs_02_mei.md` | MODIFIED | Dokumentasi ini |
| `backend_progres2.md` | MODIFIED | Update task status |

---

## 7. Yang Masih Perlu Dikerjakan

### Sprint 2 — Belum Selesai

| ID | Item | Catatan |
|----|------|---------|
| BE-S2-08 | Validasi batas wajar input | Min/max untuk tinggi, berat, umur → quick win, ~15 menit |
| BE-S2-09 | Backend notifikasi | ⚠️ PARTIAL — fcm_token field sudah ada (via migration 000006). Tersisa: notification table, NotificationController, FCM push triggers |

### Post-Sprint 2 — Frontend (belum ada backend blocker)

| Item | Catatan |
|------|---------|
| Username UI | Backend API siap (PUT /username), belum ada UI di Flutter |
| Account type toggle | Backend API siap (PUT /account-type), belum ada UI di Flutter |
| Avatar in comments | Backend CommentItem belum return avatar_url |

### Sprint 2 — Perlu Verifikasi

| Item | Catatan |
|------|---------|
| Supabase OTP digit | Pastikan Supabase mengirim 6 digit OTP. Jika 8 digit, set `GOTRUE_MAILER_OTP_LENGTH=6` di config |
| Resend DNS records | Cek SPF, DKIM, DMARC semua ✅ di Resend Dashboard |
| Logo di email | SCP logo ke VPS: `scp nutrify-logo.png root@103.253.212.55:/var/www/nutrify-app/backend/public/logo.png` |
| Email masuk spam | User perlu klik "Bukan spam" di Gmail untuk melatih filter |

### Post-Sprint 2

| Item | Prioritas |
|------|-----------|
| FE-S2-04: Help screen redesign (sesuai desain Card Panduan.png) | Medium |
| FE-S2-05: Favorit & Rekomendasi UI di Add Meal Screen | Medium |
| FS-01: Update Food Log (PUT endpoint) | Medium |
| FS-03: Push Notification pengingat makan → sudah implementasi, perlu QA | Done |
| QA-02: Testing Sprint 1 & 2 menyeluruh | High |

---

*Dokumen ini diupdate pada 3 Mei 2026 oleh Ibnu Habib.*

---

*Dokumen ini dibuat pada 2 Mei 2026 oleh Ibnu Habib.*
