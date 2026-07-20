-- Company batch: per-company business rules (attendance working hours 4-8).
-- BatchId = user-defined code (NOT identity), max 10 chars.
-- BatchId and BatchName are unique per company even after soft delete.
-- Prerequisites: dbo.Company, dbo.[User].
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'CompanyBatch')
BEGIN
    CREATE TABLE [dbo].[CompanyBatch] (
        [CompanyBatchId] INT IDENTITY(1,1) NOT NULL,
        [CompanyId] INT NOT NULL,
        [BatchId] VARCHAR(10) NOT NULL,
        [BatchName] NVARCHAR(100) NOT NULL,
        [WorkingHoursPerDay] DECIMAL(3,1) NOT NULL
            CONSTRAINT [DF_CompanyBatch_WorkingHoursPerDay] DEFAULT (8.0),
        [CreatedAt] DATETIME2(7) NOT NULL
            CONSTRAINT [DF_CompanyBatch_CreatedAt] DEFAULT (GETDATE()),
        [CreatedBy] INT NULL,
        [UpdatedAt] DATETIME2(7) NULL,
        [UpdatedBy] INT NULL,
        [DeletedAt] DATETIME2(7) NULL,
        [DeletedBy] INT NULL,
        CONSTRAINT [PK_CompanyBatch] PRIMARY KEY ([CompanyBatchId]),
        CONSTRAINT [FK_CompanyBatch_Company] FOREIGN KEY ([CompanyId])
            REFERENCES [dbo].[Company] ([CompanyId]) ON DELETE NO ACTION,
        CONSTRAINT [FK_CompanyBatch_CreatedBy] FOREIGN KEY ([CreatedBy])
            REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [FK_CompanyBatch_UpdatedBy] FOREIGN KEY ([UpdatedBy])
            REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [FK_CompanyBatch_DeletedBy] FOREIGN KEY ([DeletedBy])
            REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [CK_CompanyBatch_WorkingHoursPerDay]
            CHECK ([WorkingHoursPerDay] >= 4.0 AND [WorkingHoursPerDay] <= 8.0),
        CONSTRAINT [CK_CompanyBatch_BatchId_NotBlank]
            CHECK (LTRIM(RTRIM([BatchId])) <> '')
    );

    CREATE UNIQUE NONCLUSTERED INDEX [UX_CompanyBatch_CompanyId_BatchId]
        ON [dbo].[CompanyBatch]([CompanyId], [BatchId]);

    CREATE UNIQUE NONCLUSTERED INDEX [UX_CompanyBatch_CompanyId_BatchName]
        ON [dbo].[CompanyBatch]([CompanyId], [BatchName]);

    CREATE NONCLUSTERED INDEX [IX_CompanyBatch_CompanyId_DeletedAt]
        ON [dbo].[CompanyBatch]([CompanyId], [DeletedAt])
        INCLUDE ([BatchId], [BatchName], [WorkingHoursPerDay]);
END
GO
