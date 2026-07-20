IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'PayrollRun')
BEGIN
    CREATE TABLE [dbo].[PayrollRun] (
        [PayrollRunId]              INT IDENTITY(1,1) NOT NULL,
        [PayrollYear]               SMALLINT NOT NULL,
        [PayrollMonth]              TINYINT NOT NULL,
        [RunType]                   NVARCHAR(10) NOT NULL,
        [RunStatus]                 NVARCHAR(20) NOT NULL
            CONSTRAINT [DF_PayrollRun_RunStatus] DEFAULT ('Pending'),

        [ClientId]                  INT NULL,
        [TotalCompanyCount]         INT NOT NULL CONSTRAINT [DF_PayrollRun_TotalCompanyCount] DEFAULT (0),
        [CompletedCompanyCount]     INT NOT NULL CONSTRAINT [DF_PayrollRun_CompletedCompanyCount] DEFAULT (0),
        [FailedCompanyCount]        INT NOT NULL CONSTRAINT [DF_PayrollRun_FailedCompanyCount] DEFAULT (0),
        [SkippedCompanyCount]       INT NOT NULL CONSTRAINT [DF_PayrollRun_SkippedCompanyCount] DEFAULT (0),

        [HangfireOrchestratorJobId] NVARCHAR(100) NULL,
        [ErrorSummary]              NVARCHAR(2000) NULL,

        [CreatedAt]                 DATETIME2(7) NOT NULL CONSTRAINT [DF_PayrollRun_CreatedAt] DEFAULT (GETDATE()),
        [CreatedBy]                 INT NULL,
        [UpdatedAt]                 DATETIME2(7) NULL,
        [UpdatedBy]                 INT NULL,
        [CompletedAt]               DATETIME2(7) NULL,
        [CancelledAt]               DATETIME2(7) NULL,
        [DeletedAt]                 DATETIME2(7) NULL,
        [DeletedBy]                 INT NULL,

        CONSTRAINT [PK_PayrollRun] PRIMARY KEY ([PayrollRunId]),
        CONSTRAINT [FK_PayrollRun_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId]),
        CONSTRAINT [FK_PayrollRun_CreatedBy] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [FK_PayrollRun_UpdatedBy] FOREIGN KEY ([UpdatedBy]) REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [FK_PayrollRun_DeletedBy] FOREIGN KEY ([DeletedBy]) REFERENCES [dbo].[User] ([UserId]),

        CONSTRAINT [CK_PayrollRun_PayrollMonth] CHECK ([PayrollMonth] BETWEEN 1 AND 12),
        CONSTRAINT [CK_PayrollRun_PayrollYear] CHECK ([PayrollYear] BETWEEN 2000 AND 2100),
        CONSTRAINT [CK_PayrollRun_RunType] CHECK ([RunType] IN ('Single', 'Bulk')),
        CONSTRAINT [CK_PayrollRun_RunStatus] CHECK ([RunStatus] IN (
            'Pending', 'Processing', 'Completed', 'PartialFailed', 'Failed', 'Cancelled', 'Approved'))
    );

    CREATE NONCLUSTERED INDEX [IX_PayrollRun_Period_Status]
        ON [dbo].[PayrollRun]([PayrollYear] DESC, [PayrollMonth] DESC, [RunStatus])
        INCLUDE ([RunType], [ClientId], [CreatedAt], [DeletedAt])
        WHERE [DeletedAt] IS NULL;
END
GO
