# 🔧 Fix: Error "Unknown argument jamMulaiShift" saat Seed

## Problem

Error saat menjalankan `npx prisma db seed`:

```
# Error: Unknown Argument jamMulaiShift

## ⚠️ Error Message

```
Invalid `prisma.absensi.create()` invocation:

Unknown argument `jamMulaiShift`. Available options are marked with ?.
```

## 🔍 Root Cause

Schema database kamu **TIDAK SYNC** dengan schema di repository. Kemungkinan:
1. Database kamu punya field berbeda (misal: `gajiDihasilkan`, `jamKerjaReguler`)
2. Repository punya field: `jamMulaiShift`, `jamSelesaiShift`
3. Seeder pakai field dari repository tapi database kamu tidak punya field tersebut

## ✅ Solusi TERBAIK: Sync Database

**📖 Baca panduan lengkap:** [🔄 SYNC-DATABASE.md](../SYNC-DATABASE.md)

### Quick Fix (RECOMMENDED) ⭐

```powershell
cd backend

# Reset database dan sync dengan repository
npx prisma db push --force-reset

# Generate Prisma Client
npx prisma generate

# Seed database dengan data testing
npx prisma db seed

# (Opsional) Generate slip gaji
node docs/tools/generate-slip-gaji.js
```

**PERINGATAN:** `--force-reset` akan **HAPUS SEMUA DATA** di database!

## 🔧 Solusi Alternatif
    at prisma.absensi.create()

Available options:
  id?: Int,
  gajiDihasilkan?: Float,
  jamKerjaKurang?: Float,
  jamKerjaLembur?: Float,
  jamKerjaReguler?: Float
```

## Root Cause

Schema Prisma di local kamu berbeda dengan seeder yang ada di repository. Ada 2 kemungkinan:

1. **Schema kamu lebih lama** - Belum ada field `jamMulaiShift` dan `jamSelesaiShift`
2. **Schema kamu lebih baru** - Sudah ganti struktur ke `gajiDihasilkan`, `jamKerjaReguler`, dll.

## Solution

### Option 1: Pull Schema Terbaru dari Database (Recommended)

Jika kamu sudah punya database yang working, sync schema dari database:

```powershell
cd backend

# Pull schema dari database
npx prisma db pull

# Generate Prisma Client
npx prisma generate

# Coba seed lagi
npx prisma db seed
```

**Jika masih error**, lanjut ke Option 2.

---

### Option 2: Reset Database & Use Latest Schema

**⚠️ WARNING: Ini akan HAPUS semua data di database!**

```powershell
cd backend

# 1. Backup data penting (jika ada)

# 2. Drop semua tabel
sqlcmd -S .\SQLEXPRESS -E -Q "USE db_restoran; EXEC sp_MSforeachtable 'DROP TABLE ?'"

# 3. Push schema dari repository
npx prisma db push

# 4. Add timestamps (WAJIB!)
sqlcmd -S .\SQLEXPRESS -E -i docs/tools/add-timestamps-all-tables.sql

# 5. Generate Prisma Client
npx prisma generate

# 6. Seed database
npx prisma db seed

# 7. Generate slip gaji
node docs/tools/generate-slip-gaji.js
```

---

### Option 3: Update Schema.prisma ke Versi Terbaru

Jika `npx prisma db pull` tidak work, copy schema manual dari repository terbaru:

1. **Pull changes dari GitHub:**
```powershell
git pull origin main
```

2. **Check apakah schema.prisma berubah:**
```powershell
git diff backend/prisma/schema.prisma
```

3. **Jika ada conflict, resolve dengan:**
```powershell
# Accept incoming changes (dari GitHub)
git checkout --theirs backend/prisma/schema.prisma
git add backend/prisma/schema.prisma
```

4. **Push schema ke database:**
```powershell
cd backend
npx prisma db push
sqlcmd -S .\SQLEXPRESS -E -i docs/tools/add-timestamps-all-tables.sql
npx prisma generate
```

5. **Seed database:**
```powershell
npx prisma db seed
```

---

### Option 4: Verify Schema Model Absensi

