-- Task bulk import batch; original + result .xlsx on app server.
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'TaskImportBatch')
BEGIN
    CREATE TABLE [dbo].[TaskImportBatch] (
        [TaskImportBatchId] INT IDENTITY(1,1) NOT NULL,
        [CompanyId] INT NOT NULL,
        [StorageGuid] UNIQUEIDENTIFIER NOT NULL,
        [OriginalFileName] NVARCHAR(260) NOT NULL,
        [OriginalStoredPath] NVARCHAR(400) NOT NULL,
        [ResultStoredPath] NVARCHAR(400) NULL,
        [UploadedByUserId] INT NOT NULL,
        [UploadedAt] DATETIME2(7) NOT NULL CONSTRAINT [DF_TaskImportBatch_UploadedAt] DEFAULT (GETDATE()),
        [CompletedAt] DATETIME2(7) NULL,
        [Status] VARCHAR(30) NOT NULL CONSTRAINT [DF_TaskImportBatch_Status] DEFAULT ('Pending'),
        [SuccessCount] INT NULL,
        [FailureCount] INT NULL,
        [TotalRows] INT NULL,
        [ProcessedRowCount] INT NOT NULL CONSTRAINT [DF_TaskImportBatch_ProcessedRowCount] DEFAULT (0),
        [LastProcessedRow] INT NULL,
        [SupersededByImportBatchId] INT NULL,
        [ErrorSummary] NVARCHAR(2000) NULL,
        [HangfireJobId] VARCHAR(100) NULL,
        CONSTRAINT [PK_TaskImportBatch] PRIMARY KEY ([TaskImportBatchId]),
        CONSTRAINT [FK_TaskImportBatch_Company] FOREIGN KEY ([CompanyId])
            REFERENCES [dbo].[Company] ([CompanyId]),
        CONSTRAINT [FK_TaskImportBatch_UploadedByUser] FOREIGN KEY ([UploadedByUserId])
            REFERENCES [dbo].[User] ([UserId])
    );

    CREATE NONCLUSTERED INDEX [IX_TaskImportBatch_CompanyId_UploadedAt]
        ON [dbo].[TaskImportBatch]([CompanyId], [UploadedAt] DESC);

    CREATE NONCLUSTERED INDEX [IX_TaskImportBatch_Status_UploadedAt]
        ON [dbo].[TaskImportBatch]([Status], [UploadedAt]);
END
GO
