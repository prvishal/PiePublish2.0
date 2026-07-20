-- Seed UserClient mapper: link ClientAdmin and ClientManager users to their clients. Runs only once (tracked in __ScriptHistory).
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'UserClient') AND EXISTS (SELECT * FROM sys.tables WHERE name = 'User') AND EXISTS (SELECT * FROM sys.tables WHERE name = 'Client')
BEGIN
    IF NOT EXISTS (SELECT 1 FROM [dbo].[UserClient])
    BEGIN
        INSERT INTO [dbo].[UserClient] ([UserId], [ClientId], [IsActive], [CreatedAt], [CreatedBy], [UpdatedAt], [UpdatedBy])
        SELECT u.[UserId], 1, 1, GETUTCDATE(), NULL, NULL, NULL
        FROM [dbo].[User] u
        INNER JOIN [dbo].[Role] r ON u.[RoleId] = r.[RoleId]
        WHERE u.[UserName] IN (N'Client1Admin', N'Client1Manager') AND r.[Name] IN (N'ClientAdmin', N'ClientManager');

        INSERT INTO [dbo].[UserClient] ([UserId], [ClientId], [IsActive], [CreatedAt], [CreatedBy], [UpdatedAt], [UpdatedBy])
        SELECT u.[UserId], 2, 1, GETUTCDATE(), NULL, NULL, NULL
        FROM [dbo].[User] u
        INNER JOIN [dbo].[Role] r ON u.[RoleId] = r.[RoleId]
        WHERE u.[UserName] IN (N'Client2Admin', N'Client2Manager') AND r.[Name] IN (N'ClientAdmin', N'ClientManager');
    END
END
GO
