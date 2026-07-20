-- Seed Marital lookup values from docs/marital status arabic english.xlsx.
-- MaritalId and SortOrder both start at 1. Column order matches VALUES order.
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Marital') AND NOT EXISTS (SELECT 1 FROM [dbo].[Marital])
BEGIN
    SET IDENTITY_INSERT [dbo].[Marital] ON;
    INSERT INTO [dbo].[Marital] (
        [MaritalId], [Name], [NameAr], [SortOrder],
        [CreatedAt], [CreatedBy], [UpdatedAt], [UpdatedBy], [DeletedAt], [DeletedBy]
    )
    VALUES
        (1, N'Single',           N'أعزب/عزباء',                  1, GETDATE(), NULL, NULL, NULL, NULL, NULL),
        (2, N'Married-Have kids', N'متزوج/متزوجة ولدي أطفال',     2, GETDATE(), NULL, NULL, NULL, NULL, NULL),
        (3, N'Married-No Kids',   N'متزوج/متزوجة بدون أطفال',     3, GETDATE(), NULL, NULL, NULL, NULL, NULL),
        (4, N'Divorced',          N'مطلق/مطلقة',                  4, GETDATE(), NULL, NULL, NULL, NULL, NULL),
        (5, N'Widower/Widow',     N'أرمل/أرملة',                  5, GETDATE(), NULL, NULL, NULL, NULL, NULL);
    SET IDENTITY_INSERT [dbo].[Marital] OFF;
END
GO
