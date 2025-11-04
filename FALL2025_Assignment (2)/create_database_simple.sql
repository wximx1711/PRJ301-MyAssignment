-- Script đơn giản để tạo database nếu chưa có
-- Chạy script này TRƯỚC khi chạy leave_management_setup_v2.sql

USE master;
GO

-- Kiểm tra và tạo database nếu chưa có
IF DB_ID('FALL25_Assignment') IS NULL
BEGIN
    PRINT 'Creating database FALL25_Assignment...';
    CREATE DATABASE FALL25_Assignment;
    PRINT 'Database FALL25_Assignment created successfully!';
END
ELSE
BEGIN
    PRINT 'Database FALL25_Assignment already exists.';
END
GO

-- Kiểm tra database đã được tạo
IF DB_ID('FALL25_Assignment') IS NOT NULL
BEGIN
    PRINT '✅ Database FALL25_Assignment is ready!';
    PRINT 'You can now run leave_management_setup_v2.sql to create tables and data.';
END
ELSE
BEGIN
    PRINT '❌ Failed to create database FALL25_Assignment.';
    PRINT 'Please check SQL Server permissions and try again.';
END
GO

