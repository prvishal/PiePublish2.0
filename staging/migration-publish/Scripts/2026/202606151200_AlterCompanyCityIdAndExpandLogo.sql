-- Alter Company: drop City, add CityId FK; expand Logo to VARCHAR(500).
-- Prerequisites: dbo.City (202606141040_CreateCityTable.sql).
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Company')
BEGIN
    -- Logo: VARCHAR(100) -> VARCHAR(500)
    IF COLUMNPROPERTY(OBJECT_ID('dbo.Company'), 'Logo', 'ColumnId') IS NOT NULL
    BEGIN
        IF EXISTS (
            SELECT 1
            FROM sys.columns c
            INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
            WHERE c.object_id = OBJECT_ID('dbo.Company')
              AND c.name = 'Logo'
              AND (t.name <> 'varchar' OR c.max_length <> 500)
        )
            ALTER TABLE [dbo].[Company] ALTER COLUMN [Logo] VARCHAR(500) NULL;
    END

    -- Add CityId
    IF COLUMNPROPERTY(OBJECT_ID('dbo.Company'), 'CityId', 'ColumnId') IS NULL
        ALTER TABLE [dbo].[Company] ADD [CityId] INT NULL;

    -- Optional: backfill CityId from legacy City text before drop
    -- UPDATE c
    -- SET c.[CityId] = ci.[CityId]
    -- FROM [dbo].[Company] c
    -- INNER JOIN [dbo].[City] ci ON ci.[Name] = c.[City] AND ci.[DeletedAt] IS NULL
    -- WHERE c.[City] IS NOT NULL AND c.[CityId] IS NULL;

    -- FK Company -> City
    IF OBJECT_ID(N'dbo.City', N'U') IS NOT NULL
       AND NOT EXISTS (
           SELECT 1 FROM sys.foreign_keys
           WHERE name = N'FK_Company_City' AND parent_object_id = OBJECT_ID(N'dbo.Company')
       )
        ALTER TABLE [dbo].[Company] WITH CHECK ADD CONSTRAINT [FK_Company_City]
            FOREIGN KEY ([CityId]) REFERENCES [dbo].[City] ([CityId]) ON DELETE NO ACTION;

    -- Drop legacy City column
    IF COLUMNPROPERTY(OBJECT_ID('dbo.Company'), 'City', 'ColumnId') IS NOT NULL
        ALTER TABLE [dbo].[Company] DROP COLUMN [City];
END
GO
