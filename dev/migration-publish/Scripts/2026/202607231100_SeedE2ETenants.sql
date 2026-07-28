-- Dedicated E2E tenants for UI Playwright (idempotent by name).
-- Keeps demo Client One / Company One A untouched for manual QA.
--
-- Seeds:
--   Clients:  E2E Client Alpha, E2E Client Beta
--   Companies: E2E Company Alpha (under Alpha), E2E Company Beta (under Beta)
--   Portal users (password ChangeMe123!):
--     E2EClientAdmin, E2EClientManager  → Alpha
--     E2ECompanyAdmin, E2ECompanyManager → Alpha company
--   Employees (login = NationalId / ChangeMe123!):
--     E2EEMP0001, E2EEMP0002, E2EEMP0003 on Alpha
--     E2EEMPB001 on Beta
--   PieManager1 also assigned to E2E Client Alpha (if free)
--   Default CompanyBatch + DefaultCompanyBatchId for new companies
--
-- Prerequisites: Role, Client, Company, User, UserClient, UserCompany, Employee,
--   EmployeeEmployment, CompanyBatch (and optional PieManagerClient).

SET NOCOUNT ON;
GO

/* ---------- Clients ---------- */
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Client')
BEGIN
    IF NOT EXISTS (SELECT 1 FROM [dbo].[Client] WHERE ClientName = N'E2E Client Alpha' AND DeletedAt IS NULL)
        INSERT INTO [dbo].[Client] (
            [ClientName], [Notes], [Address], [Mobile], [Phone], [IsActive],
            [CreatedAt], [CreatedBy], [UpdatedAt], [UpdatedBy], [DeletedAt], [DeletedBy]
        )
        VALUES (
            N'E2E Client Alpha', N'UI E2E primary tenant — do not rename in manual demos',
            N'1 E2E Way', N'+966500000101', N'+966500000102', 1,
            GETDATE(), NULL, NULL, NULL, NULL, NULL
        );

    IF NOT EXISTS (SELECT 1 FROM [dbo].[Client] WHERE ClientName = N'E2E Client Beta' AND DeletedAt IS NULL)
        INSERT INTO [dbo].[Client] (
            [ClientName], [Notes], [Address], [Mobile], [Phone], [IsActive],
            [CreatedAt], [CreatedBy], [UpdatedAt], [UpdatedBy], [DeletedAt], [DeletedBy]
        )
        VALUES (
            N'E2E Client Beta', N'UI E2E secondary tenant — isolation tests',
            N'2 E2E Way', N'+966500000201', N'+966500000202', 1,
            GETDATE(), NULL, NULL, NULL, NULL, NULL
        );
END
GO

/* ---------- Companies ---------- */
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Company')
   AND EXISTS (SELECT * FROM sys.tables WHERE name = 'Client')
BEGIN
    DECLARE @AlphaClientId INT = (
        SELECT TOP (1) ClientId FROM [dbo].[Client]
        WHERE ClientName = N'E2E Client Alpha' AND DeletedAt IS NULL ORDER BY ClientId
    );
    DECLARE @BetaClientId INT = (
        SELECT TOP (1) ClientId FROM [dbo].[Client]
        WHERE ClientName = N'E2E Client Beta' AND DeletedAt IS NULL ORDER BY ClientId
    );

    IF @AlphaClientId IS NOT NULL
       AND NOT EXISTS (
           SELECT 1 FROM [dbo].[Company]
           WHERE CompanyName = N'E2E Company Alpha' AND DeletedAt IS NULL
       )
        INSERT INTO [dbo].[Company] (
            [ClientId], [CompanyName], [Description], [Mobile], [Address],
            [RegistrationDate], [DeletedAt], [DeletedBy]
        )
        VALUES (
            @AlphaClientId, N'E2E Company Alpha', N'Primary E2E company',
            N'+966500000111', N'100 E2E Street', CAST(GETDATE() AS DATE), NULL, NULL
        );

    IF @BetaClientId IS NOT NULL
       AND NOT EXISTS (
           SELECT 1 FROM [dbo].[Company]
           WHERE CompanyName = N'E2E Company Beta' AND DeletedAt IS NULL
       )
        INSERT INTO [dbo].[Company] (
            [ClientId], [CompanyName], [Description], [Mobile], [Address],
            [RegistrationDate], [DeletedAt], [DeletedBy]
        )
        VALUES (
            @BetaClientId, N'E2E Company Beta', N'Secondary E2E company',
            N'+966500000211', N'200 E2E Street', CAST(GETDATE() AS DATE), NULL, NULL
        );
