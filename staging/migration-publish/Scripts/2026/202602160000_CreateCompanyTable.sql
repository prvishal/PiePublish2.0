-- Create Company table. Runs only once (tracked in __ScriptHistory).
-- ClientId links Company to Client. Run after CreateClientTable.
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Company')
BEGIN
    CREATE TABLE [dbo].[Company] (
        [CompanyId] INT IDENTITY(1,1) NOT NULL,
        [ClientId] INT NOT NULL,
        [CompanyName] NVARCHAR(200) NULL,
        [Description] NVARCHAR(MAX) NULL,
        [EstLaborOfficeId] VARCHAR(50) NULL,
        [Mobile] VARCHAR(20) NULL,
        [City] NVARCHAR(200) NULL,
        [Address] NVARCHAR(MAX) NULL,
        [Website] VARCHAR(200) NULL,
        [Fax] VARCHAR(20) NULL,
        [Phone] VARCHAR(20) NULL,
        [Logo] VARCHAR(100) NULL,
        [RegistrationDate] DATE NOT NULL,
        [ValidityTill] DATE NULL,
        [CR_Number] VARCHAR(20) NULL,
        [InsuranceIDNumber] VARCHAR(20) NULL,
        [MID] FLOAT NULL,
        [Industry] NVARCHAR(245) NULL,
        [EstSequenceNumber] BIGINT NULL,
        [DeletedAt] DATETIME2(7) NULL,
        [DeletedBy] INT NULL,
        CONSTRAINT [PK_Company] PRIMARY KEY ([CompanyId]),
        CONSTRAINT [FK_Company_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId]) ON DELETE NO ACTION,
        CONSTRAINT [FK_Company_DeletedBy] FOREIGN KEY ([DeletedBy]) REFERENCES [dbo].[User] ([UserId])
    );
END
GO
