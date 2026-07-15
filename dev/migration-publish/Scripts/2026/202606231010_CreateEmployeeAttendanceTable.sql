-- Employee daily check-in/check-out (KSA timestamps; optional GPS).
-- Prerequisites: dbo.Employee, dbo.Company, dbo.EmployeeEmployment, dbo.CompanyBatch, dbo.[User].
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'EmployeeAttendance')
BEGIN
    CREATE TABLE [dbo].[EmployeeAttendance] (
        [EmployeeAttendanceId] INT IDENTITY(1,1) NOT NULL,
        [EmployeeId]           INT NOT NULL,
        [EmploymentId]         INT NOT NULL,
        [CompanyId]            INT NOT NULL,
        [CompanyBatchId]       INT NULL,

        [WorkDate]             DATE NOT NULL,
        [CheckInAt]            DATETIME2(7) NOT NULL,
        [CheckOutAt]           DATETIME2(7) NULL,

        [CheckInLatitude]      DECIMAL(9,6) NULL,
        [CheckInLongitude]     DECIMAL(9,6) NULL,
        [CheckOutLatitude]     DECIMAL(9,6) NULL,
        [CheckOutLongitude]    DECIMAL(9,6) NULL,

        [DayType]              TINYINT NOT NULL,
        [Status]               TINYINT NOT NULL,
        [Source]               TINYINT NOT NULL,
        [Notes]                NVARCHAR(500) NULL,

        [CreatedAt]            DATETIME2(7) NOT NULL
            CONSTRAINT [DF_EmployeeAttendance_CreatedAt] DEFAULT (GETDATE()),
        [CreatedBy]            INT NULL,
        [UpdatedAt]            DATETIME2(7) NULL,
        [UpdatedBy]            INT NULL,
        [DeletedAt]            DATETIME2(7) NULL,
        [DeletedBy]            INT NULL,

        CONSTRAINT [PK_EmployeeAttendance] PRIMARY KEY ([EmployeeAttendanceId]),
        CONSTRAINT [FK_EmployeeAttendance_Employee] FOREIGN KEY ([EmployeeId])
            REFERENCES [dbo].[Employee] ([EmployeeId]) ON DELETE NO ACTION,
        CONSTRAINT [FK_EmployeeAttendance_Employment] FOREIGN KEY ([EmploymentId])
            REFERENCES [dbo].[EmployeeEmployment] ([EmploymentId]) ON DELETE NO ACTION,
        CONSTRAINT [FK_EmployeeAttendance_Company] FOREIGN KEY ([CompanyId])
            REFERENCES [dbo].[Company] ([CompanyId]) ON DELETE NO ACTION,
        CONSTRAINT [FK_EmployeeAttendance_CompanyBatch] FOREIGN KEY ([CompanyBatchId])
            REFERENCES [dbo].[CompanyBatch] ([CompanyBatchId]) ON DELETE NO ACTION,
        CONSTRAINT [FK_EmployeeAttendance_CreatedBy] FOREIGN KEY ([CreatedBy])
            REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [FK_EmployeeAttendance_UpdatedBy] FOREIGN KEY ([UpdatedBy])
            REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [FK_EmployeeAttendance_DeletedBy] FOREIGN KEY ([DeletedBy])
            REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [CK_EmployeeAttendance_DayType] CHECK ([DayType] IN (1, 2, 3)),
        CONSTRAINT [CK_EmployeeAttendance_Status] CHECK ([Status] IN (1, 2, 3)),
        CONSTRAINT [CK_EmployeeAttendance_Source] CHECK ([Source] IN (1, 2, 3, 4)),
        CONSTRAINT [CK_EmployeeAttendance_CheckOutAfterCheckIn]
            CHECK ([CheckOutAt] IS NULL OR [CheckOutAt] > [CheckInAt])
    );

    CREATE UNIQUE NONCLUSTERED INDEX [UX_EmployeeAttendance_OpenSession]
        ON [dbo].[EmployeeAttendance]([EmployeeId])
        WHERE [CheckOutAt] IS NULL AND [DeletedAt] IS NULL;

    CREATE UNIQUE NONCLUSTERED INDEX [UX_EmployeeAttendance_WorkDate_Active]
        ON [dbo].[EmployeeAttendance]([EmployeeId], [WorkDate])
        WHERE [DeletedAt] IS NULL;

    CREATE NONCLUSTERED INDEX [IX_EmployeeAttendance_Company_WorkDate]
        ON [dbo].[EmployeeAttendance]([CompanyId], [WorkDate])
        WHERE [DeletedAt] IS NULL;

    CREATE NONCLUSTERED INDEX [IX_EmployeeAttendance_EmploymentId]
        ON [dbo].[EmployeeAttendance]([EmploymentId])
        WHERE [DeletedAt] IS NULL;
END
GO
