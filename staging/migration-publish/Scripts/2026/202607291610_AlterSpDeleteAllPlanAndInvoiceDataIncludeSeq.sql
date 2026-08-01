-- Refresh wipe SP to also clear CompanyPlanInvoiceNumberSeq (after 202607291600).

IF OBJECT_ID(N'dbo.usp_DeleteAllPlanAndInvoiceData', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[usp_DeleteAllPlanAndInvoiceData];
GO

CREATE PROCEDURE [dbo].[usp_DeleteAllPlanAndInvoiceData]
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF OBJECT_ID(N'dbo.CompanyPlanInvoiceLine', N'U') IS NOT NULL
            DELETE FROM [dbo].[CompanyPlanInvoiceLine];

        IF OBJECT_ID(N'dbo.CompanyPlanInvoice', N'U') IS NOT NULL
            DELETE FROM [dbo].[CompanyPlanInvoice];

        IF OBJECT_ID(N'dbo.CompanyPlanInvoiceNumberSeq', N'U') IS NOT NULL
            DELETE FROM [dbo].[CompanyPlanInvoiceNumberSeq];

        IF OBJECT_ID(N'dbo.CompanyEmployeePlanRequest', N'U') IS NOT NULL
        BEGIN
            UPDATE [dbo].[CompanyEmployeePlanRequest]
            SET [SuccessorPlanRequestId] = NULL;

            DELETE FROM [dbo].[CompanyEmployeePlanRequest];
        END

        IF OBJECT_ID(N'dbo.EmployeePlan', N'U') IS NOT NULL
            DELETE FROM [dbo].[EmployeePlan];

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrState INT = ERROR_STATE();
        RAISERROR(@ErrMsg, @ErrSeverity, @ErrState);
        RETURN;
    END CATCH

    IF OBJECT_ID(N'dbo.CompanyPlanInvoiceLine', N'U') IS NOT NULL
        DBCC CHECKIDENT (N'dbo.CompanyPlanInvoiceLine', RESEED, 0);

    IF OBJECT_ID(N'dbo.CompanyPlanInvoice', N'U') IS NOT NULL
        DBCC CHECKIDENT (N'dbo.CompanyPlanInvoice', RESEED, 0);

    IF OBJECT_ID(N'dbo.CompanyEmployeePlanRequest', N'U') IS NOT NULL
        DBCC CHECKIDENT (N'dbo.CompanyEmployeePlanRequest', RESEED, 0);

    IF OBJECT_ID(N'dbo.EmployeePlan', N'U') IS NOT NULL
        DBCC CHECKIDENT (N'dbo.EmployeePlan', RESEED, 0);
END
GO
