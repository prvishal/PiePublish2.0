-- Company plan invoice header (one document; lines in CompanyPlanInvoiceLine).
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'CompanyPlanInvoice')
BEGIN
    CREATE TABLE [dbo].[CompanyPlanInvoice] (
        [CompanyPlanInvoiceId] INT IDENTITY(1,1) NOT NULL,
        [CompanyEmployeePlanRequestId] INT NOT NULL,
        [CompanyId] INT NOT NULL,
        [ClientId] INT NOT NULL,
        [AsOfDate] DATE NOT NULL,
        [InvoiceDate] DATE NOT NULL,
        [LastInvoiceAsOfDate] DATE NULL,
        [TotalAmount] DECIMAL(18,2) NOT NULL
            CONSTRAINT [DF_CompanyPlanInvoice_TotalAmount] DEFAULT (0),
        [Status] NVARCHAR(30) NOT NULL
            CONSTRAINT [DF_CompanyPlanInvoice_Status] DEFAULT (N'Issued'),
        [CreatedAt] DATETIME2(7) NOT NULL
            CONSTRAINT [DF_CompanyPlanInvoice_CreatedAt] DEFAULT (SYSUTCDATETIME()),
        [CreatedBy] INT NULL,
        [UpdatedAt] DATETIME2(7) NULL,
        [UpdatedBy] INT NULL,
        CONSTRAINT [PK_CompanyPlanInvoice] PRIMARY KEY ([CompanyPlanInvoiceId]),
        CONSTRAINT [FK_CompanyPlanInvoice_PlanRequest]
            FOREIGN KEY ([CompanyEmployeePlanRequestId])
            REFERENCES [dbo].[CompanyEmployeePlanRequest] ([CompanyEmployeePlanRequestId])
            ON DELETE NO ACTION,
        CONSTRAINT [FK_CompanyPlanInvoice_Company]
            FOREIGN KEY ([CompanyId]) REFERENCES [dbo].[Company] ([CompanyId]) ON DELETE NO ACTION,
        CONSTRAINT [FK_CompanyPlanInvoice_Client]
            FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId]) ON DELETE NO ACTION,
        CONSTRAINT [FK_CompanyPlanInvoice_CreatedBy]
            FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [FK_CompanyPlanInvoice_UpdatedBy]
            FOREIGN KEY ([UpdatedBy]) REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [CK_CompanyPlanInvoice_Status]
            CHECK ([Status] IN (N'Draft', N'Issued', N'Void'))
    );

    CREATE UNIQUE NONCLUSTERED INDEX [UX_CompanyPlanInvoice_PlanRequest_AsOfDate_Active]
        ON [dbo].[CompanyPlanInvoice] ([CompanyEmployeePlanRequestId], [AsOfDate])
        WHERE [Status] <> N'Void';

    CREATE NONCLUSTERED INDEX [IX_CompanyPlanInvoice_CompanyId]
        ON [dbo].[CompanyPlanInvoice] ([CompanyId], [InvoiceDate] DESC);
END
GO
