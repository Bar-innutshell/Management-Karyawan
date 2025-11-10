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
- **[QUICK-FIX.md](QUICK-FIX.md)** — Quick fixes untuk masalah umum
- **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** — Troubleshooting panduan komprehensif

### Testing & Tools
- **[SEEDER-INFO.md](SEEDER-INFO.md)** — Panduan menggunakan database seeder
- **[TEST-SLIP-GAJI.md](TEST-SLIP-GAJI.md)** — Test cases dan hasil generate slip gaji
- **`../prisma/seed.js`** — Database seeder (8 users, 126 attendance, 42 income)
- **`../prisma/generate-slip-gaji.js`** — Auto-generator slip gaji bulanan

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

### SQL Migration Scripts
- **`../add-user-timestamps.sql`** — Add createdAt/updatedAt to User table
- **`../migrate-gaji-naming.sql`** — Migrate gaji field naming consistency
- **`setup-sql-login.sql`** — Script buat user SQL Server otomatis
- **`enable-sql-auth.ps1`** — Enable Mixed Authentication mode
- **`grant-create-db.sql`** — Grant dbcreator permission
- **`diagnose-sql.ps1`** — Auto-diagnostic tool untuk SQL Server issues
- **`diagnose-sql.bat`** — Batch version diagnostic tool
- **`test-connection.js`** — Test koneksi database

---

## Catatan Penting

- Field `shift` disimpan sebagai string di database. Backend wajib memvalidasi nilainya sebelum menyimpan.
- SELALU update dokumentasi setiap ada perubahan API agar frontend mudah integrasi.
- Jika ada error, cek folder **[errors/](errors/)** terlebih dahulu sebelum troubleshoot manual.

---

1. **Install dependencies:**
   ```bash
   cd backend
   npm install
   ```

2. **Setup SQL Server:**
   - Jalankan `backend/setup-sql-login.sql` di SSMS untuk membuat login `prisma_user`.
   - Jalankan `backend/grant-create-db.sql` untuk beri permission CREATE DATABASE (opsional, untuk migrate).
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