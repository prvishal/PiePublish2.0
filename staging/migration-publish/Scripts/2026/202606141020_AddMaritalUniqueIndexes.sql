-- Fix unique constraints if 202606141000 already ran with UQ_Marital_Name only.
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Marital')
BEGIN
    IF EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'UQ_Marital_Name')
        ALTER TABLE [dbo].[Marital] DROP CONSTRAINT [UQ_Marital_Name];

    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_Marital_Name_Active')
        CREATE UNIQUE NONCLUSTERED INDEX [UX_Marital_Name_Active]
            ON [dbo].[Marital]([Name])
            WHERE [DeletedAt] IS NULL;

    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_Marital_NameAr_Active')
        CREATE UNIQUE NONCLUSTERED INDEX [UX_Marital_NameAr_Active]
            ON [dbo].[Marital]([NameAr])
            WHERE [DeletedAt] IS NULL;
END
GO
