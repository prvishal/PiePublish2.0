-- Alter Employee: add LocationURL, BankName, BankAccount.
-- Prerequisites: dbo.Employee (202605171010_CreateEmployeeTable.sql).
-- Runs only once (tracked in __ScriptHistory).
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Employee')
BEGIN
    IF COLUMNPROPERTY(OBJECT_ID('dbo.Employee'), 'LocationURL', 'ColumnId') IS NULL
        ALTER TABLE [dbo].[Employee] ADD [LocationURL] NVARCHAR(4000) NULL;

    IF COLUMNPROPERTY(OBJECT_ID('dbo.Employee'), 'BankName', 'ColumnId') IS NULL
        ALTER TABLE [dbo].[Employee] ADD [BankName] NVARCHAR(200) NULL;

    IF COLUMNPROPERTY(OBJECT_ID('dbo.Employee'), 'BankAccount', 'ColumnId') IS NULL
        ALTER TABLE [dbo].[Employee] ADD [BankAccount] VARCHAR(100) NULL;
END
GO
