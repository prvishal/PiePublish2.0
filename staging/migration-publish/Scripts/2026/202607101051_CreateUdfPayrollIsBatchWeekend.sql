-- Batch weekend check (matches CompanyBatchWeekendHelper / BatchWorkDayChecker).
-- .NET DayOfWeek: Sun=0 .. Sat=6; 5-day batch = Fri+Sat; 6-day = Fri only.
CREATE OR ALTER FUNCTION [dbo].[udf_Payroll_NetDayOfWeek](@WorkDate DATE)
RETURNS TINYINT
AS
BEGIN
    RETURN DATEDIFF(DAY, '19000107', @WorkDate) % 7;
END
GO

CREATE OR ALTER FUNCTION [dbo].[udf_Payroll_IsBatchWeekend](
    @WorkingDaysPerWeek TINYINT,
    @WorkDate DATE)
RETURNS BIT
AS
BEGIN
    DECLARE @Dow TINYINT = dbo.udf_Payroll_NetDayOfWeek(@WorkDate);

    IF @WorkingDaysPerWeek = 6 AND @Dow = 5
        RETURN 1;

    IF @WorkingDaysPerWeek <> 6 AND @Dow IN (5, 6)
        RETURN 1;

    RETURN 0;
END
GO
