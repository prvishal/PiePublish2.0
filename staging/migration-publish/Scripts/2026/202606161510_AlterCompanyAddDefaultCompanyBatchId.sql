IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Company')
   AND EXISTS (SELECT * FROM sys.tables WHERE name = 'CompanyBatch')
BEGIN
    IF COL_LENGTH('dbo.Company', 'DefaultCompanyBatchId') IS NULL
        ALTER TABLE [dbo].[Company]
            ADD [DefaultCompanyBatchId] INT NULL;
END
GO

IF COL_LENGTH('dbo.Company', 'DefaultCompanyBatchId') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Company_DefaultCompanyBatch')
BEGIN
    ALTER TABLE [dbo].[Company]
        ADD CONSTRAINT [FK_Company_DefaultCompanyBatch]
            FOREIGN KEY ([DefaultCompanyBatchId])
            REFERENCES [dbo].[CompanyBatch] ([CompanyBatchId])
            ON DELETE NO ACTION;
END
GO
