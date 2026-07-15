-- Line rows for CompanyPlanInvoice (Headcount / NewJoining).
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'CompanyPlanInvoiceLine')
BEGIN
    CREATE TABLE [dbo].[CompanyPlanInvoiceLine] (
        [CompanyPlanInvoiceLineId] INT IDENTITY(1,1) NOT NULL,
        [CompanyPlanInvoiceId] INT NOT NULL,
        [LineType] NVARCHAR(30) NOT NULL,
        [EmployeeCount] INT NOT NULL,
        [UnitRate] DECIMAL(18,4) NOT NULL,
        [Amount] DECIMAL(18,2) NOT NULL,
        [SortOrder] INT NOT NULL
            CONSTRAINT [DF_CompanyPlanInvoiceLine_SortOrder] DEFAULT (1),
        CONSTRAINT [PK_CompanyPlanInvoiceLine] PRIMARY KEY ([CompanyPlanInvoiceLineId]),
        CONSTRAINT [FK_CompanyPlanInvoiceLine_Invoice]
            FOREIGN KEY ([CompanyPlanInvoiceId])
            REFERENCES [dbo].[CompanyPlanInvoice] ([CompanyPlanInvoiceId])
            ON DELETE CASCADE,
        CONSTRAINT [CK_CompanyPlanInvoiceLine_LineType]
            CHECK ([LineType] IN (N'Headcount', N'NewJoining')),
        CONSTRAINT [CK_CompanyPlanInvoiceLine_EmployeeCount]
            CHECK ([EmployeeCount] >= 0)
    );

    CREATE NONCLUSTERED INDEX [IX_CompanyPlanInvoiceLine_InvoiceId]
        ON [dbo].[CompanyPlanInvoiceLine] ([CompanyPlanInvoiceId], [SortOrder]);
END
GO
