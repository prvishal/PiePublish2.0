-- Seed CompanyPayrollComponent for E2E tenants (SQL-created companies skip API SeedAllForCompanyAsync).
-- Required so employee import columns include Basic and payroll flows can run against Alpha/Beta.

SET NOCOUNT ON;

DECLARE @Now DATETIME2(7) = SYSUTCDATETIME();

;WITH E2ECompanies AS (
    SELECT c.CompanyId
    FROM dbo.Company c
    WHERE c.DeletedAt IS NULL
      AND c.CompanyName IN (N'E2E Company Alpha', N'E2E Company Beta')
),
SystemComponents AS (
    SELECT pc.PayrollComponentId, pc.Code, pc.SortOrder
    FROM dbo.PayrollComponent pc
    WHERE pc.DeletedAt IS NULL
      AND pc.IsSystem = 1
)
INSERT INTO dbo.CompanyPayrollComponent (
    CompanyId,
    PayrollComponentId,
    IsEnabled,
    IsMandatory,
    SortOrder,
    CreatedAt
)
SELECT
    ec.CompanyId,
    sc.PayrollComponentId,
    1,
    CASE WHEN sc.Code = N'Basic' THEN 1 ELSE 0 END,
    sc.SortOrder,
    @Now
FROM E2ECompanies ec
CROSS JOIN SystemComponents sc
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.CompanyPayrollComponent cpc
    WHERE cpc.CompanyId = ec.CompanyId
      AND cpc.PayrollComponentId = sc.PayrollComponentId
      AND cpc.DeletedAt IS NULL
);
