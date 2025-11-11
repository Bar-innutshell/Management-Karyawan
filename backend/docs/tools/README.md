# 🛠️ Backend Tools

Folder ini berisi tools dan scripts untuk migration, testing, dan utilities.

## 📁 Contents

### Migration Scripts

#### `add-timestamps-all-tables.sql` ⭐ **Recommended**
Script untuk menambahkan kolom `createdAt` dan `updatedAt` ke **semua tabel** (Absensi, Jadwal, LaporanPemasukan).

**Usage:**
```powershell
# From project root
sqlcmd -S .\SQLEXPRESS -E -i backend\docs\tools\add-timestamps-all-tables.sql

# Windows Auth
sqlcmd -S localhost,1433 -E -i backend\docs\tools\add-timestamps-all-tables.sql

# SQL Auth
sqlcmd -S localhost,1433 -U prisma_user -P "Prisma!2025" -i backend\docs\tools\add-timestamps-all-tables.sql
```

**Features:**
- ✅ Adds timestamps to Absensi table
- ✅ Adds timestamps to Jadwal table
- ✅ Adds timestamps to LaporanPemasukan table
- ✅ Checks if columns already exist before adding
- ✅ Safe to run multiple times
- ✅ Adds default values for existing rows

**See Also:** `../errors/FIX-CREATEDAT-ERROR.md`

---

#### `add-user-timestamps.sql`
Script untuk menambahkan kolom `createdAt` dan `updatedAt` ke tabel `User` saja.

**Usage:**
```powershell
# From backend folder
sqlcmd -S .\SQLEXPRESS -E -i docs/tools/add-user-timestamps.sql

# Windows Auth
sqlcmd -S localhost,1433 -E -i docs/tools/add-user-timestamps.sql

# SQL Auth
sqlcmd -S localhost,1433 -U prisma_user -P "Prisma!2025" -i docs/tools/add-user-timestamps.sql
```

**Features:**
- ✅ Checks if columns already exist before adding
- ✅ Safe to run multiple times
- ✅ Adds default values for existing rows
- ✅ Creates indexes for better performance

**Note:** Use `add-timestamps-all-tables.sql` instead if you need timestamps on all tables.

**See Also:** `../errors/FIX-CREATEDAT-ERROR.md`

---

#### `migrate-gaji-naming.sql`
Script untuk migrate field naming consistency pada sistem gaji.

**Usage:**
```powershell
sqlcmd -S .\SQLEXPRESS -E -i docs/tools/migrate-gaji-naming.sql
```

**What it does:**
- Renames inconsistent field names to follow naming convention
- Updates foreign key references
- Safe migration with rollback support

---

### Generator Scripts

#### `generate-slip-gaji.js`
Auto-generator untuk slip gaji bulanan semua karyawan.

**Usage:**
```powershell
# From backend folder
node docs/tools/generate-slip-gaji.js
```

**Features:**
- ✅ Generate slip gaji untuk semua karyawan (except Admin)
- ✅ Auto-calculate dari data absensi
- ✅ Smart bonus calculation based on attendance rate
- ✅ Special bonus untuk Chef dengan perfect attendance
- ✅ Skip jika slip sudah exist (safe to re-run)
- ✅ Detailed console output dengan summary

**Example Output:**
```
🧾 Generating Slip Gaji for Oktober 2025...

📊 Found 7 employees (excluding Admin)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

👤 Processing: Budi Santoso (Chef)
─────────────────────────────────────────────────
   📅 Attendance records: 30
   ✅ Slip created successfully!
      Days Present: 28 | Alpha: 2
      Attendance Rate: 93.3%
      Base Salary: Rp 4.890.000
      Bonus: Rp 200.000
      Deductions: Rp 340.000
      💰 NET SALARY: Rp 4.750.000

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✨ SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   Total Slips Created: 7
   Total Payroll (Net): Rp 22.270.109
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Configuration:**
- Edit `bulan` and `tahun` variables in script to change period
- Bonus thresholds:
  - 95%+ attendance = Rp 300.000
  - 90-95% attendance = Rp 200.000
  - 85-90% attendance = Rp 100.000
  - Chef + 95%+ = Additional Rp 150.000

**See Also:**
- `../TEST-SLIP-GAJI.md` - Test cases dan hasil
- `../SLIP-GAJI-GUIDE.md` - Complete documentation
- `../API.md` - API endpoints untuk slip gaji

---

## 📝 Notes

- **Always run from `backend` folder** untuk path consistency
- All scripts are **idempotent** (safe to run multiple times)
- Check documentation in `../` folder for detailed guides
- Migration scripts check existence before modifying database

---

## 🔗 Related Documentation

- `../README.md` - Backend documentation index
- `../SETUP.md` - Setup guide untuk teammate
- `../TROUBLESHOOTING.md` - Common issues dan solutions
- `../errors/` - Error-specific documentation

---

**Last Updated:** November 11, 2025
