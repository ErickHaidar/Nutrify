# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Nutrify is a mobile nutrition tracking application built with Flutter (frontend) and Laravel 12 (backend). Users can track daily calorie and macronutrient intake based on personalized body goals (Cutting, Maintenance, Bulking). The app calculates BMI, BMR, and TDEE automatically using the Mifflin-St Jeor formula.

**Tech Stack:**
- **Frontend**: Flutter (Dart ≥ 3.8.0) with MobX state management
- **Backend**: Laravel 12 (PHP ≥ 8.2) with PostgreSQL local database
- **Authentication**: Supabase Auth (JWT) - login/register via Supabase, token verification via Laravel middleware using `firebase/php-jwt`
- **HTTP Client**: Dio for Flutter API calls
- **Database**: PostgreSQL local (localhost), NOT Supabase database

## Common Development Commands

### Backend (Laravel)
```bash
cd backend

# Install dependencies
composer install

# Run development server
php artisan serve

# Database migrations
php artisan migrate

# Seed food database (1651 Indonesian food items)
php artisan db:seed

# Run tests
php artisan test

# Clear cache
php artisan config:clear
php artisan cache:clear
```

### Frontend (Flutter)
```bash
cd frontend

# Install dependencies
flutter pub get

# Run app (connected device or emulator)
flutter run

# Build for Android
flutter build apk

# Run tests
flutter test

# Clean build cache
flutter clean
```

### Running the App (Daily Workflow)
Open 3 separate terminals:
1. `cd backend && php artisan serve` - Laravel API server on port 8000
2. `ngrok http 8000` - Tunnel for physical device testing (optional, skip for emulator)
3. `cd frontend && flutter run` - Flutter app

## Architecture

### Backend Architecture

**Database Schema:**
- `users` - user accounts with `supabase_id` for Supabase sync
- `profiles` - physical data (age, weight, height, gender, activity_level, goal)
- `foods` - 1651 Indonesian food items with nutritional info
- `food_logs` - user food consumption records (meal_time: Breakfast/Lunch/Dinner/Snack)
- `user_favorites`, `posts`, `post_likes`, `comments`, `otps` - Sprint 2 features

**Key Models:**
- `User.php` - extends Laravel's auth user with `supabase_id`
- `Profile.php` - physical profile with BMI/TDEE calculation
- `Food.php` - food database with nutrient casts (float)
- `FoodLog.php` - consumption records

**API Endpoints (all protected by Supabase JWT middleware):**
- `POST /api/profile/store` - Save/update profile
- `GET /api/profile` - Get profile with calculated BMI, BMR, TDEE, target calories
- `POST /api/profile/photo` - Upload profile photo
- `GET /api/foods?search=&page=` - Search food database
- `GET /api/food/recommendations` - Get food recommendations
- `POST /api/food-logs` - Log food consumption
- `GET /api/food-logs/summary` - Daily calorie & macro summary
- `GET /api/food-logs?date=` - Get food logs by date
- `DELETE /api/food-logs/{id}` - Delete food log
- `GET /api/food/favorites` - User's favorite foods
- `POST /api/food/favorites` - Add to favorites
- `DELETE /api/food/favorites/{food_id}` - Remove from favorites
- `GET /api/posts` - Community posts
- `POST /api/posts` - Create post
- `POST /api/posts/{id}/like` - Toggle like
- `GET /api/posts/{id}/comments` - Get comments
- `POST /api/posts/{id}/comments` - Add comment

**Authentication Flow:**
1. Flutter app calls Supabase Auth directly (`signInWithPassword()`, `signUp()`)
2. Supabase returns JWT access token
3. Flutter stores JWT and attaches it to Laravel API requests via `Authorization: Bearer` header
4. Laravel's `VerifySupabaseToken` middleware validates JWT using `SUPABASE_JWT_SECRET`
5. If valid, user is synced to Laravel `users` table via `supabase_id`

**Critical Middleware:**
- `VerifySupabaseToken` - Validates Supabase JWT using ES256 algorithm via JWKS

### Frontend Architecture

**Dual-Layer Architecture:**
The Flutter codebase has TWO architectural patterns:

**Layer 1 - Boilerplate Architecture (Clean Architecture + MobX):**
- Location: `lib/presentation/`, `lib/domain/`, `lib/data/repository/`, `lib/di/`
- Used for: Authentication features
- Pattern: Entities → UseCases → Repository Interface → Repository Implementation
- Dependency Injection: get_it service locator
- Status: Auth is fully implemented with Supabase integration

**Layer 2 - Direct Services Pattern:**
- Location: `lib/screens/`, `lib/services/`, `lib/widgets/`
- Used for: Food tracking, profile management
- Pattern: API services (`ProfileApiService`, `FoodLogApiService`, `FoodApiService`) directly called from screens
- Status: All core tracking features implemented and connected to backend API

**Key Services:**
- `ProfileApiService` - Load/save profile via API with 60s cache and request deduplication
- `FoodApiService` - Search foods from backend
- `FoodLogApiService` - Log food and get daily summary
- `SharedPreferenceHelper` - Local token storage

