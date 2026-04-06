# Panduan Setup Anggota Tim (Nutrify)

Halo Tim! Jika Anda baru saja menarik (pull) kode dari Git, ikuti langkah-langkah ini agar project bisa berjalan di laptop Anda.

## 1. Persiapan File Rahasia (.env)
Karena file `.env` diabaikan oleh Git, Anda harus meminta isi file `.env` kepada **Erick** dan buat file baru bernama `.env` di folder `frontend/`.

## 2. Instalasi & Generate Kode
Jalankan perintah berikut secara berurutan di terminal folder `frontend/`:
```powershell
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

## 3. Registrasi Google Login (SHA-1)
Agar fitur **Login Google** tidak error di laptop Anda, Erick harus mendaftarkan SHA-1 laptop Anda ke Google Cloud Console.
1. Buka folder `frontend/android/` di terminal.
2. Jalankan: `.\gradlew signingReport`
3. Cari bagian **Variant: debug**, salin kode **SHA1**-nya, dan kirim ke Erick.

## 4. Troubleshooting
Jika ada error terkait `signingConfig`, jangan khawatir. File `key.properties` hanya dibutuhkan untuk rilis ke Play Store. Untuk development di emulator/HP debug, aplikasi akan otomatis menggunakan kunci debug bawaan laptop Anda.
