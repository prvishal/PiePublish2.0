-- Company batch attendance policy: working days (5/6), mode (manual/auto), start time window.
-- Widen WorkingHoursPerDay check from 4-8 to 4-9.
-- Defaults: 5-day, Auto (2), 07:30-10:30.
-- Prerequisites: dbo.CompanyBatch (202606161500_CreateCompanyBatchTable.sql).
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'CompanyBatch')
   AND COL_LENGTH('dbo.CompanyBatch', 'WorkingDaysPerWeek') IS NULL
BEGIN
    ALTER TABLE [dbo].[CompanyBatch] ADD
        [WorkingDaysPerWeek] TINYINT NOT NULL
            CONSTRAINT [DF_CompanyBatch_WorkingDaysPerWeek] DEFAULT (5),
        [AttendanceMode] TINYINT NOT NULL
            CONSTRAINT [DF_CompanyBatch_AttendanceMode] DEFAULT (2),
        [StartWorkTimeFrom] TIME(0) NOT NULL
            CONSTRAINT [DF_CompanyBatch_StartWorkTimeFrom] DEFAULT ('07:30:00'),
        [StartWorkTimeTo] TIME(0) NOT NULL
            CONSTRAINT [DF_CompanyBatch_StartWorkTimeTo] DEFAULT ('10:30:00');
END
GO

-- Backfill any rows that predate column defaults (defensive).
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'CompanyBatch')
   AND COL_LENGTH('dbo.CompanyBatch', 'WorkingDaysPerWeek') IS NOT NULL
BEGIN
    UPDATE [dbo].[CompanyBatch]
    SET
        [WorkingDaysPerWeek] = 5,
        [AttendanceMode] = 2,
        [StartWorkTimeFrom] = '07:30:00',
        [StartWorkTimeTo] = '10:30:00'
    WHERE [WorkingDaysPerWeek] NOT IN (5, 6)
       OR [AttendanceMode] NOT IN (1, 2)
       OR [StartWorkTimeFrom] IS NULL
       OR [StartWorkTimeTo] IS NULL
       OR [StartWorkTimeFrom] >= [StartWorkTimeTo];
END
GO

IF EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE name = 'CK_CompanyBatch_WorkingHoursPerDay'
)
    ALTER TABLE [dbo].[CompanyBatch] DROP CONSTRAINT [CK_CompanyBatch_WorkingHoursPerDay];
GO

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'CompanyBatch')
   AND NOT EXISTS (
       SELECT 1 FROM sys.check_constraints WHERE name = 'CK_CompanyBatch_WorkingHoursPerDay'
   )
    ALTER TABLE [dbo].[CompanyBatch] ADD CONSTRAINT [CK_CompanyBatch_WorkingHoursPerDay]
        CHECK ([WorkingHoursPerDay] >= 4.0 AND [WorkingHoursPerDay] <= 9.0);
GO

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'CompanyBatch')
   AND NOT EXISTS (
       SELECT 1 FROM sys.check_constraints WHERE name = 'CK_CompanyBatch_WorkingDaysPerWeek'
   )
    ALTER TABLE [dbo].[CompanyBatch] ADD CONSTRAINT [CK_CompanyBatch_WorkingDaysPerWeek]
        CHECK ([WorkingDaysPerWeek] IN (5, 6));
GO

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'CompanyBatch')
   AND NOT EXISTS (
       SELECT 1 FROM sys.check_constraints WHERE name = 'CK_CompanyBatch_AttendanceMode'
   )
    ALTER TABLE [dbo].[CompanyBatch] ADD CONSTRAINT [CK_CompanyBatch_AttendanceMode]
        CHECK ([AttendanceMode] IN (1, 2));
GO

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'CompanyBatch')
   AND NOT EXISTS (
       SELECT 1 FROM sys.check_constraints WHERE name = 'CK_CompanyBatch_StartWorkTimeRange'
   )
    ALTER TABLE [dbo].[CompanyBatch] ADD CONSTRAINT [CK_CompanyBatch_StartWorkTimeRange]
        CHECK ([StartWorkTimeFrom] < [StartWorkTimeTo]);
GO
