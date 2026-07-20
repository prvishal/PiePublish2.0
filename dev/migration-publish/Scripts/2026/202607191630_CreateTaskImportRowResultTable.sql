IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'TaskImportRowResult')
BEGIN
    CREATE TABLE [dbo].[TaskImportRowResult] (
        [TaskImportRowResultId] INT IDENTITY(1,1) NOT NULL,
        [TaskImportBatchId] INT NOT NULL,
        [RowNumber] INT NOT NULL,
        [Email] NVARCHAR(255) NULL,
        [Status] VARCHAR(20) NOT NULL,
        [Message] NVARCHAR(2000) NULL,
        [EmployeeTaskId] INT NULL,
        [Action] VARCHAR(20) NULL,
        CONSTRAINT [PK_TaskImportRowResult] PRIMARY KEY ([TaskImportRowResultId]),
        CONSTRAINT [FK_TaskImportRowResult_Batch] FOREIGN KEY ([TaskImportBatchId])
            REFERENCES [dbo].[TaskImportBatch] ([TaskImportBatchId]) ON DELETE CASCADE
    );

    CREATE UNIQUE NONCLUSTERED INDEX [UX_TaskImportRowResult_Batch_RowNumber]
        ON [dbo].[TaskImportRowResult]([TaskImportBatchId], [RowNumber]);
END
GO
