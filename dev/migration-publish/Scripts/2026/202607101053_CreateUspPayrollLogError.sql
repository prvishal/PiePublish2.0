CREATE OR ALTER PROCEDURE [dbo].[usp_Payroll_LogError]
    @PayrollRunId INT = NULL,
    @PayrollRunCompanyId INT = NULL,
    @PayrollBatchId INT = NULL,
    @EmploymentId INT = NULL,
    @EmployeeId INT = NULL,
    @ErrorSource NVARCHAR(30),
    @ErrorMessage NVARCHAR(2000),
    @ErrorNumber INT = NULL,
    @ErrorLine INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [dbo].[PayrollRunErrorLog] (
        [PayrollRunId],
        [PayrollRunCompanyId],
        [PayrollBatchId],
        [EmploymentId],
        [EmployeeId],
        [ErrorSource],
        [ErrorMessage],
        [ErrorNumber],
        [ErrorLine],
        [CreatedAt])
    VALUES (
        @PayrollRunId,
        @PayrollRunCompanyId,
        @PayrollBatchId,
        @EmploymentId,
        @EmployeeId,
        @ErrorSource,
        LEFT(@ErrorMessage, 2000),
        @ErrorNumber,
        @ErrorLine,
        SYSUTCDATETIME());
END
GO
