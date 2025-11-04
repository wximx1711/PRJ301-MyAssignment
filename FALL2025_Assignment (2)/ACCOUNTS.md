# Danh sách Tài khoản - Leave Management System

## Tất cả tên đăng nhập và mật khẩu

Tất cả các tài khoản hiện tại đều sử dụng **mật khẩu: `123`**

### 👤 Quản trị viên (ADMIN)

| Tên đăng nhập | Mật khẩu | Họ tên | Phòng ban | Vai trò |
|--------------|----------|--------|-----------|---------|
| `admin` | `123` | Admin User | IT | Quản trị viên |

### 👔 Quản lý (MANAGER)

| Tên đăng nhập | Mật khẩu | Họ tên | Phòng ban | Vai trò | Quản lý |
|--------------|----------|--------|-----------|---------|---------|
| `bob` | `123` | Bob Tran | IT | Quản lý | - |
| `mike` | `123` | Mike Le | QA | Quản lý | - |

### 👨‍💼 Trưởng nhóm (LEADER)

| Tên đăng nhập | Mật khẩu | Họ tên | Phòng ban | Vai trò | Quản lý |
|--------------|----------|--------|-----------|---------|---------|
| `carl` | `123` | Carl Pham | IT | Trưởng nhóm | Bob Tran |

### 👷 Nhân viên (EMPLOYEE)

| Tên đăng nhập | Mật khẩu | Họ tên | Phòng ban | Vai trò | Quản lý |
|--------------|----------|--------|-----------|---------|---------|
| `alice` | `123` | Alice Nguyen | IT | Nhân viên | Bob Tran |
| `eva` | `123` | Eva Do | QA | Nhân viên | Mike Le |

---

## Tóm tắt nhanh

### Tài khoản Admin
- **Username:** `admin` | **Password:** `123`

### Tài khoản Manager
- **Username:** `bob` | **Password:** `123` (Manager IT)
- **Username:** `mike` | **Password:** `123` (Manager QA)

### Tài khoản Leader
- **Username:** `carl` | **Password:** `123` (Leader IT - báo cáo Bob)

### Tài khoản Employee
- **Username:** `alice` | **Password:** `123` (Employee IT - báo cáo Bob)
- **Username:** `eva` | **Password:** `123` (Employee QA - báo cáo Mike)

---

## Lưu ý bảo mật

⚠️ **Cảnh báo:** Tất cả mật khẩu hiện tại đều là `123` - đây chỉ là mật khẩu mẫu cho môi trường phát triển.

**Khuyến nghị cho Production:**
- Thay đổi tất cả mật khẩu thành mật khẩu mạnh
- Sử dụng hash (bcrypt, SHA-256) thay vì lưu plain text
- Implement password policy (độ dài tối thiểu, ký tự đặc biệt, v.v.)
- Yêu cầu đổi mật khẩu lần đầu khi đăng nhập

---

## Cấu trúc tổ chức

```
IT Department:
├── Bob Tran (Manager) - bob/123
│   ├── Alice Nguyen (Employee) - alice/123
│   └── Carl Pham (Leader) - carl/123
└── Admin User (Admin) - admin/123

QA Department:
└── Mike Le (Manager) - mike/123
    └── Eva Do (Employee) - eva/123
```

---

## Test Accounts theo Role

### Để test Admin Dashboard:
- Username: `admin`
- Password: `123`

### Để test Manager Dashboard:
- Username: `bob` hoặc `mike`
- Password: `123`

### Để test Employee Dashboard:
- Username: `alice` hoặc `eva`
- Password: `123`

### Để test Leader Dashboard:
- Username: `carl`
- Password: `123`

---

**Tổng cộng: 6 tài khoản**
- 1 Admin
- 2 Manager
- 1 Leader
- 2 Employee

