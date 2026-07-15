-- Batch assignment history per employment stint. Prerequisites: dbo.EmployeeEmployment, dbo.CompanyBatch.
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'EmployeeCompanyBatchHistory')
BEGIN
    CREATE TABLE [dbo].[EmployeeCompanyBatchHistory] (
        [EmployeeCompanyBatchHistoryId] INT IDENTITY(1,1) NOT NULL,
        [EmploymentId] INT NOT NULL,
        [CompanyBatchId] INT NOT NULL,
        [EffectiveFrom] DATE NOT NULL,
        [EffectiveTo] DATE NULL,
        [CreatedAt] DATETIME2(7) NOT NULL CONSTRAINT [DF_EmployeeCompanyBatchHistory_CreatedAt] DEFAULT (GETDATE()),
        [CreatedBy] INT NULL,
        [UpdatedAt] DATETIME2(7) NULL,
        [UpdatedBy] INT NULL,
        [DeletedAt] DATETIME2(7) NULL,
        [DeletedBy] INT NULL,
        CONSTRAINT [PK_EmployeeCompanyBatchHistory] PRIMARY KEY ([EmployeeCompanyBatchHistoryId]),
        CONSTRAINT [FK_EmployeeCompanyBatchHistory_Employment] FOREIGN KEY ([EmploymentId]) REFERENCES [dbo].[EmployeeEmployment] ([EmploymentId]),
        CONSTRAINT [FK_EmployeeCompanyBatchHistory_CompanyBatch] FOREIGN KEY ([CompanyBatchId]) REFERENCES [dbo].[CompanyBatch] ([CompanyBatchId]),
        CONSTRAINT [FK_EmployeeCompanyBatchHistory_CreatedBy] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [FK_EmployeeCompanyBatchHistory_UpdatedBy] FOREIGN KEY ([UpdatedBy]) REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [FK_EmployeeCompanyBatchHistory_DeletedBy] FOREIGN KEY ([DeletedBy]) REFERENCES [dbo].[User] ([UserId])
    );
    CREATE NONCLUSTERED INDEX [IX_EmployeeCompanyBatchHistory_EmploymentId_EffectiveFrom]
        ON [dbo].[EmployeeCompanyBatchHistory] ([EmploymentId], [EffectiveFrom])
        INCLUDE ([EffectiveTo], [CompanyBatchId], [DeletedAt]);
END
GO

INSERT INTO [dbo].[EmployeeCompanyBatchHistory] ([EmploymentId], [CompanyBatchId], [EffectiveFrom], [EffectiveTo], [CreatedAt])
SELECT ee.[EmploymentId], ee.[CompanyBatchId], ee.[JoiningDate], NULL, GETDATE()
FROM [dbo].[EmployeeEmployment] ee
WHERE ee.[DeletedAt] IS NULL
  AND ee.[CompanyBatchId] IS NOT NULL
  AND NOT EXISTS (
      SELECT 1 FROM [dbo].[EmployeeCompanyBatchHistory] h
      WHERE h.[EmploymentId] = ee.[EmploymentId] AND h.[DeletedAt] IS NULL
  );
GO
