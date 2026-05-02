<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
</head>
<body style="font-family: Arial, sans-serif; background-color: #f5f5f5; margin: 0; padding: 20px;">
    <div style="max-width: 480px; margin: 0 auto; background: #ffffff; border-radius: 16px; padding: 40px 32px; text-align: center;">
        <h1 style="color: #322E53; font-size: 24px; margin-bottom: 8px;">Nutrify</h1>
        <p style="color: #666; font-size: 14px; margin-bottom: 32px;">Kode Verifikasi Email Anda</p>

        <div style="background: #FAF1E8; border-radius: 12px; padding: 24px; margin-bottom: 24px;">
            <span style="font-size: 36px; font-weight: bold; letter-spacing: 8px; color: #322E53;">{{ $code }}</span>
        </div>

        <p style="color: #666; font-size: 13px; line-height: 1.6;">
            Masukkan kode ini di aplikasi Nutrify untuk memverifikasi email Anda.<br>
            Kode berlaku selama <strong>{{ $expiresInMinutes }} menit</strong>.
        </p>

        <p style="color: #999; font-size: 12px; margin-top: 32px;">
            Jika Anda tidak meminta kode ini, abaikan email ini.
        </p>
    </div>
</body>
</html>
