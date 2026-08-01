-- Invoice Cycle allow 1 month; ContractDurationYears + CoveredSeats on company plan requests.
-- Prerequisites: EmployeePlan, CompanyEmployeePlanRequest exist; usp_DeleteAllPlanAndInvoiceData (202607291350).
-- Order: wipe plan/invoice data via SP, then apply schema updates.

-- 0) Clear existing plan / invoice data before schema change
IF OBJECT_ID(N'dbo.usp_DeleteAllPlanAndInvoiceData', N'P') IS NULL
BEGIN
    RAISERROR(N'usp_DeleteAllPlanAndInvoiceData not found. Run 202607291350_CreateSpDeleteAllPlanAndInvoiceData.sql first.', 16, 1);
END
ELSE
BEGIN
    EXEC [dbo].[usp_DeleteAllPlanAndInvoiceData];
END
GO

-- EmployeePlan.Duration: add 1 month (Invoice Cycle)
IF EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE name = N'CK_EmployeePlan_Duration'
      AND parent_object_id = OBJECT_ID(N'dbo.EmployeePlan')
)
BEGIN
    ALTER TABLE [dbo].[EmployeePlan] DROP CONSTRAINT [CK_EmployeePlan_Duration];
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE name = N'CK_EmployeePlan_Duration'
      AND parent_object_id = OBJECT_ID(N'dbo.EmployeePlan')
)
BEGIN
    ALTER TABLE [dbo].[EmployeePlan] WITH CHECK
        ADD CONSTRAINT [CK_EmployeePlan_Duration] CHECK ([Duration] IN (1, 3, 6, 9, 12));
END
GO

-- CompanyEmployeePlanRequest.Duration: add 1 month
IF EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE name = N'CK_CompanyEmployeePlanRequest_Duration'
      AND parent_object_id = OBJECT_ID(N'dbo.CompanyEmployeePlanRequest')
)
BEGIN
    ALTER TABLE [dbo].[CompanyEmployeePlanRequest] DROP CONSTRAINT [CK_CompanyEmployeePlanRequest_Duration];
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE name = N'CK_CompanyEmployeePlanRequest_Duration'
      AND parent_object_id = OBJECT_ID(N'dbo.CompanyEmployeePlanRequest')
)
BEGIN
    ALTER TABLE [dbo].[CompanyEmployeePlanRequest] WITH CHECK
        ADD CONSTRAINT [CK_CompanyEmployeePlanRequest_Duration] CHECK ([Duration] IN (1, 3, 6, 9, 12));
END
GO

-- ContractDurationYears (1-5); default 1 for backfill
IF COL_LENGTH('dbo.CompanyEmployeePlanRequest', 'ContractDurationYears') IS NULL
BEGIN
    ALTER TABLE [dbo].[CompanyEmployeePlanRequest]
        ADD [ContractDurationYears] INT NOT NULL
            CONSTRAINT [DF_CompanyEmployeePlanRequest_ContractDurationYears] DEFAULT (1);
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE name = N'CK_CompanyEmployeePlanRequest_ContractDurationYears'
      AND parent_object_id = OBJECT_ID(N'dbo.CompanyEmployeePlanRequest')
)
BEGIN
    ALTER TABLE [dbo].[CompanyEmployeePlanRequest] WITH CHECK
        ADD CONSTRAINT [CK_CompanyEmployeePlanRequest_ContractDurationYears]
        CHECK ([ContractDurationYears] BETWEEN 1 AND 5);
END
GO

-- Backfill contract years from existing Start/End where possible (ceil years, clamp 1-5)
UPDATE r
SET r.[ContractDurationYears] = CASE
    WHEN DATEDIFF(DAY, r.[StartDate], r.[EndDate]) <= 0 THEN 1
    ELSE
        CASE
            WHEN CAST(CEILING(DATEDIFF(DAY, r.[StartDate], r.[EndDate]) / 365.25) AS INT) < 1 THEN 1
            WHEN CAST(CEILING(DATEDIFF(DAY, r.[StartDate], r.[EndDate]) / 365.25) AS INT) > 5 THEN 5
            ELSE CAST(CEILING(DATEDIFF(DAY, r.[StartDate], r.[EndDate]) / 365.25) AS INT)
        END
END
FROM [dbo].[CompanyEmployeePlanRequest] r
WHERE r.[DeletedAt] IS NULL;
GO

-- CoveredSeats watermark for NewJoining billing
IF COL_LENGTH('dbo.CompanyEmployeePlanRequest', 'CoveredSeats') IS NULL
BEGIN
    ALTER TABLE [dbo].[CompanyEmployeePlanRequest]
        ADD [CoveredSeats] INT NOT NULL
            CONSTRAINT [DF_CompanyEmployeePlanRequest_CoveredSeats] DEFAULT (0);
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE name = N'CK_CompanyEmployeePlanRequest_CoveredSeats'
      AND parent_object_id = OBJECT_ID(N'dbo.CompanyEmployeePlanRequest')
)
BEGIN
    ALTER TABLE [dbo].[CompanyEmployeePlanRequest] WITH CHECK
        ADD CONSTRAINT [CK_CompanyEmployeePlanRequest_CoveredSeats]
        CHECK ([CoveredSeats] >= 0);
END
GO
