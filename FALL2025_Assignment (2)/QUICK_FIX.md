# 🔧 Quick Fix - Database Connection Error

## Lỗi: "Cannot open database 'FALL25_Assignment'"

### ⚡ Giải pháp nhanh (3 bước)

#### Bước 1: Tạo Database
Chạy script này trong SQL Server Management Studio:
```sql
USE master;
GO

IF DB_ID('FALL25_Assignment') IS NULL
BEGIN
    CREATE DATABASE FALL25_Assignment;
    PRINT 'Database created!';
END
ELSE
BEGIN
    PRINT 'Database already exists!';
END
GO
```

#### Bước 2: Chạy Script Setup
Chạy file `leave_management_setup_v2.sql` để tạo tất cả tables và data.

#### Bước 3: Kiểm tra quyền truy cập
```sql
USE FALL25_Assignment;
GO

-- Kiểm tra user sa có quyền không
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'sa')
BEGIN
    CREATE USER [sa] FROM LOGIN [sa];
    ALTER ROLE db_owner ADD MEMBER [sa];
    PRINT 'Granted permissions to sa';
END
GO
```

## ✅ Test kết nối

Sau khi làm xong 3 bước trên, test:
1. Restart server (Tomcat/GlassFish)
2. Truy cập: `http://localhost:8080/FALL2025_Assignment/test`
3. Xem kết quả test database connection

## 🔑 Đăng nhập

Sau khi fix xong:
- Username: `admin`, `bob`, `mike`, `alice`, `carl`, `eva`
- Password: `123`

