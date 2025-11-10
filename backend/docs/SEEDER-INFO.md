# 🌱 Database Seeder Information

## Cara Menjalankan Seeder

```bash
cd backend
node prisma/seed.js
```

## Data yang Dibuat

### 👥 Users (8 orang)

| No | Nama | Role | Email | Password |
|----|------|------|-------|----------|
| 1 | Ahmad Rizki | Admin | admin@restoran.com | admin123 |
| 2 | Siti Nurhaliza | Cashier | siti.cashier@restoran.com | siti123 |
| 3 | Budi Santoso | Chef | budi.chef@restoran.com | budi123 |
| 4 | Dewi Lestari | Waiter | dewi.waiter@restoran.com | dewi123 |
| 5 | Eko Prasetyo | Employee | eko.employee@restoran.com | eko123 |
| 6 | Fitri Handayani | Waiter | fitri.waiter@restoran.com | fitri123 |
| 7 | Gilang Ramadhan | Cashier | gilang.cashier@restoran.com | gilang123 |
| 8 | Hana Safitri | Chef | hana.chef@restoran.com | hana123 |

### 💼 Roles (5 role)

| Role | Gaji Pokok Bulanan | Deskripsi |
|------|-------------------|-----------|
| Admin | Rp 8.000.000 | Administrator sistem dengan akses penuh |
| Cashier | Rp 4.500.000 | Kasir restoran, handle transaksi dan pembayaran |
| Chef | Rp 5.500.000 | Koki profesional, handle dapur dan menu |
| Waiter | Rp 3.200.000 | Pelayan restoran, melayani customer |
| Employee | Rp 3.600.000 | Karyawan biasa, staff operasional restoran |

### 📋 Data History (30 Hari Terakhir)

#### Absensi (126 records)
- **Admin tidak ada absensi** (hanya untuk management)
- **7 karyawan** dengan history berbeda-beda
- **Periode**: 30 hari terakhir (skip weekend)
- **Variasi kehadiran** berdasarkan role:
  - Chef: 95% attendance (paling rajin)
  - Cashier: 90% attendance
  - Waiter: 85% attendance
  - Employee: 80% attendance (paling sering absen)

#### Detail Absensi:
- ✅ **Shift bervariasi**: Siang (09:00-15:00) dan Sore (15:00-21:00)
- ⏰ **Keterlambatan realistis**: 30% chance telat 0-30 menit
- 💰 **Auto-calculated**:
  - Jam kerja actual
  - Menit terlambat
  - Potongan gaji (toleransi 10 menit)
  - Total gaji harian
- 🕐 **Overtime**: 20% chance overtime 1-2 jam

#### Laporan Pemasukan (42 records)
- **Periode**: 30 hari terakhir (skip weekend)
- **2 shift per hari**: Siang & Sore
- **Input oleh**: Cashier (Siti atau Gilang)
- **Total pemasukan 30 hari**: ~Rp 72.000.000
- **Variasi pendapatan**:
  - Shift Siang: Rp 1.4M - 2.6M (rata-rata 2M)
  - Shift Sore: Rp 1M - 2M (rata-rata 1.5M)

## Fitur Seeder

### 🎯 Realistis
- Nama Indonesia yang natural
- Email pattern yang konsisten
- Role distribution yang balanced
- Attendance pattern yang masuk akal (weekday only)
- Income variation yang realistis

### 🔐 Security
- Password di-hash dengan bcrypt (10 rounds)
- Setiap user punya password unik (nama123)

### 📊 Variasi Data
- **Kehadiran berbeda** per role
- **Keterlambatan random** dengan distribusi realistis
- **Shift distribution** sesuai karakteristik role
- **Overtime random** untuk simulasi lembur
- **Income variance** sesuai jam operasional

### ♻️ Idempotent
- Bisa dijalankan berulang kali
- Menggunakan `upsert` untuk Role dan User
- Data lama akan di-update, bukan duplicate

## Testing

### Login Test
```bash
# Admin
POST /auth/login
{
  "email": "admin@restoran.com",
  "password": "admin123"
}

# Cashier
POST /auth/login
{
  "email": "siti.cashier@restoran.com",
  "password": "siti123"
}
```

### Data Verification
```bash
# Lihat semua absensi (Admin only)
GET /absensi/semua
Authorization: Bearer <admin_token>

# Lihat laporan pemasukan total (Admin only)
GET /laporan/total
Authorization: Bearer <admin_token>

# Lihat absensi user tertentu
GET /absensi/saya
Authorization: Bearer <user_token>
```

## Reset Database

Jika ingin reset dan seed ulang:

```bash
# Method 1: Hapus data manual via Prisma Studio
npx prisma studio
# Delete all records dari setiap table (mulai dari child table dulu)

# Method 2: Drop & recreate database (HATI-HATI!)
# Di SQL Server Management Studio:
# 1. Drop database db_restoran
# 2. Create database db_restoran lagi
# 3. Jalankan migration SQL
# 4. Jalankan seeder

# Setelah database kosong, run seeder:
node prisma/seed.js
```

## Troubleshooting

### Error: "Cannot find module 'bcrypt'"
```bash
npm install bcrypt
```

### Error: "Unique constraint failed"
```bash
# User/Role sudah ada, seeder akan update data
# Tidak perlu khawatir, ini normal behavior upsert
```

### Error: "Invalid jamMulaiShift"
```bash
# Schema database tidak sync
npx prisma db pull
npx prisma generate
node prisma/seed.js
```

---

**Created**: November 11, 2025  
**Last Updated**: November 11, 2025  
**Version**: 1.0.0
