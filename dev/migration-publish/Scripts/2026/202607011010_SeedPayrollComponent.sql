-- Seed payroll components. Basic is system-required for every company.
IF NOT EXISTS (SELECT 1 FROM [dbo].[PayrollComponent] WHERE [Code] = 'Basic' AND [DeletedAt] IS NULL)
    INSERT INTO [dbo].[PayrollComponent] ([Code], [Name], [NameAr], [SortOrder], [IsSystem])
    VALUES ('Basic', N'Basic', N'أساسي', 1, 1);
GO

IF NOT EXISTS (SELECT 1 FROM [dbo].[PayrollComponent] WHERE [Code] = 'Medical' AND [DeletedAt] IS NULL)
    INSERT INTO [dbo].[PayrollComponent] ([Code], [Name], [NameAr], [SortOrder], [IsSystem])
    VALUES ('Medical', N'Medical', N'طبي', 2, 0);
GO

IF NOT EXISTS (SELECT 1 FROM [dbo].[PayrollComponent] WHERE [Code] = 'Transport' AND [DeletedAt] IS NULL)
    INSERT INTO [dbo].[PayrollComponent] ([Code], [Name], [NameAr], [SortOrder], [IsSystem])
    VALUES ('Transport', N'Transport', N'مواصلات', 3, 0);
GO

IF NOT EXISTS (SELECT 1 FROM [dbo].[PayrollComponent] WHERE [Code] = 'Education' AND [DeletedAt] IS NULL)
    INSERT INTO [dbo].[PayrollComponent] ([Code], [Name], [NameAr], [SortOrder], [IsSystem])
    VALUES ('Education', N'Education', N'تعليم', 4, 0);
GO

IF NOT EXISTS (SELECT 1 FROM [dbo].[PayrollComponent] WHERE [Code] = 'Social' AND [DeletedAt] IS NULL)
    INSERT INTO [dbo].[PayrollComponent] ([Code], [Name], [NameAr], [SortOrder], [IsSystem])
    VALUES ('Social', N'Social', N'اجتماعي', 5, 0);
GO

IF NOT EXISTS (SELECT 1 FROM [dbo].[PayrollComponent] WHERE [Code] = 'Housing' AND [DeletedAt] IS NULL)
    INSERT INTO [dbo].[PayrollComponent] ([Code], [Name], [NameAr], [SortOrder], [IsSystem])
    VALUES ('Housing', N'Housing', N'سكن', 6, 0);
GO
