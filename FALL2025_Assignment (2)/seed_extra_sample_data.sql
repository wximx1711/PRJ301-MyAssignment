USE FALL25_Assignment;
GO

PRINT '=== seed_extra_sample_data.sql: Thêm tài khoản mẫu và ~10 đơn mẫu ===';
GO

SET NOCOUNT ON;
-- 1) Tạo users nếu chưa có (username / password = '123')
-- Wrapper transaction + error handling để script an toàn khi chạy nhiều lần
BEGIN TRY
    BEGIN TRANSACTION;

DECLARE @IT INT = (SELECT id FROM dbo.Departments WHERE name = N'IT');
DECLARE @QA INT = (SELECT id FROM dbo.Departments WHERE name = N'QA');
DECLARE @EMP INT = (SELECT id FROM dbo.Roles WHERE code = N'EMPLOYEE');
DECLARE @MAN INT = (SELECT id FROM dbo.Roles WHERE code = N'MANAGER');
DECLARE @LEA INT = (SELECT id FROM dbo.Roles WHERE code = N'LEADER');
DECLARE @ADM INT = (SELECT id FROM dbo.Roles WHERE code = N'ADMIN');

-- Admin
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = N'admin')
BEGIN
    INSERT INTO dbo.Users(username,password_hash,full_name,role_id,department_id,manager_id)
    VALUES (N'admin', N'123', N'Admin User', @ADM, ISNULL(@IT,1), NULL);
    PRINT 'Inserted user: admin';
END
ELSE
    PRINT 'User admin already exists';

-- Managers
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = N'bob')
BEGIN
    INSERT INTO dbo.Users(username,password_hash,full_name,role_id,department_id,manager_id)
    VALUES (N'bob', N'123', N'Bob Tran', @MAN, ISNULL(@IT,1), NULL);
    PRINT 'Inserted user: bob';
END
ELSE
    PRINT 'User bob already exists';

IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = N'mike')
BEGIN
    INSERT INTO dbo.Users(username,password_hash,full_name,role_id,department_id,manager_id)
    VALUES (N'mike', N'123', N'Mike Le', @MAN, ISNULL(@QA,1), NULL);
    PRINT 'Inserted user: mike';
END
ELSE
    PRINT 'User mike already exists';

-- Leader
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = N'carl')
BEGIN
    -- Ensure bob exists for manager_id
    DECLARE @bobId INT = (SELECT id FROM dbo.Users WHERE username = N'bob');
    INSERT INTO dbo.Users(username,password_hash,full_name,role_id,department_id,manager_id)
    VALUES (N'carl', N'123', N'Carl Pham', @LEA, ISNULL(@IT,1), @bobId);
    PRINT 'Inserted user: carl';
END
ELSE
    PRINT 'User carl already exists';

-- Employees
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = N'alice')
BEGIN
    DECLARE @bobId2 INT = (SELECT id FROM dbo.Users WHERE username = N'bob');
    INSERT INTO dbo.Users(username,password_hash,full_name,role_id,department_id,manager_id)
    VALUES (N'alice', N'123', N'Alice Nguyen', @EMP, ISNULL(@IT,1), @bobId2);
    PRINT 'Inserted user: alice';
END
ELSE
    PRINT 'User alice already exists';

IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = N'eva')
BEGIN
    DECLARE @mikeId INT = (SELECT id FROM dbo.Users WHERE username = N'mike');
    INSERT INTO dbo.Users(username,password_hash,full_name,role_id,department_id,manager_id)
    VALUES (N'eva', N'123', N'Eva Do', @EMP, ISNULL(@QA,1), @mikeId);
    PRINT 'Inserted user: eva';
END
ELSE
    PRINT 'User eva already exists';


    -- commit at end of user & request inserts (below)

