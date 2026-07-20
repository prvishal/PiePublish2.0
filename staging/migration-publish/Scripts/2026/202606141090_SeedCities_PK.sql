-- Seed cities for Pakistan (Iso2 = PK). Runs once per country.
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'City')
   AND EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Country')
   AND NOT EXISTS (
       SELECT 1
       FROM [dbo].[City] c
       INNER JOIN [dbo].[Country] co ON co.[CountryId] = c.[CountryId]
       WHERE co.[Iso2] = 'PK' AND c.[DeletedAt] IS NULL
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
        (N'Karachi',      N'كراتشي',     1),
        (N'Lahore',       N'لاهور',      2),
        (N'Islamabad',    N'إسلام آباد', 3),
        (N'Rawalpindi',   N'روالبندي',   4),
        (N'Faisalabad',   N'فيصل آباد',  5),
        (N'Multan',       N'ملتان',      6),
        (N'Peshawar',     N'بيشاور',     7),
        (N'Quetta',       N'كويتا',      8),
        (N'Sialkot',      N'سيالكوت',    9),
        (N'Hyderabad',    N'حيدر آباد',  10)
    ) AS v([Name], [NameAr], [SortOrder])
    WHERE co.[Iso2] = 'PK' AND co.[DeletedAt] IS NULL;
END
GO
