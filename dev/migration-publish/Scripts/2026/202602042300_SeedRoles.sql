-- Seed Role (singular table). Runs only once (tracked in __ScriptHistory).
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Role') AND NOT EXISTS (SELECT 1 FROM [dbo].[Role])
BEGIN
    SET IDENTITY_INSERT [dbo].[Role] ON;
    INSERT INTO [dbo].[Role] ([RoleId], [Name], [Description], [CreatedAt], [UpdatedAt])
    VALUES
        (1, N'PieAdmin', N'Pie administrator with full access', GETDATE(), NULL),
        (2, N'PieManager', N'Pie manager role', GETDATE(), NULL),
        (3, N'ClientAdmin', N'Client administrator', GETDATE(), NULL),
        (4, N'ClientManager', N'Client manager role', GETDATE(), NULL),
        (5, N'CompanyAdmin', N'Company administrator', GETDATE(), NULL),
        (6, N'CompanyManager', N'Company manager role', GETDATE(), NULL),
        (7, N'Employee', N'Employee role', GETDATE(), NULL);
    SET IDENTITY_INSERT [dbo].[Role] OFF;
END
GO
