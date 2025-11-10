## API Reference

Base URL: `http://localhost:3000`

Catatan: Tambahkan endpoint baru di dokumen ini setiap menambah route di `backend/index.js` atau file route lain.

## 📚 Dokumentasi Lengkap

### Quick Links
- **[Laporan, Gaji & Absensi API](./LAPORAN-GAJI-ABSENSI.md)** - Dokumentasi lengkap untuk:
  - 📊 Laporan Pemasukkan (Admin)
  - 💰 Manajemen Gaji (Admin)
  - ⏰ Sistem Absensi (All Users)

---

## 📋 Endpoint Overview

### Authentication
- `POST /auth/register` - Registrasi user baru
- `POST /auth/login` - Login user

### Role Management (Admin Only)
- `GET /roles` - List semua roles
- `GET /roles/:id` - Get role by ID
- `POST /roles` - Buat role baru (Admin only)
- `PUT /roles/:id` - Update role (Admin only)
- `DELETE /roles/:id` - Hapus role (Admin only)

### Pemasukkan (Cashier Only untuk Input)
- `GET /pemasukkan/show` - Lihat semua pemasukkan (Authenticated)
- `POST /pemasukkan/insert` - Input pemasukkan (Cashier only)

### Laporan (Admin Only) 📊
- `GET /laporan/total` - Total pemasukkan dengan filter
- `GET /laporan/harian` - Laporan harian (daily summary)
- `GET /laporan/detail` - Detail semua pemasukkan (dengan pagination)

### Gaji (Admin Only) 💰
- `POST /gaji/set-gaji-perjam` - Set gaji per jam user
- `POST /gaji/hitung-dari-gaji-pokok` - Hitung gaji per jam dari gaji pokok
- `GET /gaji/user/:userId` - Lihat gaji user tertentu
- `GET /gaji/all` - Lihat gaji semua user

### Absensi ⏰
- `POST /absensi/clock-in` - Absen masuk (All users)
- `POST /absensi/clock-out` - Absen keluar (All users)
- `GET /absensi/today` - Lihat absensi hari ini (All users)
- `GET /absensi/my` - Riwayat absensi sendiri (All users)
- `GET /absensi/all` - Lihat semua absensi (Admin only)

### Health Check
- `GET /db/ping` - Health check koneksi database

---

## 🔐 Authentication

### POST /auth/register
Registrasi user baru.

**Request Body:**
```json
{
  "nama": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "roleId": 1
}
```

**Response 201 (Created):**
```json
{
  "message": "User berhasil terdaftar",
  "user": {
    "id": 1,
    "nama": "John Doe",
    "email": "john@example.com",
    "roleId": 1
  }
}
```

**Response 409 (Conflict):**
```json
{
  "message": "Email sudah terdaftar."
}
```

---

### POST /auth/login
Login user.

**Request Body:**
```json
{
  "email": "john@example.com",
  "password": "password123"
}
```

