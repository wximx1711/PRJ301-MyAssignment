/* ================================================================
   PRJ301_Assignment Mink — Leave Management 
   ================================================================= */

-- 0) Tạo mới DB an toàn
IF DB_ID('P42_AsignmentW10') IS NOT NULL
BEGIN
    ALTER DATABASE FALL25_Assignment SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE FALL25_Assignment;
END;
GO
CREATE DATABASE FALL25_Assignment;
GO
USE FALL25_Assignment;
GO

/* ========== 1) Lookup: Departments, Roles, LeaveTypes ========== */
CREATE TABLE dbo.Departments (
    id           INT IDENTITY(1,1) PRIMARY KEY,
    name         NVARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE dbo.Roles (
    id           INT IDENTITY(1,1) PRIMARY KEY,
    code         NVARCHAR(30)  NOT NULL UNIQUE,   -- EMPLOYEE / MANAGER / LEADER
    name         NVARCHAR(100) NOT NULL
);

CREATE TABLE dbo.LeaveTypes (
    id                 INT IDENTITY(1,1) PRIMARY KEY,
    code               NVARCHAR(30)  NOT NULL UNIQUE,  -- ANNUAL / SICK / MARRIAGE / ...
    name               NVARCHAR(100) NOT NULL,
    requires_document  BIT NOT NULL DEFAULT (0)
);

/* ========== 2) Users (chuẩn hoá, có manager_id) ========== */
CREATE TABLE dbo.Users (
    id            INT IDENTITY(1,1) PRIMARY KEY,
    username      NVARCHAR(50)  NOT NULL UNIQUE,
    password_hash NVARCHAR(255) NOT NULL,          -- (Gợi ý: lưu hash, không lưu plain)
    full_name     NVARCHAR(120) NOT NULL,
    role_id       INT NOT NULL FOREIGN KEY REFERENCES dbo.Roles(id),
    department_id INT NOT NULL FOREIGN KEY REFERENCES dbo.Departments(id),
    manager_id    INT NULL     FOREIGN KEY REFERENCES dbo.Users(id),
    is_active     BIT NOT NULL DEFAULT (1),
    created_at    DATETIME2(0) NOT NULL DEFAULT (SYSUTCDATETIME())
);
CREATE INDEX IX_Users_Manager ON dbo.Users(manager_id);

/* ========== 3) Requests + History + Attachments ========== */
CREATE TABLE dbo.Requests (
    id             INT IDENTITY(1,1) PRIMARY KEY,
    employee_id    INT NOT NULL FOREIGN KEY REFERENCES dbo.Users(id),
    type_id        INT NOT NULL FOREIGN KEY REFERENCES dbo.LeaveTypes(id),
    title          NVARCHAR(100) NOT NULL,
    reason         NVARCHAR(255) NOT NULL,
    start_date     DATE NOT NULL,
    end_date       DATE NOT NULL,
    status         NVARCHAR(20) NOT NULL 
        CONSTRAINT CK_Requests_Status CHECK (status IN (N'INPROGRESS', N'APPROVED', N'REJECTED')),
    manager_note   NVARCHAR(255) NULL,
    created_at     DATETIME2(0) NOT NULL DEFAULT (SYSUTCDATETIME()),
    created_by     INT NOT NULL FOREIGN KEY REFERENCES dbo.Users(id),
    processed_at   DATETIME2(0) NULL,
    processed_by   INT NULL FOREIGN KEY REFERENCES dbo.Users(id),
    duration_days  AS (DATEDIFF(DAY, start_date, end_date) + 1) PERSISTED
);

-- Ràng buộc ngày hợp lệ
ALTER TABLE dbo.Requests ADD CONSTRAINT CK_Requests_DateRange
CHECK (start_date <= end_date);
-- Chỉ mục phục vụ màn hình list/agenda/duyệt
CREATE INDEX IX_Requests_EmployeeStatus ON dbo.Requests(employee_id, status);
CREATE INDEX IX_Requests_DateRange     ON dbo.Requests(start_date, end_date);
CREATE INDEX IX_Requests_ProcessedBy   ON dbo.Requests(processed_by);

-- Lịch sử chuyển trạng thái / ghi chú duyệt
CREATE TABLE dbo.RequestHistory (
    id           INT IDENTITY(1,1) PRIMARY KEY,
    request_id   INT NOT NULL FOREIGN KEY REFERENCES dbo.Requests(id),
    old_status   NVARCHAR(20) NULL,
    new_status   NVARCHAR(20) NOT NULL,
    changed_by   INT NOT NULL FOREIGN KEY REFERENCES dbo.Users(id),
    changed_at   DATETIME2(0) NOT NULL DEFAULT (SYSUTCDATETIME()),
    note         NVARCHAR(255) NULL
);
CREATE INDEX IX_History_Request ON dbo.RequestHistory(request_id);

-- Đính kèm minh chứng
CREATE TABLE dbo.Attachments (
    id           INT IDENTITY(1,1) PRIMARY KEY,
    request_id   INT NOT NULL FOREIGN KEY REFERENCES dbo.Requests(id),
    file_name    NVARCHAR(255) NOT NULL,
    file_path    NVARCHAR(500) NOT NULL,  -- đường dẫn lưu file
    uploaded_by  INT NOT NULL FOREIGN KEY REFERENCES dbo.Users(id),
    uploaded_at  DATETIME2(0) NOT NULL DEFAULT (SYSUTCDATETIME())
);
CREATE INDEX IX_Attachments_Request ON dbo.Attachments(request_id);

/* ========== 4) Notifications System ========== */
CREATE TABLE dbo.Notifications (
    id           INT IDENTITY(1,1) PRIMARY KEY,
    user_id      INT NOT NULL FOREIGN KEY REFERENCES dbo.Users(id),
    type         NVARCHAR(50) NOT NULL,  -- EMAIL, SMS, IN_APP
    title        NVARCHAR(200) NOT NULL,
    message      NVARCHAR(500) NOT NULL,
    related_type NVARCHAR(50) NULL,      -- REQUEST, APPROVAL, etc.
    related_id   INT NULL,
    is_read      BIT NOT NULL DEFAULT (0),
    created_at   DATETIME2(0) NOT NULL DEFAULT (SYSUTCDATETIME()),
    read_at      DATETIME2(0) NULL
);
CREATE INDEX IX_Notifications_User ON dbo.Notifications(user_id, is_read);
CREATE INDEX IX_Notifications_Created ON dbo.Notifications(created_at DESC);

/* ========== 5) Leave Balance Tracking ========== */
CREATE TABLE dbo.LeaveBalances (
    id           INT IDENTITY(1,1) PRIMARY KEY,
    user_id      INT NOT NULL FOREIGN KEY REFERENCES dbo.Users(id),
    leave_type_id INT NOT NULL FOREIGN KEY REFERENCES dbo.LeaveTypes(id),
    year         INT NOT NULL,
    total_days   INT NOT NULL DEFAULT (0),  -- Tổng số ngày được phép
    used_days    INT NOT NULL DEFAULT (0),  -- Số ngày đã dùng
    remaining_days AS (total_days - used_days) PERSISTED,
    updated_at   DATETIME2(0) NOT NULL DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT UQ_LeaveBalance_UserTypeYear UNIQUE (user_id, leave_type_id, year)
);
CREATE INDEX IX_LeaveBalances_User ON dbo.LeaveBalances(user_id, year);

/* ========== 6) Multi-Tier Approval Workflow ========== */
CREATE TABLE dbo.ApprovalWorkflows (
    id           INT IDENTITY(1,1) PRIMARY KEY,
    request_id   INT NOT NULL FOREIGN KEY REFERENCES dbo.Requests(id),
    approver_id  INT NOT NULL FOREIGN KEY REFERENCES dbo.Users(id),
    step_order   INT NOT NULL,  -- 1, 2, 3... (cấp duyệt)
    status       NVARCHAR(20) NOT NULL DEFAULT (N'PENDING') 
        CONSTRAINT CK_ApprovalWorkflow_Status CHECK (status IN (N'PENDING', N'APPROVED', N'REJECTED')),
    note         NVARCHAR(255) NULL,
    approved_at  DATETIME2(0) NULL,
    CONSTRAINT UQ_ApprovalWorkflow_RequestStep UNIQUE (request_id, step_order)
);
CREATE INDEX IX_ApprovalWorkflows_Request ON dbo.ApprovalWorkflows(request_id);
CREATE INDEX IX_ApprovalWorkflows_Approver ON dbo.ApprovalWorkflows(approver_id, status);

/* ========== 7) Delegation (Ủy quyền) ========== */
CREATE TABLE dbo.Delegations (
    id           INT IDENTITY(1,1) PRIMARY KEY,
    delegator_id INT NOT NULL FOREIGN KEY REFERENCES dbo.Users(id),  -- Người ủy quyền
    delegate_id  INT NOT NULL FOREIGN KEY REFERENCES dbo.Users(id),  -- Người được ủy quyền
    start_date   DATE NOT NULL,
    end_date     DATE NOT NULL,
    is_active    BIT NOT NULL DEFAULT (1),
    created_at   DATETIME2(0) NOT NULL DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT CK_Delegations_DateRange CHECK (start_date <= end_date)
);
CREATE INDEX IX_Delegations_Delegate ON dbo.Delegations(delegate_id, is_active, start_date, end_date);

/* ========== 8) Audit Logs ========== */
CREATE TABLE dbo.AuditLogs (
    id           INT IDENTITY(1,1) PRIMARY KEY,
    user_id      INT NULL FOREIGN KEY REFERENCES dbo.Users(id),
    action       NVARCHAR(100) NOT NULL,  -- CREATE, UPDATE, DELETE, APPROVE, REJECT, LOGIN, etc.
    entity_type  NVARCHAR(50) NOT NULL,   -- REQUEST, USER, LEAVE_BALANCE, etc.
    entity_id    INT NULL,
    old_values   NVARCHAR(MAX) NULL,      -- JSON string
    new_values   NVARCHAR(MAX) NULL,      -- JSON string
    ip_address   NVARCHAR(45) NULL,
    user_agent   NVARCHAR(500) NULL,
    created_at   DATETIME2(0) NOT NULL DEFAULT (SYSUTCDATETIME())
);
CREATE INDEX IX_AuditLogs_User ON dbo.AuditLogs(user_id, created_at DESC);
CREATE INDEX IX_AuditLogs_Entity ON dbo.AuditLogs(entity_type, entity_id);
CREATE INDEX IX_AuditLogs_Created ON dbo.AuditLogs(created_at DESC);

/* ========== 9) Conflict Detection ========== */
CREATE TABLE dbo.ConflictAlerts (
    id           INT IDENTITY(1,1) PRIMARY KEY,
    request_id   INT NOT NULL FOREIGN KEY REFERENCES dbo.Requests(id),
    conflict_type NVARCHAR(50) NOT NULL,  -- OVERLAP, DEPARTMENT_SHORTAGE, etc.
    conflicting_request_id INT NULL FOREIGN KEY REFERENCES dbo.Requests(id),
    department_id INT NULL FOREIGN KEY REFERENCES dbo.Departments(id),
    message      NVARCHAR(500) NOT NULL,
    severity     NVARCHAR(20) NOT NULL DEFAULT (N'MEDIUM') 
        CONSTRAINT CK_ConflictAlerts_Severity CHECK (severity IN (N'LOW', N'MEDIUM', N'HIGH', N'CRITICAL')),
    is_resolved  BIT NOT NULL DEFAULT (0),
    created_at   DATETIME2(0) NOT NULL DEFAULT (SYSUTCDATETIME()),
    resolved_at  DATETIME2(0) NULL
);
CREATE INDEX IX_ConflictAlerts_Request ON dbo.ConflictAlerts(request_id, is_resolved);

/* ========== 10) Leave Policies ========== */
CREATE TABLE dbo.LeavePolicies (
    id           INT IDENTITY(1,1) PRIMARY KEY,
    department_id INT NULL FOREIGN KEY REFERENCES dbo.Departments(id),  -- NULL = áp dụng toàn công ty
    leave_type_id INT NOT NULL FOREIGN KEY REFERENCES dbo.LeaveTypes(id),
    max_days_per_year INT NOT NULL,
    min_days_per_request INT NOT NULL DEFAULT (1),
    max_days_per_request INT NULL,
    requires_advance_notice INT NULL,  -- Số ngày cần thông báo trước
    auto_approve_conditions NVARCHAR(MAX) NULL,  -- JSON string
    is_active    BIT NOT NULL DEFAULT (1),
    created_at   DATETIME2(0) NOT NULL DEFAULT (SYSUTCDATETIME())
);
CREATE INDEX IX_LeavePolicies_Department ON dbo.LeavePolicies(department_id, leave_type_id);

/* ========== 11) User Settings (Email, SMS preferences) ========== */
CREATE TABLE dbo.UserSettings (
    id           INT IDENTITY(1,1) PRIMARY KEY,
    user_id      INT NOT NULL UNIQUE FOREIGN KEY REFERENCES dbo.Users(id),
    email        NVARCHAR(255) NULL,
    phone        NVARCHAR(20) NULL,
    email_notifications BIT NOT NULL DEFAULT (1),
    sms_notifications BIT NOT NULL DEFAULT (0),
    in_app_notifications BIT NOT NULL DEFAULT (1),
    language     NVARCHAR(10) NOT NULL DEFAULT (N'vi'),
    theme        NVARCHAR(20) NOT NULL DEFAULT (N'light'),
    updated_at   DATETIME2(0) NOT NULL DEFAULT (SYSUTCDATETIME())
);
CREATE INDEX IX_UserSettings_User ON dbo.UserSettings(user_id);

/* ========== 12) Trigger: tự ghi lịch sử khi đổi trạng thái/duyệt ========== */
GO
CREATE OR ALTER TRIGGER dbo.tr_Requests_StatusHistory
ON dbo.Requests
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Ghi lịch sử khi status/manager_note/processed_by/processed_at thay đổi
    INSERT INTO dbo.RequestHistory (request_id, old_status, new_status, changed_by, note, changed_at)
    SELECT
        i.id,
        d.status,
        i.status,
        ISNULL(i.processed_by, i.created_by),  -- nếu chưa có processed_by thì tạm ghi người tạo
        i.manager_note,
        SYSUTCDATETIME()
    FROM inserted i
    JOIN deleted  d ON d.id = i.id
    WHERE (ISNULL(d.status,'') <> ISNULL(i.status,''))
       OR (ISNULL(d.manager_note,'') <> ISNULL(i.manager_note,''))
       OR (ISNULL(d.processed_by,0) <> ISNULL(i.processed_by,0))
       OR (ISNULL(d.processed_at,'1900-01-01') <> ISNULL(i.processed_at,'1900-01-01'));
END;
GO

/* ========== 13) Views phục vụ Dashboard và Reports ========== */
CREATE OR ALTER VIEW dbo.vw_Agenda
AS
SELECT 
    u.id            AS user_id,
    u.full_name,
    d.name          AS department,
    r.id            AS request_id,
    r.status,
    dt.work_date
FROM dbo.Users u
JOIN dbo.Departments d ON d.id = u.department_id
JOIN dbo.Requests   r ON r.employee_id = u.id AND r.status = N'APPROVED'
CROSS APPLY (
    SELECT DATEADD(DAY, v.number, r.start_date) AS work_date
    FROM master..spt_values v
    WHERE v.type = 'P'
      AND DATEADD(DAY, v.number, r.start_date) <= r.end_date
) dt;
GO

-- View: Leave Statistics by Department
CREATE OR ALTER VIEW dbo.vw_LeaveStatisticsByDepartment
AS
SELECT 
    d.id AS department_id,
    d.name AS department_name,
    lt.id AS leave_type_id,
    lt.name AS leave_type_name,
    YEAR(r.start_date) AS year,
    COUNT(*) AS total_requests,
    SUM(CASE WHEN r.status = N'APPROVED' THEN r.duration_days ELSE 0 END) AS approved_days,
    SUM(CASE WHEN r.status = N'INPROGRESS' THEN r.duration_days ELSE 0 END) AS pending_days,
    SUM(CASE WHEN r.status = N'REJECTED' THEN r.duration_days ELSE 0 END) AS rejected_days
FROM dbo.Departments d
JOIN dbo.Users u ON u.department_id = d.id
JOIN dbo.Requests r ON r.employee_id = u.id
JOIN dbo.LeaveTypes lt ON lt.id = r.type_id
GROUP BY d.id, d.name, lt.id, lt.name, YEAR(r.start_date);

-- View: Manager Dashboard Data
CREATE OR ALTER VIEW dbo.vw_ManagerDashboard
AS
SELECT 
    m.id AS manager_id,
    m.full_name AS manager_name,
    COUNT(DISTINCT CASE WHEN r.status = N'INPROGRESS' THEN r.id END) AS pending_requests,
    COUNT(DISTINCT CASE WHEN r.status = N'APPROVED' AND r.start_date >= CAST(GETDATE() AS DATE) THEN r.id END) AS upcoming_approvals,
    COUNT(DISTINCT e.id) AS total_subordinates,
    SUM(CASE WHEN r.status = N'APPROVED' AND YEAR(r.start_date) = YEAR(GETDATE()) THEN r.duration_days ELSE 0 END) AS approved_days_this_year
FROM dbo.Users m
LEFT JOIN dbo.Users e ON e.manager_id = m.id
LEFT JOIN dbo.Requests r ON r.employee_id = e.id
WHERE m.role_id IN (SELECT id FROM dbo.Roles WHERE code IN (N'MANAGER', N'LEADER'))
GROUP BY m.id, m.full_name;

GO

/* ========== 14) SEED dữ liệu  ========== */
-- Departments
INSERT INTO dbo.Departments(name) VALUES (N'IT'), (N'QA');

-- Roles (thêm ADMIN)
INSERT INTO dbo.Roles(code, name) VALUES
(N'EMPLOYEE', N'Nhân viên'),
(N'MANAGER',  N'Quản lý'),
(N'LEADER',   N'Trưởng nhóm'),
(N'ADMIN',    N'Quản trị viên');

-- LeaveTypes
INSERT INTO dbo.LeaveTypes(code, name, requires_document) VALUES
(N'ANNUAL',   N'Phép năm', 0),
(N'SICK',     N'Nghỉ ốm',  1),
(N'MARRIAGE', N'Nghỉ cưới',1);

-- Users (dùng '123' tạm; khuyến nghị thay bằng hash)
DECLARE @IT INT = (SELECT id FROM dbo.Departments WHERE name=N'IT');
DECLARE @QA INT = (SELECT id FROM dbo.Departments WHERE name=N'QA');

DECLARE @EMP INT = (SELECT id FROM dbo.Roles WHERE code=N'EMPLOYEE');
DECLARE @MAN INT = (SELECT id FROM dbo.Roles WHERE code=N'MANAGER');
DECLARE @LEA INT = (SELECT id FROM dbo.Roles WHERE code=N'LEADER');
DECLARE @ADM INT = (SELECT id FROM dbo.Roles WHERE code=N'ADMIN');

-- Tạo trước manager để gán manager_id
INSERT INTO dbo.Users(username,password_hash,full_name,role_id,department_id,manager_id)
VALUES
(N'bob',  N'123', N'Bob Tran',  @MAN, @IT, NULL),  -- Manager IT
(N'mike', N'123', N'Mike Le',   @MAN, @QA, NULL);  -- Manager QA

-- Lấy id của 2 manager
DECLARE @bob  INT = (SELECT id FROM dbo.Users WHERE username=N'bob');
DECLARE @mike INT = (SELECT id FROM dbo.Users WHERE username=N'mike');

-- Admin
INSERT INTO dbo.Users(username,password_hash,full_name,role_id,department_id,manager_id)
VALUES
(N'admin', N'123', N'Admin User', @ADM, @IT, NULL);

-- Nhân viên/Leader báo cáo lên manager
INSERT INTO dbo.Users(username,password_hash,full_name,role_id,department_id,manager_id)
VALUES
(N'alice', N'123', N'Alice Nguyen', @EMP, @IT,  @bob),
(N'carl',  N'123', N'Carl Pham',    @LEA, @IT,  @bob),
(N'eva',   N'123', N'Eva Do',       @EMP, @QA,  @mike);

-- Seed Leave Balances (2025)
DECLARE @admin INT = (SELECT id FROM dbo.Users WHERE username=N'admin');
DECLARE @alice INT = (SELECT id FROM dbo.Users WHERE username=N'alice');
DECLARE @carl  INT = (SELECT id FROM dbo.Users WHERE username=N'carl');
DECLARE @eva   INT = (SELECT id FROM dbo.Users WHERE username=N'eva');

INSERT INTO dbo.LeaveBalances(user_id, leave_type_id, year, total_days, used_days)
SELECT u.id, lt.id, 2025, 
    CASE lt.code 
        WHEN N'ANNUAL' THEN 12 
        WHEN N'SICK' THEN 5 
        ELSE 3 
    END,
    0
FROM dbo.Users u
CROSS JOIN dbo.LeaveTypes lt
WHERE u.username IN (N'alice', N'carl', N'eva', N'bob', N'mike');

-- Seed User Settings
INSERT INTO dbo.UserSettings(user_id, email, phone, email_notifications, sms_notifications)
SELECT id, username + '@company.com', N'+84901234567', 1, 0
FROM dbo.Users;

-- Seed Leave Policies
INSERT INTO dbo.LeavePolicies(department_id, leave_type_id, max_days_per_year, min_days_per_request, max_days_per_request, requires_advance_notice)
SELECT NULL, lt.id, 
    CASE lt.code WHEN N'ANNUAL' THEN 12 WHEN N'SICK' THEN 5 ELSE 3 END,
    1, 5, 3
FROM dbo.LeaveTypes lt;

-- Một vài Requests mẫu
DECLARE @ANNUAL INT = (SELECT id FROM dbo.LeaveTypes WHERE code=N'ANNUAL');
DECLARE @SICK   INT = (SELECT id FROM dbo.LeaveTypes WHERE code=N'SICK');

DECLARE @alice INT = (SELECT id FROM dbo.Users WHERE username=N'alice');
DECLARE @carl  INT = (SELECT id FROM dbo.Users WHERE username=N'carl');
DECLARE @eva   INT = (SELECT id FROM dbo.Users WHERE username=N'eva');

-- INPROGRESS (chưa duyệt)
INSERT INTO dbo.Requests (
    employee_id, type_id, title, reason, start_date, end_date, status, created_by
) VALUES
(@alice, @ANNUAL, N'Nghỉ phép năm', N'Về quê',    '2025-10-20', '2025-10-22', N'INPROGRESS', @alice);

-- APPROVED (đã duyệt)
INSERT INTO dbo.Requests (
    employee_id, type_id, title, reason, start_date, end_date, status, manager_note, created_by, processed_by, processed_at
) VALUES
(@carl,  @SICK,   N'Nghỉ ốm',      N'Cảm cúm',    '2025-10-15', '2025-10-16', N'APPROVED',  N'Chúc mau khoẻ', @carl,  @bob,  SYSUTCDATETIME()),
(@eva,   @ANNUAL, N'Nghỉ phép năm', N'Việc gia đình','2025-10-25','2025-10-27',N'APPROVED', N'OK',            @eva,   @mike, SYSUTCDATETIME());

GO
