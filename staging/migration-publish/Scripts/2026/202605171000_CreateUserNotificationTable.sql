-- Per-user in-app notifications (Category/EventType extensible for other modules).
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'UserNotification')
BEGIN
    CREATE TABLE [dbo].[UserNotification] (
        [UserNotificationId] INT IDENTITY(1,1) NOT NULL,
        [UserId] INT NOT NULL,
        [Category] NVARCHAR(80) NOT NULL,
        [EventType] NVARCHAR(80) NOT NULL,
        [Title] NVARCHAR(200) NOT NULL,
        [Body] NVARCHAR(2000) NULL,
        [DeepLinkPath] NVARCHAR(500) NOT NULL,
        [RelatedEntityType] NVARCHAR(80) NULL,
        [RelatedEntityId] NVARCHAR(64) NULL,
        [IsRead] BIT NOT NULL CONSTRAINT [DF_UserNotification_IsRead] DEFAULT (0),
        [ReadAt] DATETIME2(7) NULL,
        [CreatedAt] DATETIME2(7) NOT NULL CONSTRAINT [DF_UserNotification_CreatedAt] DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT [PK_UserNotification] PRIMARY KEY ([UserNotificationId]),
        CONSTRAINT [FK_UserNotification_User] FOREIGN KEY ([UserId]) REFERENCES [dbo].[User] ([UserId]) ON DELETE CASCADE
    );
    CREATE INDEX [IX_UserNotification_UserId_CreatedAt] ON [dbo].[UserNotification] ([UserId], [CreatedAt] DESC);
    CREATE INDEX [IX_UserNotification_UserId_IsRead] ON [dbo].[UserNotification] ([UserId], [IsRead]);
END
GO
