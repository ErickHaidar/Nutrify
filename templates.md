# Supabase Email Templates — Nutrify

> Salin HTML dari setiap template ke Supabase Dashboard → Authentication → Email Templates

---

## 1. Confirm Sign Up

### Subject
```
Verifikasi Email Anda — Nutrify 🌱
```

### Body
```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body style="margin:0;padding:0;background-color:#f9f5f0;font-family:'Segoe UI',Tahoma,Geneva,Verdana,sans-serif;">
  <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="background-color:#f9f5f0;padding:40px 0;">
    <tr>
      <td align="center">
        <table role="presentation" width="500" cellspacing="0" cellpadding="0" style="background-color:#ffffff;border-radius:16px;overflow:hidden;box-shadow:0 4px 24px rgba(0,0,0,0.08);">

          <!-- Header -->
          <tr>
            <td align="center" style="background:linear-gradient(135deg,#4A446F,#6B6594);padding:40px 30px 30px;">
              <img src="https://nutrify-app.my.id/logo.png" alt="Nutrify" style="height:56px;margin-bottom:10px;" />
              <p style="margin:0;color:rgba(255,255,255,0.85);font-size:14px;">Pantau kalori Anda. Pantau hidup Anda.</p>
            </td>
          </tr>

          <!-- Body -->
          <tr>
            <td style="padding:36px 40px;">
              <h2 style="margin:0 0 8px;color:#4A446F;font-size:22px;">Halo! Selamat Datang 👋</h2>
              <p style="margin:0 0 20px;color:#555;font-size:15px;line-height:1.6;">
                Terima kasih sudah mendaftar di <strong>Nutrify</strong>! Kami sangat senang Anda bergabung.
                Untuk mulai menggunakan akun Anda, silakan masukkan kode verifikasi berikut:
              </p>

              <!-- OTP Code -->
              <table role="presentation" width="100%" cellspacing="0" cellpadding="0">
                <tr>
                  <td align="center" style="padding:20px 0;">
                    <div style="background:linear-gradient(135deg,#FFF5EB,#FFECD2);border-radius:12px;padding:24px;display:inline-block;min-width:280px;">
                      <p style="margin:0 0 4px;color:#888;font-size:12px;text-transform:uppercase;letter-spacing:2px;">Kode Verifikasi Anda</p>
                      <p style="margin:0;font-size:36px;font-weight:800;color:#4A446F;letter-spacing:10px;font-family:'Courier New',monospace;">{{ .Token }}</p>
                    </div>
                  </td>
                </tr>
              </table>

              <p style="margin:16px 0 0;color:#555;font-size:15px;line-height:1.6;">
                Masukkan kode 6 digit ini di aplikasi Nutrify Anda. Kode ini berlaku selama <strong>24 jam</strong>.
              </p>

              <!-- Divider -->
              <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="margin:24px 0;">
                <tr>
                  <td style="border-top:1px solid #eee;"></td>
                </tr>
              </table>

              <p style="margin:0;color:#999;font-size:13px;line-height:1.5;">
                <strong style="color:#777;">⚠️ Penting:</strong> Jangan bagikan kode ini kepada siapa pun, termasuk pihak yang mengaku dari Nutrify. Jika Anda tidak mendaftar di Nutrify, Anda bisa mengabaikan email ini sepenuhnya.
              </p>
            </td>
          </tr>

          <!-- Footer -->
          <tr>
            <td style="background-color:#f9f5f0;padding:24px 40px;text-align:center;">
              <p style="margin:0;color:#aaa;font-size:12px;line-height:1.5;">
                © 2026 Nutrify. Semua hak dilindungi.<br>
                Email ini dikirim secara otomatis, mohon tidak membalas email ini.
              </p>
            </td>
          </tr>

        </table>
      </td>
    </tr>
  </table>
</body>
</html>
```

---

## 2. Invite User

### Subject
```
Anda Diundang ke Nutrify! 🎉
```

