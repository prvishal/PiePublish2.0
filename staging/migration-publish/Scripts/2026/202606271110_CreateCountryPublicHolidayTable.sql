-- One row = one public holiday date for a country/year.
-- Source: 1=ExternalSync, 2=Manual.
-- Prerequisites: dbo.Country, dbo.[User].
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'CountryPublicHoliday')
    DROP TABLE [dbo].[CountryPublicHoliday];
GO

CREATE TABLE [dbo].[CountryPublicHoliday] (
    [CountryPublicHolidayId]   INT IDENTITY(1,1) NOT NULL,
    [CountryId]                INT NOT NULL,
    [Year]                     SMALLINT NOT NULL,
    [HolidayDate]              DATE NOT NULL,
    [Name]                     NVARCHAR(200) NOT NULL,
    [NameAr]                   NVARCHAR(200) NULL,
    [Description]              NVARCHAR(500) NULL,
    [HolidayCategory]          NVARCHAR(50) NULL,
    [IsPaidDayOff]             BIT NOT NULL
        CONSTRAINT [DF_CountryPublicHoliday_IsPaidDayOff] DEFAULT (1),
    [Source]                   TINYINT NOT NULL
        CONSTRAINT [DF_CountryPublicHoliday_Source] DEFAULT (1),
    [ExternalProvider]         NVARCHAR(50) NOT NULL
        CONSTRAINT [DF_CountryPublicHoliday_ExternalProvider] DEFAULT (N'Manual'),
    [ExternalKey]              NVARCHAR(100) NOT NULL,
    [ExternalPrimaryType]      NVARCHAR(100) NULL,
    [LastSyncedAt]             DATETIME2(7) NULL,
    [CreatedAt]                DATETIME2(7) NOT NULL
        CONSTRAINT [DF_CountryPublicHoliday_CreatedAt] DEFAULT (GETDATE()),
    [CreatedBy]                INT NULL,
    [UpdatedAt]                DATETIME2(7) NULL,
    [UpdatedBy]                INT NULL,
    [DeletedAt]                DATETIME2(7) NULL,
    [DeletedBy]                INT NULL,
    CONSTRAINT [PK_CountryPublicHoliday] PRIMARY KEY ([CountryPublicHolidayId]),
    CONSTRAINT [FK_CountryPublicHoliday_Country] FOREIGN KEY ([CountryId])
        REFERENCES [dbo].[Country] ([CountryId]) ON DELETE NO ACTION,
    CONSTRAINT [FK_CountryPublicHoliday_CreatedBy] FOREIGN KEY ([CreatedBy])
        REFERENCES [dbo].[User] ([UserId]),
    CONSTRAINT [FK_CountryPublicHoliday_UpdatedBy] FOREIGN KEY ([UpdatedBy])
        REFERENCES [dbo].[User] ([UserId]),
    CONSTRAINT [FK_CountryPublicHoliday_DeletedBy] FOREIGN KEY ([DeletedBy])
        REFERENCES [dbo].[User] ([UserId]),
    CONSTRAINT [CK_CountryPublicHoliday_Source] CHECK ([Source] IN (1, 2))
);
GO

CREATE UNIQUE NONCLUSTERED INDEX [UX_CountryPublicHoliday_Country_Year_Provider_Key_Active]
    ON [dbo].[CountryPublicHoliday]([CountryId], [Year], [ExternalProvider], [ExternalKey])
    WHERE [DeletedAt] IS NULL;
GO

CREATE NONCLUSTERED INDEX [IX_CountryPublicHoliday_Country_HolidayDate_Active]
    ON [dbo].[CountryPublicHoliday]([CountryId], [HolidayDate])
    INCLUDE ([IsPaidDayOff], [Name], [NameAr])
    WHERE [DeletedAt] IS NULL;
GO