END
GO

/* ---------- Default company batches ---------- */
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'CompanyBatch')
BEGIN
    INSERT INTO [dbo].[CompanyBatch] (
        [CompanyId], [BatchId], [BatchName], [WorkingHoursPerDay], [CreatedAt]
    )
    SELECT c.[CompanyId], 'DEFAULT', N'Default Batch', 8.0, GETDATE()
    FROM [dbo].[Company] c
    WHERE c.[DeletedAt] IS NULL
      AND c.[CompanyName] IN (N'E2E Company Alpha', N'E2E Company Beta')
      AND NOT EXISTS (
          SELECT 1 FROM [dbo].[CompanyBatch] cb
          WHERE cb.[CompanyId] = c.[CompanyId] AND cb.[BatchId] = 'DEFAULT'
      );
END
GO

IF COL_LENGTH('dbo.Company', 'DefaultCompanyBatchId') IS NOT NULL
BEGIN
    UPDATE c
    SET c.[DefaultCompanyBatchId] = cb.[CompanyBatchId]
    FROM [dbo].[Company] c
    INNER JOIN [dbo].[CompanyBatch] cb
        ON cb.[CompanyId] = c.[CompanyId] AND cb.[BatchId] = 'DEFAULT'
    WHERE c.[DeletedAt] IS NULL
      AND c.[CompanyName] IN (N'E2E Company Alpha', N'E2E Company Beta')
      AND c.[DefaultCompanyBatchId] IS NULL;
END
GO

/* ---------- Portal users ---------- */
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'User')
   AND EXISTS (SELECT * FROM sys.tables WHERE name = 'Role')
BEGIN
    DECLARE @ClientAdminRoleId INT = (SELECT RoleId FROM [dbo].[Role] WHERE Name = N'ClientAdmin');
    DECLARE @ClientManagerRoleId INT = (SELECT RoleId FROM [dbo].[Role] WHERE Name = N'ClientManager');
    DECLARE @CompanyAdminRoleId INT = (SELECT RoleId FROM [dbo].[Role] WHERE Name = N'CompanyAdmin');
    DECLARE @CompanyManagerRoleId INT = (SELECT RoleId FROM [dbo].[Role] WHERE Name = N'CompanyManager');
    DECLARE @Pwd NVARCHAR(500) = N'ChangeMe123!';

    IF @ClientAdminRoleId IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM [dbo].[User] WHERE UserName = N'E2EClientAdmin' OR Email = N'E2EClientAdmin@telepie.local')
        INSERT INTO [dbo].[User] ([UserName], [Email], [Password], [FirstName], [LastName], [IsActive], [RoleId], [CreatedAt], [UpdatedAt])
        VALUES (N'E2EClientAdmin', N'E2EClientAdmin@telepie.local', @Pwd, N'E2E', N'ClientAdmin', 1, @ClientAdminRoleId, GETDATE(), NULL);

    IF @ClientManagerRoleId IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM [dbo].[User] WHERE UserName = N'E2EClientManager' OR Email = N'E2EClientManager@telepie.local')
        INSERT INTO [dbo].[User] ([UserName], [Email], [Password], [FirstName], [LastName], [IsActive], [RoleId], [CreatedAt], [UpdatedAt])
        VALUES (N'E2EClientManager', N'E2EClientManager@telepie.local', @Pwd, N'E2E', N'ClientManager', 1, @ClientManagerRoleId, GETDATE(), NULL);

    IF @CompanyAdminRoleId IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM [dbo].[User] WHERE UserName = N'E2ECompanyAdmin' OR Email = N'E2ECompanyAdmin@telepie.local')
        INSERT INTO [dbo].[User] ([UserName], [Email], [Password], [FirstName], [LastName], [IsActive], [RoleId], [CreatedAt], [UpdatedAt])
        VALUES (N'E2ECompanyAdmin', N'E2ECompanyAdmin@telepie.local', @Pwd, N'E2E', N'CompanyAdmin', 1, @CompanyAdminRoleId, GETDATE(), NULL);

    IF @CompanyManagerRoleId IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM [dbo].[User] WHERE UserName = N'E2ECompanyManager' OR Email = N'E2ECompanyManager@telepie.local')
        INSERT INTO [dbo].[User] ([UserName], [Email], [Password], [FirstName], [LastName], [IsActive], [RoleId], [CreatedAt], [UpdatedAt])
        VALUES (N'E2ECompanyManager', N'E2ECompanyManager@telepie.local', @Pwd, N'E2E', N'CompanyManager', 1, @CompanyManagerRoleId, GETDATE(), NULL);
