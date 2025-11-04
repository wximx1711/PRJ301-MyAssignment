# Hướng dẫn xử lý lỗi đăng nhập

## Vấn đề: Không đăng nhập được

### 1. Kiểm tra Database Connection

**Kiểm tra trong console/console logs:**
- Tìm các dòng log bắt đầu với `DBContext:`
- Kiểm tra xem có thông báo "Database connection successful!" không
- Nếu có lỗi, kiểm tra:
  - SQL Server có đang chạy không?
  - Port 1433 có mở không?
  - Database `FALL25_Assignment` đã được tạo chưa?

### 2. Kiểm tra Database đã được tạo chưa

Chạy SQL script:
```sql
USE master;
GO
SELECT name FROM sys.databases WHERE name = 'FALL25_Assignment';
GO
```

Nếu không có kết quả, chạy lại file `leave_management_setup_v2.sql`

### 3. Kiểm tra Users trong Database

Chạy SQL query:
```sql
USE FALL25_Assignment;
GO
SELECT username, password_hash, is_active, full_name FROM Users;
GO
```

Kết quả mong đợi:
- username: `admin`, `bob`, `mike`, `alice`, `carl`, `eva`
- password_hash: `123` (tất cả)
- is_active: `1` (true)
- full_name: tên tương ứng

### 4. Kiểm tra Console Logs

Khi đăng nhập, kiểm tra console logs:
```
DBContext: Attempting to connect to database...
DBContext: URL=jdbc:sqlserver://localhost:1433;databaseName=FALL25_Assignment...
DBContext: Database connection successful!
DBContext: Connected to database: FALL25_Assignment
LoginController: Attempting login for username='admin'
UserDBContext.get(): Attempting login with username='admin', password='123'
UserDBContext.get(): Executing query...
```

**Nếu login thành công:**
```
UserDBContext.get(): User found! ID=X
LoginController: Login successful for user: Admin User (ID: X)
```

**Nếu login thất bại:**
```
UserDBContext.get(): No user found with username='admin' and password='123'
UserDBContext.get(): DEBUG - User exists: username='admin', password_hash='123', is_active=true
```

### 5. Các nguyên nhân thường gặp

#### A. Database chưa được tạo
**Giải pháp:** Chạy lại file `leave_management_setup_v2.sql`

#### B. Database name không khớp
**Kiểm tra:** 
- File SQL: `FALL25_Assignment`
- File DBContext.java: `FALL25_Assignment`
- Phải giống nhau!

#### C. SQL Server không chạy
**Giải pháp:** 
- Khởi động SQL Server
- Kiểm tra SQL Server Configuration Manager
- Đảm bảo SQL Server service đang chạy

#### D. Connection string không đúng
**Kiểm tra:** `src/java/dal/DBContext.java`
```java
String url = "jdbc:sqlserver://localhost:1433;databaseName=FALL25_Assignment;encrypt=false;trustServerCertificate=true";
```

#### E. Username/Password không đúng
**Kiểm tra:** 
- Username: `admin`, `bob`, `mike`, `alice`, `carl`, `eva`
- Password: `123` (tất cả)

### 6. Test Page

Truy cập: `http://localhost:8080/FALL2025_Assignment/test`

Trang này sẽ:
- Test database connection
- Hiển thị danh sách users
- Test login với các tài khoản

### 7. Debug Steps

1. **Kiểm tra console logs** khi đăng nhập
2. **Truy cập `/test`** để xem chi tiết
3. **Kiểm tra database** bằng SQL query
4. **Kiểm tra connection string** trong DBContext.java
5. **Kiểm tra SQL script** đã chạy chưa

### 8. Quick Fix

Nếu vẫn không được, thử:

1. **Restart server**
2. **Chạy lại SQL script**
3. **Kiểm tra lại connection string**
4. **Xem console logs** khi đăng nhập

### 9. Test với SQL Query trực tiếp

```sql
USE FALL25_Assignment;
GO

-- Test query giống như trong code
SELECT TOP 1 u.id, u.username, u.full_name, u.role_id, u.department_id,
       r.code as role_code, r.name as role_name,
       d.name as department_name
FROM Users u 
JOIN Roles r ON r.id = u.role_id
JOIN Departments d ON d.id = u.department_id
WHERE u.username = 'admin' AND u.password_hash = '123' AND u.is_active = 1;
GO
```

Nếu query này trả về kết quả, database OK. Nếu không, có vấn đề với data.

### 10. Common Issues và Solutions

| Issue | Solution |
|-------|----------|
| "DB connect error" | Kiểm tra SQL Server đang chạy, port 1433 |
| "No user found" | Kiểm tra password_hash trong database = '123' |
| "SQLException" | Kiểm tra database name, table names |
| "ClassNotFoundException" | Kiểm tra SQL Server JDBC driver trong libs |

