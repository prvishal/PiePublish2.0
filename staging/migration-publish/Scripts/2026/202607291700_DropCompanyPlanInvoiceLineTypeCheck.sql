-- Allow free-form invoice line types going forward (app owns allowed values).
-- Removes CK that previously limited LineType to Headcount / NewJoining only.

IF EXISTS (
    SELECT 1
    FROM sys.check_constraints
    WHERE name = N'CK_CompanyPlanInvoiceLine_LineType'
      AND parent_object_id = OBJECT_ID(N'dbo.CompanyPlanInvoiceLine')
)
BEGIN
    ALTER TABLE [dbo].[CompanyPlanInvoiceLine]
        DROP CONSTRAINT [CK_CompanyPlanInvoiceLine_LineType];
END
GO
