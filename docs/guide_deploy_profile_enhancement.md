# Guide Deploy — Profile Enhancement (BMI WHO + Makronutrien)

> **VPS:** `103.253.212.55` | **Path:** `/var/www/nutrify-app/backend/`
> **Perubahan:** BMI 7 kategori WHO + kalkulasi makronutrien berdasarkan goal

---

## Step 1: SCP file ke VPS

```bash
scp "C:\Users\Ibnu Habib\Documents\pdbl\baru\Nutrify\backend\app\Http\Controllers\Api\ProfileController.php" root@103.253.212.55:/var/www/nutrify-app/backend/app/Http/Controllers/Api/ProfileController.php
```

## Step 2: SSH ke VPS

```bash
ssh root@103.253.212.55
```

## Step 3: Clear cache Laravel

```bash
cd /var/www/nutrify-app/backend
php artisan config:clear
php artisan cache:clear
```

## Step 4: Verifikasi

Test endpoint profile:

```bash
curl -s -X GET https://nutrify-app.my.id/api/profile \
  -H "Authorization: Bearer <token_anda>" | python3 -m json.tool | head -30
```

Pastikan response mengandung:
- `bmi_status` → format baru (misal "Normal", "Overweight", "Obesity Class I")
- `macronutrients` → object berisi `protein`, `carbohydrates`, `fat` masing-masing dengan `grams` dan `percent`

## Step 5: Cek log kalau error

```bash
tail -20 /var/www/nutrify-app/backend/storage/logs/laravel.log
```

---

*Dibuat pada 3 Mei 2026.*
