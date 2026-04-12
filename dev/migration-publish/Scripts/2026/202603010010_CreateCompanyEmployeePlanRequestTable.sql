-- Create dbo.CompanyEmployeePlanRequest only (no other objects in this file).
-- Prerequisites: dbo.EmployeePlan, dbo.Company, dbo.Client, dbo.User must already exist.
-- FKs use ON DELETE NO ACTION on Client/Company parents so mistaken deletes do not cascade-remove rows.
-- Direct assignment by Pie or client request with approval. One active per company (enforced in code).
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'CompanyEmployeePlanRequest')
BEGIN
    CREATE TABLE [dbo].[CompanyEmployeePlanRequest] (
        [CompanyEmployeePlanRequestId] INT IDENTITY(1,1) NOT NULL,
        [EmployeePlanId] INT NULL,
        [CompanyId] INT NOT NULL,
        [ClientId] INT NOT NULL,
        [Title] NVARCHAR(200) NOT NULL,
        [Duration] INT NOT NULL,
        [NumberOfEmployees] INT NOT NULL,
        [Amount] DECIMAL(18,2) NOT NULL,
        [StartDate] DATE NOT NULL,
        [EndDate] DATE NOT NULL,
        [Status] NVARCHAR(50) NOT NULL,
        [RequestedBy] INT NULL,
        [RequestedAt] DATETIME2(7) NULL,
        [ApprovedBy] INT NULL,
        [ApprovedAt] DATETIME2(7) NULL,
        [RejectionReason] NVARCHAR(500) NULL,
        [IsActive] BIT NOT NULL CONSTRAINT [DF_CompanyEmployeePlanRequest_IsActive] DEFAULT (0),
        [CreatedAt] DATETIME2(7) NOT NULL CONSTRAINT [DF_CompanyEmployeePlanRequest_CreatedAt] DEFAULT (GETDATE()),
        [CreatedBy] INT NULL,
        [UpdatedAt] DATETIME2(7) NULL,
        [UpdatedBy] INT NULL,
        [DeletedAt] DATETIME2(7) NULL,
        [DeletedBy] INT NULL,
        CONSTRAINT [PK_CompanyEmployeePlanRequest] PRIMARY KEY ([CompanyEmployeePlanRequestId]),
        CONSTRAINT [FK_CompanyEmployeePlanRequest_EmployeePlan] FOREIGN KEY ([EmployeePlanId]) REFERENCES [dbo].[EmployeePlan] ([EmployeePlanId]),
        CONSTRAINT [FK_CompanyEmployeePlanRequest_Company] FOREIGN KEY ([CompanyId]) REFERENCES [dbo].[Company] ([CompanyId]) ON DELETE NO ACTION,
        CONSTRAINT [FK_CompanyEmployeePlanRequest_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId]) ON DELETE NO ACTION,
        CONSTRAINT [FK_CompanyEmployeePlanRequest_RequestedBy] FOREIGN KEY ([RequestedBy]) REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [FK_CompanyEmployeePlanRequest_ApprovedBy] FOREIGN KEY ([ApprovedBy]) REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [FK_CompanyEmployeePlanRequest_CreatedBy] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [FK_CompanyEmployeePlanRequest_UpdatedBy] FOREIGN KEY ([UpdatedBy]) REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [FK_CompanyEmployeePlanRequest_DeletedBy] FOREIGN KEY ([DeletedBy]) REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [CK_CompanyEmployeePlanRequest_Status] CHECK ([Status] IN ('Pending', 'Approved', 'Rejected')),
        CONSTRAINT [CK_CompanyEmployeePlanRequest_Duration] CHECK ([Duration] IN (3, 6, 9, 12)),
        CONSTRAINT [CK_CompanyEmployeePlanRequest_EndDate] CHECK ([EndDate] >= [StartDate])
    );
END
GO
