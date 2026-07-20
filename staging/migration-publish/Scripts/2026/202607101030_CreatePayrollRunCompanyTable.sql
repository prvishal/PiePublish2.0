IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'PayrollRunCompany')
BEGIN
    CREATE TABLE [dbo].[PayrollRunCompany] (
        [PayrollRunCompanyId]    INT IDENTITY(1,1) NOT NULL,
        [PayrollRunId]           INT NOT NULL,
        [CompanyId]              INT NOT NULL,
        [PayrollBatchId]         INT NULL,
        [ProcessOrder]           INT NOT NULL,

        [CompanyStatus]          NVARCHAR(20) NOT NULL
            CONSTRAINT [DF_PayrollRunCompany_CompanyStatus] DEFAULT ('Pending'),
        [HangfireJobId]          NVARCHAR(100) NULL,

        [SuccessCount]           INT NOT NULL CONSTRAINT [DF_PayrollRunCompany_SuccessCount] DEFAULT (0),
        [SkippedCount]           INT NOT NULL CONSTRAINT [DF_PayrollRunCompany_SkippedCount] DEFAULT (0),
        [FailureCount]           INT NOT NULL CONSTRAINT [DF_PayrollRunCompany_FailureCount] DEFAULT (0),
        [ErrorSummary]           NVARCHAR(2000) NULL,

        [AttemptCount]           INT NOT NULL CONSTRAINT [DF_PayrollRunCompany_AttemptCount] DEFAULT (0),
        [LastError]              NVARCHAR(2000) NULL,
        [LastErrorAt]            DATETIME2(7) NULL,
        [LastErrorSource]        NVARCHAR(30) NULL,

        [StartedAt]              DATETIME2(7) NULL,
        [CompletedAt]            DATETIME2(7) NULL,
        [CreatedAt]              DATETIME2(7) NOT NULL CONSTRAINT [DF_PayrollRunCompany_CreatedAt] DEFAULT (GETDATE()),
        [UpdatedAt]              DATETIME2(7) NULL,

        CONSTRAINT [PK_PayrollRunCompany] PRIMARY KEY ([PayrollRunCompanyId]),
        CONSTRAINT [FK_PayrollRunCompany_PayrollRun] FOREIGN KEY ([PayrollRunId]) REFERENCES [dbo].[PayrollRun] ([PayrollRunId]),
        CONSTRAINT [FK_PayrollRunCompany_Company] FOREIGN KEY ([CompanyId]) REFERENCES [dbo].[Company] ([CompanyId]),
        CONSTRAINT [FK_PayrollRunCompany_PayrollBatch] FOREIGN KEY ([PayrollBatchId]) REFERENCES [dbo].[PayrollBatch] ([PayrollBatchId]),

        CONSTRAINT [CK_PayrollRunCompany_ProcessOrder] CHECK ([ProcessOrder] > 0),
        CONSTRAINT [CK_PayrollRunCompany_CompanyStatus] CHECK ([CompanyStatus] IN (
            'Pending', 'Processing', 'Completed', 'Failed', 'Skipped', 'Cancelled'))
    );

    CREATE UNIQUE NONCLUSTERED INDEX [UX_PayrollRunCompany_Run_Company]
        ON [dbo].[PayrollRunCompany]([PayrollRunId], [CompanyId]);

    CREATE UNIQUE NONCLUSTERED INDEX [UX_PayrollRunCompany_Run_ProcessOrder]
        ON [dbo].[PayrollRunCompany]([PayrollRunId], [ProcessOrder]);

    CREATE NONCLUSTERED INDEX [IX_PayrollRunCompany_Run_Status_ProcessOrder]
        ON [dbo].[PayrollRunCompany]([PayrollRunId], [CompanyStatus], [ProcessOrder])
        INCLUDE ([PayrollBatchId], [CompanyId], [HangfireJobId], [StartedAt]);
END
GO
