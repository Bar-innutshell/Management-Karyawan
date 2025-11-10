# QUICK FIX — Error Koneksi SQL Server

## ❌ Error yang Sering Muncul:

**Error 1 - P1001 (Can't reach database server):**
```
Error: P1001: Can't reach database server at localhost:1433
Please make sure your database server is running at localhost:1433.
```

**Error 2 - ECONNRESET:**
```
Error: aborted
  code: 'ECONNRESET'
```

**Error 3 - Login Timeout:**
```
Login timeout expired.
Server is not found or not accessible.
```

**Penyebab:** SQL Server tidak running, TCP/IP disabled, port 1433 tidak listening, atau connection string salah.

---

## 🔍 DIAGNOSTIC TOOL - Jalankan Ini Dulu!

**PENTING:** Sebelum coba fix manual, jalankan diagnostic tool dulu untuk tahu masalah sebenarnya:

```powershell
# Run as Administrator di PowerShell:
cd backend
.\diagnose-sql.ps1
```

Script ini akan:
- ✅ Cek SQL Server service status (dan start otomatis jika mati)
- ✅ Cek port 1433 listening atau tidak
- ✅ Test TCP connection ke localhost:1433
- ✅ Cek firewall rules (dan buat otomatis jika perlu)
- ✅ Cek .env file configuration
- ✅ Test database connection dengan Node.js

**Atau pakai batch file (tidak perlu Admin):**
```cmd
cd backend
diagnose-sql.bat
```

Setelah diagnostic selesai, ikuti instruksi yang diberikan oleh script.

---

## ⚠️ PENTING: Cek Connection String Dulu!

Buka file `.env` di folder `backend`, pastikan menggunakan format ini:

**✅ BENAR:**
```env
DATABASE_URL="sqlserver://localhost:1433;database=db_restoran;user=prisma_user;password=Prisma!2025;encrypt=true;trustServerCertificate=true"
```

**❌ SALAH - JANGAN pakai instance name:**
```env
DATABASE_URL="sqlserver://localhost\SQLEXPRESS;database=..."
DATABASE_URL="sqlserver://localhost\SQLEXPRESS:1433;database=..."
```

**Gunakan `localhost:1433` (dengan titik dua), BUKAN `localhost\SQLEXPRESS`!**

---

### 1️⃣ PASTIKAN SQL SERVER RUNNING

```powershell
# Run di PowerShell as Administrator:
Get-Service -Name "MSSQL*" | Start-Service
```

Atau manual:
- Tekan `Win + R` → ketik `services.msc`
- Cari **SQL Server (SQLEXPRESS)**
- Klik kanan → **Start** (jika belum running)

---

### 2️⃣ ENABLE TCP/IP PROTOCOL

1. Buka **SQL Server Configuration Manager**
2. Expand: **SQL Server Network Configuration**
3. Klik: **Protocols for SQLEXPRESS**
4. Klik kanan **TCP/IP** → **Enable**
5. **RESTART SQL Server service:**

```powershell
# Run di PowerShell as Administrator:
Restart-Service -Name "MSSQL`$SQLEXPRESS" -Force
```

---

### 3️⃣ BUKA PORT 1433 DI FIREWALL

```powershell
# Run di PowerShell as Administrator:
New-NetFirewallRule -DisplayName "SQL Server" -Direction Inbound -Protocol TCP -LocalPort 1433 -Action Allow
```

---

### 4️⃣ TEST KONEKSI

```powershell
cd backend
node test-connection.js
```

**Harus muncul:**
```
✅ Step 1: Connection SUCCESSFUL!
✅ Step 2: Query execution SUCCESSFUL!
🎉 ALL TESTS PASSED!
```

**Jika masih error**, lihat output error dan ikuti saran yang diberikan.

---

### 5️⃣ JALANKAN PRISMA

```powershell
npx prisma db push
npx prisma generate
npm run db:seed
npm run dev
```

---

## 🆘 MASIH ERROR?

Baca file lengkap: **`TROUBLESHOOTING.md`**

Atau hubungi:
- Teman yang sudah berhasil setup
- Check dokumentasi resmi Prisma: https://pris.ly/d/connection-strings

---

## 📝 CHECKLIST

Centang semua ini:

- [ ] SQL Server service running (cek di `services.msc`)
- [ ] TCP/IP protocol enabled (di SQL Server Configuration Manager)
- [ ] Port 1433 terbuka (cek: `netstat -an | findstr "1433"`)
- [ ] Firewall allow port 1433
- [ ] **CONNECTION STRING BENAR** di `.env` (pakai `localhost:1433`, bukan `localhost\SQLEXPRESS`)
- [ ] Test connection berhasil (`node test-connection.js`)
- [ ] File `.env` sudah diisi dengan benar
- [ ] Database `db_restoran` sudah dibuat
- [ ] User `prisma_user` ada dan punya permission

---

## 💡 TIPS DEBUGGING

**Test manual dengan sqlcmd:**
```powershell
# Format sqlcmd berbeda (pakai koma):
sqlcmd -S localhost,1433 -U prisma_user -P "Prisma!2025" -Q "SELECT DB_NAME()"
```

Jika sqlcmd berhasil tapi Prisma gagal, berarti **connection string salah**.

**Test dengan Node.js:**
```powershell
cd backend
node test-connection.js
```

Script ini akan memberikan diagnosis lengkap masalahnya.

---

Jika semua ✅, maka `npx prisma db push` pasti berhasil! 🎉
