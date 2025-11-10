# 💰 Slip Gaji (Monthly Salary Slip) - Complete Guide

## 📋 Apa itu Slip Gaji?

**Slip Gaji** adalah rekap gaji bulanan yang dibuat Admin setiap akhir bulan berdasarkan data absensi karyawan selama 1 bulan.

### Perbedaan dengan Absensi:

| Aspek | Absensi | Slip Gaji |
|-------|---------|-----------|
| **Periode** | Harian | Bulanan |
| **Tipe Data** | Raw data (clock in/out) | Processed data (rekap) |
| **Dibuat** | Auto saat clock out | Manual oleh Admin |
| **Isi** | Jam masuk, keluar, gaji harian | Total gaji + bonus + potongan |
| **Fungsi** | Tracking kehadiran | Pembayaran gaji |

---

## 🔄 Flow Sistem Gaji

```
┌─────────────────────────────────────────────────────┐
│  1. HARIAN - Karyawan Clock In/Out                  │
│     ↓                                                │
│     System auto-hitung gaji harian di Absensi       │
│     (totalGaji, potonganGaji, jamKerja, dll)        │
└─────────────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────────┐
│  2. AKHIR BULAN - Admin Generate Slip Gaji          │
│     ↓                                                │
│     System akumulasi semua absensi 1 bulan          │
│     System hitung total + bonus + potongan          │
│     SlipGaji dibuat dengan detail lengkap           │
└─────────────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────────┐
│  3. PEMBAYARAN - Karyawan Lihat & Terima Gaji       │
│     ↓                                                │
│     Karyawan bisa lihat slip gaji mereka            │
│     Admin transfer sesuai totalGajiBersih           │
└─────────────────────────────────────────────────────┘
```

---

## 📊 Struktur Slip Gaji

### Field-field dalam SlipGaji:

```javascript
{
  id: 1,
  userId: 3,
  bulan: 11,              // November
  tahun: 2025,
  
  // GAJI
  gajiBulanan: 3500000,   // Total dari semua absensi (Hadir)
  
  // BONUS
  bonusKehadiran: 200000, // Bonus rajin (manual dari Admin)
  bonusLainnya: 100000,   // Bonus lainnya (THR, dll)
  
  // POTONGAN
  potonganAlpha: 300000,  // Auto: jumlahAlpha × gajiHarian
  potonganTelat: 50000,   // Auto: akumulasi dari absensi
  potonganLainnya: 0,     // Potongan manual (BPJS, dll)
  
  // TOTAL
  totalGajiKotor: 3800000,    // gajiBulanan + bonus
  totalPotongan: 350000,       // alpha + telat + lainnya
  totalGajiBersih: 3450000,    // gajiKotor - potongan
  
  tanggalBayar: "2025-12-01",
  keterangan: "Gaji bulan November 2025"
}
```

### Formula Perhitungan:

```
gajiBulanan = Σ totalGaji dari semua absensi (status = Hadir)

potonganAlpha = jumlahAlpha × (gajiPerJam × 6 jam)

potonganTelat = Σ potonganGaji dari semua absensi

totalGajiKotor = gajiBulanan + bonusKehadiran + bonusLainnya

totalPotongan = potonganAlpha + potonganTelat + potonganLainnya

totalGajiBersih = totalGajiKotor - totalPotongan
```

---

## 🛠️ API Endpoints

### 1. Generate Slip Gaji (Admin Only)

**Generate slip gaji bulanan untuk seorang karyawan**

```http
POST /gaji/slip/generate
Authorization: Bearer <admin_token>
Content-Type: application/json

{
  "userId": 3,
  "bulan": 11,
  "tahun": 2025,
  "bonusKehadiran": 200000,    // Optional
  "bonusLainnya": 100000,      // Optional  
  "potonganLainnya": 0,        // Optional
  "keterangan": "Gaji November 2025 - Performa bagus"  // Optional
}
```

