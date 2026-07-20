-- Add UpdateType to employee bulk update batches (EmployeeInfo | Payroll).
-- Prerequisites: dbo.EmployeeBulkUpdateBatch.
IF COL_LENGTH('dbo.EmployeeBulkUpdateBatch', 'UpdateType') IS NULL
BEGIN
    ALTER TABLE [dbo].[EmployeeBulkUpdateBatch]
        ADD [UpdateType] VARCHAR(20) NULL;
END
GO