**Network Configuration:**
- Base URL configured in `lib/data/network/constants/endpoints.dart`
- For Android Emulator: Use `http://10.0.2.2:8000/api` (special alias for localhost)
- For physical device: Use ngrok URL or local network IP
- Dio client with `AuthInterceptor` auto-attaches Supabase JWT to all requests

**Key Screens:**
- `SplashScreen` - Checks Supabase session, routes to home/login
- `Login` - Email/password login, register modal, forgot password
- `HomeScreen` - Daily calorie dashboard with progress bars
- `AddMealScreen` - Search foods, log consumption with serving size
- `TrackingKaloriScreen` - Macronutrient breakdown (carbs, protein, fat)
- `ProfileScreen` - Display profile with BMI, TDEE, target calories
- `EditProfileScreen` - Update profile with dropdown selectors
- `HistoryScreen` - Food log history by date

## Important Conventions

### Backend
- Controllers use PascalCase suffix: `ProfileController`, `FoodLogController`
- Models are singular PascalCase: `FoodLog`, `UserProfile`
- Routes use kebab-case plural: `/api/food-logs`, `/api/food/favorites`
- All numeric fields in `Food` model must have `$casts` to float to prevent serialization errors
- Never use `Auth::id() ?? 1` pattern - always use middleware-authenticated user
- Migration filenames: `YYYY_MM_DD_HHMMSS_description.php`

### Frontend
- File names: snake_case (e.g., `home_screen.dart`)
- Class names: PascalCase (e.g., `HomeScreen`)
- Variables/functions: camelCase (e.g., `loadDailyData()`)
- Constants: SCREAMING_SNAKE (e.g., `BASE_URL`)
- Widget classes: PascalCase (e.g., `CalorieCard`)
- All API calls should use dedicated service classes, not direct HTTP calls

### Git Workflow
- Main branches: `main` (production), `develop` (integration)
- Feature branches: `feature/backend-description`, `feature/frontend-description`
- Bugfix branches: `fix/description`
- Commit format: `feat(backend):`, `fix(frontend):`, `chore(db):`, `test(api):`
- All protected routes require Supabase JWT token in Authorization header

## Critical Implementation Details

### Supabase JWT Verification
- Middleware uses ES256 algorithm (asymmetric) via JWKS from Supabase
- JWKS cached for 1 hour to reduce API calls
- JWT secret from `.env` must match Supabase Dashboard → Settings → JWT

### Food Database
- 1651 Indonesian foods seeded from `nilai-gizi.csv`
- All nutritional fields (calories, protein, carbs, fat, sugar, sodium, fiber) cast to float in `Food` model
- Search is case-insensitive ILIKE query with pagination (20 items per page)

### Profile Calculation
- BMI = weight / (height/100)²
- BMR (Mifflin-St Jeor):
  - Male: `(10 × weight) + (6.25 × height) − (5 × age) + 5`
  - Female: `(10 × weight) + (6.25 × height) − (5 × age) − 161`
- TDEE = BMR × activity_factor
- Target Calories:
  - Cutting: TDEE - 500
  - Bulking: TDEE + 500
  - Maintenance: TDEE

### Environment Variables
**Backend `.env` required:**
```env
DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=postgres
DB_USERNAME=postgres
DB_PASSWORD=your_password
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your_anon_key
SUPABASE_JWT_SECRET=your_jwt_secret
```

**Frontend `.env` required:**
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your_anon_key
BASE_URL=http://10.0.2.2:8000/api
```

## Testing

### Backend Tests
- Located in `backend/tests/Feature/` and `backend/tests/Unit/`
- Run with: `php artisan test`
- Auth tests: `AuthenticationTest.php`, `RegistrationTest.php`, `PasswordResetTest.php`

### Frontend Tests
- Located in `frontend/test/`
- Run with: `flutter test`
- Screen tests: `add_post_screen_test.dart`, `edit_profile_screen_test.dart`, `image_preview_screen_test.dart`
- Service tests: `profile_api_service_test.dart`

## Common Issues & Solutions

### Backend
- **"could not find driver"**: Enable `pdo_pgsql` and `pgsql` extensions in `php.ini`
- **"Connection refused"**: Check PostgreSQL is running and `.env` credentials are correct
- **401 Unauthorized**: Check `SUPABASE_JWT_SECRET` matches Supabase Dashboard, run `php artisan config:clear`

### Frontend
- **Android Emulator can't reach API**: Use `http://10.0.2.2:8000/api` not `localhost`
- **"MissingPluginException"**: Run `flutter clean && flutter pub get`
- **Supabase auth not working**: Verify `SUPABASE_URL` and `SUPABASE_ANON_KEY` in `.env`

## Development Status

**Sprint 1 (Completed):**
- ✅ Supabase Auth integration (email login, register, password reset)
- ✅ Profile management with BMI/TDEE calculation
- ✅ Food database with 1651 Indonesian items
- ✅ Food logging with daily summary
- ✅ Dashboard with calorie tracking

**Sprint 2 (In Progress):**
- 🔄 Community features (posts, likes, comments)
- 🔄 Food favorites and recommendations
- 🔄 OTP verification for phone-based auth
- 🔄 Profile photo upload
