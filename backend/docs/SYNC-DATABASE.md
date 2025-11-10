# 🔄 Panduan Sinkronisasi Database

**PENTING!** Panduan ini untuk **menyamakan schema database** agar semua tim punya struktur yang **PERSIS SAMA**.

## ⚠️ Kapan Harus Sync Database?

Jalankan panduan ini jika:
- ✅ Baru clone repository
- ✅ Dapat error "Unknown argument jamMulaiShift" saat seed
- ✅ Dapat error "Column does not exist" saat run backend
- ✅ Setelah git pull dan ada perubahan di `schema.prisma`
- ✅ Database kamu tidak sync dengan tim

## 🎯 Langkah-Langkah Sinkronisasi

### Metode 1: Reset Database (RECOMMENDED) ⭐

**Cocok untuk:** Database development/testing yang boleh dihapus

```powershell
# 1. Masuk folder backend
cd backend

# 2. Reset database dan push schema dari repository
npx prisma db push --force-reset

# 3. Generate Prisma Client
npx prisma generate

# 4. Seed database dengan data testing
npx prisma db seed

# 5. (Opsional) Generate slip gaji untuk testing
node docs/tools/generate-slip-gaji.js
```

**Penjelasan:**
- `--force-reset` akan **DROP semua table** dan buat ulang sesuai `schema.prisma`
- Semua data lama akan **HILANG**
- Database akan **PERSIS** sama dengan schema di repository

### Metode 2: Manual Pull & Reset (AMAN) 🛡️

**Cocok untuk:** Kamu mau backup dulu atau mau lihat perbedaannya

```powershell
# 1. Backup schema sekarang
cd backend
npx prisma db pull
Copy-Item prisma/schema.prisma prisma/schema.prisma.old

# 2. Restore schema dari repository
git checkout prisma/schema.prisma

# 3. Push schema ke database (akan reset)
npx prisma db push --force-reset

# 4. Generate client
npx prisma generate

# 5. Seed data
npx prisma db seed
```

### Metode 3: Fresh Database Setup 🆕

**Cocok untuk:** Mau buat database baru dari nol

```powershell
# 1. Buat database baru di SQL Server (nama: db_restoran_new)
# Bisa lewat SSMS atau SQL command

# 2. Update .env dengan connection string baru
# DATABASE_URL="sqlserver://localhost:1433;database=db_restoran_new;..."

# 3. Push schema
cd backend
npx prisma db push

# 4. Generate client
npx prisma generate

# 5. Seed data
npx prisma db seed
```

## 📋 Checklist Setelah Sync

Pastikan semua langkah ini berhasil:

- [ ] **Prisma Generate**: `npx prisma generate` → berhasil tanpa error
- [ ] **Prisma Studio**: `npx prisma studio` → bisa buka semua table
- [ ] **Seed Success**: `npx prisma db seed` → terlihat 8 users, 131 attendance
- [ ] **Backend Running**: `node index.js` → server jalan di port 5000
- [ ] **Login Test**: POST ke `/api/auth/login` → bisa login dengan `admin@restoran.com`

## 🔍 Verifikasi Schema Sudah Sama

### Cek 1: Prisma Studio
```powershell
cd backend
npx prisma studio
```

Buka table **Absensi**, pastikan ada kolom:
- ✅ `jamMulaiShift` (DateTime)
- ✅ `jamSelesaiShift` (DateTime)
- ✅ `shift` (String)
- ✅ `jamMasuk` (DateTime)
- ✅ `jamKeluar` (DateTime nullable)
- ✅ `jamKerja` (Float)
- ✅ `menitTerlambat` (Int)
- ✅ `potonganGaji` (Float)
- ✅ `totalGaji` (Float)
- ✅ `status` (String)
- ✅ `tanggal` (Date)
- ✅ `userId` (Int)
- ✅ `createdAt` (DateTime)
- ✅ `updatedAt` (DateTime)

### Cek 2: Count Tables
```powershell
cd backend
npx prisma db pull
```

Output harus:
```
✔ Introspected 6 models and wrote them into prisma\schema.prisma
```

Jika **bukan 6 models**, berarti schema belum sama!

### Cek 3: Test Seed
```powershell
cd backend
npx prisma db seed
```

Output harus:
```
✅ Created 131 attendance records
```

Jika error "Unknown argument jamMulaiShift", schema belum sync!

## 🚨 Troubleshooting

### Error: "Unknown argument jamMulaiShift"
**Penyebab:** Schema database kamu punya field berbeda dengan repository

**Solusi:**
```powershell
cd backend
npx prisma db push --force-reset
npx prisma generate
npx prisma db seed
```

### Error: "Column 'createdAt' does not exist"
**Penyebab:** Database belum punya timestamp columns

