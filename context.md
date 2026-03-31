# Project Context: Nutrify - Sprint 1

## 🎯 Sprint Goal
Membuat login, register, dan autentikasi. Membuat fitur tracking kalori harian.

## 📌 Application Overview
Nutrify adalah aplikasi *mobile* untuk melacak asupan kalori dan makronutrisi harian pengguna secara personal berdasarkan target *body goals* masing-masing (Cutting, Maintenance, Bulking).

## 🏗️ Feature Scope & System Requirements
Berikut adalah ruang lingkup fitur dan logika bisnis yang mendefinisikan Sprint 1. Agen AI diharapkan menggunakan konteks ini untuk memahami relasi antar komponen dan melakukan pengecekan mandiri terhadap *codebase* untuk mengetahui status implementasi.

### 1. Authentication & Onboarding
* **User Flow:** Aplikasi dimulai dengan Splashscreen -> Onboarding (dengan opsi Skip/Next) -> halaman Login atau Register.
* **Backend Auth:** Implementasi pendaftaran dan masuk akun menggunakan Nama, Email, dan Password. Diperlukan *password hashing* (misal: bcrypt) dan *token generation* (misal: JWT) untuk keamanan sesi.

### 2. User Profiling & Kalkulasi Target
* **Input Data:** Aplikasi membutuhkan data profil pengguna meliputi Usia, Berat Badan (BB), Tinggi Badan (TB), Gender, dan Tingkat Aktivitas.
* **Body Goals:** Pengguna harus bisa memilih target diet: *Cutting*, *Maintenance*, atau *Bulking*.
* **Core Logic:** Sistem (Backend) harus menghitung BMI (Body Mass Index) dan TDEE (Total Daily Energy Expenditure) pengguna secara otomatis berdasarkan data profil menggunakan formula standar (Harris-Benedict / Mifflin-St Jeor).

### 3. Food Tracking & Database Schema
* **Database Architecture:** Skema database inti (*ERD*) harus mencakup tabel dan relasi untuk: `User`, `Profile`, `Food Dataset`, dan `Tracking` (riwayat konsumsi).
* **Dataset Makanan:** Sistem harus mengimpor dan menyediakan API pencarian (*search*) untuk dataset makanan yang mencakup informasi Makronutrisi (Kalori, Protein, Karbohidrat, Gula/Lemak).
* **Time-Based Grouping:** Pencatatan makanan harus dikategorikan berdasarkan waktu konsumsi: Pagi (*Breakfast*), Siang (*Lunch*), Malam (*Dinner*), dan Cemilan (*Snack*). Foreign key harus merelasikan entri ini ke `User` dan `Food`.
* **Manual Tracking (CRUD):** Fungsionalitas penuh (Create, Read, Update, Delete) untuk pengguna yang ingin mencatat nama makanan, kalori, dan makronutrisi secara manual ke dalam sistem.

### 4. Dashboard & Analytics (Home)
* **UI/UX Visualisasi:** Halaman utama (*Dashboard*) harus memiliki komponen visual seperti *Card*, *Chart*, dan *Progress Bar* untuk membandingkan akumulasi kalori & makro harian pengguna dengan target mereka.
* **Data Aggregation:** Tersedia API khusus untuk mengkalkulasi total kalori, protein, karbohidrat, dan lemak yang sudah dikonsumsi *user* pada hari tertentu secara *real-time*.
* **History UI:** Tampilan riwayat yang memungkinkan pengguna meninjau total kalori dan detail spesifik makanan yang dikonsumsi per tanggal harian.

### 5. UI/UX Components & Navigation
* **Navigation:** Aplikasi menggunakan *Bottom Navigation Bar* dengan menu utama: Home, Tracking, dan Profile.
* **Reusable Components:** Membutuhkan implementasi komponen UI yang terstandarisasi dan dapat digunakan kembali di seluruh halaman (seperti *Button*, *Input Field*, *Card*).
* **Research Context:** Desain dan fungsionalitas harus mempertimbangkan *pain points* dari pengguna terkait kebiasaan pencatatan kalori yang didapat dari riset pengguna.