-- Per-row outcomes for attendance bulk import batches.
-- Prerequisites: dbo.AttendanceImportBatch, dbo.EmployeeAttendance.
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'AttendanceImportRowResult')
BEGIN
    CREATE TABLE [dbo].[AttendanceImportRowResult] (
        [AttendanceImportRowResultId] INT IDENTITY(1,1) NOT NULL,
        [AttendanceImportBatchId] INT NOT NULL,
        [RowNumber] INT NOT NULL,
        [Email] NVARCHAR(255) NULL,
        [Status] VARCHAR(20) NOT NULL,
        [Message] NVARCHAR(2000) NULL,
        [EmployeeAttendanceId] INT NULL,
        [Action] VARCHAR(20) NULL,
        CONSTRAINT [PK_AttendanceImportRowResult] PRIMARY KEY ([AttendanceImportRowResultId]),
        CONSTRAINT [FK_AttendanceImportRowResult_Batch] FOREIGN KEY ([AttendanceImportBatchId])
            REFERENCES [dbo].[AttendanceImportBatch] ([AttendanceImportBatchId]) ON DELETE CASCADE,
        CONSTRAINT [FK_AttendanceImportRowResult_Attendance] FOREIGN KEY ([EmployeeAttendanceId])
            REFERENCES [dbo].[EmployeeAttendance] ([EmployeeAttendanceId])
    );

    CREATE UNIQUE NONCLUSTERED INDEX [UX_AttendanceImportRowResult_Batch_Row]
        ON [dbo].[AttendanceImportRowResult]([AttendanceImportBatchId], [RowNumber]);
END
GO
