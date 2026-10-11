-- One physical phone (DeviceId) may have only one active employee binding.
-- Another employee cannot activate/login on that phone until it is deactivated.

IF EXISTS (SELECT * FROM sys.tables WHERE name = N'EmployeeDevice')
   AND NOT EXISTS (
        SELECT 1 FROM sys.indexes
        WHERE name = N'UX_EmployeeDevice_Device_Active'
          AND object_id = OBJECT_ID(N'dbo.EmployeeDevice')
   )
BEGIN
    -- Fail early if duplicates already exist (same DeviceId active for 2+ employees).
    IF EXISTS (
        SELECT DeviceId
        FROM dbo.EmployeeDevice
        WHERE IsActive = 1 AND DeletedAt IS NULL
        GROUP BY DeviceId
        HAVING COUNT(*) > 1
    )
    BEGIN
        THROW 50001, N'Cannot create UX_EmployeeDevice_Device_Active: duplicate active DeviceId rows exist. Deactivate extras first.', 1;
    END;

    CREATE UNIQUE NONCLUSTERED INDEX [UX_EmployeeDevice_Device_Active]
        ON [dbo].[EmployeeDevice]([DeviceId])
        WHERE [IsActive] = 1 AND [DeletedAt] IS NULL;
END
GO
