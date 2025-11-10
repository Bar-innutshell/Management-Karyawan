# TROUBLESHOOTING - Error Koneksi SQL Server

## Error yang Sering Muncul:

### Error 1: ECONNRESET
```
Error: aborted
  code: 'ECONNRESET'
```
**Artinya:** Koneksi ke SQL Server terputus saat Prisma mencoba connect.

### Error 2: Login Timeout Expired
```
Sqlcmd: Error: Microsoft ODBC Driver 17 for SQL Server : Login timeout expired.
Sqlcmd: Error: A network-related or instance-specific error has occurred while 
establishing a connection to SQL Server. Server is not found or not accessible.
```
**Artinya:** SQL Server tidak ditemukan atau tidak bisa diakses dalam waktu timeout.

### Error 3: Server is not found
```
Server is not found or not accessible. Check if instance name is correct and if 
SQL Server is configured to allow remote connections.
```
**Artinya:** Instance SQL Server tidak ditemukan atau TCP/IP tidak enabled.

---

## ⚠️ PENTING: Jangan Pakai Instance Name + Port Bersamaan!

**❌ SALAH:**
```
localhost\SQLEXPRESS,1433  // Conflict antara instance name dan port!
```

**✅ BENAR - Pilih salah satu:**
```
localhost,1433              // Pakai port static (REKOMENDASI)
localhost\SQLEXPRESS        // Pakai instance name (butuh SQL Browser)
```

**Untuk project ini, GUNAKAN PORT 1433 STATIC** (tanpa instance name).

---

## ✅ SOLUSI STEP-BY-STEP

### 1. CEK SQL SERVER SERVICE BERJALAN

Buka **Services** (tekan `Win + R`, ketik `services.msc`):

1. Cari service: **SQL Server (SQLEXPRESS)** atau **SQL Server (MSSQLSERVER)**
2. Pastikan **Status = Running**
3. Jika tidak running, klik kanan → **Start**

```powershell
# Atau jalankan command ini di PowerShell (Run as Administrator):
Get-Service -Name "MSSQL*" | Start-Service

# PENTING: Jika pakai port 1433 static, TIDAK PERLU start SQL Server Browser
# SQL Server Browser hanya diperlukan jika pakai instance name tanpa port
```

**CATATAN:** Untuk project ini yang pakai `localhost,1433` (port static), **TIDAK PERLU** SQL Server Browser service. Browser hanya diperlukan untuk dynamic ports atau instance name.

---

### 2. ENABLE TCP/IP PROTOCOL

SQL Server harus mengizinkan koneksi TCP/IP:

1. Buka **SQL Server Configuration Manager**
2. Expand **SQL Server Network Configuration**
3. Klik **Protocols for SQLEXPRESS** (atau MSSQLSERVER)
4. Klik kanan **TCP/IP** → **Enable**
5. **RESTART SQL Server service** setelah enable TCP/IP

```powershell
# Restart SQL Server setelah enable TCP/IP:
Restart-Service -Name "MSSQL`$SQLEXPRESS" -Force
```

---

### 3. CEK PORT 1433 TERBUKA

Verifikasi bahwa SQL Server listen di port 1433:

```powershell
# Jalankan di PowerShell:
netstat -an | findstr "1433"
```

**Hasil yang diharapkan:**
```
TCP    0.0.0.0:1433           0.0.0.0:0              LISTENING
TCP    [::]:1433              [::]:0                 LISTENING
```

Jika port 1433 tidak muncul:

1. Buka **SQL Server Configuration Manager**
2. Klik **SQL Server Network Configuration** → **Protocols for SQLEXPRESS**
3. Double-click **TCP/IP**
4. Tab **IP Addresses**
5. Scroll ke **IPALL**
6. Set:
   - **TCP Dynamic Ports**: *kosongkan*
   - **TCP Port**: `1433`
7. **Restart SQL Server service**

---

### 4. DISABLE FIREWALL (SEMENTARA UNTUK TEST)

Firewall Windows mungkin memblokir port 1433:

```powershell
# Run as Administrator - Buat firewall rule untuk SQL Server:
New-NetFirewallRule -DisplayName "SQL Server" -Direction Inbound -Protocol TCP -LocalPort 1433 -Action Allow
```

Atau matikan Windows Firewall sementara untuk test:
1. Control Panel → Windows Defender Firewall
2. Turn Windows Defender Firewall off (untuk Private network)
3. Test lagi `npx prisma db push`
4. Jika berhasil, nyalakan firewall lagi dan tambahkan exception untuk port 1433

---

### 5. TEST KONEKSI KE SQL SERVER

Sebelum jalankan Prisma, test koneksi dulu:

**Buat file `test-connection.js`:**

```javascript
const sql = require('mssql');

const config = {
  server: 'localhost',
  port: 1433,
  user: 'prisma_user',
  password: 'Prisma!2025',
  database: 'db_restoran',
  options: {
    encrypt: true,
    trustServerCertificate: true,
    connectTimeout: 30000 // 30 detik timeout
  }
};

async function testConnection() {
  try {
    console.log('🔄 Mencoba koneksi ke SQL Server...');
    const pool = await sql.connect(config);
    console.log('✅ Koneksi BERHASIL!');
    
    const result = await pool.request().query('SELECT @@VERSION AS Version');
    console.log('SQL Server Version:', result.recordset[0].Version);
    
    await pool.close();
  } catch (err) {
    console.error('❌ Koneksi GAGAL!');
    console.error('Error:', err.message);
    console.error('\nDetail:', err);
  }
}

