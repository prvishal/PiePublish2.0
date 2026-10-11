-- Employee device binding (history + one active) and registration requests for second+ devices.
-- Attendance punch stores DeviceId + biometric verified flags (no fingerprint templates).

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = N'EmployeeDevice')
BEGIN
    CREATE TABLE [dbo].[EmployeeDevice] (
        [EmployeeDeviceId] INT IDENTITY(1,1) NOT NULL,
        [EmployeeId] INT NOT NULL,
        [DeviceId] NVARCHAR(100) NOT NULL,
        [Platform] NVARCHAR(20) NOT NULL,
        [DeviceLabel] NVARCHAR(100) NULL,
        [IsActive] BIT NOT NULL
            CONSTRAINT [DF_EmployeeDevice_IsActive] DEFAULT (0),
        [BiometricEnrolledAt] DATETIME2(7) NULL,
        [ActivatedAt] DATETIME2(7) NULL,
        [DeactivatedAt] DATETIME2(7) NULL,
        [CreatedAt] DATETIME2(7) NOT NULL
            CONSTRAINT [DF_EmployeeDevice_CreatedAt] DEFAULT (GETDATE()),
        [CreatedBy] INT NULL,
        [UpdatedAt] DATETIME2(7) NULL,
        [UpdatedBy] INT NULL,
        [DeletedAt] DATETIME2(7) NULL,
        [DeletedBy] INT NULL,

        CONSTRAINT [PK_EmployeeDevice] PRIMARY KEY ([EmployeeDeviceId]),
        CONSTRAINT [FK_EmployeeDevice_Employee] FOREIGN KEY ([EmployeeId])
            REFERENCES [dbo].[Employee] ([EmployeeId]),
        CONSTRAINT [FK_EmployeeDevice_CreatedBy] FOREIGN KEY ([CreatedBy])
            REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [FK_EmployeeDevice_UpdatedBy] FOREIGN KEY ([UpdatedBy])
            REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [FK_EmployeeDevice_DeletedBy] FOREIGN KEY ([DeletedBy])
            REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [CK_EmployeeDevice_Platform] CHECK ([Platform] IN (N'android', N'ios'))
    );

    CREATE UNIQUE NONCLUSTERED INDEX [UX_EmployeeDevice_Employee_Active]
        ON [dbo].[EmployeeDevice]([EmployeeId])
        WHERE [IsActive] = 1 AND [DeletedAt] IS NULL;

    CREATE UNIQUE NONCLUSTERED INDEX [UX_EmployeeDevice_Employee_Device]
        ON [dbo].[EmployeeDevice]([EmployeeId], [DeviceId])
        WHERE [DeletedAt] IS NULL;
END
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = N'EmployeeDeviceRegistrationRequest')
BEGIN
    CREATE TABLE [dbo].[EmployeeDeviceRegistrationRequest] (
        [EmployeeDeviceRegistrationRequestId] INT IDENTITY(1,1) NOT NULL,
        [EmployeeId] INT NOT NULL,
        [DeviceId] NVARCHAR(100) NOT NULL,
        [Platform] NVARCHAR(20) NOT NULL,
        [Status] TINYINT NOT NULL,
        [RequestedAt] DATETIME2(7) NOT NULL
            CONSTRAINT [DF_EmpDevReg_RequestedAt] DEFAULT (GETDATE()),
        [ReviewedAt] DATETIME2(7) NULL,
        [ReviewedBy] INT NULL,
        [ReviewNote] NVARCHAR(500) NULL,
        [CreatedAt] DATETIME2(7) NOT NULL
            CONSTRAINT [DF_EmpDevReg_CreatedAt] DEFAULT (GETDATE()),
        [CreatedBy] INT NULL,
        [UpdatedAt] DATETIME2(7) NULL,
        [UpdatedBy] INT NULL,
        [DeletedAt] DATETIME2(7) NULL,
        [DeletedBy] INT NULL,

        CONSTRAINT [PK_EmployeeDeviceRegistrationRequest] PRIMARY KEY ([EmployeeDeviceRegistrationRequestId]),
        CONSTRAINT [FK_EmpDevReg_Employee] FOREIGN KEY ([EmployeeId])
            REFERENCES [dbo].[Employee] ([EmployeeId]),
        CONSTRAINT [FK_EmpDevReg_ReviewedBy] FOREIGN KEY ([ReviewedBy])
            REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [FK_EmpDevReg_CreatedBy] FOREIGN KEY ([CreatedBy])
            REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [FK_EmpDevReg_UpdatedBy] FOREIGN KEY ([UpdatedBy])
            REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [FK_EmpDevReg_DeletedBy] FOREIGN KEY ([DeletedBy])
            REFERENCES [dbo].[User] ([UserId]),
        CONSTRAINT [CK_EmpDevReg_Status] CHECK ([Status] IN (1, 2, 3, 4)),
        CONSTRAINT [CK_EmpDevReg_Platform] CHECK ([Platform] IN (N'android', N'ios'))
    );

    CREATE UNIQUE NONCLUSTERED INDEX [UX_EmpDevReg_Employee_Pending]
        ON [dbo].[EmployeeDeviceRegistrationRequest]([EmployeeId])
        WHERE [Status] = 1 AND [DeletedAt] IS NULL;

    CREATE NONCLUSTERED INDEX [IX_EmpDevReg_Status_RequestedAt]
        ON [dbo].[EmployeeDeviceRegistrationRequest]([Status], [RequestedAt])
        WHERE [DeletedAt] IS NULL;
END
GO

IF COL_LENGTH(N'dbo.EmployeeAttendance', N'DeviceId') IS NULL
BEGIN
    ALTER TABLE [dbo].[EmployeeAttendance] ADD
        [DeviceId] NVARCHAR(100) NULL,
        [CheckInBiometricVerified] BIT NULL,
        [CheckOutBiometricVerified] BIT NULL;
END
GO
