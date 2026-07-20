-- Default users for PieAdmin and PieManager. Only inserts if user does not exist.
-- Password stored as plain text (no hashing).
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'User') AND EXISTS (SELECT * FROM sys.tables WHERE name = 'Role')
BEGIN
    DECLARE @PieAdminRoleId INT = (SELECT RoleId FROM [dbo].[Role] WHERE Name = N'PieAdmin');
    DECLARE @PieManagerRoleId INT = (SELECT RoleId FROM [dbo].[Role] WHERE Name = N'PieManager');
    DECLARE @DefaultPassword NVARCHAR(500) = N'ChangeMe123!';

    IF @PieAdminRoleId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM [dbo].[User] WHERE UserName = N'PieAdmin' OR Email = N'PieAdmin@telepie.local')
    BEGIN
        INSERT INTO [dbo].[User] ([UserName], [Email], [Password], [FirstName], [LastName], [IsActive], [RoleId], [CreatedAt], [UpdatedAt])
        VALUES (N'PieAdmin', N'PieAdmin@telepie.local', @DefaultPassword, N'Pie', N'Admin', 1, @PieAdminRoleId, GETDATE(), NULL);
    END

    IF @PieManagerRoleId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM [dbo].[User] WHERE UserName = N'PieManager' OR Email = N'PieManager@telepie.local')
    BEGIN
        INSERT INTO [dbo].[User] ([UserName], [Email], [Password], [FirstName], [LastName], [IsActive], [RoleId], [CreatedAt], [UpdatedAt])
        VALUES (N'PieManager', N'PieManager@telepie.local', @DefaultPassword, N'Pie', N'Manager', 1, @PieManagerRoleId, GETDATE(), NULL);
    END
END
GO
