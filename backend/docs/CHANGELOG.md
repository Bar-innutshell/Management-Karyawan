# Changelog

All notable changes to this backend will be documented in this file.

## [Unreleased]
- TBD

## [0.4.1] - 2025-11-11
### Added 🆕
- **User Shift Assignment System:**
  - Field `shift` pada User model (String, nullable)
  - Admin dapat assign shift "Pagi" atau "Sore" ke setiap user
  - Shift dapat di-set saat create atau update user
  - Shift dapat di-unassign (set null) jika diperlukan

### Changed 🔄
- **User Schema (`prisma/schema.prisma`):**
  - Tambah field `shift String?` pada model User
  - Field ini nullable (user bisa tidak punya shift)

- **User Controller (`controller/userController.js`):**
  - `createUser`: Accept parameter `shift`, validate "Pagi" atau "Sore"
  - `updateUser`: Accept parameter `shift`, validate "Pagi" atau "Sore", atau null
  - `getAllUsers`: Return field `shift` dalam response
  - `getUserById`: Return field `shift` dalam response

- **Seeder (`prisma/seed.js`):**
  - Update seed data untuk assign shifts ke users
  - Admin: null (tidak ada shift)
  - Cashier Pagi (Siti), Kasir Sore (Gilang)
  - Chef Pagi (Budi), Chef Sore (Hana)
  - Waiter Pagi (Dewi), Waiter Sore (Fitri)
  - Employee Sore (Eko)

- **Dokumentasi (`docs/API-USER.md`):**
  - Update request/response examples dengan field `shift`
  - Tambah validation rules untuk shift
  - Tambah example untuk assign & unassign shift

### Validation ✅
- **Shift Field:**
  - Hanya menerima: `"Pagi"`, `"Sore"`, atau `null`
  - Return 400 Bad Request jika nilai invalid
  - Error message: "Shift harus 'Pagi' atau 'Sore'"

### Use Cases 💡
- Admin create user baru dengan shift: `POST /users { shift: "Pagi" }`
- Admin update shift user: `PUT /users/:id { shift: "Sore" }`
- Admin hapus shift dari user: `PUT /users/:id { shift: null }`
- Frontend populate shift dropdown dari: `GET /shifts` (template reference)
- Frontend kirim shift value saat create/update user

### Migration Guide 🔄
```powershell
# 1. Start SQL Server jika belum running

# 2. Pull latest code
git pull

# 3. Push schema (add shift field to User table)
cd backend
npx prisma db push

# 4. Generate Prisma Client
npx prisma generate

# 5. Re-seed database (assign shifts to users)
npx prisma db seed

# 6. Test endpoints
# GET /users - akan return field "shift" untuk setiap user
# POST /users - bisa kirim field "shift": "Pagi" atau "Sore"
# PUT /users/:id - bisa update shift user
```

## [0.4.0] - 2025-11-11
### BREAKING CHANGES 🔥
- **Endpoint `/auth/register` DIHAPUS** - Registrasi user tidak lagi tersedia
  - Hanya Admin yang bisa create user melalui `POST /users`
  - User tidak bisa self-register

- **Shift Management menjadi Template Only** - Tidak ada CRUD
  - `POST /shifts` - DISABLED
  - `PUT /shifts/:id` - DISABLED  
  - `DELETE /shifts/:id` - DISABLED
  - Shift hanya bisa diubah melalui seed.js

### Added 🆕
- **Shift Template System:**
  - 2 shift tetap: **Pagi** (09:00-15:00) dan **Sore** (15:00-21:00)
  - Auto-seeded saat `npx prisma db seed`
  - Hari kerja: Senin-Jumat (20 hari/bulan)
  - Shift tidak bisa diubah via API (template only)

### Changed 🔄
- **Authentication Routes (`routes/authRoute.js`):**
  - Disabled `POST /auth/register` endpoint
  - Hanya tersisa `POST /auth/login`

- **Shift Routes (`routes/shiftRoute.js`):**
  - Disabled `POST /shifts` (create)
  - Disabled `PUT /shifts/:id` (update)
  - Disabled `DELETE /shifts/:id` (delete)
  - Hanya GET endpoints yang aktif (read-only)

- **Seeder (`prisma/seed.js`):**
  - Tambah section "SHIFTS (TEMPLATE)" di awal
  - Seed 2 shift: Pagi & Sore
  - Shift di-upsert untuk prevent duplicate

