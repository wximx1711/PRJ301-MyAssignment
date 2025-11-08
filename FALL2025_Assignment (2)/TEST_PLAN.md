# 🧪 TEST PLAN - Leave Management System

## 📋 Test Accounts
- **Admin**: `admin` / `123`
- **Manager**: `bob` / `123` hoặc `mike` / `123`
- **Leader**: `carl` / `123`
- **Employee**: `alice` / `123` hoặc `eva` / `123`

---

## ✅ TEST CASE 1: LOGIN & AUTHENTICATION

### 1.1 Test Login với các tài khoản
- [ ] **Admin login**: `admin` / `123`
  - Expected: Đăng nhập thành công, redirect đến `/home`
  - Check: Session có user object với role = ADMIN
  - Check: Home page hiển thị đúng thông tin admin

- [ ] **Manager login**: `bob` / `123`
  - Expected: Đăng nhập thành công
  - Check: Home page hiển thị stats cho manager

- [ ] **Leader login**: `carl` / `123`
  - Expected: Đăng nhập thành công
  - Check: Home page hiển thị stats cho leader

- [ ] **Employee login**: `alice` / `123`
  - Expected: Đăng nhập thành công
  - Check: Home page hiển thị stats cho employee

### 1.2 Test Login với sai thông tin
- [ ] Sai username
- [ ] Sai password
- [ ] Empty username/password
- Expected: Hiển thị error message, không redirect

### 1.3 Test Logout
- [ ] Click "Đăng xuất" từ user menu
- Expected: Session bị clear, redirect về `/login`

---

## ✅ TEST CASE 2: HOME PAGE & NAVIGATION

### 2.1 Test Home Page cho từng role
- [ ] **Admin**: 
  - Check: Hero section hiển thị tên admin
  - Check: Stats cards hiển thị: Pending Requests, Total Users, Employees on Leave
  - Check: Bottom navigation có đầy đủ links (bao gồm "Báo cáo", "Tạo user")
  - Check: Quick actions có "Duyệt đơn"

- [ ] **Manager/Leader**:
  - Check: Stats cards hiển thị: Pending Requests, Total Subordinates, Employees on Leave
  - Check: Bottom navigation KHÔNG có "Báo cáo", "Tạo user"
  - Check: Quick actions có "Duyệt đơn" (nhưng chỉ xem, không duyệt được)

- [ ] **Employee**:
  - Check: Stats cards hiển thị: My Pending Requests, My Approved Requests
  - Check: Bottom navigation chỉ có basic links
  - Check: Quick actions KHÔNG có "Duyệt đơn"

### 2.2 Test Bottom Navigation
- [ ] Click từng nav item
- Expected: Navigate đúng đến trang tương ứng
- Check: Active state được highlight đúng

### 2.3 Test User Menu Dropdown
- [ ] Hover vào user name
- Expected: Dropdown menu hiển thị
- Check: Có các options: Thông báo, Hồ sơ, Cài đặt, Đăng xuất
- Check: Admin có thêm "Service"

---

## ✅ TEST CASE 3: CREATE LEAVE REQUEST

### 3.1 Test tạo đơn nghỉ phép (tất cả roles)
- [ ] Navigate đến `/request/create`
- [ ] Fill form:
  - From date: Chọn ngày bắt đầu
  - To date: Chọn ngày kết thúc
  - Reason: Nhập lý do
- [ ] Submit form
- Expected: 
  - Tạo đơn thành công
  - Redirect đến `/request/list`
  - Đơn mới có status = INPROGRESS (1)
  - Hiển thị trong "Đơn của tôi"

### 3.2 Test validation
- [ ] Empty from date → Expected: Error message
- [ ] Empty to date → Expected: Error message
- [ ] Empty reason → Expected: Error message
- [ ] From date > To date → Expected: Error message
- [ ] From date = To date → Expected: OK (nghỉ 1 ngày)

---

## ✅ TEST CASE 4: LIST LEAVE REQUESTS

### 4.1 Test "Đơn của tôi" tab (tất cả roles)
- [ ] Navigate đến `/request/list`
- [ ] Check tab "Đơn của tôi":
  - Hiển thị đơn của user hiện tại
  - Có pagination nếu > 10 đơn
  - Có filters: From, To, Status, Type

### 4.2 Test "Đơn cần duyệt" tab (Manager/Leader/Admin)
- [ ] Login với Manager/Leader/Admin
- [ ] Check tab "Đơn cần duyệt":
  - Chỉ hiển thị đơn của cấp dưới trực tiếp
  - Manager chỉ thấy đơn của nhân viên có `manager_id` = manager's id
  - Admin thấy tất cả đơn

### 4.3 Test Filters
- [ ] Filter by date range
- [ ] Filter by status (INPROGRESS, APPROVED, REJECTED)
- [ ] Filter by leave type
- [ ] Combine multiple filters
- Expected: Kết quả được filter đúng

### 4.4 Test Pagination
- [ ] Navigate giữa các pages
- Expected: Data được load đúng theo page

---

## ✅ TEST CASE 5: REVIEW & APPROVE/REJECT (ADMIN ONLY)

### 5.1 Test xem chi tiết đơn (ADMIN)
- [ ] Login với `admin` / `123`
- [ ] Navigate đến `/request/review?id=XXX`
- Expected: 
  - Hiển thị đầy đủ thông tin đơn
  - Có buttons "Duyệt" và "Từ chối"
  - Có form để nhập note

### 5.2 Test approve đơn (ADMIN)
- [ ] Click "Duyệt"
- [ ] Nhập note (optional)
- [ ] Submit
- Expected:
  - Status chuyển thành APPROVED (2)
  - `processed_by` = admin's id
  - `processed_at` = current time
  - Ghi Audit Log
  - Tạo notification cho employee
  - Redirect về `/request/list`

