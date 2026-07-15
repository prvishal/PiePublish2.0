-- Expand Employee.Logo to VARCHAR(500) for stored file paths (same as Company.Logo).
IF COLUMNPROPERTY(OBJECT_ID('dbo.Employee'), 'Logo', 'ColumnId') IS NOT NULL
BEGIN
    IF EXISTS (
        SELECT 1
        FROM sys.columns c
        INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
        WHERE c.object_id = OBJECT_ID('dbo.Employee')
          AND c.name = 'Logo'
          AND (t.name <> 'varchar' OR c.max_length < 500)
    )
    BEGIN
        ALTER TABLE [dbo].[Employee] ALTER COLUMN [Logo] VARCHAR(500) NULL;
    END
END
