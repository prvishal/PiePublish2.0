-- Create City lookup table (English + Arabic labels). Runs only once (tracked in __ScriptHistory).
-- Name and NameAr unique per CountryId among active rows.
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'City')
BEGIN
    CREATE TABLE [dbo].[City] (
        [CityId] INT IDENTITY(1,1) NOT NULL,
        [CountryId] INT NOT NULL,
        [Name] NVARCHAR(100) NOT NULL,
        [NameAr] NVARCHAR(200) NOT NULL,
        [SortOrder] INT NOT NULL,
        [CreatedAt] DATETIME2(7) NOT NULL CONSTRAINT [DF_City_CreatedAt] DEFAULT (GETDATE()),
        [CreatedBy] INT NULL,
        [UpdatedAt] DATETIME2(7) NULL,
        [UpdatedBy] INT NULL,
        [DeletedAt] DATETIME2(7) NULL,
        [DeletedBy] INT NULL,
        CONSTRAINT [PK_City] PRIMARY KEY ([CityId]),
        CONSTRAINT [FK_City_Country] FOREIGN KEY ([CountryId]) REFERENCES [dbo].[Country] ([CountryId]),
        CONSTRAINT [FK_City_CreatedBy] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [FK_City_UpdatedBy] FOREIGN KEY ([UpdatedBy]) REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [FK_City_DeletedBy] FOREIGN KEY ([DeletedBy]) REFERENCES [dbo].[User] ([UserId])
    );

    CREATE UNIQUE NONCLUSTERED INDEX [UX_City_CountryId_Name_Active]
        ON [dbo].[City]([CountryId], [Name])
        WHERE [DeletedAt] IS NULL;

    CREATE UNIQUE NONCLUSTERED INDEX [UX_City_CountryId_NameAr_Active]
        ON [dbo].[City]([CountryId], [NameAr])
        WHERE [DeletedAt] IS NULL;

    CREATE NONCLUSTERED INDEX [IX_City_CountryId_SortOrder]
        ON [dbo].[City]([CountryId], [SortOrder])
        WHERE [DeletedAt] IS NULL;
END
GO
