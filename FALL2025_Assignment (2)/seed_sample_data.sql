/* ================================================================
   SEED SAMPLE DATA - Leave Management System
   Tạo dữ liệu mẫu đầy đủ cho từng tài khoản
   ================================================================ */

USE FALL25_Assignment;
GO

PRINT '=== Bắt đầu tạo dữ liệu mẫu ===';
GO

-- Lấy các ID cần thiết
DECLARE @ANNUAL INT = (SELECT id FROM dbo.LeaveTypes WHERE code = N'ANNUAL');
DECLARE @SICK   INT = (SELECT id FROM dbo.LeaveTypes WHERE code = N'SICK');
DECLARE @WEDDING INT = (SELECT id FROM dbo.LeaveTypes WHERE code = N'WEDDING');
DECLARE @MATERNITY INT = (SELECT id FROM dbo.LeaveTypes WHERE code = N'MATERNITY');

DECLARE @admin INT = (SELECT id FROM dbo.Users WHERE username = N'admin');
DECLARE @bob   INT = (SELECT id FROM dbo.Users WHERE username = N'bob');
DECLARE @mike  INT = (SELECT id FROM dbo.Users WHERE username = N'mike');
DECLARE @carl  INT = (SELECT id FROM dbo.Users WHERE username = N'carl');
DECLARE @alice INT = (SELECT id FROM dbo.Users WHERE username = N'alice');
DECLARE @eva   INT = (SELECT id FROM dbo.Users WHERE username = N'eva');

-- Xóa dữ liệu cũ (nếu có)
DELETE FROM dbo.RequestHistory;
DELETE FROM dbo.Requests;
PRINT '✅ Đã xóa dữ liệu cũ';
GO

-- ================================================================
-- 1. ĐƠN CỦA ALICE (Employee - cấp dưới của bob)
-- ================================================================
DECLARE @ANNUAL INT = (SELECT id FROM dbo.LeaveTypes WHERE code = N'ANNUAL');
DECLARE @SICK   INT = (SELECT id FROM dbo.LeaveTypes WHERE code = N'SICK');
DECLARE @WEDDING INT = (SELECT id FROM dbo.LeaveTypes WHERE code = N'WEDDING');
DECLARE @admin INT = (SELECT id FROM dbo.Users WHERE username = N'admin');
DECLARE @bob   INT = (SELECT id FROM dbo.Users WHERE username = N'bob');
DECLARE @mike  INT = (SELECT id FROM dbo.Users WHERE username = N'mike');
DECLARE @carl  INT = (SELECT id FROM dbo.Users WHERE username = N'carl');
DECLARE @alice INT = (SELECT id FROM dbo.Users WHERE username = N'alice');
DECLARE @eva   INT = (SELECT id FROM dbo.Users WHERE username = N'eva');

-- Alice: Đơn chờ duyệt (INPROGRESS)
INSERT INTO dbo.Requests (employee_id, type_id, title, reason, start_date, end_date, status, created_by)
VALUES 
(@alice, @ANNUAL, N'Nghỉ phép năm', N'Về quê thăm gia đình', '2025-12-20', '2025-12-22', N'INPROGRESS', @alice),
(@alice, @SICK, N'Nghỉ ốm', N'Cảm cúm, sốt cao', '2025-12-10', '2025-12-11', N'INPROGRESS', @alice),
(@alice, @ANNUAL, N'Nghỉ phép cuối năm', N'Du lịch cùng gia đình', '2025-12-28', '2025-12-31', N'INPROGRESS', @alice);

