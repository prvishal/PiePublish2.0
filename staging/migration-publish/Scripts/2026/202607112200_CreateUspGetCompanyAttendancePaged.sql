-- Paged company attendance list for GET /api/Company/{id}/attendance
-- Prerequisites: dbo.EmployeeAttendance, dbo.Employee, dbo.CompanyBatch
CREATE OR ALTER PROCEDURE [dbo].[usp_GetCompanyAttendancePaged]
    @CompanyId    INT,
    @From         DATE = NULL,
    @To           DATE = NULL,
    @EmployeeId   INT = NULL,
    @PageNumber   INT = 1,
    @PageSize     INT = 50,
    @TotalCount   INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF @PageNumber < 1 SET @PageNumber = 1;
    IF @PageSize < 1 SET @PageSize = 50;
    IF @PageSize > 100 SET @PageSize = 100;

    SELECT @TotalCount = COUNT(1)
    FROM [dbo].[EmployeeAttendance] a
    WHERE a.[DeletedAt] IS NULL
      AND a.[CompanyId] = @CompanyId
      AND (@From IS NULL OR a.[WorkDate] >= @From)
      AND (@To IS NULL OR a.[WorkDate] <= @To)
      AND (@EmployeeId IS NULL OR a.[EmployeeId] = @EmployeeId);

    SELECT
        a.[EmployeeAttendanceId],
        a.[EmployeeId],
        e.[Name] AS [EmployeeName],
        a.[EmploymentId],
        a.[CompanyId],
        a.[CompanyBatchId],
        b.[BatchName] AS [CompanyBatchName],
        a.[WorkDate],
        a.[CheckInAt],
        a.[CheckOutAt],
        a.[CheckInLatitude],
        a.[CheckInLongitude],
        a.[CheckOutLatitude],
        a.[CheckOutLongitude],
        a.[DayType],
        a.[Status],
        a.[Source],
        a.[Notes]
    FROM [dbo].[EmployeeAttendance] a
    INNER JOIN [dbo].[Employee] e ON e.[EmployeeId] = a.[EmployeeId]
    LEFT JOIN [dbo].[CompanyBatch] b ON b.[CompanyBatchId] = a.[CompanyBatchId]
    WHERE a.[DeletedAt] IS NULL
      AND a.[CompanyId] = @CompanyId
      AND (@From IS NULL OR a.[WorkDate] >= @From)
      AND (@To IS NULL OR a.[WorkDate] <= @To)
      AND (@EmployeeId IS NULL OR a.[EmployeeId] = @EmployeeId)
    ORDER BY a.[WorkDate] DESC, a.[CheckInAt] DESC
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END
GO
