-- Add Address, Mobile, Phone to Client table.
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Client')
BEGIN
    IF COLUMNPROPERTY(OBJECT_ID('dbo.Client'), 'Address', 'ColumnId') IS NULL
        ALTER TABLE [dbo].[Client] ADD [Address] NVARCHAR(500) NULL;
    IF COLUMNPROPERTY(OBJECT_ID('dbo.Client'), 'Mobile', 'ColumnId') IS NULL
        ALTER TABLE [dbo].[Client] ADD [Mobile] NVARCHAR(50) NULL;
    IF COLUMNPROPERTY(OBJECT_ID('dbo.Client'), 'Phone', 'ColumnId') IS NULL
        ALTER TABLE [dbo].[Client] ADD [Phone] NVARCHAR(50) NULL;

    -- Update existing seed/dummy rows with placeholder contact data
    UPDATE [dbo].[Client]
    SET [Address] = N'123 Main Street, City',
        [Mobile] = N'+1 555-0100',
        [Phone] = N'+1 555-0199'
    WHERE [ClientId] = 1 AND ([Address] IS NULL AND [Mobile] IS NULL AND [Phone] IS NULL);

    UPDATE [dbo].[Client]
    SET [Address] = N'456 Oak Avenue, Town',
        [Mobile] = N'+1 555-0200',
        [Phone] = N'+1 555-0299'
    WHERE [ClientId] = 2 AND ([Address] IS NULL AND [Mobile] IS NULL AND [Phone] IS NULL);
END
GO