-- Alice: Đơn đã được duyệt (APPROVED)
INSERT INTO dbo.Requests (employee_id, type_id, title, reason, start_date, end_date, status, created_by, processed_by, processed_at, manager_note)
VALUES 
(@alice, @ANNUAL, N'Nghỉ phép năm', N'Về quê ăn Tết', '2025-11-15', '2025-11-17', N'APPROVED', @alice, @admin, DATEADD(DAY, -30, GETDATE()), N'Đã duyệt, chúc vui vẻ'),
(@alice, @SICK, N'Nghỉ ốm', N'Đau đầu, mệt mỏi', '2025-11-05', '2025-11-05', N'APPROVED', @alice, @admin, DATEADD(DAY, -25, GETDATE()), N'Chúc mau khỏe'),
(@alice, @ANNUAL, N'Nghỉ phép', N'Việc gia đình', '2025-10-20', '2025-10-22', N'APPROVED', @alice, @admin, DATEADD(DAY, -40, GETDATE()), N'OK');

-- Alice: Đơn bị từ chối (REJECTED)
INSERT INTO dbo.Requests (employee_id, type_id, title, reason, start_date, end_date, status, created_by, processed_by, processed_at, manager_note)
VALUES 
(@alice, @ANNUAL, N'Nghỉ phép', N'Du lịch', '2025-12-15', '2025-12-20', N'REJECTED', @alice, @admin, DATEADD(DAY, -10, GETDATE()), N'Thời gian này quá bận, vui lòng chọn thời gian khác');

PRINT '✅ Đã tạo 7 đơn nghỉ phép cho Alice';
GO

-- ================================================================
-- 2. ĐƠN CỦA EVA (Employee - cấp dưới của mike)
-- ================================================================
DECLARE @ANNUAL INT = (SELECT id FROM dbo.LeaveTypes WHERE code = N'ANNUAL');
DECLARE @SICK   INT = (SELECT id FROM dbo.LeaveTypes WHERE code = N'SICK');
DECLARE @WEDDING INT = (SELECT id FROM dbo.LeaveTypes WHERE code = N'WEDDING');
DECLARE @admin INT = (SELECT id FROM dbo.Users WHERE username = N'admin');
DECLARE @bob   INT = (SELECT id FROM dbo.Users WHERE username = N'bob');
DECLARE @mike  INT = (SELECT id FROM dbo.Users WHERE username = N'mike');
DECLARE @carl  INT = (SELECT id FROM dbo.Users WHERE username = N'carl');
DECLARE @alice INT = (SELECT id FROM dbo.Users WHERE username = N'alice');
DECLARE @eva   INT = (SELECT id FROM dbo.Users WHERE username = N'eva');

-- Eva: Đơn chờ duyệt
INSERT INTO dbo.Requests (employee_id, type_id, title, reason, start_date, end_date, status, created_by)
VALUES 
(@eva, @ANNUAL, N'Nghỉ phép năm', N'Đi du lịch', '2025-12-25', '2025-12-27', N'INPROGRESS', @eva),
(@eva, @SICK, N'Nghỉ ốm', N'Đau bụng', '2025-12-12', '2025-12-12', N'INPROGRESS', @eva);

-- Eva: Đơn đã được duyệt
INSERT INTO dbo.Requests (employee_id, type_id, title, reason, start_date, end_date, status, created_by, processed_by, processed_at, manager_note)
VALUES 
(@eva, @ANNUAL, N'Nghỉ phép năm', N'Việc gia đình', '2025-11-20', '2025-11-22', N'APPROVED', @eva, @admin, DATEADD(DAY, -20, GETDATE()), N'Đã duyệt'),
(@eva, @WEDDING, N'Nghỉ cưới', N'Đám cưới em gái', '2025-10-25', '2025-10-27', N'APPROVED', @eva, @admin, DATEADD(DAY, -45, GETDATE()), N'Chúc mừng');

-- Eva: Đơn bị từ chối
INSERT INTO dbo.Requests (employee_id, type_id, title, reason, start_date, end_date, status, created_by, processed_by, processed_at, manager_note)
VALUES 
(@eva, @ANNUAL, N'Nghỉ phép', N'Du lịch dài ngày', '2025-12-01', '2025-12-10', N'REJECTED', @eva, @admin, DATEADD(DAY, -5, GETDATE()), N'Thời gian nghỉ quá dài, không phù hợp');

PRINT '✅ Đã tạo 5 đơn nghỉ phép cho Eva';
GO

