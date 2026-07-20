-- Employee tasks (company-scoped). Unique active: CompanyId + OwnerEmployeeId + StartDate + EndDate.
-- Priority: 0=Low, 1=Medium, 2=High. Status: 0=Pending, 1=InProgress, 2=Completed.
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'EmployeeTask')
BEGIN
    CREATE TABLE [dbo].[EmployeeTask] (
        [EmployeeTaskId] INT IDENTITY(1,1) NOT NULL,
        [CompanyId] INT NOT NULL,
        [OwnerEmployeeId] INT NOT NULL,
        [TaskName] NVARCHAR(200) NOT NULL,
        [TaskDescription] NVARCHAR(MAX) NOT NULL,
        [Priority] TINYINT NOT NULL CONSTRAINT [DF_EmployeeTask_Priority] DEFAULT (0),
        [Status] TINYINT NOT NULL CONSTRAINT [DF_EmployeeTask_Status] DEFAULT (0),
        [StartDate] DATE NOT NULL,
        [EndDate] DATE NOT NULL,
        [CurrentProgressPercent] DECIMAL(5,2) NOT NULL CONSTRAINT [DF_EmployeeTask_CurrentProgressPercent] DEFAULT (0),
        [CreatedAt] DATETIME2(7) NOT NULL CONSTRAINT [DF_EmployeeTask_CreatedAt] DEFAULT (GETDATE()),
        [CreatedBy] INT NULL,
        [UpdatedAt] DATETIME2(7) NULL,
        [UpdatedBy] INT NULL,
        [DeletedAt] DATETIME2(7) NULL,
        [DeletedBy] INT NULL,
        CONSTRAINT [PK_EmployeeTask] PRIMARY KEY ([EmployeeTaskId]),
        CONSTRAINT [FK_EmployeeTask_Company] FOREIGN KEY ([CompanyId]) REFERENCES [dbo].[Company] ([CompanyId]),
        CONSTRAINT [FK_EmployeeTask_OwnerEmployee] FOREIGN KEY ([OwnerEmployeeId]) REFERENCES [dbo].[Employee] ([EmployeeId]),
        CONSTRAINT [CK_EmployeeTask_Priority] CHECK ([Priority] IN (0, 1, 2)),
        CONSTRAINT [CK_EmployeeTask_Status] CHECK ([Status] IN (0, 1, 2)),
        CONSTRAINT [CK_EmployeeTask_Dates] CHECK ([EndDate] >= [StartDate]),
        CONSTRAINT [CK_EmployeeTask_Progress] CHECK ([CurrentProgressPercent] >= 0 AND [CurrentProgressPercent] <= 100)
    );

    CREATE UNIQUE NONCLUSTERED INDEX [UX_EmployeeTask_Company_Owner_Dates]
        ON [dbo].[EmployeeTask]([CompanyId], [OwnerEmployeeId], [StartDate], [EndDate])
        WHERE [DeletedAt] IS NULL;

    CREATE NONCLUSTERED INDEX [IX_EmployeeTask_CompanyId_Status]
        ON [dbo].[EmployeeTask]([CompanyId], [Status])
        WHERE [DeletedAt] IS NULL;
END
GO
