# 🚀 Quick Setup: User & Shift Management

Panduan cepat untuk setup fitur baru: **CRUD User** dan **CRUD Shift**.

---

## 📦 Apa yang Baru?

### 1. **User Management API** 👥
Admin sekarang bisa CRUD user secara manual:
- ✅ Create user baru dengan role dan gaji
- ✅ Update user (nama, email, role, gaji)
- ✅ Delete user (jika tidak punya data terkait)
- ✅ List semua user dengan filter
- ✅ Search user berdasarkan nama/email

### 2. **Shift Management API** ⏰
Admin bisa manage master data shift:
- ✅ Create shift baru (Pagi, Siang, Malam, Custom)
- ✅ Update jam shift
- ✅ Non-aktifkan shift tanpa hapus
- ✅ Delete shift
- ✅ Semua user bisa lihat daftar shift

---

## 🔧 Setup Steps

### Step 1: Sync Database Schema

Schema sudah ditambahkan table `Shift`. Kamu harus sync database:

```powershell
cd backend

# Push schema baru ke database
npx prisma db push

# Generate Prisma Client dengan model baru
npx prisma generate
```

**Output yang diharapkan:**
```
✔ Your database is now in sync with your Prisma schema.
✔ Generated Prisma Client
```

### Step 2: Seed Shift Default (Optional)

Buat 3 shift default: Pagi, Siang, Malam.

**Manual via API:**

```bash
# Login sebagai admin dulu
POST http://localhost:3000/auth/login
{
  "email": "admin@restoran.com",
  "password": "admin123"
}

# Copy token dari response

# 1. Buat Shift Pagi
POST http://localhost:3000/shifts
Authorization: Bearer <admin_token>
Content-Type: application/json

{
  "nama": "Pagi",
  "jamMulai": "07:00",
  "jamSelesai": "15:00",
  "deskripsi": "Shift pagi untuk breakfast dan lunch"
}

# 2. Buat Shift Siang
POST http://localhost:3000/shifts
Authorization: Bearer <admin_token>
Content-Type: application/json

{
  "nama": "Siang",
  "jamMulai": "15:00",
  "jamSelesai": "23:00",
  "deskripsi": "Shift siang untuk lunch dan dinner"
}

# 3. Buat Shift Malam
POST http://localhost:3000/shifts
Authorization: Bearer <admin_token>
Content-Type: application/json

{
  "nama": "Malam",
  "jamMulai": "23:00",
  "jamSelesai": "07:00",
  "deskripsi": "Shift malam untuk late night service"
}
```

### Step 3: Test CRUD User

```bash
# List semua user
GET http://localhost:3000/users
Authorization: Bearer <admin_token>

# Buat user baru
POST http://localhost:3000/users
Authorization: Bearer <admin_token>
Content-Type: application/json

{
  "nama": "Test User",
  "email": "test@restoran.com",
  "password": "test123",
  "roleId": 4,
  "gajiPerJam": 20000
}

# Update user
PUT http://localhost:3000/users/9
Authorization: Bearer <admin_token>
Content-Type: application/json

{
  "gajiPerJam": 25000
}

# Delete user (jika tidak ada data terkait)
DELETE http://localhost:3000/users/9
Authorization: Bearer <admin_token>
```

### Step 4: Test CRUD Shift

```bash
# List semua shift (semua user bisa)
GET http://localhost:3000/shifts
Authorization: Bearer <token>

# List hanya shift aktif
GET http://localhost:3000/shifts?aktif=true
Authorization: Bearer <token>

# Update shift (admin only)
PUT http://localhost:3000/shifts/1
Authorization: Bearer <admin_token>
Content-Type: application/json

{
  "jamMulai": "06:00",
  "jamSelesai": "14:00"
}
```

---

## 📋 Checklist Setelah Setup

