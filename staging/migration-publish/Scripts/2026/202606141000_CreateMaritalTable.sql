-- Create Marital lookup table (English + Arabic labels). Runs only once (tracked in __ScriptHistory).
-- Audit columns match Client / EmployeePlan pattern. Run before SeedMarital script.
-- Name and NameAr are unique among active (non-deleted) rows.
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Marital')
BEGIN
    CREATE TABLE [dbo].[Marital] (
        [MaritalId] INT IDENTITY(1,1) NOT NULL,
        [Name] NVARCHAR(100) NOT NULL,
        [NameAr] NVARCHAR(200) NOT NULL,
        [SortOrder] INT NOT NULL,
        [CreatedAt] DATETIME2(7) NOT NULL CONSTRAINT [DF_Marital_CreatedAt] DEFAULT (GETDATE()),
        [CreatedBy] INT NULL,
        [UpdatedAt] DATETIME2(7) NULL,
        [UpdatedBy] INT NULL,
        [DeletedAt] DATETIME2(7) NULL,
        [DeletedBy] INT NULL,
        CONSTRAINT [PK_Marital] PRIMARY KEY ([MaritalId]),
        CONSTRAINT [FK_Marital_CreatedBy] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [FK_Marital_UpdatedBy] FOREIGN KEY ([UpdatedBy]) REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [FK_Marital_DeletedBy] FOREIGN KEY ([DeletedBy]) REFERENCES [dbo].[User] ([UserId])
    );

    CREATE UNIQUE NONCLUSTERED INDEX [UX_Marital_Name_Active]
        ON [dbo].[Marital]([Name])
        WHERE [DeletedAt] IS NULL;

    CREATE UNIQUE NONCLUSTERED INDEX [UX_Marital_NameAr_Active]
        ON [dbo].[Marital]([NameAr])
        WHERE [DeletedAt] IS NULL;
END
GO
