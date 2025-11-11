# Backend Documentation

Lokasi: `backend/`

Dokumentasi ini berisi API reference, aturan khusus (mis. field shift), panduan kontribusi, changelog, dan error troubleshooting untuk server Node + SQL Server.

## 📁 Struktur Dokumentasi

### API & Development
- **[API.md](API.md)** — Kontrak endpoint dan contoh request/response
- **[POSTMAN.md](POSTMAN.md)** — Panduan testing dengan Postman
- **[SHIFT.md](SHIFT.md)** — Penjelasan field `shift` (nilai: `pagi`, `siang`, `malam`)
- **[LAPORAN-GAJI-ABSENSI.md](LAPORAN-GAJI-ABSENSI.md)** — Penjelasan sistem laporan gaji dan absensi
- **[SLIP-GAJI-GUIDE.md](SLIP-GAJI-GUIDE.md)** — Panduan lengkap sistem slip gaji bulanan
- **[CONTRIBUTING.md](CONTRIBUTING.md)** — Proses kontribusi dan update dokumentasi
- **[CHANGELOG.md](CHANGELOG.md)** — Riwayat perubahan

### Setup & Onboarding
- **[SETUP.md](SETUP.md)** — Panduan setup lengkap untuk teammate baru
- **[🔄 SYNC-DATABASE.md](SYNC-DATABASE.md)** — ⭐ **PENTING!** Sinkronisasi database dengan tim
- **[QUICK-FIX.md](QUICK-FIX.md)** — Quick fixes untuk masalah umum
- **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** — Troubleshooting panduan komprehensif

### Testing & Tools
- **[SEEDER-INFO.md](SEEDER-INFO.md)** — Panduan menggunakan database seeder
- **[TEST-SLIP-GAJI.md](TEST-SLIP-GAJI.md)** — Test cases dan hasil generate slip gaji
- **`../prisma/seed.js`** — Database seeder (8 users, 126 attendance, 42 income)
- **[tools/](tools/)** — 📂 Folder tools dan scripts
  - **[tools/README.md](tools/README.md)** — Complete tools documentation
  - **[tools/add-timestamps-all-tables.sql](tools/add-timestamps-all-tables.sql)** — ⭐ Add createdAt/updatedAt to ALL tables
  - **[tools/add-user-timestamps.sql](tools/add-user-timestamps.sql)** — Add createdAt/updatedAt to User table only
  - **[tools/generate-slip-gaji.js](tools/generate-slip-gaji.js)** — Auto-generator slip gaji bulanan
  - **[tools/migrate-gaji-naming.sql](tools/migrate-gaji-naming.sql)** — Migrate gaji field naming consistency

### Error Troubleshooting
- **[errors/](errors/)** — 📂 Folder error documentation
  - **[errors/README.md](errors/README.md)** — Index semua error dan tools
  - **[errors/FIX-CREATEDAT-ERROR.md](errors/FIX-CREATEDAT-ERROR.md)** — Fix createdAt column error
  - **[errors/ERROR-P1001.md](errors/ERROR-P1001.md)** — Can't reach database server
  - **[errors/ERROR-P1000.md](errors/ERROR-P1000.md)** — Authentication failed
  - **[errors/ERROR-EPERM.md](errors/ERROR-EPERM.md)** — Permission denied errors
  - **[errors/ERROR-FOREIGN-KEY.md](errors/ERROR-FOREIGN-KEY.md)** — Foreign key constraint errors
  - **[errors/MIGRATION-COMPLETE.md](errors/MIGRATION-COMPLETE.md)** — Migration completion guide
  - **[errors/TOOLS-MIGRATION.md](errors/TOOLS-MIGRATION.md)** — Migration tools guide
  - **[errors/tools/](errors/tools/)** — 📂 Setup & diagnostic tools
    - **[errors/tools/setup-sql-login.sql](errors/tools/setup-sql-login.sql)** — Script buat user SQL Server otomatis
    - **[errors/tools/enable-sql-auth.ps1](errors/tools/enable-sql-auth.ps1)** — Enable Mixed Authentication mode
    - **[errors/tools/grant-create-db.sql](errors/tools/grant-create-db.sql)** — Grant dbcreator permission
    - **[errors/tools/diagnose-sql.ps1](errors/tools/diagnose-sql.ps1)** — Auto-diagnostic tool untuk SQL Server issues
    - **[errors/tools/diagnose-sql.bat](errors/tools/diagnose-sql.bat)** — Batch version diagnostic tool
    - **[errors/tools/test-connection.js](errors/tools/test-connection.js)** — Test koneksi database
    - **[errors/tools/fix-eperm.ps1](errors/tools/fix-eperm.ps1)** — Fix EPERM errors