-- 2) Chuẩn bị ID và loại nghỉ
DECLARE @adminId INT = (SELECT id FROM dbo.Users WHERE username = N'admin');
DECLARE @bobId INT   = (SELECT id FROM dbo.Users WHERE username = N'bob');
DECLARE @mikeId INT  = (SELECT id FROM dbo.Users WHERE username = N'mike');
DECLARE @carlId INT  = (SELECT id FROM dbo.Users WHERE username = N'carl');
DECLARE @aliceId INT = (SELECT id FROM dbo.Users WHERE username = N'alice');
DECLARE @evaId INT   = (SELECT id FROM dbo.Users WHERE username = N'eva');

DECLARE @ANNUAL INT = (SELECT id FROM dbo.LeaveTypes WHERE code = N'ANNUAL');
DECLARE @SICK   INT = (SELECT id FROM dbo.LeaveTypes WHERE code = N'SICK');
DECLARE @MARRIAGE INT = (SELECT id FROM dbo.LeaveTypes WHERE code = N'MARRIAGE');

-- Nếu LeaveTypes chưa tồn tại, throw warning
IF @ANNUAL IS NULL OR @SICK IS NULL
BEGIN
    PRINT 'Warning: Một hoặc nhiều LeaveTypes chưa tồn tại. Hãy chạy leave_management_setup_v2.sql trước.';
END

-- 3) Thêm khoảng 10 đơn mẫu (nếu chưa tồn tại các title tương ứng)
-- Alice: 3 đơn
IF NOT EXISTS (SELECT 1 FROM dbo.Requests WHERE title = N'SAMPLE: Alice - Annual 1' AND created_by = @aliceId)
BEGIN
    INSERT INTO dbo.Requests(employee_id, type_id, title, reason, start_date, end_date, status, created_by)
    VALUES (@aliceId, @ANNUAL, N'SAMPLE: Alice - Annual 1', N'Family trip', '2025-12-20', '2025-12-22', N'INPROGRESS', @aliceId);
END

IF NOT EXISTS (SELECT 1 FROM dbo.Requests WHERE title = N'SAMPLE: Alice - Sick 1' AND created_by = @aliceId)
BEGIN
    INSERT INTO dbo.Requests(employee_id, type_id, title, reason, start_date, end_date, status, created_by, processed_by, processed_at, manager_note)
    VALUES (@aliceId, @SICK, N'SAMPLE: Alice - Sick 1', N'Fever & cold', '2025-11-05', '2025-11-06', N'APPROVED', @aliceId, @bobId, SYSUTCDATETIME(), N'Get well soon');
END

IF NOT EXISTS (SELECT 1 FROM dbo.Requests WHERE title = N'SAMPLE: Alice - Annual 2' AND created_by = @aliceId)
BEGIN
    INSERT INTO dbo.Requests(employee_id, type_id, title, reason, start_date, end_date, status, created_by, processed_by, processed_at, manager_note)
    VALUES (@aliceId, @ANNUAL, N'SAMPLE: Alice - Annual 2', N'New year trip', '2025-12-28', '2025-12-31', N'REJECTED', @aliceId, @bobId, SYSUTCDATETIME(), N'Busy period');
END

-- Eva: 2 đơn
IF NOT EXISTS (SELECT 1 FROM dbo.Requests WHERE title = N'SAMPLE: Eva - Annual 1' AND created_by = @evaId)
BEGIN
    INSERT INTO dbo.Requests(employee_id, type_id, title, reason, start_date, end_date, status, created_by)
    VALUES (@evaId, @ANNUAL, N'SAMPLE: Eva - Annual 1', N'Personal work', '2025-12-25', '2025-12-27', N'INPROGRESS', @evaId);
END

IF NOT EXISTS (SELECT 1 FROM dbo.Requests WHERE title = N'SAMPLE: Eva - Sick 1' AND created_by = @evaId)
BEGIN
    INSERT INTO dbo.Requests(employee_id, type_id, title, reason, start_date, end_date, status, created_by, processed_by, processed_at, manager_note)
    VALUES (@evaId, @SICK, N'SAMPLE: Eva - Sick 1', N'Stomach pain', '2025-12-12', '2025-12-12', N'APPROVED', @evaId, @mikeId, SYSUTCDATETIME(), N'Approved');