**Response 200 (OK):**
```json
{
  "message": "Login berhasil",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Response 401 (Unauthorized):**
```json
{
  "message": "Password salah."
}
```

**Response 404 (Not Found):**
```json
{
  "message": "Email tidak ditemukan."
}
```

---

## 👥 Role Management (Admin Only)

**Headers untuk semua endpoint di bawah:**
```
Authorization: Bearer <token>
```

### GET /roles
Get semua roles (semua user yang login bisa akses).

**Response 200:**
```json
{
  "message": "Daftar role berhasil diambil",
  "data": [
    {
      "id": 1,
      "nama": "Admin",
      "gajiPokok": 10000000,
      "deskripsi": "Administrator sistem",
      "createdAt": "2025-11-07T10:00:00Z",
      "updatedAt": "2025-11-07T10:00:00Z",
      "_count": {
        "users": 2
      }
    }
  ]
}
```

---

### GET /roles/:id
Get role by ID (semua user yang login bisa akses).

**Response 200:**
```json
{
  "message": "Role berhasil diambil",
  "data": {
    "id": 1,
    "nama": "Admin",
    "gajiPokok": 10000000,
    "deskripsi": "Administrator sistem",
    "users": [
      {
        "id": 1,
        "nama": "John Doe",
        "email": "john@example.com"
      }
    ]
  }
}
```

---

### POST /roles
Buat role baru (Admin only).

**Request Body:**
```json
{
  "nama": "Manager",
  "gajiPokok": 8000000,
  "deskripsi": "Manager operasional"
}
```

**Response 201:**
```json
{
  "message": "Role berhasil dibuat",
  "data": {
    "id": 4,
    "nama": "Manager",
    "gajiPokok": 8000000,
    "deskripsi": "Manager operasional",
    "createdAt": "2025-11-07T11:00:00Z",
    "updatedAt": "2025-11-07T11:00:00Z"
  }
}
```

**Response 403 (Forbidden):**
```json
{
  "message": "Akses ditolak. Hanya Admin yang bisa mengakses endpoint ini."
}
```

---

### PUT /roles/:id
Update role (Admin only).

**Request Body:**
```json
{
  "nama": "Senior Manager",
  "gajiPokok": 9000000,
  "deskripsi": "Senior manager operasional"
}
```

**Response 200:**
```json
{
  "message": "Role berhasil diupdate",
  "data": {
    "id": 4,
    "nama": "Senior Manager",
    "gajiPokok": 9000000,
    "deskripsi": "Senior manager operasional",
    "updatedAt": "2025-11-07T12:00:00Z"
  }
}
```

---

### DELETE /roles/:id
Hapus role (Admin only).

**Response 200:**
```json
{
  "message": "Role berhasil dihapus",
  "data": {
    "id": 4,
    "nama": "Manager"
  }
}
```

**Response 400 (Bad Request):**
```json
{
  "message": "Tidak bisa hapus role. Masih ada 5 user yang menggunakan role ini"
}
```

---

## � Pemasukkan Management

**Headers untuk semua endpoint:**
```
Authorization: Bearer <token>
```

### GET /pemasukkan/show
Lihat semua laporan pemasukkan (authenticated users).

**Headers:**
```
Authorization: Bearer <token>
```

**Response 200 (OK):**
```json
{
  "message": "Daftar pemasukkan berhasil diambil",
  "data": [
    {
      "id": 1,
      "jumlahPemasukan": 5000000,
      "tanggalLaporan": "2025-11-10T10:30:00.000Z",
      "shift": "Pagi",
      "userId": 2,
      "user": {
        "id": 2,
        "nama": "Jane Smith",
        "email": "jane@example.com"
      }
    },
    {
      "id": 2,
      "jumlahPemasukan": 7500000,
      "tanggalLaporan": "2025-11-09T15:45:00.000Z",
      "shift": "Siang",
      "userId": 2,
      "user": {
        "id": 2,
        "nama": "Jane Smith",
        "email": "jane@example.com"
      }
    }
  ]
}
```

**Response 401 (Unauthorized):**
```json
{
  "message": "Token tidak valid atau tidak ditemukan."
}
```

---

### POST /pemasukkan/insert
Buat laporan pemasukkan baru (hanya userId 2).

**Headers:**
```
Authorization: Bearer <token>
```

**Request Body:**
```json
{
  "userId": 2,
  "jumlahPemasukkan": 5000000,
  "shift": "Pagi"
}
```

**Field Descriptions:**
- `userId` (number, required): ID user yang membuat laporan (harus 2)
- `jumlahPemasukkan` (number, required): Jumlah pemasukkan dalam Rupiah
- `shift` (string, required): Shift kerja ("Pagi", "Siang", atau "Malam")

**Response 201 (Created):**
```json
{
  "message": "Data pemasukkan berhasil ditambahkan",
  "data": {
    "id": 3,
    "userId": 2,
    "jumlahPemasukan": 5000000,
    "shift": "Pagi",
    "tanggalLaporan": "2025-11-10T12:00:00.000Z"
  }
}
```

**Response 400 (Bad Request - Data tidak lengkap):**
```json
{
  "message": "Data tidak lengkap. Pastikan userId, jumlahPemasukkan, dan shift terisi."
}
```

**Response 400 (Bad Request - userId invalid):**
```json
{
  "message": "userId harus berupa angka."
}
```

**Response 400 (Bad Request - jumlahPemasukkan invalid):**
```json
{
  "message": "jumlahPemasukkan harus berupa angka yang valid."
}
```

**Response 403 (Forbidden - userId bukan 2):**
```json
{
  "message": "Aksi ditolak. Hanya user dengan ID 2 yang diizinkan membuat laporan."
}
```

**Response 404 (Not Found - User tidak ada):**
```json
{
  "message": "Gagal: User dengan ID 2 tidak ditemukan."
}
```

**Response 500 (Server Error):**
```json
{
  "message": "Terjadi kesalahan pada server",
  "error": "Error message details"
}
```

**Catatan:**
- Endpoint ini memiliki business logic yang membatasi hanya `userId: 2` yang bisa membuat laporan
- `tanggalLaporan` otomatis diisi dengan waktu saat ini
- Data diurutkan berdasarkan `tanggalLaporan` terbaru di endpoint `/show`

---

## �🔧 Health Check

### GET /db/ping
Health check koneksi database.

**Method:** `GET`  
**Auth:** none (lokal)

**Response 200:**
```json
{
  "ok": true,
  "db": "db_restoran",
  "server": "NAMA-PC",
  "instance": null
}
```

**Response 500:**
```json
{
  "ok": false,
  "error": "Failed to connect to localhost in 15000ms"
}
```

**Troubleshooting:**
- Jika error `[object Object]`, cek console log server untuk detail
- Test koneksi: `node test-db.js`
- Verifikasi `.env` credentials
- Pastikan SQL Server running dan port 1433 accessible

---

Cara menambahkan endpoint baru:
1. Tambahkan deskripsi endpoint, method, URL path.
2. Tuliskan contoh request (headers, body) dan contoh response sukses + error.
3. Update contoh cURL / Postman / REST client.
