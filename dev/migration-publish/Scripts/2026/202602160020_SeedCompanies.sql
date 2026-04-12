-- Seed 4 companies: 2 per client. Runs only once (tracked in __ScriptHistory).
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Company') AND EXISTS (SELECT * FROM sys.tables WHERE name = 'Client')
BEGIN
    IF NOT EXISTS (SELECT 1 FROM [dbo].[Company])
    BEGIN
        SET IDENTITY_INSERT [dbo].[Company] ON;
        INSERT INTO [dbo].[Company] ([CompanyId], [ClientId], [CompanyName], [Description], [EstLaborOfficeId], [Mobile], [City], [Address], [Website], [Fax], [Phone], [Logo], [RegistrationDate], [ValidityTill], [CR_Number], [InsuranceIDNumber], [MID], [Industry], [EstSequenceNumber], [DeletedAt], [DeletedBy])
        VALUES
            (1, 1, N'Company One A', N'First company for Client One', NULL, N'+1 555-1001', N'City', N'100 Main St', NULL, NULL, NULL, NULL, CAST(GETDATE() AS DATE), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
            (2, 1, N'Company One B', N'Second company for Client One', NULL, N'+1 555-1002', N'City', N'101 Main St', NULL, NULL, NULL, NULL, CAST(GETDATE() AS DATE), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
            (3, 2, N'Company Two A', N'First company for Client Two', NULL, N'+1 555-2001', N'Town', N'200 Oak Ave', NULL, NULL, NULL, NULL, CAST(GETDATE() AS DATE), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
            (4, 2, N'Company Two B', N'Second company for Client Two', NULL, N'+1 555-2002', N'Town', N'201 Oak Ave', NULL, NULL, NULL, NULL, CAST(GETDATE() AS DATE), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
        SET IDENTITY_INSERT [dbo].[Company] OFF;
    END
END
GO
