-- Salary revision header per employment stint. Import: EffectiveFrom = JoiningDate.
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'EmployeeSalaryPackage')
BEGIN
    CREATE TABLE [dbo].[EmployeeSalaryPackage] (
        [SalaryPackageId] INT IDENTITY(1,1) NOT NULL,
        [EmploymentId] INT NOT NULL,
        [EffectiveFrom] DATE NOT NULL,
        [EffectiveTo] DATE NULL,
        [CurrencyCode] CHAR(3) NOT NULL CONSTRAINT [DF_EmployeeSalaryPackage_CurrencyCode] DEFAULT ('SAR'),
        [Notes] NVARCHAR(500) NULL,
        [CreatedAt] DATETIME2(7) NOT NULL CONSTRAINT [DF_EmployeeSalaryPackage_CreatedAt] DEFAULT (GETDATE()),
        [CreatedBy] INT NULL,
        [UpdatedAt] DATETIME2(7) NULL,
        [UpdatedBy] INT NULL,
        [DeletedAt] DATETIME2(7) NULL,
        [DeletedBy] INT NULL,
        CONSTRAINT [PK_EmployeeSalaryPackage] PRIMARY KEY ([SalaryPackageId]),
        CONSTRAINT [FK_EmployeeSalaryPackage_Employment] FOREIGN KEY ([EmploymentId]) REFERENCES [dbo].[EmployeeEmployment] ([EmploymentId]),
        CONSTRAINT [FK_EmployeeSalaryPackage_CreatedBy] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [FK_EmployeeSalaryPackage_UpdatedBy] FOREIGN KEY ([UpdatedBy]) REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [FK_EmployeeSalaryPackage_DeletedBy] FOREIGN KEY ([DeletedBy]) REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [CK_EmployeeSalaryPackage_EffectiveRange]
            CHECK ([EffectiveTo] IS NULL OR [EffectiveTo] >= [EffectiveFrom])
    );

    CREATE NONCLUSTERED INDEX [IX_EmployeeSalaryPackage_EmploymentId_EffectiveFrom]
        ON [dbo].[EmployeeSalaryPackage]([EmploymentId], [EffectiveFrom])
        INCLUDE ([EffectiveTo], [CurrencyCode], [DeletedAt]);
END
GO
