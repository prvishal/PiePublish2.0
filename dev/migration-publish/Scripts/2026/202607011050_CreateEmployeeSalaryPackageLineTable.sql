-- Component amounts per salary package revision.
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'EmployeeSalaryPackageLine')
BEGIN
    CREATE TABLE [dbo].[EmployeeSalaryPackageLine] (
        [SalaryPackageLineId] INT IDENTITY(1,1) NOT NULL,
        [SalaryPackageId] INT NOT NULL,
        [PayrollComponentId] INT NOT NULL,
        [Amount] DECIMAL(18,2) NOT NULL,
        [CreatedAt] DATETIME2(7) NOT NULL CONSTRAINT [DF_EmployeeSalaryPackageLine_CreatedAt] DEFAULT (GETDATE()),
        [CreatedBy] INT NULL,
        [UpdatedAt] DATETIME2(7) NULL,
        [UpdatedBy] INT NULL,
        [DeletedAt] DATETIME2(7) NULL,
        [DeletedBy] INT NULL,
        CONSTRAINT [PK_EmployeeSalaryPackageLine] PRIMARY KEY ([SalaryPackageLineId]),
        CONSTRAINT [FK_EmployeeSalaryPackageLine_SalaryPackage] FOREIGN KEY ([SalaryPackageId]) REFERENCES [dbo].[EmployeeSalaryPackage] ([SalaryPackageId]),
        CONSTRAINT [FK_EmployeeSalaryPackageLine_PayrollComponent] FOREIGN KEY ([PayrollComponentId]) REFERENCES [dbo].[PayrollComponent] ([PayrollComponentId]),
        CONSTRAINT [FK_EmployeeSalaryPackageLine_CreatedBy] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [FK_EmployeeSalaryPackageLine_UpdatedBy] FOREIGN KEY ([UpdatedBy]) REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [FK_EmployeeSalaryPackageLine_DeletedBy] FOREIGN KEY ([DeletedBy]) REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [CK_EmployeeSalaryPackageLine_Amount_NonNegative] CHECK ([Amount] >= 0)
    );

    CREATE UNIQUE NONCLUSTERED INDEX [UX_EmployeeSalaryPackageLine_Package_Component_Active]
        ON [dbo].[EmployeeSalaryPackageLine]([SalaryPackageId], [PayrollComponentId])
        WHERE [DeletedAt] IS NULL;
END
GO
