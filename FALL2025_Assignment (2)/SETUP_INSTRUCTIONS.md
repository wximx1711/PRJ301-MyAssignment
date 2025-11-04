# 📋 Hướng dẫn Setup Database - Step by Step

## 🚨 Nếu gặp lỗi "Cannot open database 'FALL25_Assignment'"

### Cách 1: Fix nhanh (Khuyến nghị)

1. **Mở SQL Server Management Studio**
2. **Connect** với SQL Server (Windows Authentication hoặc sa/123)
3. **Chạy file `fix_database.sql`** - Script này sẽ:
   - Tạo database nếu chưa có
   - Enable và cấp quyền cho user `sa`
   - Cấp quyền trong database
4. **Chạy file `leave_management_setup_v2.sql`** - Script này sẽ:
   - Tạo tất cả tables
   - Tạo views và triggers
   - Insert dữ liệu mẫu

### Cách 2: Fix thủ công

#### Bước 1: Tạo Database
```sql
USE master;
GO
CREATE DATABASE FALL25_Assignment;
GO
```

#### Bước 2: Enable SQL Server Authentication
1. SQL Server Management Studio → Right-click server → **Properties**
2. Tab **Security** → Chọn **SQL Server and Windows Authentication mode**
3. Click **OK** → **Restart SQL Server**

#### Bước 3: Enable và Set Password cho sa
```sql
USE master;
GO
ALTER LOGIN sa ENABLE;
ALTER LOGIN sa WITH PASSWORD = '123';
ALTER SERVER ROLE sysadmin ADD MEMBER sa;
GO
```

#### Bước 4: Cấp quyền trong Database
```sql
USE FALL25_Assignment;
GO
CREATE USER [sa] FROM LOGIN [sa];
ALTER ROLE db_owner ADD MEMBER [sa];
GO
```

#### Bước 5: Chạy Script Setup
Chạy file `leave_management_setup_v2.sql`

## ✅ Kiểm tra sau khi setup

### Test 1: Kiểm tra Database
```sql
USE master;
SELECT name FROM sys.databases WHERE name = 'FALL25_Assignment';
-- Kết quả: FALL25_Assignment
```

### Test 2: Kiểm tra Tables
```sql
USE FALL25_Assignment;
SELECT name FROM sys.tables ORDER BY name;
-- Kết quả: Các bảng như Users, Departments, Roles, Requests, etc.
```

### Test 3: Kiểm tra Users
```sql
USE FALL25_Assignment;
SELECT username, password_hash, full_name, is_active FROM Users;
-- Kết quả: 6 users (admin, bob, mike, alice, carl, eva)
```

### Test 4: Test Connection từ Java
- Truy cập: `http://localhost:8080/FALL2025_Assignment/test`
- Xem kết quả test

## 🔧 Nếu vẫn lỗi

### Kiểm tra SQL Server đang chạy
1. Mở **SQL Server Configuration Manager**
2. Services → SQL Server (MSSQLSERVER)
3. Status phải là **Running**
4. Nếu không → Right-click → **Start**

### Kiểm tra Port
- Default port: **1433**
- Kiểm tra trong SQL Server Configuration Manager → Network Configuration

### Kiểm tra Firewall
- Cho phép port 1433 trong Windows Firewall

### Kiểm tra Connection String
Trong file `src/java/dal/DBContext.java`:
```java
private static final String SERVER = "localhost";  // Đổi nếu cần
private static final int PORT = 1433;              // Đổi nếu cần
private static final String USER = "sa";          // Đổi nếu cần
private static final String PASS = "123";         // Đổi nếu cần
```

## 📞 Test đăng nhập sau khi fix

1. Restart server
2. Truy cập: `http://localhost:8080/FALL2025_Assignment/`
3. Đăng nhập với:
   - Username: `admin`
   - Password: `123`

