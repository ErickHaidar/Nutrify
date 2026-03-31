# Nutrify 🥗

Aplikasi mobile untuk melacak asupan kalori dan makronutrisi harian secara personal berdasarkan target *body goals* masing-masing.

---

## Struktur Repositori

```
nutrify/
├── backend/          ← REST API (Laravel 12 + PostgreSQL + Sanctum)
├── frontend/         ← Mobile App (Flutter + MobX)
├── BACKLOG.md        ← Semua backlog item & status
├── CHANGELOG.md      ← Histori perubahan per versi
├── NUTRIFY_GUIDE.md  ← Panduan lengkap onboarding & arsitektur
├── planning.md       ← Rencana sprint & saran teknis
└── nilai-gizi.csv    ← Dataset makanan Indonesia (sumber FoodSeeder)
```

---

## Tech Stack

| Layer | Teknologi |
|---|---|
| Mobile App | Flutter (Dart SDK ≥ 3.0.0) |
| State Management | MobX + flutter_mobx |
| HTTP Client | Dio |
| REST API | Laravel 12 |
| Authentication | Laravel Sanctum (Bearer Token) |
| Database | PostgreSQL ≥ 14 |

---

## Quick Start

### Backend

```bash
cd backend
composer install
cp .env.example .env
php artisan key:generate
# Edit .env — sesuaikan DB_USERNAME dan DB_PASSWORD
php artisan migrate
php artisan serve
```

API berjalan di: `http://localhost:8000`

### Frontend

```bash
cd frontend
flutter pub get
flutter run
```

---

## Dokumentasi

| Dokumen | Isi |
|---|---|
| [NUTRIFY_GUIDE.md](NUTRIFY_GUIDE.md) | Setup environment, arsitektur, API reference, aturan tim, branching |
| [BACKLOG.md](BACKLOG.md) | Semua backlog Sprint 1 + status per item |
| [CHANGELOG.md](CHANGELOG.md) | Histori perubahan tiap versi |
| [planning.md](planning.md) | Rencana eksekusi sprint + saran ke depan |

---

## Kontribusi

1. Baca [NUTRIFY_GUIDE.md](NUTRIFY_GUIDE.md) terlebih dahulu
2. Buat branch dari `develop`: `git checkout -b feature/nama-fitur`
3. Commit dengan format [Conventional Commits](https://www.conventionalcommits.org/): `feat(backend): ...`
4. Buka Pull Request ke `develop` — wajib 1 review sebelum merge

---

## Tim

> Tambahkan nama anggota tim di sini.
