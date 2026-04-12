-- Seed PieManager users and assign clients via PieManagerClient table.
-- Each client can only be assigned to ONE PieManager at a time.
-- Runs only once (tracked in __ScriptHistory).
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'User')
   AND EXISTS (SELECT * FROM sys.tables WHERE name = 'Role')
   AND EXISTS (SELECT * FROM sys.tables WHERE name = 'PieManagerClient')
   AND EXISTS (SELECT * FROM sys.tables WHERE name = 'Client')
BEGIN
    DECLARE @PieManagerRoleId INT = (SELECT RoleId FROM [dbo].[Role] WHERE Name = N'PieManager');
    DECLARE @PieAdminRoleId INT = (SELECT RoleId FROM [dbo].[Role] WHERE Name = N'PieAdmin');
    DECLARE @DefaultPassword NVARCHAR(500) = N'ChangeMe123!';
    DECLARE @PieAdminUserId INT = (SELECT UserId FROM [dbo].[User] WHERE UserName = N'PieAdmin' AND RoleId = @PieAdminRoleId);

    -- Create additional PieManager users for demonstration
    IF @PieManagerRoleId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM [dbo].[User] WHERE UserName = N'PieManager1' OR Email = N'PieManager1@telepie.local')
    BEGIN
        INSERT INTO [dbo].[User] ([UserName], [Email], [Password], [FirstName], [LastName], [IsActive], [RoleId], [CreatedAt], [UpdatedAt])
        VALUES (N'PieManager1', N'PieManager1@telepie.local', @DefaultPassword, N'Pie', N'Manager1', 1, @PieManagerRoleId, GETDATE(), NULL);
    END

    IF @PieManagerRoleId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM [dbo].[User] WHERE UserName = N'PieManager2' OR Email = N'PieManager2@telepie.local')
    BEGIN
        INSERT INTO [dbo].[User] ([UserName], [Email], [Password], [FirstName], [LastName], [IsActive], [RoleId], [CreatedAt], [UpdatedAt])
        VALUES (N'PieManager2', N'PieManager2@telepie.local', @DefaultPassword, N'Pie', N'Manager2', 1, @PieManagerRoleId, GETDATE(), NULL);
    END

    -- Assign Client 1 to PieManager1 (only if Client 1 not already assigned)
    IF NOT EXISTS (SELECT 1 FROM [dbo].[PieManagerClient] WHERE ClientId = 1 AND DeletedAt IS NULL)
       AND EXISTS (SELECT 1 FROM [dbo].[User] u INNER JOIN [dbo].[Role] r ON u.RoleId = r.RoleId WHERE u.UserName = N'PieManager1' AND r.Name = N'PieManager')
    BEGIN
        INSERT INTO [dbo].[PieManagerClient] ([UserId], [ClientId], [CreatedAt], [CreatedBy], [UpdatedAt], [UpdatedBy], [DeletedAt], [DeletedBy])
        SELECT u.[UserId], 1, GETUTCDATE(), @PieAdminUserId, NULL, NULL, NULL, NULL
        FROM [dbo].[User] u
        INNER JOIN [dbo].[Role] r ON u.[RoleId] = r.[RoleId]
        WHERE u.[UserName] = N'PieManager1' AND r.[Name] = N'PieManager';
    END

    -- Assign Client 2 to PieManager2 (only if Client 2 not already assigned)
    IF NOT EXISTS (SELECT 1 FROM [dbo].[PieManagerClient] WHERE ClientId = 2 AND DeletedAt IS NULL)
       AND EXISTS (SELECT 1 FROM [dbo].[User] u INNER JOIN [dbo].[Role] r ON u.RoleId = r.RoleId WHERE u.UserName = N'PieManager2' AND r.Name = N'PieManager')
    BEGIN
        INSERT INTO [dbo].[PieManagerClient] ([UserId], [ClientId], [CreatedAt], [CreatedBy], [UpdatedAt], [UpdatedBy], [DeletedAt], [DeletedBy])
        SELECT u.[UserId], 2, GETUTCDATE(), @PieAdminUserId, NULL, NULL, NULL, NULL
        FROM [dbo].[User] u
        INNER JOIN [dbo].[Role] r ON u.[RoleId] = r.[RoleId]
        WHERE u.[UserName] = N'PieManager2' AND r.[Name] = N'PieManager';
    END

    -- Assign Client 1 to default PieManager if not already assigned
    IF NOT EXISTS (SELECT 1 FROM [dbo].[PieManagerClient] WHERE ClientId = 1 AND DeletedAt IS NULL)
       AND EXISTS (SELECT 1 FROM [dbo].[User] u INNER JOIN [dbo].[Role] r ON u.RoleId = r.RoleId WHERE u.UserName = N'PieManager' AND r.Name = N'PieManager')
    BEGIN
        INSERT INTO [dbo].[PieManagerClient] ([UserId], [ClientId], [CreatedAt], [CreatedBy], [UpdatedAt], [UpdatedBy], [DeletedAt], [DeletedBy])
        SELECT u.[UserId], 1, GETUTCDATE(), @PieAdminUserId, NULL, NULL, NULL, NULL
        FROM [dbo].[User] u
        INNER JOIN [dbo].[Role] r ON u.[RoleId] = r.[RoleId]
        WHERE u.[UserName] = N'PieManager' AND r.[Name] = N'PieManager';
    END

    -- Assign Client 2 to default PieManager if not already assigned
    IF NOT EXISTS (SELECT 1 FROM [dbo].[PieManagerClient] WHERE ClientId = 2 AND DeletedAt IS NULL)
       AND EXISTS (SELECT 1 FROM [dbo].[User] u INNER JOIN [dbo].[Role] r ON u.RoleId = r.RoleId WHERE u.UserName = N'PieManager' AND r.Name = N'PieManager')
    BEGIN
        INSERT INTO [dbo].[PieManagerClient] ([UserId], [ClientId], [CreatedAt], [CreatedBy], [UpdatedAt], [UpdatedBy], [DeletedAt], [DeletedBy])
        SELECT u.[UserId], 2, GETUTCDATE(), @PieAdminUserId, NULL, NULL, NULL, NULL
        FROM [dbo].[User] u
        INNER JOIN [dbo].[Role] r ON u.[RoleId] = r.[RoleId]
        WHERE u.[UserName] = N'PieManager' AND r.[Name] = N'PieManager';
    END
END
GO
