-- ================================================================
-- QUICK FIX SCRIPT - Tạo Database và Cấp Quyền
-- Chạy script này TRƯỚC khi chạy leave_management_setup_v2.sql
-- ================================================================

USE master;
GO

PRINT '=== Bắt đầu fix database ===';
GO

-- 1. Tạo database nếu chưa có
IF DB_ID('FALL25_Assignment') IS NULL
BEGIN
    PRINT '1. Đang tạo database FALL25_Assignment...';
    CREATE DATABASE FALL25_Assignment;
    PRINT '   ✅ Database đã được tạo!';
END
ELSE
BEGIN
    PRINT '1. ✅ Database FALL25_Assignment đã tồn tại.';
END
GO

-- 2. Kiểm tra và enable sa login
USE master;
GO

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'sa')
BEGIN
    PRINT '2. Đang tạo login sa...';
    CREATE LOGIN sa WITH PASSWORD = '123';
    PRINT '   ✅ Login sa đã được tạo!';
END
ELSE
BEGIN
    PRINT '2. ✅ Login sa đã tồn tại.';
END
GO

-- Enable sa login
ALTER LOGIN sa ENABLE;
GO

-- Cấp quyền sysadmin cho sa
IF NOT EXISTS (
    SELECT 1 FROM sys.server_role_members 
    WHERE role_principal_id = (SELECT principal_id FROM sys.server_principals WHERE name = 'sysadmin')
    AND member_principal_id = (SELECT principal_id FROM sys.server_principals WHERE name = 'sa')
)
BEGIN
    ALTER SERVER ROLE sysadmin ADD MEMBER sa;
    PRINT '   ✅ Đã cấp quyền sysadmin cho sa.';
END
GO

-- 3. Cấp quyền trong database
USE FALL25_Assignment;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'sa')
BEGIN
    PRINT '3. Đang tạo user sa trong database...';
    CREATE USER [sa] FROM LOGIN [sa];
    PRINT '   ✅ User sa đã được tạo trong database!';
END
ELSE
BEGIN
    PRINT '3. ✅ User sa đã tồn tại trong database.';
END
GO

-- Cấp quyền db_owner
IF NOT EXISTS (
    SELECT 1 FROM sys.database_role_members 
    WHERE role_principal_id = (SELECT principal_id FROM sys.database_principals WHERE name = 'db_owner')
    AND member_principal_id = (SELECT principal_id FROM sys.database_principals WHERE name = 'sa')
)
BEGIN
    ALTER ROLE db_owner ADD MEMBER [sa];
    PRINT '   ✅ Đã cấp quyền db_owner cho sa.';
END
GO

-- 4. Kiểm tra kết quả
PRINT '';
PRINT '=== Kiểm tra kết quả ===';
SELECT 
    DB_NAME() as CurrentDatabase,
    USER_NAME() as CurrentUser;
GO

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'FALL25_Assignment')
    PRINT '✅ Database FALL25_Assignment: OK';
ELSE
    PRINT '❌ Database FALL25_Assignment: FAILED';

IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'sa' AND is_disabled = 0)
    PRINT '✅ Login sa: OK (enabled)';
ELSE
    PRINT '❌ Login sa: FAILED hoặc disabled';

IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'sa')
    PRINT '✅ User sa trong database: OK';
ELSE
    PRINT '❌ User sa trong database: FAILED';

PRINT '';
PRINT '=== Hoàn tất! ===';
PRINT 'Bây giờ bạn có thể chạy file leave_management_setup_v2.sql để tạo tables và data.';
GO

