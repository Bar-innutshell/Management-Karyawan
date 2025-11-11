# 👥 User Management API (Admin Only)

**Base URL:** `http://localhost:3000/users`

Semua endpoint di sini **memerlukan authentication** dan **hanya bisa diakses oleh Admin**.

**Headers untuk semua endpoint:**
```
Authorization: Bearer <admin_token>
Content-Type: application/json
```

---

## 📋 Endpoints Overview

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/users` | Get all users dengan filter | Admin |
| GET | `/users/:id` | Get user by ID | Admin |
| POST | `/users` | Create new user | Admin |
| PUT | `/users/:id` | Update user | Admin |
| DELETE | `/users/:id` | Delete user | Admin |

---

## GET /users

Get daftar semua users dengan filter optional.

### Query Parameters (Optional)

| Parameter | Type | Description | Example |
|-----------|------|-------------|---------|
| roleId | number | Filter berdasarkan role | `?roleId=3` |
| search | string | Cari berdasarkan nama atau email | `?search=budi` |

### Example Request

```http
GET /users?roleId=3&search=chef
Authorization: Bearer <admin_token>
```

### Response 200 (OK)

```json
{
  "message": "Daftar user berhasil diambil",
  "data": [
    {
      "id": 3,
      "nama": "Budi Santoso",
      "email": "budi.chef@restoran.com",
      "roleId": 3,
      "gajiPerJam": 25000,
      "shift": "Pagi",
      "createdAt": "2025-11-07T10:00:00.000Z",
      "updatedAt": "2025-11-07T10:00:00.000Z",
      "role": {
        "id": 3,
        "nama": "Chef",
        "deskripsi": "Koki profesional, handle dapur dan menu",
        "gajiPokokBulanan": 5500000
      },
      "_count": {
        "absensi": 42,
        "slipGaji": 3,
        "jadwal": 20,
        "laporanPemasukan": 0
      }
    },
    {
      "id": 8,
      "nama": "Hana Safitri",
      "email": "hana.chef@restoran.com",
      "roleId": 3,
      "gajiPerJam": 23000,
      "shift": "Sore",
      "createdAt": "2025-11-07T10:00:00.000Z",
      "updatedAt": "2025-11-07T10:00:00.000Z",
      "role": {
        "id": 3,
        "nama": "Chef",
        "deskripsi": "Koki profesional, handle dapur dan menu",
        "gajiPokokBulanan": 5500000
      },
      "_count": {
        "absensi": 38,
        "slipGaji": 2,
        "jadwal": 18,
        "laporanPemasukan": 0
      }
    }
  ],
  "total": 2
}
```

### Response 403 (Forbidden)

```json
{
  "message": "Akses ditolak. Hanya Admin yang bisa mengakses endpoint ini."
}
```

---

## GET /users/:id

Get detail user berdasarkan ID.

### URL Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| id | number | Yes | User ID |

### Example Request

```http
GET /users/3
Authorization: Bearer <admin_token>
```

### Response 200 (OK)

```json
{
  "message": "Data user berhasil diambil",
  "data": {
    "id": 3,
    "nama": "Budi Santoso",
    "email": "budi.chef@restoran.com",
    "roleId": 3,
    "gajiPerJam": 25000,
    "shift": "Pagi",
    "createdAt": "2025-11-07T10:00:00.000Z",
    "updatedAt": "2025-11-07T10:00:00.000Z",
    "role": {
      "id": 3,
      "nama": "Chef",
      "deskripsi": "Koki profesional, handle dapur dan menu",
      "gajiPokokBulanan": 5500000
    },
    "_count": {
      "absensi": 42,
      "slipGaji": 3,
      "jadwal": 5,
      "laporanPemasukan": 0
    }
  }
}
```

### Response 404 (Not Found)

```json
{
  "message": "User tidak ditemukan"
}
```

---

## POST /users

Buat user baru.

### Request Body

| Field | Type | Required | Description | Example |
|-------|------|----------|-------------|---------|
| nama | string | Yes | Nama lengkap user | "Ahmad Hidayat" |
| email | string | Yes | Email (unique) | "ahmad@restoran.com" |
| password | string | Yes | Password (akan di-hash) | "password123" |
| roleId | number | Yes | ID role yang valid | 4 |
| gajiPerJam | number | No | Gaji per jam (default: 0) | 20000 |
| shift | string | No | Shift karyawan: "Pagi" atau "Sore" | "Pagi" |

**⚠️ Shift Validation Rules:**
- Hanya menerima nilai: `"Pagi"` atau `"Sore"`
- Field ini opsional (boleh null/tidak diisi)
- Jika diisi dengan nilai selain "Pagi" atau "Sore", akan ditolak dengan error 400

### Example Request

```http
POST /users
Authorization: Bearer <admin_token>
Content-Type: application/json

