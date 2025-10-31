/* ================================================================
   PRJ301_Assignment Mink — Leave Management (SQL Server)
   CLEAN, RERUNNABLE, PRODUCTION-LIKE SETUP (v2)
   Fixes:
   - Feature.url -> VARCHAR(255) (allow UNIQUE index)
   ================================================================= */

IF DB_ID(N'FALL25_Assignment') IS NULL
BEGIN
  DECLARE @sql nvarchar(max) = N'CREATE DATABASE FALL25_Assignment';
  EXEC(@sql);
END
GO

USE [FALL25_Assignment];
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

/* ========================== DROP PHASE ========================== */
BEGIN TRY
  BEGIN TRAN;

  IF OBJECT_ID('dbo.v_UserFeatures', 'V')    IS NOT NULL DROP VIEW dbo.v_UserFeatures;
  IF OBJECT_ID('dbo.v_UserCurrentEnrollment','V') IS NOT NULL DROP VIEW dbo.v_UserCurrentEnrollment;
  IF OBJECT_ID('dbo.fn_Subordinates', 'IF')  IS NOT NULL DROP FUNCTION dbo.fn_Subordinates;
  IF OBJECT_ID('dbo.sp_Request_Create', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_Request_Create;
  IF OBJECT_ID('dbo.sp_Request_ApproveReject', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_Request_ApproveReject;

  IF OBJECT_ID('dbo.RequestForLeave', 'U') IS NOT NULL DROP TABLE dbo.RequestForLeave;
  IF OBJECT_ID('dbo.RoleFeature', 'U')    IS NOT NULL DROP TABLE dbo.RoleFeature;
  IF OBJECT_ID('dbo.UserRole', 'U')       IS NOT NULL DROP TABLE dbo.UserRole;
  IF OBJECT_ID('dbo.Enrollment', 'U')     IS NOT NULL DROP TABLE dbo.Enrollment;
  IF OBJECT_ID('dbo.Feature', 'U')        IS NOT NULL DROP TABLE dbo.Feature;
  IF OBJECT_ID('dbo.Role', 'U')           IS NOT NULL DROP TABLE dbo.Role;
  IF OBJECT_ID('dbo.Employee', 'U')       IS NOT NULL DROP TABLE dbo.Employee;
  IF OBJECT_ID('dbo.[User]', 'U')         IS NOT NULL DROP TABLE dbo.[User];
  IF OBJECT_ID('dbo.Division', 'U')       IS NOT NULL DROP TABLE dbo.Division;

  COMMIT;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT > 0 ROLLBACK;
  THROW;
END CATCH
GO

/* ========================= CREATE PHASE ========================= */
BEGIN TRY
  BEGIN TRAN;

  CREATE TABLE dbo.[User](
    uid          INT          NOT NULL,
    username     VARCHAR(150) NOT NULL,
    [password]   VARCHAR(150) NOT NULL,
    displayname  VARCHAR(150) NOT NULL,
    CONSTRAINT PK_User PRIMARY KEY CLUSTERED(uid),
    CONSTRAINT UQ_User_Username UNIQUE(username)
  );

  CREATE TABLE dbo.Division(
    did   INT          NOT NULL,
    dname VARCHAR(150) NOT NULL,
    CONSTRAINT PK_Division PRIMARY KEY CLUSTERED(did)
  );

  CREATE TABLE dbo.Role(
    rid   INT          NOT NULL,
    rname VARCHAR(150) NOT NULL,
    CONSTRAINT PK_Role PRIMARY KEY CLUSTERED(rid)
  );

  -- CHANGED: url VARCHAR(255) to allow unique index
  CREATE TABLE dbo.Feature(
    fid  INT NOT NULL,
    [url] VARCHAR(255) NOT NULL,
    CONSTRAINT PK_Feature PRIMARY KEY CLUSTERED(fid),
    CONSTRAINT UQ_Feature_Url UNIQUE([url])
  );

  CREATE TABLE dbo.Employee(
    eid           INT          NOT NULL,
    ename         VARCHAR(150) NOT NULL,
    did           INT          NOT NULL,
    supervisorid  INT          NULL,
    CONSTRAINT PK_Employee PRIMARY KEY CLUSTERED(eid),
    CONSTRAINT FK_Employee_Division FOREIGN KEY(did) REFERENCES dbo.Division(did),
    CONSTRAINT FK_Employee_Employee FOREIGN KEY(supervisorid) REFERENCES dbo.Employee(eid),
    CONSTRAINT CK_Employee_NotSelfSupervisor CHECK (supervisorid IS NULL OR supervisorid <> eid)
  );

  CREATE TABLE dbo.Enrollment(
    uid     INT NOT NULL,
    eid     INT NOT NULL,
    [active] BIT NOT NULL CONSTRAINT DF_Enrollment_Active DEFAULT (1),
    CONSTRAINT PK_Enrollment PRIMARY KEY CLUSTERED(uid, eid),
    CONSTRAINT FK_Enrollment_User     FOREIGN KEY(uid) REFERENCES dbo.[User](uid),
    CONSTRAINT FK_Enrollment_Employee FOREIGN KEY(eid) REFERENCES dbo.Employee(eid)
  );

  CREATE TABLE dbo.UserRole(
    uid INT NOT NULL,
    rid INT NOT NULL,
    CONSTRAINT PK_UserRole PRIMARY KEY CLUSTERED(uid, rid),
    CONSTRAINT FK_UserRole_User FOREIGN KEY(uid) REFERENCES dbo.[User](uid),
    CONSTRAINT FK_UserRole_Role FOREIGN KEY(rid) REFERENCES dbo.Role(rid)
  );

  CREATE TABLE dbo.RoleFeature(
    rid INT NOT NULL,
    fid INT NOT NULL,
    CONSTRAINT PK_RoleFeature PRIMARY KEY CLUSTERED(rid, fid),
    CONSTRAINT FK_RoleFeature_Role    FOREIGN KEY(rid) REFERENCES dbo.Role(rid),
    CONSTRAINT FK_RoleFeature_Feature FOREIGN KEY(fid) REFERENCES dbo.Feature(fid)
  );

  CREATE TABLE dbo.RequestForLeave(
    rid           INT IDENTITY(1,1) NOT NULL,
    created_by    INT       NOT NULL,
    created_time  DATETIME  NOT NULL CONSTRAINT DF_RFL_CreatedTime DEFAULT (GETDATE()),
    from_date     DATE      NOT NULL,
    to_date       DATE      NOT NULL,
    reason        VARCHAR(MAX) NOT NULL,
    status        INT       NOT NULL,
    processed_by  INT       NULL,
    CONSTRAINT PK_RequestForLeave PRIMARY KEY CLUSTERED(rid),
    CONSTRAINT FK_RFL_CreatedBy_Employee   FOREIGN KEY(created_by)  REFERENCES dbo.Employee(eid),
    CONSTRAINT FK_RFL_ProcessedBy_Employee FOREIGN KEY(processed_by) REFERENCES dbo.Employee(eid),
    CONSTRAINT CK_RFL_Status CHECK (status IN (0,1,2)),
    CONSTRAINT CK_RFL_DateOrder CHECK (from_date <= to_date)
  );

  /* Seed data */
  INSERT dbo.Division(did, dname) VALUES (1,'IT'),(2,'QA'),(3,'Sale');

  INSERT dbo.Employee(eid, ename, did, supervisorid) VALUES
  (1, 'Nguyen Van A', 1, NULL),
  (2, 'Tran Van B',   1, 1),
  (3, 'CCCCCC',       1, 1),
  (4, 'Mr DDDD',      1, 2),
  (5, 'Mr EEEE',      1, 3),
  (6, 'Mr GGGGG',     1, 2);

  INSERT dbo.[User](uid, username, [password], displayname) VALUES
  (1,'mra','123','Mr A - Division Leader'),
  (2,'mrb','123','Mr B - Manager'),
  (3,'mrc','123','Mr C - Manager'),
  (4,'mrd','123','Employee MrD'),
  (5,'mre','123','Employee MrE'),
  (6,'mrg','123','Unassigned Role');

  INSERT dbo.Enrollment(uid,eid,[active]) VALUES
  (1,1,1),(2,2,1),(3,3,1),(4,4,1),(5,5,1),(6,6,1);

  INSERT dbo.Role(rid, rname) VALUES (1,'IT Head'),(2,'IT PM'),(3,'IT Employee');

  INSERT dbo.Feature(fid, [url]) VALUES
  (1,'/request/create'),
  (2,'/request/review'),
  (3,'/request/list'),
  (4,'/division/agenda');

  INSERT dbo.RoleFeature(rid,fid) VALUES
  (1,1),(1,2),(1,3),(1,4),
  (2,1),(2,2),(2,3),
  (3,1),(3,3);

  INSERT dbo.UserRole(uid,rid) VALUES (1,1),(2,2),(3,2),(4,3),(5,3);

  SET IDENTITY_INSERT dbo.RequestForLeave ON;
  INSERT dbo.RequestForLeave(rid, created_by, created_time, from_date, to_date, reason, status, processed_by) VALUES
  (1 ,1, '2025-10-21T00:00:00', '2025-10-22','2025-10-24', 'Nghi lay vo', 0, NULL),
  (2 ,2, '2025-10-21T00:00:00', '2025-10-22','2025-10-24', 'asfasf',      0, NULL),
  (3 ,2, '2025-10-21T00:00:00', '2025-10-22','2025-10-24', 'reeeeee',     0, NULL),
  (4 ,3, '2025-10-21T00:00:00', '2025-10-22','2025-10-24', 'ssssss',      0, NULL),
  (5 ,3, '2025-10-21T00:00:00', '2025-10-22','2025-10-24', 'ffff',        0, NULL),
  (6 ,4, '2025-10-21T00:00:00', '2025-10-22','2025-10-24', 'aasss',       0, NULL),
  (7 ,4, '2025-10-21T00:00:00', '2025-10-22','2025-10-24', 'asfasfasf',   0, NULL),
  (8 ,4, '2025-10-21T00:00:00', '2025-10-22','2025-10-24', 'asfasfasfasfasfasf', 0, NULL),
  (9 ,5, '2025-10-21T00:00:00', '2025-10-22','2025-10-24', 'asfafasfaf',  0, NULL),
  (10,5, '2025-10-21T00:00:00', '2025-10-22','2025-10-24', 'asfafafasfasfasfasfasf', 0, NULL),
  (11,5, '2025-10-21T00:00:00', '2025-10-22','2025-10-24', 'aaaa',        1, 1),
  (12,5, '2025-10-21T00:00:00', '2025-10-22','2025-10-24', 'aaaaaaaaaaaa',2, 1);
  SET IDENTITY_INSERT dbo.RequestForLeave OFF;

  COMMIT;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT > 0 ROLLBACK;
  THROW;
END CATCH
GO

/* ========================== INDEX PHASE ========================== */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_RFL_CreatedBy' AND object_id = OBJECT_ID('dbo.RequestForLeave'))
  CREATE INDEX IX_RFL_CreatedBy
  ON dbo.RequestForLeave(created_by, status)
  INCLUDE (created_time, processed_by, from_date, to_date);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_RFL_DateRange' AND object_id = OBJECT_ID('dbo.RequestForLeave'))
  CREATE INDEX IX_RFL_DateRange
  ON dbo.RequestForLeave(from_date, to_date);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Employee_Supervisor' AND object_id = OBJECT_ID('dbo.Employee'))
  CREATE INDEX IX_Employee_Supervisor ON dbo.Employee(supervisorid);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_UserRole' AND object_id = OBJECT_ID('dbo.UserRole'))
  CREATE INDEX IX_UserRole ON dbo.UserRole(uid, rid);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_RoleFeature' AND object_id = OBJECT_ID('dbo.RoleFeature'))
  CREATE INDEX IX_RoleFeature ON dbo.RoleFeature(rid, fid);
GO

/* =========================== VIEWS ============================== */
CREATE OR ALTER VIEW dbo.v_UserFeatures AS
SELECT u.uid, u.username, f.fid, f.[url]
FROM dbo.[User] u
JOIN dbo.UserRole    ur ON ur.uid = u.uid
JOIN dbo.RoleFeature rf ON rf.rid = ur.rid
JOIN dbo.Feature     f  ON f.fid = rf.fid;
GO

CREATE OR ALTER VIEW dbo.v_UserCurrentEnrollment AS
SELECT u.uid, u.username, e.eid, e.ename, e.did
FROM dbo.[User] u
JOIN dbo.Enrollment en ON en.uid = u.uid AND en.active = 1
JOIN dbo.Employee e    ON e.eid = en.eid;
GO

/* ====================== FUNCTION (ĐỆ QUY) ======================= */
CREATE OR ALTER FUNCTION dbo.fn_Subordinates(@eid INT)
RETURNS TABLE
AS
RETURN
(
  WITH SubTree AS (
    SELECT e.eid, e.supervisorid
    FROM dbo.Employee e
    WHERE e.eid = @eid
    UNION ALL
    SELECT c.eid, c.supervisorid
    FROM dbo.Employee c
    JOIN SubTree p ON c.supervisorid = p.eid
  )
  SELECT eid
  FROM SubTree
  WHERE eid <> @eid
);
GO

/* ========================== PROCEDURES ========================== */
CREATE OR ALTER PROCEDURE dbo.sp_Request_Create
  @creator_uid   INT,
  @from_date     DATE,
  @to_date       DATE,
  @reason        VARCHAR(MAX)
AS
BEGIN
  SET NOCOUNT ON;
  SET XACT_ABORT ON;
  BEGIN TRY
    BEGIN TRAN;

    IF @from_date IS NULL OR @to_date IS NULL OR @from_date > @to_date
    BEGIN
      RAISERROR(N'from_date/to_date không hợp lệ', 16, 1);
    END

    DECLARE @creator_eid INT =
    (
      SELECT TOP 1 e.eid
      FROM dbo.Enrollment en
      JOIN dbo.Employee e ON e.eid = en.eid
      WHERE en.uid = @creator_uid AND en.active = 1
    );

    IF @creator_eid IS NULL
      RAISERROR(N'User chưa có Enrollment active', 16, 1);

    IF EXISTS (
      SELECT 1
      FROM dbo.RequestForLeave r
      WHERE r.created_by = @creator_eid
        AND r.status IN (0,1)
        AND NOT (@to_date < r.from_date OR @from_date > r.to_date)
    )
    BEGIN
      RAISERROR(N'Khoảng ngày bị trùng với đơn đang chờ hoặc đã duyệt', 16, 1);
    END

    INSERT dbo.RequestForLeave(created_by, from_date, to_date, reason, status)
    VALUES (@creator_eid, @from_date, @to_date, @reason, 0);

    COMMIT;
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK;
    DECLARE @msg NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR(@msg, 16, 1);
  END CATCH
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Request_ApproveReject
  @manager_uid  INT,
  @rid          INT,
  @new_status   INT,
  @note         VARCHAR(MAX) = NULL
AS
BEGIN
  SET NOCOUNT ON;
  SET XACT_ABORT ON;

  IF @new_status NOT IN (1,2)
  BEGIN
    RAISERROR(N'new_status chỉ nhận 1=Approve hoặc 2=Reject', 16, 1);
    RETURN;
  END

  BEGIN TRY
    BEGIN TRAN;

    DECLARE @manager_eid INT =
    (
      SELECT TOP 1 e.eid
      FROM dbo.Enrollment en
      JOIN dbo.Employee e ON e.eid = en.eid
      WHERE en.uid = @manager_uid AND en.active = 1
    );

    IF @manager_eid IS NULL
      RAISERROR(N'User quản lý chưa có Enrollment active', 16, 1);

    IF NOT EXISTS (
      SELECT 1
      FROM dbo.RequestForLeave r
      JOIN dbo.Employee emp ON emp.eid = r.created_by
      WHERE r.rid = @rid
        AND r.status = 0
        AND emp.supervisorid = @manager_eid
    )
    BEGIN
      RAISERROR(N'Không có quyền duyệt đơn này hoặc đơn không ở trạng thái Inprogress', 16, 1);
    END

    UPDATE r
      SET r.status = @new_status,
          r.processed_by = @manager_eid
    FROM dbo.RequestForLeave r
    WHERE r.rid = @rid AND r.status = 0;

    COMMIT;
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK;
    DECLARE @msg NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR(@msg, 16, 1);
  END CATCH
END
GO


PRINT '✅ Setup v2 completed successfully.'; 
