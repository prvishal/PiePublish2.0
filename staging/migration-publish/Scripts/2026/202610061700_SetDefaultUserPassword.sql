-- Move users still on the previous default passwords to Pie@321.
-- Custom passwords are left unchanged.
SET QUOTED_IDENTIFIER ON;
GO
UPDATE [dbo].[User]
SET [Password] = N'Pie@321',
    [UpdatedAt] = GETDATE()
WHERE [Password] IN (N'ChangeMe123!', N'Pie@321!');
GO
