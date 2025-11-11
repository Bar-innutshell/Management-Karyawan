# ⏰ Shift Management API (Template Only)

**Base URL:** `http://localhost:3000/shifts`

**PENTING:** Shift adalah **TEMPLATE TETAP** yang di-seed otomatis. 
- ✅ **Shift Pagi:** 09:00 - 15:00 (6 jam)
- ✅ **Shift Sore:** 15:00 - 21:00 (6 jam)  
- ✅ **Hari Kerja:** Senin - Jumat (20 hari/bulan)

**Tidak ada CRUD:** Shift tidak bisa dibuat, diubah, atau dihapus via API.
Jika perlu mengubah shift, update di `prisma/seed.js` dan jalankan `npx prisma db seed`.

---

## 📋 Endpoints Overview

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/shifts` | Get all shifts (2 template) | All Users |
| GET | `/shifts/:id` | Get shift by ID | All Users |
| ~~POST~~ | ~~`/shifts`~~ | **DISABLED** - Shift adalah template | - |
| ~~PUT~~ | ~~`/shifts/:id`~~ | **DISABLED** - Shift adalah template | - |
| ~~DELETE~~ | ~~`/shifts/:id`~~ | **DISABLED** - Shift adalah template | - |

---

## GET /shifts

Get daftar semua shift template (fixed: Pagi & Sore).

### Headers

```
Authorization: Bearer <token>
```

### Example Request

```http
GET /shifts
Authorization: Bearer <token>
```

### Response 200 (OK)

```json
{
  "message": "Daftar shift berhasil diambil",
  "data": [
    {
      "id": 1,
      "nama": "Pagi",
      "jamMulai": "09:00",
      "jamSelesai": "15:00",
      "deskripsi": "Shift pagi - Senin sampai Jumat (20 hari/bulan)",
      "aktif": true,
      "createdAt": "2025-11-11T10:00:00.000Z",
      "updatedAt": "2025-11-11T10:00:00.000Z"
    },
    {
      "id": 2,
      "nama": "Sore",
      "jamMulai": "15:00",
      "jamSelesai": "21:00",
      "deskripsi": "Shift sore - Senin sampai Jumat (20 hari/bulan)",
      "aktif": true,
      "createdAt": "2025-11-11T10:00:00.000Z",
      "updatedAt": "2025-11-11T10:00:00.000Z"
    }
  ],
  "total": 2
}
```

---

## GET /shifts/:id

Get detail shift berdasarkan ID.

### Headers

```
Authorization: Bearer <token>
```

### Example Request

```http
GET /shifts/1
Authorization: Bearer <token>
```

### Response 200 (OK)

```json
{
  "message": "Data shift berhasil diambil",
  "data": {
    "id": 1,
    "nama": "Pagi",
    "jamMulai": "09:00",
    "jamSelesai": "15:00",
    "deskripsi": "Shift pagi - Senin sampai Jumat (20 hari/bulan)",
    "aktif": true
  }
}
```

---

## 💡 Integration dengan Form Absensi

```javascript
// Ambil daftar shift
const response = await fetch('/shifts', {
  headers: { Authorization: `Bearer ${token}` }
});
const { data: shifts } = await response.json();

// User pilih shift dari dropdown
const selectedShift = shifts.find(s => s.nama === 'Pagi');

// Auto-fill jam berdasarkan shift
formData.shift = selectedShift.nama;                 // "Pagi"
formData.jamMulaiShift = selectedShift.jamMulai;    // "09:00"
formData.jamSelesaiShift = selectedShift.jamSelesai; // "15:00"
```

---

## 📝 Shift Templates

| Shift | Jam Mulai | Jam Selesai | Durasi | Hari Kerja |
|-------|-----------|-------------|--------|------------|
| Pagi | 09:00 | 15:00 | 6 jam | Senin-Jumat (20 hari/bulan) |
| Sore | 15:00 | 21:00 | 6 jam | Senin-Jumat (20 hari/bulan) |

**Seed Data:** Otomatis dibuat saat `npx prisma db seed`

---

**Update Terakhir:** 11 November 2025  
**Version:** 2.0 (Template Only - No CRUD)
