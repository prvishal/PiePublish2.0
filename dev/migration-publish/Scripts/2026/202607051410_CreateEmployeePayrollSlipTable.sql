-- One payslip per employee per payroll batch.
-- Prerequisites: PayrollBatch, Employee, EmployeeEmployment, EmployeeSalaryPackage
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'EmployeePayrollSlip')
BEGIN
    CREATE TABLE [dbo].[EmployeePayrollSlip] (
        [EmployeePayrollSlipId]    INT IDENTITY(1,1) NOT NULL,
        [PayrollBatchId]           INT NOT NULL,
        [CompanyId]                INT NOT NULL,
        [EmployeeId]               INT NOT NULL,
        [EmploymentId]             INT NOT NULL,
        [SalaryPackageId]          INT NULL,

        [PayslipNumber]            NVARCHAR(30) NOT NULL,
        [PayslipDate]              DATE NOT NULL,
        [PayrollYear]              SMALLINT NOT NULL,
        [PayrollMonth]             TINYINT NOT NULL,
        [CurrencyCode]             CHAR(3) NOT NULL
            CONSTRAINT [DF_EmployeePayrollSlip_CurrencyCode] DEFAULT ('SAR'),

        [EmployeeName]             NVARCHAR(200) NULL,
        [EmployeeNationalId]       NVARCHAR(20) NULL,

        [PackageTotal]             DECIMAL(18,2) NOT NULL,
        [DailyRate]                DECIMAL(18,4) NOT NULL,
        [PresentDays]              INT NOT NULL CONSTRAINT [DF_EmployeePayrollSlip_PresentDays] DEFAULT (0),
        [WeekendDays]              INT NOT NULL CONSTRAINT [DF_EmployeePayrollSlip_WeekendDays] DEFAULT (0),
        [HolidayDays]              INT NOT NULL CONSTRAINT [DF_EmployeePayrollSlip_HolidayDays] DEFAULT (0),
        [PayableAmount]            DECIMAL(18,2) NOT NULL,

        [SlipStatus]               NVARCHAR(20) NOT NULL,
        [Message]                  NVARCHAR(500) NULL,

        [CreatedAt]                DATETIME2(7) NOT NULL
            CONSTRAINT [DF_EmployeePayrollSlip_CreatedAt] DEFAULT (GETDATE()),
        [CreatedBy]                INT NULL,
        [UpdatedAt]                DATETIME2(7) NULL,
        [UpdatedBy]                INT NULL,
        [DeletedAt]                DATETIME2(7) NULL,
        [DeletedBy]                INT NULL,

        CONSTRAINT [PK_EmployeePayrollSlip] PRIMARY KEY ([EmployeePayrollSlipId]),
        CONSTRAINT [FK_EmployeePayrollSlip_PayrollBatch] FOREIGN KEY ([PayrollBatchId]) REFERENCES [dbo].[PayrollBatch] ([PayrollBatchId]),
        CONSTRAINT [FK_EmployeePayrollSlip_Company] FOREIGN KEY ([CompanyId]) REFERENCES [dbo].[Company] ([CompanyId]),
        CONSTRAINT [FK_EmployeePayrollSlip_Employee] FOREIGN KEY ([EmployeeId]) REFERENCES [dbo].[Employee] ([EmployeeId]),
        CONSTRAINT [FK_EmployeePayrollSlip_Employment] FOREIGN KEY ([EmploymentId]) REFERENCES [dbo].[EmployeeEmployment] ([EmploymentId]),
        CONSTRAINT [FK_EmployeePayrollSlip_SalaryPackage] FOREIGN KEY ([SalaryPackageId]) REFERENCES [dbo].[EmployeeSalaryPackage] ([SalaryPackageId]),
        CONSTRAINT [FK_EmployeePayrollSlip_CreatedBy] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [FK_EmployeePayrollSlip_UpdatedBy] FOREIGN KEY ([UpdatedBy]) REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [FK_EmployeePayrollSlip_DeletedBy] FOREIGN KEY ([DeletedBy]) REFERENCES [dbo].[User] ([UserId]),

        CONSTRAINT [CK_EmployeePayrollSlip_PackageTotal_NonNegative] CHECK ([PackageTotal] >= 0),
        CONSTRAINT [CK_EmployeePayrollSlip_DailyRate_NonNegative] CHECK ([DailyRate] >= 0),
        CONSTRAINT [CK_EmployeePayrollSlip_PayableAmount_NonNegative] CHECK ([PayableAmount] >= 0),
        CONSTRAINT [CK_EmployeePayrollSlip_PresentDays_NonNegative] CHECK ([PresentDays] >= 0),
        CONSTRAINT [CK_EmployeePayrollSlip_WeekendDays_NonNegative] CHECK ([WeekendDays] >= 0),
        CONSTRAINT [CK_EmployeePayrollSlip_HolidayDays_NonNegative] CHECK ([HolidayDays] >= 0)
    );

    CREATE UNIQUE NONCLUSTERED INDEX [UX_EmployeePayrollSlip_Company_Employee_Period_Active]
        ON [dbo].[EmployeePayrollSlip]([CompanyId], [EmployeeId], [PayrollYear], [PayrollMonth])
        WHERE [DeletedAt] IS NULL AND [SlipStatus] <> 'Void';

    CREATE UNIQUE NONCLUSTERED INDEX [UX_EmployeePayrollSlip_Company_PayslipNumber_Active]
        ON [dbo].[EmployeePayrollSlip]([CompanyId], [PayslipNumber])
        WHERE [DeletedAt] IS NULL AND [SlipStatus] <> 'Void';

    CREATE NONCLUSTERED INDEX [IX_EmployeePayrollSlip_PayrollBatchId]
        ON [dbo].[EmployeePayrollSlip]([PayrollBatchId])
        INCLUDE ([EmployeeId], [PayableAmount], [SlipStatus], [DeletedAt]);
END
GO
