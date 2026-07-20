IF EXISTS (SELECT * FROM sys.tables WHERE name = 'EmployeeEmployment')
   AND COL_LENGTH('dbo.EmployeeEmployment', 'CompanyBatchId') IS NULL
BEGIN
    ALTER TABLE [dbo].[EmployeeEmployment]
        ADD [CompanyBatchId] INT NULL;
END
GO

IF COL_LENGTH('dbo.EmployeeEmployment', 'CompanyBatchId') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_EmployeeEmployment_CompanyBatch')
BEGIN
    ALTER TABLE [dbo].[EmployeeEmployment]
        ADD CONSTRAINT [FK_EmployeeEmployment_CompanyBatch]
            FOREIGN KEY ([CompanyBatchId])
            REFERENCES [dbo].[CompanyBatch] ([CompanyBatchId])
            ON DELETE NO ACTION;
END
GO

IF COL_LENGTH('dbo.EmployeeEmployment', 'CompanyBatchId') IS NOT NULL
   AND COL_LENGTH('dbo.Company', 'DefaultCompanyBatchId') IS NOT NULL
BEGIN
    UPDATE ee
    SET ee.[CompanyBatchId] = c.[DefaultCompanyBatchId]
    FROM [dbo].[EmployeeEmployment] ee
    INNER JOIN [dbo].[Company] c ON c.[CompanyId] = ee.[CompanyId]
    WHERE ee.[CompanyBatchId] IS NULL
      AND ee.[DeletedAt] IS NULL
      AND c.[DefaultCompanyBatchId] IS NOT NULL;
END
GO

IF COL_LENGTH('dbo.EmployeeEmployment', 'CompanyBatchId') IS NOT NULL
   AND NOT EXISTS (
       SELECT 1 FROM sys.indexes
       WHERE name = 'IX_EmployeeEmployment_CompanyBatchId'
         AND object_id = OBJECT_ID('dbo.EmployeeEmployment'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_EmployeeEmployment_CompanyBatchId]
        ON [dbo].[EmployeeEmployment]([CompanyBatchId])
        WHERE [CompanyBatchId] IS NOT NULL AND [DeletedAt] IS NULL;
END
GO