### Body
```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body style="margin:0;padding:0;background-color:#f9f5f0;font-family:'Segoe UI',Tahoma,Geneva,Verdana,sans-serif;">
  <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="background-color:#f9f5f0;padding:40px 0;">
    <tr>
      <td align="center">
        <table role="presentation" width="500" cellspacing="0" cellpadding="0" style="background-color:#ffffff;border-radius:16px;overflow:hidden;box-shadow:0 4px 24px rgba(0,0,0,0.08);">

          <!-- Header -->
          <tr>
            <td align="center" style="background:linear-gradient(135deg,#4A446F,#6B6594);padding:40px 30px 30px;">
              <img src="https://nutrify-app.my.id/logo.png" alt="Nutrify" style="height:56px;margin-bottom:10px;" />
              <p style="margin:0;color:rgba(255,255,255,0.85);font-size:14px;">Pantau kalori Anda. Pantau hidup Anda.</p>
            </td>
          </tr>

          <!-- Body -->
          <tr>
            <td style="padding:36px 40px;">
              <h2 style="margin:0 0 8px;color:#4A446F;font-size:22px;">🎉 Anda Mendapat Undangan!</h2>
              <p style="margin:0 0 20px;color:#555;font-size:15px;line-height:1.6;">
                Seseorang telah mengundang Anda untuk bergabung di <strong>Nutrify</strong> — aplikasi pintar untuk memantau asupan gizi dan kalori harian Anda.
              </p>

              <p style="margin:0 0 24px;color:#555;font-size:15px;line-height:1.6;">
                Dengan Nutrify, Anda bisa:
              </p>

              <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="margin:0 0 24px;">
                <tr>
                  <td style="padding:6px 0;color:#4A446F;font-size:14px;">✅ &nbsp;Melacak kalori &amp; nutrisi harian</td>
                </tr>
                <tr>
                  <td style="padding:6px 0;color:#4A446F;font-size:14px;">✅ &nbsp;Mendapat rekomendasi makanan sehat</td>
                </tr>
                <tr>
                  <td style="padding:6px 0;color:#4A446F;font-size:14px;">✅ &nbsp;Berbagi pengalaman di komunitas</td>
                </tr>
                <tr>
                  <td style="padding:6px 0;color:#4A446F;font-size:14px;">✅ &nbsp;Mencatat 1.800+ makanan Indonesia</td>
                </tr>
              </table>

              <!-- CTA Button -->
              <table role="presentation" width="100%" cellspacing="0" cellpadding="0">
                <tr>
                  <td align="center" style="padding:8px 0;">
                    <a href="{{ .ConfirmationURL }}" style="display:inline-block;background:linear-gradient(135deg,#4A446F,#6B6594);color:#ffffff;text-decoration:none;padding:14px 40px;border-radius:10px;font-size:16px;font-weight:600;">Terima Undangan</a>
                  </td>
                </tr>
              </table>

              <p style="margin:20px 0 0;color:#999;font-size:13px;line-height:1.5;">
                Tautan ini bersifat pribadi dan hanya berlaku untuk Anda. Jika Anda tidak mengharapkan undangan ini, Anda bisa mengabaikan email ini dengan aman.
              </p>
            </td>
          </tr>

          <!-- Footer -->
          <tr>
            <td style="background-color:#f9f5f0;padding:24px 40px;text-align:center;">
              <p style="margin:0;color:#aaa;font-size:12px;line-height:1.5;">
                © 2026 Nutrify. Semua hak dilindungi.<br>
                Email ini dikirim secara otomatis, mohon tidak membalas email ini.
              </p>
            </td>
          </tr>

        </table>
      </td>
    </tr>
  </table>
</body>
</html>
```

---

## 3. Magic Link

### Subject
```
Tautan Login Nutrify Anda 🔗
```