-- ================================================================
-- 3. ĐƠN CỦA CARL (Leader - cấp dưới của bob)
-- ================================================================
DECLARE @ANNUAL INT = (SELECT id FROM dbo.LeaveTypes WHERE code = N'ANNUAL');
DECLARE @SICK   INT = (SELECT id FROM dbo.LeaveTypes WHERE code = N'SICK');
DECLARE @admin INT = (SELECT id FROM dbo.Users WHERE username = N'admin');
DECLARE @bob   INT = (SELECT id FROM dbo.Users WHERE username = N'bob');
DECLARE @mike  INT = (SELECT id FROM dbo.Users WHERE username = N'mike');
DECLARE @carl  INT = (SELECT id FROM dbo.Users WHERE username = N'carl');
DECLARE @alice INT = (SELECT id FROM dbo.Users WHERE username = N'alice');
DECLARE @eva   INT = (SELECT id FROM dbo.Users WHERE username = N'eva');

-- Carl: Đơn chờ duyệt
INSERT INTO dbo.Requests (employee_id, type_id, title, reason, start_date, end_date, status, created_by)
VALUES 
(@carl, @ANNUAL, N'Nghỉ phép năm', N'Về quê', '2025-12-18', '2025-12-20', N'INPROGRESS', @carl),
(@carl, @SICK, N'Nghỉ ốm', N'Cảm cúm', '2025-12-08', '2025-12-09', N'INPROGRESS', @carl);

-- Carl: Đơn đã được duyệt
INSERT INTO dbo.Requests (employee_id, type_id, title, reason, start_date, end_date, status, created_by, processed_by, processed_at, manager_note)
VALUES 
(@carl, @SICK, N'Nghỉ ốm', N'Cảm cúm', '2025-11-15', '2025-11-16', N'APPROVED', @carl, @admin, DATEADD(DAY, -30, GETDATE()), N'Chúc mau khỏe'),
(@carl, @ANNUAL, N'Nghỉ phép năm', N'Việc gia đình', '2025-10-15', '2025-10-16', N'APPROVED', @carl, @admin, DATEADD(DAY, -50, GETDATE()), N'OK');

PRINT '✅ Đã tạo 4 đơn nghỉ phép cho Carl';
GO

-- ================================================================
-- 4. ĐƠN CỦA BOB (Manager)
-- ================================================================
DECLARE @ANNUAL INT = (SELECT id FROM dbo.LeaveTypes WHERE code = N'ANNUAL');
DECLARE @SICK   INT = (SELECT id FROM dbo.LeaveTypes WHERE code = N'SICK');
DECLARE @admin INT = (SELECT id FROM dbo.Users WHERE username = N'admin');
DECLARE @bob   INT = (SELECT id FROM dbo.Users WHERE username = N'bob');
DECLARE @mike  INT = (SELECT id FROM dbo.Users WHERE username = N'mike');
DECLARE @carl  INT = (SELECT id FROM dbo.Users WHERE username = N'carl');
DECLARE @alice INT = (SELECT id FROM dbo.Users WHERE username = N'alice');
DECLARE @eva   INT = (SELECT id FROM dbo.Users WHERE username = N'eva');

-- Bob: Đơn chờ duyệt
INSERT INTO dbo.Requests (employee_id, type_id, title, reason, start_date, end_date, status, created_by)
VALUES 
(@bob, @ANNUAL, N'Nghỉ phép năm', N'Du lịch cùng gia đình', '2025-12-30', '2026-01-02', N'INPROGRESS', @bob),
(@bob, @SICK, N'Nghỉ ốm', N'Đau đầu', '2025-12-15', '2025-12-15', N'INPROGRESS', @bob);

-- Bob: Đơn đã được duyệt
INSERT INTO dbo.Requests (employee_id, type_id, title, reason, start_date, end_date, status, created_by, processed_by, processed_at, manager_note)
VALUES 
(@bob, @ANNUAL, N'Nghỉ phép năm', N'Về quê', '2025-11-10', '2025-11-12', N'APPROVED', @bob, @admin, DATEADD(DAY, -35, GETDATE()), N'Đã duyệt');

