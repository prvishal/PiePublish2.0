-- Add Months + EventMonth on invoice lines.
-- UnitRate stays plan monthly unit price; Amount = UnitRate × Months × EmployeeCount (± ResignReturn).
-- EventMonth = first day of join/resign calendar month (null for Headcount).

IF COL_LENGTH(N'dbo.CompanyPlanInvoiceLine', N'Months') IS NULL
BEGIN
    ALTER TABLE [dbo].[CompanyPlanInvoiceLine]
        ADD [Months] INT NOT NULL
            CONSTRAINT [DF_CompanyPlanInvoiceLine_Months] DEFAULT (1);
END
GO

IF COL_LENGTH(N'dbo.CompanyPlanInvoiceLine', N'EventMonth') IS NULL
BEGIN
    ALTER TABLE [dbo].[CompanyPlanInvoiceLine]
        ADD [EventMonth] DATE NULL;
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE name = N'CK_CompanyPlanInvoiceLine_Months'
      AND parent_object_id = OBJECT_ID(N'dbo.CompanyPlanInvoiceLine')
)
BEGIN
    ALTER TABLE [dbo].[CompanyPlanInvoiceLine]
        ADD CONSTRAINT [CK_CompanyPlanInvoiceLine_Months]
            CHECK ([Months] >= 0);
END
GO
