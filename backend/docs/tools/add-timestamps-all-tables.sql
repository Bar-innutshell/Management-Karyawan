-- =====================================================
-- Add createdAt and updatedAt to ALL tables
-- Safe to run multiple times (checks existence first)
-- =====================================================

USE db_restoran;
GO

PRINT '================================================';
PRINT 'Adding Timestamps to All Tables';
PRINT '================================================';
PRINT '';

-- =====================================================
-- 1. ABSENSI TABLE
-- =====================================================
PRINT '1. Checking Absensi table...';

-- Check and add createdAt to Absensi
IF NOT EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'Absensi' 
    AND COLUMN_NAME = 'createdAt'
)
BEGIN
    PRINT '   Adding createdAt column...';
    ALTER TABLE Absensi
    ADD createdAt DATETIME2 NOT NULL DEFAULT GETDATE();
    
    PRINT '   ✓ createdAt column added';
END
ELSE
BEGIN
    PRINT '   ⚠️  Column createdAt already exists in Absensi table';
END

-- Check and add updatedAt to Absensi
IF NOT EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'Absensi' 
    AND COLUMN_NAME = 'updatedAt'
)
BEGIN
    PRINT '   Adding updatedAt column...';
    ALTER TABLE Absensi
    ADD updatedAt DATETIME2 NOT NULL DEFAULT GETDATE();
    
    PRINT '   ✓ updatedAt column added';
END
ELSE
BEGIN
    PRINT '   ⚠️  Column updatedAt already exists in Absensi table';
END

PRINT '';

-- =====================================================
-- 2. JADWAL TABLE
-- =====================================================
PRINT '2. Checking Jadwal table...';

-- Check and add createdAt to Jadwal
IF NOT EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'Jadwal' 
    AND COLUMN_NAME = 'createdAt'
)
BEGIN
    PRINT '   Adding createdAt column...';
    ALTER TABLE Jadwal
    ADD createdAt DATETIME2 NOT NULL DEFAULT GETDATE();
    
    PRINT '   ✓ createdAt column added';
END
ELSE
BEGIN
    PRINT '   ⚠️  Column createdAt already exists in Jadwal table';
END

-- Check and add updatedAt to Jadwal
IF NOT EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'Jadwal' 
    AND COLUMN_NAME = 'updatedAt'
)
BEGIN
    PRINT '   Adding updatedAt column...';
    ALTER TABLE Jadwal
    ADD updatedAt DATETIME2 NOT NULL DEFAULT GETDATE();
    
    PRINT '   ✓ updatedAt column added';
END
ELSE
BEGIN
    PRINT '   ⚠️  Column updatedAt already exists in Jadwal table';
END

PRINT '';

-- =====================================================
-- 3. LAPORANPEMASUKAN TABLE
-- =====================================================
PRINT '3. Checking LaporanPemasukan table...';

-- Check and add createdAt to LaporanPemasukan
IF NOT EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'LaporanPemasukan' 
    AND COLUMN_NAME = 'createdAt'
)
BEGIN
    PRINT '   Adding createdAt column...';
    ALTER TABLE LaporanPemasukan
    ADD createdAt DATETIME2 NOT NULL DEFAULT GETDATE();
    
    PRINT '   ✓ createdAt column added';
END
ELSE
BEGIN
    PRINT '   ⚠️  Column createdAt already exists in LaporanPemasukan table';
END

-- Check and add updatedAt to LaporanPemasukan
IF NOT EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'LaporanPemasukan' 
    AND COLUMN_NAME = 'updatedAt'
)
BEGIN
    PRINT '   Adding updatedAt column...';
    ALTER TABLE LaporanPemasukan
    ADD updatedAt DATETIME2 NOT NULL DEFAULT GETDATE();
    
    PRINT '   ✓ updatedAt column added';
END
ELSE
BEGIN
    PRINT '   ⚠️  Column updatedAt already exists in LaporanPemasukan table';
END

PRINT '';

-- =====================================================
-- SUMMARY
-- =====================================================
PRINT '================================================';
PRINT 'Migration Complete!';
PRINT '================================================';
PRINT '';
PRINT 'Next steps:';
PRINT '1. Run: npx prisma generate';
PRINT '2. Restart your backend server';
PRINT '3. Test with: npx prisma studio';
PRINT '';
PRINT '✅ All timestamps columns added successfully!';
PRINT '';

GO
