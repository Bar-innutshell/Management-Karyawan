# ERROR P1000 - Authentication Failed

## 🔴 Error Message:
```
Error: P1000: Authentication failed against database server, 
the provided database credentials for prisma_user are not valid.
```

---

## 📝 Apa Artinya?

**Good news:** SQL Server **sudah bisa diakses**! Error P1001 sudah teratasi.

**Problem:** Username atau password yang ada di `.env` **tidak valid** atau user `prisma_user` belum dibuat di SQL Server.

---

## ✅ SOLUSI - Buat/Reset User SQL Server

### Step 1: Cek User di .env

Buka `backend/.env`, lihat baris `DATABASE_URL`:

```env
DATABASE_URL="sqlserver://localhost:1433;database=db_restoran;user=prisma_user;password=Prisma!2025;encrypt=true;trustServerCertificate=true"
```

**Username:** `prisma_user`  
**Password:** `Prisma!2025`

Catat username dan password ini, kita akan buat di SQL Server.

---

### Step 2: Buat Login dan User di SQL Server

Ada 2 cara:

#### **CARA 1: Pakai Script SQL (RECOMMENDED)**

Saya sudah buatkan script `setup-sql-login.sql`. Jalankan:

**Via SSMS (SQL Server Management Studio):**
1. Buka **SSMS**
2. Connect ke server: `.\SQLEXPRESS` atau `localhost,1433` (pakai Windows Authentication)
3. File → Open → `backend\setup-sql-login.sql`
4. Tekan **F5** atau klik **Execute**

**Via sqlcmd:**
```powershell
# Run di PowerShell:
cd backend
sqlcmd -S localhost\SQLEXPRESS -E -i setup-sql-login.sql
```

#### **CARA 2: Manual via SSMS GUI**

1. Buka **SSMS**, connect ke server
2. Expand **Security** → **Logins**
3. Klik kanan **Logins** → **New Login**
4. Login name: `prisma_user`
5. Pilih **SQL Server authentication**
6. Password: `Prisma!2025`
7. Confirm password: `Prisma!2025`
8. ✅ **UNCHECK** "User must change password at next login"
9. ✅ **UNCHECK** "Enforce password policy" (opsional, untuk development)
10. Tab **Server Roles** → ✅ Check **dbcreator** (agar bisa buat database)
11. Tab **User Mapping**:
    - ✅ Check **db_restoran** (jika database sudah ada)
    - Di bawah, check role: **db_owner**
12. Klik **OK**

---

### Step 3: Grant Permissions

Setelah login dibuat, pastikan user punya permission:

```sql
-- Jalankan di SSMS atau sqlcmd:

-- Grant dbcreator role (untuk buat database)
USE master;
ALTER SERVER ROLE dbcreator ADD MEMBER prisma_user;

-- Grant permission di database db_restoran
USE db_restoran;
CREATE USER prisma_user FOR LOGIN prisma_user;
ALTER ROLE db_owner ADD MEMBER prisma_user;
GO
```

Atau jalankan file `grant-create-db.sql` yang sudah ada:

```powershell
sqlcmd -S localhost\SQLEXPRESS -E -i grant-create-db.sql
```

---

### Step 4: Verifikasi User Sudah Dibuat

```sql
-- Jalankan di SSMS:

-- Cek login di server level
SELECT name, type_desc, is_disabled 
FROM sys.server_principals 
WHERE name = 'prisma_user';

-- Cek user di database level
USE db_restoran;
SELECT name, type_desc 
FROM sys.database_principals 
WHERE name = 'prisma_user';
```

**Expected output:**
```
name          type_desc        is_disabled
prisma_user   SQL_LOGIN        0
```

---

### Step 5: Test Login dengan sqlcmd

Test apakah user bisa login:

```powershell
sqlcmd -S localhost,1433 -U prisma_user -P "Prisma!2025" -Q "SELECT DB_NAME(), USER_NAME()"
```

**Expected output:**
```
-------------------- --------------------
master               prisma_user

(1 rows affected)
```

Jika berhasil, berarti **authentication sudah OK**!

---

### Step 6: Test dengan Node.js

```powershell
cd backend
node test-connection.js
```

**Expected:**
```
✅ Step 1: Connection SUCCESSFUL!
✅ Step 2: Query execution SUCCESSFUL!
✅ Step 3: Database 'db_restoran' EXISTS!
✅ Step 4: Permission check SUCCESSFUL!
🎉 ALL TESTS PASSED!
```

---

### Step 7: Jalankan Prisma DB Push

```powershell
npx prisma db push
```

Jika berhasil, lanjutkan:
```powershell
npx prisma generate
npm run db:seed
npm run dev
```

---

## 🔧 TROUBLESHOOTING

### Error: "Login failed for user 'prisma_user'"

**Penyebab:** Password salah atau user belum dibuat.

**Fix:**
1. Re-check password di `.env` (case-sensitive!)
2. Re-buat user dengan script `setup-sql-login.sql`
3. Pastikan SQL Server dalam **Mixed Authentication mode**

---

### Error: "User does not have permission to CREATE DATABASE"

**Penyebab:** User belum punya role `dbcreator`.

**Fix:**
```sql
USE master;
ALTER SERVER ROLE dbcreator ADD MEMBER prisma_user;
```

---

### Error: "Cannot open database 'db_restoran'"

**Penyebab:** Database belum dibuat atau user tidak punya akses.

**Fix:**
```sql
-- Buat database jika belum ada
CREATE DATABASE db_restoran;
GO

-- Grant akses
USE db_restoran;
CREATE USER prisma_user FOR LOGIN prisma_user;
ALTER ROLE db_owner ADD MEMBER prisma_user;
GO
```

---

### Lupa Password atau Mau Ganti Password

```sql
-- Reset password untuk prisma_user
USE master;
ALTER LOGIN prisma_user WITH PASSWORD = 'PasswordBaru123!';
```

Jangan lupa update di `.env` juga!

---

## ⚠️ PASTIKAN SQL SERVER DALAM MIXED AUTHENTICATION MODE

SQL Server harus support SQL Authentication (bukan hanya Windows Auth).

**Cek & Enable:**

1. Buka **SSMS**
2. Klik kanan server → **Properties**
3. Tab **Security**
4. Pilih: **SQL Server and Windows Authentication mode**
5. Klik **OK**
6. **Restart SQL Server service:**
   ```powershell
   Restart-Service -Name "MSSQL$SQLEXPRESS" -Force
   ```

---

## 📋 CHECKLIST

- [ ] Mixed Authentication mode **ENABLED**
- [ ] Login `prisma_user` **CREATED** di server level
- [ ] Password match dengan yang di `.env`
- [ ] Role **dbcreator** granted ke `prisma_user`
- [ ] Database `db_restoran` **EXISTS**
- [ ] User `prisma_user` **CREATED** di database `db_restoran`
- [ ] Role **db_owner** granted di database
- [ ] Test dengan sqlcmd **BERHASIL**
- [ ] Test dengan `node test-connection.js` **BERHASIL**

---

## 💡 TIPS

- **Password case-sensitive!** `Prisma!2025` ≠ `prisma!2025`
- **Restart SQL Server** setelah enable Mixed Authentication
- **Jangan pakai sa account** untuk development (security risk)
- **Backup password** yang dipakai di `.env`
- Jika lupa password, reset dengan `ALTER LOGIN ... WITH PASSWORD`

---

**Next Error?**
- Jika sudah fix P1000 tapi ada error lain → cek `TROUBLESHOOTING.md`
- Error EPERM saat `prisma generate` → tutup server dulu (`Ctrl+C`)
