-- Drop legacy holiday tables (definition + occurrence model).
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'CountryHolidayOccurrence')
    DROP TABLE [dbo].[CountryHolidayOccurrence];
GO

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'CountryHoliday')
    DROP TABLE [dbo].[CountryHoliday];
GO
