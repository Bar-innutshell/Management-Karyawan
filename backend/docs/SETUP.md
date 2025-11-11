# Setup Guide — First Time Installation

Panduan lengkap untuk menjalankan project ini dari awal (setelah clone dari GitHub).

---

## ⚡ Quick Start (TL;DR)

**Sudah setup SQL Server & punya user `prisma_user`?** Jalankan ini:

```powershell
# 1. Clone & install
git clone https://github.com/Bar-innutshell/Management-Karyawan.git
cd Management-Karyawan/backend
npm install

# 2. Setup .env (edit dengan credentials kamu)
copy .env.example .env

# 3. Setup database
npx prisma db push
npx prisma generate
npm run db:seed          # ⚠️ PENTING: Seed data default!

# 4. Run server
npm run dev
```

**Belum setup SQL Server?** Ikuti langkah lengkap di bawah! 👇

---

## 📋 Prerequisites

Pastikan sudah terinstall:
- **Node.js** (v18 atau lebih baru) — [Download](https://nodejs.org/)
- **SQL Server Express** (atau edisi lain) — [Download](https://www.microsoft.com/en-us/sql-server/sql-server-downloads)
- **SQL Server Management Studio (SSMS)** — [Download](https://aka.ms/ssmsfullsetup)
- **Git** — [Download](https://git-scm.com/)
- **Flutter SDK** (untuk mobile app) — [Download](https://flutter.dev/docs/get-started/install)

> ⚠️ **JIKA MENGALAMI ERROR:** Lihat file `TROUBLESHOOTING.md` untuk solusi lengkap error umum!

---

## 🚀 Langkah-langkah Setup

### 1. Clone Repository

```powershell
git clone https://github.com/Bar-innutshell/Management-Karyawan.git
cd Management-Karyawan
```

---

### 2. Setup SQL Server

#### A. Aktifkan SQL Server Authentication (Mixed Mode)

**Via SSMS (cara termudah):**
1. Buka SSMS
2. Connect ke server: `.\SQLEXPRESS` (Windows Authentication)
3. Klik kanan server di Object Explorer → **Properties**
4. Pilih **Security** → ubah ke **"SQL Server and Windows Authentication mode"**
5. Klik **OK**
6. Restart SQL Server service:
   - Buka `services.msc`
   - Cari **SQL Server (SQLEXPRESS)**
   - Klik kanan → **Restart**

**Via PowerShell (sebagai Administrator):**
```powershell
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQLServer" -Name "LoginMode" -Value 2
Restart-Service -Name "MSSQL`$SQLEXPRESS" -Force
```

#### B. Buat Database dan Login SQL

Jalankan script setup:
```powershell
# Buat database db_restoran
sqlcmd -S .\SQLEXPRESS -E -i "script.sql"

# Buat login prisma_user
sqlcmd -S .\SQLEXPRESS -E -i "backend\docs\errors\tools\setup-sql-login.sql"

# Beri permission CREATE DATABASE (untuk Prisma migrate)
sqlcmd -S .\SQLEXPRESS -E -i "backend\docs\errors\tools\grant-create-db.sql"
```

Atau jalankan manual di SSMS:
1. File → Open → File...
2. Pilih `script.sql` → Execute (F5)
3. Pilih `backend\docs\errors\tools\setup-sql-login.sql` → Execute (F5)
4. Pilih `backend\docs\errors\tools\grant-create-db.sql` → Execute (F5)

#### C. Verifikasi Koneksi

Test login SQL:
```powershell
sqlcmd -S localhost,1433 -U prisma_user -P "Prisma!2025" -Q "SELECT DB_NAME()"
```

Jika berhasil, akan muncul nama database.

---

### 3. Setup Backend (Node.js + Express)

```powershell
cd backend
npm install
```

#### Konfigurasi Environment

File `.env` sudah ada, pastikan isinya:
```properties
db_auth=sql
db_host=localhost
db_name=db_restoran
db_user=prisma_user
db_password=Prisma!2025
db_trust_server_certificate=true
PORT=3000

DATABASE_URL="sqlserver://localhost:1433;database=db_restoran;user=prisma_user;password=Prisma!2025;encrypt=true;trustServerCertificate=true"
SHADOW_DATABASE_URL=""
JWT_SECRET="kata_mamah_aku_sigma08953214371987"
```

**PENTING:** Jangan tambahkan `instanceName` ke config karena sudah pakai port 1433 default.

#### Test Koneksi Database SEBELUM Prisma Push

**WAJIB:** Jalankan test koneksi terlebih dahulu untuk memastikan SQL Server siap:

```powershell
node docs/errors/tools/test-connection.js
```

Expected output jika sukses:
```
✅ Step 1: Connection SUCCESSFUL!
✅ Step 2: Query execution SUCCESSFUL!
✅ Step 3: Database 'db_restoran' EXISTS!
✅ Step 4: Permission check SUCCESSFUL!
✅ Step 5: Table operations SUCCESSFUL!

🎉 ALL TESTS PASSED! SQL Server is ready for Prisma!
```

**Jika test GAGAL (error ECONNRESET, ESOCKET, dll):**
- Lihat file `TROUBLESHOOTING.md` untuk solusi lengkap
- Pastikan SQL Server service running
- Pastikan TCP/IP protocol enabled
- Pastikan port 1433 tidak diblokir firewall

#### Sinkronkan Database Schema

**Opsi A — Pakai `db push` (untuk dev lokal, lebih cepat):**
```powershell
npx prisma db push
npx prisma generate
```

**Opsi B — Pakai `migrate` (untuk production/team, buat migration history):**
```powershell
npx prisma migrate dev --name init
```

**WAJIB:** Setelah clone atau update schema, jalankan:
```powershell
npx prisma generate
```

**Jika muncul error saat `npx prisma db push`:**
1. Pastikan test-connection.js sudah berhasil
2. Lihat `TROUBLESHOOTING.md` untuk solusi error ECONNRESET
3. Pastikan SQL Server TCP/IP enabled dan restart service
4. Coba tambahkan timeout: edit DATABASE_URL tambahkan `;connectTimeout=30000`

#### Fix Timestamps Issue (WAJIB!)

**PENTING:** Setelah `npx prisma db push`, WAJIB jalankan migration ini untuk menghindari error "createdAt does not exist":

```powershell
# Add timestamps ke semua tabel
sqlcmd -S .\SQLEXPRESS -E -i docs/tools/add-timestamps-all-tables.sql

# Generate ulang Prisma Client
npx prisma generate
```

**Expected output:**
```
✓ Absensi: createdAt & updatedAt already exist
✓ Jadwal: createdAt & updatedAt added
✓ LaporanPemasukan: createdAt & updatedAt added
✅ All timestamps columns added successfully!
```

**Jika skip langkah ini:**
- ❌ Prisma Studio akan error: "The column createdAt does not exist"
- ❌ API akan error saat query data
- ❌ Frontend tidak bisa fetch data

**Lihat:** `docs/errors/FIX-CREATEDAT-ERROR.md` untuk troubleshooting lengkap.

#### Seed Database dengan Data Awal

**PENTING:** Sebelum run server, seed database dengan data testing!

```powershell
npx prisma db seed
```

**Expected output:**
```
🌱 Starting seed...
✅ 5 Roles created (Admin, Cashier, Chef, Waiter, Employee)
✅ 8 Users created with bcrypt passwords
✅ 126 Attendance records created (30 days)
✅ 42 Income reports created
🎉 Database seeded successfully!
```

**Script ini akan membuat:**
- **5 Roles:** Admin, Cashier, Chef, Waiter, Employee (dengan gaji berbeda)
- **8 Users:**
  - Admin: `admin@restoran.com` / `admin123`
  - 2 Cashier: Gilang Ramadhan, Siti Nurhaliza
  - 2 Chef: Budi Santoso, Hana Safitri
  - 2 Waiter: Dewi Lestari, Fitri Handayani
  - 1 Employee: Eko Prasetyo
- **126 Attendance records:** 30 hari kerja dengan variasi (hadir, telat, alpha)
- **42 Income reports:** Laporan pemasukan per shift

**Lihat:** `docs/SEEDER-INFO.md` untuk detail lengkap data seeder.

> ⚠️ **JANGAN SKIP LANGKAH INI!** Jika tidak seed:
> - Database kosong, tidak ada roles
> - API `/auth/register` akan error: `Foreign key constraint violated`
> - Tidak bisa register user baru karena roleId tidak ada
> - Tidak bisa test slip gaji karena tidak ada data absensi
> - Solusi: Jalankan `npx prisma db seed` sekarang!

#### Generate Test Slip Gaji (Optional, Recommended)

**Setelah seed database**, generate slip gaji untuk testing:

```powershell
node docs/tools/generate-slip-gaji.js
```

**Expected output:**
```
🧾 Generating Slip Gaji for Oktober 2025...

📊 Found 7 employees (excluding Admin)

👤 Processing: Budi Santoso (Chef)
   ✅ Slip created successfully!
      Days Present: 28 | Alpha: 2
      Attendance Rate: 93.3%
      💰 NET SALARY: Rp 4.750.000

... (6 more employees)

✨ SUMMARY
   Total Slips Created: 7
   Total Payroll (Net): Rp 22.270.109
```

**Script ini akan membuat:**
- 7 Slip Gaji untuk bulan Oktober 2025
- Auto-calculate dari data absensi yang di-seed
- Bonus kehadiran berdasarkan attendance rate
- Special bonus untuk Chef dengan perfect attendance

**Kapan harus run:**
- ✅ **SETELAH** `npx prisma db seed` (butuh data absensi)
- ✅ Setelah update seeder dengan attendance baru
- ✅ Untuk testing API `/gaji/slip/*`
- ✅ Untuk verify calculation logic

**Jika slip sudah exist:**
```
⚠️ Slip already exists for 10/2025 - Skipping
```
Script akan skip, tidak akan duplicate.

**Lihat:** `docs/TEST-SLIP-GAJI.md` untuk hasil lengkap dan test cases.

**Test koneksi (optional):**
```powershell
node test-db.js
```

#### Jalankan Server

```powershell
npm run dev
```

Buka browser: http://localhost:3000/db/ping

Response sukses:
```json
{
  "ok": true,
  "db": "db_restoran",
  "server": "NAMA-PC",
  "instance": null
}
```

---

### 4. Setup Frontend (Flutter)

```powershell
cd ..\frontend
flutter pub get
```

#### Konfigurasi API Endpoint

Edit `lib/services/api.dart` (atau file serupa):
```dart
// Untuk emulator Android
static const String baseUrl = 'http://10.0.2.2:3000';

// Untuk device fisik (ganti dengan IP PC kamu)
// static const String baseUrl = 'http://192.168.1.10:3000';
```

#### Jalankan Flutter App

**Android Emulator:**
```powershell
flutter run
```

**Device Fisik (pastikan di jaringan yang sama):**
1. Cek IP PC kamu:
   ```powershell
   ipconfig
   # Cari IPv4 Address (contoh: 192.168.1.10)
   ```
2. Update `baseUrl` di Flutter
3. Pastikan firewall allow port 3000:
   ```powershell
   netsh advfirewall firewall add rule name="Node API" dir=in action=allow protocol=TCP localport=3000
   ```
4. Jalankan:
   ```powershell
   flutter run
   ```

---

## ✅ Setup Checklist

Gunakan checklist ini untuk memastikan semua langkah sudah dilakukan:

### 1. Prerequisites
- [ ] SQL Server Express installed
- [ ] Node.js v16+ installed
- [ ] Flutter SDK installed (untuk frontend)
- [ ] Git installed

### 2. SQL Server Setup
- [ ] SQL Server service running
- [ ] TCP/IP protocol enabled (SQL Server Configuration Manager)
- [ ] Port 1433 configured (bukan dynamic port)
- [ ] Mixed Authentication mode enabled
- [ ] SQL Server service restarted setelah konfigurasi

### 3. Database & User Setup
- [ ] Database `db_restoran` created (`script.sql`)
- [ ] User `prisma_user` created (`setup-sql-login.sql`)
- [ ] Permissions granted (`grant-create-db.sql`)
- [ ] Test connection berhasil (`node docs/errors/tools/test-connection.js`)

### 4. Backend Setup
- [ ] Dependencies installed (`npm install`)
- [ ] File `.env` created dengan config yang benar
- [ ] Schema synced (`npx prisma db push`)
- [ ] Prisma Client generated (`npx prisma generate`)
- [ ] **Timestamps added** (`sqlcmd -i docs/tools/add-timestamps-all-tables.sql`) ⭐
- [ ] Timestamps verified (`npx prisma generate` ulang)

### 5. Data Seeding
- [ ] Database seeded (`npx prisma db seed`)
- [ ] 8 users created (verify via Prisma Studio)
- [ ] 126 attendance records created
- [ ] 42 income reports created
- [ ] Test slip gaji generated (`node docs/tools/generate-slip-gaji.js`)
- [ ] 7 slip gaji for Oktober 2025 created

### 6. Verification
- [ ] Prisma Studio opens without errors (`npx prisma studio`)
- [ ] No "createdAt does not exist" errors
- [ ] All tables visible (User, Role, Absensi, Jadwal, LaporanPemasukan, SlipGaji)
- [ ] Server starts without errors (`npm run dev`)
- [ ] API accessible (http://localhost:3000/db/ping)
- [ ] Login endpoint works (POST `/auth/login`)

### 7. Optional (Recommended)
- [ ] Read `docs/API.md` untuk API documentation
- [ ] Read `docs/SEEDER-INFO.md` untuk seeder details
- [ ] Read `docs/SLIP-GAJI-GUIDE.md` untuk slip gaji system
- [ ] Test API dengan Postman (lihat `docs/POSTMAN.md`)

---

## 📋 Quick Command Reference

**Complete setup dari awal:**
```powershell
# 1. Setup SQL Server
sqlcmd -S .\SQLEXPRESS -E -i ../script.sql
sqlcmd -S .\SQLEXPRESS -E -i docs/errors/tools/setup-sql-login.sql
sqlcmd -S .\SQLEXPRESS -E -i docs/errors/tools/grant-create-db.sql

# 2. Install & sync
cd backend
npm install
npx prisma db push
npx prisma generate

# 3. Fix timestamps (WAJIB!)
sqlcmd -S .\SQLEXPRESS -E -i docs/tools/add-timestamps-all-tables.sql
npx prisma generate

# 4. Seed database
npx prisma db seed

# 5. Generate test data
node docs/tools/generate-slip-gaji.js

# 6. Verify
node docs/errors/tools/test-connection.js
npx prisma studio

# 7. Run server
npm run dev
```

**Daily development workflow:**
```powershell
# Start backend
cd backend
npm run dev

# Start frontend (terminal baru)
cd frontend
flutter run

# View database (terminal baru)
cd backend
npx prisma studio
```

**Setelah pull changes dari git:**
```powershell
cd backend

# Update dependencies
npm install

# Sync schema
npx prisma generate

# If schema changed
npx prisma db push
npx prisma generate

# If error createdAt
sqlcmd -S .\SQLEXPRESS -E -i docs/tools/add-timestamps-all-tables.sql
npx prisma generate

# Restart server
npm run dev
```

---

## 🔧 Troubleshooting

### Error: "createdAt does not exist"
**Penyebab:** Timestamps belum ditambahkan ke database setelah `npx prisma db push`

**Solusi:**
```powershell
sqlcmd -S .\SQLEXPRESS -E -i docs/tools/add-timestamps-all-tables.sql
npx prisma generate
npx prisma studio  # Verify
```

**Lihat:** `docs/errors/FIX-CREATEDAT-ERROR.md` untuk troubleshooting lengkap

### Error: "Can't reach database server"
- Pastikan SQL Server service running: `services.msc` → SQL Server (SQLEXPRESS)
- Pastikan TCP/IP enabled di SQL Server Configuration Manager dan set port 1433
- Test koneksi: `sqlcmd -S localhost,1433 -U prisma_user -P "Prisma!2025" -Q "SELECT DB_NAME()"`

**Lihat:** `docs/errors/ERROR-P1001.md`

### Error: "Authentication failed"
- Jalankan ulang `backend\docs\errors\tools\setup-sql-login.sql`
- Pastikan Mixed Authentication mode aktif
- Restart SQL Server service

**Lihat:** `docs/errors/ERROR-P1000.md`

### Error: "Shadow database permission denied"
- Jalankan `backend\docs\errors\tools\grant-create-db.sql`
- Atau pakai `npx prisma db push` (tidak butuh shadow DB)

### Error: "Failed to connect to localhost\SQLEXPRESS in 15000ms"
- **Penyebab:** Konflik antara `port: 1433` dan `instanceName: SQLEXPRESS`
- **Solusi:** Hapus `instanceName` dari sqlConfig di `index.js` (sudah diperbaiki)
- Pastikan SQL Server listen di port 1433 (bukan dynamic port)

### Error: "@prisma/client did not initialize yet"
- Jalankan: `npx prisma generate`
- Pastikan import dari `@prisma/client` (bukan custom path)
- Restart nodemon atau server

### Error: "Connection refused" dari Flutter
- Pastikan backend running (`npm run dev`)
- Untuk emulator, pakai `http://10.0.2.2:3000`
- Untuk device fisik, pakai IP PC (contoh: `http://192.168.1.10:3000`)
- Cek firewall allow port 3000

**Untuk troubleshooting lengkap:** `docs/TROUBLESHOOTING.md`  
**Untuk quick fixes:** `docs/QUICK-FIX.md`

---

## 📚 Dokumentasi Tambahan

- **API Reference:** `backend/docs/API.md`
- **Field Shift Rules:** `backend/docs/SHIFT.md`
- **Contributing Guide:** `backend/docs/CONTRIBUTING.md`
- **Changelog:** `backend/docs/CHANGELOG.md`

---

## 🛠️ Development Workflow

### Jalankan Backend (mode development)
```powershell
cd backend
npm run dev  # jika ada nodemon
# atau
node index.js
```

### Lihat Database via Prisma Studio
```powershell
cd backend
npx prisma studio
```
Buka: http://localhost:5555

### Jalankan Flutter (hot reload)
```powershell
cd frontend
flutter run
```

---

## 📝 Catatan Penting

1. **Field `shift` hanya boleh:** `"pagi"`, `"siang"`, `"malam"` (lihat `backend/docs/SHIFT.md`)
2. **Password di DB harus di-hash** (gunakan bcrypt, jangan simpan plain text)
3. **Setiap perubahan API wajib update dokumentasi** di `backend/docs/API.md`
4. **Untuk production:** 
   - Ganti password `prisma_user`
   - Aktifkan SSL/TLS (`encrypt=true`)
   - Pakai `prisma migrate deploy` (bukan `db push`)

---

## 🆘 Butuh Bantuan?

- Baca dokumentasi: `backend/docs/README.md`
- Check issues di GitHub
- Contact: [maintainer email/contact]

---

**Good luck! 🚀**
