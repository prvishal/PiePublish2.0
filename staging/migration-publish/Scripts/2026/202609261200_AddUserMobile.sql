-- WhatsApp number for every login user. Client and company contact numbers stay on those tables.
SET QUOTED_IDENTIFIER ON;
GO
IF COL_LENGTH('dbo.User', 'Mobile') IS NULL
BEGIN
    ALTER TABLE [dbo].[User] ADD [Mobile] NVARCHAR(20) NULL;
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'UX_User_Mobile' AND object_id = OBJECT_ID('dbo.User'))
BEGIN
    CREATE UNIQUE INDEX [UX_User_Mobile] ON [dbo].[User]([Mobile]) WHERE [Mobile] IS NOT NULL;
END
GO

UPDATE u
SET u.Mobile = LEFT(LTRIM(RTRIM(e.Mobile)), 20)
FROM [dbo].[User] u
INNER JOIN [dbo].[Employee] e ON e.UserId = u.UserId
WHERE u.Mobile IS NULL
  AND e.Mobile IS NOT NULL
  AND LTRIM(RTRIM(e.Mobile)) <> ''
  AND e.DeletedAt IS NULL
  AND NOT EXISTS (
      SELECT 1 FROM [dbo].[User] other
      WHERE other.Mobile = LEFT(LTRIM(RTRIM(e.Mobile)), 20)
        AND other.UserId <> u.UserId)
  AND NOT EXISTS (
      SELECT 1
      FROM [dbo].[Employee] e2
      INNER JOIN [dbo].[User] u2 ON u2.UserId = e2.UserId
      WHERE e2.DeletedAt IS NULL
        AND e2.Mobile IS NOT NULL
        AND LEFT(LTRIM(RTRIM(e2.Mobile)), 20) = LEFT(LTRIM(RTRIM(e.Mobile)), 20)
        AND u2.UserId < u.UserId);
GO
