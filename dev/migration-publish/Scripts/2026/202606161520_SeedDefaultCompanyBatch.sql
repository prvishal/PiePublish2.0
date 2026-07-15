-- One DEFAULT batch (8 hours) per existing active company; set DefaultCompanyBatchId.
-- Prerequisites: 202606161500, 202606161510.
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'CompanyBatch')
BEGIN
    INSERT INTO [dbo].[CompanyBatch] (
        [CompanyId], [BatchId], [BatchName], [WorkingHoursPerDay], [CreatedAt])
    SELECT
        c.[CompanyId], 'DEFAULT', N'Default Batch', 8.0, GETDATE()
    FROM [dbo].[Company] c
    WHERE c.[DeletedAt] IS NULL
      AND NOT EXISTS (
          SELECT 1 FROM [dbo].[CompanyBatch] cb
          WHERE cb.[CompanyId] = c.[CompanyId] AND cb.[BatchId] = 'DEFAULT');
END
GO

IF COL_LENGTH('dbo.Company', 'DefaultCompanyBatchId') IS NOT NULL
BEGIN
    UPDATE c
    SET c.[DefaultCompanyBatchId] = cb.[CompanyBatchId]
    FROM [dbo].[Company] c
    INNER JOIN [dbo].[CompanyBatch] cb
        ON cb.[CompanyId] = c.[CompanyId] AND cb.[BatchId] = 'DEFAULT'
    WHERE c.[DeletedAt] IS NULL
      AND c.[DefaultCompanyBatchId] IS NULL;
END
GO