### Body
```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body style="margin:0;padding:0;background-color:#f9f5f0;font-family:'Segoe UI',Tahoma,Geneva,Verdana,sans-serif;">
  <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="background-color:#f9f5f0;padding:40px 0;">
    <tr>
      <td align="center">
        <table role="presentation" width="500" cellspacing="0" cellpadding="0" style="background-color:#ffffff;border-radius:16px;overflow:hidden;box-shadow:0 4px 24px rgba(0,0,0,0.08);">

          <!-- Header -->
          <tr>
            <td align="center" style="background:linear-gradient(135deg,#4A446F,#6B6594);padding:40px 30px 30px;">
              <img src="https://nutrify-app.my.id/logo.png" alt="Nutrify" style="height:56px;margin-bottom:10px;" />
              <p style="margin:0;color:rgba(255,255,255,0.85);font-size:14px;">Pantau kalori Anda. Pantau hidup Anda.</p>
            </td>
          </tr>

          <!-- Body -->
          <tr>
            <td style="padding:36px 40px;">
              <h2 style="margin:0 0 8px;color:#4A446F;font-size:22px;">Klik untuk Langsung Masuk ✨</h2>
              <p style="margin:0 0 24px;color:#555;font-size:15px;line-height:1.6;">
                Kami menerima permintaan login untuk akun Anda. Tidak perlu memasukkan password — cukup klik tombol di bawah ini untuk langsung masuk ke Nutrify:
              </p>

              <!-- CTA Button -->
              <table role="presentation" width="100%" cellspacing="0" cellpadding="0">
                <tr>
                  <td align="center" style="padding:8px 0;">
                    <a href="{{ .ConfirmationURL }}" style="display:inline-block;background:linear-gradient(135deg,#4A446F,#6B6594);color:#ffffff;text-decoration:none;padding:14px 40px;border-radius:10px;font-size:16px;font-weight:600;">Masuk ke Nutrify</a>
                  </td>
                </tr>
              </table>

              <p style="margin:24px 0 0;color:#999;font-size:13px;line-height:1.5;">
                <strong style="color:#777;">⏰ Tautan ini berlaku sementara.</strong> Jika tidak digunakan dalam waktu tertentu, Anda perlu meminta tautan baru. Jika Anda tidak meminta login ini, abaikan email ini — akun Anda tetap aman.
              </p>
            </td>
          </tr>

          <!-- Footer -->
          <tr>
            <td style="background-color:#f9f5f0;padding:24px 40px;text-align:center;">
              <p style="margin:0;color:#aaa;font-size:12px;line-height:1.5;">
                © 2026 Nutrify. Semua hak dilindungi.<br>
                Email ini dikirim secara otomatis, mohon tidak membalas email ini.
              </p>
            </td>
          </tr>

        </table>
      </td>
    </tr>
  </table>
</body>
</html>
```

---

## 4. Change Email Address

### Subject
```
Konfirmasi Perubahan Email — Nutrify 📧
```

### Body
```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body style="margin:0;padding:0;background-color:#f9f5f0;font-family:'Segoe UI',Tahoma,Geneva,Verdana,sans-serif;">
  <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="background-color:#f9f5f0;padding:40px 0;">
    <tr>
      <td align="center">
        <table role="presentation" width="500" cellspacing="0" cellpadding="0" style="background-color:#ffffff;border-radius:16px;overflow:hidden;box-shadow:0 4px 24px rgba(0,0,0,0.08);">

          <!-- Header -->
          <tr>
            <td align="center" style="background:linear-gradient(135deg,#4A446F,#6B6594);padding:40px 30px 30px;">
              <img src="https://nutrify-app.my.id/logo.png" alt="Nutrify" style="height:56px;margin-bottom:10px;" />
              <p style="margin:0;color:rgba(255,255,255,0.85);font-size:14px;">Pantau kalori Anda. Pantau hidup Anda.</p>
            </td>
          </tr>

          <!-- Body -->
          <tr>
            <td style="padding:36px 40px;">
              <h2 style="margin:0 0 8px;color:#4A446F;font-size:22px;">Konfirmasi Perubahan Email 📧</h2>
              <p style="margin:0 0 20px;color:#555;font-size:15px;line-height:1.6;">
                Kami menerima permintaan untuk mengubah email akun Nutrify Anda:
              </p>

              <!-- Email Change Info -->
              <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="margin:0 0 24px;">
                <tr>
                  <td style="background:#FFF5EB;border-radius:10px;padding:16px 20px;">
                    <table role="presentation" width="100%" cellspacing="0" cellpadding="0">
                      <tr>
                        <td style="padding:4px 0;font-size:14px;color:#888;">Email lama</td>
                        <td style="padding:4px 0;font-size:14px;color:#4A446F;font-weight:600;text-align:right;">{{ .Email }}</td>
                      </tr>
                      <tr>
                        <td colspan="2" style="padding:8px 0;"><div style="border-top:1px dashed #ddd;"></div></td>
                      </tr>
                      <tr>
                        <td style="padding:4px 0;font-size:14px;color:#888;">Email baru</td>
                        <td style="padding:4px 0;font-size:14px;color:#4A446F;font-weight:600;text-align:right;">{{ .NewEmail }}</td>
                      </tr>
                    </table>
                  </td>
                </tr>
              </table>

              <p style="margin:0 0 24px;color:#555;font-size:15px;line-height:1.6;">
                Jika ini benar-benar permintaan Anda, klik tombol di bawah untuk mengonfirmasi perubahan:
              </p>

              <!-- CTA Button -->
              <table role="presentation" width="100%" cellspacing="0" cellpadding="0">
                <tr>
                  <td align="center" style="padding:8px 0;">
                    <a href="{{ .ConfirmationURL }}" style="display:inline-block;background:linear-gradient(135deg,#4A446F,#6B6594);color:#ffffff;text-decoration:none;padding:14px 40px;border-radius:10px;font-size:16px;font-weight:600;">Konfirmasi Perubahan</a>
                  </td>
                </tr>
              </table>

              <p style="margin:20px 0 0;color:#999;font-size:13px;line-height:1.5;">
                <strong style="color:#777;">⚠️ Penting:</strong> Jika Anda tidak meminta perubahan ini, segera ubah password Anda dan abaikan email ini. Akun Anda tetap aman selama Anda tidak mengklik tautan di atas.
              </p>
            </td>
          </tr>

          <!-- Footer -->
          <tr>
            <td style="background-color:#f9f5f0;padding:24px 40px;text-align:center;">
              <p style="margin:0;color:#aaa;font-size:12px;line-height:1.5;">
                © 2026 Nutrify. Semua hak dilindungi.<br>
                Email ini dikirim secara otomatis, mohon tidak membalas email ini.
              </p>
            </td>
          </tr>

        </table>
      </td>
    </tr>
  </table>
</body>
</html>
```

