# 📋 TÀI LIỆU CHI TIẾT: QUYỀN HẠN VÀ CÁCH THỨC HOẠT ĐỘNG

## 🎭 1. CÁC CHỨC VỤ (ROLES) VÀ QUYỀN HẠN

Hệ thống có **4 chức vụ** chính với quyền hạn khác nhau:

---

### 👤 **NHÂN VIÊN (EMPLOYEE)**

#### ✅ **Quyền được phép:**
1. **Tạo đơn nghỉ phép:**
   - Truy cập `/request/create` để tạo đơn mới
   - Nhập thông tin: từ ngày, đến ngày, lý do nghỉ
   - Upload file đính kèm (nếu cần)
   - Đơn mới sẽ có trạng thái `INPROGRESS` (Chờ duyệt)

2. **Xem đơn của mình:**
   - Tab "Đơn của tôi" tại `/request/list`
   - Xem tất cả đơn đã tạo (đã duyệt, từ chối, chờ duyệt)
   - Có bộ lọc: ngày, trạng thái, loại phép
   - Phân trang server-side

3. **Hủy đơn của mình:**
   - ⚠️ **CHỈ ADMIN mới có thể hủy đơn** (theo yêu cầu hiện tại)
   - EMPLOYEE **KHÔNG THỂ** tự hủy đơn của mình

4. **Xem thông tin cá nhân:**
   - Xem số dư phép tại `/balance`
   - Xem lịch sử nghỉ phép
   - Xem thông báo tại `/notification`

5. **Xem Dashboard:**
   - Xem thống kê cá nhân (số đơn đã tạo, đã duyệt, chờ duyệt)
   - Xem thông báo mới

#### ❌ **Quyền KHÔNG được phép:**
- ❌ Duyệt/từ chối đơn nghỉ phép (kể cả đơn của mình)
- ❌ Xem đơn của người khác
- ❌ Tạo người dùng mới
- ❌ Truy cập trang quản trị (`/admin/*`)
- ❌ Xem báo cáo tổng hợp
- ❌ Xem lịch nghỉ của phòng ban (Agenda)

---

### 👔 **QUẢN LÝ (MANAGER) / TRƯỞNG NHÓM (LEADER)**

#### ✅ **Quyền được phép:**
1. **Tất cả quyền của EMPLOYEE:**
   - Tạo đơn nghỉ phép
   - Xem đơn của mình
   - Xem số dư phép, thông báo

2. **Xem đơn của cấp dưới:**
   - Tab "Đơn cần duyệt" tại `/request/list`
   - Chỉ xem đơn của nhân viên **trực tiếp dưới quyền** (có `manager_id` trỏ đến mình)
   - Công thức: `WHERE r.created_by IN (SELECT id FROM Users WHERE manager_id = ?)`
   - Có bộ lọc và phân trang

3. **Xem lịch nghỉ của phòng ban:**
   - Truy cập `/division/agenda`
   - Xem lịch nghỉ của tất cả nhân viên trong phòng ban
   - Filter theo phòng ban và khoảng thời gian

4. **Xem Dashboard nâng cao:**
   - Xem số đơn chờ duyệt của cấp dưới
   - Xem số nhân viên trực thuộc
   - Xem thống kê phòng ban

#### ❌ **Quyền KHÔNG được phép:**
- ❌ **Duyệt/từ chối đơn nghỉ phép** (theo yêu cầu, chỉ ADMIN mới được)
- ❌ Tạo người dùng mới
- ❌ Truy cập trang quản trị (`/admin/*`)
- ❌ Xem báo cáo tổng hợp toàn công ty

**⚠️ LƯU Ý QUAN TRỌNG:**
- Mặc dù MANAGER/LEADER có thể **XEM** đơn của cấp dưới, nhưng **KHÔNG THỂ duyệt/từ chối**
- Các nút "Duyệt" và "Từ chối" sẽ **KHÔNG HIỂN THỊ** cho MANAGER/LEADER
- Chỉ có nút "Xem" để xem chi tiết đơn

---

### 👑 **QUẢN TRỊ VIÊN (ADMIN)**

#### ✅ **Quyền được phép (TOÀN QUYỀN):**

