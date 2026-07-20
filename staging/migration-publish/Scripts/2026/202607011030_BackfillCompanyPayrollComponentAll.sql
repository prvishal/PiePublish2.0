-- Link ALL active PayrollComponent rows to every active Company.
INSERT INTO [dbo].[CompanyPayrollComponent]
    ([CompanyId], [PayrollComponentId], [IsEnabled], [IsMandatory], [SortOrder], [CreatedAt])
SELECT
    c.[CompanyId],
    pc.[PayrollComponentId],
    1,
    CASE WHEN pc.[Code] = 'Basic' THEN 1 ELSE 0 END,
    pc.[SortOrder],
    GETDATE()
FROM [dbo].[Company] c
CROSS JOIN [dbo].[PayrollComponent] pc
WHERE c.[DeletedAt] IS NULL
  AND pc.[DeletedAt] IS NULL
  AND NOT EXISTS (
      SELECT 1
      FROM [dbo].[CompanyPayrollComponent] cpc
      WHERE cpc.[CompanyId] = c.[CompanyId]
        AND cpc.[PayrollComponentId] = pc.[PayrollComponentId]
        AND cpc.[DeletedAt] IS NULL
  );
GO
