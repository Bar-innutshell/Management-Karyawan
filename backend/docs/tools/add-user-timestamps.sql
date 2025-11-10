-- Migration: Add createdAt and updatedAt to User table
-- Run this if you get error "The column createdAt does not exist in the current database"

USE db_restoran;
GO

-- Check if createdAt column exists
IF NOT EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'User' AND COLUMN_NAME = 'createdAt'
)
BEGIN
    ALTER TABLE [User]
    ADD createdAt DATETIME2 NOT NULL DEFAULT GETDATE();
    
    PRINT '✅ Column createdAt added to User table';
END
ELSE
BEGIN
    PRINT '⚠️  Column createdAt already exists in User table';
END
GO

-- Check if updatedAt column exists
IF NOT EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'User' AND COLUMN_NAME = 'updatedAt'
)
BEGIN
    ALTER TABLE [User]
    ADD updatedAt DATETIME2 NOT NULL DEFAULT GETDATE();
    
    PRINT '✅ Column updatedAt added to User table';
END
ELSE
BEGIN
    PRINT '⚠️  Column updatedAt already exists in User table';
END
GO

PRINT '';
PRINT '═══════════════════════════════════════════════════════';
PRINT '✨ Migration Completed!';
PRINT '═══════════════════════════════════════════════════════';
PRINT 'Next steps:';
PRINT '1. npx prisma generate';
PRINT '2. node index.js';
PRINT '═══════════════════════════════════════════════════════';
GO
