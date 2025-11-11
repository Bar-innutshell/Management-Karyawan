# 🔀 Shift Assignment System

## 📖 Overview

Admin dapat **assign shift** ke setiap user melalui field `shift` pada User model. Shift adalah template tetap yang hanya bisa dipilih dari 2 opsi: **"Pagi"** atau **"Sore"**.

## 🏗️ Architecture

```
┌─────────────────────┐
│  Shift Table        │ ← Template / Reference Data
│  (2 rows)           │   (Auto-seeded, read-only via API)
├─────────────────────┤
│ id | nama  | jam    │
├─────────────────────┤
│ 1  | Pagi  | 09-15  │
│ 2  | Sore  | 15-21  │
└─────────────────────┘
         ↓
    (Reference untuk)
         ↓
┌─────────────────────┐
│  User Table         │
│  shift: String?     │ ← Assigned shift (nullable)
├─────────────────────┤
│ id | nama  | shift  │
├─────────────────────┤
│ 1  | Admin | null   │
│ 2  | Siti  | Pagi   │
│ 3  | Budi  | Pagi   │
│ 4  | Dewi  | Pagi   │
│ 5  | Eko   | Sore   │
│ 6  | Fitri | Sore   │
│ 7  | Gilang| Sore   │
│ 8  | Hana  | Sore   │
└─────────────────────┘
```

## 🔑 Key Concepts

### 1. Shift Template (Read-Only)
- **Table:** `Shift`
- **Data:** 2 rows - Pagi (09:00-15:00) dan Sore (15:00-21:00)
- **Purpose:** Reference data untuk dropdown frontend
- **API:** `GET /shifts` (read-only, no CRUD)
- **Seed:** Auto-created saat `npx prisma db seed`

### 2. User Shift Assignment (Writable)
- **Field:** `User.shift` (String, nullable)
- **Values:** `"Pagi"`, `"Sore"`, atau `null`
- **Purpose:** Store shift assignment untuk setiap user
- **API:** `POST /users`, `PUT /users/:id` (admin only)
- **Default:** `null` (no shift assigned)

## 📝 Usage Examples

### 1. Create User with Shift

**Request:**
```http
POST /users
Authorization: Bearer <admin_token>
Content-Type: application/json

{
  "nama": "John Doe",
  "email": "john@restoran.com",
  "password": "john123",
  "roleId": 4,
  "gajiPerJam": 20000,
  "shift": "Pagi"
}
```

**Response:**
```json
{
  "message": "User berhasil dibuat",
  "data": {
    "id": 10,
    "nama": "John Doe",
    "email": "john@restoran.com",
    "roleId": 4,
    "gajiPerJam": 20000,
    "shift": "Pagi",
    "role": {
      "nama": "Waiter"
    }
  }
}
```

### 2. Update User Shift

**Request:**
```http
PUT /users/10
Authorization: Bearer <admin_token>
Content-Type: application/json

{
  "shift": "Sore"
}
```

**Response:**
```json
{
  "message": "User berhasil diupdate",
  "data": {
    "id": 10,
    "shift": "Sore",
    "updatedAt": "2025-11-11T16:30:00.000Z"
  }
}
```

### 3. Remove Shift from User

**Request:**
```http
PUT /users/10
Authorization: Bearer <admin_token>
Content-Type: application/json

{
  "shift": null
}
```

**Response:**
```json
{
  "message": "User berhasil diupdate",
  "data": {
    "id": 10,
    "shift": null,
    "updatedAt": "2025-11-11T16:35:00.000Z"
  }
}
```

### 4. Create User without Shift

**Request:**
```http
POST /users
Authorization: Bearer <admin_token>
Content-Type: application/json

{
  "nama": "Jane Doe",
  "email": "jane@restoran.com",
  "password": "jane123",
  "roleId": 1
}
```

**Response:**
```json
{
  "message": "User berhasil dibuat",
  "data": {
    "id": 11,
    "nama": "Jane Doe",
    "email": "jane@restoran.com",
    "roleId": 1,
    "shift": null,
    "role": {
      "nama": "Admin"
    }
  }
}
```

## ✅ Validation Rules

### Shift Field Validation

**Valid Values:**
- `"Pagi"` - Shift pagi (09:00-15:00)
- `"Sore"` - Shift sore (15:00-21:00)
- `null` - No shift assigned
- Field tidak dikirim (optional) - Akan default ke `null`

