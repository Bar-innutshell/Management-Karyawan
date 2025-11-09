# Error Documentation Index

Dokumentasi lengkap untuk troubleshooting error-error yang sering muncul saat setup dan development.

---

## 📂 Daftar Error Documentation

### Prisma Errors

#### [ERROR-P1000.md](ERROR-P1000.md) - Authentication Failed
```
Error: P1000: Authentication failed against database server
```
**Penyebab:** Username/password salah atau user SQL Server belum dibuat  
**Solusi:** Buat user `prisma_user` dengan script `setup-sql-login.sql`

---

#### [ERROR-P1001.md](ERROR-P1001.md) - Can't Reach Database Server
```
Error: P1001: Can't reach database server at localhost:1433
```
**Penyebab:** SQL Server tidak running, TCP/IP disabled, atau port 1433 tidak listening  
**Solusi:** Enable TCP/IP protocol, set port 1433, restart SQL Server

---

#### [ERROR-FOREIGN-KEY.md](ERROR-FOREIGN-KEY.md) - Foreign Key Constraint Violated 🔥 HOT
```
Foreign key constraint violated on the constraint: 'User_roleId_fkey'
```
**Penyebab:** Database belum di-seed, tabel `Role` kosong, tidak ada roleId yang valid  
**Solusi:** Jalankan `npm run db:seed` untuk create roles default

---

### General Errors

#### [ERROR-EPERM.md](ERROR-EPERM.md) - Operation Not Permitted ⚡ HOT
```
EPERM: operation not permitted, rename '...query_engine-windows.dll.node...'
```
**Penyebab:** File Prisma sedang digunakan (server masih running)  
**Solusi:** Stop server, kill Node.js processes, delete `.prisma` folder, generate ulang

---

#### ECONNRESET - Connection Reset
```
Error: aborted
  code: 'ECONNRESET'
```
**Penyebab:** Koneksi ke SQL Server terputus saat handshake  
**Solusi:** Lihat [ERROR-P1001.md](ERROR-P1001.md) - sama dengan P1001

---

#### Login Timeout Expired
```
Login timeout expired. Server is not found or not accessible.
```
**Penyebab:** SQL Server tidak ditemukan atau TCP/IP disabled  
**Solusi:** Lihat [ERROR-P1001.md](ERROR-P1001.md)

---

## 🛠️ Tools untuk Troubleshooting

📁 **[Folder Tools](tools/)** - Semua diagnostic & setup scripts ada di sini!

### Diagnostic Tools
- **[`diagnose-sql.ps1`](tools/diagnose-sql.ps1)** - Auto-diagnose dan fix SQL Server issues (Run as Administrator)
- **[`diagnose-sql.bat`](tools/diagnose-sql.bat)** - Batch version (tidak perlu Admin)
- **[`test-connection.js`](tools/test-connection.js)** - Test koneksi database dengan Node.js

### Setup Scripts
- **[`setup-sql-login.sql`](tools/setup-sql-login.sql)** - Buat user `prisma_user` otomatis
- **[`enable-sql-auth.ps1`](tools/enable-sql-auth.ps1)** - Enable Mixed Authentication mode
- **[`grant-create-db.sql`](tools/grant-create-db.sql)** - Grant dbcreator role ke user

📖 **[Tools Documentation](tools/README.md)** - Panduan lengkap cara pakai semua tools

---

## 📋 Troubleshooting Workflow

### 1. **Identifikasi Error**
Lihat error code (P1000, P1001, ECONNRESET, dll) dan baca dokumentasi spesifiknya.

### 2. **Jalankan Diagnostic Tool**
```powershell
cd backend/docs/errors/tools
.\diagnose-sql.ps1  # Run as Administrator
```

### 3. **Test Connection**
```powershell
cd backend/docs/errors/tools
node test-connection.js
```

### 4. **Fix Sesuai Error**
- **P1001?** → Enable TCP/IP, set port 1433 → [Guide](ERROR-P1001.md)
- **P1000?** → Buat user dengan `setup-sql-login.sql` → [Guide](ERROR-P1000.md)
- **EPERM?** → Stop server, kill Node.js, delete `.prisma` → [Guide](ERROR-EPERM.md)
- **Foreign Key?** → Seed database dengan `npm run db:seed` → [Guide](ERROR-FOREIGN-KEY.md)

### 5. **Verify Fix**
```powershell
npx prisma db push
npx prisma generate
npm run db:seed
npm run dev
```

---

## 🔗 Quick Links

- [Main TROUBLESHOOTING.md](../../../TROUBLESHOOTING.md) - Troubleshooting lengkap
- [QUICK-FIX.md](../../../QUICK-FIX.md) - Solusi cepat untuk error umum
- [SETUP.md](../../../SETUP.md) - Setup guide lengkap
- [API.md](../API.md) - API documentation
- [POSTMAN.md](../POSTMAN.md) - Postman testing guide

---

## 💡 Tips Debugging

1. **Selalu jalankan diagnostic tool dulu** sebelum coba fix manual
2. **Baca error message dengan teliti** - error code memberikan hint yang jelas
3. **Test dengan sqlcmd** untuk isolate masalah SQL Server vs Prisma
4. **Check service status** - SQL Server service harus running
5. **Verify .env file** - connection string harus benar
6. **Restart after changes** - restart SQL Server setelah config changes
7. **One fix at a time** - jangan ubah banyak hal sekaligus
8. **Document your fixes** - catat solusi yang berhasil untuk tim

---

## 🆘 Masih Butuh Bantuan?

Jika masih error setelah ikuti dokumentasi:

1. Screenshot error message lengkap
2. Jalankan `diagnose-sql.ps1` dan screenshot output
3. Jalankan `node test-connection.js` dan screenshot output
4. Share ke tim dengan informasi:
   - Error code
   - Steps yang sudah dicoba
   - Output dari diagnostic tools

---

**Last Updated:** November 8, 2025  
**Maintainer:** Development Team
