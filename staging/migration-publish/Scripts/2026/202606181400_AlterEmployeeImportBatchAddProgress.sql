IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID(N'[dbo].[EmployeeImportBatch]') AND name = N'ProcessedRowCount')
BEGIN
    ALTER TABLE [dbo].[EmployeeImportBatch]
        ADD [ProcessedRowCount] INT NOT NULL CONSTRAINT [DF_EmployeeImportBatch_ProcessedRowCount] DEFAULT (0);
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID(N'[dbo].[EmployeeImportBatch]') AND name = N'LastProcessedRow')
BEGIN
    ALTER TABLE [dbo].[EmployeeImportBatch]
        ADD [LastProcessedRow] INT NULL;
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID(N'[dbo].[EmployeeImportBatch]') AND name = N'SupersededByImportBatchId')
BEGIN
    ALTER TABLE [dbo].[EmployeeImportBatch]
        ADD [SupersededByImportBatchId] INT NULL;
END
GO
