/* ================================================================
   PRJ301_Assignment Mink — Leave Management 
   CLEAN, RERUNNABLE, FULL SCHEMA
   ================================================================ */

-- ================================================================
-- 0) PRE-SETUP: Kiểm tra và Fix SQL Server Authentication
-- ================================================================
USE master;
GO

PRINT '=== Bước 0: Kiểm tra và Fix SQL Server Authentication ===';
GO

-- Enable sa login nếu chưa có
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'sa')
BEGIN
    PRINT 'Tạo login sa...';
    CREATE LOGIN sa WITH PASSWORD = '123';
    PRINT '✅ Login sa đã được tạo!';
END
ELSE
BEGIN
    PRINT '✅ Login sa đã tồn tại.';
END
GO

-- Enable sa login
ALTER LOGIN sa ENABLE;
GO

-- Set password cho sa (đảm bảo password = '123')
ALTER LOGIN sa WITH PASSWORD = '123';
GO

-- Cấp quyền sysadmin cho sa (nếu chưa có)
IF NOT EXISTS (
    SELECT 1 FROM sys.server_role_members 
    WHERE role_principal_id = (SELECT principal_id FROM sys.server_principals WHERE name = 'sysadmin')
    AND member_principal_id = (SELECT principal_id FROM sys.server_principals WHERE name = 'sa')
)
BEGIN
    ALTER SERVER ROLE sysadmin ADD MEMBER sa;
    PRINT '✅ Đã cấp quyền sysadmin cho sa.';
END
GO

-- ================================================================
-- 1) Tạo mới DB an toàn
-- ================================================================
PRINT '';
PRINT '=== Bước 1: Tạo Database ===';
GO

IF DB_ID('FALL25_Assignment') IS NOT NULL
BEGIN
    PRINT 'Database FALL25_Assignment đã tồn tại. Đang xóa database cũ...';
    ALTER DATABASE FALL25_Assignment SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE FALL25_Assignment;
    PRINT '✅ Database cũ đã được xóa.';
END
GO

PRINT 'Đang tạo database FALL25_Assignment...';
CREATE DATABASE FALL25_Assignment;
PRINT '✅ Database đã được tạo!';
GO

USE FALL25_Assignment;
GO

-- Cấp quyền cho sa trong database
PRINT 'Đang cấp quyền cho user sa trong database...';
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'sa')
BEGIN
    CREATE USER [sa] FROM LOGIN [sa];
    PRINT '✅ User sa đã được tạo trong database!';
END
GO

ALTER ROLE db_owner ADD MEMBER [sa];
PRINT '✅ Đã cấp quyền db_owner cho sa.';
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

PRINT '';
PRINT '=== Bắt đầu tạo Tables và Schema ===';
GO

