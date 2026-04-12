-- Seed CompanyAdmin and CompanyManager users for each company (8 users) and link them via UserCompany. Runs only once (tracked in __ScriptHistory).
-- UserName and Email are unique; inserts only if user does not exist.
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'User') AND EXISTS (SELECT * FROM sys.tables WHERE name = 'Role') AND EXISTS (SELECT * FROM sys.tables WHERE name = 'UserCompany') AND EXISTS (SELECT * FROM sys.tables WHERE name = 'Company')
BEGIN
    DECLARE @CompanyAdminRoleId INT = (SELECT RoleId FROM [dbo].[Role] WHERE Name = N'CompanyAdmin');
    DECLARE @CompanyManagerRoleId INT = (SELECT RoleId FROM [dbo].[Role] WHERE Name = N'CompanyManager');
    DECLARE @DefaultPassword NVARCHAR(500) = N'ChangeMe123!';

    -- Company 1 - Admin (check UserName and Email for uniqueness)
    IF @CompanyAdminRoleId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM [dbo].[User] WHERE UserName = N'Company1Admin' OR Email = N'Company1Admin@telepie.local')
    INSERT INTO [dbo].[User] ([UserName], [Email], [Password], [FirstName], [LastName], [IsActive], [RoleId], [CreatedAt], [UpdatedAt])
    VALUES (N'Company1Admin', N'Company1Admin@telepie.local', @DefaultPassword, N'Company1', N'Admin', 1, @CompanyAdminRoleId, GETDATE(), NULL);

    -- Company 1 - Manager
    IF @CompanyManagerRoleId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM [dbo].[User] WHERE UserName = N'Company1Manager' OR Email = N'Company1Manager@telepie.local')
    INSERT INTO [dbo].[User] ([UserName], [Email], [Password], [FirstName], [LastName], [IsActive], [RoleId], [CreatedAt], [UpdatedAt])
    VALUES (N'Company1Manager', N'Company1Manager@telepie.local', @DefaultPassword, N'Company1', N'Manager', 1, @CompanyManagerRoleId, GETDATE(), NULL);

    -- Company 2 - Admin
    IF @CompanyAdminRoleId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM [dbo].[User] WHERE UserName = N'Company2Admin' OR Email = N'Company2Admin@telepie.local')
    INSERT INTO [dbo].[User] ([UserName], [Email], [Password], [FirstName], [LastName], [IsActive], [RoleId], [CreatedAt], [UpdatedAt])
    VALUES (N'Company2Admin', N'Company2Admin@telepie.local', @DefaultPassword, N'Company2', N'Admin', 1, @CompanyAdminRoleId, GETDATE(), NULL);

    -- Company 2 - Manager
    IF @CompanyManagerRoleId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM [dbo].[User] WHERE UserName = N'Company2Manager' OR Email = N'Company2Manager@telepie.local')
    INSERT INTO [dbo].[User] ([UserName], [Email], [Password], [FirstName], [LastName], [IsActive], [RoleId], [CreatedAt], [UpdatedAt])
    VALUES (N'Company2Manager', N'Company2Manager@telepie.local', @DefaultPassword, N'Company2', N'Manager', 1, @CompanyManagerRoleId, GETDATE(), NULL);

    -- Company 3 - Admin
    IF @CompanyAdminRoleId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM [dbo].[User] WHERE UserName = N'Company3Admin' OR Email = N'Company3Admin@telepie.local')
    INSERT INTO [dbo].[User] ([UserName], [Email], [Password], [FirstName], [LastName], [IsActive], [RoleId], [CreatedAt], [UpdatedAt])
    VALUES (N'Company3Admin', N'Company3Admin@telepie.local', @DefaultPassword, N'Company3', N'Admin', 1, @CompanyAdminRoleId, GETDATE(), NULL);

    -- Company 3 - Manager
    IF @CompanyManagerRoleId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM [dbo].[User] WHERE UserName = N'Company3Manager' OR Email = N'Company3Manager@telepie.local')
    INSERT INTO [dbo].[User] ([UserName], [Email], [Password], [FirstName], [LastName], [IsActive], [RoleId], [CreatedAt], [UpdatedAt])
    VALUES (N'Company3Manager', N'Company3Manager@telepie.local', @DefaultPassword, N'Company3', N'Manager', 1, @CompanyManagerRoleId, GETDATE(), NULL);

    -- Company 4 - Admin
    IF @CompanyAdminRoleId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM [dbo].[User] WHERE UserName = N'Company4Admin' OR Email = N'Company4Admin@telepie.local')
    INSERT INTO [dbo].[User] ([UserName], [Email], [Password], [FirstName], [LastName], [IsActive], [RoleId], [CreatedAt], [UpdatedAt])
    VALUES (N'Company4Admin', N'Company4Admin@telepie.local', @DefaultPassword, N'Company4', N'Admin', 1, @CompanyAdminRoleId, GETDATE(), NULL);

    -- Company 4 - Manager
    IF @CompanyManagerRoleId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM [dbo].[User] WHERE UserName = N'Company4Manager' OR Email = N'Company4Manager@telepie.local')
    INSERT INTO [dbo].[User] ([UserName], [Email], [Password], [FirstName], [LastName], [IsActive], [RoleId], [CreatedAt], [UpdatedAt])
    VALUES (N'Company4Manager', N'Company4Manager@telepie.local', @DefaultPassword, N'Company4', N'Manager', 1, @CompanyManagerRoleId, GETDATE(), NULL);

    -- Link users to companies via UserCompany
    IF NOT EXISTS (SELECT 1 FROM [dbo].[UserCompany])
    BEGIN
        INSERT INTO [dbo].[UserCompany] ([UserId], [CompanyId], [IsActive], [CreatedAt], [CreatedBy], [UpdatedAt], [UpdatedBy])
        SELECT u.[UserId], 1, 1, GETUTCDATE(), NULL, NULL, NULL
        FROM [dbo].[User] u INNER JOIN [dbo].[Role] r ON u.[RoleId] = r.[RoleId]
        WHERE u.[UserName] IN (N'Company1Admin', N'Company1Manager') AND r.[Name] IN (N'CompanyAdmin', N'CompanyManager');

        INSERT INTO [dbo].[UserCompany] ([UserId], [CompanyId], [IsActive], [CreatedAt], [CreatedBy], [UpdatedAt], [UpdatedBy])
        SELECT u.[UserId], 2, 1, GETUTCDATE(), NULL, NULL, NULL
        FROM [dbo].[User] u INNER JOIN [dbo].[Role] r ON u.[RoleId] = r.[RoleId]
        WHERE u.[UserName] IN (N'Company2Admin', N'Company2Manager') AND r.[Name] IN (N'CompanyAdmin', N'CompanyManager');

        INSERT INTO [dbo].[UserCompany] ([UserId], [CompanyId], [IsActive], [CreatedAt], [CreatedBy], [UpdatedAt], [UpdatedBy])
        SELECT u.[UserId], 3, 1, GETUTCDATE(), NULL, NULL, NULL
        FROM [dbo].[User] u INNER JOIN [dbo].[Role] r ON u.[RoleId] = r.[RoleId]
        WHERE u.[UserName] IN (N'Company3Admin', N'Company3Manager') AND r.[Name] IN (N'CompanyAdmin', N'CompanyManager');

        INSERT INTO [dbo].[UserCompany] ([UserId], [CompanyId], [IsActive], [CreatedAt], [CreatedBy], [UpdatedAt], [UpdatedBy])
        SELECT u.[UserId], 4, 1, GETUTCDATE(), NULL, NULL, NULL
        FROM [dbo].[User] u INNER JOIN [dbo].[Role] r ON u.[RoleId] = r.[RoleId]
        WHERE u.[UserName] IN (N'Company4Admin', N'Company4Manager') AND r.[Name] IN (N'CompanyAdmin', N'CompanyManager');
    END
END
GO