END
GO

/* ---------- UserClient (Alpha) ---------- */
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'UserClient')
BEGIN
    DECLARE @AlphaClientId2 INT = (
        SELECT TOP (1) ClientId FROM [dbo].[Client]
        WHERE ClientName = N'E2E Client Alpha' AND DeletedAt IS NULL ORDER BY ClientId
    );

    IF @AlphaClientId2 IS NOT NULL
    BEGIN
        INSERT INTO [dbo].[UserClient] ([UserId], [ClientId], [IsActive], [CreatedAt], [CreatedBy], [UpdatedAt], [UpdatedBy])
        SELECT u.[UserId], @AlphaClientId2, 1, GETUTCDATE(), NULL, NULL, NULL
        FROM [dbo].[User] u
        INNER JOIN [dbo].[Role] r ON u.[RoleId] = r.[RoleId]
        WHERE u.[UserName] IN (N'E2EClientAdmin', N'E2EClientManager')
          AND r.[Name] IN (N'ClientAdmin', N'ClientManager')
          AND NOT EXISTS (
              SELECT 1 FROM [dbo].[UserClient] uc
              WHERE uc.[UserId] = u.[UserId] AND uc.[ClientId] = @AlphaClientId2 AND uc.[IsActive] = 1
          );
    END
END
GO

/* ---------- UserCompany (Alpha company) ---------- */
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'UserCompany')
BEGIN
    DECLARE @AlphaCompanyId INT = (
        SELECT TOP (1) CompanyId FROM [dbo].[Company]
        WHERE CompanyName = N'E2E Company Alpha' AND DeletedAt IS NULL ORDER BY CompanyId
    );

    IF @AlphaCompanyId IS NOT NULL
    BEGIN
        INSERT INTO [dbo].[UserCompany] (
            [UserId], [CompanyId], [IsActive], [CreatedAt], [CreatedBy], [UpdatedAt], [UpdatedBy]
        )
        SELECT u.[UserId], @AlphaCompanyId, 1, GETUTCDATE(), NULL, NULL, NULL
        FROM [dbo].[User] u
        INNER JOIN [dbo].[Role] r ON u.[RoleId] = r.[RoleId]
        WHERE u.[UserName] IN (N'E2ECompanyAdmin', N'E2ECompanyManager')
          AND r.[Name] IN (N'CompanyAdmin', N'CompanyManager')
          AND NOT EXISTS (
              SELECT 1 FROM [dbo].[UserCompany] uc
              WHERE uc.[UserId] = u.[UserId] AND uc.[CompanyId] = @AlphaCompanyId AND uc.[IsActive] = 1
          );
    END
END
GO

