# Sprint 3 Deployment — 1 Juni 2026

VPS: `root@103.253.212.55`, path: `/var/www/nutrify-app-app/`

## Ringkasan Perubahan

| Kategori | File | Status |
|----------|------|--------|
| **Auth (Google Sign-In fix)** | `frontend/lib/presentation/login/login.dart`, `login_store.dart` | Modified |
| **Search (case-insensitive)** | `backend/app/Http/Controllers/Api/FollowController.php` | Modified |
| **Content moderation (report)** | `backend/app/Http/Controllers/Api/PostController.php`, `PostReport.php`, 2 migrations | New |
| **Progress chart API** | `backend/app/Http/Controllers/Api/ProgressController.php`, `WeightLog.php`, 1 migration | Modified |
| **Dataset enrichment** | `ImportFoods.php`, `CleanFoods.php`, `Food.php`, `StudentFoodSeeder.php`, 1 migration | New |
| **Routes** | `backend/routes/api.php` | Modified |
| **Auth messages (ID)** | `backend/app/Http/Middleware/VerifySupabaseToken.php` | Modified |

---

## Step 1: Upload Changed Backend Files

Jalankan dari folder project lokal (`C:\Users\Ibnu Habib\projects\prodhokter\Nutrify`):

```bash
# Modified files
scp backend/app/Http/Controllers/Api/FollowController.php root@103.253.212.55:/var/www/nutrify-app-app/backend/app/Http/Controllers/Api/FollowController.php
scp backend/app/Http/Controllers/Api/PostController.php root@103.253.212.55:/var/www/nutrify-app-app/backend/app/Http/Controllers/Api/PostController.php
scp backend/app/Http/Controllers/Api/ProgressController.php root@103.253.212.55:/var/www/nutrify-app-app/backend/app/Http/Controllers/Api/ProgressController.php
scp backend/app/Http/Middleware/VerifySupabaseToken.php root@103.253.212.55:/var/www/nutrify-app-app/backend/app/Http/Middleware/VerifySupabaseToken.php
scp backend/app/Models/Food.php root@103.253.212.55:/var/www/nutrify-app-app/backend/app/Models/Food.php
scp backend/app/Models/WeightLog.php root@103.253.212.55:/var/www/nutrify-app-app/backend/app/Models/WeightLog.php
scp backend/routes/api.php root@103.253.212.55:/var/www/nutrify-app-app/backend/routes/api.php

# New files
scp backend/app/Models/PostReport.php root@103.253.212.55:/var/www/nutrify-app-app/backend/app/Models/PostReport.php
scp backend/app/Console/Commands/CleanFoods.php root@103.253.212.55:/var/www/nutrify-app-app/backend/app/Console/Commands/CleanFoods.php
scp backend/app/Console/Commands/ImportFoods.php root@103.253.212.55:/var/www/nutrify-app-app/backend/app/Console/Commands/ImportFoods.php
scp backend/database/migrations/2026_06_01_000001_add_index_to_weight_logs_table.php root@103.253.212.55:/var/www/nutrify-app-app/backend/database/migrations/
scp backend/database/migrations/2026_06_01_000002_create_post_reports_table.php root@103.253.212.55:/var/www/nutrify-app-app/backend/database/migrations/
scp backend/database/migrations/2026_06_01_000003_add_hidden_to_posts_table.php root@103.253.212.55:/var/www/nutrify-app-app/backend/database/migrations/
scp backend/database/migrations/2026_06_01_000004_add_category_to_foods_table.php root@103.253.212.55:/var/www/nutrify-app-app/backend/database/migrations/
scp backend/database/seeders/StudentFoodSeeder.php root@103.253.212.55:/var/www/nutrify-app-app/backend/database/seeders/

# Dataset CSV (for import)
scp dataset_pipeline/output/foods_id_clean.csv root@103.253.212.55:/var/www/nutrify-app-app/dataset_pipeline/output/foods_id_clean.csv
```

---

## Step 2: Run on VPS

SSH ke VPS lalu jalankan:

```bash
ssh root@103.253.212.55
cd /var/www/nutrify-app-app/backend

# Set permissions
chown -R www-data:www-data /var/www/nutrify-app-app/

# Run new migrations
php artisan migrate --force

# Import cleaned dataset (2996 foods)
php artisan foods:import

# Optional: seed student foods tambahan
# php artisan db:seed --class=StudentFoodSeeder

# Clear all caches
php artisan optimize:clear
php artisan config:cache
php artisan route:cache
```

---

## Step 3: Verify

```bash
# Check routes
php artisan route:list | grep -E "validate|progress|report"

# Check food count
php artisan tinker --execute="echo \App\Models\Food::count();"

# Check migrations
php artisan migrate:status
```

Test endpoints:
- `POST /api/auth/validate` — token validation
- `POST /api/progress/weight` — save weight
- `GET /api/progress/calories?range=7d` — calorie history  
- `POST /api/posts/{id}/report` — report post

---

## Step 4: Frontend (Flutter)

Build APK baru dan upload ke VPS:

```bash
cd frontend
flutter build apk --release

# Upload ke VPS
scp build/app/outputs/flutter-apk/app-release.apk root@103.253.212.55:/var/www/nutrify-app-app/public/app-release.apk
```

Atau kalau Flutter SDK tidak terinstall di VPS, user download APK dari public URL.

---

## Catatan

- Dataset: **2,996 foods** (404 base foods, 1,312 local Indonesian, 257 beverages, 122 snacks)
- Nutrition coverage: 100% kalori, 95% protein/karbohidrat/lemak
- Pipeline AI menggunakan DeepSeek (`deepseek-chat`) via Anthropic-compatible API
- Semua error message sudah Bahasa Indonesia
- Content moderation: 3 report → auto-hide post
- Search sekarang case-insensitive (ILIKE)
