-- Seed cities for Saudi Arabia (Iso2 = SA). Runs once per country.
-- Source: docs/country city arabic english.xlsx (Sheet City).
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'City')
   AND EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Country')
   AND NOT EXISTS (
       SELECT 1
       FROM [dbo].[City] c
       INNER JOIN [dbo].[Country] co ON co.[CountryId] = c.[CountryId]
       WHERE co.[Iso2] = 'SA' AND c.[DeletedAt] IS NULL
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
        (N'Riyadh',           N'الرياض',          1),
        (N'Jeddah',           N'جدة',             2),
        (N'Makkah',           N'مكة المكرمة',     3),
        (N'Madinah',          N'المدينة المنورة', 4),
        (N'Dammam',           N'الدمام',          5),
        (N'Khobar',           N'الخبر',           6),
        (N'Dhahran',          N'الظهران',         7),
        (N'Taif',             N'الطائف',          8),
        (N'Tabuk',            N'تبوك',            9),
        (N'Abha',             N'أبها',            10),
        (N'Khamis Mushait',   N'خميس مشيط',       11),
        (N'Buraidah',         N'بريدة',           12),
        (N'Hail',             N'حائل',            13),
        (N'Najran',           N'نجران',           14),
        (N'Jazan',            N'جازان',           15),
        (N'Yanbu',            N'ينبع',            16),
        (N'Jubail',           N'الجبيل',          17),
        (N'Hofuf',            N'الهفوف',          18),
        (N'Al Mubarraz',      N'المبرز',          19),
        (N'Qatif',            N'القطيف',          20),
        (N'Al Kharj',         N'الخرج',           21),
        (N'Sakaka',           N'سكاكا',           22),
        (N'Arar',             N'عرعر',            23),
        (N'Al Bahah',         N'الباحة',          24),
        (N'Unaizah',          N'عنيزة',           25),
        (N'Diriyah',          N'الدرعية',         26),
        (N'Ras Tanura',       N'رأس تنورة',       27),
        (N'Al Khafji',        N'الخفجي',          28),
        (N'Al Majmaah',       N'المجمعة',         29),
        (N'Dawadmi',          N'الدوادمي',        30),
        (N'Al Zulfi',         N'الزلفي',          31),
        (N'Shaqra',           N'شقراء',           32),
        (N'Wadi ad-Dawasir',  N'وادي الدواسر',    33),
        (N'Bisha',            N'بيشة',            34),
        (N'Sharurah',         N'شرورة',           35),
        (N'Rafha',            N'رفحاء',           36),
        (N'Turaif',           N'طريف',            37),
        (N'Al Qurayyat',      N'القريات',         38),
        (N'Al Wajh',          N'الوجه',           39),
        (N'Umluj',            N'أملج',            40),
        (N'Duba',             N'ضباء',            41),
        (N'Rabigh',           N'رابغ',            42),
        (N'Al Lith',          N'الليث',           43),
        (N'Al Namas',         N'النماص',          44),
        (N'Muhayil',          N'محايل عسير',      45),
        (N'Samtah',           N'صامطة',           46),
        (N'Abu Arish',        N'أبو عريش',        47),
        (N'Sabya',            N'صبيا',            48),
        (N'Dhahran Al Janub', N'ظهران الجنوب',    49),
        (N'Baljurashi',       N'بلجرشي',          50),
        (N'Tanomah',          N'تنومة',           51),
        (N'Hafr Al Batin',    N'حفر الباطن',      52),
        (N'Buqayq',           N'بقيق',            53)
    ) AS v([Name], [NameAr], [SortOrder])
    WHERE co.[Iso2] = 'SA' AND co.[DeletedAt] IS NULL;
END
GO
