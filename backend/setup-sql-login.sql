-- Setup SQL Login untuk Prisma
-- Jalankan di SSMS dengan Windows Authentication

USE master;
GO

-- 1. Buat login SQL Server (ganti password sesuai kebutuhan)
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'prisma_user')
BEGIN
    CREATE LOGIN prisma_user WITH PASSWORD = 'Prisma!2025', CHECK_POLICY = OFF;
    PRINT 'Login prisma_user berhasil dibuat';
END
ELSE
BEGIN
    PRINT 'Login prisma_user sudah ada';
END
GO

-- 2. Grant dbcreator role (diperlukan untuk Prisma migrations)
ALTER SERVER ROLE dbcreator ADD MEMBER prisma_user;
PRINT 'Role dbcreator granted ke prisma_user';
GO

-- 3. Buat database jika belum ada
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'db_restoran')
BEGIN
    CREATE DATABASE db_restoran;
    PRINT 'Database db_restoran berhasil dibuat';
END
ELSE
BEGIN
    PRINT 'Database db_restoran sudah ada';
END
GO

-- 4. Buat user di database db_restoran
USE db_restoran;
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'prisma_user')
BEGIN
    CREATE USER prisma_user FOR LOGIN prisma_user;
END
GO

-- 4. Buat user di database db_restoran
USE db_restoran;
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'prisma_user')
BEGIN
    CREATE USER prisma_user FOR LOGIN prisma_user;
    PRINT 'User prisma_user berhasil dibuat di database db_restoran';
END
ELSE
BEGIN
    PRINT 'User prisma_user sudah ada di database db_restoran';
END
GO

-- 5. Beri akses penuh untuk migrasi (db_owner agar bisa CREATE TABLE, ALTER, dll)
ALTER ROLE db_owner ADD MEMBER prisma_user;
PRINT 'Role db_owner granted ke prisma_user di database db_restoran';
GO

PRINT '';
PRINT '============================================================';
PRINT 'SETUP SELESAI!';
PRINT '============================================================';
PRINT 'Login: prisma_user';
PRINT 'Password: Prisma!2025';
PRINT 'Database: db_restoran';
PRINT 'Roles: dbcreator (server), db_owner (database)';
PRINT '';
PRINT 'Test koneksi dengan:';
PRINT 'sqlcmd -S localhost,1433 -U prisma_user -P "Prisma!2025" -Q "SELECT DB_NAME()"';
PRINT '';
PRINT 'Atau test dengan Node.js:';
PRINT 'node test-connection.js';
PRINT '============================================================';
GO