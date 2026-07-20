-- Backfill Employee CountryId (Saudi) and CityId (Riyadh) for existing rows.
-- Prerequisites:
--   202606161400_AlterEmployeeProfileColumns.sql
--   SeedCities_SA (202606141060_SeedCities_SA.sql)
-- Runs only once (tracked in __ScriptHistory).
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Employee')
   AND EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Country')
   AND EXISTS (SELECT 1 FROM sys.tables WHERE name = 'City')
BEGIN
    DECLARE @SaudiCountryId INT;
    DECLARE @SaudiCityId INT;

    SELECT @SaudiCountryId = co.[CountryId]
    FROM [dbo].[Country] co
    WHERE co.[Iso2] = N'SA'
      AND co.[DeletedAt] IS NULL;

    IF @SaudiCountryId IS NOT NULL
       AND COLUMNPROPERTY(OBJECT_ID('dbo.Employee'), 'CountryId', 'ColumnId') IS NOT NULL
    BEGIN
        UPDATE [dbo].[Employee]
        SET [CountryId] = @SaudiCountryId
        WHERE [CountryId] IS NULL
          AND [DeletedAt] IS NULL;
    END

    SELECT TOP 1 @SaudiCityId = c.[CityId]
    FROM [dbo].[City] c
    INNER JOIN [dbo].[Country] co ON co.[CountryId] = c.[CountryId]
    WHERE co.[Iso2] = N'SA'
      AND co.[DeletedAt] IS NULL
      AND c.[DeletedAt] IS NULL
    ORDER BY
        CASE WHEN c.[Name] = N'Riyadh' THEN 0 ELSE 1 END,
        c.[SortOrder],
        c.[CityId];

    IF @SaudiCityId IS NOT NULL
       AND COLUMNPROPERTY(OBJECT_ID('dbo.Employee'), 'CityId', 'ColumnId') IS NOT NULL
    BEGIN
        UPDATE [dbo].[Employee]
        SET [CityId] = @SaudiCityId
        WHERE [CityId] IS NULL
          AND [CountryId] = @SaudiCountryId
          AND [DeletedAt] IS NULL;
    END
END
GO
