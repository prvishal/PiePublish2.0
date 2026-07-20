-- Seed cities for Egypt (Iso2 = EG). Runs once per country.
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'City')
   AND EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Country')
   AND NOT EXISTS (
       SELECT 1
       FROM [dbo].[City] c
       INNER JOIN [dbo].[Country] co ON co.[CountryId] = c.[CountryId]
       WHERE co.[Iso2] = 'EG' AND c.[DeletedAt] IS NULL
   )
BEGIN
    INSERT INTO [dbo].[City] (
        [CountryId], [Name], [NameAr], [SortOrder],
        [CreatedAt], [CreatedBy], [UpdatedAt], [UpdatedBy], [DeletedAt], [DeletedBy]
    )
    SELECT co.[CountryId], v.[Name], v.[NameAr], v.[SortOrder],
           GETDATE(), NULL, NULL, NULL, NULL, NULL
    FROM [dbo].[Country] co
    CROSS APPLY (VALUES
        (N'Cairo',              N'القاهرة',        1),
        (N'Alexandria',         N'الإسكندرية',     2),
        (N'Giza',               N'الجيزة',         3),
        (N'Shubra El Kheima',   N'شبرا الخيمة',    4),
        (N'Port Said',          N'بورسعيد',        5),
        (N'Suez',               N'السويس',         6),
        (N'Luxor',              N'الأقصر',         7),
        (N'Aswan',              N'أسوان',          8),
        (N'Mansoura',           N'المنصورة',       9),
        (N'Tanta',              N'طنطا',           10)
    ) AS v([Name], [NameAr], [SortOrder])
    WHERE co.[Iso2] = 'EG' AND co.[DeletedAt] IS NULL;
END
GO