**Solusi:**
```sql
-- Jalankan di SQL Server Management Studio
USE db_restoran;

-- Add timestamps ke semua table
ALTER TABLE Absensi ADD createdAt DATETIME2 DEFAULT GETDATE();
ALTER TABLE Absensi ADD updatedAt DATETIME2 DEFAULT GETDATE();

ALTER TABLE Jadwal ADD createdAt DATETIME2 DEFAULT GETDATE();
ALTER TABLE Jadwal ADD updatedAt DATETIME2 DEFAULT GETDATE();

ALTER TABLE LaporanPemasukan ADD createdAt DATETIME2 DEFAULT GETDATE();
ALTER TABLE LaporanPemasukan ADD updatedAt DATETIME2 DEFAULT GETDATE();
```

Atau pakai script otomatis:
```powershell
cd backend
# Jalankan SQL dari file
sqlcmd -S localhost -d db_restoran -i docs/tools/add-timestamps-all-tables.sql
```

### Error: "Environment variable not found: DATABASE_URL"
**Penyebab:** File `.env` belum ada atau belum diconfig

**Solusi:**
```powershell
# Copy dari template
Copy-Item .env.example .env

# Edit .env, sesuaikan:
# DATABASE_URL="sqlserver://localhost:1433;database=db_restoran;user=sa;password=YourPassword;encrypt=false;trustServerCertificate=true"
```

### Database Push Gagal Terus
**Penyebab:** Ada foreign key constraint atau data yang conflict

**Solusi:** Reset database manual di SSMS
```sql
USE master;
GO

-- Drop database jika ada
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'db_restoran')
BEGIN
    ALTER DATABASE db_restoran SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE db_restoran;
END
GO

-- Buat database baru
CREATE DATABASE db_restoran;
GO
```

Lalu lanjut:
```powershell
cd backend
npx prisma db push
npx prisma generate
npx prisma db seed
```

## 📊 Schema Reference

### Table: Role
```prisma
id               Int      PK
nama             String   UNIQUE
deskripsi        String?  NULLABLE
gajiPokokBulanan Float    DEFAULT 0
createdAt        DateTime DEFAULT now()
updatedAt        DateTime DEFAULT now()
```

### Table: User
```prisma
id         Int      PK
email      String   UNIQUE
nama       String
password   String
roleId     Int      FK -> Role.id
gajiPerJam Float    DEFAULT 0
createdAt  DateTime DEFAULT now()
updatedAt  DateTime DEFAULT now()
```

### Table: Absensi
```prisma
id              Int      PK
userId          Int      FK -> User.id
tanggal         Date     DEFAULT now()
shift           String
jamMulaiShift   DateTime REQUIRED
jamSelesaiShift DateTime REQUIRED
jamMasuk        DateTime DEFAULT now()
jamKeluar       DateTime? NULLABLE
jamKerja        Float    DEFAULT 0
menitTerlambat  Int      DEFAULT 0
potonganGaji    Float    DEFAULT 0
totalGaji       Float    DEFAULT 0
status          String   DEFAULT "Hadir"
createdAt       DateTime DEFAULT now()
updatedAt       DateTime DEFAULT now()
```

### Table: SlipGaji
```prisma
id              Int      PK
userId          Int      FK -> User.id
bulan           Int
tahun           Int
gajiBulanan     Float
bonusKehadiran  Float    DEFAULT 0
bonusLainnya    Float    DEFAULT 0
potonganAlpha   Float    DEFAULT 0
potonganTelat   Float    DEFAULT 0
potonganLainnya Float    DEFAULT 0
totalGajiKotor  Float
totalPotongan   Float
totalGajiBersih Float
tanggalBayar    DateTime DEFAULT now()
keterangan      String?  NULLABLE
createdAt       DateTime DEFAULT now()
updatedAt       DateTime DEFAULT now()

UNIQUE(userId, bulan, tahun)
```

### Table: Jadwal
```prisma
id           Int      PK
userId       Int      FK -> User.id
waktuMulai   DateTime
waktuSelesai DateTime
```

### Table: LaporanPemasukan
```prisma
id              Int      PK
userId          Int      FK -> User.id
tanggalLaporan  DateTime
jumlahPemasukan Float
shift           String
```

## 💡 Best Practice

1. **Selalu sync setelah git pull** - Terutama jika ada perubahan di `prisma/schema.prisma`
2. **Gunakan Prisma Studio** untuk verifikasi schema setelah sync
3. **Test seed setelah sync** untuk pastikan data bisa diinsert
4. **Jangan manual edit database** - Selalu pakai Prisma migration/push
5. **Backup sebelum reset** jika ada data penting

## 🔗 Related Docs

- [Setup Guide](./SETUP.md) - Setup project dari awal
- [Quick Start](./README.md) - Panduan cepat running project
- [Error Seed Absensi](./errors/ERROR-SEED-ABSENSI.md) - Fix error jamMulaiShift
- [Fix Timestamps](./errors/FIX-CREATEDAT-ERROR.md) - Fix createdAt column error

---

**Update Terakhir:** 11 November 2025  
**Versi Schema:** v1.0 (dengan jamMulaiShift & jamSelesaiShift)
