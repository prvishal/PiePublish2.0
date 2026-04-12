-- Create UserCompany mapper table (many-to-many between User and Company). Runs only once (tracked in __ScriptHistory).
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'UserCompany')
BEGIN
    CREATE TABLE [dbo].[UserCompany] (
        [UserCompanyId] INT IDENTITY(1,1) NOT NULL,
        [UserId] INT NOT NULL,
        [CompanyId] INT NOT NULL,
        [IsActive] BIT NOT NULL CONSTRAINT [DF_UserCompany_IsActive] DEFAULT (1),
        [CreatedAt] DATETIME2(7) NOT NULL CONSTRAINT [DF_UserCompany_CreatedAt] DEFAULT (GETUTCDATE()),
        [CreatedBy] INT NULL,
        [UpdatedAt] DATETIME2(7) NULL,
        [UpdatedBy] INT NULL,
        CONSTRAINT [PK_UserCompany] PRIMARY KEY ([UserCompanyId]),
        CONSTRAINT [FK_UserCompany_User] FOREIGN KEY ([UserId]) REFERENCES [dbo].[User] ([UserId]) ON DELETE CASCADE,
        CONSTRAINT [FK_UserCompany_Company] FOREIGN KEY ([CompanyId]) REFERENCES [dbo].[Company] ([CompanyId]) ON DELETE NO ACTION,
        CONSTRAINT [FK_UserCompany_CreatedBy] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [FK_UserCompany_UpdatedBy] FOREIGN KEY ([UpdatedBy]) REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [UQ_UserCompany_UserId_CompanyId] UNIQUE ([UserId], [CompanyId])
    );
END
GO
