# 🧪 Test Slip Gaji API

## Setup (Do this first!)

### 1. Start Server
```bash
cd backend
node index.js
```

### 2. Login as Admin
```bash
POST http://localhost:3000/auth/login
Content-Type: application/json

{
  "email": "admin@restoran.com",
  "password": "admin123"
}
```

**Save the token from response!** You'll need it for next requests.

---

## Test Cases

### ✅ TEST 1: View All Slip Gaji (Oktober 2025)

**Request:**
```bash
GET http://localhost:3000/gaji/slip/all?bulan=10&tahun=2025
Authorization: Bearer <your_admin_token>
```

**Expected Response:**
```json
{
  "message": "Data slip gaji berhasil diambil",
  "data": [
    {
      "id": 1,
      "userId": 3,
      "bulan": 10,
      "tahun": 2025,
      "gajiBulanan": 3977568,
      "bonusKehadiran": 300000,
      "bonusLainnya": 150000,
      "potonganAlpha": 0,
      "potonganTelat": 9931,
      "potonganLainnya": 0,
      "totalGajiKotor": 4427568,
      "totalPotongan": 9931,
      "totalGajiBersih": 4417637,
      "keterangan": "Gaji Oktober 2025 - Perfect Attendance + Chef of the Month",
      "user": {
        "nama": "Budi Santoso",
        "email": "budi.chef@restoran.com",
        "role": {
          "nama": "Chef"
        }
      }
    },
    // ... 6 more employees
  ],
  "summary": {
    "totalSlip": 7,
    "totalGajiBersih": 22270109
  }
}
```

**✅ Success Criteria:**
- Returns 7 slip gaji
- Total payroll: Rp 22.270.109
- All employees have 100% attendance rate
- Chefs get extra bonus (Rp 150.000)

---

### ✅ TEST 2: View Specific User Slip Gaji

**Request:**
```bash
GET http://localhost:3000/gaji/slip/user/3
Authorization: Bearer <your_admin_token>
```

**Expected Response:**
```json
{
  "message": "Data slip gaji berhasil diambil",
  "data": [
    {
      "id": 1,
      "userId": 3,
      "bulan": 10,
      "tahun": 2025,
      "totalGajiBersih": 4417637,
      "keterangan": "Gaji Oktober 2025 - Perfect Attendance + Chef of the Month",
      "user": {
        "nama": "Budi Santoso",
        "email": "budi.chef@restoran.com",
        "role": {
          "nama": "Chef"
        }
      }
    }
  ],
  "summary": {
    "totalSlip": 1
  }
}
```

**✅ Success Criteria:**
- Returns slip for Budi Santoso (Chef)
- Total gaji bersih: Rp 4.417.637
- Has bonus for chef of the month

---

### ✅ TEST 3: Employee View Their Own Slip

**Step 1: Login as Employee**
```bash
POST http://localhost:3000/auth/login
Content-Type: application/json

{
  "email": "budi.chef@restoran.com",
  "password": "budi123"
}
```

**Step 2: View Own Slip**
```bash
GET http://localhost:3000/gaji/slip/user/3?bulan=10&tahun=2025
Authorization: Bearer <budi_token>
```

**✅ Success Criteria:**
- Employee can see their own slip
- Cannot see other employees' slips (403 Forbidden)

---

### ✅ TEST 4: Try to View Another Employee's Slip (Should Fail)

**Request (as Budi, userId=3):**
```bash
GET http://localhost:3000/gaji/slip/user/4
Authorization: Bearer <budi_token>
```

**Expected Response:**
```json
{
  "message": "Anda tidak memiliki akses untuk melihat slip gaji user lain"
}
```

**✅ Success Criteria:**
- Returns 403 Forbidden
- Authorization works correctly

---

### ✅ TEST 5: Generate Slip Gaji for November (New Month)

**Request:**
```bash
POST http://localhost:3000/gaji/slip/generate
Authorization: Bearer <admin_token>
Content-Type: application/json

{
  "userId": 3,
  "bulan": 11,
  "tahun": 2025,
  "bonusKehadiran": 500000,
  "bonusLainnya": 200000,
  "keterangan": "Gaji November 2025 - Outstanding Performance"
}
```

