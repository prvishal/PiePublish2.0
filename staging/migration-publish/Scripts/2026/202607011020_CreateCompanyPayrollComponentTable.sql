-- Per-company payroll components. All global components are linked per company.
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'CompanyPayrollComponent')
BEGIN
    CREATE TABLE [dbo].[CompanyPayrollComponent] (
        [CompanyPayrollComponentId] INT IDENTITY(1,1) NOT NULL,
        [CompanyId] INT NOT NULL,
        [PayrollComponentId] INT NOT NULL,
        [IsEnabled] BIT NOT NULL CONSTRAINT [DF_CompanyPayrollComponent_IsEnabled] DEFAULT (1),
        [IsMandatory] BIT NOT NULL CONSTRAINT [DF_CompanyPayrollComponent_IsMandatory] DEFAULT (0),
        [SortOrder] INT NOT NULL,
        [DefaultAmount] DECIMAL(18,2) NULL,
        [CreatedAt] DATETIME2(7) NOT NULL CONSTRAINT [DF_CompanyPayrollComponent_CreatedAt] DEFAULT (GETDATE()),
        [CreatedBy] INT NULL,
        [UpdatedAt] DATETIME2(7) NULL,
        [UpdatedBy] INT NULL,
        [DeletedAt] DATETIME2(7) NULL,
        [DeletedBy] INT NULL,
        CONSTRAINT [PK_CompanyPayrollComponent] PRIMARY KEY ([CompanyPayrollComponentId]),
        CONSTRAINT [FK_CompanyPayrollComponent_Company] FOREIGN KEY ([CompanyId]) REFERENCES [dbo].[Company] ([CompanyId]) ON DELETE NO ACTION,
        CONSTRAINT [FK_CompanyPayrollComponent_PayrollComponent] FOREIGN KEY ([PayrollComponentId]) REFERENCES [dbo].[PayrollComponent] ([PayrollComponentId]),
        CONSTRAINT [FK_CompanyPayrollComponent_CreatedBy] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [FK_CompanyPayrollComponent_UpdatedBy] FOREIGN KEY ([UpdatedBy]) REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [FK_CompanyPayrollComponent_DeletedBy] FOREIGN KEY ([DeletedBy]) REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [CK_CompanyPayrollComponent_DefaultAmount] CHECK ([DefaultAmount] IS NULL OR [DefaultAmount] >= 0)
    );

    CREATE UNIQUE NONCLUSTERED INDEX [UX_CompanyPayrollComponent_Company_Component_Active]
        ON [dbo].[CompanyPayrollComponent]([CompanyId], [PayrollComponentId])
        WHERE [DeletedAt] IS NULL;

    CREATE NONCLUSTERED INDEX [IX_CompanyPayrollComponent_CompanyId_SortOrder]
        ON [dbo].[CompanyPayrollComponent]([CompanyId], [SortOrder])
        INCLUDE ([PayrollComponentId], [IsEnabled], [IsMandatory], [DeletedAt]);
END
GO
