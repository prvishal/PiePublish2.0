-- Create Country lookup table (English + Arabic labels). Runs only once (tracked in __ScriptHistory).
-- Name and NameAr unique among active rows — same pattern as Marital.
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Country')
BEGIN
    CREATE TABLE [dbo].[Country] (
        [CountryId] INT IDENTITY(1,1) NOT NULL,
        [Name] NVARCHAR(100) NOT NULL,
        [NameAr] NVARCHAR(200) NOT NULL,
        [Iso2] CHAR(2) NOT NULL,
        [SortOrder] INT NOT NULL,
        [CreatedAt] DATETIME2(7) NOT NULL CONSTRAINT [DF_Country_CreatedAt] DEFAULT (GETDATE()),
        [CreatedBy] INT NULL,
        [UpdatedAt] DATETIME2(7) NULL,
        [UpdatedBy] INT NULL,
        [DeletedAt] DATETIME2(7) NULL,
        [DeletedBy] INT NULL,
        CONSTRAINT [PK_Country] PRIMARY KEY ([CountryId]),
        CONSTRAINT [FK_Country_CreatedBy] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [FK_Country_UpdatedBy] FOREIGN KEY ([UpdatedBy]) REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [FK_Country_DeletedBy] FOREIGN KEY ([DeletedBy]) REFERENCES [dbo].[User] ([UserId])
    );

    CREATE UNIQUE NONCLUSTERED INDEX [UX_Country_Name_Active]
        ON [dbo].[Country]([Name])
        WHERE [DeletedAt] IS NULL;

    CREATE UNIQUE NONCLUSTERED INDEX [UX_Country_NameAr_Active]
        ON [dbo].[Country]([NameAr])
        WHERE [DeletedAt] IS NULL;

    CREATE UNIQUE NONCLUSTERED INDEX [UX_Country_Iso2_Active]
        ON [dbo].[Country]([Iso2])
        WHERE [DeletedAt] IS NULL;
END
GO
