-- Add AutoRenew + SuccessorPlanRequestId for plan billing / renewal.
IF COL_LENGTH('dbo.CompanyEmployeePlanRequest', 'AutoRenew') IS NULL
BEGIN
    ALTER TABLE [dbo].[CompanyEmployeePlanRequest]
        ADD [AutoRenew] BIT NOT NULL
            CONSTRAINT [DF_CompanyEmployeePlanRequest_AutoRenew] DEFAULT (0);
END
GO

IF COL_LENGTH('dbo.CompanyEmployeePlanRequest', 'SuccessorPlanRequestId') IS NULL
BEGIN
    ALTER TABLE [dbo].[CompanyEmployeePlanRequest]
        ADD [SuccessorPlanRequestId] INT NULL;
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = N'FK_CompanyEmployeePlanRequest_Successor'
      AND parent_object_id = OBJECT_ID(N'dbo.CompanyEmployeePlanRequest')
)
BEGIN
    ALTER TABLE [dbo].[CompanyEmployeePlanRequest] WITH CHECK
        ADD CONSTRAINT [FK_CompanyEmployeePlanRequest_Successor]
        FOREIGN KEY ([SuccessorPlanRequestId])
        REFERENCES [dbo].[CompanyEmployeePlanRequest] ([CompanyEmployeePlanRequestId])
        ON DELETE NO ACTION;
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_CompanyEmployeePlanRequest_EndDate_Status_AutoRenew'
      AND object_id = OBJECT_ID(N'dbo.CompanyEmployeePlanRequest')
)
BEGIN
    CREATE NONCLUSTERED INDEX [IX_CompanyEmployeePlanRequest_EndDate_Status_AutoRenew]
        ON [dbo].[CompanyEmployeePlanRequest] ([Status], [EndDate], [AutoRenew])
        WHERE [DeletedAt] IS NULL AND [SuccessorPlanRequestId] IS NULL;
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_CompanyEmployeePlanRequest_StartDate_Status'
      AND object_id = OBJECT_ID(N'dbo.CompanyEmployeePlanRequest')
)
BEGIN
    CREATE NONCLUSTERED INDEX [IX_CompanyEmployeePlanRequest_StartDate_Status]
        ON [dbo].[CompanyEmployeePlanRequest] ([Status], [StartDate])
        WHERE [DeletedAt] IS NULL;
END
GO