testConnection();
```

**Jalankan:**
```powershell
node test-connection.js
```

---

### 6. PASTIKAN SQL AUTHENTICATION ENABLED

SQL Server harus dalam mode **Mixed Authentication**:

1. Buka **SQL Server Management Studio (SSMS)**
2. Connect ke server
3. Klik kanan server name → **Properties**
4. Tab **Security**
5. Pilih **SQL Server and Windows Authentication mode**
6. Klik **OK**
7. **Restart SQL Server service**

---

### 7. PASTIKAN USER `prisma_user` ADA DAN PUNYA AKSES

```sql
-- Jalankan di SSMS atau sqlcmd:

-- Cek apakah login ada
SELECT name, type_desc FROM sys.server_principals WHERE name = 'prisma_user';

-- Cek apakah user ada di database
USE db_restoran;
SELECT name FROM sys.database_principals WHERE name = 'prisma_user';

-- Jika tidak ada, buat ulang:
USE master;
CREATE LOGIN prisma_user WITH PASSWORD = 'Prisma!2025';
ALTER SERVER ROLE dbcreator ADD MEMBER prisma_user;

USE db_restoran;
CREATE USER prisma_user FOR LOGIN prisma_user;
ALTER ROLE db_owner ADD MEMBER prisma_user;
```

---

### 8. VERIFIKASI CONNECTION STRING DI .ENV

**SANGAT PENTING:** Pastikan connection string menggunakan format yang benar!

**✅ BENAR (Yang Harus Dipakai):**
```env
DATABASE_URL="sqlserver://localhost:1433;database=db_restoran;user=prisma_user;password=Prisma!2025;encrypt=true;trustServerCertificate=true"
```

**❌ SALAH - Jangan pakai ini:**
```env
# SALAH: Pakai backslash dan instance name
DATABASE_URL="sqlserver://localhost\SQLEXPRESS;database=..."

# SALAH: Pakai instance name DAN port bersamaan
DATABASE_URL="sqlserver://localhost\SQLEXPRESS:1433;database=..."

# SALAH: Format koma untuk instance name
DATABASE_URL="sqlserver://localhost,SQLEXPRESS;database=..."
```

**Format yang Benar untuk Prisma:**
```
sqlserver://[HOST]:[PORT];database=[DB];user=[USER];password=[PASS];encrypt=true;trustServerCertificate=true
```

Di `sqlcmd` atau tools lain, format berbeda:
```bash
# sqlcmd pakai format berbeda (pakai -S flag):
sqlcmd -S localhost,1433 -U prisma_user -P "Prisma!2025" -Q "SELECT DB_NAME()"
```

**JANGAN CAMPUR format Prisma dengan format sqlcmd!**

---

### 9. INCREASE TIMEOUT DI PRISMA (Opsional)

Jika koneksi lambat, tambahkan `connectTimeout`:

```env
DATABASE_URL="sqlserver://localhost:1433;database=db_restoran;user=prisma_user;password=Prisma!2025;encrypt=true;trustServerCertificate=true;connectTimeout=30000"
```

---

### 10. COBA JALANKAN PRISMA DB PUSH LAGI

```powershell
npx prisma db push
```

Jika masih error, coba dengan verbose output:

```powershell
npx prisma db push --skip-generate
```

---

## ⚠️ CHECKLIST LENGKAP

Pastikan semua ini sudah dilakukan:

- [ ] SQL Server service running
- [ ] TCP/IP protocol enabled
- [ ] Port 1433 listening (cek dengan `netstat`)
- [ ] Firewall allow port 1433
- [ ] Mixed Authentication mode enabled
- [ ] User `prisma_user` exist dan punya permission
- [ ] Database `db_restoran` exist
- [ ] Connection string di `.env` benar
- [ ] Test connection dengan `test-connection.js` berhasil

---

## 🆘 JIKA MASIH ERROR

1. **Restart komputer** (serius, kadang ini solve masalah Windows)

2. **Cek Windows Event Viewer** untuk error SQL Server:
   ```powershell
   eventvwr.msc
   ```
   Lihat di: Windows Logs → Application → Filter for SQL Server errors

3. **Reinstall SQL Server** jika semua cara di atas gagal

4. **Gunakan Docker SQL Server** sebagai alternatif:
   ```powershell
   docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=Prisma!2025Strong" -p 1433:1433 --name sqlserver -d mcr.microsoft.com/mssql/server:2022-latest
   ```

---

## 📝 CATATAN PENTING

- Error `ECONNRESET` = koneksi terputus secara tiba-tiba
- Biasanya karena SQL Server tidak menerima koneksi TCP/IP
- **Port 1433 HARUS terbuka** dan SQL Server harus listen di port tersebut
- Jika pakai instance name (SQLEXPRESS), pastikan **SQL Server Browser service** juga running
- Tapi untuk port static 1433, **TIDAK PERLU** SQL Server Browser

---

## ✅ VERIFIKASI FINAL

Setelah semua langkah di atas, jalankan:

```powershell
# 1. Test koneksi
node test-connection.js

# 2. Prisma format (cek schema syntax)
npx prisma format

# 3. Prisma validate
npx prisma validate

# 4. Prisma db push
npx prisma db push

# 5. Prisma generate
npx prisma generate

# 6. Seed database
npm run db:seed

# 7. Start server
npm run dev
```

Semua command di atas harus **SUKSES** tanpa error! 🎉