/* ---------- PieManager1 → E2E Client Alpha ---------- */
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'PieManagerClient')
BEGIN
    DECLARE @AlphaClientId3 INT = (
        SELECT TOP (1) ClientId FROM [dbo].[Client]
        WHERE ClientName = N'E2E Client Alpha' AND DeletedAt IS NULL ORDER BY ClientId
    );
    DECLARE @PieAdminUserId INT = (
        SELECT TOP (1) u.UserId
        FROM [dbo].[User] u
        INNER JOIN [dbo].[Role] r ON u.RoleId = r.RoleId
        WHERE u.UserName = N'PieAdmin' AND r.Name = N'PieAdmin'
    );
    DECLARE @PieManager1Id INT = (
        SELECT TOP (1) u.UserId
        FROM [dbo].[User] u
        INNER JOIN [dbo].[Role] r ON u.RoleId = r.RoleId
        WHERE u.UserName = N'PieManager1' AND r.Name = N'PieManager'
    );

    IF @AlphaClientId3 IS NOT NULL
       AND @PieManager1Id IS NOT NULL
       AND NOT EXISTS (
           SELECT 1 FROM [dbo].[PieManagerClient]
           WHERE ClientId = @AlphaClientId3 AND DeletedAt IS NULL
       )
        INSERT INTO [dbo].[PieManagerClient] (
            [UserId], [ClientId], [CreatedAt], [CreatedBy], [UpdatedAt], [UpdatedBy], [DeletedAt], [DeletedBy]
        )
        VALUES (@PieManager1Id, @AlphaClientId3, GETUTCDATE(), @PieAdminUserId, NULL, NULL, NULL, NULL);
END
GO

/* ---------- Employees ---------- */
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'User')
   AND EXISTS (SELECT * FROM sys.tables WHERE name = 'Role')
   AND EXISTS (SELECT * FROM sys.tables WHERE name = 'Employee')
