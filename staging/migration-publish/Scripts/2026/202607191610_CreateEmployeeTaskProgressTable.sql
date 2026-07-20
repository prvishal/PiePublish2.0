-- Manual progress history for EmployeeTask.
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'EmployeeTaskProgress')
BEGIN
    CREATE TABLE [dbo].[EmployeeTaskProgress] (
        [EmployeeTaskProgressId] INT IDENTITY(1,1) NOT NULL,
        [EmployeeTaskId] INT NOT NULL,
        [ProgressPercent] DECIMAL(5,2) NOT NULL,
        [ProgressDate] DATE NOT NULL,
        [Notes] NVARCHAR(1000) NULL,
        [CreatedAt] DATETIME2(7) NOT NULL CONSTRAINT [DF_EmployeeTaskProgress_CreatedAt] DEFAULT (GETDATE()),
        [CreatedBy] INT NULL,
        CONSTRAINT [PK_EmployeeTaskProgress] PRIMARY KEY ([EmployeeTaskProgressId]),
        CONSTRAINT [FK_EmployeeTaskProgress_EmployeeTask] FOREIGN KEY ([EmployeeTaskId])
            REFERENCES [dbo].[EmployeeTask] ([EmployeeTaskId]),
        CONSTRAINT [CK_EmployeeTaskProgress_Percent] CHECK ([ProgressPercent] >= 0 AND [ProgressPercent] <= 100)
    );

    CREATE NONCLUSTERED INDEX [IX_EmployeeTaskProgress_EmployeeTaskId_ProgressDate]
        ON [dbo].[EmployeeTaskProgress]([EmployeeTaskId], [ProgressDate] DESC);
END
GO
