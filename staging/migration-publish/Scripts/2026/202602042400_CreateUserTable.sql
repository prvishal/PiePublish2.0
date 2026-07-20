-- Create User table (singular). Runs only once (tracked in __ScriptHistory).
-- RoleId is foreign key to Role. Run after CreateRoleTable and SeedRoles.
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'User')
BEGIN
    CREATE TABLE [dbo].[User] (
        [UserId] INT IDENTITY(1,1) NOT NULL,
        [UserName] NVARCHAR(100) NOT NULL,
        [Email] NVARCHAR(255) NOT NULL,
        [Password] NVARCHAR(500) NOT NULL,
        [FirstName] NVARCHAR(100) NULL,
        [LastName] NVARCHAR(100) NULL,
        [IsActive] BIT NOT NULL CONSTRAINT [DF_User_IsActive] DEFAULT (1),
        [RoleId] INT NOT NULL,
        [CreatedAt] DATETIME2(7) NOT NULL CONSTRAINT [DF_User_CreatedAt] DEFAULT (GETDATE()),
        [UpdatedAt] DATETIME2(7) NULL,
        CONSTRAINT [PK_User] PRIMARY KEY ([UserId]),
        CONSTRAINT [UQ_User_UserName] UNIQUE ([UserName]),
        CONSTRAINT [UQ_User_Email] UNIQUE ([Email]),
        CONSTRAINT [FK_User_Role] FOREIGN KEY ([RoleId]) REFERENCES [dbo].[Role] ([RoleId])
    );
END
GO
