-- Create Role table (singular). Runs only once (tracked in __ScriptHistory).
-- Run before SeedRoles script.
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Role')
BEGIN
    CREATE TABLE [dbo].[Role] (
        [RoleId] INT IDENTITY(1,1) NOT NULL,
        [Name] NVARCHAR(100) NOT NULL,
        [Description] NVARCHAR(500) NULL,
        [CreatedAt] DATETIME2(7) NOT NULL CONSTRAINT [DF_Role_CreatedAt] DEFAULT (GETDATE()),
        [UpdatedAt] DATETIME2(7) NULL,
        CONSTRAINT [PK_Role] PRIMARY KEY ([RoleId]),
        CONSTRAINT [UQ_Role_Name] UNIQUE ([Name])
    );
END
GO
