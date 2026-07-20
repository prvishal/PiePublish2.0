-- Create EmployeePlan table. Pie offers plans to companies.
-- Add/Edit/Delete: PieAdmin, PieManager. View: PieAdmin, PieManager, ClientAdmin, ClientManager, CompanyAdmin.
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'EmployeePlan')
BEGIN
    CREATE TABLE [dbo].[EmployeePlan] (
        [EmployeePlanId] INT IDENTITY(1,1) NOT NULL,
        [Title] NVARCHAR(200) NOT NULL,
        [Duration] INT NOT NULL,
        [NumberOfEmployees] INT NOT NULL,
        [Amount] DECIMAL(18,2) NOT NULL,
        [IsActive] BIT NOT NULL CONSTRAINT [DF_EmployeePlan_IsActive] DEFAULT (1),
        [CreatedAt] DATETIME2(7) NOT NULL CONSTRAINT [DF_EmployeePlan_CreatedAt] DEFAULT (GETDATE()),
        [CreatedBy] INT NULL,
        [UpdatedAt] DATETIME2(7) NULL,
        [UpdatedBy] INT NULL,
        [DeletedAt] DATETIME2(7) NULL,
        [DeletedBy] INT NULL,
        CONSTRAINT [PK_EmployeePlan] PRIMARY KEY ([EmployeePlanId]),
        CONSTRAINT [FK_EmployeePlan_CreatedBy] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [FK_EmployeePlan_UpdatedBy] FOREIGN KEY ([UpdatedBy]) REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [FK_EmployeePlan_DeletedBy] FOREIGN KEY ([DeletedBy]) REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [CK_EmployeePlan_Duration] CHECK ([Duration] IN (3, 6, 9, 12))
    );
END
GO
