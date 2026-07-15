-- Idempotent rename when dbo.EmployeeEmployment was created with StartDate/EndDate.
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID(N'dbo.EmployeeEmployment', N'U') IS NOT NULL
BEGIN
    IF COL_LENGTH(N'dbo.EmployeeEmployment', N'StartDate') IS NOT NULL
       AND COL_LENGTH(N'dbo.EmployeeEmployment', N'JoiningDate') IS NULL
    BEGIN
        IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_EmployeeEmployment_EmployeeId_StartDate' AND object_id = OBJECT_ID(N'dbo.EmployeeEmployment'))
            DROP INDEX [IX_EmployeeEmployment_EmployeeId_StartDate] ON [dbo].[EmployeeEmployment];

        EXEC sp_rename N'dbo.EmployeeEmployment.StartDate', N'JoiningDate', N'COLUMN';
        EXEC sp_rename N'dbo.EmployeeEmployment.EndDate', N'LeavingDate', N'COLUMN';

        IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_EmployeeEmployment_EmployeeId_JoiningDate' AND object_id = OBJECT_ID(N'dbo.EmployeeEmployment'))
            CREATE NONCLUSTERED INDEX [IX_EmployeeEmployment_EmployeeId_JoiningDate]
                ON [dbo].[EmployeeEmployment] ([EmployeeId], [JoiningDate])
                INCLUDE ([LeavingDate], [CompanyId], [DeletedAt]);
    END
END
GO
