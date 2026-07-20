-- Date-effective company weekend rules (default Fri+Sat seeded separately / on company create).
-- DayOfWeek ISO: 1=Mon .. 7=Sun; Friday=5, Saturday=6.
-- Prerequisites: dbo.Company, dbo.[User].
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'CompanyWeekendSchedule')
BEGIN
    CREATE TABLE [dbo].[CompanyWeekendSchedule] (
        [CompanyWeekendScheduleId] INT IDENTITY(1,1) NOT NULL,
        [CompanyId]                INT NOT NULL,
        [Name]                     NVARCHAR(100) NULL,
        [EffectiveFrom]            DATE NOT NULL,
        [EffectiveTo]              DATE NULL,
        [CreatedAt]                DATETIME2(7) NOT NULL
            CONSTRAINT [DF_CompanyWeekendSchedule_CreatedAt] DEFAULT (GETDATE()),
        [CreatedBy]                INT NULL,
        [UpdatedAt]                DATETIME2(7) NULL,
        [UpdatedBy]                INT NULL,
        [DeletedAt]                DATETIME2(7) NULL,
        [DeletedBy]                INT NULL,
        CONSTRAINT [PK_CompanyWeekendSchedule] PRIMARY KEY ([CompanyWeekendScheduleId]),
        CONSTRAINT [FK_CompanyWeekendSchedule_Company] FOREIGN KEY ([CompanyId])
            REFERENCES [dbo].[Company] ([CompanyId]) ON DELETE NO ACTION,
        CONSTRAINT [FK_CompanyWeekendSchedule_CreatedBy] FOREIGN KEY ([CreatedBy])
            REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [FK_CompanyWeekendSchedule_UpdatedBy] FOREIGN KEY ([UpdatedBy])
            REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [FK_CompanyWeekendSchedule_DeletedBy] FOREIGN KEY ([DeletedBy])
            REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [CK_CompanyWeekendSchedule_DateRange]
            CHECK ([EffectiveTo] IS NULL OR [EffectiveTo] >= [EffectiveFrom])
    );

    CREATE NONCLUSTERED INDEX [IX_CompanyWeekendSchedule_CompanyId_EffectiveFrom]
        ON [dbo].[CompanyWeekendSchedule]([CompanyId], [EffectiveFrom])
        WHERE [DeletedAt] IS NULL;
END
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'CompanyWeekendScheduleDay')
BEGIN
    CREATE TABLE [dbo].[CompanyWeekendScheduleDay] (
        [CompanyWeekendScheduleDayId] INT IDENTITY(1,1) NOT NULL,
        [CompanyWeekendScheduleId]    INT NOT NULL,
        [DayOfWeek]                   TINYINT NOT NULL,
        CONSTRAINT [PK_CompanyWeekendScheduleDay] PRIMARY KEY ([CompanyWeekendScheduleDayId]),
        CONSTRAINT [FK_CompanyWeekendScheduleDay_Schedule] FOREIGN KEY ([CompanyWeekendScheduleId])
            REFERENCES [dbo].[CompanyWeekendSchedule] ([CompanyWeekendScheduleId]) ON DELETE CASCADE,
        CONSTRAINT [CK_CompanyWeekendScheduleDay_DayOfWeek] CHECK ([DayOfWeek] BETWEEN 1 AND 7),
        CONSTRAINT [UQ_CompanyWeekendScheduleDay] UNIQUE ([CompanyWeekendScheduleId], [DayOfWeek])
    );
END
GO