---

## 🚀 Quick Start untuk Teammate

### Step 1: Install Dependencies
```bash
cd backend
npm install
```

### Step 2: Setup SQL Server

**Option A: Via sqlcmd (Quick)**
```powershell
# Buat database
sqlcmd -S .\SQLEXPRESS -E -i ../script.sql

# Buat user prisma_user
sqlcmd -S .\SQLEXPRESS -E -i docs/errors/tools/setup-sql-login.sql

# Grant permissions
sqlcmd -S .\SQLEXPRESS -E -i docs/errors/tools/grant-create-db.sql
```

**Option B: Via SSMS (Manual)**
- Jalankan `script.sql` di SSMS untuk membuat database `db_restoran`
- Jalankan `backend/docs/errors/tools/setup-sql-login.sql` untuk membuat login `prisma_user`
- Jalankan `backend/docs/errors/tools/grant-create-db.sql` untuk beri permission CREATE DATABASE
- Aktifkan Mixed Authentication mode:
  - SSMS > klik kanan server > Properties > Security > pilih "SQL Server and Windows Authentication mode"
  - Restart SQL Server service di services.msc
- Pastikan SQL Server listen di port 1433:
  - SQL Server Configuration Manager > Protocols for SQLEXPRESS > TCP/IP > IPAll > TCP Port = 1433

### Step 3: Configure Environment

Buat file `.env` di folder `backend/`:
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

**⚠️ PENTING:** JANGAN tambahkan `instanceName` ke sqlConfig karena konflik dengan port 1433.

### Step 4: Sync Database Schema

```bash
# Push schema ke database
npx prisma db push

# Generate Prisma Client
npx prisma generate
```

### Step 5: Add Timestamps (WAJIB!)

**Jika teammate dapat error "createdAt does not exist":**

```powershell
# Run migration untuk menambahkan timestamps ke semua tabel
sqlcmd -S .\SQLEXPRESS -E -i docs/tools/add-timestamps-all-tables.sql

# Generate ulang Prisma Client
npx prisma generate
```

**Lihat:** `docs/errors/FIX-CREATEDAT-ERROR.md` untuk troubleshooting lengkap.

### Step 6: Seed Database (Optional, Recommended)

```bash
# Seed database dengan data testing:
# - 8 users (5 roles berbeda)
# - 126 attendance records
# - 42 income reports
npx prisma db seed
```

**Expected output:**
```
✅ 8 users created
✅ 126 attendance records created
✅ 42 income reports created
🎉 Seeding completed!
```

**Lihat:** `docs/SEEDER-INFO.md` untuk detail data yang di-seed.

### Step 7: Generate Test Slip Gaji (Optional)

```bash
# Generate slip gaji untuk Oktober 2025
node docs/tools/generate-slip-gaji.js
```

**Expected output:**
```
✅ 7 slip gaji created
💰 Total Payroll: Rp 22.270.109
```

**Lihat:** `docs/TEST-SLIP-GAJI.md` untuk hasil lengkap.

### Step 8: Test Connection

```bash
# Test database connection
node docs/errors/tools/test-connection.js
```

**Expected:**
```
✅ Connection SUCCESSFUL!
✅ Query execution SUCCESSFUL!
🎉 ALL TESTS PASSED!
```

### Step 9: Run Server

```bash
# Start development server
npm run dev

# Or production mode
node index.js
```

**Expected:**
```
Server running on port 3000
Database connected: db_restoran
```

### Step 10: Verify dengan Prisma Studio

```bash
# Open Prisma Studio
npx prisma studio
```

Buka browser: http://localhost:5557

**Verify:**
- ✅ Semua tabel visible (User, Role, Absensi, Jadwal, LaporanPemasukan, SlipGaji)
- ✅ Data seeder ada (8 users, 126 attendance)
- ✅ Slip gaji ada (7 slips untuk Oktober 2025)
- ✅ No createdAt/updatedAt errors