END

-- Carl: 2 đơn
IF NOT EXISTS (SELECT 1 FROM dbo.Requests WHERE title = N'SAMPLE: Carl - Annual 1' AND created_by = @carlId)
BEGIN
    INSERT INTO dbo.Requests(employee_id, type_id, title, reason, start_date, end_date, status, created_by)
    VALUES (@carlId, @ANNUAL, N'SAMPLE: Carl - Annual 1', N'Visit parents', '2025-12-18', '2025-12-20', N'INPROGRESS', @carlId);
END

IF NOT EXISTS (SELECT 1 FROM dbo.Requests WHERE title = N'SAMPLE: Carl - Sick 1' AND created_by = @carlId)
BEGIN
    INSERT INTO dbo.Requests(employee_id, type_id, title, reason, start_date, end_date, status, created_by, processed_by, processed_at, manager_note)
    VALUES (@carlId, @SICK, N'SAMPLE: Carl - Sick 1', N'Flu', '2025-11-15', '2025-11-16', N'APPROVED', @carlId, @bobId, SYSUTCDATETIME(), N'Approved');
END

-- Bob: 2 đơn
IF NOT EXISTS (SELECT 1 FROM dbo.Requests WHERE title = N'SAMPLE: Bob - Annual 1' AND created_by = @bobId)
BEGIN
    INSERT INTO dbo.Requests(employee_id, type_id, title, reason, start_date, end_date, status, created_by)
    VALUES (@bobId, @ANNUAL, N'SAMPLE: Bob - Annual 1', N'Family holiday', '2025-12-30', '2026-01-02', N'INPROGRESS', @bobId);
END

IF NOT EXISTS (SELECT 1 FROM dbo.Requests WHERE title = N'SAMPLE: Bob - Sick 1' AND created_by = @bobId)
BEGIN
    INSERT INTO dbo.Requests(employee_id, type_id, title, reason, start_date, end_date, status, created_by, processed_by, processed_at, manager_note)
    VALUES (@bobId, @SICK, N'SAMPLE: Bob - Sick 1', N'Headache', '2025-12-15', '2025-12-15', N'APPROVED', @bobId, @adminId, SYSUTCDATETIME(), N'Approved');
END

-- Admin: 1 đơn
IF NOT EXISTS (SELECT 1 FROM dbo.Requests WHERE title = N'SAMPLE: Admin - Annual 1' AND created_by = @adminId)
BEGIN
    INSERT INTO dbo.Requests(employee_id, type_id, title, reason, start_date, end_date, status, created_by)
    VALUES (@adminId, @ANNUAL, N'SAMPLE: Admin - Annual 1', N'Official trip', '2025-12-26', '2025-12-28', N'INPROGRESS', @adminId);
END

PRINT '✅ Đã thêm các tài khoản (nếu chưa có) và ~10 đơn mẫu.';
    -- 4) Cập nhật LeaveBalances used_days dựa trên các đơn đã được duyệt
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

    PRINT '✅ Cập nhật LeaveBalances';

    COMMIT TRANSACTION;
    PRINT '✅ seed_extra_sample_data.sql executed and committed successfully.';
END TRY
BEGIN CATCH
    DECLARE @errMsg NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @errNum INT = ERROR_NUMBER();
    PRINT '❌ ERROR in seed_extra_sample_data.sql';
    PRINT 'ErrorNumber: ' + CAST(@errNum AS NVARCHAR(20));
    PRINT @errMsg;
    IF XACT_STATE() <> 0
    BEGIN
        ROLLBACK TRANSACTION;
        PRINT 'Rolled back transaction due to error.';
    END
END CATCH

GO

PRINT '=== seed_extra_sample_data.sql hoàn tất ===';
GO
