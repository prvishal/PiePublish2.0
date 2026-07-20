IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID(N'dbo.PayrollBatch') AND name = N'PayrollRunId')
BEGIN
    ALTER TABLE [dbo].[PayrollBatch]
        ADD [PayrollRunId] INT NULL;

    ALTER TABLE [dbo].[PayrollBatch]
        ADD CONSTRAINT [FK_PayrollBatch_PayrollRun]
        FOREIGN KEY ([PayrollRunId]) REFERENCES [dbo].[PayrollRun] ([PayrollRunId]);

    CREATE NONCLUSTERED INDEX [IX_PayrollBatch_PayrollRunId]
        ON [dbo].[PayrollBatch]([PayrollRunId])
        WHERE [DeletedAt] IS NULL;
END
GO