---

## 📋 Complete Command Checklist

Copy-paste commands ini secara berurutan:

```powershell
# 1. Install dependencies
cd backend
npm install

# 2. Setup SQL Server (pilih salah satu)
sqlcmd -S .\SQLEXPRESS -E -i ../script.sql
sqlcmd -S .\SQLEXPRESS -E -i docs/errors/tools/setup-sql-login.sql
sqlcmd -S .\SQLEXPRESS -E -i docs/errors/tools/grant-create-db.sql

# 3. Buat file .env (copy dari contoh di atas)

# 4. Sync schema
npx prisma db push
npx prisma generate

# 5. Add timestamps (WAJIB jika error createdAt)
sqlcmd -S .\SQLEXPRESS -E -i docs/tools/add-timestamps-all-tables.sql
npx prisma generate

# 6. Seed database
npx prisma db seed

# 7. Generate test slip gaji
node docs/tools/generate-slip-gaji.js

# 8. Test connection
node docs/errors/tools/test-connection.js

# 9. Run server
npm run dev

# 10. Verify (terminal baru)
npx prisma studio
```

**Total waktu setup:** ~10-15 menit (jika SQL Server sudah installed)

---

## 🆘 Troubleshooting

**Jika ada error:**

1. **"createdAt does not exist"**
   - Solusi: `docs/errors/FIX-CREATEDAT-ERROR.md`
   - Quick fix: `sqlcmd -S .\SQLEXPRESS -E -i docs/tools/add-timestamps-all-tables.sql`

2. **"Can't reach database server"**
   - Solusi: `docs/errors/ERROR-P1001.md`
   - Quick fix: `docs/errors/tools/diagnose-sql.ps1`

3. **"Authentication failed"**
   - Solusi: `docs/errors/ERROR-P1000.md`
   - Quick fix: Re-run `docs/errors/tools/setup-sql-login.sql`

4. **General troubleshooting:**
   - Lihat: `docs/TROUBLESHOOTING.md`
   - Quick fixes: `docs/QUICK-FIX.md`

---

## Catatan Penting

- Field `shift` disimpan sebagai string di database. Backend wajib memvalidasi nilainya sebelum menyimpan.
- SELALU update dokumentasi setiap ada perubahan API agar frontend mudah integrasi.
- Jika ada error, cek folder **[errors/](errors/)** terlebih dahulu sebelum troubleshoot manual.
- **WAJIB** jalankan `add-timestamps-all-tables.sql` setelah `npx prisma db push` untuk menghindari error createdAt.

---

## 📚 Old Setup Guide (Reference)

<details>
<summary>Click to expand detailed setup (deprecated, use Quick Start above)</summary>

1. **Install dependencies:**
   ```bash
   cd backend
   npm install
   ```

2. **Setup SQL Server:**
   - Jalankan `backend/docs/errors/tools/setup-sql-login.sql` di SSMS untuk membuat login `prisma_user`.
   - Jalankan `backend/docs/errors/tools/grant-create-db.sql` untuk beri permission CREATE DATABASE (opsional, untuk migrate).
   - Aktifkan Mixed Authentication mode (SQL + Windows Auth):
     - SSMS > klik kanan server > Properties > Security > pilih "SQL Server and Windows Authentication mode"
     - Restart SQL Server service di services.msc
   - Pastikan SQL Server listen di port 1433 (bukan dynamic port):
     - SQL Server Configuration Manager > Protocols for SQLEXPRESS > TCP/IP > IPAll > TCP Port = 1433

3. **Konfigurasi `.env`:**
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
   
   **PENTING:** JANGAN tambahkan `instanceName` ke sqlConfig karena konflik dengan port 1433.

4. **Sinkronkan database schema:**
   ```bash
   npx prisma db push
   npx prisma generate
   ```

5. **Test koneksi (opsional):**
   ```bash
   node test-db.js
   ```
   
   Expected: `✅ Connected to SQL Server`

6. **Jalankan server:**
   ```bash
   npm run dev
   ```
   Akses: http://localhost:3000/db/ping
   
   Expected response:
   ```json
   {
     "ok": true,
     "db": "db_restoran",
     "server": "NAMA-PC",
     "instance": null
   }
   ```