**Expected Response:**
```json
{
  "message": "Slip gaji berhasil dibuat",
  "data": {
    "slipGaji": {
      "id": 8,
      "userId": 3,
      "bulan": 11,
      "tahun": 2025,
      "gajiBulanan": 4200000,  // Will vary based on actual attendance
      "bonusKehadiran": 500000,
      "bonusLainnya": 200000,
      "totalGajiBersih": 4850000,  // Approximate
      "keterangan": "Gaji November 2025 - Outstanding Performance"
    },
    "detail": {
      "periode": "11/2025",
      "jumlahHadir": 18,  // Will vary
      "jumlahAlpha": 0,
      "totalAbsensi": 18
    }
  }
}
```

**✅ Success Criteria:**
- Slip created successfully
- Bonus added correctly
- Total calculated based on actual attendance

---

### ✅ TEST 6: Try to Create Duplicate Slip (Should Fail)

**Request (same as TEST 5):**
```bash
POST http://localhost:3000/gaji/slip/generate
Authorization: Bearer <admin_token>
Content-Type: application/json

{
  "userId": 3,
  "bulan": 10,
  "tahun": 2025
}
```

**Expected Response:**
```json
{
  "message": "Slip gaji untuk Budi Santoso bulan 10/2025 sudah ada",
  "data": {
    // existing slip data
  }
}
```

**✅ Success Criteria:**
- Returns 400 Bad Request
- Prevents duplicate slip creation

---

### ✅ TEST 7: Filter by Year Only

**Request:**
```bash
GET http://localhost:3000/gaji/slip/all?tahun=2025
Authorization: Bearer <admin_token>
```

**✅ Success Criteria:**
- Returns all slips for year 2025
- Currently should return 7 slips (Oktober only)

---

### ✅ TEST 8: View Slip with Prisma Studio

**Command:**
```bash
npx prisma studio
```

**Steps:**
1. Open http://localhost:5555
2. Click on "SlipGaji" table
3. View all generated slips
4. Check the calculated values

**✅ Success Criteria:**
- All 7 slips visible
- Data matches API responses
- Calculations are correct

---

## 📊 Expected Data Summary

| Employee | Role | Days Present | Bonus | Net Salary |
|----------|------|--------------|-------|------------|
| Budi Santoso | Chef | 14 | Rp 450.000 | Rp 4.417.637 |
| Hana Safitri | Chef | 14 | Rp 450.000 | Rp 4.361.110 |
| Gilang Ramadhan | Cashier | 15 | Rp 300.000 | Rp 3.771.250 |
| Siti Nurhaliza | Cashier | 14 | Rp 300.000 | Rp 3.425.000 |
| Fitri Handayani | Waiter | 12 | Rp 300.000 | Rp 2.196.000 |
| Eko Prasetyo | Employee | 10 | Rp 300.000 | Rp 2.160.000 |
| Dewi Lestari | Waiter | 10 | Rp 300.000 | Rp 1.939.112 |

**Total Payroll:** Rp 22.270.109

---

## 🐛 Troubleshooting

### "Token expired" or "Invalid token"
**Solution:** Login again to get new token

### "User tidak ditemukan"
**Solution:** Check if userId is correct. Use `GET /gaji/all` to see valid user IDs

### "No attendance data"
**Solution:** Make sure employee has attendance records for that month

### Server not responding
**Solution:** 
```bash
# Kill existing node process
Get-Process node -ErrorAction SilentlyContinue | Stop-Process -Force

# Restart server
cd backend
node index.js
```

---

## ✅ All Tests Passed?

If all tests pass, your Slip Gaji system is working perfectly! 🎉

**What you've verified:**
- ✅ Admin can view all slips
- ✅ Admin can generate new slips
- ✅ Employees can view their own slips only
- ✅ Authorization works correctly
- ✅ Calculations are accurate
- ✅ Duplicate prevention works
- ✅ Bonus system works
- ✅ Filtering works (by month, year, user)

---

**Created:** November 11, 2025  
**Last Updated:** November 11, 2025
