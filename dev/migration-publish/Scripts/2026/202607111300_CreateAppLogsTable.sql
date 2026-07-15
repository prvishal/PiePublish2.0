-- Serilog AppLogs table (MSSqlServer sink default columns).
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'AppLogs')
BEGIN
    CREATE TABLE [dbo].[AppLogs] (
        [Id]              BIGINT IDENTITY(1,1) NOT NULL,
        [Message]         NVARCHAR(MAX) NULL,
        [MessageTemplate] NVARCHAR(MAX) NULL,
        [Level]           NVARCHAR(128) NULL,
        [TimeStamp]       DATETIMEOFFSET(7) NOT NULL,
        [Exception]       NVARCHAR(MAX) NULL,
        [Properties]      NVARCHAR(MAX) NULL,
        CONSTRAINT [PK_AppLogs] PRIMARY KEY CLUSTERED ([Id] ASC)
    );

    CREATE NONCLUSTERED INDEX [IX_AppLogs_TimeStamp]
        ON [dbo].[AppLogs]([TimeStamp] ASC);
END
GO