**Invalid Values:**
- `"Malam"` ❌
- `"Morning"` ❌
- `"pagi"` ❌ (case-sensitive)
- `"PAGI"` ❌ (case-sensitive)
- `""` ❌ (empty string)
- `"Pagi Sore"` ❌

**Error Response:**
```json
{
  "message": "Shift harus 'Pagi' atau 'Sore'"
}
```

## 🎯 Frontend Integration

### 1. Populate Shift Dropdown

**Step 1:** Get shift templates
```javascript
// GET /shifts
const response = await fetch('/shifts', {
  headers: { 'Authorization': 'Bearer ' + token }
});

const shifts = await response.json();
// shifts.data = [
//   { id: 1, nama: 'Pagi', jamMulai: '09:00', jamSelesai: '15:00' },
//   { id: 2, nama: 'Sore', jamMulai: '15:00', jamSelesai: '21:00' }
// ]
```

**Step 2:** Render dropdown
```jsx
<select name="shift">
  <option value="">-- Pilih Shift --</option>
  {shifts.data.map(shift => (
    <option key={shift.id} value={shift.nama}>
      {shift.nama} ({shift.jamMulai} - {shift.jamSelesai})
    </option>
  ))}
</select>
```

### 2. Create User with Shift

```javascript
const formData = {
  nama: "John Doe",
  email: "john@restoran.com",
  password: "john123",
  roleId: 4,
  gajiPerJam: 20000,
  shift: "Pagi" // From dropdown
};

const response = await fetch('/users', {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer ' + token,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify(formData)
});
```

### 3. Update User Shift

```javascript
const response = await fetch(`/users/${userId}`, {
  method: 'PUT',
  headers: {
    'Authorization': 'Bearer ' + token,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({ shift: "Sore" })
});
```

### 4. Display User List with Shift

```jsx
<table>
  <thead>
    <tr>
      <th>Nama</th>
      <th>Email</th>
      <th>Role</th>
      <th>Shift</th>
    </tr>
  </thead>
  <tbody>
    {users.map(user => (
      <tr key={user.id}>
        <td>{user.nama}</td>
        <td>{user.email}</td>
        <td>{user.role.nama}</td>
        <td>
          {user.shift || <em>Tidak ada shift</em>}
        </td>
      </tr>
    ))}
  </tbody>
</table>
```

## 🔄 Data Flow

```
┌──────────────┐
│   Frontend   │
└──────┬───────┘
       │
       │ 1. GET /shifts (populate dropdown)
       ↓
┌──────────────┐       ┌─────────────┐
│   Backend    │ ----> │ Shift Table │ (Reference)
│   API        │       └─────────────┘
└──────┬───────┘
       │
       │ 2. POST /users { shift: "Pagi" }
       │    or PUT /users/:id { shift: "Sore" }
       ↓
┌──────────────┐
│ Validation:  │
│ shift in     │
│ ["Pagi",     │
│  "Sore",     │
│  null]       │
└──────┬───────┘
       │
       │ 3. Save to User.shift
       ↓
┌──────────────┐
│  User Table  │
│  shift field │
└──────────────┘
```

## 💼 Use Cases

### 1. New Employee Onboarding
Admin creates new user account and assigns shift immediately:
```
Admin → Create User → Assign Shift "Pagi" → User ready to work
```

### 2. Shift Change Request
Employee requests shift change, admin updates via API:
```
Employee requests → Admin reviews → PUT /users/:id { shift: "Sore" }
```

### 3. Temporary No-Shift Status
Employee on leave or no fixed shift:
```
Admin → PUT /users/:id { shift: null } → Employee has no assigned shift
```

### 4. Bulk Shift Assignment
Admin assigns shifts to multiple employees:
```javascript
const employees = [
  { id: 2, shift: "Pagi" },
  { id: 5, shift: "Sore" },
  { id: 8, shift: "Sore" }
];

for (const emp of employees) {
  await fetch(`/users/${emp.id}`, {
    method: 'PUT',
    body: JSON.stringify({ shift: emp.shift })
  });
}
```

## 🧪 Testing

### Test Scenarios

#### 1. Valid Shift Assignment
```bash
# Create user with Pagi shift
curl -X POST http://localhost:3000/users \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"nama":"Test User","email":"test@test.com","password":"test123","roleId":4,"shift":"Pagi"}'

# Expected: 201 Created, shift="Pagi"
```

