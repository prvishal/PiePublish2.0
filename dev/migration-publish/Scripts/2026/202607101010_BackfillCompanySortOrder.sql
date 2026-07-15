;WITH ranked AS (
    SELECT
        c.[CompanyId],
        ROW_NUMBER() OVER (
            PARTITION BY c.[ClientId]
            ORDER BY c.[CompanyName], c.[CompanyId]
        ) AS rn
    FROM [dbo].[Company] c
    WHERE c.[DeletedAt] IS NULL
)
UPDATE c
SET c.[SortOrder] = r.rn
FROM [dbo].[Company] c
INNER JOIN ranked r ON r.[CompanyId] = c.[CompanyId];
GO
