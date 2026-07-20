-- Per-row outcomes for employee bulk update batches.
-- Prerequisites: dbo.EmployeeBulkUpdateBatch.
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'EmployeeBulkUpdateRowResult')
BEGIN
    CREATE TABLE [dbo].[EmployeeBulkUpdateRowResult] (
        [EmployeeBulkUpdateRowResultId] INT IDENTITY(1,1) NOT NULL,
        [EmployeeBulkUpdateBatchId] INT NOT NULL,
        [RowNumber] INT NOT NULL,
        [NationalId] NVARCHAR(50) NULL,
        [Email] NVARCHAR(255) NULL,
        [Status] VARCHAR(20) NOT NULL,
        [Message] NVARCHAR(2000) NULL,
        [EmployeeId] INT NULL,
        [Action] VARCHAR(30) NULL,
        [ColumnsApplied] NVARCHAR(1000) NULL,
        CONSTRAINT [PK_EmployeeBulkUpdateRowResult] PRIMARY KEY ([EmployeeBulkUpdateRowResultId]),
        CONSTRAINT [FK_EmployeeBulkUpdateRowResult_Batch] FOREIGN KEY ([EmployeeBulkUpdateBatchId])
            REFERENCES [dbo].[EmployeeBulkUpdateBatch] ([EmployeeBulkUpdateBatchId]) ON DELETE CASCADE
    );

    CREATE NONCLUSTERED INDEX [IX_EmployeeBulkUpdateRowResult_BatchId_RowNumber]
        ON [dbo].[EmployeeBulkUpdateRowResult]([EmployeeBulkUpdateBatchId], [RowNumber]);
END
GO