---

## 5. Reset Password

### Subject
```
Atur Ulang Password Nutrify Anda 🔐
```

### Body
```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body style="margin:0;padding:0;background-color:#f9f5f0;font-family:'Segoe UI',Tahoma,Geneva,Verdana,sans-serif;">
  <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="background-color:#f9f5f0;padding:40px 0;">
    <tr>
      <td align="center">
        <table role="presentation" width="500" cellspacing="0" cellpadding="0" style="background-color:#ffffff;border-radius:16px;overflow:hidden;box-shadow:0 4px 24px rgba(0,0,0,0.08);">

          <!-- Header -->
          <tr>
            <td align="center" style="background:linear-gradient(135deg,#4A446F,#6B6594);padding:40px 30px 30px;">
              <img src="https://nutrify-app.my.id/logo.png" alt="Nutrify" style="height:56px;margin-bottom:10px;" />
              <p style="margin:0;color:rgba(255,255,255,0.85);font-size:14px;">Pantau kalori Anda. Pantau hidup Anda.</p>
            </td>
          </tr>

          <!-- Body -->
          <tr>
            <td style="padding:36px 40px;">
              <h2 style="margin:0 0 8px;color:#4A446F;font-size:22px;">Lupa Password? Tidak Masalah 😊</h2>
              <p style="margin:0 0 24px;color:#555;font-size:15px;line-height:1.6;">
                Kami menerima permintaan untuk mengatur ulang password akun Nutrify Anda. Klik tombol di bawah ini untuk membuat password baru:
              </p>

              <!-- CTA Button -->
              <table role="presentation" width="100%" cellspacing="0" cellpadding="0">
                <tr>
                  <td align="center" style="padding:8px 0;">
                    <a href="{{ .ConfirmationURL }}" style="display:inline-block;background:linear-gradient(135deg,#4A446F,#6B6594);color:#ffffff;text-decoration:none;padding:14px 40px;border-radius:10px;font-size:16px;font-weight:600;">Atur Ulang Password</a>
                  </td>
                </tr>
              </table>

              <!-- Divider -->
              <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="margin:24px 0;">
                <tr>
                  <td style="border-top:1px solid #eee;"></td>
                </tr>
              </table>

              <p style="margin:0 0 12px;color:#999;font-size:13px;line-height:1.5;">
                <strong style="color:#777;">⏰ Tautan ini berlaku sementara</strong> dan hanya bisa digunakan sekali. Jika kedaluwarsa, Anda bisa meminta tautan baru dari aplikasi.
              </p>

              <p style="margin:0;color:#999;font-size:13px;line-height:1.5;">
                <strong style="color:#777;">🔐 Tip Keamanan:</strong> Jika Anda tidak meminta pengaturan ulang password, email ini bisa diabaikan dengan aman. Password Anda tidak akan berubah kecuali Anda mengklik tautan di atas.
              </p>
            </td>
          </tr>

          <!-- Footer -->
          <tr>
            <td style="background-color:#f9f5f0;padding:24px 40px;text-align:center;">
              <p style="margin:0;color:#aaa;font-size:12px;line-height:1.5;">
                © 2026 Nutrify. Semua hak dilindungi.<br>
                Email ini dikirim secara otomatis, mohon tidak membalas email ini.
              </p>
            </td>
          </tr>

        </table>
      </td>
    </tr>
  </table>
</body>
</html>
```

