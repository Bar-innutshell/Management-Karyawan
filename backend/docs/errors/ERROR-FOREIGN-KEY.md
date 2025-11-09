# ERROR - Foreign Key Constraint Violated

## 🔴 Error Message:
```
Foreign key constraint violated on the constraint: 'User_roleId_fkey'
```

Atau:

```
Invalid `prisma.user.create()` invocation:
Foreign key constraint violated on the constraint: 'User_roleId_fkey'
```

---

## 📝 Apa Artinya?

Error ini muncul saat **mencoba membuat User dengan `roleId` yang tidak ada** di tabel `Role`.

**Contoh Scenario:**
1. Kamu register user baru dengan `roleId: 1`
2. Tapi tabel `Role` kosong (belum ada data)
3. SQL Server reject karena foreign key constraint

---

## ✅ SOLUSI LENGKAP

### 🎯 SOLUSI 1: Seed Database (RECOMMENDED)

Jalankan seed script untuk membuat roles default:

```powershell
cd backend
npm run db:seed
```

**Output yang diharapkan:**
```
🌱 Starting seed...
✅ Roles seeded successfully!
  - Created role: Admin (ID: 1)
  - Created role: Kasir (ID: 2)
  - Created role: Koki (ID: 3)
✅ Admin user created successfully!
🎉 Database seeded successfully!
```

**Setelah seed, test register:**
```bash
POST http://localhost:3000/auth/register
Body:
{
  "nama": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "roleId": 1  # Admin role
}
```

Should work now! ✅

---

### 🎯 SOLUSI 2: Buat Role Manual via SSMS

Jika tidak mau seed, buat role manual:

**Via SQL Server Management Studio:**

```sql
USE db_restoran;
GO

-- Insert roles
INSERT INTO Role (nama, gajiPokok, deskripsi, createdAt, updatedAt)
VALUES 
  ('Admin', 10000000, 'Administrator sistem', GETDATE(), GETDATE()),
  ('Kasir', 5000000, 'Kasir restoran', GETDATE(), GETDATE()),
  ('Koki', 6000000, 'Koki restoran', GETDATE(), GETDATE());

-- Check
SELECT * FROM Role;
```

**Via sqlcmd:**
```powershell
sqlcmd -S localhost,1433 -U prisma_user -P "Prisma!2025" -d db_restoran -Q "INSERT INTO Role (nama, gajiPokok, deskripsi, createdAt, updatedAt) VALUES ('Admin', 10000000, 'Administrator', GETDATE(), GETDATE())"
```

---

### 🎯 SOLUSI 3: Check Roles yang Ada

Cek role mana saja yang sudah ada:

```sql
SELECT * FROM Role;
```

**Jika kosong:** Seed database atau insert manual (solusi 1 atau 2)

**Jika ada:** Pastikan `roleId` di request body match dengan ID role yang ada

**Example:**
```json
// ❌ SALAH - roleId 1 tidak ada
{
  "roleId": 1  
}

// ✅ BENAR - roleId 2 ada di database
{
  "roleId": 2
}
```

---

## 🔧 TROUBLESHOOTING

### Scenario 1: Seed Error - "Role already exists"

**Error:**
```
Unique constraint failed on the fields: (`nama`)
```

**Solusi:**
Database sudah di-seed sebelumnya. Skip seed dan langsung test register.

---

### Scenario 2: Seed Error - "Table 'Role' doesn't exist"

**Error:**
```
Invalid `prisma.role.create()` invocation:
The table `Role` does not exist in the current database.
```

**Solusi:**
Schema belum di-push ke database:
```powershell
npx prisma db push
npx prisma generate
npm run db:seed
```

---

### Scenario 3: Register Error Setelah Seed

**Error masih muncul setelah seed?**

**Check:**
1. Apakah seed benar-benar sukses?
   ```sql
   SELECT * FROM Role;
   ```
   
2. Apakah `roleId` di request body valid?
   ```json
   {
     "roleId": 1  // Must exist in Role table
   }
   ```

3. Restart server:
   ```powershell
   Ctrl+C  # Stop server
   npm run dev  # Start again
   ```

---

## 💡 PREVENTION (Cara Hindari Error Ini)

### 1. **Always Seed After Fresh Setup**

Workflow yang benar:
```powershell
# 1. Clone repo
git clone <repo-url>
cd backend
npm install

# 2. Setup database
npx prisma db push
npx prisma generate

# 3. SEED DATABASE ← JANGAN LUPA!
npm run db:seed

# 4. Run server
npm run dev
```

### 2. **Check Roles Before Register**

Sebelum register user, pastikan roles sudah ada:

**API Endpoint:** `GET /roles`
```bash
GET http://localhost:3000/roles
Authorization: Bearer <token>  # Optional, tapi bagus untuk test auth
```

**Response:**
```json
{
  "message": "Daftar role berhasil diambil",
  "data": [
    { "id": 1, "nama": "Admin" },
    { "id": 2, "nama": "Kasir" },
    { "id": 3, "nama": "Koki" }
  ]
}
```

### 3. **Validate roleId in Controller**

Di `authController.js`, tambahkan validation:

```javascript
const register = async (req, res) => {
  const { nama, email, password, roleId } = req.body;

  // Validate roleId exists
  const role = await prisma.role.findUnique({
    where: { id: roleId }
  });

  if (!role) {
    return res.status(400).json({
      message: `Role dengan ID ${roleId} tidak ditemukan. Jalankan: npm run db:seed`
    });
  }

  // ... rest of code
};
```

---

## 📋 CHECKLIST

Jika error foreign key muncul:

- [ ] **Seed database:** `npm run db:seed`
- [ ] **Check roles ada:** `SELECT * FROM Role;` (via SSMS atau sqlcmd)
- [ ] **Verify roleId di request** match dengan role yang ada
- [ ] **Restart server:** `Ctrl+C` → `npm run dev`
- [ ] **Test register** dengan roleId yang valid (1, 2, atau 3)

Jika masih error:

- [ ] **Reset database:** `npx prisma migrate reset` → `npm run db:seed`
- [ ] **Check schema:** `npx prisma db push`
- [ ] **Regenerate client:** `npx prisma generate`

---

## 🔗 Related Errors

### Error: "Unique constraint failed on the fields: (`email`)"
Email sudah terdaftar. Gunakan email lain atau login dengan email yang sudah ada.

### Error: "P1001: Can't reach database server"
SQL Server tidak running atau port 1433 tidak accessible.  
See: [ERROR-P1001.md](ERROR-P1001.md)

### Error: "P1000: Authentication failed"
SQL Server credentials salah.  
See: [ERROR-P1000.md](ERROR-P1000.md)

---

## 📖 Summary

**Quick Fix:**
```powershell
# 1. Seed database
npm run db:seed

# 2. Test register
POST http://localhost:3000/auth/register
Body: { "nama": "Test", "email": "test@test.com", "password": "test123", "roleId": 1 }
```

**Root Cause:** Database tidak punya data roles, jadi foreign key constraint gagal.

**Prevention:** Always run `npm run db:seed` setelah setup database!

---

**Last Updated:** November 9, 2025  
**Error Type:** Database Constraint  
**Severity:** High - Blocks user registration  
**Common Cause:** Forgot to seed database
