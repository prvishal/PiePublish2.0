-- Employment stint per company (jobless gaps implied between rows). Prerequisites: dbo.Employee, dbo.Company.
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'EmployeeEmployment')
BEGIN
    CREATE TABLE [dbo].[EmployeeEmployment] (
        [EmploymentId] INT IDENTITY(1,1) NOT NULL,
        [EmployeeId] INT NOT NULL,
        [CompanyId] INT NOT NULL,
        [JoiningDate] DATE NOT NULL,
        [LeavingDate] DATE NULL,
        [CreatedAt] DATETIME2(7) NOT NULL CONSTRAINT [DF_EmployeeEmployment_CreatedAt] DEFAULT (GETDATE()),
        [CreatedBy] INT NULL,
        [UpdatedAt] DATETIME2(7) NULL,
        [UpdatedBy] INT NULL,
        [DeletedAt] DATETIME2(7) NULL,
        [DeletedBy] INT NULL,
        CONSTRAINT [PK_EmployeeEmployment] PRIMARY KEY ([EmploymentId]),
        CONSTRAINT [FK_EmployeeEmployment_Employee] FOREIGN KEY ([EmployeeId]) REFERENCES [dbo].[Employee] ([EmployeeId]),
        CONSTRAINT [FK_EmployeeEmployment_Company] FOREIGN KEY ([CompanyId]) REFERENCES [dbo].[Company] ([CompanyId]) ON DELETE NO ACTION,
        CONSTRAINT [FK_EmployeeEmployment_CreatedBy] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [FK_EmployeeEmployment_UpdatedBy] FOREIGN KEY ([UpdatedBy]) REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [FK_EmployeeEmployment_DeletedBy] FOREIGN KEY ([DeletedBy]) REFERENCES [dbo].[User] ([UserId])
    );
    CREATE NONCLUSTERED INDEX [IX_EmployeeEmployment_EmployeeId_JoiningDate]
        ON [dbo].[EmployeeEmployment] ([EmployeeId], [JoiningDate])
        INCLUDE ([LeavingDate], [CompanyId], [DeletedAt]);
END
GO