- **Dokumentasi:**
  - `docs/API.md` - Update authentication section (hapus register)
  - `docs/API.md` - Update shift section (template only)
  - `docs/API-SHIFT.md` - Rewrite jadi template only (simplified from 660 lines to 150 lines)
  - `docs/API-USER.md` - No changes

### Removed ❌
- **Register Endpoint:** `POST /auth/register` tidak lagi tersedia
- **Shift CRUD:** POST, PUT, DELETE shift endpoints dihapus
- User tidak bisa membuat akun sendiri
- Admin tidak bisa CRUD shift via API

### Security 🔒
- Lebih aman: User tidak bisa self-register
- Admin full control: Hanya admin yang bisa create akun karyawan
- Shift tetap: Tidak bisa dimanipulasi via API

### Migration Guide 🔄
```powershell
# 1. Pull latest code
git pull

# 2. Push schema (table Shift sudah ada)
cd backend
npx prisma db push

# 3. Generate Prisma Client
npx prisma generate

# 4. Seed shift templates
npx prisma db seed

# 5. Test endpoints
# - Register endpoint akan 404 (sudah dihapus)
# - POST/PUT/DELETE shift akan 404 (sudah dihapus)
# - GET /shifts akan return 2 template (Pagi & Sore)
```

### Frontend Impact 📱
- **Hapus registration screen/form** - Tidak lagi diperlukan
- **Update shift management:**
  - Hapus form create/edit shift
  - Jadikan shift dropdown read-only dari API
  - Gunakan `GET /shifts` untuk populate dropdown
- **User creation:**
  - Hanya admin yang bisa create user via `POST /users`
  - Form create user tetap ada (untuk admin)

## [0.3.0] - 2025-11-11
### Added 🆕
- **User Management API (Admin Only):**
  - `GET /users` - List semua users dengan filter (roleId, search)
  - `GET /users/:id` - Get user by ID dengan detail lengkap
  - `POST /users` - Create user baru (nama, email, password, roleId, gajiPerJam)
  - `PUT /users/:id` - Update user (semua field optional)
  - `DELETE /users/:id` - Delete user (validasi data terkait)
  - Controller: `controller/userController.js`
  - Routes: `routes/userRoute.js`
  - Dokumentasi: `docs/API-USER.md`

- **Shift Management API:**
  - `GET /shifts` - List semua shifts (all users), filter by aktif
  - `GET /shifts/:id` - Get shift by ID
  - `POST /shifts` - Create shift baru (Admin only)
  - `PUT /shifts/:id` - Update shift (Admin only)
  - `DELETE /shifts/:id` - Delete shift (Admin only)
  - Controller: `controller/shiftController.js`
  - Routes: `routes/shiftRoute.js`
  - Model: `model Shift` dengan fields: nama, jamMulai, jamSelesai, deskripsi, aktif
  - Dokumentasi: `docs/API-SHIFT.md`

- **Dokumentasi Baru:**
  - `docs/API-USER.md` - Full documentation CRUD User (15+ examples)
  - `docs/API-SHIFT.md` - Full documentation CRUD Shift (dengan use cases)
  - `docs/SETUP-USER-SHIFT.md` - Quick setup guide untuk fitur baru
  - `docs/SYNC-DATABASE.md` - Panduan sinkronisasi database tim (comprehensive)
  - `docs/errors/ERROR-SEED-ABSENSI.md` - Fix error "Unknown argument jamMulaiShift"

### Changed 🔄
- **Schema Prisma:**
  - Tambah model `Shift` dengan unique constraint pada `nama`
  - Time format untuk shift: `jamMulai` dan `jamSelesai` (String, format HH:MM)
  
- **Backend Index:**
  - Register routes `/users` dan `/shifts`
  - Import `userRoute` dan `shiftRoute`

- **Seeder (`prisma/seed.js`):**
  - Smart seeder dengan try-catch untuk kompatibilitas schema
  - Support schema lama (dengan jamMulaiShift) dan baru (tanpa jamMulaiShift)

- **API Documentation:**
  - `docs/API.md` updated dengan link ke API-USER.md dan API-SHIFT.md
  - `docs/README.md` updated dengan dokumentasi baru di section "API & Development"
  - `docs/errors/README.md` updated dengan ERROR-SEED-ABSENSI.md