---

## 6. Reauthentication

### Subject
```
Kode Konfirmasi — Nutrify 🔐
```

### Body
```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body style="margin:0;padding:0;background-color:#f9f5f0;font-family:'Segoe UI',Tahoma,Geneva,Verdana,sans-serif;">
  <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="background-color:#f9f5f0;padding:40px 0;">
    <tr>
      <td align="center">
        <table role="presentation" width="500" cellspacing="0" cellpadding="0" style="background-color:#ffffff;border-radius:16px;overflow:hidden;box-shadow:0 4px 24px rgba(0,0,0,0.08);">

          <!-- Header -->
          <tr>
            <td align="center" style="background:linear-gradient(135deg,#4A446F,#6B6594);padding:40px 30px 30px;">
              <img src="https://nutrify-app.my.id/logo.png" alt="Nutrify" style="height:56px;margin-bottom:10px;" />
              <p style="margin:0;color:rgba(255,255,255,0.85);font-size:14px;">Pantau kalori Anda. Pantau hidup Anda.</p>
            </td>
          </tr>

          <!-- Body -->
          <tr>
            <td style="padding:36px 40px;">
              <h2 style="margin:0 0 8px;color:#4A446F;font-size:22px;">Konfirmasi Identitas Anda 🔐</h2>
              <p style="margin:0 0 20px;color:#555;font-size:15px;line-height:1.6;">
                Untuk keamanan akun Anda, kami perlu memastikan bahwa ini benar-benar Anda. Masukkan kode berikut di aplikasi Nutrify:
              </p>

              <!-- OTP Code -->
              <table role="presentation" width="100%" cellspacing="0" cellpadding="0">
                <tr>
                  <td align="center" style="padding:20px 0;">
                    <div style="background:linear-gradient(135deg,#FFF5EB,#FFECD2);border-radius:12px;padding:24px;display:inline-block;min-width:280px;">
                      <p style="margin:0 0 4px;color:#888;font-size:12px;text-transform:uppercase;letter-spacing:2px;">Kode Konfirmasi</p>
                      <p style="margin:0;font-size:36px;font-weight:800;color:#4A446F;letter-spacing:10px;font-family:'Courier New',monospace;">{{ .Token }}</p>
                    </div>
                  </td>
                </tr>
              </table>

              <p style="margin:16px 0 0;color:#999;font-size:13px;line-height:1.5;">
                <strong style="color:#777;">⚠️ Jangan bagikan</strong> kode ini kepada siapa pun. Jika Anda tidak meminta kode ini, segera ubah password Anda.
              </p>
            </td>
          </tr>

          <!-- Footer -->
          <tr>
            <td style="background-color:#f9f5f0;padding:24px 40px;text-align:center;">
              <p style="margin:0;color:#aaa;font-size:12px;line-height:1.5;">
                © 2026 Nutrify. Semua hak dilindungi.<br>
                Email ini dikirim secara otomatis, mohon tidak membalas email ini.
              </p>
            </td>
          </tr>

        </table>
      </td>
    </tr>
  </table>
</body>
</html>
```

---

## Cara Pasang di Supabase

1. Buka **Supabase Dashboard** → **Authentication** → **Email Templates**
2. Pilih template (misal "Confirm signup")
3. Paste **Subject** ke field Subject
4. Paste **Body** (HTML) ke field Body
5. Klik **Save**
6. Ulangi untuk semua template lainnya

> **Yang paling penting:** Template **Confirm Sign Up** menggunakan `{{ .Token }}` untuk OTP code, bukan `{{ .ConfirmationURL }}`. Pastikan ini benar agar OTP 6 digit dikirim, bukan link konfirmasi.
