# 🔧 Fix: Error "Column createdAt does not exist"

## Problem

Jika teman kamu mendapat error seperti ini saat buka Prisma Studio atau menjalankan aplikasi:

```
The column createdAt does not exist in the current database.
```

atau

```
The column updatedAt does not exist in the current database.
```

**Error bisa muncul di tabel:**
- ❌ `User`
- ❌ `Absensi`
- ❌ `Jadwal`
- ❌ `LaporanPemasukan`

## Root Cause

Database belum punya field `createdAt` dan `updatedAt`. Ini terjadi karena:
- Database dibuat sebelum field ini ditambahkan ke schema
- Migration belum dijalankan
- Schema Prisma tidak sync dengan database

## Solution (Step by Step)

### Option 1: Quick Fix - All Tables ⭐ **Recommended**

Gunakan ini jika error muncul di **Absensi, Jadwal, atau LaporanPemasukan**:

```powershell
# 1. Masuk ke project root
cd C:\Projek\AndroidFreaky\01-SbdlPakeMysql

# 2. Jalankan migration SQL untuk SEMUA tabel
sqlcmd -S .\SQLEXPRESS -E -i backend\docs\tools\add-timestamps-all-tables.sql

# 3. Masuk ke backend folder
cd backend

# 4. Generate Prisma Client
npx prisma generate

# 5. Test dengan Prisma Studio
npx prisma studio
# Buka http://localhost:5557
```

**Selesai!** Error seharusnya hilang di semua tabel.

---

### Option 3: Manual via SQL Server Management Studio (SSMS)

Jika `sqlcmd` tidak work, jalankan script ini di SSMS untuk **semua tabel**:

**File:** `backend\docs\tools\add-timestamps-all-tables.sql`

1. Buka SSMS → Connect ke SQL Server
2. File → Open → File...
3. Pilih `backend\docs\tools\add-timestamps-all-tables.sql`
4. Execute (F5)
5. Lihat output messages untuk konfirmasi

Atau copy-paste manual query dari file tersebut.

---

## Alternative: Manual SQL (Copy-Paste)

Jika tidak ada akses ke file SQL, jalankan query ini di SSMS:

```sql
USE db_restoran;
GO

-- ===== USER TABLE =====
ALTER TABLE [User]
ADD createdAt DATETIME2 NOT NULL DEFAULT GETDATE();

ALTER TABLE [User]
ADD updatedAt DATETIME2 NOT NULL DEFAULT GETDATE();

-- ===== ABSENSI TABLE =====
ALTER TABLE Absensi
ADD createdAt DATETIME2 NOT NULL DEFAULT GETDATE();

ALTER TABLE Absensi
ADD updatedAt DATETIME2 NOT NULL DEFAULT GETDATE();

-- ===== JADWAL TABLE =====
ALTER TABLE Jadwal
ADD createdAt DATETIME2 NOT NULL DEFAULT GETDATE();

ALTER TABLE Jadwal
ADD updatedAt DATETIME2 NOT NULL DEFAULT GETDATE();

-- ===== LAPORANPEMASUKAN TABLE =====
ALTER TABLE LaporanPemasukan
ADD createdAt DATETIME2 NOT NULL DEFAULT GETDATE();

ALTER TABLE LaporanPemasukan
ADD updatedAt DATETIME2 NOT NULL DEFAULT GETDATE();

GO
```

Lalu:
```powershell
cd backend
npx prisma generate
npx prisma studio  # Test
```

---

### Option 4: Sync Schema dari Database

Jika database teman kamu berbeda total dan ingin reset schema:

```powershell
cd backend

# Pull schema dari database (overwrite schema.prisma)
npx prisma db pull

# Generate Prisma Client
npx prisma generate

# Restart server
node index.js
```

**⚠️ Warning:** Option ini akan overwrite `schema.prisma` dengan struktur database yang ada.

---

## Verification

### Test 1: Prisma Studio
```powershell
cd backend
npx prisma studio
```

Buka http://localhost:5557, klik table **User**, harusnya bisa lihat data tanpa error.

### Test 2: API
```powershell
cd backend
node index.js
```

Server harusnya running tanpa error di http://localhost:3000

### Test 3: Login
```http
POST http://localhost:3000/auth/login
Content-Type: application/json

{
  "email": "admin@restoran.com",
  "password": "admin123"
}
```

Harusnya dapat token tanpa error.

---

## Prevention (Untuk Kedepan)

Setiap kali update dari GitHub yang ada perubahan schema:

```powershell
# 1. Pull update
git pull origin main

# 2. Check if there's migration SQL files
ls backend/*.sql

# 3. If ada, run migration
cd backend
sqlcmd -S .\SQLEXPRESS -E -i nama-migration.sql

# 4. Generate Prisma Client
npx prisma generate

# 5. Run server
node index.js
```

---

## Common Errors & Solutions

### Error: "sqlcmd is not recognized"

**Solution**: Install SQL Server Command Line Tools atau pakai SSMS untuk run SQL manual.

### Error: "Login failed for user"

**Solution**: Pakai Windows Authentication (`-E` flag) atau ganti dengan:
```powershell
sqlcmd -S .\SQLEXPRESS -U prisma_user -P prisma123 -i docs/tools/add-user-timestamps.sql
```

### Error: "Cannot open database"

**Solution**: Pastikan database `db_restoran` sudah dibuat. Kalau belum:
```sql
CREATE DATABASE db_restoran;
```

### Prisma Studio masih error

**Solution**:
```powershell
# Kill all node processes
Get-Process node -ErrorAction SilentlyContinue | Stop-Process -Force

# Clear node_modules dan reinstall
rm -r node_modules
npm install

# Generate ulang
npx prisma generate

# Try again
npx prisma studio
```

---

## Files Available

- ✅ `backend/docs/tools/add-timestamps-all-tables.sql` - Migration untuk **semua tabel** ⭐ **Recommended**
- ✅ `backend/docs/tools/add-user-timestamps.sql` - Migration untuk tabel `User` saja
- ✅ Schema Prisma sudah include timestamps
- ✅ Prisma Client auto-generated setelah migration

**Pilih script yang sesuai dengan error yang muncul!**

---

## Need Help?

1. Cek `../TROUBLESHOOTING.md` untuk masalah umum lainnya
2. Cek `../QUICK-FIX.md` untuk setup SQL Server
3. Buka issue di GitHub atau tanya di grup

---

**Created**: November 11, 2025  
**Status**: ✅ Fixed
