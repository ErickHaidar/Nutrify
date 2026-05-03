# Guide Setup Firebase untuk Nutrify

## Apa yang Perlu Disiapkan:

### 1. Firebase Project
- Buat project baru di Firebase Console
- Tambah Android app
- Download 2 file penting

### 2. File yang Diperlukan:

#### A. google-services.json (Untuk Frontend/Flutter)
- Dipakai oleh Flutter app
- Berisi config Firebase untuk Android

#### B. service-account.json (Untuk Backend/Laravel)
- Dipakai oleh Laravel untuk kirim push notification
- Berisi kredensial untuk akses Firebase FCM

---

## Cara Setup Firebase:

### STEP 1: Buat Firebase Project
1. Buka: https://console.firebase.google.com
2. Klik "Add project" atau "Create a project"
3. Project name: `Nutrify` (atau nama lain)
4. Pilih/disable Google Analytics (boleh disable dulu)
5. Klik "Create project"

### STEP 2: Tambah Android App
1. Di Firebase Console, klik Android icon
2. Package name: `com.nutrifier.app` (sesuai flutter app)
3. Download `google-services.json`
4. Simpan di: `frontend/android/app/`

### STEP 3: Download Service Account
1. Buka: Project Settings → Service Accounts
2. Klik "Generate new private key"
3. Download JSON file
4. Rename jadi: `firebase-credentials.json`
5. Simpan di: `backend/storage/app/

### STEP 4: Setup Backend
- Install package FCM
- Konfigurasi .env
- Test kirim notifikasi

---

## Penting:
- JANGAN share firebase-credentials.json ke GitHub!
- File ini mengandung kredensial rahasia
- Tambah ke .gitignore
