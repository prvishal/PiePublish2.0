-- Seed cities for United States (Iso2 = US). Runs once per country.
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'City')
   AND EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Country')
   AND NOT EXISTS (
       SELECT 1
       FROM [dbo].[City] c
       INNER JOIN [dbo].[Country] co ON co.[CountryId] = c.[CountryId]
       WHERE co.[Iso2] = 'US' AND c.[DeletedAt] IS NULL
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
        (N'New York',       N'نيويورك',        1),
        (N'Los Angeles',    N'لوس أنجلوس',     2),
        (N'Chicago',        N'شيكاغو',         3),
        (N'Houston',        N'هيوستن',         4),
        (N'Phoenix',        N'فينيكس',         5),
        (N'Philadelphia',   N'فيلادلفيا',      6),
        (N'San Antonio',    N'سان أنطونيو',    7),
        (N'San Diego',      N'سان دييغو',      8),
        (N'Dallas',         N'دالاس',          9),
        (N'San Jose',       N'سان خوسيه',      10)
    ) AS v([Name], [NameAr], [SortOrder])
    WHERE co.[Iso2] = 'US' AND co.[DeletedAt] IS NULL;
END
GO