PRINT '✅ Đã tạo 3 đơn nghỉ phép cho Bob';
GO

-- ================================================================
-- 5. ĐƠN CỦA MIKE (Manager)
-- ================================================================
DECLARE @ANNUAL INT = (SELECT id FROM dbo.LeaveTypes WHERE code = N'ANNUAL');
DECLARE @SICK   INT = (SELECT id FROM dbo.LeaveTypes WHERE code = N'SICK');
DECLARE @admin INT = (SELECT id FROM dbo.Users WHERE username = N'admin');
DECLARE @bob   INT = (SELECT id FROM dbo.Users WHERE username = N'bob');
DECLARE @mike  INT = (SELECT id FROM dbo.Users WHERE username = N'mike');
DECLARE @carl  INT = (SELECT id FROM dbo.Users WHERE username = N'carl');
DECLARE @alice INT = (SELECT id FROM dbo.Users WHERE username = N'alice');
DECLARE @eva   INT = (SELECT id FROM dbo.Users WHERE username = N'eva');

-- Mike: Đơn chờ duyệt
INSERT INTO dbo.Requests (employee_id, type_id, title, reason, start_date, end_date, status, created_by)
VALUES 
(@mike, @ANNUAL, N'Nghỉ phép năm', N'Việc gia đình', '2025-12-22', '2025-12-24', N'INPROGRESS', @mike);

-- Mike: Đơn đã được duyệt
INSERT INTO dbo.Requests (employee_id, type_id, title, reason, start_date, end_date, status, created_by, processed_by, processed_at, manager_note)
VALUES 
(@mike, @SICK, N'Nghỉ ốm', N'Cảm cúm', '2025-11-08', '2025-11-09', N'APPROVED', @mike, @admin, DATEADD(DAY, -28, GETDATE()), N'Chúc mau khỏe');

PRINT '✅ Đã tạo 2 đơn nghỉ phép cho Mike';
GO

-- ================================================================
-- 6. ĐƠN CỦA ADMIN
-- ================================================================
DECLARE @ANNUAL INT = (SELECT id FROM dbo.LeaveTypes WHERE code = N'ANNUAL');
DECLARE @SICK   INT = (SELECT id FROM dbo.LeaveTypes WHERE code = N'SICK');
DECLARE @admin INT = (SELECT id FROM dbo.Users WHERE username = N'admin');
DECLARE @bob   INT = (SELECT id FROM dbo.Users WHERE username = N'bob');
DECLARE @mike  INT = (SELECT id FROM dbo.Users WHERE username = N'mike');
DECLARE @carl  INT = (SELECT id FROM dbo.Users WHERE username = N'carl');
DECLARE @alice INT = (SELECT id FROM dbo.Users WHERE username = N'alice');
DECLARE @eva   INT = (SELECT id FROM dbo.Users WHERE username = N'eva');

-- Admin: Đơn chờ duyệt (admin tự duyệt được)
INSERT INTO dbo.Requests (employee_id, type_id, title, reason, start_date, end_date, status, created_by)
VALUES 
(@admin, @ANNUAL, N'Nghỉ phép năm', N'Du lịch', '2025-12-26', '2025-12-28', N'INPROGRESS', @admin);

-- Admin: Đơn đã được duyệt (admin tự duyệt)
INSERT INTO dbo.Requests (employee_id, type_id, title, reason, start_date, end_date, status, created_by, processed_by, processed_at, manager_note)
VALUES 
(@admin, @ANNUAL, N'Nghỉ phép năm', N'Về quê', '2025-11-25', '2025-11-27', N'APPROVED', @admin, @admin, DATEADD(DAY, -15, GETDATE()), N'Tự duyệt');

PRINT '✅ Đã tạo 2 đơn nghỉ phép cho Admin';
GO