1. **Tất cả quyền của EMPLOYEE, MANAGER, LEADER:**
   - Tạo đơn nghỉ phép
   - Xem đơn của mình
   - Xem đơn của cấp dưới
   - Xem lịch nghỉ phòng ban

2. **Duyệt/Từ chối đơn nghỉ phép:**
   - ⭐ **CHỈ ADMIN mới có quyền này**
   - Duyệt/từ chối **BẤT KỲ** đơn nào (của mình hoặc của người khác)
   - Tại `/request/list`: Nút "Duyệt" và "Từ chối" chỉ hiển thị cho ADMIN
   - Tại `/request/review?id=XXX`: Trang chi tiết với form duyệt/từ chối
   - Khi duyệt/từ chối:
     - Cập nhật `status` trong bảng `Requests`
     - Ghi `processed_by` = ID của ADMIN
     - Ghi `processed_at` = thời gian hiện tại
     - Ghi `manager_note` = ghi chú (nếu có)
     - Ghi vào `AuditLogs` để theo dõi

3. **Hủy đơn nghỉ phép:**
   - Có thể hủy đơn của mình hoặc của người khác
   - Chỉ áp dụng cho đơn có trạng thái `INPROGRESS`

4. **Quản lý người dùng:**
   - **Tạo người dùng mới** tại `/admin/users/create`:
     - Nhập: username, password, full name
     - Chọn: role (EMPLOYEE/MANAGER/LEADER/ADMIN), department
     - Chọn: manager (optional)
     - Set: active/inactive
   - **Danh sách người dùng** tại `/admin/users/list`:
     - Xem tất cả người dùng
     - Tìm kiếm, sắp xếp
     - Kích hoạt/vô hiệu hóa tài khoản
     - Đặt lại mật khẩu

5. **Truy cập báo cáo & thống kê:**
   - `/reports/overview`: Báo cáo tổng hợp với biểu đồ
   - `/reports`: Xuất CSV danh sách đơn
   - Xem thống kê theo phòng ban, loại phép

6. **Truy cập Audit Log:**
   - Xem nhật ký các hành động quan trọng:
     - Tạo đơn (`CREATE`)
     - Duyệt/từ chối đơn (`APPROVE_REJECT`)
     - Đăng nhập (`LOGIN`)
     - Tạo người dùng (`CREATE USER`)

7. **Truy cập tất cả tính năng:**
   - Không bị giới hạn bởi `RoleFilter`
   - Có thể truy cập tất cả controller và JSP

---

## 🔐 2. CƠ CHẾ BẢO MẬT VÀ PHÂN QUYỀN

### **2.1. Authentication (Xác thực)**
- **Filter:** `AuthFilter`
- **Chức năng:** Kiểm tra user đã đăng nhập chưa
- **Public paths:** `/login`, `/logout`, `/css/*`, `/js/*`, `/img/*`
- **Protected paths:** Tất cả các path khác yêu cầu đăng nhập

### **2.2. Authorization (Phân quyền)**
- **Filter:** `RoleFilter`
- **Chức năng:** Kiểm tra quyền truy cập dựa trên role

**Các path bị giới hạn:**
```java
// Chỉ ADMIN mới được truy cập
if (path.startsWith("/admin/")) {
    if (!"ADMIN".equals(role)) {
        resp.sendError(HttpServletResponse.SC_FORBIDDEN);
        return;
    }
}

// Chỉ ADMIN mới được duyệt/hủy
if (path.startsWith("/request/review")) {
    if (!"ADMIN".equals(role)) {
        resp.sendError(HttpServletResponse.SC_FORBIDDEN);
        return;
    }
}
```

**Controller-level authorization:**
- `ReviewController`: Kiểm tra `user.getRole().getCode() == "ADMIN"` trong cả GET và POST
- `AdminCreateUserController`: Kiểm tra `isAdmin(req)` trước khi xử lý

**JSP-level authorization:**
- Sử dụng `<c:if test="${user.role.code eq 'ADMIN'}">` để ẩn/hiện nút
- Ví dụ: Nút "Duyệt" chỉ hiển thị nếu `r.status == 1 AND user.role.code == 'ADMIN'`

---

## 👥 3. AI LÀ NGƯỜI DUYỆT ĐƠN CỦA AI?

### **3.1. Quy trình duyệt đơn hiện tại:**

