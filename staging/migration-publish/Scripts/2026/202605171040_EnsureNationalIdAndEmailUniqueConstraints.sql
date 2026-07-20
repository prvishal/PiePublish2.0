-- Ensure Employee.NationalId is unique when set (filtered index; multiple NULL / blank-unknown rows allowed).
-- Ensure dbo.[User].Email has unique constraint UQ_User_Email (credentials uniqueness).
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID(N'dbo.Employee', N'U') IS NOT NULL
BEGIN
    IF EXISTS (
        SELECT 1 FROM sys.key_constraints
        WHERE parent_object_id = OBJECT_ID(N'dbo.Employee')
          AND name = N'UQ_Employee_NationalId'
          AND type = N'UQ')
        ALTER TABLE [dbo].[Employee] DROP CONSTRAINT [UQ_Employee_NationalId];

    IF NOT EXISTS (
        SELECT 1 FROM sys.indexes
        WHERE object_id = OBJECT_ID(N'dbo.Employee')
          AND name = N'UX_Employee_NationalId')
    BEGIN
        CREATE UNIQUE NONCLUSTERED INDEX [UX_Employee_NationalId]
            ON [dbo].[Employee]([NationalId])
            WHERE [NationalId] IS NOT NULL AND [NationalId] <> '';
    END
END
GO

IF OBJECT_ID(N'dbo.[User]', N'U') IS NOT NULL
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM sys.key_constraints
        WHERE parent_object_id = OBJECT_ID(N'dbo.[User]')
          AND name = N'UQ_User_Email')
        ALTER TABLE [dbo].[User] ADD CONSTRAINT [UQ_User_Email] UNIQUE ([Email]);
END
GO