{
  "nama": "Ahmad Hidayat",
  "email": "ahmad@restoran.com",
  "password": "password123",
  "roleId": 4,
  "gajiPerJam": 20000,
  "shift": "Pagi"
}
```

### Response 201 (Created)

```json
{
  "message": "User berhasil dibuat",
  "data": {
    "id": 9,
    "nama": "Ahmad Hidayat",
    "email": "ahmad@restoran.com",
    "roleId": 4,
    "gajiPerJam": 20000,
    "shift": "Pagi",
    "createdAt": "2025-11-11T15:30:00.000Z",
    "updatedAt": "2025-11-11T15:30:00.000Z",
    "role": {
      "id": 4,
      "nama": "Waiter",
      "deskripsi": "Pelayan restoran, melayani customer",
      "gajiPokokBulanan": 3200000
    }
  }
}
```

### Response 400 (Bad Request - Missing Fields)

```json
{
  "message": "Nama, email, password, dan roleId harus diisi"
}
```

### Response 400 (Bad Request - Invalid Shift)

```json
{
  "message": "Shift harus 'Pagi' atau 'Sore'"
}
```

### Response 404 (Not Found - Role tidak ada)

```json
{
  "message": "Role tidak ditemukan"
}
```

### Response 409 (Conflict - Email sudah ada)

```json
{
  "message": "Email sudah terdaftar"
}
```

---

## PUT /users/:id

Update data user.

### URL Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| id | number | Yes | User ID yang akan diupdate |

### Request Body

Semua field **optional**. Hanya field yang dikirim yang akan diupdate.

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| nama | string | Nama lengkap baru | "Ahmad Hidayat Wijaya" |
| email | string | Email baru (harus unique) | "ahmad.new@restoran.com" |
| password | string | Password baru (akan di-hash) | "newpassword123" |
| roleId | number | Role ID baru | 3 |
| gajiPerJam | number | Gaji per jam baru | 25000 |
| shift | string | Shift baru: "Pagi", "Sore", atau null untuk unassign | "Sore" |

**⚠️ Shift Validation Rules:**
- Hanya menerima nilai: `"Pagi"`, `"Sore"`, atau `null` (untuk menghapus shift)
- Jika diisi dengan nilai selain "Pagi" atau "Sore", akan ditolak dengan error 400

### Example Request - Update Shift

```http
PUT /users/9
Authorization: Bearer <admin_token>
Content-Type: application/json

{
  "nama": "Ahmad Hidayat Wijaya",
  "gajiPerJam": 25000,
  "roleId": 3,
  "shift": "Sore"
}
```

### Example Request - Remove Shift

```http
PUT /users/9
Authorization: Bearer <admin_token>
Content-Type: application/json

