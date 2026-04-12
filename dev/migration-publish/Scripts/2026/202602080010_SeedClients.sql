-- Seed two clients. Runs only once (tracked in __ScriptHistory).
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Client') AND NOT EXISTS (SELECT 1 FROM [dbo].[Client])
BEGIN
    SET IDENTITY_INSERT [dbo].[Client] ON;
    INSERT INTO [dbo].[Client] ([ClientId], [ClientName], [Notes], [Address], [Mobile], [Phone], [IsActive], [CreatedAt], [CreatedBy], [UpdatedAt], [UpdatedBy], [DeletedAt], [DeletedBy])
    VALUES
        (1, N'Client One', NULL, N'123 Main Street, City', N'+1 555-0100', N'+1 555-0199', 1, GETDATE(), NULL, NULL, NULL, NULL, NULL),
        (2, N'Client Two', NULL, N'456 Oak Avenue, Town', N'+1 555-0200', N'+1 555-0299', 1, GETDATE(), NULL, NULL, NULL, NULL, NULL);
    SET IDENTITY_INSERT [dbo].[Client] OFF;
END
GO
