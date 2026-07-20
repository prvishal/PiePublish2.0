-- Employee bulk update batch; original + result .xlsx on app server.
-- Prerequisites: dbo.[User], dbo.Company.
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'EmployeeBulkUpdateBatch')
BEGIN
    CREATE TABLE [dbo].[EmployeeBulkUpdateBatch] (
        [EmployeeBulkUpdateBatchId] INT IDENTITY(1,1) NOT NULL,
        [CompanyId] INT NOT NULL,
        [OriginalFileName] NVARCHAR(260) NOT NULL,
        [OriginalStoredPath] NVARCHAR(400) NOT NULL,
        [ResultStoredPath] NVARCHAR(400) NULL,
        [UploadedByUserId] INT NOT NULL,
        [UploadedAt] DATETIME2(7) NOT NULL CONSTRAINT [DF_EmployeeBulkUpdateBatch_UploadedAt] DEFAULT (GETDATE()),
        [CompletedAt] DATETIME2(7) NULL,
        [Status] VARCHAR(30) NOT NULL CONSTRAINT [DF_EmployeeBulkUpdateBatch_Status] DEFAULT ('Pending'),
        [SuccessCount] INT NULL,
        [FailureCount] INT NULL,
        [SkipCount] INT NULL,
        [TotalRows] INT NULL,
        [ProcessedRowCount] INT NOT NULL CONSTRAINT [DF_EmployeeBulkUpdateBatch_ProcessedRowCount] DEFAULT (0),
        [LastProcessedRow] INT NULL,
        [SupersededByBulkUpdateBatchId] INT NULL,
        [ErrorSummary] NVARCHAR(2000) NULL,
        [HangfireJobId] VARCHAR(100) NULL,
        CONSTRAINT [PK_EmployeeBulkUpdateBatch] PRIMARY KEY ([EmployeeBulkUpdateBatchId]),
        CONSTRAINT [FK_EmployeeBulkUpdateBatch_Company] FOREIGN KEY ([CompanyId])
            REFERENCES [dbo].[Company] ([CompanyId]),
        CONSTRAINT [FK_EmployeeBulkUpdateBatch_UploadedByUser] FOREIGN KEY ([UploadedByUserId])
            REFERENCES [dbo].[User] ([UserId])
    );

    CREATE NONCLUSTERED INDEX [IX_EmployeeBulkUpdateBatch_CompanyId_UploadedAt]
        ON [dbo].[EmployeeBulkUpdateBatch]([CompanyId], [UploadedAt] DESC);

    CREATE NONCLUSTERED INDEX [IX_EmployeeBulkUpdateBatch_UploadedByUserId]
        ON [dbo].[EmployeeBulkUpdateBatch]([UploadedByUserId]);

    CREATE NONCLUSTERED INDEX [IX_EmployeeBulkUpdateBatch_Status_UploadedAt]
        ON [dbo].[EmployeeBulkUpdateBatch]([Status], [UploadedAt]);
END
GO