{
  "shift": null
}
```

### Response 200 (OK)

```json
{
  "message": "User berhasil diupdate",
  "data": {
    "id": 9,
    "nama": "Ahmad Hidayat Wijaya",
    "email": "ahmad@restoran.com",
    "roleId": 3,
    "gajiPerJam": 25000,
    "shift": "Sore",
    "createdAt": "2025-11-11T15:30:00.000Z",
    "updatedAt": "2025-11-11T16:00:00.000Z",
    "role": {
      "id": 3,
      "nama": "Chef",
      "deskripsi": "Koki profesional, handle dapur dan menu",
      "gajiPokokBulanan": 5500000
    }
  }
}
```

### Response 400 (Bad Request - Invalid Shift)

```json
{
  "message": "Shift harus 'Pagi' atau 'Sore'"
}
```

### Response 404 (Not Found - User)

```json
{
  "message": "User tidak ditemukan"
}
```

### Response 404 (Not Found - Role)

```json
{
  "message": "Role tidak ditemukan"
}
```

### Response 409 (Conflict - Email)

```json
{
  "message": "Email sudah digunakan oleh user lain"
}
```

---

## DELETE /users/:id

Hapus user berdasarkan ID.

**PENTING:** User hanya bisa dihapus jika **tidak punya data terkait** (absensi, slip gaji, jadwal, laporan).

### URL Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| id | number | Yes | User ID yang akan dihapus |

### Example Request

```http
DELETE /users/9
Authorization: Bearer <admin_token>
```

### Response 200 (OK)

```json
{
  "message": "User berhasil dihapus",
  "data": {
    "id": 9,
    "nama": "Ahmad Hidayat",
    "email": "ahmad@restoran.com"
  }
}
```

### Response 400 (Bad Request - Ada data terkait)

```json
{
  "message": "Tidak dapat menghapus user. User memiliki data terkait",
  "relatedData": {
    "absensi": 15,
    "slipGaji": 2,
    "jadwal": 3,
    "laporanPemasukan": 0
  }
}
```

### Response 404 (Not Found)

```json
{
  "message": "User tidak ditemukan"
}
```

---

## 💡 Use Cases

### 1. Tambah Karyawan Baru

```bash
# 1. Cek daftar role yang tersedia
GET /roles

# 2. Buat user baru dengan role yang dipilih
POST /users
{
  "nama": "Siti Aminah",
  "email": "siti@restoran.com",
  "password": "siti123",
  "roleId": 4,
  "gajiPerJam": 18000
}
```

### 2. Update Gaji Karyawan

```bash
# Update hanya gaji per jam
PUT /users/5
{
  "gajiPerJam": 22000
}
```

### 3. Promosi Karyawan (Ubah Role)

```bash
# Promosi dari Waiter (4) ke Chef (3)
PUT /users/6
{
  "roleId": 3,
  "gajiPerJam": 25000
}
```

### 4. Cari Karyawan berdasarkan Role

```bash
# Lihat semua Chef
GET /users?roleId=3

# Lihat semua Waiter
GET /users?roleId=4
```

### 5. Cari Karyawan berdasarkan Nama/Email

```bash
# Search "budi"
GET /users?search=budi

# Hasil: Semua user yang nama atau email mengandung "budi"
```

---

## 🔒 Security Notes

1. **Password di-hash** menggunakan bcrypt sebelum disimpan
2. **Email harus unique** - tidak boleh duplicate
3. **Hanya Admin** yang bisa CRUD user
4. **Soft delete recommended** - Jangan hapus user yang sudah punya data
5. **Validasi role** - Role harus exist sebelum assign ke user

---

## 🚨 Error Handling

| Status Code | Meaning | Action |
|-------------|---------|--------|
| 200 | OK | Request berhasil |
| 201 | Created | User berhasil dibuat |
| 400 | Bad Request | Validasi gagal, cek field yang required |
| 401 | Unauthorized | Token tidak valid atau expired |
| 403 | Forbidden | Bukan admin, tidak punya akses |
| 404 | Not Found | User atau role tidak ditemukan |
| 409 | Conflict | Email sudah terdaftar |
| 500 | Server Error | Error di server, cek log |

---

## 📊 Database Schema

```prisma
model User {
  id         Int      @id @default(autoincrement())
  email      String   @unique
  nama       String
  password   String   // Hashed
  roleId     Int      // FK -> Role.id
  gajiPerJam Float    @default(0)
  createdAt  DateTime @default(now())
  updatedAt  DateTime @default(now()) @updatedAt
  
  // Relations
  role             Role
  absensi          Absensi[]
  slipGaji         SlipGaji[]
  jadwal           Jadwal[]
  laporanPemasukan LaporanPemasukan[]
}
```

---

**Update Terakhir:** 11 November 2025  
**Version:** 1.0
