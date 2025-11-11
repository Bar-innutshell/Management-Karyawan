# 🔄 Shift Assignment Update - Quick Guide

## 📢 What Changed?

Admin sekarang dapat **assign shift** langsung ke user melalui field `shift` pada User model.

### Before (v0.4.0)
- Shift adalah template saja (read-only)
- Tidak ada cara untuk assign shift ke user

### After (v0.4.1)
- User punya field `shift` (String, nullable)
- Admin bisa assign shift saat create/update user
- Validation: hanya accept "Pagi" atau "Sore"

## 🚀 How to Update (Team Members)

### Step 1: Pull Latest Code
```powershell
git pull
```

### Step 2: Start SQL Server
Pastikan SQL Server sudah running di `localhost:1433`

### Step 3: Push Schema Changes
```powershell
cd backend
npx prisma db push
```

Ini akan menambahkan kolom `shift` ke table `User`.

### Step 4: Generate Prisma Client
```powershell
npx prisma generate
```

### Step 5: Re-seed Database
```powershell
npx prisma db seed
```

Ini akan assign shifts ke semua test users:
- Admin: No shift
- Cashier Pagi (Siti), Kasir Sore (Gilang)
- Chef Pagi (Budi), Chef Sore (Hana)
- Waiter Pagi (Dewi), Waiter Sore (Fitri)
- Employee Sore (Eko)

### Step 6: Test API
```powershell
# Login as admin
curl -X POST http://localhost:3000/auth/login `
  -H "Content-Type: application/json" `
  -d '{\"email\":\"admin@restoran.com\",\"password\":\"admin123\"}'

# Get all users (should show shift field)
curl http://localhost:3000/users `
  -H "Authorization: Bearer <your_token>"

# Create user with shift
curl -X POST http://localhost:3000/users `
  -H "Authorization: Bearer <your_token>" `
  -H "Content-Type: application/json" `
  -d '{\"nama\":\"Test User\",\"email\":\"test@test.com\",\"password\":\"test123\",\"roleId\":4,\"shift\":\"Pagi\"}'
```

## 📝 API Changes

### Create User (POST /users)

**Before:**
```json
{
  "nama": "John Doe",
  "email": "john@restoran.com",
  "password": "john123",
  "roleId": 4,
  "gajiPerJam": 20000
}
```

**After (NEW: shift field):**
```json
{
  "nama": "John Doe",
  "email": "john@restoran.com",
  "password": "john123",
  "roleId": 4,
  "gajiPerJam": 20000,
  "shift": "Pagi"
}
```

### Update User (PUT /users/:id)

**New capability:** Update shift
```json
{
  "shift": "Sore"
}
```

**Remove shift:**
```json
{
  "shift": null
}
```

### Get Users (GET /users)

**Response now includes shift:**
```json
{
  "data": [
    {
      "id": 3,
      "nama": "Budi Santoso",
      "shift": "Pagi",
      ...
    }
  ]
}
```

## ⚠️ Validation Rules

**Valid shift values:**
- `"Pagi"`
- `"Sore"`
- `null` (no shift)

**Invalid values (will return 400):**
- `"Malam"`
- `"pagi"` (case-sensitive!)
- `""`
- Any other string

## 🎯 Frontend Impact

### 1. Update User Form (Create/Edit)

Add shift dropdown:
```jsx
<select name="shift">
  <option value="">-- No Shift --</option>
  <option value="Pagi">Pagi (09:00-15:00)</option>
  <option value="Sore">Sore (15:00-21:00)</option>
</select>
```

### 2. User List Display

Show shift column:
```jsx
<table>
  <thead>
    <tr>
      <th>Nama</th>
      <th>Email</th>
      <th>Role</th>
      <th>Shift</th>  {/* NEW */}
    </tr>
  </thead>
  <tbody>
    {users.map(user => (
      <tr key={user.id}>
        <td>{user.nama}</td>
        <td>{user.email}</td>
        <td>{user.role.nama}</td>
        <td>{user.shift || '-'}</td>  {/* NEW */}
      </tr>
    ))}
  </tbody>
</table>
```

### 3. Populate Shift Dropdown from API

```javascript
// Get shift templates from API
const response = await fetch('/shifts', {
  headers: { 'Authorization': 'Bearer ' + token }
});
const shifts = await response.json();

// Render dropdown
shifts.data.map(shift => (
  <option value={shift.nama}>
    {shift.nama} ({shift.jamMulai} - {shift.jamSelesai})
  </option>
))
```

## 🐛 Troubleshooting

### Error: "Shift harus 'Pagi' atau 'Sore'"
**Cause:** Sending invalid shift value  
**Fix:** Use exact values "Pagi" or "Sore" (case-sensitive)

### Error: "Unknown column 'shift'"
**Cause:** Schema not pushed to database  
**Fix:** Run `npx prisma db push`

### Error: User.shift is undefined
**Cause:** Prisma Client not regenerated  
**Fix:** Run `npx prisma generate`

### Seed shows old users without shift
**Cause:** Old seed data  
**Fix:** Run `npx prisma db seed` to update users

## 📚 Documentation

Full documentation available in:
- **[SHIFT-ASSIGNMENT.md](./backend/docs/SHIFT-ASSIGNMENT.md)** - Complete shift assignment guide
- **[API-USER.md](./backend/docs/API-USER.md)** - User CRUD API with shift examples
- **[CHANGELOG.md](./backend/docs/CHANGELOG.md)** - Version 0.4.1 changelog

## ✅ Testing Checklist

After update, verify:
- [ ] SQL Server is running
- [ ] `npx prisma db push` completed successfully
- [ ] `npx prisma generate` completed successfully
- [ ] `npx prisma db seed` shows shift assignments
- [ ] GET /users returns shift field
- [ ] POST /users with shift="Pagi" works
- [ ] POST /users with shift="Malam" returns 400
- [ ] PUT /users/:id can update shift
- [ ] PUT /users/:id can remove shift (set null)

## 🆘 Need Help?

Contact team lead or check:
1. [TROUBLESHOOTING.md](./backend/docs/TROUBLESHOOTING.md)
2. [SYNC-DATABASE.md](./backend/docs/SYNC-DATABASE.md)
3. [CHANGELOG.md](./backend/docs/CHANGELOG.md)

---

**Version:** 0.4.1  
**Last Updated:** 2025-11-11
