-- HR employee profile (one row per User). Prerequisites: dbo.User.
-- Credentials stay on User; company tenure is dbo.EmployeeEmployment.
-- Email uniqueness is enforced on dbo.[User] (UQ_User_Email).
-- NationalId: unique when provided (non-null, non-empty); see UX_Employee_NationalId filter below.
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Employee')
BEGIN
    CREATE TABLE [dbo].[Employee] (
        [EmployeeId] INT IDENTITY(1,1) NOT NULL,
        [UserId] INT NOT NULL,
        [NationalId] VARCHAR(50) NULL,
        [Name] NVARCHAR(500) NULL,
        [Mobile] VARCHAR(20) NULL,
        [Gender] TINYINT NULL,
        [DateOfBirth] DATE NULL,
        [City] NVARCHAR(200) NULL,
        [ZIP] VARCHAR(100) NULL,
        [Address] NVARCHAR(MAX) NULL,
        [Qualification] NVARCHAR(100) NULL,
        [CV] NVARCHAR(200) NULL,
        [Logo] VARCHAR(100) NULL,
        [CreatedAt] DATETIME2(7) NOT NULL CONSTRAINT [DF_Employee_CreatedAt] DEFAULT (GETDATE()),
        [CreatedBy] INT NULL,
        [UpdatedAt] DATETIME2(7) NULL,
        [UpdatedBy] INT NULL,
        [DeletedAt] DATETIME2(7) NULL,
        [DeletedBy] INT NULL,
        CONSTRAINT [PK_Employee] PRIMARY KEY ([EmployeeId]),
        CONSTRAINT [UQ_Employee_UserId] UNIQUE ([UserId]),
        CONSTRAINT [FK_Employee_User] FOREIGN KEY ([UserId]) REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [FK_Employee_CreatedBy] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [FK_Employee_UpdatedBy] FOREIGN KEY ([UpdatedBy]) REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [FK_Employee_DeletedBy] FOREIGN KEY ([DeletedBy]) REFERENCES [dbo].[User] ([UserId])
    );

    CREATE UNIQUE NONCLUSTERED INDEX [UX_Employee_NationalId]
        ON [dbo].[Employee]([NationalId])
        WHERE [NationalId] IS NOT NULL AND [NationalId] <> '';
END
GO
