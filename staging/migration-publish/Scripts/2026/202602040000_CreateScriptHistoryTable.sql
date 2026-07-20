-- Creates the tracking table so we know which scripts have already run.
-- The migration runner also creates this in code; this script ensures it exists (e.g. if run manually).
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = '__ScriptHistory')
BEGIN
    CREATE TABLE [dbo].[__ScriptHistory] (
        [Id] INT IDENTITY(1,1) NOT NULL,
        [ScriptName] NVARCHAR(255) NOT NULL,
        [ExecutedAt] DATETIME2(7) NOT NULL CONSTRAINT [DF___ScriptHistory_ExecutedAt] DEFAULT (GETDATE()),
        CONSTRAINT [PK___ScriptHistory] PRIMARY KEY ([Id]),
        CONSTRAINT [UQ___ScriptHistory_ScriptName] UNIQUE ([ScriptName])
    );
END
GO
