-- =============================================
-- Migration: Rename Gaji Fields untuk Konsistensi
-- Jalankan dengan: sqlcmd -S .\SQLEXPRESS -E -d db_restoran -i migrate-gaji-naming.sql
-- =============================================

USE db_restoran;
GO

PRINT '🔧 Starting migration...';
GO

-- ========================================
-- PART 1: Role Table - gajiPokok → gajiPokokBulanan
-- ========================================

-- Drop default constraint dulu (yang ngalangin)
DECLARE @ConstraintName NVARCHAR(200);
SELECT @ConstraintName = name 
FROM sys.default_constraints 
WHERE parent_object_id = OBJECT_ID('Role') 
AND parent_column_id = (SELECT column_id FROM sys.columns WHERE object_id = OBJECT_ID('Role') AND name = 'gajiPokok');

IF @ConstraintName IS NOT NULL
BEGIN
    EXEC('ALTER TABLE Role DROP CONSTRAINT ' + @ConstraintName);
    PRINT '  ✓ Dropped default constraint on Role.gajiPokok';
END
GO

-- Tambah kolom baru
ALTER TABLE Role ADD gajiPokokBulanan FLOAT NOT NULL DEFAULT 0;
GO
PRINT '  ✓ Added Role.gajiPokokBulanan';

-- Copy data
UPDATE Role SET gajiPokokBulanan = gajiPokok;
GO
PRINT '  ✓ Copied data from gajiPokok to gajiPokokBulanan';

-- Drop kolom lama
ALTER TABLE Role DROP COLUMN gajiPokok;
GO
PRINT '  ✓ Dropped Role.gajiPokok';
PRINT '';

-- ========================================
-- PART 2: Gaji → SlipGaji dengan struktur baru
-- ========================================

-- Cek apakah ada data di Gaji
DECLARE @GajiCount INT;
SELECT @GajiCount = COUNT(*) FROM Gaji;

IF @GajiCount > 0
BEGIN
    PRINT '  ⚠️  Warning: Ada ' + CAST(@GajiCount AS NVARCHAR) + ' record di table Gaji';
    PRINT '  Data akan di-migrate ke SlipGaji dengan struktur baru';
    PRINT '';
END

-- Buat table SlipGaji baru
IF OBJECT_ID('SlipGaji', 'U') IS NOT NULL
BEGIN
    DROP TABLE SlipGaji;
    PRINT '  ✓ Dropped existing SlipGaji table';
END
GO

CREATE TABLE SlipGaji (
    id INT IDENTITY(1,1) PRIMARY KEY,
    
    -- Periode gaji
    bulan INT NOT NULL,
    tahun INT NOT NULL,
    
    -- Komponen gaji
    gajiBulanan FLOAT NOT NULL,
    bonusKehadiran FLOAT NOT NULL DEFAULT 0,
    bonusLainnya FLOAT NOT NULL DEFAULT 0,
    potonganAlpha FLOAT NOT NULL DEFAULT 0,
    potonganTelat FLOAT NOT NULL DEFAULT 0,
    potonganLainnya FLOAT NOT NULL DEFAULT 0,
    
    -- Total final
    totalGajiKotor FLOAT NOT NULL,
    totalPotongan FLOAT NOT NULL,
    totalGajiBersih FLOAT NOT NULL,
    
    -- Metadata
    tanggalBayar DATETIME NOT NULL DEFAULT GETDATE(),
    keterangan NVARCHAR(500) NULL,
    
    -- User relation
    userId INT NOT NULL FOREIGN KEY REFERENCES [User](id),
    
    -- Timestamps
    createdAt DATETIME NOT NULL DEFAULT GETDATE(),
    updatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    
    -- Unique constraint
    CONSTRAINT SlipGaji_userId_bulan_tahun_key UNIQUE (userId, bulan, tahun)
);
GO
PRINT '  ✓ Created SlipGaji table with new structure';

-- Migrate data dari Gaji ke SlipGaji
INSERT INTO SlipGaji (
    bulan, tahun, gajiBulanan, bonusLainnya, potonganLainnya,
    totalGajiKotor, totalPotongan, totalGajiBersih,
    tanggalBayar, userId, createdAt
)
SELECT 
    MONTH(tanggalGaji) as bulan,
    YEAR(tanggalGaji) as tahun,
    gajiPokok as gajiBulanan,
    bonus as bonusLainnya,
    potongan as potonganLainnya,
    (gajiPokok + bonus) as totalGajiKotor,
    potongan as totalPotongan,
    (gajiPokok + bonus - potongan) as totalGajiBersih,
    tanggalGaji as tanggalBayar,
    userId,
    GETDATE() as createdAt
FROM Gaji;
GO

DECLARE @MigratedCount INT;
SELECT @MigratedCount = COUNT(*) FROM SlipGaji;
PRINT '  ✓ Migrated ' + CAST(@MigratedCount AS NVARCHAR) + ' records to SlipGaji';

-- Drop table Gaji lama
DROP TABLE Gaji;
GO
PRINT '  ✓ Dropped old Gaji table';
PRINT '';

-- ========================================
-- SUMMARY
-- ========================================
PRINT '✅ Migration completed successfully!';
PRINT '';
PRINT '📊 Summary of changes:';
PRINT '  1. Role.gajiPokok → Role.gajiPokokBulanan';
PRINT '  2. Table Gaji → SlipGaji (dengan struktur lebih detail)';
PRINT '';
PRINT '📋 SlipGaji new fields:';
PRINT '  - bulan, tahun (periode)';
PRINT '  - gajiBulanan (dari absensi)';
PRINT '  - bonusKehadiran, bonusLainnya';
PRINT '  - potonganAlpha, potonganTelat, potonganLainnya';
PRINT '  - totalGajiKotor, totalPotongan, totalGajiBersih';
PRINT '';
PRINT '⚠️  NEXT STEP:';
PRINT '  Run: npx prisma db pull';
PRINT '  Run: npx prisma generate';
GO

