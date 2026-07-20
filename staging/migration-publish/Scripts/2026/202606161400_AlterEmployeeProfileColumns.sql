-- Alter Employee: profile columns, CityId, MedicalInsuranceStatus; drop legacy City text.
-- CountryId defaults to Saudi Arabia (Iso2 = SA), not a hard-coded id.
-- Prerequisites:
--   dbo.Employee  (202605171010_CreateEmployeeTable.sql)
--   dbo.Marital   (202606141000_CreateMaritalTable.sql)
--   dbo.Country   (202606141030_CreateCountryTable.sql + SeedAllCountries)
--   dbo.City      (202606141040_CreateCityTable.sql)
-- Runs only once (tracked in __ScriptHistory).

-- Batch 1: Gender, HijriDOB, MaritalStatus + FK
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Employee')
BEGIN
    IF COLUMNPROPERTY(OBJECT_ID('dbo.Employee'), 'Gender', 'ColumnId') IS NOT NULL
    BEGIN
        IF EXISTS (
            SELECT 1
            FROM sys.columns c
            INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
            WHERE c.object_id = OBJECT_ID('dbo.Employee')
              AND c.name = 'Gender'
              AND t.name = 'tinyint'
        )
            ALTER TABLE [dbo].[Employee] ALTER COLUMN [Gender] INT NULL;
    END

    IF COLUMNPROPERTY(OBJECT_ID('dbo.Employee'), 'HijriDOB', 'ColumnId') IS NULL
        ALTER TABLE [dbo].[Employee] ADD [HijriDOB] NVARCHAR(200) NULL;

    IF COLUMNPROPERTY(OBJECT_ID('dbo.Employee'), 'MaritalStatus', 'ColumnId') IS NULL
        ALTER TABLE [dbo].[Employee] ADD [MaritalStatus] INT NULL;

    IF OBJECT_ID(N'dbo.Marital', N'U') IS NOT NULL
       AND COLUMNPROPERTY(OBJECT_ID('dbo.Employee'), 'MaritalStatus', 'ColumnId') IS NOT NULL
       AND NOT EXISTS (
           SELECT 1 FROM sys.foreign_keys
           WHERE name = N'FK_Employee_Marital' AND parent_object_id = OBJECT_ID(N'dbo.Employee')
       )
        ALTER TABLE [dbo].[Employee] WITH CHECK ADD CONSTRAINT [FK_Employee_Marital]
            FOREIGN KEY ([MaritalStatus]) REFERENCES [dbo].[Marital] ([MaritalId]) ON DELETE NO ACTION;
END
GO

-- Batch 2: add CountryId only (no reference in same batch)
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Employee')
BEGIN
    IF COLUMNPROPERTY(OBJECT_ID('dbo.Employee'), 'CountryId', 'ColumnId') IS NULL
        ALTER TABLE [dbo].[Employee] ADD [CountryId] INT NULL;
END
GO

-- Batch 3: backfill CountryId (Saudi), NOT NULL, default, FK
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Employee')
BEGIN
    DECLARE @SaudiCountryId INT;

    SELECT @SaudiCountryId = co.[CountryId]
    FROM [dbo].[Country] co
    WHERE co.[Iso2] = N'SA'
      AND co.[DeletedAt] IS NULL;

    IF @SaudiCountryId IS NOT NULL
       AND COLUMNPROPERTY(OBJECT_ID('dbo.Employee'), 'CountryId', 'ColumnId') IS NOT NULL
    BEGIN
        UPDATE [dbo].[Employee]
        SET [CountryId] = @SaudiCountryId
        WHERE [CountryId] IS NULL;

        IF NOT EXISTS (SELECT 1 FROM [dbo].[Employee] WHERE [CountryId] IS NULL)
            ALTER TABLE [dbo].[Employee] ALTER COLUMN [CountryId] INT NOT NULL;

        IF NOT EXISTS (
            SELECT 1 FROM sys.default_constraints
            WHERE name = N'DF_Employee_CountryId'
              AND parent_object_id = OBJECT_ID(N'dbo.Employee')
        )
        BEGIN
            DECLARE @dfCountrySql NVARCHAR(500) =
                N'ALTER TABLE [dbo].[Employee] ADD CONSTRAINT [DF_Employee_CountryId] DEFAULT ('
                + CAST(@SaudiCountryId AS NVARCHAR(11))
                + N') FOR [CountryId];';
            EXEC (@dfCountrySql);
        END
    END

    IF OBJECT_ID(N'dbo.Country', N'U') IS NOT NULL
       AND COLUMNPROPERTY(OBJECT_ID('dbo.Employee'), 'CountryId', 'ColumnId') IS NOT NULL
       AND NOT EXISTS (
           SELECT 1 FROM sys.foreign_keys
           WHERE name = N'FK_Employee_Country' AND parent_object_id = OBJECT_ID(N'dbo.Employee')
       )
        ALTER TABLE [dbo].[Employee] WITH CHECK ADD CONSTRAINT [FK_Employee_Country]
            FOREIGN KEY ([CountryId]) REFERENCES [dbo].[Country] ([CountryId]) ON DELETE NO ACTION;