-- ================================================================
-- 7. TẠO NOTIFICATIONS
-- ================================================================
DECLARE @admin INT = (SELECT id FROM dbo.Users WHERE username = N'admin');
DECLARE @bob   INT = (SELECT id FROM dbo.Users WHERE username = N'bob');
DECLARE @mike  INT = (SELECT id FROM dbo.Users WHERE username = N'mike');
DECLARE @carl  INT = (SELECT id FROM dbo.Users WHERE username = N'carl');
DECLARE @alice INT = (SELECT id FROM dbo.Users WHERE username = N'alice');
DECLARE @eva   INT = (SELECT id FROM dbo.Users WHERE username = N'eva');

-- Notifications cho admin về đơn chờ duyệt
INSERT INTO dbo.Notifications (user_id, type, title, message, related_type, related_id, is_read)
SELECT @admin, N'IN_APP', N'Đơn nghỉ phép mới', 
       N'Có ' + CAST(COUNT(*) AS NVARCHAR(10)) + N' đơn nghỉ phép đang chờ duyệt',
       N'REQUEST', NULL, 0
FROM dbo.Requests 
WHERE status = N'INPROGRESS';

-- Notifications cho managers về đơn của cấp dưới
INSERT INTO dbo.Notifications (user_id, type, title, message, related_type, related_id, is_read)
SELECT @bob, N'IN_APP', N'Đơn nghỉ phép mới từ cấp dưới',
       N'Alice và Carl có đơn nghỉ phép mới cần xem',
       N'REQUEST', NULL, 0;

INSERT INTO dbo.Notifications (user_id, type, title, message, related_type, related_id, is_read)
SELECT @mike, N'IN_APP', N'Đơn nghỉ phép mới từ cấp dưới',
       N'Eva có đơn nghỉ phép mới cần xem',
       N'REQUEST', NULL, 0;

-- Notifications cho employees về đơn đã được duyệt/từ chối
INSERT INTO dbo.Notifications (user_id, type, title, message, related_type, related_id, is_read)
SELECT @alice, N'IN_APP', N'Đơn nghỉ phép đã được duyệt',
       N'Đơn nghỉ phép của bạn đã được duyệt',
       N'REQUEST', id, 0
FROM dbo.Requests 
WHERE employee_id = @alice AND status = N'APPROVED' AND processed_at > DATEADD(DAY, -7, GETDATE());

INSERT INTO dbo.Notifications (user_id, type, title, message, related_type, related_id, is_read)
SELECT @eva, N'IN_APP', N'Đơn nghỉ phép đã được duyệt',
       N'Đơn nghỉ phép của bạn đã được duyệt',
       N'REQUEST', id, 0
FROM dbo.Requests 
WHERE employee_id = @eva AND status = N'APPROVED' AND processed_at > DATEADD(DAY, -7, GETDATE());

PRINT '✅ Đã tạo notifications';
GO

-- ================================================================
-- 8. CẬP NHẬT LEAVE BALANCES (sử dụng số ngày đã nghỉ)
-- ================================================================
DECLARE @ANNUAL INT = (SELECT id FROM dbo.LeaveTypes WHERE code = N'ANNUAL');
DECLARE @SICK   INT = (SELECT id FROM dbo.LeaveTypes WHERE code = N'SICK');

-- Cập nhật used_days dựa trên các đơn đã được duyệt
UPDATE lb
SET lb.used_days = (
    SELECT ISNULL(SUM(r.duration_days), 0)
    FROM dbo.Requests r
    WHERE r.employee_id = lb.user_id
      AND r.type_id = lb.leave_type_id
      AND r.status = N'APPROVED'
      AND YEAR(r.start_date) = lb.year
)
FROM dbo.LeaveBalances lb;

PRINT '✅ Đã cập nhật Leave Balances';
GO

