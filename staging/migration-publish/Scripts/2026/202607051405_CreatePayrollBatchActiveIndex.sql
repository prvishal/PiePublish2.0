-- Repair script: if 202607051000 failed after CREATE TABLE but before indexes (NOT IN syntax error).
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'PayrollBatch')
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM sys.indexes
        WHERE name = 'UX_PayrollBatch_Company_Period_Active'
          AND object_id = OBJECT_ID(N'dbo.PayrollBatch'))
    BEGIN
        CREATE UNIQUE NONCLUSTERED INDEX [UX_PayrollBatch_Company_Period_Active]
            ON [dbo].[PayrollBatch]([CompanyId], [PayrollYear], [PayrollMonth])
            WHERE [DeletedAt] IS NULL
              AND [BatchStatus] IN ('Pending', 'Processing', 'Completed', 'Approved');
    END

    IF NOT EXISTS (
        SELECT 1 FROM sys.indexes
        WHERE name = 'IX_PayrollBatch_CompanyId_ProcessedAt'
          AND object_id = OBJECT_ID(N'dbo.PayrollBatch'))
    BEGIN
        CREATE NONCLUSTERED INDEX [IX_PayrollBatch_CompanyId_ProcessedAt]
            ON [dbo].[PayrollBatch]([CompanyId], [ProcessedAt] DESC)
            INCLUDE ([PayrollYear], [PayrollMonth], [BatchStatus], [DeletedAt]);
    END
END
GO
