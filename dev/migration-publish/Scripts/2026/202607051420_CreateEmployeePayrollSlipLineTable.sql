IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'EmployeePayrollSlipLine')
BEGIN
    CREATE TABLE [dbo].[EmployeePayrollSlipLine] (
        [EmployeePayrollSlipLineId] INT IDENTITY(1,1) NOT NULL,
        [EmployeePayrollSlipId]     INT NOT NULL,
        [PayrollComponentId]        INT NOT NULL,
        [Amount]                    DECIMAL(18,2) NOT NULL,
        [SortOrder]                 INT NOT NULL CONSTRAINT [DF_EmployeePayrollSlipLine_SortOrder] DEFAULT (0),

        [CreatedAt]                 DATETIME2(7) NOT NULL
            CONSTRAINT [DF_EmployeePayrollSlipLine_CreatedAt] DEFAULT (GETDATE()),
        [CreatedBy]                 INT NULL,
        [UpdatedAt]                 DATETIME2(7) NULL,
        [UpdatedBy]                 INT NULL,
        [DeletedAt]                 DATETIME2(7) NULL,
        [DeletedBy]                 INT NULL,

        CONSTRAINT [PK_EmployeePayrollSlipLine] PRIMARY KEY ([EmployeePayrollSlipLineId]),
        CONSTRAINT [FK_EmployeePayrollSlipLine_Slip] FOREIGN KEY ([EmployeePayrollSlipId]) REFERENCES [dbo].[EmployeePayrollSlip] ([EmployeePayrollSlipId]),
        CONSTRAINT [FK_EmployeePayrollSlipLine_PayrollComponent] FOREIGN KEY ([PayrollComponentId]) REFERENCES [dbo].[PayrollComponent] ([PayrollComponentId]),
        CONSTRAINT [FK_EmployeePayrollSlipLine_CreatedBy] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [FK_EmployeePayrollSlipLine_UpdatedBy] FOREIGN KEY ([UpdatedBy]) REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [FK_EmployeePayrollSlipLine_DeletedBy] FOREIGN KEY ([DeletedBy]) REFERENCES [dbo].[User] ([UserId]),

        CONSTRAINT [CK_EmployeePayrollSlipLine_Amount_NonNegative] CHECK ([Amount] >= 0)
    );

    CREATE UNIQUE NONCLUSTERED INDEX [UX_EmployeePayrollSlipLine_Slip_Component_Active]
        ON [dbo].[EmployeePayrollSlipLine]([EmployeePayrollSlipId], [PayrollComponentId])
        WHERE [DeletedAt] IS NULL;
END
GO
