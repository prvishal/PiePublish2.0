-- Create UserClient mapper table (many-to-many between User and Client). Runs only once (tracked in __ScriptHistory).
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'UserClient')
BEGIN
    CREATE TABLE [dbo].[UserClient] (
        [UserClientId] INT IDENTITY(1,1) NOT NULL,
        [UserId] INT NOT NULL,
        [ClientId] INT NOT NULL,
        [IsActive] BIT NOT NULL CONSTRAINT [DF_UserClient_IsActive] DEFAULT (1),
        [CreatedAt] DATETIME2(7) NOT NULL CONSTRAINT [DF_UserClient_CreatedAt] DEFAULT (GETUTCDATE()),
        [CreatedBy] INT NULL,
        [UpdatedAt] DATETIME2(7) NULL,
        [UpdatedBy] INT NULL,
        CONSTRAINT [PK_UserClient] PRIMARY KEY ([UserClientId]),
        CONSTRAINT [FK_UserClient_User] FOREIGN KEY ([UserId]) REFERENCES [dbo].[User] ([UserId]) ON DELETE CASCADE,
        CONSTRAINT [FK_UserClient_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId]) ON DELETE NO ACTION,
        CONSTRAINT [FK_UserClient_CreatedBy] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [FK_UserClient_UpdatedBy] FOREIGN KEY ([UpdatedBy]) REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [UQ_UserClient_UserId_ClientId] UNIQUE ([UserId], [ClientId])
    );
END
GO
