-- Default weekend Fri+Sat for existing companies without an active weekend schedule.
-- DayOfWeek ISO: 5=Friday, 6=Saturday.
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'CompanyWeekendSchedule')
   AND EXISTS (SELECT * FROM sys.tables WHERE name = 'CompanyWeekendScheduleDay')
BEGIN
    INSERT INTO [dbo].[CompanyWeekendSchedule] (
        [CompanyId], [Name], [EffectiveFrom], [EffectiveTo], [CreatedAt])
    SELECT
        c.[CompanyId],
        N'Default',
        CAST(ISNULL(c.[RegistrationDate], CAST(GETDATE() AS DATE)) AS DATE),
        NULL,
        GETDATE()
    FROM [dbo].[Company] c
    WHERE c.[DeletedAt] IS NULL
      AND NOT EXISTS (
          SELECT 1
          FROM [dbo].[CompanyWeekendSchedule] s
          WHERE s.[CompanyId] = c.[CompanyId]
            AND s.[DeletedAt] IS NULL);

    INSERT INTO [dbo].[CompanyWeekendScheduleDay] ([CompanyWeekendScheduleId], [DayOfWeek])
    SELECT s.[CompanyWeekendScheduleId], d.[DayOfWeek]
    FROM [dbo].[CompanyWeekendSchedule] s
    CROSS JOIN (VALUES (5), (6)) AS d([DayOfWeek])
    WHERE s.[Name] = N'Default'
      AND s.[DeletedAt] IS NULL
      AND NOT EXISTS (
          SELECT 1
          FROM [dbo].[CompanyWeekendScheduleDay] sd
          WHERE sd.[CompanyWeekendScheduleId] = s.[CompanyWeekendScheduleId]);
END
GO
