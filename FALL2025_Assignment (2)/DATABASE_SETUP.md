# Hướng dẫn Setup Database

## Lỗi thường gặp: "Cannot open database 'FALL25_Assignment'"

### Nguyên nhân:
Database `FALL25_Assignment` chưa được tạo hoặc không có quyền truy cập.

## Giải pháp:

### Bước 1: Kiểm tra SQL Server đang chạy

1. Mở **SQL Server Configuration Manager**
2. Kiểm tra **SQL Server (MSSQLSERVER)** đang **Running**
3. Nếu không, click chuột phải → **Start**

### Bước 2: Kiểm tra và tạo database

**Cách 1: Chạy script kiểm tra (khuyến nghị)**
```sql
-- Chạy file check_database.sql
-- Script này sẽ kiểm tra và tạo database nếu chưa có
```

**Cách 2: Chạy script tạo database đầy đủ**
```sql
-- Chạy file leave_management_setup_v2.sql
-- Script này sẽ:
-- 1. Xóa database cũ (nếu có)
-- 2. Tạo database mới
-- 3. Tạo tất cả các bảng
-- 4. Insert dữ liệu mẫu
```

### Bước 3: Kiểm tra kết nối

**Test kết nối trong SQL Server Management Studio:**
```sql
USE master;
GO

-- Kiểm tra SQL Server đang chạy
SELECT @@SERVERNAME as ServerName, 
       @@VERSION as Version;

-- Kiểm tra database có tồn tại không
SELECT name FROM sys.databases WHERE name = 'FALL25_Assignment';

-- Nếu database chưa tồn tại, tạo mới:
CREATE DATABASE FALL25_Assignment;
GO

USE FALL25_Assignment;
GO

-- Kiểm tra quyền truy cập
SELECT USER_NAME() as CurrentUser, DB_NAME() as CurrentDatabase;
```

### Bước 4: Kiểm tra thông tin đăng nhập

**Trong file `src/java/dal/DBContext.java`:**
- Server: `localhost`
- Port: `1433`
- Database: `FALL25_Assignment`
- Username: `sa`
- Password: `123`

**Nếu thông tin khác, sửa trong `DBContext.java`:**

```java
private static final String SERVER = "localhost";  // Thay đổi nếu cần
private static final int PORT = 1433;              // Thay đổi nếu cần
private static final String USER = "sa";            // Thay đổi nếu cần
private static final String PASS = "123";           // Thay đổi nếu cần
```

### Bước 5: Kiểm tra SQL Server Authentication

1. Mở **SQL Server Management Studio**
2. Connect với **Windows Authentication**
3. Right-click server → **Properties** → **Security**
4. Chọn **SQL Server and Windows Authentication mode**
5. Click **OK** và **Restart SQL Server**

### Bước 6: Tạo Login cho user 'sa'

```sql
USE master;
GO

-- Kiểm tra login 'sa' có tồn tại không
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'sa')
BEGIN
    CREATE LOGIN sa WITH PASSWORD = '123';
END
ELSE
BEGIN
    -- Đổi password nếu cần
    ALTER LOGIN sa WITH PASSWORD = '123';
END
GO

-- Enable sa login
ALTER LOGIN sa ENABLE;
GO

-- Cấp quyền server
ALTER SERVER ROLE sysadmin ADD MEMBER sa;
GO
```

### Bước 7: Cấp quyền cho database

```sql
USE FALL25_Assignment;
GO

-- Tạo user trong database
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'sa')
BEGIN
    CREATE USER [sa] FROM LOGIN [sa];
END
GO

-- Cấp quyền db_owner
ALTER ROLE db_owner ADD MEMBER [sa];
GO
```

## Kiểm tra sau khi setup

### Test 1: Kiểm tra database tồn tại
```sql
USE master;
SELECT name FROM sys.databases WHERE name = 'FALL25_Assignment';
```

### Test 2: Kiểm tra các bảng đã được tạo
```sql
USE FALL25_Assignment;
SELECT name FROM sys.tables ORDER BY name;
```

### Test 3: Kiểm tra dữ liệu users
```sql
USE FALL25_Assignment;
SELECT username, password_hash, full_name, is_active FROM Users;
```

### Test 4: Test kết nối từ Java
- Truy cập: `http://localhost:8080/FALL2025_Assignment/test`
- Xem kết quả test database connection

## Troubleshooting

### Lỗi: "Login failed for user 'sa'"
**Giải pháp:**
1. Kiểm tra SQL Server Authentication đã bật
2. Kiểm tra password đúng
3. Enable sa login: `ALTER LOGIN sa ENABLE;`

### Lỗi: "Cannot open database"
**Giải pháp:**
1. Chạy script `leave_management_setup_v2.sql`
2. Kiểm tra database name đúng: `FALL25_Assignment`
3. Kiểm tra user có quyền truy cập database

### Lỗi: "Connection refused"
**Giải pháp:**
1. Kiểm tra SQL Server đang chạy
2. Kiểm tra port 1433 mở
3. Kiểm tra firewall

### Lỗi: "SQL Server JDBC Driver not found"
**Giải pháp:**
1. Kiểm tra file `mssql-jdbc-*.jar` trong thư mục `libs/`
2. Kiểm tra file trong `WEB-INF/lib/`
3. Rebuild project

## Quick Fix Commands

```sql
-- 1. Tạo database nếu chưa có
USE master;
IF DB_ID('FALL25_Assignment') IS NULL
    CREATE DATABASE FALL25_Assignment;
GO

-- 2. Enable sa login
USE master;
ALTER LOGIN sa ENABLE;
ALTER LOGIN sa WITH PASSWORD = '123';
GO

-- 3. Cấp quyền
USE FALL25_Assignment;
CREATE USER [sa] FROM LOGIN [sa];
ALTER ROLE db_owner ADD MEMBER [sa];
GO

-- 4. Chạy script tạo bảng
-- Chạy file leave_management_setup_v2.sql
```

## Sau khi setup xong

1. Restart server (Tomcat/GlassFish)
2. Test đăng nhập với:
   - Username: `admin`
   - Password: `123`