### Security 🔒
- User CRUD endpoints dilindungi `isAdmin` middleware
- Shift POST/PUT/DELETE dilindungi `isAdmin` middleware
- Password auto-hash dengan bcrypt saat create/update user
- Email validation unique untuk prevent duplicate user
- Delete user validation - tidak bisa delete jika ada data terkait

### Database Migration 🗄️
- Added table `Shift` dengan schema:
  ```sql
  CREATE TABLE Shift (
    id INT PRIMARY KEY IDENTITY,
    nama NVARCHAR(255) UNIQUE NOT NULL,
    jamMulai VARCHAR(5) NOT NULL,
    jamSelesai VARCHAR(5) NOT NULL,
    deskripsi NVARCHAR(MAX),
    aktif BIT DEFAULT 1,
    createdAt DATETIME2 DEFAULT GETDATE(),
    updatedAt DATETIME2 DEFAULT GETDATE()
  )
  ```

### Validation ✅
- **User Management:**
  - Email format validation & uniqueness check
  - Password minimum length (handled by bcrypt)
  - RoleId must exist in Role table
  - Cannot delete user with related data (absensi, slipGaji, jadwal, laporanPemasukan)

- **Shift Management:**
  - Time format validation: `/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/`
  - Shift name uniqueness
  - Valid values: "07:00", "15:30", "23:45"
  - Invalid values: "7:00", "25:00", "12:60"

## [0.2.0] - 2025-11-07
### Added
- **Role Management System:** Admin bisa buat, edit, dan hapus role custom.
- Field baru di model Role: `gajiPokok`, `deskripsi`, `createdAt`, `updatedAt`.
- Controller `roleController.js` dengan CRUD lengkap untuk role.
- Middleware `authMiddleware.js`:
  - `authenticateToken`: Verifikasi JWT token.
  - `isAdmin`: Cek apakah user adalah Admin.
- Routes `/roles` dengan proteksi admin-only untuk create, update, delete.
- Dokumentasi lengkap di `docs/API.md` untuk endpoint auth dan role management.
- Dokumentasi Postman di `docs/POSTMAN.md` dengan flow testing lengkap.

### Changed
- Model Role sekarang support gaji per role (gaji tidak lagi di model Gaji saja).
- Endpoint role management memerlukan authentication (Bearer token).
- Admin dapat create role dengan nama dan gaji custom.

### Security
- Semua endpoint role (kecuali GET) dilindungi middleware `isAdmin`.
- Token JWT expires dalam 1 jam.
- Password di-hash dengan bcrypt sebelum disimpan.

## [0.1.1] - 2025-11-07
### Fixed
- Fix SQL Server connection timeout issue: removed `instanceName` from sqlConfig (konflik dengan port 1433).
- Fix error handling di `/db/ping` endpoint (tampilkan error message dengan benar).
- Ubah dari Windows Authentication ke SQL Authentication (driver `mssql` tedious, bukan `mssql/msnodesqlv8`).

### Changed
- Prisma generator output kembali ke default `node_modules/@prisma/client` (bukan custom path).
- Update `.env` dengan semua variabel yang dibutuhkan termasuk JWT_SECRET.
- Update dokumentasi setup dengan troubleshooting common errors.

### Added
- Script `test-db.js` untuk debug koneksi database.
- NPM scripts: `dev`, `studio`, `db:push`, `db:migrate`, `db:generate`.

## [0.1.0] - 2025-11-07
### Added
- Initial documentation files: `API.md`, `SHIFT.md`, `CONTRIBUTING.md`, `CHANGELOG.md`, `README.md` in `backend/docs`.
- Setup script `setup-sql-login.sql` untuk membuat SQL login `prisma_user`.
- Script `enable-sql-auth.ps1` untuk mengaktifkan Mixed Authentication mode.
- Script `grant-create-db.sql` untuk beri permission CREATE DATABASE.
- Prisma schema dengan model: Role, User, Jadwal, Absensi, Gaji, LaporanPemasukan.

### Changed
- Field `shift` di model `LaporanPemasukan` menggunakan string (bukan enum) dengan validasi: "pagi", "siang", "malam".
- `.env` menggunakan SQL Authentication (bukan Windows Auth) untuk kompatibilitas Prisma.
- Shadow database disabled (`SHADOW_DATABASE_URL=""`) untuk dev lokal tanpa permission CREATE DATABASE.

