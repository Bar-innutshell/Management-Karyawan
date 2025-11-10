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

## Root Cause

Database belum punya field `createdAt` dan `updatedAt` di table `User`. Ini terjadi karena:
- Database dibuat sebelum field ini ditambahkan ke schema
- Migration belum dijalankan
- Schema Prisma tidak sync dengan database

## Solution (Step by Step)

### Option 1: Quick Fix (Recommended)

```powershell
# 1. Masuk ke folder backend
cd backend

# 2. Jalankan migration SQL
sqlcmd -S .\SQLEXPRESS -E -i add-user-timestamps.sql

# 3. Generate Prisma Client
npx prisma generate

# 4. Test dengan Prisma Studio
npx prisma studio
# Buka http://localhost:5557
```

**Selesai!** Error seharusnya hilang.

---

### Option 2: Manual via SQL Server Management Studio (SSMS)

Jika `sqlcmd` tidak work, jalankan query ini di SSMS:

```sql
USE db_restoran;
GO

-- Add createdAt column
ALTER TABLE [User]
ADD createdAt DATETIME2 NOT NULL DEFAULT GETDATE();

-- Add updatedAt column
ALTER TABLE [User]
ADD updatedAt DATETIME2 NOT NULL DEFAULT GETDATE();
GO
```

Lalu:
```powershell
cd backend
npx prisma generate
```

---

### Option 3: Sync Schema dari Database

Jika database teman kamu berbeda total:

```powershell
cd backend

# Pull schema dari database
npx prisma db pull

# Generate Prisma Client
npx prisma generate

# Restart server
node index.js
```

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
sqlcmd -S .\SQLEXPRESS -U prisma_user -P prisma123 -i add-user-timestamps.sql
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

## Files Created

- ✅ `backend/add-user-timestamps.sql` - Migration untuk fix error ini
- ✅ Schema Prisma sudah updated
- ✅ Prisma Client sudah di-generate

---

## Need Help?

1. Cek `TROUBLESHOOTING.md` untuk masalah umum lainnya
2. Cek `QUICK-FIX.md` untuk setup SQL Server
3. Buka issue di GitHub atau tanya di grup

---

**Created**: November 11, 2025  
**Status**: ✅ Fixed