-- ================================================================
-- 9. TẠO AUDIT LOGS
-- ================================================================
DECLARE @admin INT = (SELECT id FROM dbo.Users WHERE username = N'admin');
DECLARE @bob   INT = (SELECT id FROM dbo.Users WHERE username = N'bob');
DECLARE @mike  INT = (SELECT id FROM dbo.Users WHERE username = N'mike');
DECLARE @carl  INT = (SELECT id FROM dbo.Users WHERE username = N'carl');
DECLARE @alice INT = (SELECT id FROM dbo.Users WHERE username = N'alice');
DECLARE @eva   INT = (SELECT id FROM dbo.Users WHERE username = N'eva');

-- Audit logs cho việc tạo đơn
INSERT INTO dbo.AuditLogs (user_id, action, entity_type, entity_id, old_values, new_values, created_at)
SELECT created_by, N'CREATE', N'REQUEST', id, 
       NULL, 
       N'{"status":"INPROGRESS","start_date":"' + CAST(start_date AS NVARCHAR(10)) + '","end_date":"' + CAST(end_date AS NVARCHAR(10)) + '"}',
       created_at
FROM dbo.Requests
WHERE status = N'INPROGRESS';

-- Audit logs cho việc duyệt/từ chối đơn
INSERT INTO dbo.AuditLogs (user_id, action, entity_type, entity_id, old_values, new_values, created_at)
SELECT processed_by, N'APPROVE_REJECT', N'REQUEST', id,
       N'{"status":"INPROGRESS"}',
       N'{"status":"' + status + '","note":"' + ISNULL(manager_note, '') + '"}',
       processed_at
FROM dbo.Requests
WHERE processed_by IS NOT NULL;

PRINT '✅ Đã tạo Audit Logs';
GO

-- ================================================================
-- 10. THỐNG KÊ
-- ================================================================
PRINT '';
PRINT '=== Thống kê dữ liệu đã tạo ===';
GO

SELECT 
    'Tổng số đơn nghỉ phép' AS Metric,
    COUNT(*) AS Count
FROM dbo.Requests
UNION ALL
SELECT 
    'Đơn chờ duyệt (INPROGRESS)',
    COUNT(*)
FROM dbo.Requests
WHERE status = N'INPROGRESS'
UNION ALL
SELECT 
    'Đơn đã duyệt (APPROVED)',
    COUNT(*)
FROM dbo.Requests
WHERE status = N'APPROVED'
UNION ALL
SELECT 
    'Đơn bị từ chối (REJECTED)',
    COUNT(*)
FROM dbo.Requests
WHERE status = N'REJECTED'
UNION ALL
SELECT 
    'Tổng số notifications',
    COUNT(*)
FROM dbo.Notifications
UNION ALL
SELECT 
    'Notifications chưa đọc',
    COUNT(*)
FROM dbo.Notifications
WHERE is_read = 0;

PRINT '';
PRINT '=== Chi tiết đơn theo user ===';
GO

SELECT 
    u.username,
    u.full_name,
    r.status,
    COUNT(*) AS so_don
FROM dbo.Requests r
JOIN dbo.Users u ON u.id = r.employee_id
GROUP BY u.username, u.full_name, r.status
ORDER BY u.username, r.status;

PRINT '';
PRINT '✅✅✅ Đã tạo dữ liệu mẫu thành công! ✅✅✅';
PRINT '';
PRINT '📊 Tổng kết:';
PRINT '  - Alice (Employee): 7 đơn (3 chờ duyệt, 3 đã duyệt, 1 từ chối)';
PRINT '  - Eva (Employee): 5 đơn (2 chờ duyệt, 2 đã duyệt, 1 từ chối)';
PRINT '  - Carl (Leader): 4 đơn (2 chờ duyệt, 2 đã duyệt)';
PRINT '  - Bob (Manager): 3 đơn (2 chờ duyệt, 1 đã duyệt)';
PRINT '  - Mike (Manager): 2 đơn (1 chờ duyệt, 1 đã duyệt)';
PRINT '  - Admin: 2 đơn (1 chờ duyệt, 1 đã duyệt)';
PRINT '';
PRINT '🎯 Bây giờ bạn có thể test đầy đủ các tính năng!';
GO

