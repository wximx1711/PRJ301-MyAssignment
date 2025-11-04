# ⚡ NetBeans Quick Start Guide

## 🎯 Setup nhanh trong 5 phút

### Bước 1: Chạy SQL Script (2 phút)

1. **Mở SQL Server Management Studio**
2. **Connect** với:
   - Server: `localhost` hoặc `localhost\SQLEXPRESS`
   - Login: `sa`
   - Password: `123`
3. **File** → **Open** → Chọn file `leave_management_setup_v2.sql`
4. Click **Execute** (F5)
5. Đợi script chạy xong (sẽ thấy message "✅✅✅ Database FALL25_Assignment đã được tạo...")

### Bước 2: Build Project (1 phút)

1. **NetBeans** → **Projects** → Right-click project **FALL2025_Assignment**
2. **Clean and Build** (hoặc **Shift+F11**)
3. Đợi build xong

### Bước 3: Run Project (1 phút)

1. **Run** → **Run Project** (hoặc **F6**)
2. Browser sẽ tự động mở: `http://localhost:8080/FALL2025_Assignment/`
3. Tự động redirect đến trang login

### Bước 4: Test Đăng nhập (1 phút)

1. Nhập:
   - Username: `admin`
   - Password: `123`
2. Click **Đăng nhập ngay**
3. Nếu thành công → Chuyển đến trang home

## ✅ Checklist

- [ ] SQL Server đang chạy
- [ ] Đã chạy file `leave_management_setup_v2.sql`
- [ ] Database `FALL25_Assignment` đã được tạo
- [ ] Project đã được build thành công
- [ ] Tomcat server đang chạy
- [ ] Đăng nhập thành công

## 🐛 Nếu có lỗi

### Lỗi: "Cannot open database"
→ Chạy lại file `leave_management_setup_v2.sql`

### Lỗi: "Login failed"
→ Kiểm tra SQL Server Authentication đã bật chưa

### Lỗi: "ClassNotFoundException"
→ Kiểm tra JDBC driver trong Project Properties → Libraries

### Lỗi: Port 1433
→ Nếu dùng SQL Express, có thể cần thay đổi connection string

## 📞 Test Connection

Truy cập: `http://localhost:8080/FALL2025_Assignment/test`

Trang này sẽ hiển thị:
- Database connection status
- Danh sách users
- Test login với các tài khoản

