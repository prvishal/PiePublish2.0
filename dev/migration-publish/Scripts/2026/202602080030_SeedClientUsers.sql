-- Seed ClientAdmin and ClientManager users for both clients. Only inserts if user does not exist.
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'User') AND EXISTS (SELECT * FROM sys.tables WHERE name = 'Role')
BEGIN
    DECLARE @ClientAdminRoleId INT = (SELECT RoleId FROM [dbo].[Role] WHERE Name = N'ClientAdmin');
    DECLARE @ClientManagerRoleId INT = (SELECT RoleId FROM [dbo].[Role] WHERE Name = N'ClientManager');
    DECLARE @DefaultPassword NVARCHAR(500) = N'ChangeMe123!';

    -- Client 1 - Admin
    IF @ClientAdminRoleId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM [dbo].[User] WHERE UserName = N'Client1Admin')
    BEGIN
        INSERT INTO [dbo].[User] ([UserName], [Email], [Password], [FirstName], [LastName], [IsActive], [RoleId], [CreatedAt], [UpdatedAt])
        VALUES (N'Client1Admin', N'Client1Admin@telepie.local', @DefaultPassword, N'Client1', N'Admin', 1, @ClientAdminRoleId, GETDATE(), NULL);
    END

    -- Client 1 - Manager
    IF @ClientManagerRoleId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM [dbo].[User] WHERE UserName = N'Client1Manager')
    BEGIN
        INSERT INTO [dbo].[User] ([UserName], [Email], [Password], [FirstName], [LastName], [IsActive], [RoleId], [CreatedAt], [UpdatedAt])
        VALUES (N'Client1Manager', N'Client1Manager@telepie.local', @DefaultPassword, N'Client1', N'Manager', 1, @ClientManagerRoleId, GETDATE(), NULL);
    END

    -- Client 2 - Admin
    IF @ClientAdminRoleId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM [dbo].[User] WHERE UserName = N'Client2Admin')
    BEGIN
        INSERT INTO [dbo].[User] ([UserName], [Email], [Password], [FirstName], [LastName], [IsActive], [RoleId], [CreatedAt], [UpdatedAt])
        VALUES (N'Client2Admin', N'Client2Admin@telepie.local', @DefaultPassword, N'Client2', N'Admin', 1, @ClientAdminRoleId, GETDATE(), NULL);
    END

    -- Client 2 - Manager
    IF @ClientManagerRoleId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM [dbo].[User] WHERE UserName = N'Client2Manager')
    BEGIN
        INSERT INTO [dbo].[User] ([UserName], [Email], [Password], [FirstName], [LastName], [IsActive], [RoleId], [CreatedAt], [UpdatedAt])
        VALUES (N'Client2Manager', N'Client2Manager@telepie.local', @DefaultPassword, N'Client2', N'Manager', 1, @ClientManagerRoleId, GETDATE(), NULL);
    END
END
GO
