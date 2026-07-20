-- Payroll run error log (company-level and per-employee failures).
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'PayrollRunErrorLog')
BEGIN
    CREATE TABLE [dbo].[PayrollRunErrorLog] (
        [PayrollRunErrorLogId]   INT IDENTITY(1,1) NOT NULL,
        [PayrollRunId]           INT NULL,
        [PayrollRunCompanyId]    INT NULL,
        [PayrollBatchId]         INT NULL,
        [EmploymentId]           INT NULL,
        [EmployeeId]             INT NULL,
        [ErrorSource]            NVARCHAR(30) NOT NULL,
        [ErrorMessage]           NVARCHAR(2000) NOT NULL,
        [ErrorNumber]            INT NULL,
        [ErrorLine]              INT NULL,
        [CreatedAt]              DATETIME2(7) NOT NULL
            CONSTRAINT [DF_PayrollRunErrorLog_CreatedAt] DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT [PK_PayrollRunErrorLog] PRIMARY KEY ([PayrollRunErrorLogId]),
        CONSTRAINT [FK_PayrollRunErrorLog_PayrollRun] FOREIGN KEY ([PayrollRunId])
            REFERENCES [dbo].[PayrollRun] ([PayrollRunId]) ON DELETE NO ACTION,
        CONSTRAINT [FK_PayrollRunErrorLog_PayrollRunCompany] FOREIGN KEY ([PayrollRunCompanyId])
            REFERENCES [dbo].[PayrollRunCompany] ([PayrollRunCompanyId]) ON DELETE NO ACTION,
        CONSTRAINT [FK_PayrollRunErrorLog_PayrollBatch] FOREIGN KEY ([PayrollBatchId])
            REFERENCES [dbo].[PayrollBatch] ([PayrollBatchId]) ON DELETE NO ACTION
    );

    CREATE NONCLUSTERED INDEX [IX_PayrollRunErrorLog_RunId_CreatedAt]
        ON [dbo].[PayrollRunErrorLog]([PayrollRunId], [CreatedAt] DESC);

    CREATE NONCLUSTERED INDEX [IX_PayrollRunErrorLog_RunCompanyId_CreatedAt]
        ON [dbo].[PayrollRunErrorLog]([PayrollRunCompanyId], [CreatedAt] DESC);
END
GO
