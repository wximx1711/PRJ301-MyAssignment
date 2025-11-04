# 🛠️ Hướng dẫn Setup cho NetBeans + Tomcat + SQL Server

## 📋 Yêu cầu

- **NetBeans IDE** (đã cài đặt)
- **Apache Tomcat** (đã cấu hình trong NetBeans)
- **SQL Server** (đang chạy)
- **SQL Server Management Studio** (SSMS) hoặc **NetBeans Database Services**

## 🔧 Bước 1: Chạy SQL Script trong NetBeans

### Cách 1: Sử dụng NetBeans Database Services

1. **Mở NetBeans**
2. **Services** → **Databases** → Right-click **Drivers** → **New Driver**
3. Chọn file: `libs/mssql-jdbc-13.2.0.jre11.jar`
4. Click **OK**
5. **Services** → **Databases** → Right-click **jdbc:sqlserver://localhost:1433** → **Connect**
   - User: `sa`
   - Password: `123`
6. Right-click database → **Execute Command**
7. Mở file `leave_management_setup_v2.sql`
8. Copy toàn bộ nội dung và paste vào SQL Command window
9. Click **Run SQL** (F5)

### Cách 2: Sử dụng SQL Server Management Studio (Khuyến nghị)

1. **Mở SQL Server Management Studio**
2. **Connect** với:
   - Server name: `localhost` hoặc `localhost\SQLEXPRESS` (nếu dùng Express)
   - Authentication: **SQL Server Authentication**
   - Login: `sa`
   - Password: `123`
3. Click **Connect**
4. **File** → **Open** → **File** → Chọn `leave_management_setup_v2.sql`
5. Click **Execute** (F5) hoặc **F5**

## ✅ Bước 2: Kiểm tra Database đã được tạo

Trong SQL Server Management Studio:
```sql
USE master;
GO
SELECT name FROM sys.databases WHERE name = 'FALL25_Assignment';
GO
```

Nếu có kết quả → Database đã được tạo ✅

Kiểm tra dữ liệu:
```sql
USE FALL25_Assignment;
GO
SELECT * FROM Users;
GO
```

## 🔧 Bước 3: Cấu hình Project trong NetBeans

### 3.1. Kiểm tra JDBC Driver

1. **Projects** → Right-click project → **Properties**
2. **Libraries** → **Compile** tab
3. Kiểm tra có `mssql-jdbc-13.2.0.jre11.jar` không
4. Nếu chưa có:
   - Click **Add JAR/Folder**
   - Chọn file: `libs/mssql-jdbc-13.2.0.jre11.jar`
   - Click **OK**

### 3.2. Kiểm tra Tomcat Server

1. **Services** → **Servers** → Right-click **Tomcat**
2. Kiểm tra **Server Status** = **Running**
3. Nếu không → Right-click → **Start**

### 3.3. Build và Deploy

1. **Projects** → Right-click project → **Clean and Build**
2. **Projects** → Right-click project → **Deploy**
3. Hoặc click **Run** (F6)

## 🚀 Bước 4: Test Application

1. **Run** project (F6)
2. Browser sẽ tự động mở: `http://localhost:8080/FALL2025_Assignment/`
3. Hoặc truy cập thủ công: `http://localhost:8080/FALL2025_Assignment/login`

## 🔍 Bước 5: Kiểm tra Logs

Nếu có lỗi, kiểm tra:
1. **Output** tab trong NetBeans (Console)
2. **Services** → **Servers** → **Tomcat** → **View Server Output**
3. Tìm các dòng bắt đầu với `DBContext:` để xem chi tiết

## 🐛 Troubleshooting

### Lỗi: "Cannot open database"

**Giải pháp:**
1. Chạy lại file `leave_management_setup_v2.sql` trong SQL Server Management Studio
2. Kiểm tra SQL Server đang chạy
3. Kiểm tra username/password đúng: `sa/123`

### Lỗi: "Login failed for user 'sa'"

**Giải pháp:**
1. SQL Server Management Studio → Right-click server → **Properties** → **Security**
2. Chọn **SQL Server and Windows Authentication mode**
3. Click **OK** → **Restart SQL Server**
4. Sau đó chạy lại script `leave_management_setup_v2.sql` (script sẽ tự enable sa)

### Lỗi: "ClassNotFoundException: SQLServerDriver"

**Giải pháp:**
1. Kiểm tra file `mssql-jdbc-13.2.0.jre11.jar` trong thư mục `libs/`
2. **Project Properties** → **Libraries** → Add JAR
3. **Clean and Build** project

### Lỗi: Port 1433 không kết nối được

**Giải pháp:**
1. Kiểm tra SQL Server đang chạy trên port 1433
2. Nếu dùng SQL Server Express, có thể port khác
3. Sửa trong `DBContext.java`:
   ```java
   private static final String SERVER = "localhost\\SQLEXPRESS";  // Nếu dùng Express
   private static final int PORT = 1433;  // Hoặc port khác
   ```

### Lỗi: Connection timeout

**Giải pháp:**
1. Kiểm tra Windows Firewall
2. Cho phép port 1433
3. Kiểm tra SQL Server Browser service đang chạy

## 📝 Connection String trong Code

Hiện tại trong `src/java/dal/DBContext.java`:
```java
private static final String SERVER = "localhost";  // Đổi nếu cần
private static final int PORT = 1433;              // Đổi nếu cần
private static final String USER = "sa";            // Đổi nếu cần
private static final String PASS = "123";          // Đổi nếu cần
```

**Nếu dùng SQL Server Express:**
```java
private static final String SERVER = "localhost\\SQLEXPRESS";
private static final int PORT = 1433;  // Hoặc port khác
```

## ✅ Sau khi setup xong

1. ✅ Database `FALL25_Assignment` đã được tạo
2. ✅ Tất cả tables đã được tạo
3. ✅ Dữ liệu mẫu đã được insert
4. ✅ Project đã được build và deploy
5. ✅ Có thể đăng nhập với:
   - Username: `admin`, `bob`, `mike`, `alice`, `carl`, `eva`
   - Password: `123`

## 🎯 Quick Test

1. Chạy SQL script → Kiểm tra trong SSMS
2. Build project trong NetBeans
3. Run project → Test đăng nhập
4. Xem logs nếu có lỗi

