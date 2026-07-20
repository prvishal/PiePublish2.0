-- Backfill Company.CityId with a Saudi lookup city (Riyadh) for existing rows.
-- Prerequisites: dbo.Company.CityId, dbo.City, Saudi cities seeded (SeedCities_SA).
-- Run after: 202606151200_AlterCompanyCityIdAndExpandLogo.sql
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Company')
   AND EXISTS (SELECT 1 FROM sys.tables WHERE name = 'City')
   AND COLUMNPROPERTY(OBJECT_ID('dbo.Company'), 'CityId', 'ColumnId') IS NOT NULL
BEGIN
    DECLARE @SaudiCityId INT;

    -- Prefer Riyadh (SortOrder 1 in SeedCities_SA); fallback to any active SA city
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
    BEGIN
        UPDATE [dbo].[Company]
        SET [CityId] = @SaudiCityId
        WHERE [CityId] IS NULL
          AND [DeletedAt] IS NULL;
    END
END
GO
