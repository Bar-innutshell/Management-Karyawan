# 📊 Laporan, Gaji & Absensi API Documentation

Dokumentasi lengkap untuk fitur Laporan Pemasukkan, Manajemen Gaji, dan Sistem Absensi.

Base URL: `http://localhost:3000`

---

## 📋 Table of Contents
1. [Laporan Pemasukkan (Admin Only)](#laporan-pemasukkan)
2. [Manajemen Gaji (Admin Only)](#manajemen-gaji)
3. [Sistem Absensi](#sistem-absensi)

---

## 📊 Laporan Pemasukkan (Admin Only)

### GET /laporan/total
Hitung total pemasukkan dengan filter opsional.

**Auth:** Admin only

**Headers:**
```
Authorization: Bearer <token>
```

**Query Parameters:**
- `startDate` (optional): Filter dari tanggal (YYYY-MM-DD)
- `endDate` (optional): Filter sampai tanggal (YYYY-MM-DD)
- `shift` (optional): Filter shift ("Pagi", "Siang", "Sore", "Malam")

**Response 200:**
```json
{
  "message": "Total pemasukkan berhasil dihitung",
  "data": {
    "totalPemasukkan": 25000000,
    "jumlahTransaksi": 45,
    "filter": {
      "startDate": "2025-11-01",
      "endDate": "2025-11-10",
      "shift": "all"
    }
  }
}
```

---

### GET /laporan/harian
Lihat laporan pemasukkan per hari (daily summary).

**Auth:** Admin only

**Headers:**
```
Authorization: Bearer <token>
```

**Query Parameters:**
- `startDate` (optional): Filter dari tanggal
- `endDate` (optional): Filter sampai tanggal
- `shift` (optional): Filter shift

**Response 200:**
```json
{
  "message": "Laporan harian berhasil diambil",
  "data": {
    "summary": [
      {
        "tanggal": "2025-11-10",
        "totalPemasukkan": 7500000,
        "jumlahTransaksi": 12,
        "byShift": {
          "Pagi": {
            "shift": "Pagi",
            "total": 3000000,
            "count": 5
          },
          "Siang": {
            "shift": "Siang",
            "total": 4500000,
            "count": 7
          }
        },
        "details": [...]
      }
    ],
    "totalKeseluruhan": 25000000,
    "totalTransaksi": 45
  }
}
```

---

### GET /laporan/detail
Lihat detail semua pemasukkan (dengan pagination).

**Auth:** Admin only

**Headers:**
```
Authorization: Bearer <token>
```

**Query Parameters:**
- `page` (optional, default: 1): Halaman
- `limit` (optional, default: 50): Jumlah data per halaman
- `startDate` (optional): Filter dari tanggal
- `endDate` (optional): Filter sampai tanggal
- `shift` (optional): Filter shift
- `userId` (optional): Filter by user ID

**Response 200:**
```json
{
  "message": "Laporan detail berhasil diambil",
  "data": [
    {
      "id": 1,
      "jumlahPemasukan": 5000000,
      "tanggalLaporan": "2025-11-10T10:30:00.000Z",
      "shift": "Pagi",
      "user": {
        "id": 2,
        "nama": "Jane Smith",
        "email": "jane@example.com",
        "role": {
          "nama": "Cashier"
        }
      }
    }
  ],
  "pagination": {
    "currentPage": 1,
    "totalPages": 3,
    "totalRecords": 150,
    "limit": 50
  }
}
```

---

## 💰 Manajemen Gaji (Admin Only)

### POST /gaji/set-gaji-perjam
Admin mengatur gaji per jam untuk user tertentu.

**Auth:** Admin only

**Headers:**
```
Authorization: Bearer <token>
```

**Request Body:**
```json
{
  "userId": 3,
  "gajiPerJam": 50000
}
```

**Response 200:**
```json
{
  "message": "Gaji per jam berhasil diatur",
  "data": {
    "user": {
      "id": 3,
      "nama": "John Doe",
      "email": "john@example.com",
      "role": "Employee"
    },
    "gaji": {
      "gajiPerJam": 50000,
      "gajiHarian": 300000,
      "gajiBulanan": 6000000,
      "formula": "50000 × 6 jam × 20 hari = 6000000"
    }
  }
}
```

---

### POST /gaji/hitung-dari-gaji-pokok
Hitung gaji per jam dari gaji pokok role.

**Formula:** `Gaji Pokok ÷ 20 hari ÷ 6 jam = Gaji Per Jam`

**Auth:** Admin only

**Headers:**
```
Authorization: Bearer <token>
```

**Request Body:**
```json
{
  "userId": 3
}
```

**Response 200:**
```json
{
  "message": "Gaji per jam berhasil dihitung dari gaji pokok",
  "data": {
    "user": {
      "id": 3,
      "nama": "John Doe",
      "email": "john@example.com",
      "role": "Employee"
    },
    "gaji": {
      "gajiPokok": 6000000,
      "gajiPerJam": 50000,
      "gajiHarian": 300000,
      "gajiBulanan": 6000000,
      "formula": "6000000 ÷ 20 hari ÷ 6 jam = 50000.00 per jam"
    }
  }
}
```

---

### GET /gaji/user/:userId
Lihat detail gaji user tertentu.

**Auth:** Admin only

**Headers:**
```
Authorization: Bearer <token>
```

**Response 200:**
```json
{
  "message": "Data gaji user berhasil diambil",
  "data": {
    "user": {
      "id": 3,
      "nama": "John Doe",
      "email": "john@example.com",
      "role": "Employee"
    },
    "gaji": {
      "gajiPokok": 6000000,
      "gajiPerJam": 50000,
      "gajiHarian": 300000,
      "gajiBulanan": 6000000
    }
  }
}
```

---

### GET /gaji/all
Lihat daftar gaji semua user.

**Auth:** Admin only

**Headers:**
```
Authorization: Bearer <token>
```

**Response 200:**
```json
{
  "message": "Daftar gaji user berhasil diambil",
  "data": [
    {
      "user": {
        "id": 2,
        "nama": "Jane Smith",
        "email": "jane@example.com",
        "role": "Cashier"
      },
      "gaji": {
        "gajiPokok": 5000000,
        "gajiPerJam": 41666.67,
        "gajiHarian": 250000,
        "gajiBulanan": 5000000
      }
    }
  ],
  "summary": {
    "totalUser": 5,
    "totalGajiBulanan": 25000000
  }
}
```

---

## ⏰ Sistem Absensi

### POST /absensi/clock-in
User absen masuk (memulai shift).

**Auth:** Authenticated user

**Headers:**
```
Authorization: Bearer <token>
```

**Request Body:**
```json
{
  "shift": "Siang"
}
```

**Shift Options:**
- `"Siang"`: 09:00 - 15:00 (6 jam)
- `"Sore"`: 15:00 - 21:00 (6 jam)

**Response 201:**
```json
{
  "message": "Clock in berhasil untuk shift Siang",
  "data": {
    "absensi": {
      "id": 1,
      "tanggal": "2025-11-10T00:00:00.000Z",
      "shift": "Siang",
      "jamMasuk": "2025-11-10T09:05:00.000Z",
      "jamMulaiShift": "2025-11-10T09:00:00.000Z",
      "status": "Hadir",
      "menitTerlambat": 5,
      "potonganGaji": 0
    },
    "user": {
      "nama": "John Doe",
      "gajiPerJam": 50000
    },
    "info": "Anda terlambat 5 menit (masih dalam toleransi 10 menit)"
  }
}
```

**Response 201 (Telat > 10 menit):**
```json
{
  "message": "Clock in berhasil untuk shift Siang",
  "data": {
    "absensi": {
      "id": 2,
      "tanggal": "2025-11-10T00:00:00.000Z",
      "shift": "Siang",
      "jamMasuk": "2025-11-10T09:25:00.000Z",
      "jamMulaiShift": "2025-11-10T09:00:00.000Z",
      "status": "Telat",
      "menitTerlambat": 25,
      "potonganGaji": 12500
    },
    "user": {
      "nama": "John Doe",
      "gajiPerJam": 50000
    },
    "info": "Anda terlambat 25 menit. Potongan gaji: Rp 12500.00"
  }
}
```

**Business Logic:**
- ✅ Toleransi keterlambatan: **10 menit**
- ❌ Telat > 10 menit: Potong gaji `(Menit Telat - 10) / 60 × Gaji Per Jam`
- ⚠️ User harus sudah memiliki `gajiPerJam` (diatur oleh admin)
- ⚠️ Tidak bisa clock in 2x untuk shift yang sama di hari yang sama

**Error Responses:**

**400 - Shift invalid:**
```json
{
  "message": "Shift harus salah satu dari: Siang, Sore"
}
```

**400 - Sudah clock in:**
```json
{
  "message": "Anda sudah clock in untuk shift Siang hari ini"
}
```

**400 - Gaji belum diatur:**
```json
{
  "message": "Gaji per jam belum diatur. Hubungi admin untuk mengatur gaji Anda."
}
```

---

### POST /absensi/clock-out
User absen keluar (mengakhiri shift), gaji otomatis dihitung.

**Auth:** Authenticated user

**Headers:**
```
Authorization: Bearer <token>
```

**Request Body:**
```json
{
  "absensiId": 1
}
```

**Response 200:**
```json
{
  "message": "Clock out berhasil",
  "data": {
    "absensi": {
      "id": 1,
      "tanggal": "2025-11-10T00:00:00.000Z",
      "shift": "Siang",
      "jamMasuk": "2025-11-10T09:05:00.000Z",
      "jamKeluar": "2025-11-10T15:00:00.000Z",
      "jamKerja": 5.92,
      "status": "Hadir",
      "menitTerlambat": 5
    },
    "gaji": {
      "gajiPerJam": 50000,
      "gajiKotor": 296000,
      "potonganGaji": 0,
      "totalGaji": 296000,
      "formula": "(5.92 jam × Rp 50000) - Rp 0 = Rp 296000"
    },
    "user": {
      "nama": "John Doe"
    }
  }
}
```

**Business Logic:**
- Total Gaji = `(Jam Kerja × Gaji Per Jam) - Potongan Gaji`
- Jam Kerja dihitung dari `jamMasuk` sampai `jamKeluar`
- Potongan Gaji sudah dihitung saat clock in (jika telat > 10 menit)

**Error Responses:**

**400 - Sudah clock out:**
```json
{
  "message": "Anda sudah clock out sebelumnya",
  "data": {
    "jamKeluar": "2025-11-10T15:00:00.000Z",
    "totalGaji": 296000
  }
}
```

**403 - Bukan absensi sendiri:**
```json
{
  "message": "Anda tidak bisa clock out absensi user lain"
}
```

**404 - Absensi tidak ditemukan:**
```json
{
  "message": "Data absensi tidak ditemukan"
}
```

---

### GET /absensi/today
Lihat absensi hari ini (untuk ambil absensiId untuk clock out).

**Auth:** Authenticated user

**Headers:**
```
Authorization: Bearer <token>
```

**Response 200:**
```json
{
  "message": "Absensi hari ini berhasil diambil",
  "data": [
    {
      "id": 1,
      "tanggal": "2025-11-10T00:00:00.000Z",
      "shift": "Siang",
      "jamMasuk": "2025-11-10T09:05:00.000Z",
      "jamKeluar": null,
      "jamKerja": 0,
      "menitTerlambat": 5,
      "potonganGaji": 0,
      "totalGaji": 0,
      "status": "Hadir",
      "jamMulaiShift": "2025-11-10T09:00:00.000Z",
      "jamSelesaiShift": "2025-11-10T15:00:00.000Z"
    }
  ]
}
```

---

### GET /absensi/my
Lihat riwayat absensi sendiri.

**Auth:** Authenticated user

**Headers:**
```
Authorization: Bearer <token>
```

**Query Parameters:**
- `startDate` (optional): Filter dari tanggal
- `endDate` (optional): Filter sampai tanggal
- `shift` (optional): Filter shift

**Response 200:**
```json
{
  "message": "Riwayat absensi berhasil diambil",
  "data": [
    {
      "id": 1,
      "tanggal": "2025-11-10T00:00:00.000Z",
      "shift": "Siang",
      "jamMasuk": "2025-11-10T09:05:00.000Z",
      "jamKeluar": "2025-11-10T15:00:00.000Z",
      "jamKerja": 5.92,
      "menitTerlambat": 5,
      "potonganGaji": 0,
      "totalGaji": 296000,
      "status": "Hadir"
    }
  ],
  "summary": {
    "totalHariKerja": 20,
    "totalJamKerja": 118.5,
    "totalGaji": 5925000,
    "totalPotongan": 75000,
    "totalTelat": 3
  }
}
```

---

### GET /absensi/all
Lihat semua absensi semua user (Admin only).

**Auth:** Admin only

**Headers:**
```
Authorization: Bearer <token>
```

**Query Parameters:**
- `startDate` (optional): Filter dari tanggal
- `endDate` (optional): Filter sampai tanggal
- `shift` (optional): Filter shift
- `userId` (optional): Filter by user ID

**Response 200:**
```json
{
  "message": "Data absensi berhasil diambil",
  "data": [
    {
      "id": 1,
      "tanggal": "2025-11-10T00:00:00.000Z",
      "shift": "Siang",
      "jamMasuk": "2025-11-10T09:05:00.000Z",
      "jamKeluar": "2025-11-10T15:00:00.000Z",
      "jamKerja": 5.92,
      "menitTerlambat": 5,
      "potonganGaji": 0,
      "totalGaji": 296000,
      "status": "Hadir",
      "user": {
        "id": 3,
        "nama": "John Doe",
        "email": "john@example.com",
        "gajiPerJam": 50000,
        "role": {
          "nama": "Employee"
        }
      }
    }
  ],
  "summary": {
    "totalRecords": 100,
    "totalJamKerja": 600,
    "totalGaji": 30000000,
    "totalPotongan": 500000,
    "totalTelat": 15
  }
}
```

---

## 📋 Business Rules Summary

### Gaji
1. **Formula Gaji Bulanan:** `Gaji Per Jam × 6 jam × 20 hari`
2. **Formula Gaji Per Jam:** `Gaji Pokok ÷ 20 hari ÷ 6 jam`
3. Admin bisa set `gajiPerJam` manual atau hitung dari `gajiPokok` role

### Absensi
1. **Jam Kerja:**
   - Shift Siang: 09:00 - 15:00 (6 jam)
   - Shift Sore: 15:00 - 21:00 (6 jam)

2. **Toleransi Keterlambatan:** 10 menit
   - Telat 0-10 menit: **Tidak ada potongan**
   - Telat > 10 menit: **Potong gaji**

3. **Rumus Potongan:** `(Menit Telat - 10) ÷ 60 × Gaji Per Jam`

4. **Perhitungan Gaji:** `(Jam Kerja × Gaji Per Jam) - Potongan Gaji`

### Pemasukkan
1. Hanya **Cashier** yang bisa input pemasukkan
2. **Admin** bisa lihat:
   - Total pemasukkan (dengan filter)
   - Laporan harian (summary per hari)
   - Detail semua transaksi (dengan pagination)

---

## 🔐 Authorization Matrix

| Endpoint | Admin | Cashier | Employee |
|----------|-------|---------|----------|
| POST /pemasukkan/insert | ❌ | ✅ | ❌ |
| GET /laporan/* | ✅ | ❌ | ❌ |
| POST /gaji/* | ✅ | ❌ | ❌ |
| GET /gaji/* | ✅ | ❌ | ❌ |
| POST /absensi/clock-in | ✅ | ✅ | ✅ |
| POST /absensi/clock-out | ✅ | ✅ | ✅ |
| GET /absensi/my | ✅ | ✅ | ✅ |
| GET /absensi/today | ✅ | ✅ | ✅ |
| GET /absensi/all | ✅ | ❌ | ❌ |

---

## 📖 Example Usage Flow

### 1. Admin Setup Gaji User
```bash
# Set gaji per jam manual
POST /gaji/set-gaji-perjam
{
  "userId": 3,
  "gajiPerJam": 50000
}

# Atau hitung dari gaji pokok role
POST /gaji/hitung-dari-gaji-pokok
{
  "userId": 3
}
```

### 2. User Clock In
```bash
POST /absensi/clock-in
{
  "shift": "Siang"
}
# Response: absensiId = 1
```

### 3. User Clock Out
```bash
# Ambil absensiId dari /absensi/today
GET /absensi/today

# Clock out
POST /absensi/clock-out
{
  "absensiId": 1
}
# Gaji otomatis dihitung!
```

### 4. Cashier Input Pemasukkan
```bash
POST /pemasukkan/insert
{
  "jumlahPemasukkan": 5000000,
  "shift": "Siang"
}
```

### 5. Admin Lihat Laporan
```bash
# Total pemasukkan
GET /laporan/total?startDate=2025-11-01&endDate=2025-11-10

# Laporan harian
GET /laporan/harian?startDate=2025-11-01

# Detail lengkap
GET /laporan/detail?page=1&limit=50

# Laporan gaji semua user
GET /gaji/all

# Laporan absensi semua user
GET /absensi/all?startDate=2025-11-01
```

---

Untuk dokumentasi endpoint lainnya, lihat [API.md](./API.md)