END
GO

-- Batch 4: add CityId, Nationality, MedicalInsuranceStatus (no FK yet)
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Employee')
BEGIN
    IF COLUMNPROPERTY(OBJECT_ID('dbo.Employee'), 'CityId', 'ColumnId') IS NULL
        ALTER TABLE [dbo].[Employee] ADD [CityId] INT NULL;

    IF COLUMNPROPERTY(OBJECT_ID('dbo.Employee'), 'Nationality', 'ColumnId') IS NULL
        ALTER TABLE [dbo].[Employee] ADD [Nationality] INT NULL;

    IF COLUMNPROPERTY(OBJECT_ID('dbo.Employee'), 'MedicalInsuranceStatus', 'ColumnId') IS NULL
        ALTER TABLE [dbo].[Employee] ADD [MedicalInsuranceStatus] INT NULL;
END
GO

-- Batch 5: FKs for CityId and Nationality
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Employee')
BEGIN
    IF OBJECT_ID(N'dbo.City', N'U') IS NOT NULL
       AND COLUMNPROPERTY(OBJECT_ID('dbo.Employee'), 'CityId', 'ColumnId') IS NOT NULL
       AND NOT EXISTS (
           SELECT 1 FROM sys.foreign_keys
           WHERE name = N'FK_Employee_City' AND parent_object_id = OBJECT_ID(N'dbo.Employee')
       )
        ALTER TABLE [dbo].[Employee] WITH CHECK ADD CONSTRAINT [FK_Employee_City]
            FOREIGN KEY ([CityId]) REFERENCES [dbo].[City] ([CityId]) ON DELETE NO ACTION;

    IF OBJECT_ID(N'dbo.Country', N'U') IS NOT NULL
       AND COLUMNPROPERTY(OBJECT_ID('dbo.Employee'), 'Nationality', 'ColumnId') IS NOT NULL
       AND NOT EXISTS (
           SELECT 1 FROM sys.foreign_keys
           WHERE name = N'FK_Employee_Nationality' AND parent_object_id = OBJECT_ID(N'dbo.Employee')
       )
        ALTER TABLE [dbo].[Employee] WITH CHECK ADD CONSTRAINT [FK_Employee_Nationality]
            FOREIGN KEY ([Nationality]) REFERENCES [dbo].[Country] ([CountryId]) ON DELETE NO ACTION;
END
GO

-- Batch 6: backfill CityId from legacy City text
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Employee')
   AND OBJECT_ID(N'dbo.City', N'U') IS NOT NULL
   AND COLUMNPROPERTY(OBJECT_ID('dbo.Employee'), 'CityId', 'ColumnId') IS NOT NULL
   AND COLUMNPROPERTY(OBJECT_ID('dbo.Employee'), 'City', 'ColumnId') IS NOT NULL
   AND COLUMNPROPERTY(OBJECT_ID('dbo.Employee'), 'CountryId', 'ColumnId') IS NOT NULL
BEGIN
    UPDATE e
    SET e.[CityId] = ci.[CityId]
    FROM [dbo].[Employee] e
    INNER JOIN [dbo].[City] ci
        ON ci.[CountryId] = e.[CountryId]
       AND ci.[Name] = e.[City]
       AND ci.[DeletedAt] IS NULL
    WHERE e.[City] IS NOT NULL
      AND LTRIM(RTRIM(e.[City])) <> N''
      AND e.[CityId] IS NULL
      AND e.[DeletedAt] IS NULL;
END
GO

-- Batch 7: drop legacy City text column
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Employee')
BEGIN
    IF COLUMNPROPERTY(OBJECT_ID('dbo.Employee'), 'City', 'ColumnId') IS NOT NULL
        ALTER TABLE [dbo].[Employee] DROP COLUMN [City];
END
GO
