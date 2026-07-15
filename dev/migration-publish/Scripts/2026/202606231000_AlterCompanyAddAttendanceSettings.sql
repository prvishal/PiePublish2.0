-- Attendance: shift-day cutover reserved for future WorkDate logic (default midnight).
-- Prerequisites: dbo.Company.
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Company')
   AND COL_LENGTH('dbo.Company', 'ShiftDayCutoverTime') IS NULL
BEGIN
    ALTER TABLE [dbo].[Company] ADD
        [ShiftDayCutoverTime] TIME(0) NOT NULL
            CONSTRAINT [DF_Company_ShiftDayCutoverTime] DEFAULT ('00:00:00');
END
GO