- [ ] **Database synced**: `npx prisma db push` berhasil
- [ ] **Prisma Client generated**: `npx prisma generate` berhasil
- [ ] **Backend running**: `node index.js` jalan tanpa error
- [ ] **Shift created**: Minimal 3 shift (Pagi, Siang, Malam) sudah dibuat
- [ ] **Test CRUD User**: Bisa create, read, update user
- [ ] **Test CRUD Shift**: Bisa create, read, update shift
- [ ] **Prisma Studio**: Table `Shift` terlihat di Prisma Studio

---

## 🔍 Verifikasi

### Cek 1: Prisma Studio
```powershell
cd backend
npx prisma studio
```

Buka browser, pastikan ada table baru:
- ✅ **Shift** - dengan kolom: id, nama, jamMulai, jamSelesai, deskripsi, aktif

### Cek 2: Test Endpoints

```bash
# 1. Login admin
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@restoran.com","password":"admin123"}'

# 2. List users
curl http://localhost:3000/users \
  -H "Authorization: Bearer <token>"

# 3. List shifts
curl http://localhost:3000/shifts \
  -H "Authorization: Bearer <token>"
```

### Cek 3: Backend Logs

```powershell
cd backend
node index.js
```

Output harus:
```
API running at http://localhost:3000
```

Tidak ada error Prisma atau "unknown model Shift"

---

## 🚨 Troubleshooting

### Error: "Unknown model Shift"

**Penyebab:** Prisma Client belum di-generate

**Solusi:**
```powershell
cd backend
npx prisma generate
```

### Error: "Table 'Shift' does not exist"

**Penyebab:** Database belum di-push

**Solusi:**
```powershell
cd backend
npx prisma db push
```

### Error: "Can't reach database server"

**Penyebab:** SQL Server tidak running

**Solusi:**
1. Buka Services (Win + R → services.msc)
2. Cari "SQL Server (SQLEXPRESS)"
3. Start service
4. Retry `npx prisma db push`

### Error: "Column createdAt does not exist in Shift"

**Penyebab:** Schema tidak sync

**Solusi:**
```powershell
cd backend
npx prisma db push --force-reset
npx prisma generate
npx prisma db seed
```

---

## 📖 Dokumentasi Lengkap

- **[API-USER.md](./API-USER.md)** - Dokumentasi lengkap CRUD User
- **[API-SHIFT.md](./API-SHIFT.md)** - Dokumentasi lengkap CRUD Shift
- **[API.md](./API.md)** - Overview semua endpoints
- **[SYNC-DATABASE.md](./SYNC-DATABASE.md)** - Panduan sync database dengan tim

---

## 🎯 Use Cases

### 1. Tambah Karyawan Baru via API
```bash
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
PUT /users/5
{
  "gajiPerJam": 22000
}
```

### 3. Setup Custom Shift
```bash
POST /shifts
{
  "nama": "Weekend Special",
  "jamMulai": "10:00",
  "jamSelesai": "22:00",
  "deskripsi": "Shift khusus weekend"
}
```

### 4. Non-aktifkan Shift Sementara
```bash
PUT /shifts/3
{
  "aktif": false
}
```

---

## 🔗 Integration

### User Management → Role
```javascript
// User harus punya role yang valid
{
  "roleId": 3  // FK ke table Role
}
```

### User → Gaji
```javascript
// Admin bisa set gaji per jam langsung saat create/update
{
  "gajiPerJam": 25000
}
```

### Shift → Absensi
```javascript
// Shift name digunakan di Absensi
{
  "shift": "Pagi"  // Harus match dengan Shift.nama
}
```

---

**Update Terakhir:** 11 November 2025  
**Version:** 1.0

---

## 💡 Next Steps

Setelah setup selesai, kamu bisa:
1. ✅ Integrate CRUD User ke Flutter UI
2. ✅ Integrate CRUD Shift ke Flutter UI
3. ✅ Buat dropdown shift di form absensi (ambil dari API `/shifts`)
4. ✅ Validation: Pastikan shift name di absensi match dengan master shift
5. ✅ Auto-calculate jam kerja berdasarkan shift yang dipilih
