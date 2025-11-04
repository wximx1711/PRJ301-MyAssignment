-- Script kiểm tra và tạo database nếu chưa tồn tại
-- Chạy script này trước khi chạy leave_management_setup_v2.sql

USE master;
GO

-- Kiểm tra xem database có tồn tại không
IF DB_ID('FALL25_Assignment') IS NULL
BEGIN
    PRINT 'Database FALL25_Assignment không tồn tại. Đang tạo database...';
    CREATE DATABASE FALL25_Assignment;
    PRINT 'Database FALL25_Assignment đã được tạo thành công!';
END
ELSE
BEGIN
    PRINT 'Database FALL25_Assignment đã tồn tại.';
END
GO

-- Kiểm tra quyền truy cập
USE FALL25_Assignment;
GO

-- Kiểm tra xem user 'sa' có quyền truy cập không
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'sa')
BEGIN
    PRINT 'User sa có quyền truy cập database.';
END
ELSE
BEGIN
    PRINT 'User sa chưa có quyền truy cập. Đang cấp quyền...';
    CREATE USER [sa] FROM LOGIN [sa];
    ALTER ROLE db_owner ADD MEMBER [sa];
    PRINT 'Đã cấp quyền db_owner cho user sa.';
END
GO

-- Kiểm tra các bảng chính
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Users')
    PRINT 'Table Users đã tồn tại.';
ELSE
    PRINT 'Table Users chưa tồn tại. Vui lòng chạy leave_management_setup_v2.sql.';
GO

IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Departments')
    PRINT 'Table Departments đã tồn tại.';
ELSE
    PRINT 'Table Departments chưa tồn tại. Vui lòng chạy leave_management_setup_v2.sql.';
GO

IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Roles')
    PRINT 'Table Roles đã tồn tại.';
ELSE
    PRINT 'Table Roles chưa tồn tại. Vui lòng chạy leave_management_setup_v2.sql.';
GO

PRINT '=== Kiểm tra hoàn tất ===';
GO