**Response Success:**
```json
{
  "message": "Slip gaji berhasil dibuat",
  "data": {
    "slipGaji": {
      "id": 1,
      "userId": 3,
      "bulan": 11,
      "tahun": 2025,
      "gajiBulanan": 3200000,
      "bonusKehadiran": 200000,
      "bonusLainnya": 100000,
      "potonganAlpha": 0,
      "potonganTelat": 50000,
      "potonganLainnya": 0,
      "totalGajiKotor": 3500000,
      "totalPotongan": 50000,
      "totalGajiBersih": 3450000,
      "tanggalBayar": "2025-11-11T10:30:00.000Z",
      "keterangan": "Gaji November 2025 - Performa bagus",
      "user": {
        "nama": "Budi Santoso",
        "email": "budi.chef@restoran.com",
        "role": {
          "nama": "Chef"
        }
      }
    },
    "detail": {
      "periode": "11/2025",
      "jumlahHadir": 20,
      "jumlahAlpha": 0,
      "totalAbsensi": 20
    }
  }
}
```

**Response Error - Slip Sudah Ada:**
```json
{
  "message": "Slip gaji untuk Budi Santoso bulan 11/2025 sudah ada",
  "data": { /* existing slip */ }
}
```

---

### 2. Lihat Slip Gaji User

**User bisa lihat slip gaji sendiri, Admin bisa lihat slip user manapun**

```http
GET /gaji/slip/user/:userId?bulan=11&tahun=2025
Authorization: Bearer <token>
```

**Query Parameters (Optional):**
- `bulan` - Filter berdasarkan bulan (1-12)
- `tahun` - Filter berdasarkan tahun

**Response:**
```json
{
  "message": "Data slip gaji berhasil diambil",
  "data": [
    {
      "id": 1,
      "userId": 3,
      "bulan": 11,
      "tahun": 2025,
      "gajiBulanan": 3200000,
      "bonusKehadiran": 200000,
      "bonusLainnya": 100000,
      "potonganAlpha": 0,
      "potonganTelat": 50000,
      "potonganLainnya": 0,
      "totalGajiKotor": 3500000,
      "totalPotongan": 50000,
      "totalGajiBersih": 3450000,
      "user": {
        "nama": "Budi Santoso",
        "email": "budi.chef@restoran.com",
        "role": { "nama": "Chef" }
      }
    }
  ],
  "summary": {
    "totalSlip": 1
  }
}
```

---

### 3. Lihat Semua Slip Gaji (Admin Only)

**Lihat slip gaji semua karyawan dengan filter**

```http
GET /gaji/slip/all?bulan=11&tahun=2025&userId=3
Authorization: Bearer <admin_token>
```

**Query Parameters (Optional):**
- `bulan` - Filter berdasarkan bulan
- `tahun` - Filter berdasarkan tahun
- `userId` - Filter berdasarkan user tertentu

**Response:**
```json
{
  "message": "Data slip gaji berhasil diambil",
  "data": [
    { /* slip gaji 1 */ },
    { /* slip gaji 2 */ },
    { /* ... */ }
  ],
  "summary": {
    "totalSlip": 8,
    "totalGajiBersih": 25600000
  }
}
```

---

## 💡 Contoh Penggunaan

### Scenario 1: Generate Slip Gaji Akhir Bulan

Admin mau bayar gaji semua karyawan untuk bulan November 2025:

```bash
# 1. Login sebagai Admin
POST /auth/login
{
  "email": "admin@restoran.com",
  "password": "admin123"
}
# Dapat token: eyJhbGc...

# 2. Lihat daftar semua user
GET /gaji/all
Authorization: Bearer eyJhbGc...
# Dapat list userId

# 3. Generate slip gaji untuk setiap user
POST /gaji/slip/generate
{
  "userId": 2,
  "bulan": 11,
  "tahun": 2025,
  "bonusKehadiran": 150000  // Bonus karena rajin
}

POST /gaji/slip/generate
{
  "userId": 3,
  "bulan": 11,
  "tahun": 2025,
  "bonusKehadiran": 200000,
  "bonusLainnya": 100000  // Bonus chef of the month
}

# ... dst untuk semua user
```

---

### Scenario 2: Karyawan Cek Slip Gaji Sendiri

```bash
# 1. Login sebagai karyawan
POST /auth/login
{
  "email": "budi.chef@restoran.com",
  "password": "budi123"
}
# userId dari token: 3

# 2. Lihat slip gaji sendiri (semua bulan)
GET /gaji/slip/user/3
Authorization: Bearer <token>

# 3. Lihat slip gaji bulan tertentu
GET /gaji/slip/user/3?bulan=11&tahun=2025
Authorization: Bearer <token>
```

