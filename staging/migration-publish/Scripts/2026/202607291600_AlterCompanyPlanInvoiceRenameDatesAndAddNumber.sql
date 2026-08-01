-- Rename billing dates on CompanyPlanInvoice; add InvoiceNumber + sequence table.
-- AsOfDate → InvoiceDate (billing cycle)
-- InvoiceDate → InvoiceGeneratedDate (when created)
-- LastInvoiceAsOfDate → LastInvoiceDate

-- 1) Free the InvoiceDate name
IF COL_LENGTH(N'dbo.CompanyPlanInvoice', N'InvoiceGeneratedDate') IS NULL
   AND COL_LENGTH(N'dbo.CompanyPlanInvoice', N'InvoiceDate') IS NOT NULL
   AND COL_LENGTH(N'dbo.CompanyPlanInvoice', N'AsOfDate') IS NOT NULL
BEGIN
    EXEC sp_rename N'dbo.CompanyPlanInvoice.InvoiceDate', N'InvoiceGeneratedDate', N'COLUMN';
END
GO

-- 2) AsOfDate → InvoiceDate
IF COL_LENGTH(N'dbo.CompanyPlanInvoice', N'AsOfDate') IS NOT NULL
   AND COL_LENGTH(N'dbo.CompanyPlanInvoice', N'InvoiceDate') IS NULL
BEGIN
    EXEC sp_rename N'dbo.CompanyPlanInvoice.AsOfDate', N'InvoiceDate', N'COLUMN';
END
GO

-- 3) LastInvoiceAsOfDate → LastInvoiceDate
IF COL_LENGTH(N'dbo.CompanyPlanInvoice', N'LastInvoiceAsOfDate') IS NOT NULL
   AND COL_LENGTH(N'dbo.CompanyPlanInvoice', N'LastInvoiceDate') IS NULL
BEGIN
    EXEC sp_rename N'dbo.CompanyPlanInvoice.LastInvoiceAsOfDate', N'LastInvoiceDate', N'COLUMN';
END
GO

-- 4) Replace unique index (PlanRequest, AsOfDate) → (PlanRequest, InvoiceDate)
IF EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'UX_CompanyPlanInvoice_PlanRequest_AsOfDate_Active'
      AND object_id = OBJECT_ID(N'dbo.CompanyPlanInvoice')
)
BEGIN
    DROP INDEX [UX_CompanyPlanInvoice_PlanRequest_AsOfDate_Active] ON [dbo].[CompanyPlanInvoice];
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'UX_CompanyPlanInvoice_PlanRequest_InvoiceDate_Active'
      AND object_id = OBJECT_ID(N'dbo.CompanyPlanInvoice')
)
   AND COL_LENGTH(N'dbo.CompanyPlanInvoice', N'InvoiceDate') IS NOT NULL
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX [UX_CompanyPlanInvoice_PlanRequest_InvoiceDate_Active]
        ON [dbo].[CompanyPlanInvoice] ([CompanyEmployeePlanRequestId], [InvoiceDate])
        WHERE [Status] <> N'Void';
END
GO

-- 5) InvoiceNumber
IF COL_LENGTH(N'dbo.CompanyPlanInvoice', N'InvoiceNumber') IS NULL
BEGIN
    ALTER TABLE [dbo].[CompanyPlanInvoice]
        ADD [InvoiceNumber] NVARCHAR(40) NULL;
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'UX_CompanyPlanInvoice_InvoiceNumber'
      AND object_id = OBJECT_ID(N'dbo.CompanyPlanInvoice')
)
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX [UX_CompanyPlanInvoice_InvoiceNumber]
        ON [dbo].[CompanyPlanInvoice] ([InvoiceNumber])
        WHERE [InvoiceNumber] IS NOT NULL;
END
GO

-- 6) Per company + year sequence for INV-{CompanyId}-{yyyy}-{####}
IF OBJECT_ID(N'dbo.CompanyPlanInvoiceNumberSeq', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[CompanyPlanInvoiceNumberSeq] (
        [CompanyId] INT NOT NULL,
        [Year] INT NOT NULL,
        [LastValue] INT NOT NULL
            CONSTRAINT [DF_CompanyPlanInvoiceNumberSeq_LastValue] DEFAULT (0),
        CONSTRAINT [PK_CompanyPlanInvoiceNumberSeq] PRIMARY KEY ([CompanyId], [Year]),
        CONSTRAINT [FK_CompanyPlanInvoiceNumberSeq_Company]
            FOREIGN KEY ([CompanyId]) REFERENCES [dbo].[Company] ([CompanyId]) ON DELETE NO ACTION
    );
END
GO