/* ========== 1) Lookup: Departments, Roles, LeaveTypes ========== */
CREATE TABLE dbo.Departments (
    id    INT IDENTITY(1,1) PRIMARY KEY,
    name  NVARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE dbo.Roles (
    id    INT IDENTITY(1,1) PRIMARY KEY,
    code  NVARCHAR(30)  NOT NULL UNIQUE,   -- EMPLOYEE / MANAGER / LEADER / ADMIN
    name  NVARCHAR(100) NOT NULL
);

CREATE TABLE dbo.LeaveTypes (
    id                 INT IDENTITY(1,1) PRIMARY KEY,
    code               NVARCHAR(30)  NOT NULL UNIQUE,  -- ANNUAL / SICK / MARRIAGE / ...
    name               NVARCHAR(100) NOT NULL,
    requires_document  BIT NOT NULL DEFAULT (0)
);

/* ========== 2) Users (chuẩn hoá, có manager_id tự tham chiếu) ========== */
CREATE TABLE dbo.Users (
    id            INT IDENTITY(1,1) PRIMARY KEY,
    username      NVARCHAR(50)  NOT NULL UNIQUE,
    password_hash NVARCHAR(255) NOT NULL,          -- khuyến nghị hash
    full_name     NVARCHAR(120) NOT NULL,
    role_id       INT NOT NULL,
    department_id INT NOT NULL,
    manager_id    INT NULL,
    is_active     BIT NOT NULL DEFAULT (1),
    created_at    DATETIME2(0) NOT NULL DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT FK_Users_Role        FOREIGN KEY (role_id)       REFERENCES dbo.Roles(id),
    CONSTRAINT FK_Users_Department  FOREIGN KEY (department_id) REFERENCES dbo.Departments(id),
    CONSTRAINT FK_Users_Manager     FOREIGN KEY (manager_id)    REFERENCES dbo.Users(id)
);
CREATE INDEX IX_Users_Manager ON dbo.Users(manager_id);
CREATE INDEX IX_Users_Department ON dbo.Users(department_id);

/* ========== 3) Requests + History + Attachments ========== */
CREATE TABLE dbo.Requests (
    id             INT IDENTITY(1,1) PRIMARY KEY,
    employee_id    INT NOT NULL,
    type_id        INT NOT NULL,
    title          NVARCHAR(100) NOT NULL,
    reason         NVARCHAR(255) NOT NULL,
    start_date     DATE NOT NULL,
    end_date       DATE NOT NULL,
    status         NVARCHAR(20) NOT NULL DEFAULT (N'INPROGRESS')
        CONSTRAINT CK_Requests_Status CHECK (status IN (N'INPROGRESS', N'APPROVED', N'REJECTED')),
    manager_note   NVARCHAR(255) NULL,
    created_at     DATETIME2(0) NOT NULL DEFAULT (SYSUTCDATETIME()),
    created_by     INT NOT NULL,
    processed_at   DATETIME2(0) NULL,
    processed_by   INT NULL,
    -- Duration (ngày) (bao gồm cả 2 đầu)
    duration_days  AS (DATEDIFF(DAY, start_date, end_date) + 1) PERSISTED,
    CONSTRAINT FK_Requests_Employee   FOREIGN KEY (employee_id) REFERENCES dbo.Users(id),
    CONSTRAINT FK_Requests_Type       FOREIGN KEY (type_id)     REFERENCES dbo.LeaveTypes(id),
    CONSTRAINT FK_Requests_CreatedBy  FOREIGN KEY (created_by)  REFERENCES dbo.Users(id),
    CONSTRAINT FK_Requests_ProcessedBy FOREIGN KEY (processed_by) REFERENCES dbo.Users(id),
    CONSTRAINT CK_Requests_DateRange CHECK (start_date <= end_date)
);
CREATE INDEX IX_Requests_EmployeeStatus ON dbo.Requests(employee_id, status);
CREATE INDEX IX_Requests_DateRange     ON dbo.Requests(start_date, end_date);
CREATE INDEX IX_Requests_ProcessedBy   ON dbo.Requests(processed_by);

CREATE TABLE dbo.RequestHistory (
    id           INT IDENTITY(1,1) PRIMARY KEY,
    request_id   INT NOT NULL,
    old_status   NVARCHAR(20) NULL,
    new_status   NVARCHAR(20) NOT NULL,
    changed_by   INT NOT NULL,
    changed_at   DATETIME2(0) NOT NULL DEFAULT (SYSUTCDATETIME()),
    note         NVARCHAR(255) NULL,
    CONSTRAINT FK_History_Request  FOREIGN KEY (request_id) REFERENCES dbo.Requests(id),
    CONSTRAINT FK_History_ChangedBy FOREIGN KEY (changed_by) REFERENCES dbo.Users(id)
);
CREATE INDEX IX_History_Request ON dbo.RequestHistory(request_id);

CREATE TABLE dbo.Attachments (
    id           INT IDENTITY(1,1) PRIMARY KEY,
    request_id   INT NOT NULL,
    file_name    NVARCHAR(255) NOT NULL,
    file_path    NVARCHAR(500) NOT NULL,
    uploaded_by  INT NOT NULL,
    uploaded_at  DATETIME2(0) NOT NULL DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT FK_Attachments_Request  FOREIGN KEY (request_id) REFERENCES dbo.Requests(id),
    CONSTRAINT FK_Attachments_Uploaded FOREIGN KEY (uploaded_by) REFERENCES dbo.Users(id)
);
CREATE INDEX IX_Attachments_Request ON dbo.Attachments(request_id);

/* ========== 4) Notifications ========== */
CREATE TABLE dbo.Notifications (
    id           INT IDENTITY(1,1) PRIMARY KEY,
    user_id      INT NOT NULL,
    type         NVARCHAR(50) NOT NULL,  -- EMAIL, SMS, IN_APP
    title        NVARCHAR(200) NOT NULL,
    message      NVARCHAR(500) NOT NULL,
    related_type NVARCHAR(50) NULL,      -- REQUEST, APPROVAL, etc.
    related_id   INT NULL,
    is_read      BIT NOT NULL DEFAULT (0),
    created_at   DATETIME2(0) NOT NULL DEFAULT (SYSUTCDATETIME()),
    read_at      DATETIME2(0) NULL,
    CONSTRAINT FK_Notifications_User FOREIGN KEY (user_id) REFERENCES dbo.Users(id)
);
CREATE INDEX IX_Notifications_User   ON dbo.Notifications(user_id, is_read);
CREATE INDEX IX_Notifications_Created ON dbo.Notifications(created_at);

/* ========== 5) Leave Balances ========== */
CREATE TABLE dbo.LeaveBalances (
    id            INT IDENTITY(1,1) PRIMARY KEY,
    user_id       INT NOT NULL,
    leave_type_id INT NOT NULL,
    year          INT NOT NULL,
    total_days    INT NOT NULL DEFAULT (0),
    used_days     INT NOT NULL DEFAULT (0),
    remaining_days AS (total_days - used_days) PERSISTED,
    updated_at    DATETIME2(0) NOT NULL DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT FK_LeaveBalances_User      FOREIGN KEY (user_id)       REFERENCES dbo.Users(id),
    CONSTRAINT FK_LeaveBalances_LeaveType FOREIGN KEY (leave_type_id) REFERENCES dbo.LeaveTypes(id),
    CONSTRAINT UQ_LeaveBalance_UserTypeYear UNIQUE (user_id, leave_type_id, year)
);
CREATE INDEX IX_LeaveBalances_User ON dbo.LeaveBalances(user_id, year);

/* ========== 6) Multi-Tier Approval Workflow ========== */
CREATE TABLE dbo.ApprovalWorkflows (
    id           INT IDENTITY(1,1) PRIMARY KEY,
    request_id   INT NOT NULL,
    approver_id  INT NOT NULL,
    step_order   INT NOT NULL,  -- 1,2,3...
    status       NVARCHAR(20) NOT NULL DEFAULT (N'PENDING')
        CONSTRAINT CK_ApprovalWorkflow_Status CHECK (status IN (N'PENDING', N'APPROVED', N'REJECTED')),
    note         NVARCHAR(255) NULL,
    approved_at  DATETIME2(0) NULL,
    CONSTRAINT UQ_ApprovalWorkflow_RequestStep UNIQUE (request_id, step_order),
    CONSTRAINT FK_ApprovalWorkflow_Request  FOREIGN KEY (request_id)  REFERENCES dbo.Requests(id),
    CONSTRAINT FK_ApprovalWorkflow_Approver FOREIGN KEY (approver_id) REFERENCES dbo.Users(id)
);
CREATE INDEX IX_ApprovalWorkflows_Request  ON dbo.ApprovalWorkflows(request_id);
CREATE INDEX IX_ApprovalWorkflows_Approver ON dbo.ApprovalWorkflows(approver_id, status);

/* ========== 7) Delegation (Ủy quyền) ========== */
CREATE TABLE dbo.Delegations (
    id           INT IDENTITY(1,1) PRIMARY KEY,
    delegator_id INT NOT NULL,
    delegate_id  INT NOT NULL,
    start_date   DATE NOT NULL,
    end_date     DATE NOT NULL,
    is_active    BIT NOT NULL DEFAULT (1),
    created_at   DATETIME2(0) NOT NULL DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT CK_Delegations_DateRange CHECK (start_date <= end_date),
    CONSTRAINT FK_Delegations_Delegator FOREIGN KEY (delegator_id) REFERENCES dbo.Users(id),
    CONSTRAINT FK_Delegations_Delegate  FOREIGN KEY (delegate_id)  REFERENCES dbo.Users(id)
);
CREATE INDEX IX_Delegations_Delegate ON dbo.Delegations(delegate_id, is_active, start_date, end_date);

/* ========== 8) Audit Logs ========== */
CREATE TABLE dbo.AuditLogs (
    id           INT IDENTITY(1,1) PRIMARY KEY,
    user_id      INT NULL,
    action       NVARCHAR(100) NOT NULL,  -- CREATE, UPDATE, DELETE, APPROVE, REJECT, LOGIN, etc.
    entity_type  NVARCHAR(50) NOT NULL,   -- REQUEST, USER, LEAVE_BALANCE, etc.
    entity_id    INT NULL,
    old_values   NVARCHAR(MAX) NULL,      -- JSON string
    new_values   NVARCHAR(MAX) NULL,      -- JSON string
    ip_address   NVARCHAR(45) NULL,
    user_agent   NVARCHAR(500) NULL,
    created_at   DATETIME2(0) NOT NULL DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT FK_AuditLogs_User FOREIGN KEY (user_id) REFERENCES dbo.Users(id)
);
CREATE INDEX IX_AuditLogs_User   ON dbo.AuditLogs(user_id, created_at);
CREATE INDEX IX_AuditLogs_Entity ON dbo.AuditLogs(entity_type, entity_id);
CREATE INDEX IX_AuditLogs_Created ON dbo.AuditLogs(created_at);

/* ========== 9) Conflict Detection ========== */
CREATE TABLE dbo.ConflictAlerts (
    id                     INT IDENTITY(1,1) PRIMARY KEY,
    request_id             INT NOT NULL,
    conflict_type          NVARCHAR(50) NOT NULL,  -- OVERLAP, DEPARTMENT_SHORTAGE, ...
    conflicting_request_id INT NULL,
    department_id          INT NULL,
    message                NVARCHAR(500) NOT NULL,
    severity               NVARCHAR(20) NOT NULL DEFAULT (N'MEDIUM')
        CONSTRAINT CK_ConflictAlerts_Severity CHECK (severity IN (N'LOW', N'MEDIUM', N'HIGH', N'CRITICAL')),
    is_resolved            BIT NOT NULL DEFAULT (0),
    created_at             DATETIME2(0) NOT NULL DEFAULT (SYSUTCDATETIME()),
    resolved_at            DATETIME2(0) NULL,
    CONSTRAINT FK_ConflictAlerts_Request      FOREIGN KEY (request_id)             REFERENCES dbo.Requests(id),
    CONSTRAINT FK_ConflictAlerts_Conflicting FOREIGN KEY (conflicting_request_id) REFERENCES dbo.Requests(id),
    CONSTRAINT FK_ConflictAlerts_Department   FOREIGN KEY (department_id)          REFERENCES dbo.Departments(id)
);
CREATE INDEX IX_ConflictAlerts_Request ON dbo.ConflictAlerts(request_id, is_resolved);

/* ========== 10) Leave Policies ========== */
CREATE TABLE dbo.LeavePolicies (
    id                     INT IDENTITY(1,1) PRIMARY KEY,
    department_id          INT NULL,  -- NULL = áp dụng toàn công ty
    leave_type_id          INT NOT NULL,
    max_days_per_year      INT NOT NULL,
    min_days_per_request   INT NOT NULL DEFAULT (1),
    max_days_per_request   INT NULL,
    requires_advance_notice INT NULL,  -- Số ngày cần thông báo trước
    auto_approve_conditions NVARCHAR(MAX) NULL,  -- JSON string
    is_active              BIT NOT NULL DEFAULT (1),
    created_at             DATETIME2(0) NOT NULL DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT FK_LeavePolicies_Department FOREIGN KEY (department_id) REFERENCES dbo.Departments(id),
    CONSTRAINT FK_LeavePolicies_LeaveType  FOREIGN KEY (leave_type_id) REFERENCES dbo.LeaveTypes(id)
);
CREATE INDEX IX_LeavePolicies_Department ON dbo.LeavePolicies(department_id, leave_type_id);

/* ========== 11) User Settings ========== */
CREATE TABLE dbo.UserSettings (
    id                  INT IDENTITY(1,1) PRIMARY KEY,
    user_id             INT NOT NULL UNIQUE,
    email               NVARCHAR(255) NULL,
    phone               NVARCHAR(20) NULL,
    email_notifications BIT NOT NULL DEFAULT (1),
    sms_notifications   BIT NOT NULL DEFAULT (0),
    in_app_notifications BIT NOT NULL DEFAULT (1),
    language            NVARCHAR(10) NOT NULL DEFAULT (N'vi'),
    theme               NVARCHAR(20) NOT NULL DEFAULT (N'light'),
    updated_at          DATETIME2(0) NOT NULL DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT FK_UserSettings_User FOREIGN KEY (user_id) REFERENCES dbo.Users(id)
);
CREATE INDEX IX_UserSettings_User ON dbo.UserSettings(user_id);

GO

/* ========== 15) Password Reset Requests ========== */
IF OBJECT_ID('dbo.PasswordResetRequests', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.PasswordResetRequests (
        id INT IDENTITY(1,1) PRIMARY KEY,
        user_id INT NULL,
        note NVARCHAR(1000) NULL,
        status TINYINT NOT NULL DEFAULT (0), -- 0: pending, 1: processed, 2: rejected
        processed_by INT NULL,
        created_at DATETIME2(0) NOT NULL DEFAULT (SYSUTCDATETIME()),
        processed_at DATETIME2(0) NULL,
        CONSTRAINT FK_PasswordReset_User FOREIGN KEY (user_id) REFERENCES dbo.Users(id),
        CONSTRAINT FK_PasswordReset_ProcessedBy FOREIGN KEY (processed_by) REFERENCES dbo.Users(id)
    );
    CREATE INDEX IX_PasswordResetRequests_User ON dbo.PasswordResetRequests(user_id);
END
GO

/* ========== 12) Trigger: ghi lịch sử khi đổi trạng thái ========== */
CREATE OR ALTER TRIGGER dbo.tr_Requests_StatusHistory
ON dbo.Requests
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.RequestHistory (request_id, old_status, new_status, changed_by, note, changed_at)
    SELECT
        i.id,
        d.status,
        i.status,
        ISNULL(i.processed_by, i.created_by),
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

/* ========== 13) Views phục vụ Dashboard/Agenda ========== */
CREATE OR ALTER VIEW dbo.vw_Agenda
AS
SELECT 
    u.id            AS user_id,
    u.full_name,
    d.name          AS department,
    r.id            AS request_id,
    r.status,
    DATEADD(DAY, v.number, r.start_date) AS work_date
FROM dbo.Users u
JOIN dbo.Departments d ON d.id = u.department_id
JOIN dbo.Requests   r ON r.employee_id = u.id AND r.status = N'APPROVED'
JOIN master..spt_values v ON v.type = 'P'
WHERE DATEADD(DAY, v.number, r.start_date) <= r.end_date;
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
GO

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

/* ========== 14) SEED dữ liệu ========== */
-- Departments
INSERT INTO dbo.Departments(name) VALUES (N'IT'), (N'QA');

-- Roles
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

-- Users
DECLARE @IT INT = (SELECT id FROM dbo.Departments WHERE name=N'IT');
DECLARE @QA INT = (SELECT id FROM dbo.Departments WHERE name=N'QA');
DECLARE @EMP INT = (SELECT id FROM dbo.Roles WHERE code=N'EMPLOYEE');
DECLARE @MAN INT = (SELECT id FROM dbo.Roles WHERE code=N'MANAGER');
DECLARE @LEA INT = (SELECT id FROM dbo.Roles WHERE code=N'LEADER');
DECLARE @ADM INT = (SELECT id FROM dbo.Roles WHERE code=N'ADMIN');

-- Tạo manager trước
INSERT INTO dbo.Users(username,password_hash,full_name,role_id,department_id,manager_id)
VALUES
(N'bob',  N'123', N'Bob Tran',  @MAN, @IT, NULL),
(N'mike', N'123', N'Mike Le',   @MAN, @QA, NULL);

DECLARE @bob  INT = (SELECT id FROM dbo.Users WHERE username=N'bob');
DECLARE @mike INT = (SELECT id FROM dbo.Users WHERE username=N'mike');

-- Admin
INSERT INTO dbo.Users(username,password_hash,full_name,role_id,department_id,manager_id)
VALUES (N'admin', N'123', N'Admin User', @ADM, @IT, NULL);

-- Nhân viên/Leader
INSERT INTO dbo.Users(username,password_hash,full_name,role_id,department_id,manager_id)
VALUES
(N'alice', N'123', N'Alice Nguyen', @EMP, @IT,  @bob),
(N'carl',  N'123', N'Carl Pham',    @LEA, @IT,  @bob),
(N'eva',   N'123', N'Eva Do',       @EMP, @QA,  @mike);

-- Leave Balances (2025)
INSERT INTO dbo.LeaveBalances(user_id, leave_type_id, year, total_days, used_days)
SELECT u.id, lt.id, 2025,
    CASE lt.code WHEN N'ANNUAL' THEN 12 WHEN N'SICK' THEN 5 ELSE 3 END,
    0
FROM dbo.Users u
CROSS JOIN dbo.LeaveTypes lt
WHERE u.username IN (N'alice', N'carl', N'eva', N'bob', N'mike');

-- User Settings
INSERT INTO dbo.UserSettings(user_id, email, phone, email_notifications, sms_notifications, in_app_notifications)
SELECT id, username + '@company.com', N'+84901234567', 1, 0, 1
FROM dbo.Users;

-- Leave Policies
INSERT INTO dbo.LeavePolicies(department_id, leave_type_id, max_days_per_year, min_days_per_request, max_days_per_request, requires_advance_notice)
SELECT NULL, lt.id,
    CASE lt.code WHEN N'ANNUAL' THEN 12 WHEN N'SICK' THEN 5 ELSE 3 END,
    1, 5, 3
FROM dbo.LeaveTypes lt;

-- Requests
DECLARE @ANNUAL INT = (SELECT id FROM dbo.LeaveTypes WHERE code=N'ANNUAL');
DECLARE @SICK   INT = (SELECT id FROM dbo.LeaveTypes WHERE code=N'SICK');
DECLARE @alice INT = (SELECT id FROM dbo.Users WHERE username=N'alice');
DECLARE @carl  INT = (SELECT id FROM dbo.Users WHERE username=N'carl');
DECLARE @eva   INT = (SELECT id FROM dbo.Users WHERE username=N'eva');

INSERT INTO dbo.Requests (
    employee_id, type_id, title, reason, start_date, end_date, status, created_by
) VALUES
(@alice, @ANNUAL, N'Nghỉ phép năm', N'Về quê', '2025-10-20', '2025-10-22', N'INPROGRESS', @alice);

INSERT INTO dbo.Requests (
    employee_id, type_id, title, reason, start_date, end_date, status, manager_note, created_by, processed_by, processed_at
) VALUES
(@carl,  @SICK,   N'Nghỉ ốm',      N'Cảm cúm', '2025-10-15', '2025-10-16', N'APPROVED', N'Chúc mau khoẻ', @carl,  @bob,  SYSUTCDATETIME()),
(@eva,   @ANNUAL, N'Nghỉ phép năm', N'Việc gia đình', '2025-10-25','2025-10-27', N'APPROVED', N'OK', @eva, @mike, SYSUTCDATETIME());

PRINT '';
PRINT '=== Bước cuối: Kiểm tra kết quả ===';
GO

-- Kiểm tra số lượng records
DECLARE @userCount INT = (SELECT COUNT(*) FROM dbo.Users);
DECLARE @deptCount INT = (SELECT COUNT(*) FROM dbo.Departments);
DECLARE @roleCount INT = (SELECT COUNT(*) FROM dbo.Roles);
DECLARE @leaveTypeCount INT = (SELECT COUNT(*) FROM dbo.LeaveTypes);
DECLARE @requestCount INT = (SELECT COUNT(*) FROM dbo.Requests);
DECLARE @balanceCount INT = (SELECT COUNT(*) FROM dbo.LeaveBalances);

PRINT '';
PRINT '📊 Thống kê dữ liệu đã tạo:';
PRINT '  - Departments: ' + CAST(@deptCount AS NVARCHAR(10));
PRINT '  - Roles: ' + CAST(@roleCount AS NVARCHAR(10));
PRINT '  - Leave Types: ' + CAST(@leaveTypeCount AS NVARCHAR(10));
PRINT '  - Users: ' + CAST(@userCount AS NVARCHAR(10));
PRINT '  - Requests: ' + CAST(@requestCount AS NVARCHAR(10));
PRINT '  - Leave Balances: ' + CAST(@balanceCount AS NVARCHAR(10));
PRINT '';

-- Test kết nối
SELECT 
    DB_NAME() as CurrentDatabase,
    USER_NAME() as CurrentUser,
    @@SERVERNAME as ServerName;
GO

PRINT '';
PRINT '✅✅✅ Database FALL25_Assignment đã được tạo và seed dữ liệu thành công! ✅✅✅';
PRINT '';
PRINT '📝 Tài khoản đăng nhập:';
PRINT '  - Admin: admin / 123';
PRINT '  - Manager: bob / 123 hoặc mike / 123';
PRINT '  - Leader: carl / 123';
PRINT '  - Employee: alice / 123 hoặc eva / 123';
PRINT '';
PRINT '🎉 Bạn có thể bắt đầu sử dụng hệ thống!';
GO
