-- Job title segments within one employment stint. Prerequisites: dbo.EmployeeEmployment.
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'EmployeeEmploymentJobProfile')
BEGIN
    CREATE TABLE [dbo].[EmployeeEmploymentJobProfile] (
        [EmploymentJobProfileId] INT IDENTITY(1,1) NOT NULL,
        [EmploymentId] INT NOT NULL,
        [JobTitle] NVARCHAR(200) NOT NULL,
        [EffectiveFrom] DATE NOT NULL,
        [EffectiveTo] DATE NULL,
        [CreatedAt] DATETIME2(7) NOT NULL CONSTRAINT [DF_EmployeeEmploymentJobProfile_CreatedAt] DEFAULT (GETDATE()),
        [CreatedBy] INT NULL,
        [UpdatedAt] DATETIME2(7) NULL,
        [UpdatedBy] INT NULL,
        [DeletedAt] DATETIME2(7) NULL,
        [DeletedBy] INT NULL,
        CONSTRAINT [PK_EmployeeEmploymentJobProfile] PRIMARY KEY ([EmploymentJobProfileId]),
        CONSTRAINT [FK_EmployeeEmploymentJobProfile_Employment] FOREIGN KEY ([EmploymentId]) REFERENCES [dbo].[EmployeeEmployment] ([EmploymentId]),
        CONSTRAINT [FK_EmployeeEmploymentJobProfile_CreatedBy] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [FK_EmployeeEmploymentJobProfile_UpdatedBy] FOREIGN KEY ([UpdatedBy]) REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [FK_EmployeeEmploymentJobProfile_DeletedBy] FOREIGN KEY ([DeletedBy]) REFERENCES [dbo].[User] ([UserId])
    );
    CREATE NONCLUSTERED INDEX [IX_EmployeeEmploymentJobProfile_EmploymentId_EffectiveFrom]
        ON [dbo].[EmployeeEmploymentJobProfile] ([EmploymentId], [EffectiveFrom])
        INCLUDE ([EffectiveTo], [DeletedAt]);
END
GO
