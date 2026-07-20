-- Create PieManagerClient mapper table (PieManager User to Client).
-- UserClient table is for ClientAdmin and ClientManager users only.
-- Uses soft delete (DeletedAt/DeletedBy) for removing client assignments.
-- A client can only be assigned to ONE PieManager at a time (filtered unique on ClientId).
-- Runs only once (tracked in __ScriptHistory).
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'PieManagerClient')
BEGIN
    CREATE TABLE [dbo].[PieManagerClient] (
        [PieManagerClientId] INT IDENTITY(1,1) NOT NULL,
        [UserId] INT NOT NULL,
        [ClientId] INT NOT NULL,
        [CreatedAt] DATETIME2(7) NOT NULL CONSTRAINT [DF_PieManagerClient_CreatedAt] DEFAULT (GETDATE()),
        [CreatedBy] INT NULL,
        [UpdatedAt] DATETIME2(7) NULL,
        [UpdatedBy] INT NULL,
        [DeletedAt] DATETIME2(7) NULL,
        [DeletedBy] INT NULL,
        CONSTRAINT [PK_PieManagerClient] PRIMARY KEY ([PieManagerClientId]),
        CONSTRAINT [FK_PieManagerClient_User] FOREIGN KEY ([UserId]) REFERENCES [dbo].[User] ([UserId]) ON DELETE CASCADE,
        CONSTRAINT [FK_PieManagerClient_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId]) ON DELETE NO ACTION,
        CONSTRAINT [FK_PieManagerClient_CreatedBy] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [FK_PieManagerClient_UpdatedBy] FOREIGN KEY ([UpdatedBy]) REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [FK_PieManagerClient_DeletedBy] FOREIGN KEY ([DeletedBy]) REFERENCES [dbo].[User] ([UserId])
    );

    -- A client can only be assigned to ONE PieManager at a time (only for non-deleted records)
    CREATE UNIQUE NONCLUSTERED INDEX [UQ_PieManagerClient_ClientId_Active]
    ON [dbo].[PieManagerClient] ([ClientId])
    WHERE [DeletedAt] IS NULL;
END
GO