### 5.3 Test reject đơn (ADMIN)
- [ ] Click "Từ chối"
- [ ] Nhập note (optional)
- [ ] Submit
- Expected:
  - Status chuyển thành REJECTED (3)
  - Các fields khác giống approve
  - Redirect về `/request/list`

### 5.4 Test unauthorized access
- [ ] Login với Manager/Leader/Employee
- [ ] Truy cập `/request/review?id=XXX` trực tiếp
- Expected: HTTP 403 Forbidden

---

## ✅ TEST CASE 6: USER MANAGEMENT (ADMIN ONLY)

### 6.1 Test tạo user mới
- [ ] Login với `admin` / `123`
- [ ] Navigate đến `/admin/users/create`
- [ ] Fill form:
  - Username: unique username
  - Password: password
  - Full Name: tên đầy đủ
  - Role: chọn role
  - Department: chọn department
  - Manager: chọn manager (optional)
  - Active: checkbox
- [ ] Submit
- Expected:
  - User được tạo thành công
  - Có thể login với user mới

### 6.2 Test list users
- [ ] Navigate đến `/admin/users/list`
- Expected: Hiển thị danh sách tất cả users
- Check: Có search, sort, pagination

### 6.3 Test activate/deactivate user
- [ ] Click "Deactivate" trên một user
- Expected: User bị deactivate, không thể login
- [ ] Click "Activate"
- Expected: User được activate lại

### 6.4 Test reset password
- [ ] Click "Reset Password"
- Expected: Password được reset về "123"

### 6.5 Test unauthorized access
- [ ] Login với Manager/Leader/Employee
- [ ] Truy cập `/admin/users/*` trực tiếp
- Expected: HTTP 403 Forbidden

---

## ✅ TEST CASE 7: NOTIFICATIONS

### 7.1 Test notification count
- [ ] Check notification badge trong user menu
- Expected: Hiển thị số unread notifications

### 7.2 Test notification khi đơn được tạo
- [ ] Employee tạo đơn
- Expected: Manager nhận notification (nếu có manager)

### 7.3 Test notification khi đơn được duyệt/từ chối
- [ ] Admin duyệt/từ chối đơn
- Expected: Employee nhận notification

---

## ✅ TEST CASE 8: LEAVE BALANCE

### 8.1 Test xem số dư phép
- [ ] Navigate đến `/balance`
- Expected: Hiển thị số dư phép theo năm và loại phép

---

## ✅ TEST CASE 9: REPORTS (ADMIN ONLY)

### 9.1 Test reports overview
- [ ] Login với `admin` / `123`
- [ ] Navigate đến `/reports/overview`
- Expected: Hiển thị charts và statistics

### 9.2 Test export CSV
- [ ] Navigate đến `/request/export`
- Expected: Download CSV file với danh sách đơn

---

## ✅ TEST CASE 10: AGENDA/CALENDAR

### 10.1 Test xem lịch phép
- [ ] Login với Manager/Leader/Admin
- [ ] Navigate đến `/division/agenda`
- Expected: Hiển thị calendar với các đơn nghỉ phép

---

## ✅ TEST CASE 11: ROLE-BASED ACCESS CONTROL

### 11.1 Test EMPLOYEE permissions
- [ ] Login với `alice` / `123`
- [ ] Check: CÓ thể:
  - Tạo đơn nghỉ phép
  - Xem đơn của mình
  - Xem số dư phép
- [ ] Check: KHÔNG thể:
  - Duyệt/từ chối đơn (kể cả đơn của mình)
  - Xem đơn của người khác
  - Truy cập `/admin/*`
  - Truy cập `/request/review`
  - Truy cập `/reports`

### 11.2 Test MANAGER/LEADER permissions
- [ ] Login với `bob` / `123` (Manager)
- [ ] Check: CÓ thể:
  - Tất cả quyền của EMPLOYEE
  - Xem đơn của cấp dưới (tab "Đơn cần duyệt")
  - Xem lịch phép phòng ban
- [ ] Check: KHÔNG thể:
  - Duyệt/từ chối đơn (dù có thể xem)
  - Truy cập `/admin/*`
  - Truy cập `/request/review` (403)
  - Truy cập `/reports`

### 11.3 Test ADMIN permissions
- [ ] Login với `admin` / `123`
- [ ] Check: CÓ thể:
  - Tất cả quyền của EMPLOYEE, MANAGER, LEADER
  - Duyệt/từ chối BẤT KỲ đơn nào
  - Tạo và quản lý users
  - Truy cập reports
  - Truy cập tất cả endpoints

---

## ✅ TEST CASE 12: UI/UX & RESPONSIVE

### 12.1 Test giao diện
- [ ] Check: Font Inter hiển thị đúng tiếng Việt
- [ ] Check: Gradient colors đúng
- [ ] Check: Animations mượt mà
- [ ] Check: Hover effects hoạt động

### 12.2 Test responsive
- [ ] Test trên mobile (< 768px)
- [ ] Test trên tablet (768px - 992px)
- [ ] Test trên desktop (> 992px)
- Expected: Layout responsive, không bị vỡ

---

## 🐛 BUGS FOUND

### Bug #1: [Mô tả bug]
- **Severity**: High/Medium/Low
- **Steps to reproduce**: 
- **Expected**: 
- **Actual**: 
- **Status**: Open/Fixed

---

## 📝 NOTES

- Test trên NetBeans + Tomcat 10+ + SQL Server
- Đảm bảo database đã được setup với `leave_management_setup_v2.sql`
- Check console logs để debug