Pastikan model `Absensi` di `backend/prisma/schema.prisma` seperti ini:

```prisma
model Absensi {
  id              Int       @id @default(autoincrement())
  jamMasuk        DateTime  @default(now())
  jamKeluar       DateTime?
  userId          Int
  createdAt       DateTime  @default(now())
  jamKerja        Float     @default(0)
  jamMulaiShift   DateTime
  jamSelesaiShift DateTime
  menitTerlambat  Int       @default(0)
  potonganGaji    Float     @default(0)
  shift           String
  status          String    @default("Hadir")
  tanggal         DateTime  @default(now()) @db.Date
  totalGaji       Float     @default(0)
  updatedAt       DateTime  @default(now())
  user            User      @relation(fields: [userId], references: [id])
}
```

**Jika berbeda:**
1. Copy model di atas
2. Paste ke `backend/prisma/schema.prisma`
3. Jalankan `npx prisma db push`
4. Jalankan `npx prisma generate`
5. Jalankan `npx prisma db seed`

---

## Verification

Setelah fix, verify dengan:

```powershell
# 1. Check Prisma Client generated
npx prisma generate

# 2. Run seed
npx prisma db seed
```

**Expected output:**
```
🌱 Seeding database...

📌 Creating roles...
   ✅ Admin (ID: 1)
   ✅ Cashier (ID: 2)
   ✅ Chef (ID: 3)
   ✅ Waiter (ID: 4)
   ✅ Employee (ID: 5)

📌 Creating users with diverse roles...
   ✅ Ahmad Rizki (Admin) - admin@restoran.com
   ... (7 more users)

📌 Creating attendance history (last 30 days)...
   ✅ Created 126 attendance records

📌 Creating income reports (last 30 days)...
   ✅ Created 42 income reports

✅ Seed completed successfully!
```

**Verify di Prisma Studio:**
```powershell
npx prisma studio
```

Buka http://localhost:5557 dan check:
- ✅ 8 users exist
- ✅ 126 absensi records exist
- ✅ 42 laporanPemasukan records exist
- ✅ All fields populated correctly

---

## Troubleshooting

### Error: "Can't reach database server"
**Solution:**
```powershell
# Test connection
node docs/errors/tools/test-connection.js

# If fails, check SQL Server
docs/errors/tools/diagnose-sql.ps1
```

### Error: "Foreign key constraint violated"
**Penyebab:** Roles belum dibuat atau ID tidak match.

**Solution:**
```powershell
# Delete all data
DELETE FROM Absensi;
DELETE FROM LaporanPemasukan;
DELETE FROM SlipGaji;
DELETE FROM [User];
DELETE FROM Role;

# Seed again
npx prisma db seed
```

### Error: "Unique constraint failed"
**Penyebab:** Data sudah ada di database.

**Solution:**
```powershell
# Option A: Delete existing data (see above)

# Option B: Skip seed if data exists (modify seed.js)
# Seeder sudah handle ini dengan try-catch
```

---

## Prevention

Untuk menghindari issue ini di masa depan:

1. **Selalu pull changes dari GitHub sebelum coding:**
```powershell
git pull origin main
```

2. **Selalu generate Prisma Client setelah pull:**
```powershell
cd backend
npx prisma generate
```

3. **Jika schema berubah, push ke database:**
```powershell
npx prisma db push
sqlcmd -S .\SQLEXPRESS -E -i docs/tools/add-timestamps-all-tables.sql
npx prisma generate
```

4. **Komunikasi dengan team jika ada perubahan schema:**
   - Buat PR dengan jelas mention "BREAKING CHANGE: Schema updated"
   - Share migration script di grup
   - Update documentation

---

## Related Documentation

- **Setup Guide:** `docs/SETUP.md`
- **Seeder Info:** `docs/SEEDER-INFO.md`
- **Troubleshooting:** `docs/TROUBLESHOOTING.md`
- **Schema Sync Issues:** `docs/errors/ERROR-P1000.md`

---

**Created:** November 11, 2025  
**Last Updated:** November 11, 2025
