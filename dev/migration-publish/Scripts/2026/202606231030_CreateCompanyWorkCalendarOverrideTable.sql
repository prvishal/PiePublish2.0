-- Per-date work-day / weekend / holiday overrides (wins over weekend schedule).
-- DayType: 1=WorkDay, 2=Weekend, 3=Holiday.
-- Prerequisites: dbo.Company, dbo.[User].
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'CompanyWorkCalendarOverride')
BEGIN
    CREATE TABLE [dbo].[CompanyWorkCalendarOverride] (
        [CompanyWorkCalendarOverrideId] INT IDENTITY(1,1) NOT NULL,
        [CompanyId]                     INT NOT NULL,
        [CalendarDate]                  DATE NOT NULL,
        [DayType]                       TINYINT NOT NULL,
        [Name]                          NVARCHAR(100) NULL,
        [CreatedAt]                     DATETIME2(7) NOT NULL
            CONSTRAINT [DF_CompanyWorkCalendarOverride_CreatedAt] DEFAULT (GETDATE()),
        [CreatedBy]                     INT NULL,
        [UpdatedAt]                     DATETIME2(7) NULL,
        [UpdatedBy]                     INT NULL,
        [DeletedAt]                     DATETIME2(7) NULL,
        [DeletedBy]                     INT NULL,
        CONSTRAINT [PK_CompanyWorkCalendarOverride] PRIMARY KEY ([CompanyWorkCalendarOverrideId]),
        CONSTRAINT [FK_CompanyWorkCalendarOverride_Company] FOREIGN KEY ([CompanyId])
            REFERENCES [dbo].[Company] ([CompanyId]) ON DELETE NO ACTION,
        CONSTRAINT [FK_CompanyWorkCalendarOverride_CreatedBy] FOREIGN KEY ([CreatedBy])
            REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [FK_CompanyWorkCalendarOverride_UpdatedBy] FOREIGN KEY ([UpdatedBy])
            REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [FK_CompanyWorkCalendarOverride_DeletedBy] FOREIGN KEY ([DeletedBy])
            REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [CK_CompanyWorkCalendarOverride_DayType] CHECK ([DayType] IN (1, 2, 3))
    );

    CREATE UNIQUE NONCLUSTERED INDEX [UX_CompanyWorkCalendarOverride_Date_Active]
        ON [dbo].[CompanyWorkCalendarOverride]([CompanyId], [CalendarDate])
        WHERE [DeletedAt] IS NULL;
END
GO