```
┌─────────────────────────────────────────┐
│  EMPLOYEE tạo đơn                        │
│  → Status: INPROGRESS                    │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│  MANAGER/LEADER XEM đơn (chỉ xem)      │
│  → Tab "Đơn cần duyệt"                 │
│  → KHÔNG có nút Duyệt/Từ chối          │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│  ADMIN DUYỆT/TỪ CHỐI đơn               │
│  → Có nút "Duyệt" và "Từ chối"         │
│  → Cập nhật status, processed_by       │
│  → Ghi Audit Log                        │
└─────────────────────────────────────────┘
```

### **3.2. Quan hệ Manager-Subordinate:**

**Cách xác định cấp dưới:**
- Trong bảng `Users`, mỗi user có trường `manager_id`
- Nếu `user.manager_id = X`, thì user đó là cấp dưới của user có `id = X`
- MANAGER/LEADER/ADMIN có thể xem đơn của tất cả user có `manager_id` trỏ đến mình

**SQL Query:**
```sql
-- Lấy đơn của cấp dưới
SELECT r.* FROM Requests r
WHERE r.created_by IN (
    SELECT id FROM Users WHERE manager_id = ?
)
```

**Ví dụ:**
- User `bob` (MANAGER, id=1) có `manager_id = NULL`
- User `alice` (EMPLOYEE, id=3) có `manager_id = 1` (trỏ đến bob)
- → `bob` có thể xem đơn của `alice`
- → `alice` KHÔNG thể xem đơn của `bob`

### **3.3. Ai có thể duyệt đơn?**

**Theo code hiện tại:**
- ✅ **CHỈ ADMIN** có thể duyệt/từ chối đơn
- ❌ MANAGER/LEADER **KHÔNG THỂ** duyệt đơn (dù có thể xem)

**Lý do:**
- Theo yêu cầu gần đây: "chỉ ADMIN mới được duyệt/hủy"
- Code đã được cập nhật để giới hạn quyền này

**Tương lai (nếu cần):**
- Database có sẵn bảng `ApprovalWorkflows` để hỗ trợ quy trình duyệt đa cấp
- Có thể mở rộng để MANAGER/LEADER duyệt đơn của cấp dưới trực tiếp

---

## 👤 4. AI LÀ NGƯỜI TẠO NGƯỜI DÙNG?

### **4.1. Quyền tạo người dùng:**

**CHỈ ADMIN** mới có quyền tạo người dùng mới.

**Cách thức:**
1. **Truy cập:** `/admin/users/create`
2. **Kiểm tra quyền:** `AdminCreateUserController` kiểm tra `isAdmin(req)`
3. **Nhập thông tin:**
   - Username (phải unique)
   - Password
   - Full Name
   - Role (EMPLOYEE/MANAGER/LEADER/ADMIN)
   - Department
   - Manager (optional - chọn manager cho user mới)
   - Active status (kích hoạt/vô hiệu hóa)

4. **Xử lý:**
   - `UserDBContext.createUser()` kiểm tra username đã tồn tại chưa
   - Nếu tồn tại → throw `RuntimeException("Username đã tồn tại")`
   - Nếu chưa → Insert vào bảng `Users`

### **4.2. Quản lý người dùng:**

**Truy cập:** `/admin/users/list`

**Chức năng:**
- Xem danh sách tất cả người dùng
- Tìm kiếm, sắp xếp
- **Kích hoạt/Vô hiệu hóa** tài khoản:
  - `UserDBContext.updateUserStatus(userId, active)`
  - User bị vô hiệu hóa sẽ không thể đăng nhập
- **Đặt lại mật khẩu:**
  - `UserDBContext.resetUserPassword(userId, newPassword)`
  - Admin có thể reset password cho bất kỳ user nào

---

## 🔄 5. CÁCH THỨC HOẠT ĐỘNG CHI TIẾT

### **5.1. Vòng đời của một đơn nghỉ phép:**