#### 2. Invalid Shift Value
```bash
# Try to assign invalid shift
curl -X POST http://localhost:3000/users \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"nama":"Test User","email":"test2@test.com","password":"test123","roleId":4,"shift":"Malam"}'

# Expected: 400 Bad Request, "Shift harus 'Pagi' atau 'Sore'"
```

#### 3. Update Shift
```bash
# Update user shift from Pagi to Sore
curl -X PUT http://localhost:3000/users/10 \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"shift":"Sore"}'

# Expected: 200 OK, shift="Sore"
```

#### 4. Remove Shift
```bash
# Remove shift assignment
curl -X PUT http://localhost:3000/users/10 \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"shift":null}'

# Expected: 200 OK, shift=null
```

#### 5. Create User without Shift
```bash
# Create user without shift field
curl -X POST http://localhost:3000/users \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"nama":"Test User","email":"test3@test.com","password":"test123","roleId":1}'

# Expected: 201 Created, shift=null
```

## 📊 Database Schema

### User Table (with shift field)
```sql
CREATE TABLE User (
  id INT PRIMARY KEY IDENTITY,
  nama NVARCHAR(255) NOT NULL,
  email NVARCHAR(255) UNIQUE NOT NULL,
  password NVARCHAR(255) NOT NULL,
  roleId INT NOT NULL,
  gajiPerJam INT DEFAULT 0,
  shift NVARCHAR(50) NULL,  -- New field (nullable)
  createdAt DATETIME2 DEFAULT GETDATE(),
  updatedAt DATETIME2 DEFAULT GETDATE(),
  
  FOREIGN KEY (roleId) REFERENCES Role(id)
)
```

### Shift Table (template reference)
```sql
CREATE TABLE Shift (
  id INT PRIMARY KEY IDENTITY,
  nama NVARCHAR(255) UNIQUE NOT NULL,
  jamMulai VARCHAR(5) NOT NULL,
  jamSelesai VARCHAR(5) NOT NULL,
  deskripsi NVARCHAR(MAX),
  aktif BIT DEFAULT 1,
  createdAt DATETIME2 DEFAULT GETDATE(),
  updatedAt DATETIME2 DEFAULT GETDATE()
)
```

## 🚀 Deployment Checklist

- [ ] Start SQL Server
- [ ] Pull latest code: `git pull`
- [ ] Push schema: `npx prisma db push`
- [ ] Generate client: `npx prisma generate`
- [ ] Re-seed database: `npx prisma db seed`
- [ ] Test shift assignment: `POST /users { shift: "Pagi" }`
- [ ] Test shift update: `PUT /users/:id { shift: "Sore" }`
- [ ] Test shift removal: `PUT /users/:id { shift: null }`
- [ ] Verify shift validation: Invalid shift returns 400
- [ ] Update frontend shift dropdown
- [ ] Update frontend user forms (create/edit)

## 📚 Related Documentation

- [API-USER.md](./API-USER.md) - User CRUD API documentation
- [API-SHIFT.md](./API-SHIFT.md) - Shift template API documentation
- [CHANGELOG.md](./CHANGELOG.md) - Version 0.4.1 changelog
- [SYNC-DATABASE.md](./SYNC-DATABASE.md) - Database sync guide

## ❓ FAQ

### Q: Mengapa shift tidak ada CRUD?
**A:** Shift adalah template tetap (Pagi & Sore) yang tidak perlu diubah-ubah. Hanya ada 2 shift, cukup di-seed sekali saja.

### Q: Bagaimana cara menambah shift baru (misal "Malam")?
**A:** Edit `backend/prisma/seed.js`, tambah shift "Malam" di array `shiftsData`, lalu run `npx prisma db seed`. Jangan lupa update validation di `userController.js` untuk accept "Malam".

### Q: Apakah user bisa punya lebih dari 1 shift?
**A:** Tidak. User hanya bisa punya 1 shift pada satu waktu. Jika perlu multiple shifts, bisa gunakan array atau relasi many-to-many.

### Q: Bagaimana cara lihat semua user shift Pagi?
**A:** Frontend filter sendiri dari `GET /users`, atau backend bisa tambah query param `?shift=Pagi`.

### Q: Apakah shift bisa diubah oleh user sendiri?
**A:** Tidak. Hanya admin yang bisa assign/update shift melalui `POST /users` atau `PUT /users/:id`.

---

**Last Updated:** 2025-11-11  
**Version:** 0.4.1
