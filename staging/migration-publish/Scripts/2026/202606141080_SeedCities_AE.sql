-- Seed cities for United Arab Emirates (Iso2 = AE). Runs once per country.
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'City')
   AND EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Country')
   AND NOT EXISTS (
       SELECT 1
       FROM [dbo].[City] c
       INNER JOIN [dbo].[Country] co ON co.[CountryId] = c.[CountryId]
       WHERE co.[Iso2] = 'AE' AND c.[DeletedAt] IS NULL
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
        (N'Dubai',          N'دبي',        1),
        (N'Abu Dhabi',      N'أبوظبي',     2),
        (N'Sharjah',        N'الشارقة',    3),
        (N'Ajman',          N'عجمان',      4),
        (N'Ras Al Khaimah', N'رأس الخيمة', 5),
        (N'Fujairah',       N'الفجيرة',    6),
        (N'Umm Al Quwain',  N'أم القيوين', 7),
        (N'Al Ain',         N'العين',      8)
    ) AS v([Name], [NameAr], [SortOrder])
    WHERE co.[Iso2] = 'AE' AND co.[DeletedAt] IS NULL;
END
GO
