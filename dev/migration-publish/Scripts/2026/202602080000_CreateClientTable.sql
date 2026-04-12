-- Create Client table. Runs only once (tracked in __ScriptHistory).
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Client')
BEGIN
    CREATE TABLE [dbo].[Client] (
        [ClientId] INT IDENTITY(1,1) NOT NULL,
        [ClientName] NVARCHAR(200) NOT NULL,
        [Notes] NVARCHAR(MAX) NULL,
        [Address] NVARCHAR(500) NULL,
        [Mobile] NVARCHAR(50) NULL,
        [Phone] NVARCHAR(50) NULL,
        [IsActive] BIT NOT NULL CONSTRAINT [DF_Client_IsActive] DEFAULT (1),
        [CreatedAt] DATETIME2(7) NOT NULL CONSTRAINT [DF_Client_CreatedAt] DEFAULT (GETDATE()),
        [CreatedBy] INT NULL,
        [UpdatedAt] DATETIME2(7) NULL,
        [UpdatedBy] INT NULL,
        [DeletedAt] DATETIME2(7) NULL,
        [DeletedBy] INT NULL,
        CONSTRAINT [PK_Client] PRIMARY KEY ([ClientId]),
        CONSTRAINT [FK_Client_CreatedBy] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [FK_Client_UpdatedBy] FOREIGN KEY ([UpdatedBy]) REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [FK_Client_DeletedBy] FOREIGN KEY ([DeletedBy]) REFERENCES [dbo].[User] ([UserId])
    );
END
GO
