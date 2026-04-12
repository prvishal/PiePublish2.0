-- Replace ON DELETE CASCADE with NO ACTION on Client/Company parent FKs so accidental
-- DELETE of Client or Company does not silently remove dependent rows. Application must
-- remove or reassign children first, or use soft delete.
-- Safe to re-run: drops and recreates the same constraint names with NO ACTION.

IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Company_Client' AND parent_object_id = OBJECT_ID(N'dbo.Company'))
    ALTER TABLE [dbo].[Company] DROP CONSTRAINT [FK_Company_Client];
GO

IF OBJECT_ID(N'dbo.Company', N'U') IS NOT NULL
    AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Company_Client' AND parent_object_id = OBJECT_ID(N'dbo.Company'))
    ALTER TABLE [dbo].[Company] WITH CHECK ADD CONSTRAINT [FK_Company_Client]
        FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId]) ON DELETE NO ACTION;
GO

IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_UserClient_Client' AND parent_object_id = OBJECT_ID(N'dbo.UserClient'))
    ALTER TABLE [dbo].[UserClient] DROP CONSTRAINT [FK_UserClient_Client];
GO

IF OBJECT_ID(N'dbo.UserClient', N'U') IS NOT NULL
    AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_UserClient_Client' AND parent_object_id = OBJECT_ID(N'dbo.UserClient'))
    ALTER TABLE [dbo].[UserClient] WITH CHECK ADD CONSTRAINT [FK_UserClient_Client]
        FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId]) ON DELETE NO ACTION;
GO

IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_PieManagerClient_Client' AND parent_object_id = OBJECT_ID(N'dbo.PieManagerClient'))
    ALTER TABLE [dbo].[PieManagerClient] DROP CONSTRAINT [FK_PieManagerClient_Client];
GO

IF OBJECT_ID(N'dbo.PieManagerClient', N'U') IS NOT NULL
    AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_PieManagerClient_Client' AND parent_object_id = OBJECT_ID(N'dbo.PieManagerClient'))
    ALTER TABLE [dbo].[PieManagerClient] WITH CHECK ADD CONSTRAINT [FK_PieManagerClient_Client]
        FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId]) ON DELETE NO ACTION;
GO

IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_UserCompany_Company' AND parent_object_id = OBJECT_ID(N'dbo.UserCompany'))
    ALTER TABLE [dbo].[UserCompany] DROP CONSTRAINT [FK_UserCompany_Company];
GO

IF OBJECT_ID(N'dbo.UserCompany', N'U') IS NOT NULL
    AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_UserCompany_Company' AND parent_object_id = OBJECT_ID(N'dbo.UserCompany'))
    ALTER TABLE [dbo].[UserCompany] WITH CHECK ADD CONSTRAINT [FK_UserCompany_Company]
        FOREIGN KEY ([CompanyId]) REFERENCES [dbo].[Company] ([CompanyId]) ON DELETE NO ACTION;
GO

IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_CompanyEmployeePlanRequest_Company' AND parent_object_id = OBJECT_ID(N'dbo.CompanyEmployeePlanRequest'))
    ALTER TABLE [dbo].[CompanyEmployeePlanRequest] DROP CONSTRAINT [FK_CompanyEmployeePlanRequest_Company];
GO

IF OBJECT_ID(N'dbo.CompanyEmployeePlanRequest', N'U') IS NOT NULL
    AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_CompanyEmployeePlanRequest_Company' AND parent_object_id = OBJECT_ID(N'dbo.CompanyEmployeePlanRequest'))
    ALTER TABLE [dbo].[CompanyEmployeePlanRequest] WITH CHECK ADD CONSTRAINT [FK_CompanyEmployeePlanRequest_Company]
        FOREIGN KEY ([CompanyId]) REFERENCES [dbo].[Company] ([CompanyId]) ON DELETE NO ACTION;
GO
