# Guide: Setup Brevo SMTP untuk Supabase OTP Email

> Untuk: Ibnu (Backend Developer)
> Tujuan: Supabase OTP email dikirim via Brevo (300/hari gratis) bukan Supabase default (3/jam)
> Terakhir diperbarui: 2 Mei 2026

---

## DAFTAR ISI

1. [Daftar Brevo](#1-daftar-brevo)
2. [Verifikasi Email di Brevo](#2-verifikasi-email-di-brevo)
3. [Buat SMTP Key](#3-buat-smtp-key)
4. [Konfigurasi Supabase](#4-konfigurasi-supabase)
5. [Test](#5-test)
6. [Troubleshooting](#6-troubleshooting)

---

## 1. Daftar Brevo

1. Buka https://www.brevo.com
2. Klik **"Sign Up Free"**
3. Isi form:
   - **Email**: pakai email yang mau jadi pengirim OTP (misal Gmail kamu)
   - **Password**: buat password baru untuk Brevo
   - **Nama**: isi bebas
4. Klik **"Sign Up"**
5. Brevo akan kirim **verification email** ke inbox kamu

---

## 2. Verifikasi Email di Brevo

1. Buka inbox email yang didaftarkan
2. Cari email dari Brevo
3. Klik link verifikasi
4. Setelah verified, login ke Brevo Dashboard

### Tambah Sender Email

1. Di Brevo Dashboard, klik **profile dropdown** (kanan atas)
2. Klik **"Senders, Domains & Dedicated IPs"**
3. Klik **"Add a Sender"**
4. Isi:
   - **Name**: `Nutrify`
   - **Email**: email kamu (misal `ibnuhabib@gmail.com`)
5. Klik **Save**
6. Brevo kirim verification email → klik link untuk verify

> Tanpa verifikasi sender, email tidak bisa dikirim.

---

## 3. Buat SMTP Key

1. Login ke Brevo Dashboard
2. Klik **profile dropdown** (kanan atas) → **"SMTP & API"**
3. Di tab **SMTP**, kamu akan melihat:
   - **Login**: email kamu
   - **SMTP Server**: `smtp-relay.brevo.com`
   - **Port**: `587`
4. Klik **"Generate a new SMTP key"**
5. Beri nama key: `nutrify-supabase`
6. Klik **Generate**
7. **COPY password/key yang muncul** → ini hanya ditampilkan sekali!

> Simpan key ini di tempat aman. Kalau lupa, harus generate ulang.

### Yang kamu butuhkan (catat ini):

```
Host:     smtp-relay.brevo.com
Port:     587
Username: email-kamu@gmail.com    ← email login Brevo
Password: xsmtpsib-xxxxxxxxxxxx   ← SMTP key yang baru digenerate
```

---

## 4. Konfigurasi Supabase

1. Buka **Supabase Dashboard** → https://supabase.com/dashboard
2. Pilih project **Nutrify**
3. Klik **Project Settings** (icon gear ⚙️ di sidebar kiri bawah)
4. Klik **Authentication** di submenu
5. Scroll ke bawah cari section **SMTP Settings**
6. **Enable** toggle "Enable Custom SMTP"
7. Isi form:

| Field | Value |
|-------|-------|
| **Host** | `smtp-relay.brevo.com` |
| **Port** | `587` |
| **Username** | email login Brevo kamu |
| **Password** | SMTP key dari step 3 |
| **Sender email** | email yang sudah diverifikasi di Brevo |
| **Sender name** | `Nutrify` |
| **Minimum interval** | biarkan default |
| **Enable SSL** | ✅ ON (atau "tls") |

8. Klik **Save**

> Supabase akan test koneksi. Kalau berhasil, akan muncul notifikasi sukses.

---

## 5. Test

### Test dari App Nutrify

1. Buka app Nutrify
2. Daftar akun baru dengan email yang belum terdaftar
3. Cek inbox → harus ada email OTP dari `Nutrify <email-kamu@gmail.com>`
4. Masukkan kode 6 digit → verifikasi

### Test via cURL (opsional)

```bash
# Di VPS atau lokal
curl -X POST https://nutrify-app.my.id/api/auth/send-otp \
  -H "Content-Type: application/json" \
  -d '{"email":"ibnuhabib017@gmail.com"}'
```

Cek inbox → kalau Brevo sudah terhubung dengan Laravel, email akan masuk.

### Cek Brevo Statistics

1. Login Brevo Dashboard
2. Klik **"Transactionals"** → **"Logs"**
3. Lihat log email yang terkirim

---

## 6. Troubleshooting

### Email tidak masuk

1. **Cek folder Spam/Junk** — sering masuk sana di awal
2. **Cek Brevo Logs** — Transactionals → Logs → apakah status "delivered" atau "bounced"
3. **Cek Supabase Logs** — Authentication → Logs → apakah email dikirim
4. **Tunggu 1-2 menit** — kadang ada delay

### Error "Sender not verified"

- Brevo Dashboard → Senders → pastikan email sender sudah verified
- Kalau belum, klik "Verify" dan cek inbox

### Error "Authentication failed"

- Cek username/password SMTP di Supabase
- Password = SMTP key (bukan password akun Brevo)
- Cek ada spasi atau karakter tersembunyi

### Error "Connection refused"

- Cek Host: `smtp-relay.brevo.com` (bukan yang lain)
- Cek Port: `587`
- Cek SSL enabled

### Gmail menolak

- Gmail kadang menolak email dari sender yang tidak dikenal
- Solusi: tambahkan domain khusus (opsional) atau coba kirim ke email non-Gmail dulu untuk test

---

## Cheat Sheet

```
Brevo Dashboard:    https://app.brevo.com
SMTP Host:          smtp-relay.brevo.com
SMTP Port:          587
Free Tier:          300 email/hari
SMTP Key Location:  Profile → SMTP & API → Generate new key
Sender Setup:       Profile → Senders, Domains & Dedicated IPs

Supabase SMTP:      Project Settings → Authentication → SMTP Settings
```
