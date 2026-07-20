-- Monthly payroll batch: one company + year + month.
-- Prerequisites: dbo.Company, dbo.[User]
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'PayrollBatch')
BEGIN
    CREATE TABLE [dbo].[PayrollBatch] (
        [PayrollBatchId]             INT IDENTITY(1,1) NOT NULL,
        [CompanyId]                  INT NOT NULL,
        [PayrollYear]                SMALLINT NOT NULL,
        [PayrollMonth]               TINYINT NOT NULL,
        [PeriodStart]                DATE NOT NULL,
        [PeriodEnd]                  DATE NOT NULL,

        [ProcessedAt]                DATETIME2(7) NULL,
        [ProcessedByUserId]          INT NULL,

        [DaysDivisor]                INT NOT NULL
            CONSTRAINT [DF_PayrollBatch_DaysDivisor] DEFAULT (30),
        [CurrencyCode]               CHAR(3) NOT NULL
            CONSTRAINT [DF_PayrollBatch_CurrencyCode] DEFAULT ('SAR'),

        [BatchStatus]                NVARCHAR(20) NOT NULL
            CONSTRAINT [DF_PayrollBatch_BatchStatus] DEFAULT ('Pending'),
        [HangfireJobId]              NVARCHAR(100) NULL,

        [SuccessCount]               INT NOT NULL CONSTRAINT [DF_PayrollBatch_SuccessCount] DEFAULT (0),
        [SkippedCount]               INT NOT NULL CONSTRAINT [DF_PayrollBatch_SkippedCount] DEFAULT (0),
        [FailureCount]               INT NOT NULL CONSTRAINT [DF_PayrollBatch_FailureCount] DEFAULT (0),
        [ErrorSummary]               NVARCHAR(2000) NULL,

        [ApprovedAt]                 DATETIME2(7) NULL,
        [ApprovedByUserId]           INT NULL,
        [SupersededByPayrollBatchId] INT NULL,

        [CreatedAt]                  DATETIME2(7) NOT NULL
            CONSTRAINT [DF_PayrollBatch_CreatedAt] DEFAULT (GETDATE()),
        [CreatedBy]                  INT NULL,
        [UpdatedAt]                  DATETIME2(7) NULL,
        [UpdatedBy]                  INT NULL,
        [DeletedAt]                  DATETIME2(7) NULL,
        [DeletedBy]                  INT NULL,

        CONSTRAINT [PK_PayrollBatch] PRIMARY KEY ([PayrollBatchId]),
        CONSTRAINT [FK_PayrollBatch_Company] FOREIGN KEY ([CompanyId]) REFERENCES [dbo].[Company] ([CompanyId]),
        CONSTRAINT [FK_PayrollBatch_ProcessedByUser] FOREIGN KEY ([ProcessedByUserId]) REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [FK_PayrollBatch_ApprovedByUser] FOREIGN KEY ([ApprovedByUserId]) REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [FK_PayrollBatch_SupersededBy] FOREIGN KEY ([SupersededByPayrollBatchId]) REFERENCES [dbo].[PayrollBatch] ([PayrollBatchId]),
        CONSTRAINT [FK_PayrollBatch_CreatedBy] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [FK_PayrollBatch_UpdatedBy] FOREIGN KEY ([UpdatedBy]) REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [FK_PayrollBatch_DeletedBy] FOREIGN KEY ([DeletedBy]) REFERENCES [dbo].[User] ([UserId]),

        CONSTRAINT [CK_PayrollBatch_PayrollMonth] CHECK ([PayrollMonth] BETWEEN 1 AND 12),
        CONSTRAINT [CK_PayrollBatch_PayrollYear] CHECK ([PayrollYear] BETWEEN 2000 AND 2100),
        CONSTRAINT [CK_PayrollBatch_DaysDivisor] CHECK ([DaysDivisor] > 0),
        CONSTRAINT [CK_PayrollBatch_PeriodRange] CHECK ([PeriodEnd] >= [PeriodStart])
    );

    CREATE UNIQUE NONCLUSTERED INDEX [UX_PayrollBatch_Company_Period_Active]
        ON [dbo].[PayrollBatch]([CompanyId], [PayrollYear], [PayrollMonth])
        WHERE [DeletedAt] IS NULL
          AND [BatchStatus] IN ('Pending', 'Processing', 'Completed', 'Approved');

    CREATE NONCLUSTERED INDEX [IX_PayrollBatch_CompanyId_ProcessedAt]
        ON [dbo].[PayrollBatch]([CompanyId], [ProcessedAt] DESC)
        INCLUDE ([PayrollYear], [PayrollMonth], [BatchStatus], [DeletedAt]);
END
GO
