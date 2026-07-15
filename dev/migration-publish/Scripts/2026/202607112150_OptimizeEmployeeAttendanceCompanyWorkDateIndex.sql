-- Optimize company attendance list/count (CompanyId + WorkDate).
-- Replaces IX_EmployeeAttendance_Company_WorkDate with a covering filtered index.
-- Prerequisites: dbo.EmployeeAttendance (202606231010).
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'EmployeeAttendance')
BEGIN
    IF EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'IX_EmployeeAttendance_Company_WorkDate'
          AND object_id = OBJECT_ID(N'dbo.EmployeeAttendance')
    )
    BEGIN
        DROP INDEX [IX_EmployeeAttendance_Company_WorkDate]
            ON [dbo].[EmployeeAttendance];
    END

    CREATE NONCLUSTERED INDEX [IX_EmployeeAttendance_Company_WorkDate]
        ON [dbo].[EmployeeAttendance]([CompanyId], [WorkDate])
        INCLUDE (
            [EmployeeId],
            [EmploymentId],
            [CompanyBatchId],
            [CheckInAt],
            [CheckOutAt],
            [DayType],
            [Status],
            [Source]
        )
        WHERE [DeletedAt] IS NULL;

    UPDATE STATISTICS [dbo].[EmployeeAttendance] WITH FULLSCAN;
END
GO
