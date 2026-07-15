-- Per-row outcomes for employee bulk import batches.
-- Prerequisites: dbo.EmployeeImportBatch.
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'EmployeeImportRowResult')
BEGIN
    CREATE TABLE [dbo].[EmployeeImportRowResult] (
        [EmployeeImportRowResultId] INT IDENTITY(1,1) NOT NULL,
        [EmployeeImportBatchId] INT NOT NULL,
        [RowNumber] INT NOT NULL,
        [Email] NVARCHAR(255) NULL,
        [Status] VARCHAR(20) NOT NULL,
        [Message] NVARCHAR(2000) NULL,
        [EmployeeId] INT NULL,
        [Action] VARCHAR(20) NULL,
        CONSTRAINT [PK_EmployeeImportRowResult] PRIMARY KEY ([EmployeeImportRowResultId]),
        CONSTRAINT [FK_EmployeeImportRowResult_Batch] FOREIGN KEY ([EmployeeImportBatchId])
            REFERENCES [dbo].[EmployeeImportBatch] ([EmployeeImportBatchId]) ON DELETE CASCADE
    );

    CREATE NONCLUSTERED INDEX [IX_EmployeeImportRowResult_BatchId_RowNumber]
        ON [dbo].[EmployeeImportRowResult]([EmployeeImportBatchId], [RowNumber]);
END
GO
