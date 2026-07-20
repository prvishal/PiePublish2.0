-- Global payroll component lookup. Prerequisites: dbo.[User].
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'PayrollComponent')
BEGIN
    CREATE TABLE [dbo].[PayrollComponent] (
        [PayrollComponentId] INT IDENTITY(1,1) NOT NULL,
        [Code] VARCHAR(20) NOT NULL,
        [Name] NVARCHAR(100) NOT NULL,
        [NameAr] NVARCHAR(200) NOT NULL,
        [SortOrder] INT NOT NULL,
        [IsSystem] BIT NOT NULL CONSTRAINT [DF_PayrollComponent_IsSystem] DEFAULT (0),
        [CreatedAt] DATETIME2(7) NOT NULL CONSTRAINT [DF_PayrollComponent_CreatedAt] DEFAULT (GETDATE()),
        [CreatedBy] INT NULL,
        [UpdatedAt] DATETIME2(7) NULL,
        [UpdatedBy] INT NULL,
        [DeletedAt] DATETIME2(7) NULL,
        [DeletedBy] INT NULL,
        CONSTRAINT [PK_PayrollComponent] PRIMARY KEY ([PayrollComponentId]),
        CONSTRAINT [FK_PayrollComponent_CreatedBy] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [FK_PayrollComponent_UpdatedBy] FOREIGN KEY ([UpdatedBy]) REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [FK_PayrollComponent_DeletedBy] FOREIGN KEY ([DeletedBy]) REFERENCES [dbo].[User] ([UserId])
    );

    CREATE UNIQUE NONCLUSTERED INDEX [UX_PayrollComponent_Code_Active]
        ON [dbo].[PayrollComponent]([Code])
        WHERE [DeletedAt] IS NULL;

    CREATE UNIQUE NONCLUSTERED INDEX [UX_PayrollComponent_Name_Active]
        ON [dbo].[PayrollComponent]([Name])
        WHERE [DeletedAt] IS NULL;

    CREATE UNIQUE NONCLUSTERED INDEX [UX_PayrollComponent_NameAr_Active]
        ON [dbo].[PayrollComponent]([NameAr])
        WHERE [DeletedAt] IS NULL;
END
GO
