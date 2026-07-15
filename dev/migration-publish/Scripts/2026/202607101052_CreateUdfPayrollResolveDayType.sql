-- Day type resolver (matches WorkCalendarResolver): 1=WorkDay, 2=Weekend, 3=Holiday.
CREATE OR ALTER FUNCTION [dbo].[udf_Payroll_ResolveDayType](
    @CompanyId INT,
    @WorkDate DATE,
    @DefaultCountryIso2 CHAR(2) = 'SA')
RETURNS TINYINT
AS
BEGIN
    DECLARE @DayType TINYINT;

    SELECT TOP (1) @DayType = o.[DayType]
    FROM [dbo].[CompanyWorkCalendarOverride] o
    WHERE o.[CompanyId] = @CompanyId
      AND o.[CalendarDate] = @WorkDate
      AND o.[DeletedAt] IS NULL;

    IF @DayType IS NOT NULL
        RETURN @DayType;

    DECLARE @CountryId INT;
    SELECT TOP (1) @CountryId = c.[CountryId]
    FROM [dbo].[Country] c
    WHERE c.[Iso2] = @DefaultCountryIso2
      AND c.[DeletedAt] IS NULL;

    IF @CountryId IS NOT NULL
       AND EXISTS (
            SELECT 1
            FROM [dbo].[CountryPublicHoliday] h
            WHERE h.[CountryId] = @CountryId
              AND h.[HolidayDate] = @WorkDate
              AND h.[DeletedAt] IS NULL)
        RETURN 3;

    DECLARE @NetDow TINYINT = dbo.udf_Payroll_NetDayOfWeek(@WorkDate);

    IF EXISTS (
        SELECT 1
        FROM [dbo].[CompanyWeekendSchedule] s
        INNER JOIN [dbo].[CompanyWeekendScheduleDay] d
            ON d.[CompanyWeekendScheduleId] = s.[CompanyWeekendScheduleId]
        WHERE s.[CompanyId] = @CompanyId
          AND s.[DeletedAt] IS NULL
          AND s.[EffectiveFrom] <= @WorkDate
          AND (s.[EffectiveTo] IS NULL OR s.[EffectiveTo] >= @WorkDate)
          AND d.[DayOfWeek] = @NetDow)
        RETURN 2;

    RETURN 1;
END
GO