BEGIN
    DECLARE @EmployeeRoleId INT = (SELECT RoleId FROM [dbo].[Role] WHERE Name = N'Employee');
    DECLARE @PwdEmp NVARCHAR(500) = N'ChangeMe123!';
    DECLARE @AlphaCoId INT = (
        SELECT TOP (1) CompanyId FROM [dbo].[Company]
        WHERE CompanyName = N'E2E Company Alpha' AND DeletedAt IS NULL ORDER BY CompanyId
    );
    DECLARE @BetaCoId INT = (
        SELECT TOP (1) CompanyId FROM [dbo].[Company]
        WHERE CompanyName = N'E2E Company Beta' AND DeletedAt IS NULL ORDER BY CompanyId
    );
    DECLARE @AlphaBatchId INT = (
        SELECT TOP (1) CompanyBatchId FROM [dbo].[CompanyBatch]
        WHERE CompanyId = @AlphaCoId AND BatchId = 'DEFAULT'
    );
    DECLARE @BetaBatchId INT = (
        SELECT TOP (1) CompanyBatchId FROM [dbo].[CompanyBatch]
        WHERE CompanyId = @BetaCoId AND BatchId = 'DEFAULT'
    );

    -- Helper inline inserts for each employee
    DECLARE @Rows TABLE (
        UserName NVARCHAR(100),
        Email NVARCHAR(256),
        NationalId VARCHAR(50),
        FirstName NVARCHAR(100),
        LastName NVARCHAR(100),
        Mobile VARCHAR(20),
        CompanyId INT,
        BatchId INT
    );

    INSERT INTO @Rows VALUES
        (N'E2EEMP0001', N'E2EEmployee1@telepie.local', 'E2EEMP0001', N'E2E', N'Employee1', N'0500000001', @AlphaCoId, @AlphaBatchId),
        (N'E2EEMP0002', N'E2EEmployee2@telepie.local', 'E2EEMP0002', N'E2E', N'Employee2', N'0500000002', @AlphaCoId, @AlphaBatchId),
        (N'E2EEMP0003', N'E2EEmployee3@telepie.local', 'E2EEMP0003', N'E2E', N'Employee3', N'0500000003', @AlphaCoId, @AlphaBatchId),
        (N'E2EEMPB001', N'E2EEmployeeB1@telepie.local', 'E2EEMPB001', N'E2E', N'EmployeeB1', N'0500000101', @BetaCoId, @BetaBatchId);

    IF @EmployeeRoleId IS NOT NULL
    BEGIN
        DECLARE @un NVARCHAR(100), @em NVARCHAR(256), @nid VARCHAR(50), @fn NVARCHAR(100), @ln NVARCHAR(100), @mob VARCHAR(20), @co INT, @batch INT;
        DECLARE @uid INT, @eid INT;

        DECLARE emp_cursor CURSOR LOCAL FAST_FORWARD FOR
            SELECT UserName, Email, NationalId, FirstName, LastName, Mobile, CompanyId, BatchId FROM @Rows;
        OPEN emp_cursor;
        FETCH NEXT FROM emp_cursor INTO @un, @em, @nid, @fn, @ln, @mob, @co, @batch;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            IF @co IS NOT NULL
               AND NOT EXISTS (SELECT 1 FROM [dbo].[User] WHERE UserName = @un OR Email = @em OR UserName = @nid)
            BEGIN
                INSERT INTO [dbo].[User] (
                    [UserName], [Email], [Password], [FirstName], [LastName], [IsActive], [RoleId], [CreatedAt], [UpdatedAt]
                )
                VALUES (@un, @em, @PwdEmp, @fn, @ln, 1, @EmployeeRoleId, GETDATE(), NULL);
                SET @uid = SCOPE_IDENTITY();

                INSERT INTO [dbo].[Employee] ([UserId], [NationalId], [Name], [Mobile], [CreatedAt])
                VALUES (@uid, @nid, CONCAT(@fn, N' ', @ln), @mob, GETDATE());
                SET @eid = SCOPE_IDENTITY();

                IF EXISTS (SELECT * FROM sys.tables WHERE name = 'EmployeeEmployment')
                   AND NOT EXISTS (
                       SELECT 1 FROM [dbo].[EmployeeEmployment]
                       WHERE EmployeeId = @eid AND CompanyId = @co AND DeletedAt IS NULL
                   )
                BEGIN
                    IF COL_LENGTH('dbo.EmployeeEmployment', 'CompanyBatchId') IS NOT NULL
                        INSERT INTO [dbo].[EmployeeEmployment] (
                            [EmployeeId], [CompanyId], [JoiningDate], [LeavingDate], [CompanyBatchId], [CreatedAt]
                        )
                        VALUES (@eid, @co, CAST('2026-01-01' AS DATE), NULL, @batch, GETDATE());
                    ELSE
                        INSERT INTO [dbo].[EmployeeEmployment] (
                            [EmployeeId], [CompanyId], [JoiningDate], [LeavingDate], [CreatedAt]
                        )
                        VALUES (@eid, @co, CAST('2026-01-01' AS DATE), NULL, GETDATE());
                END
            END
            ELSE IF @co IS NOT NULL AND EXISTS (SELECT * FROM sys.tables WHERE name = 'EmployeeEmployment')
            BEGIN
                -- Re-run safe: attach employment if user already exists without Alpha/Beta row
                SET @uid = (SELECT TOP 1 UserId FROM [dbo].[User] WHERE UserName = @un OR Email = @em OR UserName = @nid);
                SET @eid = (SELECT TOP 1 EmployeeId FROM [dbo].[Employee] WHERE UserId = @uid AND DeletedAt IS NULL);
                IF @eid IS NOT NULL
                   AND NOT EXISTS (
                       SELECT 1 FROM [dbo].[EmployeeEmployment]
                       WHERE EmployeeId = @eid AND CompanyId = @co AND DeletedAt IS NULL
                   )
                BEGIN
                    IF COL_LENGTH('dbo.EmployeeEmployment', 'CompanyBatchId') IS NOT NULL
                        INSERT INTO [dbo].[EmployeeEmployment] (
                            [EmployeeId], [CompanyId], [JoiningDate], [LeavingDate], [CompanyBatchId], [CreatedAt]
                        )
                        VALUES (@eid, @co, CAST('2026-01-01' AS DATE), NULL, @batch, GETDATE());
                    ELSE
                        INSERT INTO [dbo].[EmployeeEmployment] (
                            [EmployeeId], [CompanyId], [JoiningDate], [LeavingDate], [CreatedAt]
                        )
                        VALUES (@eid, @co, CAST('2026-01-01' AS DATE), NULL, GETDATE());
                END
            END

            FETCH NEXT FROM emp_cursor INTO @un, @em, @nid, @fn, @ln, @mob, @co, @batch;
        END
        CLOSE emp_cursor;
        DEALLOCATE emp_cursor;
    END
END
GO
