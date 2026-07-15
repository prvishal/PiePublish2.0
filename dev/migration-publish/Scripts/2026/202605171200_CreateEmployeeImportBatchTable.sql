-- Employee bulk import batch; original + result .xlsx on app server.
-- Prerequisites: dbo.[User], dbo.Company.
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'EmployeeImportBatch')
BEGIN
    CREATE TABLE [dbo].[EmployeeImportBatch] (
        [EmployeeImportBatchId] INT IDENTITY(1,1) NOT NULL,
        [CompanyId] INT NOT NULL,
        [OriginalFileName] NVARCHAR(260) NOT NULL,
        [OriginalStoredPath] NVARCHAR(400) NOT NULL,
        [ResultStoredPath] NVARCHAR(400) NULL,
        [UploadedByUserId] INT NOT NULL,
        [UploadedAt] DATETIME2(7) NOT NULL CONSTRAINT [DF_EmployeeImportBatch_UploadedAt] DEFAULT (GETDATE()),
        [CompletedAt] DATETIME2(7) NULL,
        [Status] VARCHAR(30) NOT NULL CONSTRAINT [DF_EmployeeImportBatch_Status] DEFAULT ('Pending'),
        [SuccessCount] INT NULL,
        [FailureCount] INT NULL,
        [TotalRows] INT NULL,
        [ErrorSummary] NVARCHAR(2000) NULL,
        [HangfireJobId] VARCHAR(100) NULL,
        CONSTRAINT [PK_EmployeeImportBatch] PRIMARY KEY ([EmployeeImportBatchId]),
        CONSTRAINT [FK_EmployeeImportBatch_Company] FOREIGN KEY ([CompanyId])
            REFERENCES [dbo].[Company] ([CompanyId]),
        CONSTRAINT [FK_EmployeeImportBatch_UploadedByUser] FOREIGN KEY ([UploadedByUserId])
            REFERENCES [dbo].[User] ([UserId])
    );

    CREATE NONCLUSTERED INDEX [IX_EmployeeImportBatch_CompanyId_UploadedAt]
        ON [dbo].[EmployeeImportBatch]([CompanyId], [UploadedAt] DESC);

    CREATE NONCLUSTERED INDEX [IX_EmployeeImportBatch_UploadedByUserId]
        ON [dbo].[EmployeeImportBatch]([UploadedByUserId]);

    CREATE NONCLUSTERED INDEX [IX_EmployeeImportBatch_Status_UploadedAt]
        ON [dbo].[EmployeeImportBatch]([Status], [UploadedAt]);
END
GO
