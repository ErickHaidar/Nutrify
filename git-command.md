# NUTRIFY — Panduan Lengkap Git

> Referensi semua perintah Git untuk tim Nutrify.
> Terakhir diperbarui: 5 Maret 2026

---

## Daftar Isi

1. [Struktur Branch Nutrify](#1-struktur-branch-nutrify)
2. [Setup Awal (Pertama Kali)](#2-setup-awal-pertama-kali)
3. [Alur Kerja Sehari-hari](#3-alur-kerja-sehari-hari)
4. [Format Commit Message](#4-format-commit-message)
5. [Sinkronisasi Branch Backend](#5-sinkronisasi-branch-backend)
6. [Perintah Dasar Git](#6-perintah-dasar-git)
7. [Manajemen Branch](#7-manajemen-branch)
8. [Melihat Riwayat & Status](#8-melihat-riwayat--status)
9. [Undo & Perbaikan](#9-undo--perbaikan)
10. [Stash — Simpan Pekerjaan Sementara](#10-stash--simpan-pekerjaan-sementara)
11. [Merge & Rebase](#11-merge--rebase)
12. [Resolve Konflik](#12-resolve-konflik)
13. [Remote Repository](#13-remote-repository)
14. [Tag & Release](#14-tag--release)
15. [Situasi Darurat](#15-situasi-darurat)

---

## 1. Struktur Branch Nutrify

```
main              ← Kode stabil, siap production (PROTECTED — jangan push langsung)
│
develop           ← Integrasi harian, kode QA
│
├── feature/be-07-food-list-api      ← Fitur backend
├── feature/fe-05-supabase-auth      ← Fitur frontend
├── fix/be-food-log-validation       ← Bugfix
└── chore/update-env-example         ← Non-fitur (config, docs)

backend           ← Mirror isi folder backend/ saja (untuk deploy BE terpisah)
sprint1-apps      ← Branch kerja Sprint 1 (monorepo lengkap)
```

### Aturan Branch

| Branch | Dibuat dari | Merge ke | Siapa |
|---|---|---|---|
| `feature/*` | `develop` | `develop` via PR | Developer |
| `fix/*` | `develop` | `develop` via PR | Developer |
| `hotfix/*` | `main` | `main` + `develop` | Lead |
| `develop` | — | `main` via PR | Lead |
| `backend` | — | — | Di-sync via `git subtree split` |

---

## 2. Setup Awal (Pertama Kali)

```bash
# Clone repo
git clone https://github.com/prodhokter/nutrify.git
cd nutrify

# Cek semua branch yang ada di remote
git branch -a

# Pindah ke branch kerja utama
git checkout sprint1-apps

# Set identitas kamu (wajib sebelum commit pertama)
git config user.name "Nama Kamu"
git config user.email "email@kamu.com"

# Untuk seluruh komputer (bukan hanya repo ini):
git config --global user.name "Nama Kamu"
git config --global user.email "email@kamu.com"
```

---

## 3. Alur Kerja Sehari-hari

```bash
# 1. Pastikan kamu di branch yang benar dan ambil perubahan terbaru
git checkout develop
git pull origin develop

# 2. Buat branch baru untuk task/fitur
git checkout -b feature/fe-05-supabase-auth

# 3. Kerjakan kode...

# 4. Cek apa yang berubah
git status
git diff

# 5. Stage dan commit
git add .
git commit -m "feat(frontend): tambah integrasi Supabase email login"

# 6. Push branch kamu ke remote
git push origin feature/fe-05-supabase-auth

# 7. Buka Pull Request di GitHub → ke branch develop
#    URL: https://github.com/prodhokter/nutrify/compare/develop...feature/fe-05-supabase-auth
```

---

## 4. Format Commit Message

Gunakan **Conventional Commits**:

```
<type>(<scope>): <deskripsi singkat>
```

### Type yang Valid

| Type | Kapan dipakai |
|---|---|
| `feat` | Fitur baru |
| `fix` | Perbaikan bug |
| `refactor` | Perubahan kode tanpa fitur/bug baru |
| `chore` | Config, dependencies, docs, tooling |
| `test` | Penambahan atau perbaikan test |
| `style` | Formatting, whitespace — tanpa perubahan logika |

### Scope yang Valid

| Scope | Konteks |
|---|---|
| `backend` | Perubahan di folder `backend/` |
| `frontend` | Perubahan di folder `frontend/` |
| `db` | Migration, seeder |
| `api` | Route, controller |
| `auth` | Autentikasi (Supabase, middleware) |
| `docs` | Dokumentasi, markdown |

### Contoh Commit yang Benar

```bash
git commit -m "feat(backend): tambah endpoint GET /api/foods dengan search"
git commit -m "feat(frontend): implementasi email login via supabase_flutter"
git commit -m "fix(backend): hapus fallback Auth::id() ?? 1 di FoodLogController"
git commit -m "chore(db): update migration foods — tambah sodium dan fiber"
git commit -m "refactor(api): pindahkan register/login ke AuthController"
git commit -m "feat(auth): tambah middleware VerifySupabaseToken"
git commit -m "chore(docs): update NUTRIFY_GUIDE dengan panduan Supabase"
git commit -m "test(backend): tambah feature test untuk endpoint food-logs"
```

---

## 5. Sinkronisasi Branch Backend

Branch `backend` di remote hanya berisi isi folder `backend/` (tanpa `frontend/`, tanpa docs root).
Gunakan `git subtree split` setiap kali ingin sync.

### Perintah Sync (Jalankan dari root repo)

```bash
# 1. Buat branch sementara dari isi folder backend/ saja
git subtree split --prefix=backend --branch temp-backend-sync

# 2. Force push ke remote branch backend
git push origin temp-backend-sync:backend --force

# 3. Hapus branch sementara lokal
git branch -D temp-backend-sync
```

### Kapan Perlu Dijalankan?

- Setelah push perubahan backend ke `sprint1-apps` atau `develop`
- Setelah migration baru atau perubahan config backend
- Sebelum deploy backend ke server

### Catatan Penting

- `--force` pada `push` itu **aman** karena branch `backend` memang selalu di-overwrite dari monorepo
- **Jangan** merge langsung ke branch `backend` — selalu melalui `subtree split`
- Jalankan dari branch yang sudah **up-to-date** (sudah pull terbaru)

---

## 6. Perintah Dasar Git

### Inisialisasi & Clone

```bash
git init                          # Buat repo baru di folder ini
git clone <url>                   # Clone repo dari remote
git clone <url> nama-folder       # Clone ke folder dengan nama tertentu
```

### Stage & Commit

```bash
git status                        # Cek file yang berubah
git add namafile.php              # Stage file tertentu
git add folder/                   # Stage seluruh folder
git add .                         # Stage semua perubahan
git add -p                        # Stage secara interaktif (pilih baris demi baris)

git commit -m "pesan commit"      # Commit dengan pesan singkat
git commit                        # Buka editor untuk pesan panjang
git commit --amend                # Edit commit terakhir (pesan atau isi)
git commit --amend --no-edit      # Tambah file ke commit terakhir tanpa ubah pesan
```

### Push & Pull

```bash
git push origin nama-branch       # Push branch ke remote
git push -u origin nama-branch    # Push + set upstream (lakukan sekali, berikutnya cukup git push)
git push                          # Push ke upstream yang sudah di-set

git pull origin nama-branch       # Fetch + merge dari remote
git pull --rebase origin develop  # Fetch + rebase (lebih bersih dari merge)
git fetch origin                  # Hanya download perubahan, belum merge ke lokal
```

---

## 7. Manajemen Branch

### Melihat Branch

```bash
git branch                        # Lihat semua branch lokal
git branch -a                     # Lihat semua branch (lokal + remote)
git branch -v                     # Lihat branch + commit terakhir
git branch --merged               # Branch yang sudah di-merge ke branch saat ini
git branch --no-merged            # Branch yang belum di-merge
```

### Buat & Pindah Branch

```bash
git checkout -b nama-branch             # Buat branch baru DAN pindah ke sana
git checkout -b feature/be-08-food-api  # Contoh penamaan sesuai konvensi

git checkout nama-branch                # Pindah ke branch yang sudah ada
git switch nama-branch                  # Alternatif modern dari checkout
git switch -c nama-branch               # Buat branch baru (alternatif)
```

### Hapus Branch

```bash
git branch -d nama-branch         # Hapus branch lokal (safe — tolak jika belum di-merge)
git branch -D nama-branch         # Hapus branch lokal paksa
git push origin --delete nama-branch  # Hapus branch di remote
```

### Rename Branch

```bash
git branch -m nama-lama nama-baru       # Rename branch lokal
git branch -m nama-baru                 # Rename branch yang sedang aktif
# Setelah rename, update di remote:
git push origin --delete nama-lama
git push -u origin nama-baru
```

---

## 8. Melihat Riwayat & Status

```bash
git log                           # Riwayat commit lengkap
git log --oneline                 # Satu baris per commit
git log --oneline -10             # 10 commit terakhir
git log --oneline --graph         # Tampilkan graph branch
git log --oneline --graph --all   # Semua branch dalam graph

git log --author="Nama"           # Filter berdasarkan author
git log --since="2026-03-01"      # Commit sejak tanggal tertentu
git log --until="2026-03-05"      # Commit sampai tanggal tertentu
git log -- path/ke/file.php       # Riwayat satu file saja

git show commit-hash              # Detail satu commit
git show HEAD                     # Detail commit terakhir
git show HEAD~2                   # Detail 2 commit sebelum HEAD

git diff                          # Perubahan yang belum di-stage
git diff --staged                 # Perubahan yang sudah di-stage
git diff branch1 branch2          # Perbedaan antara dua branch
git diff HEAD~1 HEAD              # Perbedaan commit terakhir vs sebelumnya

git blame namafile.php            # Siapa yang ubah baris mana
git shortlog -sn                  # Ringkasan jumlah commit per author
```

---

## 9. Undo & Perbaikan

> ⚠️ Perhatikan mana yang **aman** (tidak mengubah history) dan mana yang **berbahaya** (ubah history).

### Aman — Tidak Mengubah History

```bash
# Batalkan perubahan di working directory (belum di-stage)
git restore namafile.php          # Kembalikan file ke kondisi commit terakhir
git restore .                     # Kembalikan semua file

# Batalkan stage (sudah git add, belum commit)
git restore --staged namafile.php
git reset HEAD namafile.php       # Cara lama, sama hasilnya

# Buat commit baru yang membalik commit tertentu
git revert commit-hash            # Aman untuk history yang sudah di-push
git revert HEAD                   # Revert commit terakhir
```

### Berbahaya — Mengubah History (Hati-hati!)

> ❌ **Jangan gunakan pada branch yang sudah di-push dan dipakai orang lain.**

```bash
# Pindah HEAD ke commit tertentu
git reset --soft HEAD~1           # Undo commit terakhir, perubahan tetap di-stage
git reset --mixed HEAD~1          # Undo commit + unstage, perubahan tetap di file (default)
git reset --hard HEAD~1           # Undo commit + buang semua perubahan (PERMANEN)

git reset --hard origin/develop   # Reset lokal ke kondisi remote (buang semua lokal)

# Edit commit terakhir (belum di-push)
git commit --amend -m "pesan baru"
```

---

## 10. Stash — Simpan Pekerjaan Sementara

Gunakan `stash` ketika perlu pindah branch sementara tapi pekerjaan belum siap di-commit.

```bash
git stash                         # Simpan semua perubahan (tracked files)
git stash push -m "WIP: login screen"  # Simpan dengan nama deskriptif
git stash push -u                 # Termasuk untracked files (file baru)

git stash list                    # Lihat semua stash
git stash show stash@{0}          # Detail stash tertentu
git stash show -p stash@{0}       # Detail dengan diff

git stash pop                     # Ambil stash terbaru + hapus dari list
git stash apply stash@{0}         # Ambil stash tertentu tanpa hapus dari list
git stash drop stash@{0}          # Hapus stash tertentu
git stash clear                   # Hapus semua stash
```

---

## 11. Merge & Rebase

### Merge

```bash
# Merge branch ke branch saat ini
git checkout develop
git merge feature/fe-05-supabase-auth

git merge --no-ff feature/fe-05-supabase-auth  # Buat merge commit (lebih jelas history)
git merge --squash feature/fe-05-supabase-auth  # Gabungkan semua commit menjadi satu
git merge --abort                               # Batalkan merge yang sedang berlangsung
```

### Rebase

```bash
# Rebase branch fitur ke atas develop terbaru
git checkout feature/fe-05-supabase-auth
git rebase develop

git rebase --continue     # Lanjutkan setelah resolve konflik
git rebase --abort        # Batalkan rebase
git rebase --skip         # Lewati commit yang konflik

# Interactive rebase — edit, gabungkan, atau hapus commit
git rebase -i HEAD~3      # Edit 3 commit terakhir secara interaktif
git rebase -i develop     # Interactive rebase dari titik branch develop
```

> **Kapan pakai merge vs rebase?**
> - `merge` → untuk menggabungkan branch di `develop`/`main` (history jelas)
> - `rebase` → untuk update branch fitur dengan perubahan terbaru dari `develop` (history bersih)

---

## 12. Resolve Konflik

Ketika ada konflik setelah `merge` atau `rebase`:

```bash
# 1. Cek file yang konflik
git status

# 2. Buka file yang konflik — cari tanda:
# <<<<<<< HEAD          ← Perubahan kamu
# =======
# >>>>>>> branch-lain   ← Perubahan dari branch lain

# 3. Edit file — pilih/gabungkan perubahan yang benar
# 4. Hapus tanda konflik (<<<, ===, >>>)

# 5. Stage file yang sudah di-resolve
git add namafile.php

# 6. Lanjutkan proses
git merge --continue      # Jika sedang merge
git rebase --continue     # Jika sedang rebase

# Jika mau batalkan saja:
git merge --abort
git rebase --abort
```

---

## 13. Remote Repository

```bash
# Lihat konfigurasi remote
git remote -v

# Tambah remote
git remote add origin https://github.com/prodhokter/nutrify.git

# Ubah URL remote
git remote set-url origin https://github.com/prodhokter/nutrify.git

# Hapus remote
git remote remove origin

# Fetch semua dari remote (download tanpa merge)
git fetch origin
git fetch --all               # Fetch dari semua remote
git fetch --prune             # Hapus referensi branch remote yang sudah dihapus

# Lihat branch remote
git branch -r
git branch -a

# Track branch remote di lokal
git checkout -b develop origin/develop
git checkout --track origin/develop   # Shortcut, sama hasilnya
```

---

## 14. Tag & Release

```bash
# Buat tag (untuk versi / release)
git tag v1.0.0                          # Lightweight tag
git tag -a v1.0.0 -m "Sprint 1 release"  # Annotated tag (direkomendasikan)

# Lihat semua tag
git tag
git tag -l "v1.*"             # Filter tag

# Push tag ke remote
git push origin v1.0.0        # Push satu tag
git push origin --tags        # Push semua tag

# Hapus tag
git tag -d v1.0.0             # Hapus lokal
git push origin --delete v1.0.0  # Hapus di remote

# Checkout ke tag tertentu
git checkout v1.0.0
```

---

## 15. Situasi Darurat

### "Saya commit ke branch yang salah"

```bash
# Pindahkan commit terakhir ke branch yang benar
git branch nama-branch-baru       # Buat branch baru dari posisi ini
git reset --hard HEAD~1           # Kembalikan branch lama ke sebelum commit
git checkout nama-branch-baru     # Pindah ke branch yang benar
```

### "Saya tidak sengaja hapus file penting"

```bash
git checkout HEAD -- path/ke/file.php    # Kembalikan file dari commit terakhir
git checkout commit-hash -- path/ke/file.php  # Kembalikan dari commit tertentu
```

### "Saya perlu lihat kode dari commit lama"

```bash
git show commit-hash:path/ke/file.php   # Lihat isi file di commit tertentu
git checkout commit-hash                # Pindah ke commit lama (detached HEAD)
git checkout -                          # Kembali ke branch sebelumnya
```

### "Branch lokal saya sudah berantakan, ingin reset ke remote"

```bash
git fetch origin
git reset --hard origin/develop   # Reset total ke kondisi remote develop
# ⚠️ Semua perubahan lokal yang belum di-push akan HILANG
```

### "Saya push sesuatu yang salah ke remote"

```bash
# Cara aman — buat revert commit
git revert HEAD
git push origin nama-branch

# Cara berbahaya — edit history (gunakan hanya jika benar-benar perlu)
git reset --hard HEAD~1
git push origin nama-branch --force
# ⚠️ Beritahu semua anggota tim! Mereka perlu git fetch --all && git reset --hard origin/nama-branch
```

### "Ada file sensitif yang tidak sengaja di-commit"

```bash
# Hapus file dari tracking git (tapi tidak dari disk)
git rm --cached namafile.txt
echo "namafile.txt" >> .gitignore
git add .gitignore
git commit -m "chore: hapus file sensitif dari tracking"
git push origin nama-branch

# Jika sudah terlanjur push, anggap rahasia tersebut compromised
# Ganti password/API key tersebut SEGERA
```

### "Saya ingin cari tahu kapan bug ini masuk"

```bash
git bisect start                  # Mulai proses bisect
git bisect bad                    # Commit saat ini ada bug-nya
git bisect good v1.0.0            # Commit ini masih oke
# Git akan checkout commit di tengah — cek apakah ada bug
git bisect bad                    # Jika commit ini ada bug
git bisect good                   # Jika commit ini tidak ada bug
# Ulangi sampai Git menemukan commit yang memperkenalkan bug
git bisect reset                  # Selesai, kembali ke HEAD
```

---

## Quick Reference

```
Situasi                            Perintah
──────────────────────────────────────────────────────────────────
Lihat status file                  git status
Lihat perubahan                    git diff
Stage semua                        git add .
Commit                             git commit -m "pesan"
Push branch ini                    git push origin HEAD
Pull terbaru                       git pull origin develop
Buat branch baru                   git checkout -b feature/nama
Pindah branch                      git checkout nama-branch
Hapus branch lokal                 git branch -D nama-branch
Simpan kerja sementara             git stash
Ambil kerja dari stash             git stash pop
Lihat log ringkas                  git log --oneline -10
Lihat graph semua branch           git log --oneline --graph --all
Reset file ke kondisi terakhir     git restore namafile.php
Undo commit terakhir (keep files)  git reset --soft HEAD~1

Sync branch backend dari monorepo
  git subtree split --prefix=backend --branch temp-backend-sync
  git push origin temp-backend-sync:backend --force
  git branch -D temp-backend-sync
```

---

*Untuk konvensi branch dan aturan tim, lihat [NUTRIFY_GUIDE.md](NUTRIFY_GUIDE.md) → Section 10.*
