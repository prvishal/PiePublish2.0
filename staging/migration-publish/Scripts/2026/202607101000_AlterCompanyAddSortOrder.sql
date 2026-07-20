-- Per-client company display/process order.
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID(N'dbo.Company') AND name = N'SortOrder')
BEGIN
    ALTER TABLE [dbo].[Company]
        ADD [SortOrder] INT NOT NULL
            CONSTRAINT [DF_Company_SortOrder] DEFAULT (0);
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_Company_ClientId_SortOrder'
      AND object_id = OBJECT_ID(N'dbo.Company'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_Company_ClientId_SortOrder]
        ON [dbo].[Company]([ClientId], [SortOrder], [CompanyId])
        WHERE [DeletedAt] IS NULL;
END
GO