---

### Scenario 3: Admin Lihat Rekap Gaji Bulan Ini

```bash
# Lihat semua slip gaji November 2025
GET /gaji/slip/all?bulan=11&tahun=2025
Authorization: Bearer <admin_token>

# Response akan ada summary total gaji yang harus dibayar:
{
  "summary": {
    "totalSlip": 7,
    "totalGajiBersih": 24500000  // Total yang harus dibayar ke semua karyawan
  }
}
```

---

## ⚙️ Business Rules

### 1. **Satu Slip Per Bulan Per User**
- User hanya bisa punya 1 slip gaji per bulan
- Kalau generate lagi untuk bulan sama = error
- Solusi: hapus slip lama dulu kalau mau generate ulang

### 2. **Auto-Calculate Potongan Alpha**
- Sistem otomatis hitung jumlah hari alpha dari absensi
- Formula: `jumlahAlpha × gajiHarian`
- gajiHarian = gajiPerJam × 6 jam

### 3. **Akumulasi Potongan Telat**
- System ambil semua `potonganGaji` dari absensi bulan itu
- Dijumlahkan jadi `potonganTelat` di slip gaji

### 4. **Bonus Manual**
- `bonusKehadiran` - Admin kasih manual (misal: bonus rajin)
- `bonusLainnya` - Bonus tambahan (THR, achievement, dll)
- `potonganLainnya` - Potongan manual (BPJS, pinjaman, dll)

### 5. **Authorization**
- **Generate slip**: Admin only
- **Lihat slip sendiri**: Semua user (tapi cuma punya sendiri)
- **Lihat semua slip**: Admin only

---

## 📝 Tips & Best Practices

### 1. Generate Slip di Awal Bulan Berikutnya

```bash
# Untuk gaji November, generate di tanggal 1-5 Desember
# Jangan generate sebelum bulan selesai!
```

### 2. Review Absensi Dulu

```bash
# Sebelum generate, cek absensi dulu
GET /absensi/semua?userId=3&bulan=11&tahun=2025

# Pastikan:
# - Semua absensi sudah clock out
# - Tidak ada data aneh
# - Jumlah hadir sudah sesuai
```

### 3. Beri Keterangan yang Jelas

```javascript
{
  "keterangan": "Gaji November 2025 - Bonus THR + Chef of the Month"
}
```

### 4. Backup Data Sebelum Generate

```bash
# Export data absensi dulu (via Prisma Studio atau SQL)
# Jaga-jaga kalau ada kesalahan
```

---

## 🐛 Troubleshooting

### Error: "Slip gaji sudah ada"

**Solusi**: Hapus slip yang lama dulu

```sql
-- Via Prisma Studio atau SQL
DELETE FROM SlipGaji WHERE userId = 3 AND bulan = 11 AND tahun = 2025;
```

### Error: "User tidak ditemukan"

**Cek**: Apakah userId valid?

```bash
GET /gaji/all  # Lihat daftar userId yang ada
```

### Gaji Tidak Sesuai Ekspektasi

**Debug**:

```bash
# 1. Cek absensi bulan itu
GET /absensi/semua?userId=3&bulan=11&tahun=2025

# 2. Hitung manual:
# - Jumlah hari hadir × gajiHarian
# - Jumlah hari alpha × gajiHarian (potongan)
# - Total potongan telat

# 3. Bandingkan dengan hasil generate
```

---

## 🔮 Future Enhancements

Fitur yang bisa ditambahkan nanti:

1. **Auto-generate slip gaji** (Cron job tiap tanggal 1)
2. **Email notifikasi** saat slip gaji dibuat
3. **PDF export** untuk slip gaji
4. **Approval workflow** (Admin review → approve → send)
5. **Perbandingan bulan** (gaji bulan ini vs bulan lalu)
6. **Tax calculation** (PPh 21)
7. **Payroll summary** (total gaji per bulan, per tahun)

---

**Created**: November 11, 2025  
**Version**: 1.0.0  
**Author**: Bar-innutshell Team
