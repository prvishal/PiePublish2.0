-- Hard-remove NumberOfEmployees from catalog and company plan requests.
-- Headcount is always derived from active employees at invoice time.

IF COL_LENGTH(N'dbo.EmployeePlan', N'NumberOfEmployees') IS NOT NULL
BEGIN
    ALTER TABLE [dbo].[EmployeePlan]
        DROP COLUMN [NumberOfEmployees];
END
GO

IF COL_LENGTH(N'dbo.CompanyEmployeePlanRequest', N'NumberOfEmployees') IS NOT NULL
BEGIN
    ALTER TABLE [dbo].[CompanyEmployeePlanRequest]
        DROP COLUMN [NumberOfEmployees];
END
GO