```
1. TẠO ĐƠN (CREATE)
   ├─ User: EMPLOYEE/MANAGER/LEADER/ADMIN
   ├─ Endpoint: POST /request/create
   ├─ Status: INPROGRESS
   ├─ Ghi Audit Log: CREATE
   └─ Thông báo: Tạo notification cho manager (nếu có)

2. XEM ĐƠN (VIEW)
   ├─ User: Tất cả (đơn của mình) hoặc MANAGER/LEADER/ADMIN (đơn cấp dưới)
   ├─ Endpoint: GET /request/list
   ├─ Tab "Đơn của tôi": listMine()
   └─ Tab "Đơn cần duyệt": listOfSubordinates() (chỉ MANAGER/LEADER/ADMIN)

3. DUYỆT/TỪ CHỐI (APPROVE/REJECT)
   ├─ User: CHỈ ADMIN
   ├─ Endpoint: POST /request/review
   ├─ Status: APPROVED hoặc REJECTED
   ├─ Ghi processed_by, processed_at, manager_note
   ├─ Ghi Audit Log: APPROVE_REJECT
   └─ Thông báo: Tạo notification cho employee

4. HỦY ĐƠN (CANCEL)
   ├─ User: CHỈ ADMIN
   ├─ Endpoint: (chưa implement đầy đủ)
   ├─ Status: (có thể thêm status CANCELLED)
   └─ Ghi Audit Log: CANCEL
```

### **5.2. Bộ lọc và tìm kiếm:**

**Tại `/request/list`:**
- **Bộ lọc:**
  - Từ ngày (`from`)
  - Đến ngày (`to`)
  - Trạng thái (`status`: INPROGRESS/APPROVED/REJECTED)
  - Loại phép (`typeId`)
- **Phân trang:**
  - Server-side pagination
  - `pageMine`, `sizeMine` cho tab "Đơn của tôi"
  - `pageSubs`, `sizeSubs` cho tab "Đơn cần duyệt"
- **SQL:**
  ```sql
  -- Ví dụ: Lọc đơn của tôi
  SELECT r.* FROM Requests r
  WHERE r.employee_id = ?
    AND r.start_date >= ?  -- from
    AND r.end_date <= ?    -- to
    AND r.status = ?       -- status
    AND r.type_id = ?      -- typeId
  ORDER BY r.created_at DESC
  OFFSET ? ROWS FETCH NEXT ? ROWS ONLY
  ```

### **5.3. Audit Log (Nhật ký kiểm toán):**

**Mục đích:** Theo dõi tất cả hành động quan trọng trong hệ thống

**Bảng:** `AuditLogs`
- `user_id`: Người thực hiện
- `action`: Hành động (CREATE, APPROVE_REJECT, LOGIN, etc.)
- `entity_type`: Loại entity (REQUEST, USER, etc.)
- `entity_id`: ID của entity
- `old_values`: Giá trị cũ (JSON)
- `new_values`: Giá trị mới (JSON)
- `created_at`: Thời gian

**Các hành động được ghi log:**
1. **CREATE:** Tạo đơn nghỉ phép
2. **APPROVE_REJECT:** Duyệt/từ chối đơn
3. **LOGIN:** Đăng nhập (có thể thêm)
4. **CREATE_USER:** Tạo người dùng mới (có thể thêm)

### **5.4. Notifications (Thông báo):**

**Bảng:** `Notifications`
- `user_id`: Người nhận
- `type`: Loại (EMAIL, SMS, IN_APP)
- `title`: Tiêu đề
- `message`: Nội dung
- `related_type`: REQUEST, APPROVAL, etc.
- `related_id`: ID liên quan
- `is_read`: Đã đọc chưa

**Các thông báo tự động:**
1. Khi đơn được tạo → Thông báo cho manager
2. Khi đơn được duyệt/từ chối → Thông báo cho employee
3. (Có thể mở rộng: thông báo sắp hết hạn, conflict, etc.)

---

## 📊 6. ĐỘ ỔN ĐỊNH VÀ TÍNH NĂNG ĐÃ HOẠT ĐỘNG

### **6.1. Tính năng đã hoạt động ổn định:**

✅ **Đăng nhập/Đăng xuất:**
- Giao diện hiện đại, responsive
- Xử lý lỗi database connection tốt
- Session management ổn định

✅ **Tạo đơn nghỉ phép:**
- Form validation
- Upload file đính kèm
- Ghi Audit Log
- Tạo notification

✅ **Danh sách đơn nghỉ phép:**
- 2 tabs: "Đơn của tôi" và "Đơn cần duyệt"
- Bộ lọc nâng cao (ngày, trạng thái, loại phép)
- Server-side pagination
- Role-based button visibility

✅ **Duyệt/Từ chối đơn:**
- Chỉ ADMIN có quyền
- Cập nhật database đúng
- Ghi Audit Log
- Tạo notification

✅ **Quản lý người dùng (Admin):**
- Tạo user mới với đầy đủ thông tin
- List, search, sort users
- Activate/deactivate
- Reset password

✅ **Dashboard:**
- Thống kê theo role
- Quick actions
- Modern UI

✅ **Notifications:**
- In-app notifications
- Mark as read
- Unread count

✅ **Leave Balance:**
- Hiển thị số dư phép
- Theo năm và loại phép

✅ **Agenda/Calendar:**
- FullCalendar integration
- Filter theo phòng ban và ngày

✅ **Reports:**
- Chart.js integration
- CSV export

### **6.2. Vấn đề còn lại:**

⚠️ **Lỗi môi trường (không phải lỗi code):**
- Jakarta Servlet API chưa được cấu hình trong NetBeans
- Cần Tomcat 10+ và thư viện `jakarta.servlet.*`
- **Giải pháp:** Cấu hình môi trường theo hướng dẫn trong `NETBEANS_SETUP.md`

⚠️ **Tính năng chưa hoàn thiện:**
- Hủy đơn (cancel request) chưa implement đầy đủ
- Email service chỉ là stub (in ra console)
- Multi-tier approval workflow chưa được sử dụng (database có sẵn nhưng code chưa dùng)

### **6.3. Database Schema:**

✅ **Đã có đầy đủ:**
- Tables: Users, Roles, Departments, Requests, LeaveTypes, Notifications, LeaveBalances, AuditLogs, ApprovalWorkflows, Delegations, ConflictAlerts, LeavePolicies, UserSettings
- Views: vw_Agenda, vw_LeaveStatisticsByDepartment, vw_ManagerDashboard
- Triggers: tr_Requests_StatusHistory (ghi lịch sử thay đổi status)
- Indexes: Tối ưu cho các query thường dùng

✅ **Script SQL:**
- `leave_management_setup_v2.sql`: Rerunnable, self-contained
- Pre-setup SQL Server authentication
- Seed data đầy đủ

---

## 🎯 7. TÓM TẮT NHANH

| Chức vụ | Xem đơn của mình | Xem đơn cấp dưới | Duyệt/Từ chối | Tạo user | Quản trị |
|---------|------------------|------------------|---------------|----------|----------|
| **EMPLOYEE** | ✅ | ❌ | ❌ | ❌ | ❌ |
| **MANAGER** | ✅ | ✅ (chỉ cấp dưới trực tiếp) | ❌ | ❌ | ❌ |
| **LEADER** | ✅ | ✅ (chỉ cấp dưới trực tiếp) | ❌ | ❌ | ❌ |
| **ADMIN** | ✅ | ✅ (tất cả) | ✅ (tất cả) | ✅ | ✅ |

**Quy trình duyệt đơn:**
1. EMPLOYEE tạo đơn → Status: INPROGRESS
2. MANAGER/LEADER xem đơn (chỉ xem, không duyệt)
3. ADMIN duyệt/từ chối → Status: APPROVED/REJECTED

**Quy trình tạo user:**
- CHỈ ADMIN có quyền tạo user mới tại `/admin/users/create`

---

## 📝 8. GHI CHÚ QUAN TRỌNG

1. **Quyền duyệt đơn:** Hiện tại CHỈ ADMIN mới có quyền duyệt/từ chối. MANAGER/LEADER chỉ có thể XEM đơn của cấp dưới.

2. **Quan hệ Manager-Subordinate:** Dựa trên trường `manager_id` trong bảng `Users`. Mỗi user có thể có 1 manager.

3. **Audit Log:** Tất cả hành động quan trọng đều được ghi log để theo dõi và kiểm tra.

4. **Notifications:** Hệ thống tự động tạo thông báo khi có sự kiện quan trọng (tạo đơn, duyệt/từ chối).

5. **Database:** Schema đã được thiết kế để hỗ trợ các tính năng nâng cao (multi-tier approval, delegation, conflict detection), nhưng code hiện tại chỉ sử dụng một phần.

---

**Tài liệu này được tạo dựa trên code thực tế trong project.**
**Cập nhật lần cuối:** Dựa trên code hiện tại của project.

